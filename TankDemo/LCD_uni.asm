;HD44780-based Character-LCD
;W_LCD  equ 40
;Updated: "2010-09-02" "20:13"
;Updated: "2011-03-14" "20:01"

#ifndef MACROEX_INC
  #include "MacroEX.asm"
#endif
.list
.listmac

;< in process
;PROC fLCD_Shuffle
;;  .equ  LCD_D0 = 0
;;  .equ  LCD_D1 = 1
;;  .equ  LCD_D2 = 2
;;  .equ  LCD_D3 = 3
;;  .equ  LCD_D4 = 4
;;  .equ  LCD_D5 = 5
;;  .equ  LCD_D6 = 6
;;  .equ  LCD_D7 = 7
;#define rCnt r17
;#define rTmp r18
;#define rTemp r19
;
; push  rCnt
; push  rTmp
; push  rTemp
;
; clr   rTemp
;   LDW   Z,  (Shuffle<<1)
; ldi   rCnt, 8
; L_fLCD_Shuffle:
;   clr   rTmp
;     lpm   rTmp, z+
;     sbrc  AL,   bit0
;     add   rTemp, rTmp
;     ror   AL
;   dec   rCnt
; brne L_fLCD_Shuffle
; mov   AL, rTemp
;
; pop   rTemp
; pop   rTmp
; pop   rCnt
;
; ret
;#undef rCnt
;#undef rTmp
;#undef rTemp
;Shuffle:
; .db (1<<LCD_D0),(1<<LCD_D1),(1<<LCD_D2),(1<<LCD_D3),(1<<LCD_D4),(1<<LCD_D5),(1<<LCD_D6),(1<<LCD_D7)
;ENDP fLCD_Shuffle
;> in process

PROC fLCD_WR8
  out   P_LCD,  AL
  rcall fLCD_Strob
  ret
ENDP fLCD_WR8


PROC fLCD_WR4
  push  AH
    .if (LCDMODE == LCDLOW)
      push  AL
      in    AH, P_LCD
      cbr   AH, LCDMODE
      ;< 4-7 bits
      swap  AL
      andi  AL, LCDMODE
      or    AL, AH
      out   P_LCD,  AL
      rcall fLCD_Strob
      ;> 4-7 bits
      pop   AL
      ;< 0-3 bits
      andi  AL, LCDMODE
      or    AL, AH
      out   P_LCD,  AL
      rcall fLCD_Strob
      ;> 0-3 bits
      rcall fLCDWait
    .elif (LCDMODE == LCDHI)
      push  AL
      in    AH, P_LCD
      cbr   AH, LCDMODE
      ;< 4-7 bits
      swap  AL
      andi  AL, LCDMODE
      or    AL, AH
      out   P_LCD,  AL
      rcall fLCD_Strob
      ;> 4-7 bits
      pop   AL
      ;< 0-3 bits
      andi  AL, LCDMODE
      or    AL, AH
      out   P_LCD,  AL
      rcall fLCD_Strob
      ;> 0-3 bits
      rcall fLCDWait
    .else
      .error  ""
      .message "+-----------------------+"
      .message "| LCD: 4-bit interface  |"
      .message "| Support only          |"
      .message "| LCDMODE: LCDLOW/LCDHI |"
      .message "+-----------------------+"
    .endif

  pop   AH
  ret
ENDP fLCD_WR4
;################################## FUNCTION ###################################
;Name of function:
 ; fLCD_WR3
;Input:
 ; AL - byte
;Return:
 ; -
;Description:
 ; Write byte to LCD
;
;< ################################# R-chart ###################################
;
; +---------->+---------->+---------------------->+(ret)->
;                         !                       !
;                         !---------------------->!
;
;> ################################# R-chart ###################################
.if LCDTYPE == 3
  PROC fLCD_WR3
    push  AH
    ldi   AH,8           ;bit counter
   L_fLCD_WR3:
      mPinCLR LCDDat    ;set LCD Data bit to 0
      sbrc  AL,7        ;if zero, clock it out
      mPinSET LCDDat    ;if 1, set LCD Data bit to 1
      rol   AL          ;shift bits in AL
      mPinSET LCDClk    ;bit clocks on rising edge
      mPinCLR LCDClk    ;bring clock back to 0
      dec   AH          ;shift out 8 bits
    brne L_fLCD_WR3
    pop     AH
    ret
  ENDP fLCD_WR3
.endif

PROC fLCD_Strob
  mPinCLR LCDE
  nop
  mPinSET LCDE
  nop
  mPinCLR LCDE
  ret
ENDP fLCD_Strob

PROC fLCDInit
  ;< Init LCD PORTs
  mPinCLR LCDE
  mPinCLR LCDRS
  mPinOut LCDE
  mPinOut LCDRS
  .ifdef LCDRW
    mPinCLR LCDRW
    mPinOut LCDRW
  .endif
  ;> Init LCD PORTs

  .if LCDTYPE == 3
    ;< Set 3 wire 8-bit interface
    mPinCLR LCDClk
    mPinOut LCDClk
    ldi   AL, FunctionSet|Interface8bit|DisplayLine2|Font5_10Dot
    mLCD_WR LCD_CMD
    ;> Set 3 wire 8-bit interface

  .elif LCDTYPE == 4
    ;< Set 4 bit interface
    .if (LCDMODE == LCDLOW) ||(LCDMODE == LCDHI)
      in    AL,     P_LCD-1
      ori   AL,     LCDMODE
      out   P_LCD-1,AL
    .else
      .error  ""
      .message "+-----------------------+"
      .message "| LCD: 4-bit interface  |"
      .message "| Support only          |"
      .message "| LCDMODE: LCDLOW/LCDHI |"
      .message "+-----------------------+"
    .endif


    ldi AL, FunctionSet|Interface8bit
    .if (LCDMODE == LCDLOW)
      swap  AL
    .elif (LCDMODE == LCDHI)
      ;
    .else
      .error  ""
      .message "+-----------------------+"
      .message "| LCD: 4-bit interface  |"
      .message "| Support only          |"
      .message "| LCDMODE: LCDLOW/LCDHI |"
      .message "+-----------------------+"
    .endif
    in    AH, P_LCD
    cbr   AH, LCDMODE
    andi  AL, LCDMODE
    or    AL, AH
    out   P_LCD,  AL

    rcall fLCD_Strob
    mDelay_Us 5000;4100
    rcall fLCD_Strob
    mDelay_Us 200;100
    rcall fLCD_Strob
    rcall fLCDWait

    ldi AL, FunctionSet|Interface4bit
    .if (LCDMODE == LCDLOW)
      swap  AL
    .elif (LCDMODE == LCDHI)
      ;
    .else
      .error  ""
      .message "+-----------------------+"
      .message "| LCD: 4-bit interface  |"
      .message "| Support only          |"
      .message "| LCDMODE: LCDLOW/LCDHI |"
      .message "+-----------------------+"
    .endif
    in    AH, P_LCD
    cbr   AH, LCDMODE
    andi  AL, LCDMODE
    or    AL, AH
    out   P_LCD,  AL

    rcall fLCD_Strob
    rcall fLCDWait
    ldi   AL, FunctionSet|Interface4bit|DisplayLine2|Font5_10Dot
    mLCD_WR LCD_CMD
    ;> Set 4 bit interface

  .elif LCDTYPE == 8
    ;< Set 8 bit interface
    ldi   AL, $FF
    out   P_LCD-1,  AL
    ldi AL, FunctionSet|Interface8bit
    out   P_LCD,  AL
    rcall fLCD_Strob
    mDelay_Us 4100
    rcall fLCD_Strob
    mDelay_Us 100
    rcall fLCD_Strob
    rcall fLCDWait
    ldi   AL, FunctionSet|Interface8bit|DisplayLine2|Font5_10Dot
    mLCD_WR LCD_CMD
    ;> Set 8 bit interface
  .endif



  ldi   AL, DispControl|DisplayON|CursorON|CursorNoFlash
  sts   (v_LCDCtrl),  AL
  mLCD_WR LCD_CMD
  ldi   AL, EntryMode|IncCurPos|NoDispShift
  mLCD_WR LCD_CMD
  ldi   AL, ClearDisplay
  mLCD_WR LCD_CMD
  mDelay_Us 2000

  ldi   AL,   SetDDRAM|Line1|Pos0
  sts   (v_LCDPos), AL

  ret
ENDP fLCDInit

;##########################################################
PROC  fLCD_Char
  sbrc  AL,7
    rcall fLCDReCode
  mLCD_WR LCD_DATA
  rcall fLCDWait
  ret
ENDP fLCD_Char
;##########################################################
PROC fLCDReCode
  mPUSHw Z
  andi  AL, $7F
  LDW   Z,    (ReCode_ANSI<<1)
  add   ZL,   AL
  adc   ZH,   ZERO
  lpm   AL, z
  mPOPw Z
  ret
ENDP fLCDReCode


;##########################################################
PROC fLCDszY
    ld    AL, y+
    rcall fLCD_Char   ;,Data
    ld    AL, y
    tst   AL
  brne  fLCDszY
  ret
ENDP fLCDszY

PROC fLCDszZ
    lpm   AL, z+
    rcall fLCD_Char   ;,Data
    lpm   AL, z
    tst   AL
  brne  fLCDszZ
  ret
ENDP fLCDszZ

;##########################################################
; AH - длина строки
PROC fLCDsZ
    lpm   AL, z+
    rcall fLCD_Char   ;,Data
    dec   AH
  brne  fLCDsZ
  ret
ENDP fLCDsZ

; AH - длина строки
PROC fLCDsY
    ld    AL, y+
    rcall fLCD_Char   ;,Data
    dec   AH
  brne  fLCDsY
  ret
ENDP fLCDsY


PROC fLCDWait
  mDelay_Us DelayLCD1
  ret
ENDP fLCDWait

PROC fLCDPageZ
  ldi   AH, LCDCHARS
  mLCDSetPos  Line1,Pos0
  rcall fLCDsZ
  mLCDSetPos  Line2,Pos0
  ldi   AH, LCDCHARS
  rcall fLCDsZ
  ret
ENDP fLCDPageZ

PROC fLCDPageY
  ldi   AH, LCDCHARS
  mLCDSetPos  Line1,Pos0
  rcall fLCDsY
  mLCDSetPos  Line2,Pos0
  ldi   AH, LCDCHARS
  rcall fLCDsY
  ret
ENDP fLCDPageY



PROC fLCDPrint
  LDW   Y,(v_LCDBuf)
  rcall fLCDPageY
  lds   AL, (v_LCDCtrl);, DispControl|DisplayON|CursorOFF|CursorFlash
  mLCD_WR LCD_CMD
  lds   AL, (v_LCDPos);,  SetDDRAM|Line2|Pos3
  mLCD_WR LCD_CMD
  ret
ENDP fLCDPrint

PROC fLCDBuffCLR
  ldi   AH, LCDBUFFSIZE
  ldi   AL, ' '
;  LDW   Y,(v_LCDBuf)
   st   y+,   AL
   dec    AH
  brne  (pc-1-1)
  ret
ENDP fLCDBuffCLR

;¬ывод ASCIIZ строки из Flash в RAM
;Z - адресс начала ASCIIZ строки во Flash пам€ти
;Y - адресс начальной €чейки в RAM пам€ти
PROC fLCDsz2BuffZ
  lpm   AL, z+
  st    y+,   AL
  lpm   AL, z
  tst   AL
  brne  fLCDsz2BuffZ
  ret
ENDP fLCDsz2BuffZ
;##########################################################


PROC fLCDLightOn
  ;< ¬ключим подсветку LCD
    mPinOut LCDLight
    mPinSET LCDLight
  ;> ¬ключим подсветку LCD
  ret
ENDP fLCDLightOn

PROC fLCDLightOff
  ;< ¬ключим подсветку LCD
    mPinOut LCDLight
    mPinCLR LCDLight
  ;> ¬ключим подсветку LCD
  ret
ENDP fLCDLightOff


;###############################################################################



;S_Alex

.exit
