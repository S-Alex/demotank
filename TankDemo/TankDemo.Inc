;File TankDemo.Inc
;Updated: "2011-03-07" "19:41"
;72 - ����� �� ��������
;5.08 ��� �����
;73* 5.08 = 370.84 mm ����� ��������
;73.66 = 29*2.54 ������
;

#define tdLenFM     83000 ;um ����� ������
#define tdRotate   150000 ;um ����� �� ������ �� ������� ������
#define tdWidth   29*2540 ;um ������ �������
#define tdLength  73*2540 ;um 
#define tdStep       2540 ;um 2 pulse
#define PI         3.1415

.equ  TMONET  = 614   ;Value for 1grn = 614 - �������� ������
.equ  FLAMP   = 50    ;Flash frequency [Hz] ������� �����
.equ  GNDMIN  = 128   ;Low level for GND sensor ������� �������
.equ  GMDMAX  = 255   ;High level for GND sensor 

#define	Alf			50    ; ���� ������� ������
#define	TIMEOUT	 5*60 ;[���] ����� ���������� �� ����. ����� ���� ����� �� �����


#define degT      *2*PI*tdWidth /(tdStep*360)
#define degTM     *2*PI*tdWidth*tdLenFM /(tdStep*360*tdRotate)


#define mm  *1000/tdStep
#define um  *1/tdStep

;
;###############################################################################
.include  "m64def.inc"    ;Include the specific headers file for MCU
;###############################################################################
;################### Define a symbol equal to an expression ####################
;###############################################################################
.equ  Fclk    = 16000000  ;Hz
.set  us      = 1
;###############################################################################

;###############################################################################
;################## Define a symbolic name on a register #######################
;###############################################################################
.equ  CF    =   0;Carry Flag
.equ  ZF    =   1;Zero Flag
.equ  NF    =   2;Negative Flag
.equ  VF    =   3;Two's Complement Overflow Flag
.equ  SF    =   4;Sign Bit
.equ  HF    =   5;Half Carry Flag
.equ  TF    =   6;Bit Copy Storage
.equ  IF    =   7;Global Interrupt Enable

.equ  bit0  = 0
.equ  bit1  = 1
.equ  bit2  = 2
.equ  bit3  = 3
.equ  bit4  = 4
.equ  bit5  = 5
.equ  bit6  = 6
.equ  bit7  = 7

.def  ZERO    = r3  ;������� ������ ��� ������
                    ; ������ ������ ��������� 0


.def  TmpSREG = r6
.def  StoreI  = r8

.def  rvInitFlag  = r9

.def  rvIDEvent  = r11
.def  rvIDTask   = r12


.def  rvSpeedLR = r24 ; ����������� ���������� �������� ����������� �������� � ��������
;bit 76543210
;    ||||||||
;    |||||+++--> ������� �������� ������ ��������
;    ||||+-----> �����������; 1 - ������, 0 - �����
;    ||||
;    |+++------> ������� �������� ����� ��������
;    +---------> �����������; 1 - ������, 0 - �����
; ����� 4-� ������

.def  rvIndxServo = r25 ; Index for Servo position


;< Register A 16bit
;#define  AL  r16
.def  AL  = r16
.def  AH  = r17
;> Register A 16bit
;< Register B 16bit
.def  BL  = r18
.def  BH  = r19
;> Register B 16bit
;< Register C 16bit
.def  CL  = r20
.def  CH  = r21
;> Register C 16bit
;;< Register D 16bit
;.def DL  = r22
;.def DH  = r23
;;> Register D 16bit
;;< Register E 16bit
;.def EL  = r24
;.def EH  = r25
;;> Register E 16bit

.def  r_Flags   = r22
  .equ flg_ServoDir = 0   ; 1 - INC ; 0 - DEC rvIndxServo
  .equ flg_AnyKey   = 1   ;
  .equ flg_ADC      = 2
  .equ flg_LS_LR    = 3   ; 1 - Left; 0 - Right
  .equ flg_StepL    = 4   ; ������ �������� �����
  .equ flg_StepR    = 5   ; ������ �������� ������
  .equ flg_IRStart  = 6   ; IRStart
  .set flg_IR_OK    = 7   ; IROK
.def  r_FlagsH  = r23
  .equ flg_LFL      = 8   ; LINE FRONT-L
  .equ flg_LFR      = 9   ; LINE FRONT-R
  .equ flg_LRL      = 10  ; LINE REAR-L
  .equ flg_LRR      = 11  ; LINE REAR-R
  .equ flg_BampF    = 12  ; ����������� �������
  .equ flg_BampR    = 13  ; ����������� �����
  .equ flg_Init     = 13  ; Initialization
  .equ flg_Lamp     = 14  ; �������� �����
  .equ flg_Monet    = 15  ; �������

#define TReklama  2000ms

;###############################################################################

.ifdef  PROTEUS
  .equ  Stop_P    = PORTC
  .equ  Stop_Bit  = bit0
.endif
;###############################################################################

;###############################################################################
.include  "MacroEX.asm" ;Include User macros
.include  "DataRAM.inc" ;
;###############################################################################
;###############################################################################
  .eseg
  .nolist
  .org  0x10
    e_LSMid:
    e_LSMidL: .byte 1
    e_LSMidH: .byte 1

    e_FMMid:
    e_FMMidL: .byte 1
    e_FMMidH: .byte 1


  	e_GNDMin:
  	e_GNDMinFR:		.byte	1	;FRONT-R
  	e_GNDMinFL:		.byte	1	;FRONT-L
  	e_GNDMinRR:		.byte	1	;REAR-R
  	e_GNDMinRL:		.byte	1	;REAR-L
  	e_GNDMax:
  	e_GNDMaxFR:		.byte	1	;FRONT-R
  	e_GNDMaxFL:		.byte	1	;FRONT-L
  	e_GNDMaxRR:		.byte	1	;REAR-R
  	e_GNDMaxRL:		.byte	1	;REAR-L

  .cseg
  .listmac

;< Define Pin for Proteus debug
.if PROTEUS
  mEquPin Stop,PORTA,bit4
.endif
;> Define Pin for Proteus debug

  mEquPin LedRed,PORTG,bit0 ; ����������� ��������� ����� � �����
  mEquPin LedGrn,PORTG,bit1 ; ����������� ��������� ����� � �����

  mEquPin LCDLight,PORTG,bit2 ; ��������� LCD �������

;����������� HXT900
;������ 1500us �����, 1000-2000us �������� ������������.
;������ ���� ����� �����������,
;� ���� HS5980SG �������� �� 550-2450
;������ ���������� �� 700-800 �� 2200-2300,
  mEquPin Servo0  ,PORTB,bit5 ;Out ��� ������ ��� ������������ 0 FM �������
  mEquPin Servo1  ,PORTB,bit6 ;Out  ��� ������ ��� ������������ 1 (�� ������������)

  mEquPin DrvRF   ,PORTA,bit1  ;Out  Right Crawler motor Forward
  mEquPin DrvRR   ,PORTA,bit0  ;Out  Right Crawler motor Rear

  mEquPin DrvLF   ,PORTA,bit7  ;Out  Left Crawler motor Forward
  mEquPin DrvLR   ,PORTA,bit6  ;Out  Left Crawler motor Rear

  mEquPin NCodL   ,PORTE,bit3  ;In ������� ����� ��������
  mEquPin NCodR   ,PORTE,bit4  ;In ������� ������ ��������

  mEquPin SB2     ,PORTC,bit0  ;In ������ ���������� SB2  | PCB Tank R0.1
  mEquPin SB3     ,PORTC,bit1  ;In ������ ���������� SB3  |(SB4) (SB3) (SB2)
  mEquPin SB4     ,PORTC,bit2  ;In ������ ���������� SB4  +-----------------

  mEquPin BampEN  ,PORTD,bit2  ;Out  ���������� ������ ����������� ��������� ��������
  mEquPin BampDir ,PORTE,bit2  ;Out  ����� ������� ��������/������
  mEquPin F0      ,PORTB,bit7  ;Out  ����� �� ���������� ���������� ��������

  mEquPin TSOPF   ,PORTE,bit5  ;In �� ������� ��������� �������  ;INT5
  mEquPin TSOPR   ,PORTE,bit6  ;In �� ������� ������� �������  ;INT6(�� ������������)

  mEquPin LightS  ,PORTD,bit3  ;In �� ������� ������������ ;INT3 (��������)
; mEquPin LightS  ,PORTD,bit4 ;In �� ������� ������������ ;INT3 (��������)

  mEquPin pBuzer  ,PORTC,bit7 ; Buzer

  mEquPin IRC     ,PORTE,bit5  ;In �� ������� ��������� �������  ;INT5

;###############################################################################
;S_Alex
