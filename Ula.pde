/*Classe ULA do ANEM */
class Ula{
  int posX,posY; //Posição (canto superior esquerdo)
  int a,b, out;  //Entradas e saída
  int posXa,posYa,posXb,posYb,posXout,posYout; // E respectivas coordenadas
  int posXc,posYc; //entrada do controle

  int Z,C,Ov;    //flags
  String funcao; //Função sendo executada no momento
  
  Ula(int iposX, int iposY){
    posX    = iposX;
    posXa   = posX;
    posXb   = posX;
    posXout = posX + 80;
    posXc   = posX + 40;

    posY    = iposY;
    posYa   = posY + 30;
    posYb   = posY + 130;
    posYout = posY + 80;
    posYc   = posY + 134;
  }
  
  void display(){
    fill(255);
    beginShape();
      vertex(posX+00, posY+0);
      vertex(posX+80, posY+50);
      vertex(posX+80, posY+110);
      vertex(posX+00, posY+160);
      vertex(posX+00, posY+100);
      vertex(posX+20, posY+80);
      vertex(posX+00, posY+60);
    endShape(CLOSE);
    fill(0);
    textAlign(LEFT);
    text(funcao,posX+24,posY+92);
    fill((1-Z)*255);
    text('Z',posX+0,posY+184);
    fill((1-C)*255);
    text('C',posX+24,posY+184);
    fill((1-Ov)*255);
    text("Ov",posX+48,posY+184);
  }
    
  void exec(int ulaCont,int funcExt,int shamt){
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
      Z = 0;  //Se função inválida, não gera flag.
    } else {
      Z = out==0?1:0;
    }
  }
}
