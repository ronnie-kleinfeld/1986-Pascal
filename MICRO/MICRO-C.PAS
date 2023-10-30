{$I MICRO-A.PAS}
{$I MICRO-B.PAS}
  procedure JUMP;
    begin
      LIN := B*256+A-3;
    end;
  procedure CALL;
    begin
      D_      := ADD_4(HEX(LIN+3));
      MRY[SP] := DEC(16,copy(D_,3,2));
      SP      := SP-1;
      MRY[SP] := DEC(16,copy(D_,1,2));
      SP      := SP-1;
      LIN     := B*256+A-3;
    end;
  procedure RET;
    begin
      LIN := MRY[SP+1]*256+MRY[SP+2]-1;
      SP  := SP+2;
    end;
  procedure CAOF;
    begin
      case OP of
       $0 : exit;
       $1 : begin
              RB := B;
              RC := A;
              exit;
            end;
       $2 : begin
              MRY[RB*256+RC] := RA;
              exit;
            end;
       $3 : begin
              D_ := HEX(RB*256+RC+1);
              RB := DEC(16,(copy(D_,1,2)));
              RC := DEC(16,(copy(D_,3,2)));
              exit;
            end;
       $4 : begin
              RB := FLAGS(RB+1);
              exit;
            end;
       $5 : begin
              RB := FLAGS(RB-1);
              exit;
            end;
       $6 : begin
              RB := A;
              exit;
            end;
       $7 : begin
              X := CY;
              if RA>127
               then CY := 1
               else CY := 0;
              RA := ZIMZOM(2*RA+X);
              exit;
            end;
       $8 : begin
              delay(abs(A*256+B-32767) div 2);
              exit;
            end;
       $9 : begin
              D_ := ADD_2(HEX(RH*256+RL+RB*256+RC));
              RH := DEC(16,copy(D_,1,2));
              RL := DEC(16,copy(D_,3,2));
              RH := CARRY(RH);
              exit;
            end;
       $A : begin
              RA := MRY[RB*256+RC];
              exit;
            end;
       $B : begin
              D_ := HEX(RB*256+RC-1);
              RB := DEC(16,(copy(D_,1,2)));
              RC := DEC(16,(copy(D_,3,2)));
              exit;
            end;
       $C : begin
              RC := FLAGS(RC+1);
              exit;
            end;
       $D : begin
              RC := FLAGS(RC-1);
              exit;
            end;
       $E : begin
              RC := A;
              exit;
            end;
       $F : begin
              X  := RA and 1;
              RA := RA div 2;
              RA := RA+128*CY;
              CY := X;
              exit;
            end;
       $10 : begin
               E := 1;
               exit;
             end;
       $11 : begin
               RD := B;
               RE := A;
               exit;
             end;
       $12 : begin
               MRY[RD*256+RE] := RA;
               exit;
             end;
       $13 : begin
               D_ := HEX(RD*256+RE+1);
               RD := DEC(16,(copy(D_,1,2)));
               RE := DEC(16,(copy(D_,3,2)));
               exit;
             end;
       $14 : begin
               RD := FLAGS(RD+1);
               exit;
             end;
       $15 : begin
               RD := FLAGS(RD-1);
               exit;
             end;
       $16 : begin
               RD := A;
               exit;
             end;
       $17 : begin
               CY := RA and 1;
               if RA>127
                then X := 1
                else X := 0;
               RA := ZIMZOM(2*RA+X);
               exit;
             end;
       $18 : begin
               E := 1;
               exit;
             end;
       $19 : begin
               D_ := ADD_2(HEX(RH*256+RL+RD*256+RE));
               RH := DEC(16,copy(D_,1,2));
               RL := DEC(16,copy(D_,3,2));
               RH := CARRY(RH);
               exit;
             end;
       $1A : begin
               RA := MRY[RD*256+RE];
               exit;
             end;
       $1B : begin
               D_ := HEX(RD*256+RE-1);
               RD := DEC(16,(copy(D_,1,2)));
               RE := DEC(16,(copy(D_,3,2)));
               exit;
             end;
       $1C : begin
               RE := FLAGS(RE+1);
               exit;
             end;
       $1D : begin
               RE := FLAGS(RE-1);
               exit;
             end;
       $1E : begin
               RE := A;
               exit;
             end;
       $1F : begin
               X := RA and 1;
               if RA>127
                then CY := 1
                else CY := 0;
               RA := RA div 2;
               RA := RA+128*X;
               exit;
             end;
       $20 : exit;
       $21 : begin
               RH := B;
               RL := A;
               exit;
             end;
       $22 : begin
               X        := A+B*256;
               MRY[X]   := RL;
               MRY[X+1] := RH;
               exit;
             end;
       $23 : begin
               D_ := HEX(RH*256+RL+1);
               RH := DEC(16,(copy(D_,1,2)));
               RL := DEC(16,(copy(D_,3,2)));
               exit;
             end;
       $24 : begin
               RH := FLAGS(RH+1);
               exit;
             end;
       $25 : begin
               RH := FLAGS(RH-1);
               exit;
             end;
       $26 : begin
               RH := A;
               exit;
             end;
       $27 : exit;
       $28 : begin
               E := 1;
               exit;
             end;
       $29 : begin
               D_ := ADD_2(HEX(2*(RH*256+RL)));
               RH := DEC(16,copy(D_,1,2));
               RL := DEC(16,copy(D_,3,2));
               RH := CARRY(RH);
               exit;
             end;
       $2A : begin
               X  := B*256+A;
               RL := MRY[I];
               RH := MRY[I+1];
               exit;
             end;
       $2B : begin
               D_ := HEX(RH*256+RL-1);
               RH := DEC(16,(copy(D_,1,2)));
               RL := DEC(16,(copy(D_,3,2)));
               exit;
             end;
       $2C : begin
               RL := FLAGS(RL+1);
               exit;
             end;
       $2D : begin
               RL := FLAGS(RL-1);
               exit;
             end;
       $2E : begin
               RL := A;
               exit;
             end;
       $2F : begin
               RA := 255-RA;
               exit;
             end;
       $30 : exit;
       $31 : begin
               SP := B*256+A;
               exit;
             end;
       $32 : begin
               MRY[B*256+A] := RA;
               exit;
             end;
       $33 : begin
               SP := SP+1;
               exit;
             end;
       $34 : begin
               X      := RH*256+RL;
               MRY[X] := FLAGS(MRY[X]+1);
               exit;
             end;
       $35 : begin
               X      := RH*256+RL;
               MRY[X] := FLAGS(MRY[X]-1);
               exit;
             end;
       $36 : begin
               MRY[RH*256+RL] := A;
               exit;
             end;
       $37 : begin
               CY := 1;
               exit;
             end;
       $38 : begin
               E := 1;
               exit;
             end;
       $39 : begin
               D_ := ADD_2(HEX(RH*256+RL+SP));
               RH := DEC(16,copy(D_,1,2));
               RL := DEC(16,copy(D_,3,2));
               RH := CARRY(RH);
               exit;
             end;
       $3A : begin
               RA := MRY[B*256+A];
               exit;
             end;
       $3B : begin
               SP := SP-1;
               exit;
             end;
       $3C : begin
               RA := FLAGS(RA+1);
               exit;
             end;
       $3D : begin
               RA := FLAGS(RA-1);
               exit;
             end;
       $3E : begin
               RA := A;
               exit;
             end;
       $3F : begin
               CY := 1-CY;
               exit;
             end;
       $40 : exit;
       $41 : begin
               RB := RC;
               exit;
             end;
       $42 : begin
               RB := RD;
               exit;
             end;
       $43 : begin
               RB := RE;
               exit;
             end;
       $44 : begin
               RB := RH;
               exit;
             end;
       $45 : begin
               RB := RL;
               exit;
             end;
       $46 : begin
               RB := MRY[RH*256+RL];
               exit;
             end;
       $47 : begin
               RB := RA;
               exit;
             end;
       $48 : begin
               RC := RB;
               exit;
             end;
       $49 : exit;
       $4A : begin
               RC := RD;
               exit;
             end;
       $4B : begin
               RC := RE;
               exit;
             end;
       $4C : begin
               RC := RH;
               exit;
             end;
       $4D : begin
               RC := RL;
               exit;
             end;
       $4E : begin
               RC := MRY[RH*256+RL];
               exit;
             end;
       $4F : begin
               RC := RA;
               exit;
             end;
       $50 : begin
               RD := RB;
               exit;
             end;
       $51 : begin
               RD := RC;
               exit;
             end;
       $52 : exit;
       $53 : begin
               RD := RE;
               exit;
             end;
       $54 : begin
               RD := RH;
               exit;
             end;
       $55 : begin
               RD := RL;
               exit;
             end;
       $56 : begin
               RD := MRY[RH*256+RL];
               exit;
             end;
       $57 : begin
               RD := RA;
               exit;
             end;
       $58 : begin
               RE := RB;
               exit;
             end;
       $59 : begin
               RE := RC;
               exit;
             end;
       $5A : begin
               RE := RD;
               exit;
             end;
       $5B : exit;
       $5C : begin
               RE := RH;
               exit;
             end;
       $5D : begin
               RE := RL;
               exit;
             end;
       $5E : begin
               RE := MRY[RH*256+RL];
               exit;
             end;
       $5F : begin
               RE := RA;
               exit;
             end;
       $60 : begin
               RH := RB;
               exit;
             end;
       $61 : begin
               RH := RC;
               exit;
             end;
       $62 : begin
               RH := RD;
               exit;
             end;
       $63 : begin
               RH := RE;
               exit;
             end;
       $64 : exit;
       $65 : begin
               RH := RL;
               exit;
             end;
       $66 : begin
               RH := MRY[RH*256+RL];
               exit;
             end;
       $67 : begin
               RH := RA;
               exit;
             end;
       $68 : begin
               RL := RB;
               exit;
             end;
       $69 : begin
               RL := RC;
               exit;
             end;
       $6A : begin
               RL := RD;
               exit;
             end;
       $6B : begin
               RL := RE;
               exit;
             end;
       $6C : begin
               RL := RH;
               exit;
             end;
       $6D : exit;
       $6E : begin
               RL := MRY[RH*256+RL];
               exit;
             end;
       $6F : begin
               RL := RA;
               exit;
             end;
       $70 : begin
               MRY[RH*256+RL] := RB;
               exit;
             end;
       $71 : begin
               MRY[RH*256+RL] := RC;
               exit;
             end;
       $72 : begin
               MRY[RH*256+RL] := RD;
               exit;
             end;
       $73 : begin
               MRY[RH*256+RL] := RE;
               exit;
             end;
       $74 : begin
               MRY[RH*256+RL] := RH;
               exit;
             end;
       $75 : begin
               MRY[RH*256+RL] := RL;
               exit;
             end;
       $76 : begin
               ADVANCE_LINE;
               CLEAN_FULL_LINE;
               gotoxy(2,Y); write('Halt at ',HEX(LIN));
               GO := true;
               exit;
             end;
       $77 : begin
               MRY[RH*256+RL] := RA;
               exit;
             end;
       $78 : begin
               RA := RB;
               exit;
             end;
       $79 : begin
               RA := RC;
               exit;
             end;
       $7A : begin
               RA := RD;
               exit;
             end;
       $7B : begin
               RA := RE;
               exit;
             end;
       $7C : begin
               RA := RH;
               exit;
             end;
       $7D : begin
               RA := RL;
               exit;
             end;
       $7E : begin
               RA := MRY[RH*256+RL];
               exit;
             end;
       $7F : exit;
       $80 : begin
               RA := ALL(RA+RB);
               exit;
             end;
       $81 : begin
               RA := ALL(RA+RC);
               exit;
             end;
       $82 : begin
               RA := ALL(RA+RD);
               exit;
             end;
       $83 : begin
               RA := ALL(RA+RE);
               exit;
             end;
       $84 : begin
               RA := ALL(RA+RH);
               exit;
             end;
       $85 : begin
               RA := ALL(RA+RL);
               exit;
             end;
       $86 : begin
               RA := ALL(RA+MRY[RH*256+RL]);
               exit;
             end;
       $87 : begin
               RA := ALL(2*RA);
               exit;
             end;
       $88 : begin
               RA := ALL(RA+RB+CY);
               exit;
             end;
       $89 : begin
               RA := ALL(RA+RC+CY);
               exit;
             end;
       $8A : begin
               RA := ALL(RA+RD+CY);
               exit;
             end;
       $8B : begin
               RA := ALL(RA+RE+CY);
               exit;
             end;
       $8C : begin
               RA := ALL(RA+RH+CY);
               exit;
             end;
       $8D : begin
               RA := ALL(RA+RL+CY);
               exit;
             end;
       $8E : begin
               RA := ALL(MRY[RH*256+RL]+CY);
               exit;
             end;
       $8F : begin
               RA := ALL(2*RA+CY);
               exit;
             end;
       $90 : begin
               RA := ALL(RA-RB);
               exit;
             end;
       $91 : begin
               RA := ALL(RA-RC);
               exit;
             end;
       $92 : begin
               RA := ALL(RA-RD);
               exit;
             end;
       $93 : begin
               RA := ALL(RA-RE);
               exit;
             end;
       $94 : begin
               RA := ALL(RA-RH);
               exit;
             end;
       $95 : begin
               RA := ALL(RA-RL);
               exit;
             end;
       $96 : begin
               RA := ALL(RA-MRY[RH*256+RL]);
               exit;
             end;
       $97 : begin
               RA := ALL(RA-B);
               exit;
             end;
       $98 : begin
               RA := ALL(RA-RB-CY);
               exit;
             end;
       $99 : begin
               RA := ALL(RA-RC-CY);
               exit;
             end;
       $9A : begin
               RA := ALL(RA-RD-CY);
               exit;
             end;
       $9B : begin
               RA := ALL(RA-RE-CY);
               exit;
             end;
       $9C : begin
               RA := ALL(RA-RH-CY);
               exit;
             end;
       $9D : begin
               RA := ALL(RA-RL-CY);
               exit;
             end;
       $9E : begin
               RA := ALL(RA-MRY[RH*256+RL]-CY);
               exit;
             end;
       $9F : begin
               RA := ALL(0-CY);
               exit;
             end;
       $A0 : begin
               RA := ALL(RA and RB);
               exit;
             end;
       $A1 : begin
               RA := ALL(RA and RC);
               exit;
             end;
       $A2 : begin
               RA := ALL(RA and RD);
               exit;
             end;
       $A3 : begin
               RA := ALL(RA and RE);
               exit;
             end;
       $A4 : begin
               RA := ALL(RA and RH);
               exit;
             end;
       $A5 : begin
               RA := ALL(RA and RL);
               exit;
             end;
       $A6 : begin
               RA := ALL(RA and MRY[RH*256+RL]);
               exit;
             end;
       $A7 : begin
               RA := ALL(RA);
               exit;
             end;
       $A8 : begin
               RA := ALL(RA xor RB);
               exit;
             end;
       $A9 : begin
               RA := ALL(RA xor RC);
               exit;
             end;
       $AA : begin
               RA := ALL(RA xor RD);
               exit;
             end;
       $AB : begin
               RA := ALL(RA xor RE);
               exit;
             end;
       $AC : begin
               RA := ALL(RA xor RH);
               exit;
             end;
       $AD : begin
               RA := ALL(RA xor RL);
               exit;
             end;
       $AE : begin
               RA := ALL(RA xor MRY[RH*256+RL]);
               exit;
             end;
       $AF : begin
               RA := ALL(0);
               exit;
             end;
       $B0 : begin
               RA := ALL(RA or RB);
               exit;
             end;
       $B1 : begin
               RA := ALL(RA or RC);
               exit;
             end;
       $B2 : begin
               RA := ALL(RA or RD);
               exit;
             end;
       $B3 : begin
               RA := ALL(RA or RE);
               exit;
             end;
       $B4 : begin
               RA := ALL(RA or RH);
               exit;
             end;
       $B5 : begin
               RA := ALL(RA or RL);
               exit;
             end;
       $B6 : begin
               RA := ALL(RA or MRY[RH*256+RL]);
               exit;
             end;
       $B7 : begin
               RA := ALL(RA);
               exit;
             end;
       $B8 : begin
               X := ALL(RA-RB);
               exit;
             end;
       $B9 : begin
               X := ALL(RA-RC);
               exit;
             end;
       $BA : begin
               X := ALL(RA-RD);
               exit;
             end;
       $BB : begin
               X := ALL(RA-RE);
               exit;
             end;
       $BC : begin
               X := ALL(RA-RH);
               exit;
             end;
       $BD : begin
               X := ALL(RA-RL);
               exit;
             end;
       $BE : begin
               X := ALL(RA-MRY[RH*256+RL]);
               exit;
             end;
       $BF : begin
               X := ALL(0);
               exit;
             end;
       $C0 : begin
               if Z = 0 then RET;
               exit;
             end;
       $C1 : begin
               RB := MRY[SP];
               RC := MRY[SP+1];
               SP := SP+2;
               exit;
             end;
       $C2 : begin
               if Z = 0 then JUMP;
               exit;
             end;
       $C3 : begin
               JUMP;
               exit;
             end;
       $C4 : begin
               if Z = 0 then CALL;
               exit;
             end;
       $C5 : begin
               MRY[SP]   := RC;
               MRY[SP-2] := RB;
               SP        := SP-2;
               exit;
             end;
       $C6 : begin
               RA := ALL(RA+A);
               exit;
             end;
       $C7 : exit;
       $C8 : begin
               if Z = 1 then RET;
               exit;
             end;
       $C9 : begin
               RET;
               exit;
             end;
       $CA : begin
               if Z = 1 then JUMP;
               exit;
             end;
       $CB : begin
               E := 1;
               exit;
             end;
       $CC : begin
               if Z = 1 then CALL;
               exit;
             end;
       $CD : begin
               CALL;
               exit;
             end;
       $CE : begin
               RA := ALL(RA+A+CY);
               exit;
             end;
       $CF : exit;
       $D0 : begin
               if CY = 0 then RET;
               exit;
             end;
       $D1 : begin
               RD := MRY[SP];
               RE := MRY[SP+1];
               SP := SP+2;
               exit;
             end;
       $D2 : begin
               if CY = 0 then JUMP;
               exit;
             end;
       $D3 : begin
               case A of
                0 : begin
                      A_ := ADD_2(HEX(RA));
                      gotoxy(57,15);
                      write(OT_[DEC(16,copy(A_,1,1))],'∫',OT_[DEC(16,copy(A_,2,1))]);
                    end;
                4 : begin
                      if not (IN5 in [1..6]) then exit;
                      X := RA;
                      if X<128
                       then PD_[1] := '-'
                       else begin
                              PD_[1] := ' ';
                              X      := X-128;
                            end;
                      if X<64
                       then PD_[2] := '≥'
                       else begin
                              PD_[2] := ' ';
                              X      := X-64;
                            end;
                      if X<32
                       then PD_[3] := '≥'
                       else begin
                              PD_[3] := ' ';
                              X      := X-32;
                            end;
                      if X<16
                       then PD_[4] := '-'
                       else begin
                              PD_[4] := ' ';
                              X      := X-16;
                            end;
                      if X<8
                       then PD_[5] := '.'
                       else begin
                              PD_[5] := ' ';
                              X      := X-8;
                            end;
                      if X<4
                       then PD_[6] := '-'
                       else begin
                              PD_[6] := ' ';
                              X      := X-4;
                            end;
                      if X<2
                       then PD_[7] := '≥'
                       else begin
                              PD_[7] := ' ';
                              X      := X-2;
                            end;
                      if X<1
                       then PD_[8] := '≥'
                       else PD_[8] := ' ';
                      for I := 1 to 8 do
                       begin
                         gotoxy(XP[IN5,I]-1,SC[I]); write(PD_[I]);
                       end;
                      IN5 := IN5+INK;
                      if IN5>6 then IN5 := 1;
                    end;
                5 : begin
                      X := RA;
                      A := X div 16;
                      B := X-A*16;
                      if A<>8 then exit;
                      if B>7
                       then begin
                              INK := 1;
                              B   := B-8;
                              end
                       else INK := 0;
                      IN5 := B+1;
                      if IN5>6 then IN5 := 6;
                    end;
                255 : begin
                        if RA in [0..31] then exit;
                        gotoxy(55+T,13); write(chr(RA));
                        if T = 20
                         then T := 1
                         else T := T+1;
                      end;
               end;
               exit;
             end;
       $D4 : begin
               if CY = 0 then CALL;
               exit;
             end;
       $D5 : begin
               MRY[SP]   := RE;
               MRY[SP-2] := RD;
               SP        := SP-2;
               exit;
             end;
       $D6 : begin
               RA := ALL(RA-A);
               exit;
             end;
       $D7 : exit;
       $D8 : begin
               if CY = 1 then RET;
               exit;
             end;
       $D9 : begin
               E := 1;
               exit;
             end;
       $DA : begin
               if CY = 1 then JUMP;
               exit;
             end;
       $DB : begin
               case A of
                0   : begin
                        gotoxy(57,17); write('1œ2œ3œ4œ5œ6œ7œ8');
                        gotoxy(57,16); write('‹∫‹∫‹∫‹∫‹∫‹∫‹∫‹');
                        ADVANCE_LINE;
                        LOOP := false;
                        for I := 1 to 8 do OT[I] := 0;
                        gotoxy(2,Y); write('Enter number #00->  ≥',SPD_);
                        repeat
                         CH_ := INKEY;
                         if CH_ in ['B','b','ê']
                          then begin
                                 ADVANCE_LINE;
                                 gotoxy(57,17); write('Õ Õ Õ Õ Õ Õ Õ Õ');
                                 gotoxy(2,Y); write('Break at ',HEX(LIN));
                                 GO := true;
                                 exit;
                               end;
                         case CH_ of
                          #13      : begin
                                       gotoxy(57,17); write('Õ Õ Õ Õ Õ Õ Õ Õ');
                                       LOOP := true;
                                     end;
                          '1'..'8' : begin
                                       I := ord(CH_)-48;
                                       gotoxy(55+I*2,16);
                                       case OT[I] of
                                        0 : begin
                                              write('ﬂ');
                                              OT[I] := 1;
                                            end;
                                        1 : begin
                                              write('‹');
                                              OT[I] := 0;
                                            end;
                                       end;
                                     end;
                         end;
                        RA   := 0;
                        for I := 1 to 8 do RA := RA+CHEZKA(2,I-1)*OT[9-I];
                        gotoxy(20,Y); write(ADD_2(HEX(RA)));
                        until LOOP;
                      end;
                255 : begin
                        ADVANCE_LINE;
                        gotoxy(2,Y); write('Enter key in #FF:   ≥',SPD_);
                        CH_ := INKEY;
                        CH_ := copy(CH_,1,1);
                        A   := ord(CH_);
                        if A in [0..31] then exit;
                        if CH_ in ['B','b','ê']
                         then begin
                                ADVANCE_LINE;
                                gotoxy(2,Y); write('Break at ',HEX(LIN));
                                GO := true;
                                exit;
                              end;
                        RA := A;
                        gotoxy(20,Y);    write(CH_);
                        gotoxy(55+T,13); write(CH_);
                        if T = 20
                         then T := 1
                         else T := T+1;
                      end;
               end;
               exit;
             end;
       $DC : begin
               if CY = 1 then CALL;
               exit;
             end;
       $DD : begin
               E := 1;
               exit;
             end;
       $DE : begin
               RA := ALL(RA-A-CY);
               exit;
             end;
       $DF : exit;
       $E0 : begin
               if PPP = 0 then RET;
              exit;
             end;
       $E1 : begin
               RH := MRY[SP];
               RL := MRY[SP+1];
               SP := SP+2;
               exit;
             end;
       $E2 : begin
               if PPP = 0 then JUMP;
               exit;
             end;
       $E3 : begin
               X         := RH;
               RH        := MRY[SP+1];
               MRY[SP+1] := X;
               X         := RL;
               RL        := MRY[SP];
               MRY[SP]   := X;
               exit;
             end;
       $E4 : begin
               if PPP = 0 then CALL;
               exit;
             end;
       $E5 : begin
               MRY[SP]   := RL;
               MRY[SP-1] := RH;
               SP        := SP-2;
               exit;
             end;
       $E6 : begin
               RA := ALL(RA and A);
               exit;
             end;
       $E7 : exit;
       $E8 : begin
               if PPP = 1 then RET;
               exit;
             end;
       $E9 : begin
               LIN := RH*256+RL;
               exit;
             end;
       $EA : begin
               if PPP = 1 then JUMP;
               exit;
             end;
       $EB : begin
               X  := RH;
               RH := RD;
               RD := X;
               X  := RL;
               RL := RE;
               RE := X;
               exit;
             end;
       $EC : begin
               if PPP = 1 then CALL;
               exit;
             end;
       $ED : begin
               E := 1;
               exit;
             end;
       $EE : begin
               RA := ALL(RA xor A);
               exit;
             end;
       $EF : exit;
       $F0 : begin
               if S = 0 then RET;
               exit;
             end;
       $F1 : begin
               RA := MRY[SP];
               A  := MRY[SP+1];
               SP := SP+2;
               POP_PSW;
               exit;
             end;
       $F2 : begin
               if S = 0 then JUMP;
               exit;
             end;
       $F3 : exit;
       $F4 : begin
               if S = 0 then CALL;
               exit;
             end;
       $F5 : begin
               MRY[SP]   := RA;
               MRY[SP-1] := DEC(2,HEX(S)+HEX(Z)+'000'+HEX(PPP)+'0'+HEX(CY));
               SP        := SP-2;
               exit;
             end;
       $F6 : begin
               RA := ALL(RA or A);
               exit;
             end;
       $F7 : exit;
       $F8 : begin
               if S = 1 then RET;
               exit;
             end;
       $F9 : begin
               SP := RH*256+RL;
               exit;
             end;
       $FA : begin
               if S = 1 then JUMP;
               exit;
             end;
       $FB : exit;
       $FC : begin
               if S = 1 then CALL;
               exit;
             end;
       $FD : begin
               E := 1;
               exit;
             end;
       $FE : begin
               X := ALL(RA-A);
               exit;
             end;
       $FF : exit;
       $100 : begin
                ADVANCE_LINE;
                CLEAN_FULL_LINE;
                gotoxy(2,Y); write('Break at ',HEX(LIN));
              end;
      end;
    end;
  procedure RUN;
    begin
      GO := false;
      repeat
       OP := MRY[LIN];
       E  := LEN[OP];
       A  := MRY[LIN+1];
       B  := MRY[LIN+2];
       if keypressed
        then begin
               CH_ := INKEY;
               case CH_ of
                ' '         : begin
                                PRESS_ANY_KEY;
                                CH_ := INKEY;
                                CLEAN_MESSEG_LINE;
                              end;
                'B','b','ê' : begin
                                ADVANCE_LINE;
                                CLEAN_FULL_LINE;
                                gotoxy(2,Y); write('Break at ',HEX(LIN));
                                ADVANCE_LINE;
                                CLEAN_FULL_LINE;
                                X := 2;
                                REGISTERS;
                                BEEP;
                                exit;
                              end;
               end;
             end;
       if C_ = 'T'
        then begin
               REGISTERS;
               PRESS_ANY_KEY;
               CH_ := INKEY;
               if CH_ in ['B','b','ê']
                then begin
                       CLEAN_MESSEG_LINE;
                       ADVANCE_LINE;
                       CLEAN_FULL_LINE;
                       gotoxy(2,Y); write('Break at ',HEX(LIN));
                       ADVANCE_LINE;
                       CLEAN_FULL_LINE;
                       X := 2;
                       REGISTERS;
                       BEEP;
                       exit;
                     end;
               CLEAN_MESSEG_LINE;
             end;
       CAOF;
       LIN := LIN+E;
      until GO;
      ADVANCE_LINE;
      CLEAN_FULL_LINE;
      X := 2;
      REGISTERS;
      BEEP;
    end;
  procedure ENTER;
    begin
      INS := false;
      COLORS;
      NORMAL_COLOR;
      Z_ := '∫';
      for I := 2 to 21 do
       begin
         SCREEN(I,Y);
         Z_ := Z_+VIEW_;
       end;
      Z_ := Z_+'≥';
      CLEAN_MESSEG_LINE;
      C_ := copy(Z_,2,1);
      B  := pos(C_,CD_);
      if B = 0
       then begin
              ERROR(6);
              exit;
            end;
      case C_ of
       ' ' : begin
               ADVANCE_LINE;
               CLEAN_FULL_LINE;
               X := 2;
               exit;
             end;
       'C' : begin
               window(2,5,21,22);  clrscr;
               window(23,5,42,22); clrscr;
               window(1,1,80,25);
               X := 2; Y := 5;
             end;
       'R' : BEGS;
       else begin
              X := 8;
              CHECK_LIN(3,6);
              case C_ of
               'A'         : APPEND;
               'O'         : OPCODE;
               'L','K','P' : LIST;
               'S'         : SIT;
               'M'         : MOV;
               'G','T'     : RUN;
              end;
            end;
      end;
    end;
  procedure EDITOR;
    begin
      SCREEN(X,Y);
      COLORS;
      gotoxy(X,Y); write(VIEW_);
      NORMAL_COLOR;
      CH_ := INKEY;
      if not ((CH_ = #27) and INKEYP)
       then begin
              gotoxy(X,Y); write(VIEW_);
              CH_ := upcase(CH_);
              if CH_ in ['A'..'Z','0'..'9',' ','=','-','*',',','#',':']
               then begin
                      if INS then begin
                                    gotoxy(X,Y); write(VIEW_);
                                    for I := 20 downto X do
                                     begin
                                       SCREEN(I,Y);
                                       gotoxy(I+1,Y); write(VIEW_);
                                     end;
                                    gotoxy(X,Y); write(CH_);
                                    X := X+1;
                                    exit;
                                  end
                             else begin
                                    gotoxy(X,Y); write(CH_);
                                    X := X+1;
                                    exit;
                                  end;
                    end
               else begin
                      case CH_ of
                       #08 : begin
                             case X of
                              2     : exit;
                              3..21 : begin
                                        for I := X to 21 do
                                         begin
                                           SCREEN(I,Y); gotoxy(I-1,Y);
                                           write(VIEW_);
                                         end;
                                        X := X-1;
                                        gotoxy(21,Y); write(' ');
                                        exit;
                                      end;
                             end;
                           end;
                       #09 : begin
                               gotoxy(X,Y); write(VIEW_);
                               X := TAB[X-1];
                               exit;
                             end;
                       #15 : begin
                               gotoxy(X,Y); write(VIEW_);
                               X := BTAB[X-1];
                               exit;
                             end;
                       #13 : ENTER;
                       #27 : begin
                             CLEAN_FULL_LINE;
                             X := 2;
                           end;
                      end;
                    end;
              exit;
            end
       else begin
              CH_ := INKEY;
              gotoxy(X,Y); write(VIEW_);
              case CH_ of
               #75 : begin
                       X := X-1;
                       if X<2 then X := 2;
                       exit;
                     end;
               #77 : begin
                       X := X+1;
                       if X>21 then X := 21;
                       exit;
                     end;
               #72 : begin
                       Y := Y-1;
                       if Y<5 then Y := 5;
                       exit;
                     end;
               #80 : begin
                       Y := Y+1;
                       if Y>22 then Y := 22;
                       exit;
                     end;
               #82 : begin
                       INS := not(INS);
                       exit;
                     end;
               #83 : begin
                       for I := X+1 to 21 do
                        begin
                          SCREEN(I,Y);
                          gotoxy(I-1,Y); write(VIEW_);
                        end;
                       gotoxy(21,Y); write(' ');
                       exit;
                     end;
               #79 : begin
                       I := 22;
                       repeat
                        I := I-1;
                        SCREEN(I,Y);
                       until (I = 1) or (VIEW_<>#32);
                       X := I+1;
                       exit;
                     end;
               #117 : begin
                        window(2,5,21,22);
                        gotoxy(X-1,Y-4); clreol;
                        window(1,1,80,25);
                        exit;
                      end;
               #119 : begin
                        X := 2;
                        Y := 5;
                        exit;
                      end;
               #73 : Y := 5;
               #81 : Y := 22;
               #71 : X := 2;
               #65 : PROGRAM_END := true;
               #63 : OPERATE;
               #67 : INUT;
               #61 : ERL;
               #59 : COMMAND;
              end;
            end;
    end;
begin
  T   := 1;
  BP  := 1;
  INK := 1;
  IN5 := 1;
  X   := 2;
  Y   := 5;
  IPUS;
  INKEYP := false;INS := false;PROGRAM_END := false;
  MAIN_SCREEN;
  repeat
   CURSOR(false);
   gotoxy(8,3);  write('  ');
   gotoxy(8,3);  write(Y-4 : 2);
   gotoxy(20,3); write(' ');
   gotoxy(20,3); write(X-1 : 2);
   EDITOR;
   case X of
    -32767..1 : X := 2;
    3         : INPUT_POINTS;
    22..32767 : X := 21;
   end;
  until PROGRAM_END;
  CURSOR(true);
  clrscr;
end.