;File RTOSA.inc
;RTOSA Ver. 0.0.0.1 - Copyright (C) 2009-2010 S_Alex.
;This file is part of the RTOSA distribution.
; "2010-08-09" "19:24"
;Updated: "2010-09-09" "23:32"
;Updated: "2011-03-07" "19:41"
;Updated: "2011-04-05" "14:27"

;###############################################################################
#ifndef TIMERCNTRS_INC
  #include  "RTOSA\TimerCntrs.inc"
#endif
;###############################################################################
;#ifndef AL
; #define AL r16
;#else
; #message "Info: AL already defined"
;#endif

;###############################################################################
.nolist
.dseg
.equ TASKQUEUESIZE    = 16      ; ������ ������� ����� 2,4,8,16
alignD TASKQUEUESIZE
TaskQueue:  .byte TASKQUEUESIZE   ; ����� ������� ����� � SRAM

.equ TIMERSPOOLSIZE   = 16      ; ���������� ��������
TimersPool: .byte TIMERSPOOLSIZE*3  ; ������ ���������� � ��������
.cseg
.list
;###############################################################################
;###############################################################################

;###############################################################################
.def  r_RND     = r7
.def  r_TaskS   = r2  ;������� ��������� ������� �����
.def  r_CNTTASK = r10
;###############################################################################
;######Not ..."
;#########################################################################

;###############################################################################
;######################## ������� ���� ���� ####################################
;###############################################################################
#define TicFreq 100 ; ������� ��������� ������

#define GetTaskID(func) TP_ ## func - TaskProcs;
#define Task(func) TP_ ## func: .dw  func
#define ms * TicFreq/1000
#define s *TicFreq

;#define  Tpod  7500ms
;#define  Tkz   50ms
;#define  Tstick  2000ms
;#define  TReklama  2000ms
;#define  TMenu   2000ms

;mSetTimerTask {ProcName},{Time (min: 1; max: 65535)}
;Example: mSetTimerTask fInitRisCurrentI,50ms
.macro mSetTimerTask
  .if @1>(1<<16) || (@1==0)
    .error "Time out range!!!"
  .else
    ldi   AL  ,GetTaskID(@0)
    ldi   XL  ,low(@1)      ;
    ldi   XH  ,high(@1)   ; �������� � ������������
    rcall krSetTimer
  .endif
.endmacro

;mSetTimerTaskID {GetTaskID(ProcName)},{Time (min: 1; max: 65535)}
;Example: mSetTimerTaskID GetTaskID(fInitRisCurrentI),50ms
.macro mSetTimerTaskID
  .if @1>(1<<16) || (@1==0)
    .error "Time out range!!!"
  .else
    ldi   AL  ,@0
    ldi   XL  ,low(@1)      ;
    ldi   XH  ,high(@1)   ; �������� � ������������
    rcall krSetTimer
  .endif
.endmacro

;mClrTimer {GetTaskID(ProcName)}
;Example: mClrTimerID GetTaskID(fInitRisCurrentI)
.macro mClrTimerID
  ldi   AL  ,@0
  rcall krClrTimer
  ;
.endmacro

;mClrTimer {ProcName}
;Example: mClrTimer fInitRisCurrentI
.macro mClrTimer
  ldi   AL  ,GetTaskID(@0)
  rcall krClrTimer
  ;
.endmacro


;==========================================================================
.macro mSendTask
  push  AL
  ldi   AL  ,GetTaskID(@0)  ; ��������� � ��������� ����� ���������� ���������
  rcall krSendTask        ;
  pop   AL
.endmacro

.macro mSendTask_AL
  rcall krSendTask        ;
.endmacro

.macro  mSendTaskIfSET
  push  AL
  ldi   AL          ,GetTaskID(@1)  ; ��������� � ��������� ����� ���������� ���������
  .if @0<8
    sbrc  r_Flags   ,@0
  .else
    sbrc  r_FlagsH  ,@0&0b111
  .endif
  rcall krSendTask
  pop   AL
.endmacro

.macro  mSendTaskIfSET_AL
  .if @0<8
    sbrc  r_Flags   ,@0
  .else
    sbrc  r_FlagsH  ,@0&0b111
  .endif
  rcall krSendTask
.endmacro

.macro  mSendTaskIfSETC
  push  AL
  ldi   AL          ,GetTaskID(@1)  ; ��������� � ��������� ����� ���������� ���������
  .if @0<8
    sbrc  r_Flags   ,@0
    rcall krSendTask
    sbrc  r_Flags   ,@0
    cbr   r_Flags   ,(1<<@0)
  .else
    sbrc  r_FlagsH  ,@0&0b111
    rcall krSendTask
    sbrc  r_FlagsH  ,@0&0b111
    cbr   r_FlagsH  ,1<<(@0&0b111)
  .endif
  pop   AL
.endmacro

.macro  mSendTaskIfSETC_AL
  .if @0<8
    sbrc  r_Flags   ,@0
    rcall krSendTask
    sbrc  r_Flags   ,@0
    cbr   r_Flags   ,(1<<@0)
  .else
    sbrc  r_FlagsH  ,@0&0b111
    rcall krSendTask
    sbrc  r_FlagsH  ,@0&0b111
    cbr   r_FlagsH  ,1<<(@0&0b111)
  .endif
.endmacro

.macro  mSendTaskIfCLR
  push  AL
  ldi   AL          ,GetTaskID(@1)  ; ��������� � ��������� ����� ���������� ���������
  .if @0<8
    sbrs  r_Flags   ,@0
  .else
    sbrs  r_FlagsH  ,@0&0b111
  .endif
  rcall krSendTask
  pop   AL
.endmacro

.macro  mSendTaskIfCLR_AL
  .if @0<8
    sbrs  r_Flags   ,@0
  .else
    sbrs  r_FlagsH  ,@0&0b111
  .endif
  rcall krSendTask
.endmacro

.macro  mSendTaskIfCLRS
  push  AL
  ldi   AL          ,GetTaskID(@1)  ; ��������� � ��������� ����� ���������� ���������
  .if @0<8
    sbrs  r_Flags   ,@0
    rcall krSendTask
    sbrs  r_Flags   ,@0
    sbr   r_Flags   ,(1<<@0)
  .else
    sbrs  r_FlagsH  ,@0&0b111
    rcall krSendTask
    sbrs  r_FlagsH  ,@0&0b111
    sbr   r_FlagsH  ,1<<(@0&0b111)
  .endif
  pop   AL
.endmacro

.macro  mSendTaskIfCLRS_AL
  .if @0<8
    sbrs  r_Flags   ,@0
    rcall krSendTask
    sbrs  r_Flags   ,@0
    sbr   r_Flags   ,(1<<@0)
  .else
    sbrs  r_FlagsH  ,@0&0b111
    rcall krSendTask
    sbrs  r_FlagsH  ,@0&0b111
    sbr   r_FlagsH  ,1<<(@0&0b111)
  .endif
.endmacro

.macro mSetTask
  ldi   AL  ,@0     ; ��������� � ��������� ����� ���������� ���������
  rcall krSendTask    ;
.endmacro

;==========================================================================

.macro mTimerService
#define Counter r18
; in    TmpSREG,  SREG
; push  AL        ; ���������� �������� AL
  mPUSHw  Z         ; ���������� �������� Z
  push  Counter     ; ���������� �������� Counter

  ldi   ZL      ,low(TimersPool)    ; �������� � ������� Z ������ RAM,
  ldi   ZH      ,high(TimersPool)   ; �� �������� ��������� ���������� � ��������
  ldi   Counter ,TIMERSPOOLSIZE  ; ������������ ���������� ��������

 lTimerService_Loop:
  ld    AL  ,z        ; AL = [Z] ; �������� ����� �������
  cpi   AL  ,0xFF        ; ��������� �� "NOP"
  breq lTimerService_Next   ; ���� NOP �� ������� � ��������� �������

  ;<
  push  AH
  ldd   AL  ,z+1      ;������ ������� ����� ��������
  ldd   AH  ,z+2      ;������ ������� ����� ��������
  subi  AL  ,low(1)   ;���������� ������� ����� �������� �� 1
  sbci  AH  ,high(1)    ;���������� ������� ����� �������� �� 1
  std   z+1 ,AL
  std   z+2 ,AH
  or    AL  ,AH
  pop   AH
  brne lTimerService_Next   ; ���� �� �������
  ;>

  ld    AL  ,z        ; �������� ����� �������
  rcall krSendTask      ; ������� � ��������� ������� �����

  ldi   AL  ,0xFF       ; = NOP (������ ���������, ������ �������������)
  st    z   ,AL       ; Clear Event

 lTimerService_Next:
;   subi  ZL,low(-3)      ; Skip Counter
; sbci  ZH,high(-3)     ; Z+=3 - ������� � ���������� �������
  adiw  ZL  ,3
  dec   Counter       ; ������� ��������
  brne lTimerService_Loop   ; Loop

  pop   Counter       ; ��������������� ����������
  mPOPw   Z
; pop   AL          ; ��������������� ��������
; out   SREG,   TmpSREG
#undef  Counter
.endmacro

;======================================================================================
.macro  mINIT_RTOS
  out   SREG  ,ZERO     ; ������������� SREG
  clr   r_TaskS
  rcall fClearTimers    ; �������� ������ �������� ����
  rcall fClearTaskQueue ; �������� ������� ������� ����
;< ��������� TC0 ;T/C 0 - Init
  ldi   AL    ,T0Div1024 ;Freq/1024 (From prescaler)
  out   TCCR0 ,AL
  in    AL    ,TIMSK
  ori   AL    ,(1<<TOIE0);Bit 0 - TOIE0: Timer/Counter0 Overflow Interrupt Enable
  out   TIMSK ,AL
;> ��������� TC0
.endmacro

;###############################################################################
;###############################################################################

;
;.set Fn  = ((1<<N_Cnt)*PreDiv*F_T0_Ovf  - Fclk) / (PreDiv * F_T0_Ovf)

.macro mInitTicOS ;
  .set  F_T0_Ovf  = @0;100
  .set  N_Cnt     = 8
  .set  FnMin     = 0
  .set  FnMax     = (1<<N_Cnt) - 1

  .set  PreDivMin = Fclk / ( F_T0_Ovf * ((1<<N_Cnt) - FnMin))
  .set  PreDivMax = Fclk / ( F_T0_Ovf * ((1<<N_Cnt) - FnMax))

#if defined(__ATmega8__)||defined(__ATmega64__)
 #message "PreDiv for ATmega8"
  .message  " +--------------+"
  .message  " |PreDiv for TC0|"

  .if PreDivMin < 1
    .message " |   Div1       |"
    .set PreDiv = 1
    .set Val_TCCR0 = T0Div1
  .elif PreDivMin < 8
    .message " |   Div8       |"
    .set PreDiv = 8
    .set Val_TCCR0 = T0Div8
  .elif PreDivMin < 64
    .message " |   Div64      |"
    .set PreDiv = 64
    .set Val_TCCR0 = T0Div64
  .elif PreDivMin < 256
    .message " |   Div256     |"
    .set PreDiv = 256
    .set Val_TCCR0 = T0Div256
  .elif PreDivMin < 1024
    .message " |   Div1024    |"
    .set PreDiv = 1024
    .set Val_TCCR0 = T0Div1024
  .else
    .error "Timer 0 not config"
  .endif
  .message  " +--------------+"

  ldi   AL    ,Val_TCCR0
  out   TCCR0 ,AL
#else
  #error "Sorry. Chip not support"
#endif

  .set  Fn  = Fclk/(PreDiv * F_T0_Ovf)

; .set  Fn  = ((1<<N_Cnt)*PreDiv*F_T0_Ovf  - Fclk) / (PreDiv * F_T0_Ovf)
  .set  Re_TCNT0  = 256-Fn

.endmacro

;F_T0_Ovf = Fclk / (PreDiv * (2^n - Fn))
;PreDiv  = Fclk / ( F_T0_Ovf * (2^n - Fn))

.macro  mINIT_RTOSA
  out   SREG,   ZERO      ; ������������� SREG
  clr   r_TaskS
  clr   r_CNTTASK
  rcall krClearTimers   ; �������� ������ �������� ����
  rcall krClearTaskQueue  ; �������� ������� ������� ����

  #if defined(__ATmega8__)
    ;< ��������� TC0 ;T/C 0 - Init
    
    ; ldi   AL,   T0Div1024 ;Freq/1024 (From prescaler)
    ; out   TCCR0,    AL
      mInitTicOS  TicFreq
    
      in    AL      ,TIMSK
      ori   AL      ,(1<<TOIE0);Bit 0 - TOIE0: Timer/Counter0 Overflow Interrupt Enable
      ori   AL      ,(1<<OCIE0);Bit 1 - OCIE0: Timer/Counter0 Output Compare Match Interrupt Enable
      
      out   TIMSK   ,AL
    
      rjmp  mINIT_RTOSA_Ret
    
    ;< Interrupt
      .set  OldPC = pc
      .org  OVF0addr  ;Overflow0 Interrupt Vector Address
        rjmp TIM0_OVF ;Timer0 Overflow Handler
      .org  OldPC
    ;> Interrupt
    
    
    ;.equ OC0addr = 0x001e  ; Timer/Counter0 Compare Match
    
    
    ;> ��������� TC0
    
    
    
    TIM0_OVF: ;Timer0 Overflow Handler
      in    TmpSREG ,SREG
      push  AL
    
      ;Place your code here
      ldi   AL      ,Re_TCNT0
      out   TCNT0   ,AL
      mTimerService
      pop   AL
      out   SREG    ,TmpSREG
    reti

  #elif defined(__ATmega64__)
    ;< ��������� TC0 ;T/C 0 - Init
    
    ; ldi   AL,   T0Div1024 ;Freq/1024 (From prescaler)
    ; out   TCCR0,    AL
      mInitTicOS  TicFreq
    
      in    AL    ,TIMSK
      ori   AL    ,(1<<OCIE0);Bit 1 - OCIE0: Timer/Counter0 Output Compare Match Interrupt Enable
      
      out   TIMSK ,AL
    
      rjmp  mINIT_RTOSA_Ret
    
    ;< Interrupt
      .set  OldPC = pc
      .org  OC0addr ; Timer/Counter0 Compare Match
        rjmp INT_OC0  ;Timer/Counter0 Compare Match Handler
      .org  OldPC
    ;> Interrupt
    
    
    
    INT_OC0:  ;Timer/Counter0 Compare Match Handler
      in    TmpSREG,  SREG
      push  AL
      push  AH
      ;Place your code here
      ldi   AL    ,Fn
      in    AH    ,OCR0
      add   AL    ,AH
      out   OCR0  ,AL
      
      mTimerService
      pop   AH
      pop   AL
      out   SREG  ,TmpSREG
    reti
    ;> ��������� TC0


  #endif


 mINIT_RTOSA_Ret:
.endmacro

; mkrMemFill v_LCDBuf,' ',LCDBUFFSIZE
.macro  mkrMemFill
  LDW   Y   ,@0
  ldi   AL  ,@1
  ldi   AH  ,@2
  rcall krMemFill
.endmacro

.exit

;S_Alex



