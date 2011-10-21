;File Dedug.asm
PROC krDedug
  push  AL
  ldi   AL        ,TASKQUEUESIZE
  cp    r_CNTTASK ,AL
  brcs no_ovf_task
  
    LDW   Z       ,(szErrorTaskOvf)
    rcall fLCDPageZ
    rjmp  pc
 no_ovf_task:
  pop   AL
  ret
szErrorTaskOvf:
;-------------------------+
             ;|01234567| ;|
          .db "  Error " ;|
          .db "Task ovf" ;|
;-------------------------+

ENDP krDedug

PROC krError
  mLCDszZat Line1,Pos0,szError
  rjmp  pc
  ret
szError:
  .db "Error!!",0
ENDP krError
.exit

;S_Alex
