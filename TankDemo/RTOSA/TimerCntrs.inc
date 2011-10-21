;File TimerCntrs.inc
;Updated: "2011-03-07" "19:41"
;Updated: "2011-03-17" "23:39"

#ifndef TIMERCNTRS_INC
#define TIMERCNTRS_INC 1
  ;< <<<
  ;< TC0
    #if defined(__ATmega8__)
      #message "--------------------------------------------Timers for ATmega8:--------------------------------------------"
      ;CS02 CS01 CS00         ;Description
      .equ T0_OFF     = 0b000 ;No clock source. (Timer/counter stopped)
      .equ T0Div1     = 0b001 ;clkI/O/1 (No prescaling)
      .equ T0Div8     = 0b010 ;clkI/O/8 (From prescaler)
      .equ T0Div64    = 0b011 ;clkI/O/64 (From prescaler)
      .equ T0Div256   = 0b100 ;clkI/O/256 (From prescaler)
      .equ T0Div1024  = 0b101 ;clkI/O/1024 (From prescaler)
      .equ T0ExtFall  = 0b110 ;External clock source on T0 pin. Clock on falling edge.
      .equ T0ExtRis   = 0b111 ;External clock source on T0 pin. Clock on rising edge.
    #elif defined (__ATmega103__)|defined (__ATmega64__)
      ;CS02 CS01 CS00         ;Description
      .equ T0_OFF     = 0b000 ;No clock source. (Timer/counter stopped)
      .equ T0Div1     = 0b001 ;clkI/O/1 (No prescaling)
      .equ T0Div8     = 0b010 ;clkI/O/8 (From prescaler)
      .equ T0Div32    = 0b011 ;clkI/O/32 (From prescaler)
      .equ T0Div64    = 0b100 ;clkI/O/64 (From prescaler)
      .equ T0Div128   = 0b101 ;clkI/O/128 (From prescaler)
      .equ T0Div256   = 0b110 ;clkI/O/256 (From prescaler)
      .equ T0Div1024  = 0b111 ;clkI/O/1024 (From prescaler)
      ;-----------------------------------------------------+
      ;Compare Output Mode, Non-PWM Mode                    |
      ;COM01|COM00| Description                             |
      ;  0  |  0  | Normal port operation, OC2 disconnected.|
      ;  0  |  1  | Toggle OC2 on compare match             |
      ;  1  |  0  | Clear OC2 on compare match              |
      ;  1  |  1  | Set OC2 on compare match                |
      ;-----------------------------------------------------+
      .equ  COMTC0NORMAL  = (0<<COM01)|(0<<COM00) ;         |
      .equ  COMTC0Toggle  = (0<<COM01)|(1<<COM00) ;         |
      .equ  COMTC0Clear   = (1<<COM01)|(0<<COM00) ;         |
      .equ  COMTC0Set     = (1<<COM01)|(1<<COM00) ;         |
      ;-----------------------------------------------------+
    #endif
  ;> TC0

  ;< TC1
  ;< 16-bit Timer/Counter (Timer/Counterl and Timer/Counter3)
  #if defined(__ATmega8__)||defined(__ATmega64__)
  ;Тактируется от задающего генератора TCK или от внешнего входа T1
  ;через делитель коэффициент деления 1,8,64,256,1024.
  ;Регистр управления таймером/счетчиком0.
  ;TCCR1A-(The Timer/Counter1 Control Register)
    ;CS12 CS11 CS10 Description
    .equ T1_OFF     = 0b000 ;No clock source. (Timer/counter stopped)
    .equ T1Div1     = 0b001 ;clkI/O/1 (No prescaling)
    .equ T1Div8     = 0b010 ;clkI/O/8 (From prescaler)
    .equ T1Div64    = 0b011 ;clkI/O/64 (From prescaler)
    .equ T1Div256   = 0b100 ;clkI/O/256 (From prescaler)
    .equ T1Div1024  = 0b101 ;clkI/O/1024 (From prescaler)
    .equ T1ExtFall  = 0b110 ;External clock source on T1 pin. Clock on falling edge.
    .equ T1ExtRis   = 0b111 ;External clock source on T1 pin. Clock on rising edge.


;----+-----+-----+-----+-----+---------------------------+------+---------+---------+
;Mode|WGMn3|WGMn2|WGMnl|WGMnO|Timer/Counter Mode of      |TOP   |Update of|TOVn Flag|
;    |     |CTCn |PWMnl|PWMn0|        Operation          |      |OCRnx at | Set on  |
;  0 |  0  |  0  |  0  |  0  |Normal                     |OxFFFF|Immediate|MAX      |
;  1 |  0  |  0  |  0  |  1  |PWM, Phase Correct, 8-bit  |OxOOFF|TOP      |BOTTOM   |
;  2 |  0  |  0  |  1  |  0  |PWM, Phase Correct, 9-bit  |0x01FF|TOP      |BOTTOM   |
;  3 |  0  |  0  |  1  |  1  |PWM, Phase Correct, 10-bit |0x03FF|TOP      |BOTTOM   |
;  4 |  0  |  1  |  0  |  0  |CTC                        |OCRnA |Immediate|MAX      |
;  5 |  0  |  1  |  0  |  1  |Fast PWM, 8-bit            |OxOOFF|TOP      |TOP      |
;  6 |  0  |  1  |  1  |  0  |Fast PWM, 9-bit            |0x01FF|TOP      |TOP      |
;  7 |  0  |  1  |  1  |  1  |Fast PWM, 10-bit           |0x03FF|TOP      |TOP      |
;  8 |  1  |  0  |  0  |  0  |PWM, Phase and Freq Correct|ICRn  |BOTTOM   |BOTTOM   |
;  9 |  1  |  0  |  0  |  1  |PWM, Phase and Freq Correct|OCRnA |BOTTOM   |BOTTOM   |
;  10|  1  |  0  |  1  |  0  |PWM, Phase Correct         |ICRn  |TOP      |BOTTOM   |
;  11|  1  |  0  |  1  |  1  |PWM, Phase Correct         |OCRnA |TOP      |BOTTOM   |
;  12|  1  |  1  |  0  |  0  |CTC                        |ICRn  |Immediate|MAX      |
;  13|  1  |  1  |  0  |  1  |(Reserved)                 |-     |  -      |-        |
;  14|  1  |  1  |  1  |  0  |Fast PWM                   |ICRn  |TOP      |TOP      |
;  15|  1  |  1  |  1  |  1  |Fast PWM                   |OCRnA |TOP      |TOP      |
;----+-----+-----+-----+-----+---------------------------+------+---------+---------+
    .equ  PWM1A_Discon  = (0<<COM1A1)|(0<<COM1A0)
    .equ  PWM1A_Toggle  = (0<<COM1A1)|(1<<COM1A0)
    .equ  PWM1A_NoInv   = (1<<COM1A1)|(0<<COM1A0)
    .equ  PWM1A_Inv     = (1<<COM1A1)|(1<<COM1A0)

    .equ  PWM1B_Discon  = (0<<COM1B1)|(0<<COM1B0)
    .equ  PWM1B_Toggle  = (0<<COM1B1)|(1<<COM1B0)
    .equ  PWM1B_NoInv   = (1<<COM1B1)|(0<<COM1B0)
    .equ  PWM1B_Inv     = (1<<COM1B1)|(1<<COM1B0)

    #if defined(__ATmega64__)
    
      .equ T3_OFF     = 0b000 ;No clock source. (Timer/counter stopped)
      .equ T3Div1     = 0b001 ;clkI/O/1 (No prescaling)
      .equ T3Div8     = 0b010 ;clkI/O/8 (From prescaler)
      .equ T3Div64    = 0b011 ;clkI/O/64 (From prescaler)
      .equ T3Div256   = 0b100 ;clkI/O/256 (From prescaler)
      .equ T3Div1024  = 0b101 ;clkI/O/1024 (From prescaler)
      .equ T3ExtFall  = 0b110 ;External clock source on T1 pin. Clock on falling edge.
      .equ T3ExtRis   = 0b111 ;External clock source on T1 pin. Clock on rising edge.
  
      .equ  PWM1C_Discon  = (0<<COM1C1)|(0<<COM1C0)
      .equ  PWM1C_Toggle  = (0<<COM1C1)|(1<<COM1C0)
      .equ  PWM1C_NoInv   = (1<<COM1C1)|(0<<COM1C0)
      .equ  PWM1C_Inv     = (1<<COM1C1)|(1<<COM1C0)
    #endif


  #endif
  ;> 16-bit Timer/Counter (Timer/Counterl and Timer/Counter3)
  ;> TC1

  ;< TC2
    #if defined(__ATmega8__)
      #message "--------------------------------------------Timers for ATmega8:--------------------------------------------"
      ;CS22 CS21 CS20         ;Description
      .equ T2_OFF     = 0b000 ;No clock source. (Timer/counter stopped)
      .equ T2Div1     = 0b001 ;clkI/O/1 (No prescaling)
      .equ T2Div8     = 0b010 ;clkI/O/8 (From prescaler)
      .equ T2Div32    = 0b011 ;clkI/O/32 (From prescaler)
      .equ T2Div64    = 0b100 ;clkI/O/64 (From prescaler)
      .equ T2Div128   = 0b101 ;clkI/O/128 (From prescaler)
      .equ T2Div256   = 0b110 ;clkI/O/256 (From prescaler)
      .equ T2Div1024  = 0b111 ;clkI/O/1024 (From prescaler)
    #elif defined (__ATmega103__)|defined (__ATmega64__)
      ;CS22 CS21 CS20         ;Description
      .equ T2_OFF     = 0b000 ;No clock source. (Timer/counter stopped)
      .equ T2Div1     = 0b001 ;clkI/O/1 (No prescaling)
      .equ T2Div8     = 0b010 ;clkI/O/8 (From prescaler)
      .equ T2Div64    = 0b011 ;clkI/O/64 (From prescaler)
      .equ T2Div256   = 0b100 ;clkI/O/256 (From prescaler)
      .equ T2Div1024  = 0b101 ;clkI/O/1024 (From prescaler)
      .equ T2ExtFall  = 0b110 ;External clock source on T0 pin. Clock on falling edge.
      .equ T2ExtRis   = 0b111 ;External clock source on T0 pin. Clock on rising edge.
      ;-----------------------------------------------------+
      ;Compare Output Mode, Non-PWM Mode                    |
      ;COM21|COM20| Description                             |
      ;  0  |  0  | Normal port operation, OC2 disconnected.|
      ;  0  |  1  | Toggle OC2 on compare match             |
      ;  1  |  0  | Clear OC2 on compare match              |
      ;  1  |  1  | Set OC2 on compare match                |
      ;-----------------------------------------------------+
      .equ  COMTC2NORMAL  = (0<<COM21)|(0<<COM20) ;         |
      .equ  COMTC2Toggle  = (0<<COM21)|(1<<COM20) ;         |
      .equ  COMTC2Clear   = (1<<COM21)|(0<<COM20) ;         |
      .equ  COMTC2Set     = (1<<COM21)|(1<<COM20) ;         |
      ;-----------------------------------------------------+

    #endif

  ;> TC2

    .macro mInitTC8bit  ;TIMER,FREQUENCY ;mInitTC8bit 0,100
      #if defined(__ATmega8__)
        .set  F_Ovf = @1;100
      #elif defined(__ATmega64__)
        .set  F_Ovf = @1*2;100
      #endif
      .set  F_Ovf = @1*2;100
      .set  N_Cnt   = 8
      .set  FnMin   = 1
      .set  FnMax   = (1<<N_Cnt) - 1

      .set  PreDivMin = Fclk / ( F_Ovf * FnMax)
      .set  PreDivMax = Fclk / ( F_Ovf * FnMin)

    #if defined(__ATmega8__)||defined(__ATmega64__)
      .message  " +--------------+"
      .if @0==0
       .message " |PreDiv for TC0|"
      .elif @0==2
       .message " |PreDiv for TC2|"
      .endif
      .if PreDivMin < 1
        .message " |   Div1       |"
        .set PreDiv = 1
        .set DivMask = T@0Div1
      .elif (PreDivMin<8)&&defined(T@0Div8)
        .message " |   Div8       |"
        .set PreDiv = 8
        .set DivMask = T@0Div8
      .elif (PreDivMin<32)&&defined(T@0Div32)
        .message " |   Div32      |"
        .set PreDiv = 32
        .set DivMask = T@0Div32
      .elif (PreDivMin<64)&&defined(T@0Div64)
        .message " |   Div64      |"
        .set PreDiv = 64
        .set DivMask = T@0Div64
      .elif (PreDivMin<128)&&defined(T@0Div128)
        .message " |   Div128     |"
        .set PreDiv = 128
        .set DivMask = T@0Div128
      .elif (PreDivMin<256)&&defined(T@0Div256)
        .message " |   Div256     |"
        .set PreDiv = 256
        .set DivMask = T@0Div256
      .elif (PreDivMin<1024)&& defined(T@0Div8)
        .message " |   Div1024    |"
        .set PreDiv = 1024
        .set DivMask = T@0Div1024
      .else
        .error "Timer not config"
      .endif
      .message  "+--------------+"


      .set  Fn  = Fclk/(PreDiv * F_Ovf)
      #if defined(__ATmega8__)
        in    AL,     TIMSK
        ori   AL,     (1<<TOIE0);Bit 0 - TOIE0: Timer/Counter0 Overflow Interrupt Enable
        out   TIMSK,  AL
      
      ;< Interrupt
        .set  OldPC = pc
        .org  OVF0addr  ;Overflow0 Interrupt Vector Address
          rjmp TIM0_OVF ;Timer0 Overflow Handler
        .org  OldPC
        
        TIM0_OVF: ;Timer0 Overflow Handler
        in    TmpSREG,  SREG
        push  AL
        ;Place your code here
        ldi   AL, (1<<N_Cnt)-Fn
        out   TCNT0,  AL
        ;
        pop   AL
        out   SREG,   TmpSREG
        reti
      ;> Interrupt

      #elif defined(__ATmega64__)
        .if @0==0
          ldi   AL,     DivMask|(1<<WGM01)|(0<<WGM00)|COMTC0Toggle
          out   TCCR0,  AL
          ldi   AL,     Fn
          out   OCR0,   AL
        .elif @0==2
          ldi   AL,     DivMask|(1<<WGM21)|(0<<WGM20)|COMTC2Toggle
          out   TCCR2,  AL
          ldi   AL,     Fn
          out   OCR2,   AL
        .endif
      #endif
    #else
      #error "Sorry. Chip not support"
    #endif


    .endmacro

    ;F_Ovf = Fclk / (PreDiv * (2^n - Fn))
    ;PreDiv  = Fclk / ( F_Ovf * (2^n - Fn))






  #if defined(__ATmega8__)
    .equ  PWM       = bit3
    .equ  P_PWM     = PORTB
  #elif defined(__ATmega64__)
    .equ  PWM1A     = bit5
    .equ  P_PWM1A   = PORTB
    .equ  PWM1B     = bit6
    .equ  P_PWM1B   = PORTB
  #endif

  ;###############################################################################
  ;###############################################################################

  ;###############################################################################
  ;опредение переменных для работы с таймерами/счетчиками.
  ;###############################################################################
  ;Table 42. Waveform Generation Mode Bit Description
  ;---------------------------------------------------------------------|
  ;Mode | WGM21 | WGM20 | Timer/Counter      | TOP |  Update  | TOV2    |
  ;     | (CTC2)| (PWM2)| Mode of Operation  |     | of OCR2  | Flag Set|
  ;---------------------------------------------------------------------|
  ; 0   |   0   |   0   | Normal             |0xFF |Immediate | MAX     |
  ; 1   |   0   |   1   | PWM, Phase Correct |0xFF |   TOP    | BOTTOM  |
  ; 2   |   1   |   0   | CTC                |OCR2 |Immediate | MAX     |
  ; 3   |   1   |   1   | Fast PWM           |0xFF |   TOP    | MAX     |
  ;---------------------------------------------------------------------|
  ;Note: 1. The CTC2 and PWM2 bit definition names are now obsolete.
  ;Use the WGM21:0 definitions.
  ;However, the functionality and location of these bits are compatible with
  ;previous versions of the timer.
  ;###############################################################################

  ;###############################################################################
  ;Bit        |  7 |   6  |   5  |   4  |   3  |   2 |   1 |  0  |
  ;TCCR2      |FOC2| WGM20| COM21| COM20| WGM21| CS22| CS21| CS20| ;OLD
  ;TCCR2      |FOC2| PWM2 | COM21| COM20| CTC2 | CS22| CS21| CS20|
  ;Read/Write |  W | R/W  | R/W  | R/W  | R/W  | R/W | R/W | R/W |
  ;Init Value |  0 |   0  |   0  |   0  |   0  |   0 |   0 |  0  |
  ;###############################################################################


  .macro  mPWM2Init
    ldi   ACC,  T2Div1|PWM_Fast|PWM_NoInv
    out   TCCR2,  ACC
    mPinOut PWM
    mPinSET PWM
  .endmacro

  .macro  mPWM2Stop
    ldi   ACC,  T2_OFF
    out   TCCR2,  ACC
    mPinIn  PWM
    mPinSET PWM
  .endmacro


  ;###############################################################################
  ;For  ATmega8 & ATmega103 & ATmega64

  ;опредение переменных для работы с таймерами/счетчиками.

  ;Таймер/счетчик0  8 разрядный.
  ;Тактируется от задающего генератора TCK, или TOSC1 RTC,
  ;через делитель коэффициент деления 1,8,32,64,128,256,1024.
  ;Регистр управления таймером/счетчиком0.
  ;TCCR0-(The Timer/Counter0 Control Register)
  #if defined(__ATmega8__)
  ;code specific for these devices
  #message "--------------------------------------------Timers for ATmega8:--------------------------------------------"

    .equ  PWM_PhC   = (0<<CTC2)|(1<<PWM2);PWM, Phase Correct
    .equ  PWM_Fast  = (1<<CTC2)|(1<<PWM2);Fast PWM
    .equ  PWM_NoInv = (1<<COM21)|(0<<COM20)
    .equ  PWM_Inv   = (1<<COM21)|(1<<COM20)






  #elif defined (__ATmega103__)|defined (__ATmega64__)
; ;code specific for ATmega103
;   ;Bits2,1,0-CS02,CS01,CS00:Clock Select
;   ;Биты выбора тактовой частоты таймера/счетчика0
;   ;       = 0b76543210
;   .equ T0_OFF   = 0b00000000
;   .equ T0Div1   = 0b00000001
;   .equ T0Div8   = 0b00000010
;   .equ T0Div32  = 0b00000011
;   .equ T0Div64  = 0b00000100
;   .equ T0Div128 = 0b00000101
;   .equ T0Div256 = 0b00000110
;   .equ T0Div1024  = 0b00000111
  #endif

  ;mInit_TC0  T0Div8, 1 установить предделитель на 8 и разрешить прерывания от таймера
  .macro  mInit_TC0 ;T0Div8, 1
    ldi   ACC,  @0
    out   TCCR0,  ACC
    out   TCNT0,  ZERO  ;Clear T/C 0
    .if @1
      in    ACC,  TIMSK
      ori   ACC,  @1
      out   TIMSK,  ACC
    .endif

  .endmacro
  ;###############################################################################
  ;###############################################################################

  ;###############################################################################

  #if defined(__ATmega8__)
    .macro  mInit_TC2
      ldi   R16,  @0
      out   TCCR2,  R16

      in    R16,  TIMSK
      andi  R16,  ~(1<<TOIE2)
      out   TIMSK,  R16

    .endmacro

  #elif defined (__ATmega103__)
    ;Таймер/счетчик2  8 разрядный.
    ;Тактируется от задающего генератора TCK через делитель.
    ;коэффициент деления 1,8,64,256,1024.Или от входа PD7(T2).
    ;Регистр управления таймером/счетчиком2.
    ;TCCR2-(The Timer/Counter2 Control Register)

    ;=======================================================
    ;Bit6-PWM0,PWM2: Pulse Width Modulator Enable.
    ; Разрешение ШИМ.
    .equ PWM_ON   = 0b01000000
    .equ PWM_OFF  = 0b00000000
    ;-------------------------------------------------------
    ;Bits5,4-COM01,COM00/COM21,COM20: Compare Output Mode.
    ;Режим работы вывода PB4(OC0/PWM0)
    ;       = 0b76543210
    .equ OC_OFF   = 0b00000000;отключение вывода PB4(OC0/PWM0)
                  ; -//-    PB7(OC2/PWM2).
    .equ OC_Toggle  = 0b00010000;перключение вывода PB4(OC0/PWM0)
                  ; -//-    PB7(OC2/PWM2).
    .equ OC_Clear = 0b00100000;Очистка вывода PB4(OC0/PWM0)
                  ; -//-    PB7(OC2/PWM2).
    .equ OC_Set   = 0b00110000;Установка вывода PB4(OC0/PWM0)
                  ; -//-    PB7(OC2/PWM2).
    ;-------------------------------------------------------
    ;Bit3-CTC0/CTC2: Clear Timer/Counter on Compare match
    ;Очистить Таймер/счетчик0,2 при совпадении значения
    ;таймера/счетчика [регистр TCNT0,2-(Timer/Counter0,2)]
    ;с содержимым регистра OCR0,2-(Timer/Counter0,2 Output Compare Register)
    ;       = 0b76543210
    .equ Comp_ON  = 0b00001000
    .equ Comp_OFF = 0b00000000
    ;-------------------------------------------------------

    ;CS02 CS01 CS00 Description
    ;0 0 0 No clock source (Timer/counter stopped).
    ;0 0 1 clkI/O/(No prescaling)
    ;0 1 0 clkI/O/8 (From prescaler)
    ;0 1 1 clkI/O/64 (From prescaler)
    ;1 0 0 clkI/O/256 (From prescaler)
    ;1 0 1 clkI/O/1024 (From prescaler)
    ;1 1 0 External clock source on T0 pin. Clock on falling edge.
    ;1 1 1 External clock source on T0 pin. Clock on rising edge.

    ;Bits2,1,0-CS22,CS21,CS20:Clock Select
    ;Биты выбора тактовой частоты таймера/счетчика2
    ;       = 0b76543210
    .equ T2_OFF   = 0b00000000
    .equ T2Div1   = 0b00000001
    .equ T2Div8   = 0b00000010
    .equ T2Div64  = 0b00000011
    .equ T2Div256 = 0b00000100
    .equ T2Div1024  = 0b00000101
    .equ T2NegEdge  = 0b00000110
    .equ T2PosEdge  = 0b00000111
    ;=======================================================
    .equ ASync  =$08
    .equ Sync =$00

    .macro Init_TC0;
      ldi   R16,@1
      out   ASSR0,R16
      ldi   R16,@0
      out   TCCR0,R16
      LAsync1:
      in    R16,ASSR0
      andi  R16,$07
      brne  LAsync1
    .endm

    .macro  mInit_TC2
      ldi R16,@0
      out TCCR2,R16
    .endmacro
  #endif
  ;###############################################################################
  ;###############################################################################











  ;###############################################################################


  .macro  mInit_TC1
    ldi   ACC   ,@0
    out   TCCR1B,ACC
  .endmacro




  .macro  mPWM1Init
    ;Timer/Counter 1 Control
    ;Register A – TCCR1A
    ;   7      6     5      4      3       2     1     0
    ;COM1A1 COM1A0 COM1B1 COM1B0 COM1C1 COM1C0 WGM11 WGM10
    
    ;Timer/Counter 1 Control
    ;Register B – TCCR1B
    ; 7   |  6  |5|  4  |  3  | 2  | 1  | 0  |
    ;ICNC1|ICES1|–|WGM13|WGM12|CS12|CS11|CS10|
    
    ldi   AL      ,0x80
    mOut  TCCR1A  ,AL;
    ldi   AL      ,0x14
    mOut  TCCR1B  ,AL;
    
    
    ldi   AL      ,0x00
    mOut  OCR1AH  ,AL;
    ldi   AL      ,0xf0
    mOut  OCR1AL  ,AL;
    
    LDW   Z       ,(2500)
    mOut  ICR1H   ,ZL;
    mOut  ICR1L   ,ZH;

    mPinOut PWM1A
    mPinSET PWM1A
  .endmacro

  .macro mT1SetMode ;MODE,PREDIV,PWM1TYPE
  .if 1
  .endif
    mIn   AL    ,TCCR1A
    cbr   AL    ,0xff;(1<<WGM11)|(1<<WGM10)
    ori   AL    ,(@0&0b0011)|@2

    mIn   AH    ,TCCR1B
    .if @1>7
      ; Ignore PREDIV
      cbr   AH  ,(1<<WGM13)|(1<<WGM12)
      ori   AH  ,((@0&0b1100)<<1)
    .else       
      cbr   AH  ,(1<<WGM13)|(1<<WGM12)|(1<<CS12)|(1<<CS11)|(1<<CS10)
      ori   AH  ,((@0&0b1100)<<1)|@1
    .endif

    mOut  TCCR1A  ,AL
    mOut  TCCR1B  ,AH



    mPinOut PWM1A
    mPinSET PWM1A

  .endmacro

  .macro mT3SetMode ;MODE,PREDIV,PWM1TYPE

    mIn   AL,     TCCR3A
    cbr   AL,     0xff;(1<<WGM11)|(1<<WGM10)
    ori   AL,     (@0&0b0011)|@2

    mIn   AH,     TCCR3B
    .if @1>7
      ; Ignore PREDIV
      cbr   AH,     (1<<WGM33)|(1<<WGM32)
      ori AH,     ((@0&0b1100)<<1)
    .else
      cbr   AH,     (1<<WGM33)|(1<<WGM32)|(1<<CS32)|(1<<CS31)|(1<<CS30)
      ori   AH,     ((@0&0b1100)<<1)|@1|(1<<ICNC3)|(1<<ICES3)
    .endif

    mOut  TCCR3A, AL
    mOut  TCCR3B, AH

  .endmacro



  ;> >>>

#else
    #warning "----------------------------------------------"
    #message "### Duplicate include file '" __FILE__ "' ###"
    #message "----------------------------------------------"
#endif

.exit
;S_Alex
