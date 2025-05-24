/******************************************************************************
Simulador gráfico do microcontrolador ANEM
Autor: João Paulo Cerquinho Cajueiro
 ******************************************************************************/


RegFile regfile;
Register regA,regB,ulaOut;
Register instruction,reg_in;
Ula ULA;
Memory instMem,dataMem;
Control control;
Pc PC;

let AdrA, AdrB, func, opcode, inByte, ende;

void setup() {
  background(255);
  size(1200,1200);
  textSize(24);
  //fullScreen();
  pushMatrix();
  scale(2);
  instruction = new Register("Instruction",240,40);
  instMem = new Memory(20,600,"MEM INST","cod_maquina.hex");
  dataMem = new Memory(640,600,"MEM DATA");
  reg_in= new Register("Memory Input",440,40);
  PC = new Pc(400,400);
  regfile = new RegFile(16,60,140);
  //for (let i = 1; i<16; i++){
  //  regfile.write(i,floor(random(0x10000)));
  //}
  regA = new Register("A OUT",400,140);
  regB = new Register("B OUT",400,240);
  ULA = new Ula(640,146);
  ulaOut = new Register("ULA out",960,190);
  control = new Control(720,400);
  popMatrix();
//  regfile.display();
//  noLoop();
}

void display() {
/* Todos os comandos gráficos são executados  desta função.
   Cada objeto gráfico deve ter um método display() para ser chamado aqui.*/

  background(255);
  fill(0);

  //CLOCK
  rect(0,0,80,80);
  textAlign(CENTER);
  fill(255);
  text("CK",40,52);
  stroke(0);

  // Instrução atual
  instruction.display();

  //Entrada de dados da memória
  reg_in.display();

  //Banco de registradores
  regfile.display();

  //Saída do banco
  line(regfile.posXout,regfile.posYregs[AdrA],regA.posXin,regA.posYin);
  line(regfile.posXout,regfile.posYregs[AdrB],regB.posXin,regB.posYin);
  regA.display();
  regB.display();

  //ULA
  line(regA.posXout,regA.posYout,ULA.posXa,ULA.posYa);
  line(regB.posXout,regB.posYout,ULA.posXb,ULA.posYb);
  ULA.display();

  //Saída da ULA
  line(ULA.posXout,ULA.posYout,ulaOut.posXin,ulaOut.posYin);
  ulaOut.display();

  //Retorno ao banco de registradores
  switch(control.controlReg) {
  case 5: //grava PC no 15
    noFill();
    beginShape();
      vertex(PC.posXout,PC.posYout);
      vertex(PC.posXout+10,PC.posYout);
      vertex(PC.posXout+10,regfile.posY-20);
      vertex(20,regfile.posY-20);
      vertex(20,regfile.posYregs[15]);
      vertex(regfile.posXin,regfile.posYregs[15]);
    endShape();
    break;
  case 4: //grava com reg_in
    noFill();
    beginShape();
      vertex(reg_in.posXout,reg_in.posYout);
      vertex(reg_in.posXout+10,reg_in.posYout);
      vertex(reg_in.posXout+10,regfile.posY-20);
      vertex(20,regfile.posY-20);
      vertex(20,regfile.posYregs[AdrA]);
      vertex(regfile.posXin,regfile.posYregs[AdrA]);
    endShape();
    break;
  case 2: //LIU
  case 3: //LIL
    noFill();
    beginShape();
      vertex(instruction.posXout,instruction.posYout);
      vertex(instruction.posXout+10,instruction.posYout);
      vertex(instruction.posXout+10,regfile.posY-20);
      vertex(20,regfile.posY-20);
      vertex(20,regfile.posYregs[AdrA]);
      vertex(regfile.posXin,regfile.posYregs[AdrA]);
    endShape();
    break;
  case 1: //Grava da ULA
    noFill();
    beginShape();
      vertex(ulaOut.posXout,ulaOut.posYout);
      vertex(ulaOut.posXout+10,ulaOut.posYout);
      vertex(ulaOut.posXout+10,regfile.posY-20);
      vertex(20,regfile.posY-20);
      vertex(20,regfile.posYregs[AdrA]);
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
    vertex(control.posXcReg - 20,control.posYcReg);
    vertex(control.posXcReg - 20,regfile.posYc+20);
    vertex(regfile.posXc,regfile.posYc+20);
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

void asinc() {
/* Executa a lógica combinacional (assíncrona) do anem
   Funções complexas são realizadas por métodos exec() de cada objeto */
  // Obtêm os valores de saída do banco
  regA.value = regfile.read(AdrA);
  regB.value = regfile.read(AdrB);

  //Carrega as entradas da ULA
  ULA.a = regA.value;
  ULA.b = regB.value;

  //Executa a ULA
  ULA.exec(control.controlULA,func,AdrB);
  ulaOut.value = ULA.out;

  //Obtém um dado da memória
  if(control.enData == 1) {
    reg_in.value = dataMem.read(ulaOut.value);
  } else {
    reg_in.value = 0;
  }

  //Executa o controle para o próximo clock
  control.exec(opcode);

  // Controla o trecho de memória que é mostrado.  
  if(mousePressed) {
    if(instMem.mouseOverSlider(mouseX,mouseY)) {
      instMem.updatePos(mouseY);
    } else if(dataMem.mouseOverSlider(mouseX,mouseY)) {
      dataMem.updatePos(mouseY);
    }
  }

}

void draw() {
/* No asinc() são executadas todas as operações assíncronas.
   No final é chamado o display() para efetivamente desenhar */
  asinc();
  display(); 
}

void mousePressed() {
  if((mouseX < 80) && (mouseY < 80)) {  //Se apertou o mouse no clock
    sinc(); //executa os códigos síncronos (atualiza os registradores)
  } else if((mouseX > 1120) && (mouseY > 520)) { //Se apertou o mouse no dump
    dataMem.dump("memória.txt");
  }
}

void keyPressed() {
  if(key == ' ') {
    sinc();
  }
}

void sinc() {
/* Tudo que depende do relógio */
  //Atualiza a memória
  if(control.wData == 1) {
    dataMem.write(ulaOut.value, regA.value);
  }

  //Atualiza o banco de registradores
  regfile.exec(control.controlReg);

  //Calcula o novo PC
  PC.exec(control.controlPC, ende, func, regA.value, ULA.Z);

  //Obtêm a instrução da memória. A princípio estaria em asinc(),
  //mas como só muda quando PC muda, aqui gasta menos processamento
  instruction.value = instMem.read(PC.value);
  //E os subcampos da instrução
  opcode = instruction.value>>12; //equivalente a (instruction.value & 0xf000)>>12
  AdrA   = (instruction.value & 0x0f00)>>8;
  AdrB   = (instruction.value & 0x00f0)>>4;
  func = (instruction.value & 0x000f);
  //func   = ((instruction.value & 0x1000)>>8)|(instruction.value & 0x000f);
  opcode = instruction.value>>12; //equivalente a (instruction.value & 0xf000)>>12
  inByte = instruction.value & 0x00ff;
  ende   = instruction.value & 0x0fff;  
  
}
