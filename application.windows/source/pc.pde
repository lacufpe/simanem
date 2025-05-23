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
    
  void exec(int pc_cnt,int adr,int offset,int reg, int Z){
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

