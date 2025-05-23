import processing.core.*; 
import processing.xml.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class simanem extends PApplet {

/******************************************************************************
Simulador gr\u00e1fico do microcontrolador ANEM
Autor: Jo\u00e3o Paulo Cerquinho Cajueiro
 ******************************************************************************/

RegFile regfile;
Register regA,regB,ulaOut;
Register instruction,reg_in;
Ula ULA;
Memory instMem,dataMem;
Control control;
Pc PC;

int AdrA, AdrB, func, opcode, inByte, ende;

public void setup(){
  background(255);
  size(600,600);
  instruction = new Register("Instruction",120,20);
  instMem = new Memory(10,300,"cod_maquina.hex");
  dataMem = new Memory(310,300);
  reg_in= new Register("Memory Input",220,20);
  PC = new Pc(200,200);
  regfile = new RegFile(16,30,70);
  //for (int i = 1; i<16; i++){
  //  regfile.write(i,floor(random(0x10000)));
  //}
  regA = new Register("A OUT",200,70);
  regB = new Register("B OUT",200,120);
  ULA = new Ula(320,73);
  ulaOut = new Register("ULA out",480,95);
  control = new Control(360,200);
//  regfile.display();
//  noLoop();
}

public void display(){
/* Todos os comandos gr\u00e1ficos s\u00e3o executados  desta fun\u00e7\u00e3o.
   Cada objeto gr\u00e1fico deve ter um m\u00e9todo display() para ser chamado aqui.*/

  background(255);
  fill(0);

  //CLOCK
  rect(0,0,40,40);
  textAlign(CENTER);
  fill(255);
  text("CK",20,26);
  stroke(0);

  // Instru\u00e7\u00e3o atual
  instruction.display();

  //Entrada de dados da mem\u00f3ria
  reg_in.display();

  //Banco de registradores
  regfile.display();

  //Sa\u00edda do banco
  line(regfile.posXout,regfile.posYregs[AdrA],regA.posXin,regA.posYin);
  line(regfile.posXout,regfile.posYregs[AdrB],regB.posXin,regB.posYin);
  regA.display();
  regB.display();

  //ULA
  line(regA.posXout,regA.posYout,ULA.posXa,ULA.posYa);
  line(regB.posXout,regB.posYout,ULA.posXb,ULA.posYb);
  ULA.display();

  //Sa\u00edda da ULA
  line(ULA.posXout,ULA.posYout,ulaOut.posXin,ulaOut.posYin);
  ulaOut.display();

  //Retorno ao banco de registradores
  switch (control.controlReg) {
  case 5: //grava PC no 15
    noFill();
    beginShape();
      vertex(PC.posXout,PC.posYout);
      vertex(PC.posXout+5,PC.posYout);
      vertex(PC.posXout+5,regfile.posY-10);
      vertex(10,regfile.posY-10);
      vertex(10,regfile.posYregs[15]);
      vertex(regfile.posXin,regfile.posYregs[15]);
    endShape();
    break;
  case 4: //grava com reg_in
    noFill();
    beginShape();
      vertex(reg_in.posXout,reg_in.posYout);
      vertex(reg_in.posXout+5,reg_in.posYout);
      vertex(reg_in.posXout+5,regfile.posY-10);
      vertex(10,regfile.posY-10);
      vertex(10,regfile.posYregs[AdrA]);
      vertex(regfile.posXin,regfile.posYregs[AdrA]);
    endShape();
    break;
  case 2: //LIU
  case 3: //LIL
    noFill();
    beginShape();
      vertex(instruction.posXout,instruction.posYout);
      vertex(instruction.posXout+5,instruction.posYout);
      vertex(instruction.posXout+5,regfile.posY-10);
      vertex(10,regfile.posY-10);
      vertex(10,regfile.posYregs[AdrA]);
      vertex(regfile.posXin,regfile.posYregs[AdrA]);
    endShape();
    break;
  case 1: //Grava da ULA
    noFill();
    beginShape();
      vertex(ulaOut.posXout,ulaOut.posYout);
      vertex(ulaOut.posXout+5,ulaOut.posYout);
      vertex(ulaOut.posXout+5,regfile.posY-10);
      vertex(10,regfile.posY-10);
      vertex(10,regfile.posYregs[AdrA]);
      vertex(regfile.posXin,regfile.posYregs[AdrA]);
    endShape();
    break;
  }
  
  //Program counter
  PC.display();
  
  //Bloco de controle
  control.display();
  noFill();
  beginShape();
    vertex(control.posXcULA,control.posYcULA);
    vertex(ULA.posXc,control.posYcULA);
    vertex(ULA.posXc,ULA.posYc);
  endShape();
  
  beginShape();
    vertex(control.posXcReg,control.posYcReg);
    vertex(control.posXcReg - 10,control.posYcReg);
    vertex(control.posXcReg - 10,regfile.posYc+10);
    vertex(regfile.posXc,regfile.posYc+10);
    vertex(regfile.posXc,regfile.posYc);
  endShape();
  
  beginShape();
    vertex(control.posXcPC,control.posYcPC);
    vertex(PC.posXc,control.posYcPC);
    vertex(PC.posXc,PC.posYc);
  endShape();

  instMem.display(1,0,PC.value);
  dataMem.display(control.enData,control.wData,ulaOut.value);
  
}

public void asinc(){
/* Executa a l\u00f3gica combinacional (ass\u00edncrona) do anem
   Fun\u00e7\u00f5es complexas s\u00e3o realizadas por m\u00e9todos exec() de cada objeto */
  // Obt\u00eam os valores de sa\u00edda do banco
  regA.value = regfile.read(AdrA);
  regB.value = regfile.read(AdrB);

  //Carrega as entradas da ULA
  ULA.a = regA.value;
  ULA.b = regB.value;

  //Executa a ULA
  ULA.exec(control.controlULA,func,AdrB);
  ulaOut.value = ULA.out;

  //Obt\u00e9m um dado da mem\u00f3ria
  if (control.enData == 1){
    reg_in.value = dataMem.read(ulaOut.value);
  } else {
    reg_in.value = 0;
  }

  //Executa o controle para o pr\u00f3ximo clock
  control.exec(opcode);
}

public void draw(){
/* No asinc() s\u00e3o executadas todas as opera\u00e7\u00f5es ass\u00edncronas.
   No final \u00e9 chamado o display() para efetivamente desenhar */
  asinc();
  display();
}

public void mousePressed(){
  if ((mouseX < 40) && (mouseY < 40)){  //Se apertou o mouse no clock
    sinc(); //executa os c\u00f3digos s\u00edncronos (atualiza os registradores)
  } else if((mouseX > 560) && (mouseY > 260)){ //Se apertou o mouse no dump
    dataMem.dump("mem\u00f3ria.txt");
  }
}

public void keyPressed(){
  if (key == ' '){
    sinc();
  }
}

public void sinc(){
/* Tudo que depende do rel\u00f3gio */
  //Atualiza a mem\u00f3ria
  if (control.wData == 1){
    dataMem.write(ulaOut.value, regA.value);
  }

  //Atualiza o banco de registradores
  regfile.exec(control.controlReg);

  //Calcula o novo PC
  PC.exec(control.controlPC, ende, func, regA.value, ULA.Z);

  //Obt\u00eam a instru\u00e7\u00e3o da mem\u00f3ria. A princ\u00edpio estaria em asinc(),
  //mas como s\u00f3 muda quando PC muda, aqui gasta menos processamento
  instruction.value = instMem.read(PC.value);
  //E os subcampos da instru\u00e7\u00e3o
  opcode = instruction.value>>12; //equivalente a (instruction.value & 0xf000)>>12
  AdrA   = (instruction.value & 0x0f00)>>8;
  AdrB   = (instruction.value & 0x00f0)>>4;
  func = (instruction.value & 0x000f);
  //func   = ((instruction.value & 0x1000)>>8)|(instruction.value & 0x000f);
  opcode = instruction.value>>12; //equivalente a (instruction.value & 0xf000)>>12
  inByte = instruction.value & 0x00ff;
  ende   = instruction.value & 0x0fff;  
  
}
/*Class Control*/

class Control{

  int posX,posY;
  int controlReg,controlPC,controlULA,wData,enData;
  int posXcReg,posXcPC,posXcULA,posXw,posXen;
  int posYcReg,posYcPC,posYcULA,posYw,posYen;
  String operation;
  
  Control(int iposX, int iposY){
    posX = iposX;
    posXcReg = posX;
    posXcULA = posX;
    posXcPC  = posX;
    posXw    = posX + 100;
    posXen   = posX + 100;
    
    posY = iposY;
    posYcULA = posY + 18;
    posYcReg = posY + 42;
    posYcPC  = posY + 30;
    posYw    = posY + 18;
    posYen   = posY + 30;
  }
  
  public void display(){
    textAlign(CENTER);
    fill(210);
    rect(posX,posY,100,12);
    fill(0);
    text("controle",posX+50,posY+12-1);
    fill(255);
    rect(posX,posY+12,100,60);
    fill(0);
    text(operation,posX+50,posY+48);
    textAlign(LEFT);
    text(binary(controlULA,3),posX+1,posYcULA+5);
    text(binary(controlReg,2),posX+1,posYcReg+5);
    text(binary(controlPC,2),posX+1,posYcPC+5);
    textAlign(RIGHT);
    text(binary(wData,1),posXw-1,posYw+5);
    text(binary(enData,1),posXen-1,posYen+5);
  }
  
  public void exec(int opcode){
    switch(opcode){
    case 0:
      operation = "R";
      controlReg = 1; //Grava o resultado da ULA
      controlULA = 1; //ULA executa tipo R
      controlPC  = 0; //PC incrementa
      wData      = 0;
      enData     = 0;
      break;
    case 1:
      operation = "S";
      controlReg = 1; //Grava o resultado da ULA
      controlULA = 2; //ULA executa tipo S
      controlPC  = 0; //PC incrementa
      wData      = 0;
      enData     = 0;
      break;
    case 8:
      operation = "J";
      controlReg = 0; //RegFile n\u00e3o faz nada
      controlULA = 0; //ULA fica parada
      controlPC  = 1; //PC salta
      wData      = 0;
      enData     = 0; 
      break;
    case 9:
      operation = "JAL";
      controlReg = 5; //RegFile Guarda o PC no registrador 15
      controlULA = 0; //ULA fica parada
      controlPC  = 1; //PC salta
      wData      = 0;
      enData     = 0;
      break;
    case 6:
      operation = "BEQ";
      controlReg = 0; //RegFile n\u00e3o faz nada
      controlULA = 3; //ULA subtrai
      controlPC  = 3; //PC testa
      wData      = 0;
      enData     = 0;
      break;
    case 7:
      operation = "JR";
      controlReg = 0; //RegFile n\u00e3o faz nada
      controlULA = 0; //ULA fica parada
      controlPC  = 2; //PC salta p reg.
      wData      = 0;
      enData     = 0;
      break;
    case 4:
      operation = "SW";
      controlReg = 0; //RegFile n\u00e3o faz nada
      controlULA = 4; //ULA calcula endere\u00e7o
      controlPC  = 0; //PC incrementa
      wData      = 0;
      enData     = 1;  //L\u00ea os dados
      break;
    case 5:
      operation = "LW";
      controlReg = 4; //RegFile Guarda o reg_in
      controlULA = 4; //ULA calcula endere\u00e7o
      controlPC  = 0; //PC incrementa
      wData      = 1;
      enData     = 1;  //Grava os dados
      break;
    case 12:
      operation = "LIU";
      controlReg = 2; // Grava o byte superior
      controlULA = 0; //ULA fica parada
      controlPC  = 0; //PC incrementa
      wData      = 0;
      enData     = 0;
      break;
    case 13:
      operation = "LIL";
      controlReg = 3; // Grava o byte inferior
      controlULA = 0; //ULA fica parada
      controlPC  = 0; //PC incrementa
      wData      = 0;
      enData     = 0;
      break;
    case 15:
      operation = "HAB";
      controlReg = 0; //RegFile n\u00e3o faz nada
      controlULA = 0; //ULA fica parada
      controlPC  = 0; //PC incrementa
      wData      = 0;
      enData     = 0;
      break;
    default:
      operation ="ERR";
      controlReg = 0; //RegFile n\u00e3o faz nada
      controlULA = 0; //ULA fica parada
      controlPC  = 0; //PC incrementa
      wData      = 0;
      enData     = 0;
    }
  }

  
 }

class Memory{
  String[] lines;
  int index = 0;
  int[] vecMemory;
  int memSize = 1<<16;
  int posX,posY;
  
  Memory(int iposX,int iposY,String fileName){
    posX = iposX;
    posY = iposY;
    vecMemory = new int[memSize];
    lines = loadStrings(fileName);
    while (index < lines.length){
      int nWords = unhex(lines[index].substring(1,3)) >> 1; //nWords = 2*nBytes
      int startAdr = unhex(lines[index].substring(3,7));
      for (int i = 0; i < nWords; i++){
        vecMemory[startAdr+i] = unhex(lines[index].substring(9+4*i,9+4*(i+1)));
      }
      index ++;
    }
  }

  Memory(int iposX,int iposY){
    posX = iposX;
    posY = iposY;
    vecMemory = new int[memSize];
  }
  
  public int read(int address){
    return vecMemory[address];
  }

  public void write(int address, int value){
    vecMemory[address] = value;
  }

  public void dump(String fileName){
    dumpFile(fileName,8);
  }

  public void dumpFile(String fileName,int nCols){
    String[] lines = new String[memSize/nCols];
    int nLine = 0;
    for (int index = 0; index < memSize; index ++){
      if (index%nCols == 0){
        nLine = index/nCols;
        lines[nLine] = hex(index,4);
      }
      lines[nLine] += "\t"+hex(vecMemory[index],4);
    }
    saveStrings(fileName,lines);
  }

  public void display(int read,int write,int ind){
    fill(255);
    stroke(0);
    rect(posX-1,posY-1,257,257);
    for (int index = 0; index < memSize;index ++){
      if ((index == ind) && (write == 1)){
        stroke(200,0,0);
      } else if ((index == ind) && (read == 1)){
        stroke(0,200,0);
      } else if (vecMemory[index] == 0){
        stroke(255);
      } else {
        stroke(120);
      }
      point(posX+(index%256),posY+(index/256));
    }
  }
}
/*class RegFile */

class RegFile{
  int nReg = 16;
  int[] regs;
  int posX,posY;
  int posXin,posXout;
  int[] posYregs;
  int posXc,posYc;

  RegFile(int inReg,int iposX,int iposY){
    nReg = inReg;
    regs = new int[nReg];
    posX = iposX;
    posXin = posX;
    posXout = posX+100;
    posXc = posX + 50;
    
    posY = iposY;
    posYregs = new int[nReg];
    for(int i = 0; i<nReg; i++){
      posYregs[i] = posY + 18 +12*i;
    }
    posYc = posYregs[nReg-1] + 6;
  }
  
  public void display(){
    textAlign(CENTER);
    fill(210);
    rect(posX,posY,100,12);
    fill(0);
    text("banco de reg.",posX+50,posY+12-1);
    for(int i = 0; i<nReg; i++){
      fill(255);
      rect(posX,12*(i+1)+posY,100,12);
      fill(0);
      text(i,posX+10,12*(i+2)+posY-1);
      text(hex(regs[i],4),posX+60,12*(i+2)+posY-1);
    }
    line(posX+20,posY+12,posX+20,posY+(nReg+1)*12);
  }
  
  public void write(int reg,int valor){
    if (!(reg == 0)){
      regs[reg] = valor;
    }
  }

  public void writeByte(int reg,int valor,char UorL){
    if (!(reg == 0)){
      if (UorL == 'U'){
        regs[reg] = (regs[reg] & 0x00ff) | valor <<8;
      } else if (UorL == 'L'){
        regs[reg] = (regs[reg] & 0x0ff00) | valor;
      }
    }
  }
  
  public int read(int reg){
    return regs[reg];
  }

  public void exec(int reg_cnt){
    switch (reg_cnt) {
    case 5: //grava PC no 15
      write(15,PC.value);
    case 4: //grava com reg_in
      write(AdrA,reg_in.value);
      break;
    case 2: //LIU
      writeByte(AdrA,inByte,'U');
      break;
    case 3: //LIL
      writeByte(AdrA,inByte,'L');
      break;
    case 1: //Grava da ULA
      write(AdrA,ULA.out);
      break;
    }
  }
}
/*class Register */

class Register{
  int posX,posY;  
  int posXin,posXout;
  int posYin,posYout;
  int value = 0;
  String name;
  
  Register(String iName,int iposX, int iposY){
    name = iName;
    posX = iposX;
    posXin = posX;
    posXout = posX + 80;
    posY = iposY;
    posYin = posY+18;
    posYout = posYin;
  }
  
  public void display(){
    textAlign(CENTER);
    fill(210);
    rect(posX,posY,80,12);
    fill(0);
    text(name,posX+40,posY+12-1);
    fill(255);
    rect(posX,posY+12,80,12);
    fill(0);
    text(hex(value,4),posX+40,posY+24-1);
  }
}
/*Classe ULA do ANEM */
class Ula{
  int posX,posY; //Posi\u00e7\u00e3o (canto superior esquerdo)
  int a,b, out;  //Entradas e sa\u00edda
  int posXa,posYa,posXb,posYb,posXout,posYout; // E respectivas coordenadas
  int posXc,posYc; //entrada do controle

  int Z,C,Ov;    //flags
  String funcao; //Fun\u00e7\u00e3o sendo executada no momento
  
  Ula(int iposX, int iposY){
    posX    = iposX;
    posXa   = posX;
    posXb   = posX;
    posXout = posX + 40;
    posXc   = posX + 20;

    posY    = iposY;
    posYa   = posY + 15;
    posYb   = posY + 65;
    posYout = posY + 40;
    posYc   = posY + 67;
  }
  
  public void display(){
    fill(255);
    beginShape();
      vertex(posX+00, posY+0);
      vertex(posX+40, posY+25);
      vertex(posX+40, posY+55);
      vertex(posX+00, posY+80);
      vertex(posX+00, posY+50);
      vertex(posX+10, posY+40);
      vertex(posX+00, posY+30);
    endShape(CLOSE);
    fill(0);
    textAlign(LEFT);
    text(funcao,posX+12,posY+46);
    fill((1-Z)*255);
    text('Z',posX+0,posY+92);
    fill((1-C)*255);
    text('C',posX+12,posY+92);
    fill((1-Ov)*255);
    text("Ov",posX+24,posY+92);
  }
    
  public void exec(int ulaCont,int funcExt,int shamt){
    int funcInt;
    //Define o func interno
    //Feito de acordo com Ula.vhd
    switch (ulaCont){
    case 1:  // tipo R
      funcInt = funcExt;
      break;
    case 2: // tipo S
      funcInt = 0x10 | funcExt;
      break;
    case 3: // BEQ
      funcInt = 0x06;
      break;
    case 4: //LW ou SW
      funcInt = 0x19;
      break;
    default:
      funcInt = 0x1f;
      break;
    }
      
    //Funcao
    switch (funcInt){
    case 0X02:
     funcao = "ADD";
     out = a+b;
     break;
    case 0X06:
     funcao = "SUB";
     out = a+(0x10000-b);
     C = out/0x10000;
     if (((a/0x8000) == (b/0x8000)) && !((a/0x8000) == (out/0x8000))){
       Ov = 1;
     } else {
       Ov = 0;
     }
     break;
    case 0x01:
     funcao = "OR";
     out = a | b;
     break;
     case 0x00:
     funcao = "AND";
     out = a & b;
     break;
     case 0x0F:
     funcao = "XOR";
     out = a ^ b;
     break;
     case 0x0C:
     funcao = "NOR";
     out = ~(a|b);
     break;
     case 0x07:
     funcao = "SLT";
     out = a<b?1:0;
     break;
     case 0x12:
     funcao = "SHL";
     out = a << shamt;
     break;
     case 0x11:
     funcao= "SHR";
     out = a >> shamt;
     break;
     case 0x10:
     funcao = "SAR";
     out = a/(1<<shamt);
     break;
     case 0x18:
     funcao = "ROL";
     out =(a/(1<<(16-shamt)))|(a <<shamt);
     break;
     case 0x14:
     funcao = "ROR";
     out = (a%(1<<shamt)<<(16-shamt))|(a >> shamt);
     break;
    case 0x19:
      funcao = "END";
      out = funcExt > 7?b - 16 + funcExt: b + funcExt;
      break;
     default:
     funcao = "ERR";
     out =0;
    }

    //Carry e Overflow
    if((funcInt == 0X02) || (funcInt == 0X06)){ //ADD ou SUB
      C = out/0x10000;
      if (((a/0x8000) == (b/0x8000)) && !((a/0x8000) == (out/0x8000))){
        Ov = 1;
      } else {
        Ov = 0;
      }
    } else {
      C = 0;
      Ov = 0;
    }
    
    out = out%0x10000;
    if (funcao == "ERR"){
      Z = 0;  //Se fun\u00e7\u00e3o inv\u00e1lida, n\u00e3o gera flag.
    } else {
      Z = out==0?1:0;
    }
  }
}
/* Classe PC do ANEM */

class Pc extends Register{
  int posXc,posYc;
  
  Pc(int iposX,int iposY){
    super("PC",iposX,iposY);
    posXc = posX + 40;
    posYc = posY + 24;
  }
    
  //void display(){
      
  //}
    
  public void exec(int pc_cnt,int adr,int offset,int reg, int Z){
    switch(pc_cnt){
    case 1:  //Jump
      value = (value & 0x0f000)| adr;
      break;
    case 2:  //Jump register
      value = reg;
      break;
    case 3:  //beq
      if (Z > 0){
        value = offset>7?value-16+offset:value+offset;
      } else {
        value ++;
      }
      break;
    case 0:  //Normal. Incrementa
    default:
      value ++;
    }
    
  }
}

  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "simanem" });
  }
}
