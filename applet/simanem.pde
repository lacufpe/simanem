/******************************************************************************
Simulador gráfico do microcontrolador ANEM
Autor: João Paulo Cerquinho Cajueiro
 ******************************************************************************/

RegFile regfile;
Register regA,regB,ulaOut;
Register instruction,reg_in;
Ula ULA;
Control control;

int AdrA, AdrB, func, opcode, inByte, ende;

void setup(){
  background(255);
  size(600,300);
  instruction = new Register("Instruction",120,20);
  reg_in= new Register("Memory Input",220,20);
  regfile = new RegFile(16,30,70);
  for (int i = 1; i<16; i++){
    regfile.write(i,floor(random(0x10000)));
  }
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

  // Instrução atual
  instruction.display();

  //Entrada de dados da memória
  reg_in.display();

  //Banco de registradores
  regfile.display();

  //Saída do banco
  line(regfile.posX+100,regfile.posY+6+12*(AdrA+1),regA.posXin,regA.posYin);
  line(regfile.posX+100,regfile.posY+6+12*(AdrB+1),regB.posXin,regB.posYin);
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
  noFill();
  beginShape();
  vertex(ulaOut.posXout,ulaOut.posYout);
  vertex(ulaOut.posXout+10,ulaOut.posYout);
  vertex(ulaOut.posXout+10,290);
  vertex(10,290);
  vertex(10,regfile.posYregs[AdrA]);
  vertex(regfile.posXin,regfile.posYregs[AdrA]);
  endShape();

  //Bloco de controle
  control.display();
  
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

  //Executa o controle para o próximo clock
  control.exec(opcode);
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
  }
}

void sinc(){
/* Atualiza os registradores */

  regfile.exec(control.controlReg);

  //Obtêm a instrução (depois virá da memória)
  instruction.value = floor(random(0x10000));
  //E os subcampos da instrução
  AdrA   = (instruction.value & 0x0f00)>>8;
  AdrB   = (instruction.value & 0x00f0)>>4;
  func = (instruction.value & 0x000f);
  //func   = ((instruction.value & 0x1000)>>8)|(instruction.value & 0x000f);
  opcode = instruction.value>>12; //equivalente a (instruction.value & 0xf000)>>12
  inByte = instruction.value & 0x00ff;
  ende   = instruction.value & 0x0fff;

  //Gera um dado (depois virá da memória)
  reg_in.value = floor(random(0x10000));
}
