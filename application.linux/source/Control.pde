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
    text(binary(controlULA,3),posX+1,posYcULA+5);
    text(binary(controlReg,2),posX+1,posYcReg+5);
    text(binary(controlPC,2),posX+1,posYcPC+5);
    textAlign(RIGHT);
    text(binary(wData,1),posXw-1,posYw+5);
    text(binary(enData,1),posXen-1,posYen+5);
  }
  
  void exec(int opcode){
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
      controlReg = 0; //RegFile não faz nada
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
      controlReg = 0; //RegFile não faz nada
      controlULA = 3; //ULA subtrai
      controlPC  = 3; //PC testa
      wData      = 0;
      enData     = 0;
      break;
    case 7:
      operation = "JR";
      controlReg = 0; //RegFile não faz nada
      controlULA = 0; //ULA fica parada
      controlPC  = 2; //PC salta p reg.
      wData      = 0;
      enData     = 0;
      break;
    case 4:
      operation = "SW";
      controlReg = 0; //RegFile não faz nada
      controlULA = 4; //ULA calcula endereço
      controlPC  = 0; //PC incrementa
      wData      = 1;
      enData     = 1;  //Lê os dados
      break;
    case 5:
      operation = "LW";
      controlReg = 4; //RegFile Guarda o reg_in
      controlULA = 4; //ULA calcula endereço
      controlPC  = 0; //PC incrementa
      wData      = 0;
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
      controlReg = 0; //RegFile não faz nada
      controlULA = 0; //ULA fica parada
      controlPC  = 0; //PC incrementa
      wData      = 0;
      enData     = 0;
      break;
    default:
      operation ="ERR";
      controlReg = 0; //RegFile não faz nada
      controlULA = 0; //ULA fica parada
      controlPC  = 0; //PC incrementa
      wData      = 0;
      enData     = 0;
    }
  }

  
 }
