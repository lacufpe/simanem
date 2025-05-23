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
    posXout = posX + 80;
    posY = iposY;
    posYin = posY+18;
    posYout = posYin;
  }
  
  void display(){
    textAlign(CENTER);
    fill(210);
    rect(posX,posY,80,12);
    fill(0);
    text(name,posX+40,posY+12-1);
    fill(255);
    rect(posX,posY+12,80,12);
    fill(0);
    text(hex(value,4),posX+40,posY+24-1);
  }
}
