/*Class Control*/

class Control{

  int posX,posY;
  int controlReg,controlPC,controlULA,wDados,enDados;
  int posXcReg,posXcPC,posXcULA;
  int posYcReg,posYcPC,posYcULA;
  String operation;
  
  Control(int iposX, int iposY){
    posX = iposX;
    posXcReg = posX;
    posXcULA = posX;
    posY = iposY;
    posYcULA = posY+18;
    posYcReg = posY+30;
  }
  
  void display(){
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
    text(hex(controlULA,1),posX+1,posY+23);
    text(hex(controlReg,1),posX+1,posY+35);
  }
  
  void exec(int opcode){
    switch(opcode){
    case 0:
      operation = "R";
      controlReg = 1; //Grava o resultado da ULA
      controlULA = 1; //ULA executa tipo R
      break;
    case 1:
      operation = "S";
      controlReg = 1; //Grava o resultado da ULA
      controlULA = 2; //ULA executa tipo S
      break;
    case 8:
      operation = "J";
      controlReg = 0; //RegFile não faz nada
      controlULA = 0; //ULA fica parada
      break;
    case 9:
      operation = "JAL";
      controlReg = 0; //RegFile não faz nada
      controlULA = 0; //ULA fica parada
      break;
    case 6:
      operation = "BEQ";
      controlReg = 0; //RegFile não faz nada
      controlULA = 3; //ULA subtrai
      break;
    case 7:
      operation = "JR";
      controlReg = 4; //RegFile Guarda o PC no registrador 15
      controlULA = 0; //ULA fica parada
      break;
    case 4:
      operation = "SW";
      controlReg = 0; //RegFile não faz nada
      controlULA = 4; //ULA calcula endereço
      break;
    case 5:
      operation = "LW";
      controlReg = 4; //RegFile Guarda o reg_in
      controlULA = 4; //ULA calcula endereço
      break;
    case 12:
      operation = "LIU";
      controlReg = 2; // Grava o byte superior
      controlULA = 0; //ULA fica parada
      break;
    case 13:
      operation = "LIL";
      controlReg = 3; // Grava o byte inferior
      controlULA = 0; //ULA fica parada
      break;
    default:
      operation ="ERR";
    }
  }
    
}
