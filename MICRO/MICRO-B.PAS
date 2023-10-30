 procedure COMMAND;
    begin
      GO := false;
      TAKE_WINDOW;
      repeat
       gotoxy(13,2);  write(': COMMANDS - Main menu :');
       gotoxy(13,3);  write('------------------------');
       gotoxy(5,5);   write('A. A0000              O. O0000');
       gotoxy(5,6);   write('C. CLS                P. P0000-0000');
       gotoxy(5,7);   write('G. G0000              R. R:reg=');
       gotoxy(5,8);   write('K. K0000-0000         S. S0000');
       gotoxy(5,9);   write('L. L0000-0000         T. T0000');
       gotoxy(5,10);  write('M. M0000-0000 0000');
       gotoxy(20,11); write('F7 - Exit.'); 
       gotoxy(15,13); write('Enter your choice ?'); 
       CH_ := INKEY; 
       case upcase(CH_) of
        'A' : begin
                CLEAN_WINDOW;
                writeln('              : A0000 - Append :');
                writeln('              ------------------');
                writeln('');
                writeln(' A0000 ___________    A2000 MVI  A,38 <- Example');
                writeln(' ³ÀÄÂÙ ÀÄÂÙÀÄÄÂÄÄÙ');
                writeln(' ³  ³    ³    ÀÄ> Mnemonics operand.');
                writeln(' ³  ³    ³');
                writeln(' ³  ³    ÀÄ> Mnemonics operation.');
                writeln(' ³  ³');
                writeln(' ³  ÀÄ> Address in Hex.');
                writeln(' ³');
                writeln(' ÀÄ> Command.');
                gotoxy(1,14); write('          Press any key to continue');
                CH_ := INKEY;
              end;
        'C' : begin
                CLEAN_WINDOW;
                writeln('             : CLS - Clear Screen :');
                writeln('             ----------------------');
                writeln('');
                writeln(' CLS');
                writeln(' ÀÂÙ');
                writeln('  ÀÄ> Command.');
                gotoxy(1,14); write('            Press any key to continue');
                CH_ := INKEY;
              end;
        'G' : begin
                CLEAN_WINDOW;
                writeln('               : G0000 - Run :');
                writeln('               ---------------');
                writeln('');
                writeln(' G0000                           G2000 <- Example');
                writeln(' ³ÀÄÂÙ');
                writeln(' ³  ÀÄ> Address in Hex.');
                writeln(' ³');
                writeln(' ÀÄ> Command.');
                gotoxy(1,14); write('            Press any key to continue');
                CH_ := INKEY;
              end;
        'K' : begin
                CLEAN_WINDOW;
                writeln('        : K0000-0000 - List in Opcodes :');
                writeln('        --------------------------------');
                writeln('');
                writeln(' This option will do exactly as L0000-0000 option');
                writeln(' 5 in the menu but all will be written in the');
                writeln(' other way example :');
                writeln(' O2010:3E,38        ³A2010 MVI  A,38');
                gotoxy(1,14); write('            Press any key to continue');
                CH_ := INKEY;
              end;
        'L' : begin
                CLEAN_WINDOW;
                writeln('       : L0000-0000 - List in Mnemonics :');
                writeln('       ----------------------------------');
                writeln('  Option 1 :');
                writeln(' L0000-0000                 L2000-2010 <- Example');
                writeln(' ³ÀÄÂÙ ÀÄÂÙ');
                writeln(' ³  ³    ÀÄ> Address in Hex.');
                writeln(' ³  ÀÄ> Address in Hex.');
                writeln(' ÀÄ> Command.');
                writeln(' This option will create a range and all the ');
                writeln(' mnemonics in this range will be writen.');
                writeln('  Output -> A2000:MVI  A,38      ³O2000:3E,38');
                writeln('               .   .    .        .  .   .  .');
                writeln('            A2010:HLT            ³O2000:76');
                write('            Press any key to continue');
                CH_ := INKEY;
                CLEAN_WINDOW;
                writeln('       : L0000-0000 - List in Mnemonics :');
                writeln('       ----------------------------------');
                writeln('  Option 2 :');
                writeln(' L0000-                         L2000- <- Example');
                writeln(' ³ÀÄÂÙ');
                writeln(' ³  ³');
                writeln(' ³  ÀÄ> Address in Hex.');
                writeln(' ÀÄ> Command.');
                writeln(' This option will write all the mnemonics from');
                writeln(' the first number until 7FFF Hex.');
                writeln('  Output -> A2000:MVI  A,38      ³O2000:3E,38');
                writeln('               .   .    .        .  .   .  .');
                writeln('            A7FFF:HLT            ³O2000:76');
                write('            Press any key to continue');
                CH_ := INKEY;
                CLEAN_WINDOW;
                writeln('       : L0000-0000 - List in Mnemonics :');
                writeln('       ----------------------------------');
                writeln('  Option 3 :');
                writeln(' L0000                           L2000 <- Example'); writeln(' ³ÀÄÂÙ');
                writeln(' ³ÀÄÂÙ');
                writeln(' ³  ÀÄ> Address in Hex.');
                writeln(' ÀÄ> Command.');
                writeln('');
                writeln(' This option will write one line only.');
                writeln('');
                writeln('  Output -> A2000:MVI  A,38      ³O2000:3E,38');
                gotoxy(1,14); write('          Press any key to continue');
                CH_ := INKEY;
              end;
        'M' : begin
                CLEAN_WINDOW;
                writeln('           : M0000-0000 0000 - Move :');
                writeln('           --------------------------');
                writeln('');
                writeln(' M0000-0000 0000       M2000-2010 3000 <- Example');
                writeln(' ³ÀÄÂÙ ÀÄÂÙ ÀÄÂÙ');
                writeln(' ³  ³    ³    ÀÄ> Address in Hex, where');
                writeln(' ³  ³    ³        to start the new addressing.');
                writeln(' ³  ³    ÀÄ> Address in Hex.');
                writeln(' ³  ÀÄ> Address in Hex.');
                writeln(' ÀÄ> Command.');
                writeln(' This command will create a range and will move');
                writeln(' all the op codes to the following address of the');
                writeln(' third address number.');
                write('            Press any key to continue');
                CH_ := INKEY;
              end;
        'O' : begin
                CLEAN_WINDOW;
                writeln('              : O0000 - Append :');
                writeln('              ------------------');
                writeln('');
                writeln(' O0000 __ ____      O2000 3E,38 <- Example');
                writeln(' ³ÀÄÂÙ À´ ÀÄÂÙ');
                writeln(' ³  ³   ³   ÀÄ> Op code operand.');
                writeln(' ³  ³   ³');
                writeln(' ³  ³   ÀÄ> Op code operation.');
                writeln(' ³  ³');
                writeln(' ³  ÀÄ> Address in Hex.');
                writeln(' ³');
                writeln(' ÀÄ> Command.');
                gotoxy(1,14); write('            Press any key to continue');
                CH_ := INKEY;
              end;
        'P' : begin
                CLEAN_WINDOW;
                writeln('       : P0000-0000 - Print in mnemonics :');
                writeln('       -----------------------------------');
                writeln('');
                writeln(' This option will do exactly as L0000-0000 option');
                writeln(' 5 in the menu but only will print the lines to');
                writeln(' printer.');
                gotoxy(1,14); write('            Press any key to continue');
                CH_ := INKEY;
              end;
        'R' : begin
                CLEAN_WINDOW;
                writeln('  : R:reg= - Set a register or flag to a value :');
                writeln('  ----------------------------------------------');
                writeln(' R:reg=____                      R:A=15 - Example');
                writeln(' ³ ÀÂÙ ÀÄÂÙ');
                writeln(' ³  ³    ÀÄ> Value in Hex.');
                writeln(' ³  ÀÄ> Name of register.');
                writeln(' ÀÄ> Command.');
                writeln(' A, B, C, D, E, H, L, M(HL).');
                writeln(' SP - Stack pointer, PC - Program counter.');
                writeln(' PSW - Accumolator + Flag register.');
                writeln(' BC, DE, HL - Pair register.');
                writeln(' S - Sign, Z - Zero, P - Parity, CY - Carry.');
                writeln(' R:A=15 give the register A the value 15(hex).');
                write('            Press any key to continue');
                CH_ := INKEY;
              end;
        'S' : begin
                CLEAN_WINDOW;
                writeln('                : S0000 - Set:');
                writeln('                --------------');
                writeln('');
                writeln(' S0000 __,__,__,...   S2000 48,54 <- Example');
                writeln(' ³ÀÄÂÙ À´ À´ À´ À´');
                writeln(' ³  ³   ÀÄÄÁÄÄÁÄÄÁÄ> Op codes.');
                writeln(' ³  ÀÄ> Address in Hex.');
                writeln(' ÀÄ> Command.');
                writeln('');
                writeln(' This command will set the memory to the');
                writeln(' following opcodes as much as there are.');
                gotoxy(1,14); write('          Press any key to continue');
                CH_ := INKEY;
              end;
        'T' : begin
                CLEAN_WINDOW;
                writeln('              : T0000 - Trace :');
                writeln('              -----------------');
                writeln('');
                writeln(' T0000                           T2000 <- Example');
                writeln(' ³ÀÄÂÙ');
                writeln(' ³  ÀÄ> Address in Hex.');
                writeln(' ³');
                writeln(' ÀÄ> Command.');
                gotoxy(1,14); write('            Press any key to continue');
                CH_ := INKEY;
              end;
        else if (CH_ = #27) and INKEYP
              then begin
                     CH_ := INKEY;
                     if CH_ = #65
                      then GO := true
                      else BEEP;
                   end
              else BEEP;
       end;
       CLEAN_WINDOW;
      until GO;
      PUT_WINDOW;
    end;
  procedure ERLA;
    begin
      Q := 6;
      gotoxy(5,4); write(SPD_,SPD_);
      gotoxy(5+(40-length(ERR_[W])) div 2,4); write(ERR_[W]);
      gotoxy(5,5); write('----------------------------------------');
      for I := (W-1)*3+1 to (W-1)*3+3 do
       begin
         gotoxy(1,Q); write('                                                  ');
         gotoxy(3,Q); write(ERT[I]);
         Q := Q+1;
       end;
    end;
  procedure ERL;
    begin
      TAKE_WINDOW;
      gotoxy(20,1);  write(': ERROR :');
      gotoxy(20,2);  write('---------');
      gotoxy(11,12); write('Home, End, Up, Down, F7 exit');
      gotoxy(18,13); write('Press any key');
      W  := 1;
      GO := false;
      repeat
       ERLA;
       CH_ := INKEY;
       if (CH_ = #27) and INKEYP
        then begin
               CH_ := INKEY;
               case CH_ of
                #71 : W  := 1;
                #79 : W  := 8;
                #72 : W  := W-1;
                #80 : W  := W+1;
                #65 : GO := true;
               end;
               if W<1 then W := 1;
               if W>8 then W := 8;
               end
        else BEEP;
      until GO;
      PUT_WINDOW;
    end;
  procedure IPUS;
    begin
      RA  := 0;RB := 0;RC := 0;RD  := 0;RE := 0;RH := 0;RL := 0;
      CY  := 0;S  := 0;Z  := 0;PPP := 0;
      SP  := $38FE;
      LIN := $2000;
    end;
  procedure OPERATE;
    var
      MENU : array[2..3] of boolean;
    begin
      for I := 2 to 3 do MENU[I] := false;
      TAKE_WINDOW;
      LOOP := false;
      repeat
       gotoxy(13,1); write(': OPERATE - MAIN MENU :');
       gotoxy(13,2); write('-----------------------');
       gotoxy(2,4);  write('1. Beep - ');
       case BP of
        0 : write('OFF.');
        1 : write('ON. ');
       end;
       gotoxy(2,5);   write('2. Clean ports - ',MENU[2],'. ');
       gotoxy(2,6);   write('3. Clear registers - ',MENU[3],'. ');
       gotoxy(20,12); write('F7 Exit');
       gotoxy(12,13); write('Press any key to continue');
       CH_ := INKEY;
       if (CH_ = #27) and INKEYP
        then begin
               CH_ := INKEY;
               if CH_ = #65 then LOOP := true;
             end
        else begin
               case CH_ of
                '1' : begin
                        BP := 1-BP;
                        beep;
                      end;
                '2' : MENU[2] := not(MENU[2]);
                '3' : MENU[3] := not(MENU[3]);
                else BEEP;
               end;
             end;
      until LOOP;
      PUT_WINDOW;
      if MENU[2]
       then begin
              T   := 1;
              INK := 1;
              IN5 := 1;
              gotoxy(56,13); write(SPD_);
              gotoxy(57,15); write('ùºùºùºùºùºùºùºù');
              gotoxy(57,16); write('ÜºÜºÜºÜºÜºÜºÜºÜ');
              for I := 18 to 22 do
               begin
                 gotoxy(53,I); write('                          ');
               end;
            end;
      if MENU[3]
       then begin
              IPUS;
              REGISTERS;
            end;
    end;
  procedure HOZAAT_REVACHIM;
    begin
      J := 0;
      CH_ := ' ';
      I := 1;
      repeat
       CH_ := copy(Z_,I,1);
       if (CH_ in [' ','-','*',',','#',':']) and (I<>1)
        then begin
               delete(Z_,I,1);
               J := J+1;
             end
        else I := I+1;
      until CH_ = '³';
      A := length(Z_);
      for I := A to J+A-1 do insert(' ',Z_,I);
    end;
  procedure CHECK_CMD_LSD;
    begin
      CMD_ := '';
      LSD_ := '';
      B_ := copy(Z_,8,14);
      B := pos(' ',B_);
      CMD_ := copy(B_,1,B-1);
      case length(CMD_) of
       2 : CMD_ := CMD_+'  ';
       3 : CMD_ := CMD_+' ';
      end;
      I := B+7;
      repeat
       I := I+1;
       B_ := copy(Z_,I,1);
      until (I = 23) or (B_<>' ');
      if I = 23
       then LSD_ := '       '
       else begin
              LSD_ := copy(Z_,I,7);
              if copy(LSD_,1,2)<>'SP'
               then LSD_ := copy(LSD_,1,pos(' ',LSD_)-1);
            end;
      M_ :='A'+copy(Z_,3,4)+':'+CMD_+' '+LSD_;
    end;
  procedure APPEND;
    begin
      SCREEN(8,Y);
      if VIEW_ = ' '
       then begin
              ADVANCE_LINE;
              CLEAN_FULL_LINE;
              X := 2;
              exit;
            end;
      CLEAN_FULL_LINE;
      CHECK_CMD_LSD;
      gotoxy(2,Y); write(M_);
      OP := 0;
      A  := 1;
      I  := 8;
      repeat
       I  := I-1;
       OP := OP+CHEZKA(2,I)*A;
       N  := SRC[OP];
       E_ := CMD_+copy(LSD_,1,OPRL[N]);
       B_ := copy(MEM_[N],1,MEML[N]);
       case length(B_) of
        2 : B_ := B_+'  ';
        3 : B_ := B_+' ';
       end;
       C_ := B_+copy(OPR_[N],1,OPRL[N]);
       if E_>C_
        then A := 1
        else A := -1;
      until (I = 0) or (C_ = E_);
      if (I = 0) and (C_<>E_)
       then begin
              ERROR(2);
              exit;
            end;
      if C_ = E_
       then begin
              OP := N;
              O_ := 'O'+copy(Z_,3,4)+':'+ADD_2(HEX(OP));
              B  := pos('$',OPR_[OP]);
              if B<>0
               then begin
                      B    := B+4;
                      LOOP := false;
                      for I := length(LSD_) to 6 do LSD_ := LSD_+' ';
                      I  := B;
                      P_ := '';
                      repeat
                       B_ := copy(LSD_,I-4,1);
                       case B_ of
                        'A'..'F','0'..'9' : P_   := P_+B_;
                        ' '               : LOOP := true;
                        else begin
                               ERROR(3);
                               exit;
                             end;
                       end;
                       I := I+1;
                      until (I = 12) or LOOP;
                      if (P_ = '')
                       then begin
                              ERROR(3);
                              exit;
                            end
                       else begin
                              W := 0;
                              W := LEN[OP];
                              if W*2-2<>length(P_)
                               then begin
                                      ERROR(3);
                                      exit;
                                    end
                               else begin
                                      case length(P_) of
                                       2 : begin
                                             O_ := O_+','+P_;
                                             MRY[LIN+1] := DEC(16,P_);
                                           end;
                                       4 : begin
                                             O_ := O_+','+copy(P_,3,2)+','+copy(P_,1,2);
                                             MRY[LIN+2] := DEC(16,copy(P_,1,2));
                                             MRY[LIN+1] := DEC(16,copy(P_,3,2));
                                           end;
                                       else O_ := '';
                                      end;
                                    end;
                            end;
                    end;
            end;
      MRY[LIN] := OP;
      gotoxy(23,Y); write(O_);
      ADVANCE_LINE;
      LIN := LIN+LEN[OP];
      if LIN>32767 then LIN := 257;
      SCREEN(7,Y);
      if VIEW_<>':' then CLEAN_FULL_LINE;
      gotoxy(2,Y); write('A',ADD_4(HEX(LIN)));
    end;
  procedure OPCODE;
    begin
      SCREEN(8,Y);
      if VIEW_ = ' '
       then begin
              ADVANCE_LINE;
              CLEAN_FULL_LINE;
              X := 2; 
              exit;
            end; 
      HOZAAT_REVACHIM; 
      B := pos(':',Z_);
      if B = 0
       then B := 7
       else B := 8;
      A_ := '';
      repeat
       CH_ := copy(Z_,B,1);
       if CH_ in ['0'..'9','A'..'F'] then A_ := A_+CH_;
       B := B+1;
      until (CH_ = ' ') or (B = 22);
      C := length(A_);
      if (int(C/2)<>(C/2)) or (C = 0)
       then begin
              ERROR(7);
              exit;
            end; 
      OP := DEC(16,copy(A_,1,2));
      M_ := 'A'+HEX(LIN)+':';
      O_ := 'O'+HEX(LIN)+':';
      N := LEN[OP]; 
      CMD_ := '';
      LSD_ := '';
      case N of
       0 : begin
             ERROR(8);
             exit;
           end;
       1 : begin
             if length(A_)<>2
              then begin
                     ERROR(7);
                     exit;
                   end;
             M_ := M_+MEM_[OP]+SPC(4-length(MEM_[OP]))+' '+copy(OPR_[OP],1,OPRL[OP]);
             O_ := O_+ADD_2(HEX(OP));
             MRY[LIN] := OP;
           end;
       2 : begin
             if length(A_)<>4
              then begin
                     ERROR(7);
                     exit;
                   end;
             C  := pos('$',OPR_[OP]);
             B_ := copy(A_,3,2);
             M_ := M_+MEM_[OP]+SPC(4-length(MEM_[OP]))+' '+copy(OPR_[OP],1,C-1)+B_;
             O_ := O_+ADD_2(HEX(OP))+','+B_;
             MRY[LIN]   := OP;
             MRY[LIN+1] := DEC(16,B_);
           end;
       3 : begin
             if length(A_)<>6
              then begin
                     ERROR(7);
                     exit;
                   end;
             C  := pos('$',OPR_[OP]);
             B_ := copy(A_,3,2);
             C_ := copy(A_,5,2);
             M_ := M_+MEM_[OP]+SPC(4-length(MEM_[OP]))+' '+copy(OPR_[OP],1,C-1)+C_+B_;
             O_ := O_+ADD_2(HEX(OP))+','+B_+','+C_;
             MRY[LIN]   := OP;
             MRY[LIN+1] := DEC(16,B_);
             MRY[LIN+2] := DEC(16,C_);
           end;
      end;
      SCREEN(7,Y);
      if VIEW_<>':' then CLEAN_FULL_LINE;
      gotoxy(2,Y);  write(O_);
      gotoxy(23,Y); write(M_);
      ADVANCE_LINE;
      LIN := LIN+LEN[OP];
      if LIN>32767 then LIN := 8192;
      SCREEN(7,Y);
      if VIEW_<>':' then CLEAN_FULL_LINE;
      gotoxy(2,Y); write('O',HEX(LIN));
    end;
  procedure LIST;
    begin
      START := LIN;
      D_    := C_;
      Q     := 0;
      LOOP  := false;
      X     := 2;
      ADVANCE_LINE;
      if (copy(Z_,7,1) = '-') and (copy(Z_,8,1) = ' ')
       then begin
              F   := 32767;
              CH_ := '1';
            end
       else begin
              CH_ := '0';
              HOZAAT_REVACHIM;
              case copy(Z_,7,1) of
               ' ' : F := START;
               else begin
                      CHECK_LIN(7,10);
                      if C_ = 'U' then exit;
                      F := LIN;
                    end
              end;
            end;
      if (CH_ = '1') and (D_ = 'P')
       then begin
              ERROR(1);
              exit;
            end;
      LIN := START;
      if F<LIN
       then begin
              ERROR(1);
              exit;
            end;
      repeat
       OP := MRY[LIN];
       N  := LEN[OP];
       M_ := 'A'+ADD_4(HEX(LIN))+':';
       O_ := 'O'+ADD_4(HEX(LIN))+':';
       case N of
        0 : begin
              M_ := M_+'----';
              O_ := O_+'--';
              N  := 1;
            end;
        1 : begin
              M_ := M_+MEM_[OP]+SPC(4-length(MEM_[OP]))+' '+copy(OPR_[OP],1,OPRL[OP]);
              O_ := O_+ADD_2(HEX(OP));
            end;
        2 : begin
              C  := pos('$',OPR_[OP]);
              M_ := M_+MEM_[OP]+SPC(4-length(MEM_[OP]))+' '+copy(OPR_[OP],1,C-1)+ADD_2(HEX(MRY[LIN+1]));
              O_ := O_+ADD_2(HEX(OP))+','+ADD_2(HEX(MRY[LIN+1]));
            end;
        3 : begin
              C  := pos('$',OPR_[OP]);
              M_:=M_+MEM_[OP]+SPC(4-length(MEM_[OP]))+' '+copy(OPR_[OP],1,C-1)+ADD_2(HEX(MRY[LIN+2]))+ADD_2(HEX(MRY[LIN+1]));
              O_ := O_+ADD_2(HEX(OP))+','+ADD_2(HEX(MRY[LIN+1]))+','+ADD_2(HEX(MRY[LIN+2]));
            end;
       end;
       CLEAN_FULL_LINE;
       case D_ of
        'L' : begin
                gotoxy(2,Y);  write(M_);
                gotoxy(23,Y); write(O_);
              end;
        'K' : begin
                gotoxy(2,Y);  write(O_);
                gotoxy(23,Y); write(M_);
              end;
        'P' : begin
                writeln(lst,'   ',copy(M_,2,length(M_)-1),SPC(28-length(M_)),copy(O_,7,length(O_)-6));
              end;
       end;
       if (D_ = 'L') or (D_ = 'K')
        then begin
               if Y = 22
                then begin
                       CLEAN_MESSEG_LINE;
                       gotoxy(2,23); write('Press space to continue, other to end.');
                       Y   := 5;
                       CH_ := INKEY;
                       CLEAN_MESSEG_LINE;
                       if CH_<>' '
                        then begin
                               CLEAN_FULL_LINE;
                               exit;
                             end;
                     end
                else Y := Y+1;
             end;
       LIN := LIN+N;
      until LIN>F;
      CLEAN_FULL_LINE;
      if D_ = 'P' then writeln(lst,chr(12));
    end;
  procedure SIT;
    begin
      HOZAAT_REVACHIM;
      if copy(Z_,8,1) = ' '
       then begin
              ADVANCE_LINE;
              CLEAN_FULL_LINE;
              X := 2;
              exit;
            end;
      A_ := '';
      I  := 7;
      repeat
       CH_ := copy(Z_,I,1);
       if (not (CH_ in ['A'..'F','0'..'9'])) and (CH_<>' ')
        then begin
               ERROR(7);
               exit;
             end;
       A_ := A_+CH_;
       I  := I+1;
      until (CH_ = ' ') or (I = 22);
      A_ := copy(A_,1,length(A_)-1);
      C  := length(A_);
      if (int(C/2)<>(C/2)) or (C = 0)
       then begin
              ERROR(7);
              exit;
            end;
      CLEAN_FULL_LINE;
      gotoxy(2,Y); write('S',HEX(LIN),':',A_);
      I := 1;
      repeat
       MRY[LIN] := DEC(16,copy(A_,I,2));
       LIN      := LIN+1;
       I        := I+2;
      until I = C+1;
      ADVANCE_LINE;
      CLEAN_FULL_LINE;
      X := 8;
      gotoxy(2,Y); write('S',HEX(LIN),':');
    end;
  procedure MOV;
    begin
      HOZAAT_REVACHIM;
      A := LIN;
      CHECK_LIN(7,10);
      B := LIN;
      CHECK_LIN(11,14);
      C := LIN;
      LIN := A;
      if B<A
       then begin
              ERROR(1);
              exit;
            end;
      for I := 0 to B-8192 do MRY[I+C] := MRY[I+A];
      ADVANCE_LINE;
      CLEAN_FULL_LINE;
      X := 2;
    end;
  procedure POP_PSW;
    begin
      if A>127
       then begin
              S := 1;
              A := A-128;
            end
       else S := 0;
      if A>63
       then begin
              Z := 1;
              A := A-64;
            end
       else Z := 0;
      A := A-(A div 16)*16;
      if A>4 then A := A-4;
      if A>2
       then begin
              PPP := 1;
              A   := A-2;
            end
       else PPP := 0;
      case A of
       1,2 : CY := 1;
       0   : CY := 0;
      end;
    end;
  procedure BEGS;
    procedure BEG_CHECK;
      begin
        if B_ = 'SP'
         then begin
                SP := B;
                exit;
              end;
        if B_ = 'PC'
         then begin
                LIN := B;
                exit;
              end;
        if B_ = 'CY'
         then begin
                CY := B;
                exit;
              end;
        if B_ = 'PSW'
         then begin
                A  := DEC(16,copy(C_,1,2));
                RA := DEC(16,copy(C_,3,2));
                POP_PSW;
                exit;
              end;
        if B_ = 'BC'
         then begin
                RB := DEC(16,copy(C_,1,2));
                RC := DEC(16,copy(C_,3,2));
                exit;
              end;
        if B_ = 'DE'
         then begin
                RD := DEC(16,copy(C_,1,2));
                RE := DEC(16,copy(C_,3,2));
                exit;
              end;
        if B_ = 'HL'
         then begin
                RH := DEC(16,copy(C_,1,2));
                RL := DEC(16,copy(C_,3,2));
                exit;
              end;
        case B_ of
         'A' : RA       := B;
         'B' : RB       := B;
         'C' : RC       := B;
         'D' : RD       := B;
         'E' : RE       := B;
         'H' : RH       := B;
         'L' : RL       := B;
         'M' : MRY[LIN] := B;
         'S' : S        := B;
         'Z' : Z        := B;
         'P' : PPP      := B;
        end;
      end;
    begin
      HOZAAT_REVACHIM;
      B := pos('=',Z_);
      if B = 0
       then begin
              ERROR(4); 
              exit; 
            end; 
      B_ := copy(Z_,3,B-3);
      C  := pos(' ',Z_);
      C_ := copy(Z_,B+1,C-(B+1));
      B  := DEC(16,C_);
      CLEAN_FULL_LINE;
      gotoxy(2,Y); write('R:',B_,'=',C_);
      FIND := true;
      if pos(B_,ZC_) = 0
       then begin
              ERROR(4);
              exit;
            end;
      if (B_ = 'A') or (B_ = 'B') or (B_ = 'C') or (B_ = 'D') or (B_ = 'E') or (B_ = 'H') or (B_ = 'L') or (B_ = 'M')
       then if not (B in [0..255])
             then FIND := false;
      if (B_ = 'S') or (B_ = 'Z') or (B_ = 'P') or (B_ = 'CY')
       then if not (B in [0..1])
             then FIND := false;
      if (B_ = 'SP') or (B_ = 'PC') or (B_ = 'PSW') or (B_ = 'BC') or (B_ = 'DE') or (B_ = 'HL')
       then if (B in [0..32767])
             then FIND := false;
      if not FIND
       then begin
              ERROR(4);
              exit;
            end;
      BEG_CHECK;
      REGISTERS;
      ADVANCE_LINE;
      SCREEN(2,Y);
      if VIEW_ <> 'R'
       then begin
              CLEAN_FULL_LINE;
              gotoxy(2,Y); write('R:reg=');
            end;
      X := 4;
    end;