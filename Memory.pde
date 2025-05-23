
class Memory{
  String[] lines;
  int index = 0;
  int[] vecMemory;
  int memSize = 1<<16;
  int posX,posY;
  int startPosition = 0;
  int indMouse;
  
  Memory(int iposX,int iposY,String  name, String fileName){
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

  Memory(int iposX,int iposY,String  name){
    posX = iposX;
    posY = iposY;
    vecMemory = new int[memSize];
  }
  
  int read(int address){
    return vecMemory[address];
  }

  void write(int address, int value){
    vecMemory[address] = value;
  }

  void dump(String fileName){
    dumpFile(fileName,8);
  }

  void dumpFile(String fileName,int nCols){
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

  void display(int read,int write,int ind){
    fill(255);
    stroke(0);
//    rect(posX-1,posY-1,256,256);
    rect(posX-20,posY,18,512);
    fill(200);
    rect(posX-20,posY+startPosition,18,32);
    stroke(0);
    for (int index = startPosition*256; index < (startPosition+16)*256;index ++){
      if ((index == ind) && (write == 1)){
        fill(200,0,0);
      } else if ((index == ind) && (read == 1)){
        fill(0,200,0);
      } else if (vecMemory[index] == 0){
        fill(255);
      } else {
        fill(120);
      }
      rect(posX+(index%64)*8,posY+((index-startPosition*256)/64)*8,8,8);
    }
    if (mouseOverMem(mouseX,mouseY)){
      int Xtemp = mouseX;
      int Ytemp = mouseY;
      indMouse = startPosition*256 + ((Ytemp-posY)/8)*64 + (Xtemp-posX)/8;
      fill(255);
      rect(Xtemp+20,Ytemp+2,80,48);
      fill(0);
      textAlign(CENTER);
      text(hex(indMouse,4),Xtemp+60,Ytemp+26);
      text(hex(vecMemory[indMouse],4),Xtemp+60,Ytemp+50);
    }
  }
  
  boolean mouseOverSlider(int x,int y){
    if ((x < posX)&&(x > posX-20)&&(y >= posY) && (y < posY+512)){
      return true;
    } else {
      return false;
    }
  }

  boolean mouseOverMem(int x,int y){
    if ((x < posX+512)&&(x > posX)&&(y >= posY) && (y < posY+512)){
      return true;
    } else {
      return false;
    }
  }
  
  void updatePos(int pos){
    if (pos < posY+16){
      startPosition = 0;
    } else if (pos > posY +512 -16){
      startPosition = 512-32;
    } else {
      startPosition = pos - posY - 16;
    }
  }
}
