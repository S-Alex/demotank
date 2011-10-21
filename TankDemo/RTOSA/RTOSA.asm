;File RTOSA.asm
;RTOSA Ver. 0.0.0.1 - Copyright (C) 2009-2011 S_Alex.
;This file is part of the RTOSA distribution.
; "2010-08-09" "19:24"
;Updated: "2010-09-09" "23:32"
;Updated: "2011-03-22" "19:00"

PROC krClearTaskQueue
#define Counter AH
  mPUSHw  Z
  LDW   Z,  (TaskQueue)

  ldi   AL,     0xFF
  ldi   Counter,  TASKQUEUESIZE
  
  ;< Loop
    st  z+,     AL  ;
    dec Counter     ;
  brne (pc)-1-1     ; Loop
  ;> Loop
  mPOPw   Z
  ret
#undef  Counter
ENDP krClearTaskQueue
;###############################################################################
;###############################################################################

;###############################################################################
PROC krClearTimers
#define Counter AH
  mPUSHw  Z
  LDW   Z,  (TimersPool)
  ldi Counter, TIMERSPOOLSIZE
  ldi AL, 0xFF    ; Empty
  ;< Loop
    st z+, AL     ; Event
    st z+, ZERO   ; Counter Lo
    st z+, ZERO   ; Counter Hi
    dec Counter   ;
  brne pc-1-1-1-1 ; Loop
  ;> Loop
  mPOPw   Z
  ret
#undef  Counter
ENDP krClearTimers
;###############################################################################
;###############################################################################
;###############################################################################
PROC krProcessTaskQueue
#define SREG_ r18       ;

  LDW   Z,  (TaskQueue)     ;Загрузка указателя на начало очереди задач
  mov   AL, r_TaskS
  andi  AL, TASKQUEUESIZE-1
  add   ZL,   AL
  ld    AL,   z     ; Читаем идентификатор текущей задачи ID_Task
  cpi   AL,   $FF     ; No Event or Addr out of Range
  breq lProcessTaskQueueN_Ret ; No Action
  ;< Продвижение очереди вперед на одну задачу
  ; Advance Queue
  ;< critical section
  push  SREG_
  in    SREG_,  SREG
  cli
  ldi   AH, $FF
  st    z,    AH
    mov   AH, r_TaskS
    swap  AH
    subi  AH, -$10
    andi  AH, ((TASKQUEUESIZE-1)<<4)|0b1111
    swap  AH
    mov   r_TaskS,AH
  dec   r_CNTTASK
  ;> Продвижение очереди вперед на одну задачу

  LDW   Z,  (TaskProcs<<1)  ;Загрузка указателя на начало списка задач
  lsl   AL        ;ID_Task*2
  add   ZL,   AL
  adc   ZH,   ZERO

  ;< Получаем адрес текущей задачи
  lpm   AL, z+
  lpm   ZH,   z
  mov   ZL,   AL
  ;> Получаем адрес текущей задачи
  out   SREG, SREG_
  pop   SREG_
  ;> critical section

  ijmp      ; Переход на код задачи ;Minimize Stack Usage
 lProcessTaskQueueN_Ret:
  ret
#undef  SREG_
ENDP krProcessTaskQueue
;###############################################################################
;###############################################################################


;###############################################################################
; AL - ID_Tasck
PROC krSendTask
;.ifdef PROTEUS
;   mStop
; .endif

#define SREG_ r18
  mPUSHw  Y
  push  AH
  push  SREG_
  ;< critical section
  in    SREG_,  SREG
  cli

  LDW   Y   ,(TaskQueue)       ;Загрузка указателя на начало очереди задач
  mov   AH  ,r_TaskS
  swap  AH  
  andi  AH  ,TASKQUEUESIZE-1
  add   YL  ,AH
  ld    AH  ,y
  cpi   AH  ,0xFF
  brne lSendTaskN1
    st    y       ,AL
    mov   AH      ,r_TaskS
    subi  AH      ,-0x10
    andi  AH      ,((TASKQUEUESIZE-1)<<4)|0b1111
    mov   r_TaskS ,AH
    inc   r_CNTTASK
    rcall krDedug
 lSendTaskN1:
  out   SREG, SREG_
  ;> critical section
  pop   SREG_
  pop   AH
  mPOPw Y
  ret
#undef  SREG_
ENDP krSendTask
;###############################################################################
;###############################################################################

;###############################################################################
; AL - Timer ID_Task
; X - Counter
;#if 1
;#endif

PROC krSetTimer
#define SREG_ r19
#define Counter r18
  mPUSHw  Z
  push AH
  push Counter
  push SREG_
  
  ;< critical section
  in    SREG_,  SREG  ; Critical Section
  cli
  
  ;< Поиск в очереди таймеров таймера с текущим заданием ID_Task
  LDW   Z     ,(TimersPool)
  ldi Counter ,TIMERSPOOLSIZE
 L_krSetTimer_SearchLoop:
    ld  AH    ,z      ; Value / Counter
    cp  AH    ,AL     ; Search for Event
    brne L_krSetTimer_MissMatchID
    
; L_krSetTimer_MatchID:
  ;< ID_Task match AL
  std   z+1   ,XL    
  std   z+2   ,XH    ; Update Counter
  or    XL    ,XH
  brne L_krSetTimer_ret   ; Exit
    ldi AH    ,0xFF
    st  z     ,AH
  rjmp L_krSetTimer_ret   ; Exit
  ;> ID_Task match AL
  
 L_krSetTimer_MissMatchID:
    adiw  ZL, 3
    dec Counter     ;
    brne L_krSetTimer_SearchLoop; Loop
  ;> Поиск в очереди таймеров таймера с текущим заданием ID_Task

  ;< Search in queue Empty Timer
  LDW   Z,    (TimersPool)
  ldi Counter, TIMERSPOOLSIZE
 L_krSetTimer_EmptyLoop:
    ld  AH, z     ; Value / Counter
    cpi AH, 0xFF    ; Search for Empty Timer
    brne L_krSetTimer_NoEmpty
    
; L_krSetTimer_Empty:
  ;< ID_Task match AL
  st    z,    AL    ; Set Event ID_Task
  std   z+1,  XL    
  std   z+2,  XH    ; Update Counter
  rjmp L_krSetTimer_ret   ; Exit
  ;> ID_Task match AL
  
 L_krSetTimer_NoEmpty:
    adiw  ZL, 3
    dec Counter     ;
    brne L_krSetTimer_EmptyLoop; Loop
  ;> Search in queue Empty Timer
  
  rcall krError


 L_krSetTimer_ret:
  out   SREG, SREG_ ; leave Critical Section
  ;> critical section
 
  pop SREG_
  pop Counter
  pop AH
  mPOPw   Z
  ret
#undef  SREG_
#undef  Counter
ENDP krSetTimer

;###############################################################################
;###############################################################################

;###############################################################################
; AL - Timer ID_Task
PROC krClrTimer
#define SREG_ r19
#define Counter r18
  mPUSHw  Z
  push AH
  push Counter
  push SREG_
  

  LDW   Z,    (TimersPool)
  ldi Counter, TIMERSPOOLSIZE
  ; Поиск в очереди таймеров таймера с текущим заданием ID_Task
  
  ;< critical section
  in    SREG_,  SREG  ; Critical Section
  cli
  
 L_krClrTimer_Loop:
  ld AH, z      ; Value / Counter
  cp AH, AL   ; Search for Event
  brne lClrTimer_NE

  std   z+1,  ZERO    ; Critical Section
  std   z+2,  ZERO    ; Update Counter
  ldi   AH,   0xFF
  st    z,    AH  ;Запишем маркер отключения таймера
  rjmp  lClrTimer_Exit

 lClrTimer_NE:
  adiw  ZL, 3

  dec Counter     ;
  brne L_krClrTimer_Loop     ; Loop

 lClrTimer_Exit:
 
  out   SREG, SREG_ ; leave Critical Section
  ;> critical section
  
  pop SREG_
  pop Counter
  pop AH
  mPOPw   Z
  ret
#undef  SREG_
#undef  Counter
ENDP krClrTimer


;###############################################################################
;###############################################################################
;################################## FUNCTION ###################################
;Name of function:
 ; krMemFill
;Input:
 ; AL - byte for filling
 ; AH - size of filling block
 ; y  - RAM pointer. The address of the beginning of the block of filling
;Return:
 ; -
;Description:
 ; Fills the block of memory in the specified byte
;


PROC krMemFill
; ldi   AH, LCDBUFFSIZE
; ldi   AL, ' '
; LDW   Y,(v_LCDBuf)
  push  AH
   st   y+,   AL
   dec    AH
  brne  (pc)-1-1
  pop   AH
  ret
ENDP krMemFill

;################################## FUNCTION ###################################
;Name of function:
 ; krMemCopyR2R
;Input:
 ; AL - size the block of memory for copy 
 ; Z  - RAM pointer. The address of the beginning of the block of copying
 ; y  - RAM pointer. Destination address
;Return:
 ; -
;Description:
 ; Copying the specified size the block of memory from RAM into RAM
;
PROC krMemCopyR2R
  push  AH
  push  AL
  ;
    ld  AH  ,z+
    st  y+  ,AH
    dec AL
  brne (pc)-1-1-1
  pop   AL
  pop   AH
  ret
ENDP krMemCopyR2R

;################################## FUNCTION ###################################
;Name of function:
 ; krMemCopyF2R
;Input:
 ; AL - size the block of memory for copy 
 ; Z  - FLASH pointer. The address of the beginning of the block of copying
 ; y  - RAM pointer. Destination address
;Return:
 ; -
;Description:
 ; Copying the specified size the block of memory from FLASH into RAM
;
PROC krMemCopyF2R
  push  AH
  push  AL
  ;
    lpm   AH, z+
    st    y+,   AH
    dec   AL
  brne (pc)-1-1-1
  pop   AL
  pop   AH
  ret
ENDP krMemCopyF2R

;###############################################################################

;PROC fTimerService
; mTimerService
; ret
;ENDP fTimerService

PROC krRand
  ;< MUL RND,17
  mov AL, r_RND ; x1
  lsl AL    ; x2
  lsl AL    ; x4
  lsl AL    ; x8
  lsl AL    ; x16
  add AL, r_RND ; x(16+1) = 0b00010001
  ;> MUL RND,17
  subi AL, -53  ; -(-53) = +53
  mov r_RND,AL  ; RND = (RNDi * 17 + 53) {MOD 256}
  ret
ENDP krRand
;
#include  "RTOSA/Debug.asm" ;

.exit

;S_Alex
