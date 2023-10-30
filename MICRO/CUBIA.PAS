var
  L,K,X,Y,I,J,A,B : integer;
begin
  clrscr;
  X := 1;
  Y := X;
  for B := 1 to 32767 do
   begin
    L := B;
    if B > 20 then begin L := 20;gotoxy(1,1);delline;end;
    for K := 1 to X do begin gotoxy(K,L);write('Í');end;
    for K := 80-Y to 80 do begin gotoxy(K,L);write('Í');end;
{   gotoxy(1,B);write(X);
    gotoxy(77,B);write(Y);
}   I := random(6);
    J := random(6);
    A := I+J;
    if (A/2) = int(A/2)
     then begin
            X := X+1;
            Y := Y-1;
          end
     else begin
            X := X-1;
            Y := Y+1;
          end;
   end;
end.