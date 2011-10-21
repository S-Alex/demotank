;File LCD_uni.inc
;HD44780-based Character-LCD
;Updated: "2010-09-02" "20:13"
;Updated: "2011-03-14" "20:01"

.nolist
#define LCDLINES  2
#define LCDCHARS  8

#define LCDMODE4LOW     1
#define LCDMODE4HI      1
#define LCDMODESHUFFLE  1
#define LCDMODE8        1
#define LCDMODESPI      1
.list
.listmac


.nolist
#ifndef LCD_UNI_INC
  #define LCD_UNI_INC 1
;<
  #ifndef MACROEX_INC
    #include "MacroEX.asm"
  #endif

  .equ  LCD_D0 = 0
  .equ  LCD_D1 = 1
  .equ  LCD_D2 = 2
  .equ  LCD_D3 = 3
  .equ  LCD_D4 = 4
  .equ  LCD_D5 = 5
  .equ  LCD_D6 = 6
  .equ  LCD_D7 = 7

  ;< Select LCD interface
                  ; 3 - 3 wire (SPI)
                  ; 4 - 4-bit
                  ; 8 - 8-bit
  .equ  LCDTYPE   = 4
  ;> Select LCD interface

  ;<
  .equ  LCDLOW  = 0x0F
  .equ  LCDHI   = ~(LCDLOW)
  .set  LCDMODE = LCDLOW
  ;>


  ;< Port for 4-bit or 8-bit LCD interface
  ; if 4-bit use hight nibble
  .equ  P_LCD     = PORTC   ;DATA PD4-PD7
  ;> Port for 4-bit or 8-bit LCD interface

  .equ  LCDRS     = 6       ;"1" - DATA. "0" - COMMAND
  .equ  P_LCDRS   = PORTC   ; DATA or COMMAND selector

  .equ  LCDE      = 4       ; LCD Data Strobe
  .equ  P_LCDE    = PORTC

  .equ  LCDRW     = 5
  .equ  P_LCDRW   = PORTC

  .if LCDTYPE == 3
    ;< Pins for 3 wire (SPI) LCD interface
    .equ  LCDDat    = LCDRS   ; Serial Data
    .equ  P_LCDDat  = P_LCDRS

    .equ  LCDClk    = 3       ; Serial Clock
    .equ  P_LCDClk  = PORTC
    ;> Pins for 3 wire (SPI) LCD interface
  .endif


  ;< Data type for LCD use whith macro mLCD_WR
  .equ  LCD_CMD   = 0
  .equ  LCD_DATA  = 1
  ;> Data type for LCD use whith macro mLCD_WR

  ;< For info
  .if LCDTYPE == 3
    .message "+-----------------------------+"
    .message "| LCD: 3 wire (SPI) interface |"
    .message "+-----------------------------+"
  .elif LCDTYPE == 4
    .message "+----------------------+"
    .message "| LCD: 4-bit interface |"
    .message "+----------------------+"
  .elif LCDTYPE == 8
    .message "+----------------------+"
    .message "| LCD: 8-bit interface |"
    .message "+----------------------+"
  .endif
  ;> For info

  .equ  LCDBUFFSIZE = LCDLINES * LCDCHARS


  .equ DelayLCD1  = 45    ;us
  .equ DelayLCD2  = 1800  ;us after ClearDisplay

  .equ Line1      = 0x00
  .equ Line2      = 0x40 ; exp(LCD_D6)  ;

  .equ Pos0   = 0<<LCD_D3|0<<LCD_D2|0<<LCD_D1|0<<LCD_D0 ;
  .equ Pos1   = 0<<LCD_D3|0<<LCD_D2|0<<LCD_D1|1<<LCD_D0 ;
  .equ Pos2   = 0<<LCD_D3|0<<LCD_D2|1<<LCD_D1|0<<LCD_D0 ;
  .equ Pos3   = 0<<LCD_D3|0<<LCD_D2|1<<LCD_D1|1<<LCD_D0 ;
  .equ Pos4   = 0<<LCD_D3|1<<LCD_D2|0<<LCD_D1|0<<LCD_D0 ;
  .equ Pos5   = 0<<LCD_D3|1<<LCD_D2|0<<LCD_D1|1<<LCD_D0 ;
  .equ Pos6   = 0<<LCD_D3|1<<LCD_D2|1<<LCD_D1|0<<LCD_D0 ;
  .equ Pos7   = 0<<LCD_D3|1<<LCD_D2|1<<LCD_D1|1<<LCD_D0 ;
  .equ Pos8   = 1<<LCD_D3|0<<LCD_D2|0<<LCD_D1|0<<LCD_D0 ;
  .equ Pos9   = 1<<LCD_D3|0<<LCD_D2|0<<LCD_D1|1<<LCD_D0 ;
  .equ Pos10  = 1<<LCD_D3|0<<LCD_D2|1<<LCD_D1|0<<LCD_D0 ;
  .equ Pos11  = 1<<LCD_D3|0<<LCD_D2|1<<LCD_D1|1<<LCD_D0 ;
  .equ Pos12  = 1<<LCD_D3|1<<LCD_D2|0<<LCD_D1|0<<LCD_D0 ;
  .equ Pos13  = 1<<LCD_D3|1<<LCD_D2|0<<LCD_D1|1<<LCD_D0 ;
  .equ Pos14  = 1<<LCD_D3|1<<LCD_D2|1<<LCD_D1|0<<LCD_D0 ;
  .equ Pos15  = 1<<LCD_D3|1<<LCD_D2|1<<LCD_D1|1<<LCD_D0 ;

  ;-----------------------
  .equ ClearDisplay  =0x01  ; exp(LCD_D0) ;
  .equ ReturnHome    =0x02  ; exp(LCD_D1) ;
  ;-----------------------
  .equ EntryMode     =0x04  ; exp(LCD_D2) ;
  .equ DecCurPos     =0x04  ; exp(LCD_D2) ;
  .equ IncCurPos     =0x06  ; exp(LCD_D2)+exp(LCD_D1) ;
  .equ NoDispShift   =0x04  ; exp(LCD_D2) ;
  .equ DispShift     =0x05  ; exp(LCD_D2)+exp(LCD_D1) ;
  ;-----------------------
  .equ DispControl   =0x08  ; exp(LCD_D3) ;
  .equ DisplayOFF    =0x08  ; exp(LCD_D3) ;
  .equ DisplayON     =0x0C  ; exp(LCD_D3)+exp(LCD_D2) ;
  .equ CursorOFF     =0x08  ; exp(LCD_D3) ;
  .equ CursorON      =0x0A  ; exp(LCD_D3)+exp(LCD_D1) ;
  .equ CursorNoFlash =0x08  ; exp(LCD_D3) ;
  .equ CursorFlash   =0x09  ; exp(LCD_D3)+exp(LCD_D0) ;
  ;-----------------------
  .equ CusDispShift  =0x10  ; exp(LCD_D4) ;
  .equ MoveCursor    =0x10  ; exp(LCD_D4) ;
  .equ ShiftDisplay  =0x18  ; exp(LCD_D4)+exp(LCD_D3) ;
  .equ ShiftLeft     =0x10  ; exp(LCD_D4) ;
  .equ ShiftRight    =0x14  ; exp(LCD_D4)+exp(LCD_D2) ;
  ;-----------------------
  .equ FunctionSet   =0x20  ; exp(LCD_D5) ;
  .equ Interface4bit =0x20  ; exp(LCD_D5) ;
  .equ Interface8bit =0x30  ; exp(LCD_D5)+exp(LCD_D4) ;
  .equ DisplayLine1  =0x20  ; exp(LCD_D5) ;
  .equ DisplayLine2  =0x28  ; exp(LCD_D5)+exp(LCD_D3) ;
  .equ Font5_7Dot    =0x20  ; exp(LCD_D5) ;
  .equ Font5_10Dot   =0x24  ; exp(LCD_D5)+exp(LCD_D2) ;
  ;-----------------------
  .equ SetCGRAM      =0x40  ; exp(LCD_D6) ;
  .equ MaskACG       =0x3f  ; ~(exp(LCD_D7)+exp(LCD_D6) ;
  ;-----------------------
  .equ SetDDRAM      =0x80  ; exp(LCD_D7) ;
  .equ MaskADD       =0x7f  ; ~(exp(LCD_D7) ;
  ;##########################################################
  ;##########################################################
  .dseg
  .nolist
  alignD $10
    v_LCDBuf:
    v_LCDBuf1:  .byte LCDBUFFSIZE/2
    v_LCDBuf2:  .byte LCDBUFFSIZE/2
    v_LCDCtrl:  .byte 1
    v_LCDPos:   .byte 1
  .cseg
  .listmac
  ;##########################################################
  ;##########################################################

  .macro mLCD_WR  ; mLCD_WR LCD_CMD (LCD_DATA_)
    .if LCDTYPE == 3
      ;< LCD whith 3 wire interface (SPI) use 74hc164
      rcall fLCD_WR3
      .if @0==LCD_CMD
        mPinCLR LCDRS
      .elif @0==LCD_DATA
        mPinSET LCDRS
      .else
        .error "Botva BATENKA!!!"
      .endif
      rcall fLCD_Strob
      rcall fLCDWait
      ;> LCD whith 3 wire interface (SPI) use 74hc164
    .elif LCDTYPE == 4
      ;< LCD 4-bit interface
      .if @0==LCD_CMD
        mPinCLR LCDRS
      .elif @0==LCD_DATA
        mPinSET LCDRS
      .else
        .error "Botva BATENKA!!!"
      .endif
      rcall fLCD_WR4
      ;> LCD 4-bit interface
    .elif LCDTYPE == 8
      ;< LCD 8-bit interface. !!! NOT CHECK
      .if @0==LCD_CMD
        mPinCLR LCDRS
      .elif @0==LCD_DATA
        mPinSET LCDRS
      .else
        .error "Botva BATENKA!!!"
      .endif
      ;> LCD 8-bit interface. !!! NOT CHECK
      rcall fLCD_WR8
    .endif
  .endmacro

  .macro mLCDSetPos ; mLCDSetPos Line(1,2),Pos(0-15)
    ldi AL,SetDDRAM|@0|@1
    mLCD_WR LCD_CMD;rcall fLCD_WR4
;   mDelayUS 2000
  .endmacro

  .macro mLCDszZat  ; mLCDszZat Line(1,2),Pos(0-15),addr SZ
    ldi AL,SetDDRAM|@0|@1
    mLCD_WR LCD_CMD
    ldi ZL,low(@2*2)
    ldi ZH,high(@2*2)
    rcall fLCDszZ
  .endmacro

  .macro mLCDszZ    ; mLCDszZ addr SZ
    ldi ZL,low(@0*2)
    ldi ZH,high(@0*2)
    rcall fLCDszZ
  .endmacro

  .macro mLCDszYat  ; mLCDszYat Line(1,2),Pos(0-15),addr SZ
    ldi AL,SetDDRAM|@0|@1
    mLCD_WR
    ldi YL,low(@2)
    ldi YH,high(@2)
    rcall fLCDszY
  .endmacro

  .macro mLCDszY    ; mLCDszY addr SZ
    ldi YL,low(@0)
    ldi YH,high(@0)
    rcall fLCDszY
  .endmacro


  .macro mLCDClear  ; mLCDClear
    ldi AL,ClearDisplay
    mLCD_WR
    mDelayUS DelayLCD2
  .endmacro

  .macro mLCDPageY  ; mLCDPageY addr SZ
    ldi YL,low(@0)
    ldi YH,high(@0)
    rcall fLCDPageY
  .endmacro

  .macro mLCDPageZ  ; mLCDPageZ addr SZ
    ldi ZL,low(@0)
    ldi ZH,high(@0)
    rcall fLCDPageZ
  .endmacro

  .macro mLCDBuffCLR
    LDW   Y ,@0
    rcall fLCDBuffCLR
  .endmacro
  .include  "LCD_uni.asm"
;>
#else
  #warning "----------------------------------------------";
  #message "### Duplicate include file '" __FILE__ "' ###";windows.inc;
  #message "----------------------------------------------";
#endif
.list
.listmac
.exit
;S_Alex
