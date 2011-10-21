;File EEPROM.ASM
.cseg
;###############################################################################
;###############################################################################

;###############################################################################
;***************************************************************************
;* 
;* fEEWrite
;*
;* This subroutine waits until the EEPROM is ready to be programmed, then
;* programs the EEPROM with register variable "EEdwr" at address "EEawr:EEawr"
;*
;* Number of words  :1200 ; 5 + return
;*      :8515 ; 7 + return
;* Number of cycles :1200 ; 8 + return (if EEPROM is ready)
;*      :8515 ; 11 + return (if EEPROM is ready)
;* Low Registers used :None
;* High Registers used: ;3 (EEdwr,EEawr,EEawrh)
;*
;***************************************************************************

;***** Subroutine register variables

#define EEdwr   AL    ;data byte to write to EEPROM
#define EEAddL  YL   ;address low byte to write to
#define EEAddH  YH   ;address high byte to write to

;***** Code
PROC  fEEWrite
  sbic  EECR,   EEWE  ;if EEWE not clear
  rjmp  fEEWrite    ;    wait more

; out EEAR,EEawr  ;output address for 1200, commented out !

; the two following lines must be replaced with the line above if 1200 is used
  out   EEARH,    EEAddH  ;output address high for 8515
  out   EEARL,    EEAddL  ;output address low for 8515
    

  out   EEDR,   EEdwr ;output data
  sbi   EECR,   EEMWE ;set master write enable, remove if 1200 is used  
  sbi   EECR,   EEWE  ;set EEPROM Write strobe
        ;This instruction takes 4 clock cycles since
        ;it halts the CPU for two clock cycles
  ret
#undef  EEdwr
#undef  EEAddrL 
#undef  EEAddrH
ENDP  fEEWrite
;###############################################################################
;###############################################################################

;###############################################################################
;***************************************************************************
;* 
;* fEERead
;*
;* This subroutine waits until the EEPROM is ready to be programmed, then
;* reads the register variable "EEdrd" from address "EEardh:EEard"
;*
;* Number of words  :1200 ; 5 + return
;*      :8515 ; 6 + return
;* Number of cycles :1200 ; 8 + return (if EEPROM is ready)
;*      :8515 ; 9 + return (if EEPROM is ready)
;* Low Registers used :1 (EEdrd)
;* High Registers used: :2 (EEard,EEardh)
;*
;***************************************************************************

;***** Subroutine register variables

#define EEdrd   AL    ;result data byte
#define EEAddL  YL   ;address low to read from
#define EEAddH  YH   ;address high to read from

;***** Code

PROC  fEERead
  sbic  EECR,   EEWE  ;if EEWE not clear
  rjmp  fEERead   ;    wait more
; out EEAR,EEard  ;output address for 1200, commented out !

; the two following lines must be replaced with the line above if 1200 is used
  out   EEARH,    EEAddH  ;output address high for 8515
  out   EEARL,    EEAddL  ;output address low for 8515


  sbi   EECR,   EERE  ;set EEPROM Read strobe
        ;This instruction takes 4 clock cycles since
        ;it halts the CPU for two clock cycles
  in    EEdrd,    EEDR  ;get data
  ret
#undef  EEdrd   
#undef  EEAddL 
#undef  EEAddH
ENDP  fEERead
;###############################################################################
;###############################################################################

;###############################################################################

;S_Alex & ATMEL
