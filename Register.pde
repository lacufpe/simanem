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
    posXout = posX + 160;
    posY = iposY;
    posYin = posY+36;
    posYout = posYin;
  }
  
  void display(){
    textAlign(CENTER);
    fill(210);
    rect(posX,posY,160,24);
    fill(0);
    text(name,posX+80,posY+24-1);
    fill(255);
    rect(posX,posY+24,160,24);
    fill(0);
    text(hex(value,4),posX+80,posY+48-1);
  }
}
