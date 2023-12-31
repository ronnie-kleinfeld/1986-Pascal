-E3
B Y    R A A N A N    K L E I N F E L D  -  C O M M A N D S    F O R	8 0 8 5
- F
 |---------------------------------------------|----------------------------------|-----------------------------------------------|
 |   Move group 			       | Direct group			  |Jump group	   PC=addr			  |
 |	     A	B  C  D  E  H  L  M	       |				  |   JMP addr	   C3				  |
 |    MOV A 7F 78 79 7A 7B 7C 7D 7E  A=r       |    MVI A,$$	 3E  A=$$	  |   JNZ addr	   C2  Z =0  -	  ��� ��	  |
 |    MOV B 47 40 41 42 43 44 45 46  B=r       |    MVI B,$$	 06  B=$$	  |   JZ  addr	   CA  Z =1  -	     ���	  |
 |    MOV C 4F 48 49 4A 4B 4C 4D 4E  C=r       |    MVI C,$$	 0E  C=$$	  |   JNC addr	   D2  CY=0  -	  ��� ��	  |
 |    MOV D 57 50 51 52 53 54 55 56  D=r       |    MVI D,$$	 16  D=$$	  |   JC  addr	   DA  CY=1  -	     ���	  |
 |    MOV E 5F 58 59 5A 5B 5C 5D 5E  E=r       |    MVI E,$$	 1E  E=$$	  |   JPO addr	   E2  P =0  -	 ���� ��	  |
 |    MOV H 67 60 61 62 63 64 65 66  H=r       |    MVI H,$$	 26  H=$$	  |   JPE addr	   EA  P =1  -	    ����	  |
 |    MOV L 6F 68 69 6A 6B 6C 6D 6E  L=r       |    MVI L,$$	 3E  L=$$	  |   JP  addr	   F2  S =0  -	   �����	  |
 |    MOV M 77 70 71 72 73 74 75     M=r       |    MVI M,$$	 36  M=$$	  |   JM  addr	   FA  S =1  -	����� ��	  |
 |  * ADD   87 80 81 82 83 84 85 86  A=A+r     |  * ADI $$	 C6  A=A+$$	  |-----------------------------------------------|
 |  * ADC   8F 88 89 8A 8B 8C 8D 8E  A=A+r+CY  |  * ACI $$	 CE  A=A+$$+CY	  |Call group	   (SP-1,SP)=PC , SP=SP-2 ,PC=addr|
 |  * SUB   97 90 91 92 93 94 95 96  A=A-r     |  * SUI $$	 D6  A=A-$$	  |   CALL addr    CD				  |
 |  * SBB   9F 98 99 9A 9B 9C 9D 9E  A=A-r-CY  |  * SBI $$	 DE  A=A-$$-CY	  |   CNZ  addr    C4  Z =0  -	  ��� ��	  |
 |  * ANA   A7 A0 A1 A2 A3 A4 A5 A6  A=A and r |  * ANI $$	 E6  A=A and $$   |   CZ   addr    CC  Z =1  -	     ���	  |
 |  * XRA   AF A8 A9 AA AB AC AD AE  A=A xor r |  * XRI $$	 EE  A=A xor $$   |   CNC  addr    D4  CY=0  -	  ��� ��	  |
 |  * ORA   B7 B0 B1 B2 B3 B4 B5 B6  A=A or r  |  * ORI $$	 F6  A=A or $$	  |   CC   addr    DC  CY=1  -	     ���	  |
 |  * CMP   BF B8 B9 BA BB BC BD BE  A-r       |  * CPI $$	 FE  A-$$	  |   CPO  addr    E4  P =0  -	 ���� ��	  |
 |					       |    LXI B,$$$$	 01  BC=$$$$	  |   CPE  addr    EC  P =1  -	    ����	  |
 |*** INR   3C 04 0C 14 1C 24 2C 34  r=r+1     |    LXI D,$$$$	 11  DE=$$$$	  |   CP   addr    F4  S =0  -	   �����	  |
 |*** DCR   3D 05 0D 15 1D 25 2D 35  r=r-1     |    LXI H,$$$$	 21  HL=$$$$	  |   CM   addr    FC  S =1  -	����� ��	  |
 |					       |    LXI SP,$$$$  31  SP=$$$$	  |-----------------------------------------------|
 |---------------------------------------------|----------------------------------|Return group    PC=(SP,SP-1) , SP=SP+2	  |
 | Indirect group			       | Special group			  |   RET	   C9				  |
 |    LDA addr	   3A  A=(addr) 	       |  * DAA 	 27  A=B.C.D	  |   RNZ	   C0  Z =0  -	  ��� ��	  |
 |    STA addr	   32  (addr)=A 	       | ** RLC 	 07  --------	  |   RZ	   C8  Z =1  -	     ���	  |
 |    LDAX B	   0A  A=(B,C)		       | ** RRC 	 0F  - Down -	  |   RNC	   D0  CY=0  -	  ��� ��	  |
 |    LDAX D	   1A  A=(D,E)		       | ** RAL 	 17  --------	  |   RC	   D8  CY=1  -	     ���	  |
 |    STAX B	   02  (B,C)=A		       | ** RAR 	 1F  --------	  |   RPO	   E0  P =0  -	 ���� ��	  |
 |    STAX D	   12  (D,E)=A		       |    CMA 	 2F  A=not A	  |   RPE	   E8  P =1  -	    ����	  |
 |    LHLD addr    2A  L=(addr)  H=(addr+1)    | ** CMC 	 3F  CY=not CY	  |   RP	   F0  S =0  -	   �����	  |
 |    SHLD addr    22  (addr)=L  (addr+1)=H    | ** STC 	 37  CY=1	  |   RM	   F8  S =1  -	����� ��	  |
 |    XCHG	   EB  H��D  L��E	       |    PCHL	 E9  PC=HL	  |-----------------------------------------------|
 |---------------------------------------------|    XTHL	 E3  L��SP H��SP+1|Reset group (SP-1,SP-2)=PC , SP=SP-2 , PC=addr |
 | Double register group		       |    SPHL	 F9  SP=HL	  |		       ���� ������ �����	  |
 |	    B  D  H SP PSW		       |    IN	#$$	 DB  A=#$$	  |   RST 0	   C7	     0000		  |
 |    INX  03 13 23 33	    rp=rp+1	       |    OUT #$$	 D3  #$$=A	  |   RST 1	   CF	     0008		  |
 |    DCX  0B 1B 2B 3B	    rp=rp-1	       |    DI		 F3  Disable	  |   RST 2	   D7	     0010		  |
 | ** DAD  09 19 29 39	    M=M+rp	       |    EI		 FB  Enable	  |   RST 3	   DF	     0018		  |
 |    PUSH C5 D5 E5    F5   (SP-1,SP-2)=rp,SP-2|    HLT 	 76  Halt	  |   RST 4	   E7	     0020		  |
 |    POP  C1 D1 E1    F1   rp=(SP,SP+1)  ,SP+2|    SIM 	 30  Set mask	  |   RST 5	   EF	     0028		  |
 |---------------------------------------------|    RIM 	 20  Read mask	  |   RST 6	   F7	     0030		  |
 |	    All flag change	 -   *	       |    NOP 	 00  No operation |   RST 7	   FF	     0038		  |
 |	    Carry change only	 -  **	       |----------------------------------|-----------------------------------------------|
 |	    All but carry change - ***	       |										  |
 |------------------------------|--------------------------------|------------------------------|---------------------------------|
 |	      ����������������Ŀ|     �������������������������Ŀ|     ����������������Ŀ	|     �������������������������Ŀ |
 |RAL  ��Ŀ  �^�������������Ŀ �|RLC  � ��Ŀ  ���������������Ŀ �|RAR  � ���������������^�  ��Ŀ|RRC  � ���������������Ŀ  ��Ŀ � |
 |     �CY�<ͳ7�6�5�4�3�2�1�0�<�|     �<�CY�<ͳ7�6�5�4�3�2�1�0�<�|     �>�7�6�5�4�3�2�1�0��>�CY�|     �>�7�6�5�4�3�2�1�0��>�CY�>� |
 |17   ����  �����������������	|07	����  �����������������  |1F	 �����������������  ����|0F	�����������������  ����   |
 |	      <- <- <- <- <-	|	       <- <- <- <- <-	 |	   -> -> -> -> ->	|	  -> -> -> -> ->	  |
 |------------------------------|--------------------------------|------------------------------|---------------------------------|
