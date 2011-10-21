;File IntRoutines.asm
;
;###############################################################################
;######################### Interrupt routines ##################################
;###############################################################################
;
;###############################################################################
.cseg

INT_0:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_1:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_2:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
PROC INT_3 ;Calc LS

  in    TmpSREG,  SREG
  ;Place your code here
  push  AL
  push  AH
  push  BL
  push  BH
  push  CL
  push  CH

  mIn   AL        ,TCNT3L
  lds   AH        ,(v_LSOldL)
  sts   (v_LSOldL),AL
  sub   AL        ,AH
  sts   (v_LSCurL),AL

  mIn   AL        ,TCNT3H
  lds   AH        ,(v_LSOldH)
  sts   (v_LSOldH),AL
  sbc   AL        ,AH
  sts   (v_LSCurH),AL


  ;< LS SET_SENSOR_FLGAG
;  mFlgClr flg_Lamp    ; Источник света

  lds   AL  ,(v_LSMidL)
  lds   AH  ,(v_LSMidH)
  lsr   AH
  ror   AL  ;AL/2   ±50%
  lsr   AH
  ror   AL  ;AL/4   ±25%
  lsr   AH
  ror   AL  ;AL/8   ±12.5%
  lsr   AH
  ror   AL  ;AL/16  ±6.25%
  lsr   AH
  ror   AL  ;AL/32  ±3.125%

  lds   BL  ,(v_LSMidL)
  lds   BH  ,(v_LSMidH)
  add   BL  ,AL
  adc   BH  ,AH

  lds   CL  ,(v_LSMidL)     ;        |
  lds   CH  ,(v_LSMidH)     ;        |
  sub   CL  ,AL             ;        |
  sbc   CH  ,AH             ;        |


  lds   AL  ,(v_LSCurL)
  lds   AH  ,(v_LSCurH)
  cp    AL  ,BL
  cpc   AH  ,BH
  brsh (pc+1)+1+1+1+1+1+2 ;----------->+
    cp    AL  ,CL             ;        |
    cpc   AH  ,CH             ;        |
    brlo (pc+1)+1+1+2         ;------->+
      mFlgSet flg_Lamp        ;        |
      ldi AL  ,0x80           ;        |
      sts (v_InfoBuf1+5),AL   ;        |Источник света
  ;                       ;-<----------+
  ;> LS SET_SENSOR_FLGAG

  ;
  pop   CH
  pop   CL
  pop   BH
  pop   BL
  pop   AH
  pop   AL
  out   SREG,   TmpSREG
  reti

ENDP INT_3
;---
INT_4:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
PROC INT_5
  in    TmpSREG,  SREG
  ;Place your code here

  ;< F-Bamper
  mPinState TSOPF
  mFlgLd    flg_BampF
  mFlgCpl   flg_BampF
  ;> F-Bamper

  push  AL
  ldi   AL, '^'
  mFlgSkipSet flg_BampF   ; Препятствие спереди
    ldi   AL, '_'
  sts   v_InfoBuf1+4,  AL ; Препятствие спереди
  sts   v_InfoBuf1+3,  AL ; Препятствие спереди
  pop   AL


  mPinCpl LedRed

  call fIRShiftBuff

  out   SREG,   TmpSREG
  reti

ENDP INT_5
;---
PROC INT_6
  in    TmpSREG,  SREG
  ;Place your code here
  ;< R-Bamper
  mPinState TSOPR
  mFlgLd    flg_BampR
  mFlgCpl   flg_BampR
  ;> R-Bamper

; rcall krRand

  out   SREG,   TmpSREG
  reti

ENDP INT_6
;---
INT_7:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_OC2:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_OVF2:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_ICP1:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_OC1A:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_OC1B:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_OVF1:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_OC0:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_OVF0:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_SPI:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_URXC0:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_UDRE0:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_UTXC0:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_ADCC:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_ERDY:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_ACI:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_OC1C:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
PROC INT_ICP3 ; Interrupt from FM sensor
  in    TmpSREG,  SREG
  ;Place your code here
  push  AL
  push  AH
  push  BL
  push  BH
  push  CL
  push  CH

  ;< Calculate current value for FM sensor
  mIn   AL        ,ICR3L
  lds   AH        ,(v_FMOldL)
  sts   (v_FMOldL),AL
  sub   AL        ,AH
  sts   (v_FMCurL),AL

  mIn   AL        ,ICR3H
  lds   AH        ,(v_FMOldH)
  sts   (v_FMOldH),AL
  sbc   AL        ,AH
  sts   (v_FMCurH),AL
  ;> Calculate current value for FM sensor

  ;< FM SET_SENSOR_FLGAG
;  mFlgClr flg_Monet   ; Монетка

  ;lds    AL  ,(v_FMMidL)
  ;lds    AH  ,(v_FMMidH)
  lds   AL  ,(v_FMMidH)
  sbr   AL  ,0x01
  ldi   AH  ,0x00   ; AH:AL = (v_FMMid / 256) or 1

  lds   BL  ,(v_FMMidL)
  lds   BH  ,(v_FMMidH)
  add   BL  ,AL
  adc   BH  ,AH
  ;Hi = v_FMMid + v_FMMid / 256

  lds   CL  ,(v_FMMidL)
  lds   CH  ,(v_FMMidH)
  sub   CL  ,AL
  sbc   CH  ,AH
  ;Lo = v_FMMid - v_FMMid / 256


  lds   AL  ,(v_FMCurL)
  lds   AH  ,(v_FMCurH)
  cp    AL  ,BL
  cpc   AH  ,BH
  brsh (pc+1)+1+1+1+1+1+2     ;------->+
    cp    AL  ,CL               ;        |
    cpc   AH  ,CH               ;        |
    brlo (pc+1)+1+1+2           ;------->+
      mFlgSet flg_Monet         ;        |
        ldi   AL, '$'           ;        |
        sts   (v_InfoBuf1+2),AL ;Монетка |
        
  ;                             ; <------+
  ;> FM SET_SENSOR_FLGAG

  pop   CH
  pop   CL
  pop   BH
  pop   BL
  pop   AH
  pop   AL
  out   SREG,   TmpSREG
  reti

ENDP INT_ICP3
;---
INT_OC3A:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_OC3B:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
PROC INT_OC3C ;"Buzer"

  in    TmpSREG   ,SREG
  ;Place your code here
  mPinCpl pBuzer  ; Инверсия состояния для вывода "Buzer"

  push  AL
  push  AH
  mIn   AL    ,OCR3CL
  lds   AH    ,v_DivNote+0
  add   AL    ,AH

  push  AL
  mIn   AL    ,OCR3CH
  lds   AH    ,v_DivNote+1
  adc   AH    ,AL
  pop   AL

  mOut OCR3CH ,AH
  mOut OCR3CL ,AL

  pop   AH
  pop   AL
  out   SREG  ,TmpSREG
  reti

ENDP INT_OC3C
;---
INT_OVF3:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_URXC1:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_UDRE1:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_UTXC1:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_TWI:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---
INT_SPMR:
;  in    TmpSREG ,SREG
;  ;Place your code here
;  out   SREG    ,TmpSREG
  reti
;---



;;###############################################################################
PROC  f_IntOVF1
    ;Timer0 Overflow Handler
  in    TmpSREG ,SREG
  push    AL
  push    AH
  mPUSHw  Z
  ;Place your code here
  ;< Set Servo into new position
  LDW   Z       ,(ct_Servo4Scan)
  mov   AL      ,rvIndxServo
  andi  AL      ,0x0F
  add   ZL      ,AL
  adc   ZH      ,ZERO
  lsl   ZL
  rol   ZH
  lpm   AL      ,z+
  lpm   AH      ,z+
  mOut  OCR1AH  ,AH
  mOut  OCR1AL  ,AL
  ;> Set Servo into new position
  ;
  mPOPw   Z
  pop     AH
  pop     AL
  out   SREG    ,TmpSREG
  reti

ENDP f_IntOVF1
;;###############################################################################
;;###############################################################################


;;###############################################################################

;###############################################################################
;S_Alex

