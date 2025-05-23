/*class RegFile */

class RegFile{
  int nReg = 16;
  int[] regs;
  int posX,posY;
  int posXin,posXout;
  int[] posYregs;

  /*
ENTITY BancoReg IS
  PORT(S_IN	: IN STD_LOGIC;				       --ENTRADA SERIAL DE TESTE
       TEST	: IN STD_LOGIC;				       --MODO DE TESTE ATIVO OU NAO
       ULA_IN	: IN STD_LOGIC_VECTOR(DATA_W-1 DOWNTO 0);      --RETORNO DA ULA
       BYTE_IN	: IN STD_LOGIC_VECTOR(W-1 DOWNTO 0);	       --ENTRADA PARALELA DE DADOS
       SEL_A	: IN STD_LOGIC_VECTOR(REGBNK_ADDR-1 DOWNTO 0); --SELETOR DO REGISTRADOR A
       SEL_B	: IN STD_LOGIC_VECTOR(REGBNK_ADDR-1 DOWNTO 0); --SELETOR DO REGISTRADOR B
       DATA_IN	: IN STD_LOGIC_VECTOR(DATA_W-1 DOWNTO 0);      --ENTRADA DA MEMORIA
       CK	: IN STD_LOGIC;				       --CLOCK
       RST	: IN STD_LOGIC;				       --RESET ASSINCRONO
       REG_CNT	: IN STD_LOGIC_VECTOR(2 DOWNTO 0);	       --CONTROLE DE OPERACOES
       A_OUT	: OUT STD_LOGIC_VECTOR(DATA_W-1 DOWNTO 0);     --SAIDA DE DADOS DO REGISTRADOR A
       B_OUT	: OUT STD_LOGIC_VECTOR(DATA_W-1 DOWNTO 0);     --SAIDA DE DADIS DO REGISTRADOR B
       S_OUT	: OUT STD_LOGIC);			       --SAIDA SERIAL DE TESTE
END ENTITY;
  */

  RegFile(int inReg,int iposX,int iposY){
    nReg = inReg;
    regs = new int[nReg];
    posX = iposX;
    posXin = posX;
    posXout = posX+100;
    posY = iposY;
    posYregs = new int[nReg];
    for(int i = 0; i<nReg; i++){
      posYregs[i] = posY + 18 +12*i;
    }
  }
  
  void display(){
    textAlign(CENTER);
    fill(210);
    rect(posX,posY,100,12);
    fill(0);
    text("banco de reg.",posX+50,posY+12-1);
    for(int i = 0; i<nReg; i++){
      fill(255);
      rect(posX,12*(i+1)+posY,100,12);
      fill(0);
      text(i,posX+10,12*(i+2)+posY-1);
      text(hex(regs[i],4),posX+60,12*(i+2)+posY-1);
    }
    line(posX+20,posY+12,posX+20,posY+(nReg+1)*12);
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
    case 4: //grava com reg_in
      write (AdrA,reg_in.value);
      break;
    case 2: //LIU
      writeByte (AdrA,inByte,'U');
      break;
    case 3: //LIL
      writeByte (AdrA,inByte,'L');
      break;
    case 1: //Grava da ULA
      write (AdrA,ULA.out);
      break;
    }
  }
}
