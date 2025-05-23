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
    posXout = posX+200;
    posXc = posX + 100;
    
    posY = iposY;
    posYregs = new int[nReg];
    for(int i = 0; i<nReg; i++){
      posYregs[i] = posY + 36 +24*i;
    }
    posYc = posYregs[nReg-1] + 12;
  }
  
  void display(){
    textAlign(CENTER);
    fill(210);
    rect(posX,posY,200,24);
    fill(0);
    text("banco de reg.",posX+100,posY+24-1);
    for(int i = 0; i<nReg; i++){
      fill(255);
      rect(posX,24*(i+1)+posY,200,24);
      fill(0);
      text(i,posX+20,24*(i+2)+posY-1);
      text(hex(regs[i],4),posX+120,24*(i+2)+posY-1);
    }
    line(posX+40,posY+24,posX+40,posY+(nReg+1)*24);
  }
  
  void write(int reg,int valor){
    if (!(reg == 0)){
      regs[reg] = valor;
    }
  }

  void writeByte(int reg,int valor,char UorL){
    if (!(reg == 0)){
      if (UorL == 'U'){
        regs[reg] = (regs[reg] & 0x00ff) | valor <<8;
      } else if (UorL == 'L'){
        regs[reg] = (regs[reg] & 0x0ff00) | valor;
      }
    }
  }
  
  int read(int reg){
    return regs[reg];
  }

  void exec(int reg_cnt){
    switch (reg_cnt) {
    case 5: //grava PC no 15
      write(15,PC.value+1);
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
