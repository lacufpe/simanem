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

int AdrA, AdrB, func, opcode, inByte, ende;

void setup(){
  background(255);
  size(326+256+50,600);
  instruction = new Register("Instruction",120,20);
  instMem = new Memory(10,300,"MEM INST","cod_maquina.hex");
  dataMem = new Memory(326,300,"MEM DATA");
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

void display(){
/* Todos os comandos gráficos são executados  desta função.
   Cada objeto gráfico deve ter um método display() para ser chamado aqui.*/

  background(255);
  fill(0);

  //CLOCK
  rect(0,0,40,40);
  textAlign(CENTER);
  fill(255);
  text("CK",20,26);
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

void asinc(){
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
  if (control.enData == 1){
    reg_in.value = dataMem.read(ulaOut.value);
  } else {
    reg_in.value = 0;
  }

  //Executa o controle para o próximo clock
  control.exec(opcode);

  // Controla o trecho de memória que é mostrado.  
  if (mousePressed){
    if (instMem.mouseOverSlider(mouseX,mouseY)){
      instMem.updatePos(mouseY);
    } else if (dataMem.mouseOverSlider(mouseX,mouseY)){
      dataMem.updatePos(mouseY);
    }
  }

}

void draw(){
/* No asinc() são executadas todas as operações assíncronas.
   No final é chamado o display() para efetivamente desenhar */
  asinc();
  display(); 
}

void mousePressed(){
  if ((mouseX < 40) && (mouseY < 40)){  //Se apertou o mouse no clock
    sinc(); //executa os códigos síncronos (atualiza os registradores)
  } else if((mouseX > 560) && (mouseY > 260)){ //Se apertou o mouse no dump
    dataMem.dump("memória.txt");
  }
}

void keyPressed(){
  if (key == ' '){
    sinc();
  }
}

void sinc(){
/* Tudo que depende do relógio */
  //Atualiza a memória
  if (control.wData == 1){
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
