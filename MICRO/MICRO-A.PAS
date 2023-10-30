Program MICRO;
  type
    MAIN        = record
                    FILENAME_                        : string[8];
                    START_ADDR,
                    RANGE                            : integer;
                    BOL                              : boolean;
                  end;
    SUB         = record
                    OPCOD                            : byte;
                  end;
    REGTYPE     = record
                    AX,BX,CX,DX,BP,SI,DI,DS,ES,FLAGS : integer;
                  end;
    HALFREGTYPE = record
                    AL,AH,BL,BH,CL,CH,DL,DH          : byte
                  end;
    G255_ = string[255];
  var
    F1                                                      : FILE OF MAIN;
    R1                                                      : MAIN;
    F2                                                      : FILE OF SUB;
    R2                                                      : SUB;
    REGS,SAVEREG                                            : REGTYPE;
    SAVEHALF                                                : HALFREGTYPE absolute SAVEREG;
    ESC,GO,INS,FIND,INKEYP,LOOP,PROGRAM_END,TRS             : boolean;
    S,PPP,Z,CY,XS,RA,RB,RC,RD,RE,RH,RL,T,INK,IN5,BP,X,Y     : byte;
    MRY                                                     : array[0..1] of byte;
    OT                                                      : array[1..8] of byte;
    WIN                                                     : array[15..67,5..20] of char;
    PD_                                                     : array[1..8] of char;
    A,B,C,E,R,BL,LIN,SP,CC,CD,D,I,J,F,N,OP,Q,START,VL,W,FLS : integer;
    A_,B_,C_,D_,E_,M_,O_,P_,Z_,AS_,AD_                      : string[255];
    CH_,VIEW_                                               : char;
  const
    CMD_ : string[4]  = '';
    LSD_ : string[7]  = '';
    CD_  : string[12] = 'CRSAOLPGMTK ';
    SPD_ : string[20] = '                    ';
    SPU_ : string[20] = 'ออออออออออออออออออออ';
    ZC_  : string[26] = 'ABCDEHLMSZPCYSPPCPSWBCDEHL';
    PA   : array[0..15] of byte=(1,0,0,1,0,0,1,0,0,1,1,0,1,0,0,1);
    TAB  : array[1..20] of integer=(
     8,8,8,8,8,8,
     13,13,13,13,13,
     1,1,1,1,1,1,1,1,1);
    BTAB : array[1..20] of integer=(
     13,13,13,13,13,13,
     1,1,1,1,1,
     8,8,8,8,8,8,8,8,8);
    ERR_ : array[1..8] of string[30]=(
     '1 List type mistake',
     '2 Invalid mnemonics operations',
     '3 Invalid mnemonics operand',
     '4 Syntax error',
     '5 Line out of range',
     '6 Unkonwed command',
     '7 Op code syntax error',
     '8 Unkonwed op code');
    ERT : array[1..24] of string[43]=(
     'A request for a program list that does  not',
     'have a char that departure between the  two',
     'line numbers',
     'The mnemonics operation does not match with',
     'the computer library or the mnemonics  does',
     'not operate like an command',
     'The mnemonics operand is not correct',
     '',
     '',
     'An error was brought up in  the  middle  of',
     'the program run and  the  program  can  not',
     'continue',
     'Line number is out of the computer range',
     '(h0100-h7FFF)',
     '',
     'The first letter in the line does not match',
     'with the list which the computer has',
     '',
     'The op code is out  of  range,  this  error',
     'might be also because the length of the  op',
     'code is not in the right length',
     'The op code in the  memory  list  does  not',
     'operate like an op code',
     '');
    SC   : array[1..8] of integer=(22,21,19,18,22,20,19,21);
    XP   : array[1..6,1..8] of integer=(
     (56,57,57,56,58,56,55,55),
     (60,61,61,60,62,60,59,59),
     (64,65,65,64,66,64,63,63),
     (68,69,69,68,70,68,67,67),
     (73,74,74,73,75,73,72,72),
     (77,78,78,77,79,77,76,76));
    CM_  : array[1..12] of string[19]=('LS',':reg=','0000','0000','0000','0000-0000','0000-0000','0000','0000-0000 0000',
     '0000','0000-0000','0000-0000');
    BIN_ : array[0..15] of string[4]=('0000','0001','0010','0011','0100','0101','0110','0111','1000','1001','1010','1011',
     '1100','1101','1110','1111');
    OT_  : array[0..15] of string[7]=('๙บ๙บ๙บ๙','๙บ๙บ๙บþ','๙บ๙บþบ๙','๙บ๙บþบþ','๙บþบ๙บ๙','๙บþบ๙บþ','๙บþบþบ๙','๙บþบþบþ',
     'þบ๙บ๙บ๙','þบ๙บ๙บþ','þบ๙บþบ๙','þบ๙บþบþ','þบþบ๙บ๙','þบþบ๙บþ','þบþบþบ๙','þบþบþบþ');
    FP_  : array[0..15] of string[7]=('s z p c','s z p C','s z P c','s z P C','s Z p c','s Z p C','s Z P c','s Z P C',
     'S z p c','S z p C','S z P c','S z P C','S Z p c','S Z p C','S Z P c','S Z P C');
    MEM_ : array[0..255] of string[4]=('NOP','LXI','STAX','INX','INR','DCR','MVI','RLC','HOLD','DAD','LDAX','DCX','INR','DCR'
     ,'MVI','RRC','----','LXI','STAX','INX','INR','DCR','MVI','RAL','----','DAD','LDAX','DCX','INR','DCR','MVI','RAR','RIM'
     ,'LXI','SHLD','INX','INR','DCR','MVI','DAA','----','DAD','LHLD','DCX','INR','DCR','MVI','CMA','SIM','LXI','STA','INX'
     ,'INR','DCR','MVI','STC','----','DAD','LDA','DCX','INR','DCR','MVI','CMC','MOV','MOV','MOV','MOV','MOV','MOV','MOV',
     'MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV'
     ,'MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV'
     ,'MOV','MOV','MOV','MOV','MOV','MOV','MOV','HLT','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','MOV','ADD','ADD','ADD'
     ,'ADD','ADD','ADD','ADD','ADD','ADC','ADC','ADC','ADC','ADC','ADC','ADC','ADC','SUB','SUB','SUB','SUB','SUB','SUB','SUB'
     ,'SUB','SBB','SBB','SBB','SBB','SBB','SBB','SBB','SBB','ANA','ANA','ANA','ANA','ANA','ANA','ANA','ANA','XRA','XRA','XRA'
     ,'XRA','XRA','XRA','XRA','XRA','ORA','ORA','ORA','ORA','ORA','ORA','ORA','ORA','CMP','CMP','CMP','CMP','CMP','CMP','CMP'
     ,'CMP','RNZ','POP','JNZ','JMP','CNZ','PUSH','ADI','RST','RZ','RET','JZ','----','CZ','CALL','ACI','RST','RNC','POP','JNC'
     ,'OUT','CNC','PUSH','SUI','RST','RC','----','JC','IN','CC','----','SBI','RST','RPO','POP','JPO','XTHL','CPO','PUSH',
     'ANI','RST','RPE','PCHL','JPE','XCHG','CPE','----','XRI','RST','RP','POP','JP','DI','CP','PUSH','ORI','RST','RM','SPHL'
     ,'JM','EI','CM','----','CPI','RST');
    OPR_ : array[0..255] of string[7]=('','B,$$$$','B','B','B','B','B,$$','','$$$$','B','B','B','C','C','C,$$','','','D,$$$$'
     ,'D','D','D','D','D,$$','','','D','D','D','E','E','E,$$','','','H,$$$$','$$$$','H','H','H','H,$$','','','H','$$$$','H',
     'L','L','L,$$','','','SP,$$$$','$$$$','SP','M','M','M,$$','','','SP','$$$$','SP','A','A','A,$$','','B,B','B,C','B,D',
     'B,E','B,H','B,L','B,M','B,A','C,B','C,C','C,D','C,E','C,H','C,L','C,M','C,A','D,B','D,C','D,D','D,E','D,H','D,L','D,M',
     'D,A','E,B','E,C','E,D','E,E','E,H','E,L','E,M','E,A','H,B','H,C','H,D','H,E','H,H','H,L','H,M','H,A','L,B','L,C','L,D',
     'L,E','L,H','L,L','L,M','L,A','M,B','M,C','M,D','M,E','M,H','M,L','','M,A','A,B','A,C','A,D','A,E','A,H','A,L','A,M',
     'A,A','B','C','D','E','H','L','M','A','B','C','D','E','H','L','M','A','B','C','D','E','H','L','M','A','B','C','D','E',
     'H','L','M','A','B','C','D','E','H','L','M','A','B','C','D','E','H','L','M','A','B','C','D','E','H','L','M','A','B','C',
     'D','E','H','L','M','A','','B','$$$$','$$$$','$$$$','B','$$','0','','','$$$$','','$$$$','$$$$','$$','1','','D','$$$$',
     '#$$','$$$$','D','$$','2','','','$$$$','#$$','$$$$','','$$','3','','H','$$$$','','$$$$','H','$$','4','','','$$$$','',
     '$$$$','','$$','5','','PSW','$$$$','','$$$$','PSW','$$','6','','','$$$$','','$$$$','','$$','7');
    MEML : array[0..255] of byte=(3,3,4,3,3,3,3,3,4,3,4,3,3,3,3,3,0,3,4,3,3,3,3,3,0,3,4,3,3,3,3,3,3,3,4,3,3,3,3,3,0,3,4,3,3,3
     ,3,3,3,3,3,3,3,3,3,3,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
     ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
     ,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,4,3,3,2,3,2,0,2,4,3,3,3,3,3,3,3,4,3,3,2,0,2,2,2,0,3,3,3,3
     ,3,4,3,4,3,3,3,4,3,4,3,0,3,3,2,3,2,2,2,4,3,3,2,4,2,2,2,0,3,3);
    OPRL : array[0..255] of byte=(0,1,1,1,1,1,1,0,0,1,1,1,1,1,1,0,0,1,1,1,1,1,1,0,0,1,1,1,1,1,1,0,0,1,0,1,1,1,1,0,0,1,0,1,1,1
     ,1,0,0,2,0,2,1,1,1,0,0,2,0,2,1,1,1,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
     ,3,3,3,3,3,3,3,3,3,3,3,3,0,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
     ,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,1,0,1,0,1,0,1,0,0,0,1,0,0,0,1,0,1
     ,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,3,0,0,0,3,0,1,0,0,0,0,0,0,0,1);
    SRC  : array[0..255] of byte=(16,24,40,56,203,217,221,237,253,206,143,136,137,138,139,140,141,142,135,128,129,130,131,132
     ,133,134,198,167,160,161,162,163,164,165,166,230,205,220,252,47,63,191,184,185,186,187,188,189,190,212,196,244,236,254,
     228,204,39,9,25,41,57,61,05,13,21,29,37,45,53,11,27,43,59,243,251,118,8,219,60,4,12,20,28,36,44,52,3,19,35,51,218,250,
     195,210,194,242,234,226,202,58,10,26,42,1,17,33,49,127,120,121,122,123,124,125,126,71,64,65,66,67,68,69,70,79,72,73,74,
     75,76,77,78,87,80,81,82,83,84,85,86,95,88,89,90,91,92,93,94,103,96,97,98,99,100,101,102,111,104,105,106,107,108,109,110,
     119,112,113,114,115,116,117,62,6,14,22,30,38,46,54,0,183,176,177,178,179,180,181,182,246,211,233,193,209,225,241,197,213
     ,229,245,23,31,216,201,32,7,248,208,192,240,232,224,15,199,207,215,223,231,239,247,255,200,159,152,153,154,155,156,157,
     158,222,34,48,249,50,2,18,55,151,144,145,146,147,148,149,150,214,235,175,168,169,170,171,172,173,174,238,227);
    LEN  : array[0..256] of byte=(1,3,1,1,1,1,2,1,3,1,1,1,1,1,2,1,0,3,1,1,1,1,2,1,0,1,1,1,1,1,2,1,1,3,3,1,1,1,2,1,0,1,3,1,1,1
     ,2,1,1,3,3,1,1,1,2,1,0,1,3,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
     ,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
     ,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,1,2,1,1,1,3,0,3,3,2,1,1,1,3,2,3,1,2,1,1,0,3,2,3,0,2,3,1,1
     ,3,1,3,1,2,1,1,1,3,1,3,0,2,1,1,1,3,1,3,1,2,1,1,1,3,1,3,0,2,1,0);
  function INKEY : char;
    var
      AC : char;
    begin
      if INKEYP
       then begin
              INKEY  := AC;
              INKEYP := false;
            end
       else begin
              SAVEREG.AX := 0;
              intr($16,SAVEREG);
              if SAVEHALF.AL = 0
               then begin
                      INKEY  := #27;
                      AC     := chr(SAVEHALF.AH);
                      INKEYP := true;
                    end
               else begin
                      INKEY  := chr(SAVEHALF.AL);
                      INKEYP := false;
                    end;
           end;
    end;
  function SPC(N : integer) : G255_;
    var
      I_ : string[255];
    begin
      I_ := '';
      for I := 1 to N do I_ := I_+' ';
      SPC := I_;
    end;
  procedure NORMAL_COLOR;
    begin
      TextColor(10);
      TextBackground(0);
    end;
  procedure MAIN_SCREEN;
    begin
      clrscr;
      writeln('By Raanan Kleinfeld                           1988 (c) All rights reserved MADA');
      writeln('ษอออออออออออออออออออออออออออออออออออออออออหอออออออออออออออออออออออออออออออออออป');
      writeln('บ Line  1 - Column  1 - Replace  Ver 2.00 บ       Flag registers - s z p c    บ');
      writeln('ฬออออออออออออออออออออัออออออออออออออออออออน                                   บ');
      writeln('บ                    ณ                    บ   AC  - h00 b00000000 d  0        บ');
      writeln('บ                    ณ                    บ   B   - h00    C - h00    M - h00 บ');
      writeln('บ                    ณ                    บ   D   - h00    E - h00    M - h00 บ');
      writeln('บ                    ณ                    บ   H   - h00    L - h00    M - h00 บ');
      writeln('บ                    ณ                    บ   SP  - h0000                     บ');
      writeln('บ                    ณ                    บ   PC  - h0000             M - h00 บ');
      writeln('บ                    ณ                    บ   PSW - h0000                     บ');
      writeln('บ                    ณ                    บ  Keyboard                         บ');
      writeln('บ                    ณ                    บ   #FF ->  [                    ]  บ');
      writeln('บ                    ณ                    บ            ษอหอหอหอหอหอหอหอปOn Offบ');
      writeln('บ                    ณ                    บBinaric Out-บ๙บ๙บ๙บ๙บ๙บ๙บ๙บ๙บ þ  ๙ บ');
      writeln('บ                    ณ                    บDisplay In -บÜบÜบÜบÜบÜบÜบÜบÜบ Ü  ฿ บ');
      writeln('บ                    ณ                    บ  #00       ศอสอสอสอสอสอสอสอผ      บ');
      writeln('บ                    ณ                    บ                                   บ');
      writeln('บ                    ณ                    บDigital                            บ');
      writeln('บ                    ณ                    บ                                   บ');
      writeln('บ                    ณ                    บDisplay                            บ');
      writeln('บ                    ณ                    บ#04,#05                            บ');
      writeln('ศออออออออออออออออออออฯออออออออออออออออออออสอออออออออออออออออออออออออออออออออออผ');
      write  ('            F1-Orders F3-Error F5-Operator F7-Quit F9-Input\Output');
    end;
  function ADD_2(A2_ : G255_) : G255_;
    begin
      for I := length(A2_) to 1 do insert('0',A2_,1);
      ADD_2 := A2_;
    end;
  function ADD_4(A4_ : G255_) : G255_;
    begin
      for I := length(A4_) to 3 do insert('0',A4_,1);
      ADD_4 := A4_;
    end;
  function CHEZKA(N,M : integer) : integer;
    var
      PO,IC : integer;
    begin
      PO := 1;
      for IC := 1 to M do PO := PO*N;
      CHEZKA := PO;
    end;
  procedure BEEP;
    begin
      if BP = 1 then write(#7);
    end;
  procedure CLEAN_MESSEG_LINE;
    begin
      gotoxy(2,23);
      write(SPU_,'ฯ',SPU_);
    end;
  procedure ERROR(N : integer);
   begin
     CLEAN_MESSEG_LINE;
     if N = 0
      then exit
      else begin
             gotoxy(3,23); write(ERR_[N]);
             BEEP;
           end;
   end;
  procedure CURSOR(TURNON : boolean);
    begin
      if TURNON
       then if MEM[0 : $449] = 7
             then SAVEREG.CX := $C0D
             else SAVEREG.CX := $607
       else SAVEREG.CX := $2000;
      SAVEREG.AX := $100;
      INTR($10,SAVEREG);
    end;
  function GET_CHAR : integer;
    begin
      SAVEREG.AX := $800;
      SAVEREG.BX := 0;
      INTR($10,SAVEREG);
      GET_CHAR := SAVEREG.AX;
    end;
  function ZIMZOM(N : integer) : integer;
    begin
      if N > 256
       then begin
              N := N-256;
              N := ZIMZOM(N);
            end;
      ZIMZOM := N;
    end;
  function HARCHAVA(N : integer) : integer;
    begin
      if N < -256
       then begin
              N := N+256;
              N := HARCHAVA(N);
            end;
      HARCHAVA := N;
    end;
  procedure SCREEN(WX,WY : integer);
    begin
      gotoxy(WX,WY);
      CC    := GET_CHAR;
      VIEW_ := chr(ZIMZOM(CC));
    end;
  function HEX(N : integer) : G255_;
    var
      DX   : integer;
      DX_  : string[1];
      HEX_ : string[4];
    begin
      HEX  := '';
      HEX_ := '';
      repeat
       DX := N mod 16;
       N  := N div 16;
       if DX in [0..9]
        then str(DX,DX_)
        else DX_ := chr(DX+55);
       insert(DX_,HEX_,1);
      until N = 0;
      HEX := HEX_;
    end;
  function DEC(N : integer; MM_ : G255_) : integer;
    var
      DX,DC,ID : integer;
      DX_ : string[4];
    begin
      MM_ := ADD_2(MM_);
      DX  := 0;
      DC  := 0;
      for ID := 1 to length(MM_) do
       begin
         DX_ := copy(MM_,ID,1);
         case DX_ of
          '0'..'9' : val(DX_,DX,VL);
          'A'..'F' : DX := ord(upcase(DX_))-55;
         end;
         DC := DC+DX*CHEZKA(N,length(MM_)-ID);
       end;
      DEC := DC;
    end;
  function SGN(N : integer) : integer;
    begin
      case N of
       -32767..-1 : N := -1;
       0          : N :=  0;
       1..32767   : N :=  1;
      end;
      SGN := N;
    end;
  procedure ADVANCE_LINE;
    begin
      if Y = 22
       then begin
              window(2,5,42,22);
              gotoxy(1,1); delline;
              window(1,1,80,25);
              gotoxy(22,22); write('ณ');
            end
       else Y := Y+1;
    end;
  procedure CLEAN_FULL_LINE;
    begin
      gotoxy(2,Y); write('                    ณ                   ');
    end;
  procedure PRESS_ANY_KEY;
    begin
      CLEAN_MESSEG_LINE;
      gotoxy(3,23); write('Press any key to continue');
      BEEP;
    end;
  procedure INPUT_POINTS;
    begin
      SCREEN(3,Y);
      if VIEW_ in ['0',' ','=']
       then begin
              SCREEN(2,Y);
              B := pos(VIEW_,CD_);
              if B in [1..11]
               then begin
                      gotoxy(2,Y); write(SPD_);
                      gotoxy(2,Y); write(VIEW_,CM_[B]);
                    end;
            end;
    end;
  function FLAGS(N : integer) : integer;
    begin
      Z   := 1-ABS(SGN(N));
      PPP := PA[N div 16]+PA[N-(N div 16)*16];
      if N >= 0 then S := 0
                else S := 1;
      N := HARCHAVA(N);
      N := ZIMZOM(N);
      FLAGS := N;
    end;
  function CARRY(N : integer) : integer;
    begin
      if (N > -256) and (N < 256) then CY := 0
                                  else CY := 1;
      N := ZIMZOM(N);
      N := HARCHAVA(N);
      CARRY := N;
    end;
  function ALL(N : integer) : integer;
    begin
      N := CARRY(N);
      N := FLAGS(N);
      ALL := N;
    end;
  procedure CHECK_LIN(N,M : integer);
    begin
      R := DEC(16,COPY(Z_,N,(M-N+1)));
      if (R < 256) or (R > 32767) then ERROR(1);
      LIN := R;
    end;
  procedure COLORS;
    begin
      if INS
       then begin
              NORMAL_COLOR;
              gotoxy(25,3);  write('Insert ');
              textcolor(25); textbackground(0);
            end
       else begin
              NORMAL_COLOR;
              gotoxy(25,3);  write('Replace');
              textcolor(9);  textbackground(0);
            end;
    end;
  procedure CLEAN_WINDOW;
    begin
      window(1,1,80,25);
      gotoxy(15,5);  write('ฺ');
      gotoxy(5,67);  write('ฟ');
      gotoxy(67,20); write('ู');
      gotoxy(15,20); write('ภ');
      for I := 16 to 66 do
       begin
         gotoxy(I,5);  write('ฤ');
         gotoxy(I,20); write('ฤ');
       end;
      for I := 6 to 19 do
       begin
         gotoxy(67,I); write('ณ');
         gotoxy(15,I); write('ณ');
       end;
      window(16,6,66,19);
      clrscr;
    end;
  procedure TAKE_WINDOW;
    begin
      window(1,1,80,25);
      for I := 15 to 67 do
       for J := 5 to 20 do
        begin
          SCREEN(I,J);
          WIN[I,J] := VIEW_;
        end;
      window(15,5,67,20);
      CLEAN_WINDOW;
    end;
  procedure PUT_WINDOW;
    begin
      window(1,1,80,25);
      for J := 5 to 20 do
       for I := 15 to 67 do
        begin
          gotoxy(I,J); write(WIN[I,J]);
        end;
    end;
  function INPUT(Q,W,LEN : integer; DCR_ : char; N : byte) : G255_;
    procedure INO;
      begin
        FIND := false;
        repeat
         CH_ := INKEY;
         CH_ := upcase(CH_);
         case N of
          1 : if not (CH_ in ['0'..'9','A'..'F',#13,#8,#27])
               then begin
                      BEEP;
                      INO;
                    end;
          2 : if not (CH_ in ['0'..'9',#13,#8,#27])
               then begin
                      BEEP;
                      INO;
                    end;
         end;
         case CH_ of
          ' ','.' : begin
                      BEEP;
                      INO;
                    end;
          #13     : if length(M_) = 0
                     then begin
                            BEEP;
                            INO;
                          end
                     else begin
                            gotoxy(XS,W); write(M_,SPC(LEN-length(M_)));
                            FIND := true;
                          end;
          #27     : begin
                      gotoxy(XS,W); write(M_,SPC(LEN-length(M_)));
                      FIND := true;
                      ESC  := true;
                      exit;
                    end;
          #8      : begin
                      if length(M_) = 0
                       then begin
                              BEEP;
                              INO;
                            end
                       else begin
                              M_ := copy(M_,1,length(M_)-1);
                              Q  := Q-1;
                              lowvideo;
                              gotoxy(Q,W); write(DCR_);
                              highvideo;
                              INO;
                            end;
                    end;
          else if length(M_) = LEN
                then begin
                       BEEP;
                       INO;
                     end
                else begin
                       Q  := Q+1;
                       M_ := M_+CH_;
                       gotoxy(XS,W); write(M_);
                       INO;
                     end;
         end;
        until FIND;
      end;
    begin
      ESC := false;
      lowvideo;
      gotoxy(Q,W); for I := 1 to LEN do write(DCR_);
      XS := Q;
      M_ := '';
      highvideo;
      INO;
      INPUT := M_;
      highvideo;
    end;
  function EXIST(FILENAME : G255_) : boolean;
    var
      FIL : FILE;
    begin
      assign(FIL,FILENAME);
      {$I-}
      reset(fil);
      {$I+}
      EXIST := ioresult = 0;
      close(FIL);
    end;
  procedure FID;
    begin
      for FLS := 0 to filesize(F1)-1 do
       begin
         seek(F1,FLS);
         read(F1,R1);
         if R1.BOL then I := I+1;
         if (R1.FILENAME_ = A_) and R1.BOL
          then begin
                 GO := true;
                 exit;
               end;
       end;
      GO := false;
    end;
  procedure DIR;
    procedure DIS;
      begin
        seek(F1,E);
        read(F1,R1);
        if not R1.BOL
         then begin
                E := E+1;
                DIS;
              end
         else begin
                gotoxy(12,J+4); write(R1.FILENAME_,SPC(8-length(R1.FILENAME_)));
                gotoxy(20,J+4); write(' |  ',ADD_4(HEX(R1.START_ADDR)));
                gotoxy(28,J+4); write(' |  ',ADD_4(HEX(R1.RANGE)));
                if E+1 = filesize(F1)
                 then for D := J+1 to 8 do
                       begin
                         gotoxy(12,D+4); write('                        ');
                       end
                 else begin
                        E := E+1;
                        J := J+1;
                        if J < 8 then DIS;
                      end;
                if E > filesize(F1)
                 then begin
                        E := E-1;
                        J := J-1;
                        DIS;
                      end;
              end;
        E := E-1;
      end;
    begin
      CLEAN_WINDOW;
      gotoxy(18,1);  write(': DIRECTORY :');
      gotoxy(11,3);  write('   NAME     START   RANGE');
      gotoxy(11,4);  write('--------------------------');
      gotoxy(10,13); writeln('Home, End, Up, Down, F7 Exit');
      if not EXIST('MCRNAME.DAT')
       then begin
              gotoxy(21,5); write('No file');
              gotoxy(18,6); write('Press any key');
              BEEP;
              repeat until keypressed;
              CLEAN_WINDOW;
              exit;
            end;
      assign(F1,'MCRNAME.DAT');
      reset(F1);
      I := 0;
      FID;
      if (filesize(F1) = 0) or (I = 0)
       then begin
              gotoxy(21,5); write('No file');
              gotoxy(18,6); write('Press any key');
              BEEP;
              repeat until keypressed;
              CLEAN_WINDOW;
              exit;
            end;
      FIND := false;
      E := 0;
      repeat
       J := 1;
       DIS;
       CH_ := INKEY;
       if (CH_ = #27) and INKEYP
        then begin
               CH_ := INKEY;
               case CH_ of
                #65 : FIND := true;
                #71 : E    := 0;
                #72 : E    := E-1;
                #79 : E    := filesize(F1)-1;
                #80 : E    := E+2;
                else BEEP;
               end;
             end
        else BEEP;
       if E < 0 then E := 0;
       if E > filesize(F1)-1 then E := filesize(F1)-1;
      until FIND;
      CLEAN_WINDOW;
    end;
  procedure SVE;
    procedure STAR;
      begin
        A_ := INPUT(24,6,4,'_',1);
        if ESC then exit;
        CH_ := copy(ADD_4(A_),1,1);
        if not (CH_ in ['0'..'7'])
         then begin
                BEEP;
                STAR;
              end;
        START := DEC(16,A_);
      end;
    procedure ENDR;
      begin
        A_ := INPUT(29,6,4,'_',1);
        if ESC then exit;
        CH_ := copy(ADD_4(A_),1,1);
        if not (CH_ in ['0'..'7'])
         then begin
                BEEP;
                ENDR;
              end;
        F := DEC(16,A_);
        if START > F
         then begin
                BEEP;
                ENDR;
              end;
      end;
    begin
      ESC := true;
      A_  := INPUT(27,4,8,'_',0);
      if D = 1
       then FID
       else FLS := 0;
      if not Go then FLS := FLS+1;
      if ESC then exit;
      D_ := A_;
      STAR;
      if ESC then exit;
      ENDR;
      if ESC then exit;
      ESC := false;
    end;
  procedure SAVE;
    begin
      CLEAN_WINDOW;
      gotoxy(21,1); write(': SAVE :');
      gotoxy(21,2); write('--------');
      if EXIST('MCRNAME.DAT')
       then begin
              D := 1;
              assign(F1,'MCRNAME.DAT');
              reset(F1);
            end
       else begin
              D := 0;
              assign(F1,'MCRNAME.DAT');
              rewrite(F1);
            end;
      gotoxy(15,4);  write('File name : ________');
      gotoxy(16,6);  write('Range : ____-____');
      gotoxy(17,12); writeln('Enter, <-, Esc');
      gotoxy(12,13); write('Press any key to continue');
      SVE;
      if ESC
       then begin
              CLEAN_WINDOW;
              exit;
            end;
      R1.FILENAME_  := D_;
      R1.START_ADDR := START;
      R1.RANGE      := F-START+1;
      R1.BOL        := true;
      seek(F1,FLS);
      write(F1,R1);
      D_ := D_+'.DAT';
      assign(F2,D_);
      rewrite(F2);
      for I := START to F do
       begin
         R2.OPCOD := MRY[I];
         write(F2,R2);
       end;
      CLEAN_WINDOW;
    end;
  procedure LOD;
    procedure LODA;
      begin
        A_ := INPUT(27,4,8,'_',0);
        D_ := A_;
        if ESC then exit;
        FID;
        if (not GO) or (not EXIST(D_+'.DAT'))
         then begin
                gotoxy(35,5); write('File not found');
                BEEP;
                repeat until keypressed;
                gotoxy(35,5); write('              ');
                ESC := true;
                exit;
              end;
      end;
    procedure LODB;
      begin
        A_ := INPUT(34,6,4,'_',1);
        if ESC then exit;
        CH_ := copy(ADD_4(A_),1,1);
        if not (CH_ in ['0'..'7'])
         then begin
                BEEP;
                LODB;
              end;
        START := DEC(16,A_);
      end;
    begin
      LODA;
      if ESC then exit;
      seek(F1,FLS);
      read(F1,R1);
      gotoxy(26,6); write(ADD_4(HEX(R1.START_ADDR)));
      LODB;
    end;
  procedure LOAD;
    begin
      CLEAN_WINDOW;
      gotoxy(21,1); write(': LOAD :');
      gotoxy(21,2); write('--------');
      if not EXIST('MCRNAME.DAT')
       then begin
              gotoxy(8,4);  write('Main file "MCRNAME.DAT" not found');
              gotoxy(18,6); write('Press any key');
              BEEP;
              repeat until keypressed;
              CLEAN_WINDOW;
              exit;
            end;
      assign(F1,'MCRNAME.DAT');
      gotoxy(15,4);  write('File name : ________');
      gotoxy(20,6);  write('From (    ) : ____');
      gotoxy(17,12); writeln('Enter, <-, Esc');
      gotoxy(12,13); write('Press any key to continue');
      reset(F1);
      LOD;
      if ESC
       then begin
              CLEAN_WINDOW;
              exit;
            end;
      R1.FILENAME_  := D_;
      R1.START_ADDR := START;
      R1.RANGE      := N;
      R1.BOL        := true;
      seek(F1,FLS);
      write(F1,R1);
      D_ := D_+'.DAT';
      I  := START;
      N  := 0;
      assign(F2,D_);
      reset(F2);
      while not eof(F2) do
       begin
         if I > 32767 then I := 256;
         read(F2,R2);
         MRY[I] := R2.OPCOD;
         I      := I+1;
         N      := N+1;
       end;
      CLEAN_WINDOW;
    end;
  procedure ERAS;
    procedure ERASEA;
      begin
        A_ := INPUT(27,4,8,'_',0);
        D_ := A_;
        if ESC then exit;
        FID;
        if (not GO) or (not EXIST(D_+'.DAT'))
         then begin
                gotoxy(35,5); write('File not found');
                BEEP;
                repeat until keypressed;
                gotoxy(35,5); write('              ');
                ESC := true;
                exit;
              end;
      end;
    begin
      ERASEA;
      if ESC then exit;
    end;
  procedure ERASE;
    begin
      CLEAN_WINDOW;
      gotoxy(21,1); write(': ERASE :');
      gotoxy(21,2); write('---------');
      if not EXIST('MCRNAME.DAT')
       then begin
              gotoxy(8,4);  write('Main file "MCRNAME.DAT" not found');
              gotoxy(18,6); write('Press any key');
              BEEP;
              repeat until keypressed;
              CLEAN_WINDOW;
              exit;
            end;
      assign(F1,'MCRNAME.DAT');
      gotoxy(15,4);  write('File name : ________');
      gotoxy(8,6);   write('!!! Confirm erasing !!! (Y/N) : _');
      gotoxy(17,12); write('Enter, <-, Esc');
      gotoxy(12,13); write('Press any key to continue');
      reset(F1);
      ERAS;
      if ESC
       then begin
              CLEAN_WINDOW;
              exit;
            end;
      repeat
       TRS := true;
       lowvideo;
       gotoxy(8,6); write('!!! Confirm erasing !!! (Y/N) : _');
       highvideo;
       CH_ := INKEY;
       gotoxy(40,6); write(CH_);
       case CH_ of
        'Y','y',''     : begin
                            R1.BOL := false;
                            seek(F1,FLS);
                            write(F1,R1);
                            assign(F2,D_);
                            CLEAN_WINDOW;
                          end;
        'N','n','',#27 : begin
                            CLEAN_WINDOW;
                          end;
        else              begin
                            TRS := false;
                            BEEP;
                          end;
       end;
      until TRS;
    end;
  procedure INUT;
    begin
      D_ := 'MCRNAME.DAT';
      TAKE_WINDOW;
      LOOP := false;
      FIND := false;
      repeat
       gotoxy(11,1);  write(': INPUT OUTPUT - MAIN MENU :');
       gotoxy(11,2);  write('----------------------------');
       gotoxy(20,4);  write('1. Load.');
       gotoxy(20,5);  write('2. Save.');
       gotoxy(20,6);  write('3. Dir.');
       gotoxy(20,7);  write('4. Erase.');
       gotoxy(20,12); write('F7 Exit');
       gotoxy(12,13); write('Press any key to continue');
       CH_ := INKEY;
       TRS := true;
       if (CH_ = #27) and INKEYP
        then begin
               CH_ := INKEY;
               IF CH_ = #65 then LOOP := true;
             end
        else case CH_ of
              '1' : LOAD;
              '2' : SAVE;
              '3' : DIR;
              '4' : ERASE;
              else BEEP;
             end;
       {$I-}
       close(F1);
       {$I+}
       if ioresult <> 0 then begin
                               assign(F1,'MCRNAME.DAT');
                               close(F1);
                             end;
       {$I-}
       close(F2);
       {$I+}
       if ioresult <> 0 then begin
                               assign(F2,D_);
                               close(F2);
                             end;
      until LOOP;
      PUT_WINDOW;
    end;
  procedure REGISTERS;
    begin
      gotoxy(68,3);  write(FP_[S*8+Z*4+PPP*2+CY]);
      gotoxy(54,5);  write(ADD_2(HEX(RA)));
      A_ := HEX(RA);
      gotoxy(58,5);  write(BIN_[DEC(16,copy(A_,1,1))],BIN_[DEC(16,copy(A_,2,1))]);
      gotoxy(68,5);  write(RA:3);
      gotoxy(54,6);  write(ADD_2(HEX(RB)));
      gotoxy(54,7);  write(ADD_2(HEX(RD)));
      gotoxy(54,8);  write(ADD_2(HEX(RH)));
      gotoxy(65,6);  write(ADD_2(HEX(RC)));
      gotoxy(65,7);  write(ADD_2(HEX(RE)));
      gotoxy(65,8);  write(ADD_2(HEX(RL)));
      gotoxy(76,6);  write(ADD_2(HEX(MRY[RB*256+RC])));
      gotoxy(76,7);  write(ADD_2(HEX(MRY[RD*256+RE])));
      gotoxy(76,8);  write(ADD_2(HEX(MRY[RH*256+RL])));
      gotoxy(54,9);  write(ADD_4(HEX(SP)));
      gotoxy(54,10); write(ADD_4(HEX(LIN)));
      gotoxy(76,10); write(ADD_2(HEX(MRY[LIN])));
      gotoxy(54,11); write(ADD_4(HEX((S*256+Z*128+PPP*8+C)*256+RA)));
    end;