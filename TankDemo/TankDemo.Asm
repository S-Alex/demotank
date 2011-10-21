;File TankDemo.asm
;Updated: "2011-03-07" "19:41"

;###############################################################################
#pragma warning range byte overflow
#pragma overlap error
;###############################################################################

;.equ DEBUG   = 1

; ! ! ! ! ! ! ! ! ! !! ВНИМАНИЕ ! ! ATTENTION !  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
; ! ! ! ! ! ! ! ! ! !! ВНИМАНИЕ ! ! ATTENTION !  ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !
;4,OT,"$b\avrasm2143" -fI -vs -v2 -I"$I" -c -o"$3" -l"$4" -d"$2" -e"$5" -m"$7" -FD"%Y-%m-%d" -FT"%H:%M" ,1
; !!! avrasm2143 - установить совместимость с Windows 98
; !!! avrasm2143 - поменять на другую если выдает ошибки потери определений
; Искать тут
;   \RadASM\AVR\Bin\avrasm2143.exe
; Например: YH - определена, но ... что за ф..ня ?!?!?!?
;   MacroEX.asm(22): error: Invalid symbol in this context: YH(11)

; ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! ! !

;###############################################################################
  #message "+--------------------+"
#ifndef DBG
  #message "|  Info: Release...  |"
#else
  #message "| Info: Debugging... |"
  .equ  DEBUG = 1
#endif
  #message "+--------------------+"
;###############################################################################


;###############################################################################
  #message "+-------------"
  #message "| TIME FORMAT:" __DATE__ __TIME__
  #message "+----------------"
;###############################################################################

.equ  PROTEUS   = 1

;###############################################################################

;###############################################################################
;######################### Include Files #######################################
;###############################################################################
.include  "TankDemo.inc"  ;
.include  "IntVector.inc"   ;Include  IVT

;< Rights
szAllRights:
.db "Device:",'"',"-=TankDemo v0.1=-",'"',13,10
.db "Assembly by S_Alex",13,10
.db __TIME__,' ',__DATE__,13,10,0,0
;> Rights
.include  "Delays.asm"

.include  "Interrupt.inc" ;

.include  "IntRoutines.asm" ;

;RESET:
;   mDelay_Us (exp2(8)*3)+4
;.exit

.include  "RTOSA/RTOSA.inc"
;.include "RTOSA/TimerCntrs.inc"
.include  "ADC.inc" ;
.include  "KBD_3x1.inc" ;
.include  "NCod.inc"  ;
.include  "Drive.asm" ;
.include  "LCD_uni.inc" ;
.include  "Soft_RTC.inc" ;

  .dseg
  .nolist
  alignD $10
    v_InfoBuf:
    v_InfoBuf1: .byte LCDBUFFSIZE/2
    v_InfoBuf2: .byte LCDBUFFSIZE/2
  .cseg
  .listmac


;###############################################################################
.list
.listmac
;###############################################################################
;############################## Code ###########################################
;###############################################################################
;< Список адресов задач
TaskProcs:  ; !!! Имя метки должно быть неизменным !!! Используется в макросе
  Task(Idle)  ;Always 1st   ;0
  Task(f1sec)               ;1
  Task(fReklama)            ;2
  Task(fDrvOnLeft)          ;3
  Task(fDrvOnRight)         ;4
  Task(fENGet)              ;5
  Task(fGNDMinMax)          ;6
  Task(fGNDGetMidLevel)     ;7
  Task(fMelodyPlay)         ;8
  Task(fInit_FM_LS)         ;9
  Task(fShowSensorsState)   ;10
  Task(fSetLineFlg)         ;11
  Task(fRefreshLCD)         ;12
  Task(fIRTimeOut)          ;13
  Task(fIR_Command)         ;14
  Task(fAdjustAtMonet)      ;15
  Task(fDrvStop)            ;16
  Task(fEvent)              ;17
  Task(fMoveEX)             ;18
  Task(fFinish)             ;19
  Task(fDrvStopL)           ;20
  Task(fDrvStopR)           ;21
  Task(fRL_90)              ;22
  Task(fRR_90)              ;23
  Task(fRR_360_2)           ;24
  Task(fSearch_Finish)      ;25
  Task(fGo_Finish)          ;26
  Task(fScanMonet)          ;27
  Task(fSearchMove)         ;28
  Task(fRotate)             ;29
  Task(fGoGoGo)             ;30
  Task(fSearchLampLR)       ;31
  Task(fCoverMonet)         ;32
  Task(fMelodyMoneta)       ;33
  Task(fInfoSets)           ;34
  Task(fDrvStopAtFinish_L)  ;35
  Task(fDrvStopAtFinish_R)  ;36
  Task(fBeginShow)          ;37
  Task(fInitAllSensor)      ;38
  Task(fMenuInfo)           ;39
  Task(fOutLine)            ;40
  Task(fkrSetEvent)         ;41
  Task(fFlashLed)           ;42
  Task(fLCDLightOff)        ;42
  Task(fChengeLampLR)       ;43

; Task(fServoInc)
; Task(fServoLR)


;> Список адресов задач
;###############################################################################

;< ##################### Initialization Code ###################################
RESET:
;< Config Pin for Proteus debug
.if PROTEUS
  mPinOut Stop
.endif
;> Config Pin for Proteus debug


  SetStack (RAMEND)
  clr   ZERO
  mAllRegZero
  mMemFill SRAM_START,RAMEND,0x00

  mINIT_RTOSA


;###############################################################################


  ;< Init LED
    mPinOut LedRed
    mPinOut LedGrn
    mPinCLR LedRed
    mPinSET LedGrn
  ;> Init LED

  ;< Отключим подсветку LCD
    rcall fLCDLightOff
  ;> Отключим подсветку LCD

  rcall fLCDInit

;  mSetTimerTask f1sec              ,1 ;1
;  mSetTimerTask fReklama           ,1 ;2
;  mSetTimerTask fDrvOnLeft         ,1 ;3
;  mSetTimerTask fDrvOnRight        ,1 ;4
;  mSetTimerTask fENGet             ,1 ;5
;  mSetTimerTask fGNDMinMax         ,1 ;6
;  mSetTimerTask fGNDGetMidLevel    ,1 ;7
;  mSetTimerTask fMelodyPlay        ,1 ;8
;  mSetTimerTask fInit_FM_LS        ,1 ;9
;  mSetTimerTask fShowSensorsState  ,1 ;10
;  mSetTimerTask fSetLineFlg        ,1 ;11
;  mSetTimerTask fRefreshLCD        ,1 ;12
;  mSetTimerTask fIRTimeOut         ,1 ;13
;  mSetTimerTask fIR_Command        ,1 ;14
;  mSetTimerTask fAdjustAtMonet     ,1 ;15
;  mSetTimerTask fDrvStop           ,1 ;16

  rcall fFlashLed

; rcall fReklama
  rcall fBuzerInit
  rcall fIRInit
  rcall fIR_Command

  rcall fLSInit
  rcall fFM_Init

; rcall fBampInit ;

  rcall fServoInit
  rcall fDrvInit

  rcall fNCodInit


  rcall fRefreshLCD
  rcall fEvent_CLR ; очистка всех событий
  ldi   AL, DispControl|DisplayON|CursorOFF|CursorNoFlash
  sts   (v_LCDCtrl),  AL


  ;< For InitAllSensor
    mFlgClr flg_AnyKey ; show page1 or page2
    clr     rvInitFlag
  ;> For InitAllSensor

;

;
    rcall fKBDScan
  ;< Push button "SB2" for EmuInit !"СБРОС НАСТРОЕК"!
    sbrc  AL, SB2
     rcall fEmuInit ;
    sbrc  AL, SB2
     rjmp L_End_Init ;
  ;> Push button "SB2" for EmuInit

  ;< Push button "SB3" for fInitAllSensor !"МЕНЮ"!
    sbrc  AL, SB3
     rcall fInitAllSensor ;
    sbrc  AL, SB3
     rcall fMenuInfo ;
    sbrc  AL, SB3
     rjmp L_End_Init ;
  ;> Push button "SB3" for fInitAllSensor

     rcall fBeginShow ;

L_End_Init:
  sei

;> ##################### Initialization Code ###################################

;> ########################### Main Code #######################################
PROC  MainLoop
  rcall krProcessTaskQueue  ;Обработка очереди задач
  rjmp  MainLoop
ENDP MainLoop
;> ########################## Main Code ########################################

PROC Idle
  ret
ENDP Idle

PROC f1sec
	rcall fRTC_Inc		      ;
	mSetTimerTask f1sec,1s  ;
	ret
ENDP f1sec

PROC fFlashLed
  mPinCpl LedGrn
	mSetTimerTask fFlashLed,510ms
  ret
ENDP fFlashLed

PROC fMenuInfo
  push  AL
    LDW   Z   ,(sz_ButtonLSFM_1<<1)
  mIfFlgCLR flg_AnyKey,rjmp L_fMenuInfo_1
    LDW   Z   ,(sz_ButtonLSFM_2<<1)

 L_fMenuInfo_1:
    LDW   Y   ,(v_InfoBuf)
    ldi   AL  ,LCDBUFFSIZE
    rcall krMemCopyF2R
  mSetTimerTask fMenuInfo,1800ms
  pop   AL

  tst   rvInitFlag
  brne  (pc+1)+1
    ret
  mFlgCpl flg_AnyKey
  ret
ENDP fMenuInfo

PROC fInitAllSensor
  push  AL

  mSetTimerTask fInitAllSensor,300ms

  LDW   Z   ,(v_InfoBuf)
  LDW   Y   ,(v_LCDBuf)
  ldi   AL  ,LCDBUFFSIZE
  rcall krMemCopyR2R

  rcall fKBDScan
  ;< Push button "SB2" for fInit_FM_LS
    sbrc  AL, SB2
      rcall fInit_FM_LS ;
  ;> Push button "SB2" for fInit_FM_LS

  ;< Push button "SB4" for fGNDDetect
    sbrc  AL, SB4
      rcall fGNDDetect ;
  ;> Push button "SB4" for fGNDDetect

  tst   rvInitFlag

  breq L_fInitAllSensor
    ;< Push button "SB3" for fBeginShow
      sbrc  AL, SB3
        rcall fBeginShow ;
    ;> Push button "SB3" for fBeginShow
 L_fInitAllSensor:

  pop   AL
  ret

ENDP fInitAllSensor



PROC fEmuInit

  push  AL
  ;< Emu fGNDDetect
    ;< Sets v_GNDMin value
      ldi   AL      ,GNDMIN ;
      LDW   Y       ,(v_GNDMin)
      ldi   AH      ,4
      ;< loop
        st    y+    ,AL
        dec   AH
      brne (pc)-1-1
      ;> Loop
    ;> Sets v_GNDMin value

    ;< Sets v_GNDMax value
      ldi   AL      ,255
      ldi   AH      ,4
      ;< loop
        st    y+    ,AL
        dec   AH
      brne (pc)-1-1
      ;> Loop
    ;> Sets v_GNDMax value

  ;> Emu fGNDDetect

  rcall fSaveGNDSensorLevel

  LDW   Y          ,(TMONET)
  sts   (v_FMMidL) ,YL
  sts   (v_FMMidH) ,YH

  LDW   Y          ,(2000000/FLAMP)
  sts   (v_LSMidL) ,YL
  sts   (v_LSMidH) ,YH

  rcall fSaveFMLSSensorLevel
  mSendTask fBeginShow ;

  pop   AL
  ret

ENDP fEmuInit

PROC fBeginShow
  rcall fGNDInit
  mClrTimer fInitAllSensor; отключает сенсоры
  mClrTimer fMenuInfo; отключает меню

  rcall fReadFMLSSensorLevel ; читают настройки из памяти
  rcall fReadGNDSensorLevel

  rcall fEvent_CLR ; очишаются все задачи
  rcall fEvent ; запуск диспетчера событий


  ;< v_CntMonet = 5
    ldi AL          ,1 ; стави счетчик на 5 монет
    sts (v_CntMonet),AL
  ;> v_CntMonet = 5

  ;< Sets fGoGoGo on the "Lamp" event
    mFlgClr flg_Lamp; очищаем флаг лампы
    ldi AL    ,GetTaskID(fGoGoGo)
    ldi AH    ,GetEventID(v_Event,Lamp)
    rcall fSendEvent
  ;> Sets fGoGoGo on the "Lamp" event


  mSendTask fInfoSets; вывод настроек на экран

  ;< Clear all FLAGS
    clr r_Flags
    clr r_FlagsH
  ;> Clear all FLAGS


  ret

ENDP fBeginShow


PROC fGoGoGo
  mClrTimer fInfoSets

  mSetTimerTask fSearch_Finish,(TIMEOUT)s
  ;< Run  RTC
    mRTC_Init
    rcall f1sec
  ;> Run  RTC

  mSendTask fShowSensorsState

  ;< Clear Lamp event
    sts   (v_Event_Lamp),ZERO ;Idle
  ;> Clear Lamp event

  ldi   rvSpeedLR   ,0x66

  ;< Lamp on the Right
    mFlgClr  flg_LS_LR    ; 1 - Left; 0 - Right
  ;> Lamp on the Right

  ;< Searching a lamp on the left or right side
    mSetTimerTask fSearchLampLR,  1000ms
  ;> Searching a lamp on the left or right side

  ret

ENDP fGoGoGo



PROC fSearchLampLR

  rcall fDrvStop

  ;< Clear Lamp event
    sts   (v_Event_Lamp),ZERO ;Idle
  ;> Clear Lamp event

  ;< Stop servo scan
    mClrTimer    fScanMonet; скинирует монеты
  ;> Stop servo scan

  ;< v_CntMonet check at the mission complete
    lds AL            ,(v_CntMonet)
    tst AL
    brne (pc+1)+1+1
      rcall fSearch_Finish
      ret
  ;> v_CntMonet check at the mission complete

  
  ;< Lamp on the right
    mFlgSkipSet  flg_LS_LR    ; 1 - Left; 0 - Right
      ldi   rvIndxServo   ,9 ;Sets the Servo into right Max position
  ;> Lamp on the right

  ;< Lamp on the left
    mFlgSkipClr  flg_LS_LR    ; 1 - Left; 0 - Right
      ldi   rvIndxServo   ,10 ;Sets the Servo into left Max position
  ;> Lamp on the left


  ;< Sets fChengeLampLR on the "Lamp" event
    mFlgClr flg_Lamp
    ldi AL    ,GetTaskID(fSearchMove)
    ldi AH    ,GetEventID(v_Event,Lamp)
    rcall fSendEvent
  ;> Sets fChengeLampLR on the "Lamp" event

  ;< Sets fSearchLampLR on the "EndMov" event
    ldi AL              ,GetTaskID(fSearchLampLR)
    sts (v_Event_EndMov),AL
  ;> Sets fSearchLampLR on the "EndMov" event


  LDW   Y     ,(ct_Rotate2R<<1)
  mIfFlgSET flg_LS_LR, rjmp L_fSearchLampLR_Skip
    LDW   Y     ,(ct_Rotate2L<<1)
 L_fSearchLampLR_Skip:  
  rcall fMoveEX_Run

  ret

ENDP fSearchLampLR

; ldi AL    ,GetTaskID(fSearchMove)
; ldi AH    ,GetEventID(v_Event,Lamp)
; rcall fSendEvent
PROC fSendEvent
  mov rvIDEvent ,AH
  mov rvIDTask  ,AL
  mSetTimerTask fkrSetEvent,400ms
  ret
ENDP fSendEvent


PROC fkrSetEvent
.ifdef	PROTEUS
  	mStop
  .endif
    LDW   Y       ,(v_Event)
  add   YL      ,rvIDEvent
  adc   YH      ,ZERO
  st    y       ,rvIDTask
  ret
ENDP fkrSetEvent


PROC fEvent_CLR
  ;< Idle for all events
  sts (v_Event_LFL)   ,ZERO ; LINE FRONT-L
  sts (v_Event_LRL)   ,ZERO ; LINE REAR-L
  sts (v_Event_LFR)   ,ZERO ; LINE FRONT-R
  sts (v_Event_LRR)   ,ZERO ; LINE REAR-R
  sts (v_Event_BampF) ,ZERO ; Препятствие спереди
  sts (v_Event_BampR) ,ZERO ; Препятствие сзади
  sts (v_Event_Lamp)  ,ZERO ;
  sts (v_Event_Monet) ,ZERO ;
  sts (v_Event_EndMov),ZERO ; Task at THE END of current MOVE LIST
  sts (v_Event_Melody),ZERO ; Task at THE END of current MELODY
  ;> Idle for all events

  ldi AL              ,GetTaskID(fDrvStopR)
  sts (v_Event_StepR) ,AL  ;
  ldi AL              ,GetTaskID(fDrvStopL)
  sts (v_Event_StepL) ,AL  ;
  ret

ENDP fEvent_CLR

PROC fEvent
  push  AL

  mFlgSkipClr flg_ADC ;Converting complete. For all ADC canals
    rcall fSetLineFlg

  ;< Check event "LINE xxx"

    ;< Check event "LINE FRONT-L"
      lds AL      ,(v_Event_LFL)
;      tst AL
;      breq (pc+1)+4
        mSendTaskIfSETC_AL flg_LFL
    ;> Check event "LINE FRONT-L"

    ;< Check event "LINE REAR-L"
      lds AL      ,(v_Event_LRL)
;      tst AL
;      breq (pc+1)+4
        mSendTaskIfSETC_AL flg_LRL
    ;> Check event "LINE REAR-L"

    ;< Checking event "LINE FRONT-R"
      lds AL      ,(v_Event_LFR)
;      tst AL
;      breq (pc+1)+4
        mSendTaskIfSETC_AL flg_LFR
    ;> Checking event "LINE FRONT-R"

    ;< Check event "LINE REAR-R"
      lds AL      ,(v_Event_LRR)
;      tst AL
;      breq (pc+1)+4
        mSendTaskIfSETC_AL flg_LRR
    ;> Check event "LINE REAR-R"

  ;> Check event "LINE xxx"

;  ;< Check event "BampF"
;    lds AL      ,(v_Event_BampF)
;    tst AL
;    breq (pc+1)+4
;      mSendTaskIfSETC_AL flg_BampF  ; 4b
;  ;> Check event "BampF"

;  ;< Check event "BampR"
;    lds AL      ,(v_Event_BampR)
;    tst AL
;    breq (pc+1)+4
;      mSendTaskIfSETC_AL flg_BampR
;  ;> Check event "BampR"

  ;< Check event "Lamp"
    lds AL      ,(v_Event_Lamp)
;    tst AL
;    breq (pc+1)+4
      mSendTaskIfSETC_AL flg_Lamp
  ;> Check event "Lamp"

  ;< Check event "Monet"
  lds AL      ,(v_Event_Monet)
;    tst AL
;    breq (pc+1)+4
    mSendTaskIfSETC_AL flg_Monet
  ;> Check event "Monet"

  mSetTimerTask fEvent,50ms

  pop AL
  ret

ENDP fEvent

PROC fCalcMid_FM_LS
  ;< v_FMMid = (v_FMMid + v_FMCur)/2
  lds   AL        ,(v_FMMidL)
  lds   AH        ,(v_FMCurL)
  add   AL        ,AH
  push  AL
  lds   AL        ,(v_FMCurH)
  lds   AH        ,(v_FMMidH)
  adc   AH        ,AL
  ror   AH
  pop   AL
  ror   AL
  sts   (v_FMMidL),AL
  sts   (v_FMMidH),AH
  ;> v_FMMid = (v_FMMid + v_FMCur)/2

   ;< v_LSMid = (v_LSMid + v_LSCur)/2
  lds   AL        ,(v_LSCurL)
  lds   AH        ,(v_LSMidL)
  add   AL        ,AH

  push  AL
  lds   AH        ,(v_LSCurH)
  lds   AL        ,(v_LSMidH)
  adc   AH        ,AL
  ror   AH

  pop   AL
  ror   AL

  sts   (v_LSMidL),AL
  sts   (v_LSMidH),AH
  ;> v_LSMid = (v_LSMid + v_LSCur)/2

  ret
ENDP fCalcMid_FM_LS

PROC fInit_FM_LS
  push  AL

  mClrTimer fInitAllSensor

  inc   rvInitFlag

  rcall fCalcMid_FM_LS

  mLCDBuffCLR (v_LCDBuf)


  LDW Y   ,(v_LCDBuf1)
  ldi AL  ,'L'
  st  y+  ,AL
  ldi AL  ,'S'
  st  y+  ,AL
  ldi AL  ,':'
  st  y+  ,AL

  LDW Y   ,(v_LCDBuf+3)
  lds AL  ,(v_LSMidL)
  lds AH  ,(v_LSMidH)
  rcall fw2a

  LDW Y   ,(v_LCDBuf2)
  lds AL  ,(v_FMMidL)
  lds AH  ,(v_FMMidH)
  rcall fw2a


  LDW Y   ,(v_LCDBuf2+4)
  ldi AL  ,'S'
  st  y+  ,AL
  ldi AL  ,'B'
  st  y+  ,AL
  ldi AL  ,'4'
  st  y+  ,AL
  ldi AL  ,126
  st  y+  ,AL


  rcall fKBDScan
  sbrc  AL, SB4
    rjmp L_Init_FM_LS_exit ;If Push key "SB4"

  mSetTimerTask fInit_FM_LS,(110ms)
  rjmp L_Init_FM_LS_ret

 L_Init_FM_LS_exit:
  rcall fSaveFMLSSensorLevel
  LDW   Z   ,(sz_Init_FM_LS_OK<<1)
  LDW   Y   ,(v_LCDBuf)
  ldi   AL  ,LCDBUFFSIZE
  rcall krMemCopyF2R
  mSetTimerTask fInitAllSensor,3s

 L_Init_FM_LS_ret:
  pop   AL
  ret

ENDP fInit_FM_LS

PROC fSaveFMLSSensorLevel
  ;< Save FM to EEPROM
  LDW   Y   ,(e_FMMid)
  LDW   X   ,(v_FMMid)
  ldi   AH  ,2
  ;                  ;-<--------+
    ld  AL  ,x+      ;          |
    rcall fEEWrite   ;          |
    adiw  YL, 1      ;          |
    dec AH           ;          |
  brne (pc)-1-1-1-1  ;--------->+
  ;> Save FM to EEPROM

  ;< Save LS to EEPROM
  LDW   Y   ,(e_LSMid)
  LDW   X   ,(v_LSMid)
  ldi   AH  ,2
  ;                  ;-<--------+
    ld  AL  ,x+      ;          |
    rcall fEEWrite   ;          |
    adiw  YL, 1      ;          |
    dec AH           ;          |
  brne (pc)-1-1-1-1  ;--------->+
  ;> Save LS to EEPROM
  ret
ENDP fSaveFMLSSensorLevel

PROC fSaveGNDSensorLevel
  LDW   Y   ,(e_GNDMin)
  LDW   X   ,(v_GNDMin)
  ldi   AH  ,8
  ;                  ;-<--------+
    ld  AL  ,x+      ;          |
    rcall fEEWrite   ;          |
    adiw  YL, 1      ;          |
    dec AH           ;          |
  brne (pc)-1-1-1-1  ;--------->+
  ret
ENDP fSaveGNDSensorLevel

PROC fReadFMLSSensorLevel
  ;< Read FM from EEPROM
  LDW   Y   ,(e_FMMid)
  LDW   X   ,(v_FMMid)
  ldi   AH  ,2
  ;                  ;-<--------+
    rcall fEERead    ;          |
    st    x+  ,AL    ;          |
    adiw  YL  ,1     ;          |
    dec AH           ;          |
  brne (pc)-1-1-1-1  ;--------->+
  ;> Read FM from EEPROM

  ;< Read LS from EEPROM
  LDW   Y   ,(e_LSMid)
  LDW   X   ,(v_LSMid)
  ldi   AH  ,2
  ;                  ;-<--------+
    rcall fEERead    ;          |
    st    x+  ,AL    ;          |
    adiw  YL  ,1     ;          |
    dec AH           ;          |
  brne (pc)-1-1-1-1  ;--------->+
  ;> Read LS from EEPROM
  ret
ENDP fReadFMLSSensorLevel

PROC fReadGNDSensorLevel
  LDW   Y   ,(e_GNDMin)
  LDW   X   ,(v_GNDMin)
  ldi   AH  ,8
  ;                  ;-<--------+
    rcall fEERead    ;          |
    st    x+  ,AL    ;          |
    adiw  YL  ,1     ;          |
    dec AH           ;          |
  brne (pc)-1-1-1-1  ;--------->+
  ret
ENDP fReadGNDSensorLevel

PROC fCoverMonet


  ;< Sets fRotate on the "Melody" event
    ldi   AL              ,GetTaskID(fRotate)
    sts   (v_Event_Melody),AL
  ;> Sets fRotate on the "Melody" event

  ;< Sets fCoverMonet on the "EndMov" event
    ldi   AL              ,GetTaskID(fMelodyMoneta)
    sts   (v_Event_EndMov),AL
  ;> Sets fCoverMonet on the "EndMov" event
  LDW   Y ,(ct_MoveCover<<1)
  rcall fMoveEX_Run

  ret

ENDP fCoverMonet

PROC fAdjustAtMonet
  mClrTimer    fScanMonet

  ;< Clear "Monet" event
    sts   (v_Event_Monet),ZERO ;Idle
  ;> Clear "Monet" event

  ;< Clear "Lamp" event
    sts   (v_Event_Lamp),ZERO ;Idle
  ;> Clear "Lamp" event

  rcall fDrvStop

  ;< Clear "LINE FRONT-L" and "LINE FRONT-R" event
    sts   (v_Event_LFL) ,ZERO ;Idle
    sts   (v_Event_LFR) ,ZERO ;Idle
  ;> Clear "LINE FRONT-L" and "LINE FRONT-R" event

    ;< Sets Y at the ROTATE MOVE LIST for current sector
      mov   AL              ,rvIndxServo
      mFlgSkipClr           flg_ServoDir  ; ---if set--+ ;1"+";0"-"
        swap  AL                          ;            |
      andi  AL              ,0b00000111   ; <----------+
      LDW   Z               ,(ct_List_Sec)
      add   ZL              ,AL
      adc   ZH              ,ZERO
      lsl   ZL
      rol   ZH
      lpm   YL              ,z+
      lpm   YH              ,z
    ;> Sets Y at the ROTATE MOVE LIST for current sector

  ;< Sets fCoverMonet on the "EndMov" event
    ldi   AL              ,GetTaskID(fCoverMonet)
    sts   (v_Event_EndMov),AL
  ;> Sets fCoverMonet on the "EndMov" event
  rcall fMoveEX_Run ; Y = MoveList


  ;< Sets Servo into the starting position
    mFlgSkipSet   flg_ServoDir
      ldi rvIndxServo     ,0x77
    mFlgSkipClr   flg_ServoDir
      ldi rvIndxServo     ,0x00
  ;> Sets Servo into the starting position

  ret

ENDP fAdjustAtMonet

PROC fOutLine
  ;< Stop servo scan
    mClrTimer    fScanMonet
  ;> Stop servo scan

  rcall fDrvStop

  ;< Clear "LINE FRONT-L" and "LINE FRONT-R" event
    sts   (v_Event_LFL) ,ZERO ;Idle
    sts   (v_Event_LFR) ,ZERO ;Idle
  ;> Clear "LINE FRONT-L" and "LINE FRONT-R" event

  ;< Find out line. Move list
    ;< Lamp on the left
      mIfFlgCLR flg_LS_LR,rjmp L_fOutLine1    ; 1 - Left; 0 - Right
         LDW   Y  ,(ct_OutLineMoveL<<1)
    ;> Lamp on the left
  L_fOutLine1:
  
    ;< Lamp on the right
      mIfFlgSET flg_LS_LR,rjmp L_fOutLine2    ; 1 - Left; 0 - Right
         LDW   Y  ,(ct_OutLineMoveR<<1)
    ;> Lamp on the right
    L_fOutLine2:
  ;> Find out line. Move list

  ;< Toggle the Lamp side
    mFlgCpl  flg_LS_LR    ; 1 - Left <=> 0 - Right
  ;> Toggle the Lamp side


  ;< Sets fSearchLampLR on the "EndMov" event
    ldi   AL              ,GetTaskID(fSearchLampLR)
    sts   (v_Event_EndMov),AL
  ;> Sets fSearchLampLR on the "EndMov" event
  rcall fMoveEX_Run ; Y = MoveList

  ret

ENDP fOutLine


PROC fChengeLampLR
;  ;< Toggle the Lamp side
;    mFlgCpl  flg_LS_LR    ; 1 - Left <=> 0 - Right
;  ;> Toggle the Lamp side
;  mSendTask fSearchLampLR
  ret

ENDP fChengeLampLR

PROC fSearchMove

  mSendTask fScanMonet

;  ;< Отключим подсветку LCD
;    rcall fLCDLightOff
;  ;> Отключим подсветку LCD

  ;< Clear Lamp event
    sts (v_Event_Lamp),ZERO ;Idle
  ;> Clear Lamp event


  ;< Sets fAdjustAtMonet on the "Monet" event
    mFlgClr flg_Monet
    ldi AL             ,GetTaskID(fAdjustAtMonet)
    sts (v_Event_Monet),AL
  ;> Sets fAdjustAtMonet on the "Monet" event

  ;< Sets fOutLine on the "LINE FRONT-L" event
    mFlgClr flg_LFL
    ldi AL           ,GetTaskID(fOutLine)
    sts (v_Event_LFL),AL
  ;> Sets fOutLine on the "LINE FRONT-L" event

  ;< Sets fOutLine on the "LINE FRONT-R" event
    mFlgClr flg_LFR
    ;ldi   AL           ,GetTaskID(fOutLine)
    sts (v_Event_LFR),AL
  ;> Sets fOutLine on the "LINE FRONT-R" event

  ;< After "Search Move" Send Task "fScanMonet"
    ldi AL              ,GetTaskID(fScanMonet)
    sts (v_Event_EndMov),AL
  ;> After "Search Move" Send Task "fScanMonet"

  ;< Search move list
    LDW   Y             ,(ct_SearchMove<<1)
    rcall fMoveEX_Run ; Y = MoveList
  ;> Search move list



  ret
ENDP fSearchMove

PROC fScanMonet

  mov   AL            ,rvIndxServo
  swap  AL
  andi  rvIndxServo   ,0b00001111
  andi  AL            ,0b11110000

  ;< Inc/Dec rvIndxServo
  inc   rvIndxServo
  mFlgSkipSet flg_ServoDir  ;--if set---+ ;0"+";1"-"
    subi  rvIndxServo,2     ;           |
                       ; <--------------+
  ;> Inc/Dec rvIndxServo
  mov   AH            ,rvIndxServo
  andi  rvIndxServo   ,0b00000111       ;1b
  or    rvIndxServo   ,AL

  andi  AH, 0b00001000
  breq LfScanMonet_Cont
  ;< установить махало на начало движения
    mFlgSkipSet   flg_ServoDir
      ldi rvIndxServo     ,0x00
    mFlgSkipClr   flg_ServoDir
      ldi rvIndxServo     ,0x77
  ;> установить махало на начало движения
  mFlgCpl flg_ServoDir                  ;4b
  mSetTimerTask fSearchMove,50ms
  ret
 LfScanMonet_Cont:

  mSetTimerTask fScanMonet,50ms

  ret

ENDP fScanMonet

PROC fRotate


  ;< Включим подсветку LCD
    rcall fLCDLightOn
    mSetTimerTask fLCDLightOff,150ms
  ;> Включим подсветку LCD


  ;< Clear the "Melody" event
    sts   (v_Event_Melody),ZERO
  ;> Clear the "Melody' event


  ;< Sets fSearchLampLR on the "EndMov" event
    ldi   AL              ,GetTaskID(fSearchLampLR)
    sts   (v_Event_EndMov),AL
  ;> Sets fSearchLampLR on the "EndMov" event
  LDW   Y               ,(ct_Rotate<<1)
  rcall fMoveEX_Run ; Y = MoveList

  ret

ENDP fRotate

PROC fRx_xxx

CPROC fRR_90
  ;<
  LDW   Y               ,(ct_RR_90<<1)
  rjmp fRx_xxx_com
  ;>

CPROC fRL_90
  ;<
  LDW   Y               ,(ct_RL_90<<1)
  rjmp fRx_xxx_com
  ;>

CPROC fRR_360_2
  ;<
  LDW   Y               ,(ct_RR_360_2<<1)

  ;< Clear "EndMov" event
    sts   (v_Event_EndMov),ZERO ;Idle
  ;> Clear "EndMov" event

  rjmp fRx_xxx_com
  ;>

CPROC fRx_xxx_com

  ;< Clear LINE FRONT-L and "LINE FRONT-R" event
    sts   (v_Event_LFL) ,ZERO ;Idle
    sts   (v_Event_LFR) ,ZERO ;Idle
  ;> Clear LINE FRONT-L and "LINE FRONT-R" event

  rcall fMoveEX_Run ; Y = MoveList


  ret

ENDP fRx_xxx

PROC fSearch_Finish
  ;< Stop servo scan
    mClrTimer    fScanMonet
  ;> Stop servo scan

  ;< Clear "LINE FRONT-L" and "LINE FRONT-R" event
    sts   (v_Event_LFL) ,ZERO ;Idle
    sts   (v_Event_LFR) ,ZERO ;Idle
  ;> Clear "LINE FRONT-L" and "LINE FRONT-R" event

  ;< Clear "Monet" event
    sts   (v_Event_Monet),ZERO ;Idle
  ;> Clear "Monet" event


  ;< установить махало в середину
    ldi   rvIndxServo,8
  ;> установить махало в середину

  ;< Sets fGo_Finish on the "Lamp" event
    ldi AL    ,GetTaskID(fGo_Finish)
    ldi AH    ,GetEventID(v_Event,Lamp)
    rcall fSendEvent
  ;> Sets fGo_Finish on the "Lamp" event



  ;< Sets fSearch_Finish on the "EndMov" event
    ldi   AL              ,GetTaskID(fSearch_Finish)
    sts   (v_Event_EndMov),AL
  ;> Sets fSearch_Finish on the "EndMov" event
  LDW   Y                 ,(ct_SearchFinishMove<<1)
  rcall fMoveEX_Run ; Y = MoveList
  
  ret

ENDP fSearch_Finish

PROC fGo_Finish
  ;< Clear "EndMov" event
    sts   (v_Event_EndMov),ZERO ;Idle
  ;> Clear "EndMov" event

 rcall  fDrvStop

  ;< Clear "Lamp" event
    sts   (v_Event_Lamp),ZERO ;Idle
  ;> Clear "Lamp" event

  ;< Clear "StepL" event
    sts   (v_Event_StepL),ZERO ;Idle
    sts   (v_Event_StepR),ZERO ;Idle
  ;> Clear "StepL" event

  ldi rvSpeedLR ,0x77

  ;< Sets fDrvStopAtFinish_L on the "LINE FRONT-L" event
    ldi AL           ,GetTaskID(fDrvStopAtFinish_L)
    sts (v_Event_LFL),AL
  ;> Sets fDrvStopAtFinish_L on the "LINE FRONT-L" event

  ;< Sets fDrvStopAtFinish_R on the "LINE FRONT-R" event
    ldi AL           ,GetTaskID(fDrvStopAtFinish_R)
    sts (v_Event_LFR),AL
  ;> Sets fDrvStopAtFinish_R on the "LINE FRONT-R" event

  ret

ENDP fGo_Finish

PROC fDrvStopAtFinish_L
  andi  rvSpeedLR,0x0F
  ;< Sets fFinish on the "LINE FRONT-R" event
    ldi AL           ,GetTaskID(fFinish)
    sts (v_Event_LFR),AL
  ;> Sets fFinish on the "LINE FRONT-R" event

  ;< Clear "LINE FRONT-L" event
    sts   (v_Event_LFL) ,ZERO ;Idle
  ;> Clear "LINE FRONT-L" event

  ret
ENDP fDrvStopAtFinish_L

PROC fDrvStopAtFinish_R
  andi  rvSpeedLR,0xF0
  ;< Sets fFinish on the "LINE FRONT-L" event
    ldi AL           ,GetTaskID(fFinish)
    sts (v_Event_LFL),AL
  ;> Sets fFinish on the "LINE FRONT-L" event

  ;< Clear "LINE FRONT-R" event
    sts   (v_Event_LFR) ,ZERO ;Idle
  ;> Clear "LINE FRONT-R" event
  ret
ENDP fDrvStopAtFinish_R

PROC fFinish
  mSendTask fDrvStop
  mClrTimer fShowSensorsState
  mClrTimer f1sec

	;< Отображаем время тестирования на LCD
	LDW		Y,	(v_LCDBuf)
	rcall fRTC2Str	;
	;> Отображаем время тестирования на LCD

  ;< Clear LINE FRONT-L and "LINE FRONT-R" event
    sts   (v_Event_LFL) ,ZERO ;Idle
    sts   (v_Event_LFR) ,ZERO ;Idle
  ;> Clear LINE FRONT-L and "LINE FRONT-R" event

  mSetTimerTask fReklama,20s

  ;< Clear "Melody" event
    sts   (v_Event_Melody) ,ZERO ;Idle
  ;> Clear "Melody" event

  rcall fMelodyFinish

  ret

ENDP fFinish


PROC fSetLineFlg
  mFlgClr flg_ADC

  lds AL,           (v_ADC+0)
  sts (v_GNDCur+0), AL
  lds AL,           (v_ADC+1)
  sts (v_GNDCur+1), AL
  lds AL,           (v_ADC+2)
  sts (v_GNDCur+2), AL
  lds AL,           (v_ADC+3)
  sts (v_GNDCur+3), AL
 L_fSetSensorFlg:
  ;< LINE SET_SENSOR_FLGAG
  LDW   Y,  (v_GND) ; Load addr struct v_GND

  ;< LINE FRONT-R
  ldd AH, y+SOI(v_GND,Cur)

  ldd AL, y+SOI(v_GND,Min)
  cp  AH, AL
  brsh (pc+1)+1
    mFlgSet flg_LFR     ; LINE FRONT-R

  ldd AL, y+SOI(v_GND,Max)
  cp  AL, AH
  brsh (pc+1)+1
    mFlgSet flg_LFR     ; LINE FRONT-R
  ;> LINE FRONT-R

  adiw  YL,1

  ;< LINE FRONT-L
  ldd AH, y+SOI(v_GND,Cur)

  ldd AL, y+SOI(v_GND,Min)
  cp  AH, AL
  brsh (pc+1)+1
    mFlgSet flg_LFL     ; LINE FRONT-L

  ldd AL, y+SOI(v_GND,Max)
  cp  AL, AH
  brsh (pc+1)+1
    mFlgSet flg_LFL     ; LINE FRONT-L
  ;> LINE FRONT-L

  adiw  YL,1

  ;< LINE REAR-R
  ldd AH, y+SOI(v_GND,Cur)

  ldd AL, y+SOI(v_GND,Min)
  cp  AH, AL
  brsh (pc+1)+1
    mFlgSet flg_LRR     ; LINE REAR-R

  ldd AL, y+SOI(v_GND,Max)
  cp  AL, AH
  brsh (pc+1)+1
    mFlgSet flg_LRR     ; LINE REAR-R
  ;> LINE REAR-R

  adiw  YL,1

  ;< LINE REAR-L
  ldd AH, y+SOI(v_GND,Cur)

  ldd AL, y+SOI(v_GND,Min)
  cp  AH, AL
  brsh (pc+1)+1
    mFlgSet flg_LRL     ; LINE REAR-L

  ldd AL, y+SOI(v_GND,Max)
  cp  AL, AH
  brsh (pc+1)+1
    mFlgSet flg_LRL     ; LINE REAR-L
  ;> LINE REAR-L

  ;> LINE SET_SENSOR_FLGAG

  rcall fPrintLineInfo

  ret

ENDP fSetLineFlg

PROC fRefreshLCD
  rcall fLCDPrint
  mSetTimerTask fRefreshLCD,290ms
  ret
ENDP fRefreshLCD

;< fGND..oOo..
;###############################################################################
PROC fGNDInit
  rcall fADCInit
  ser   AL
  sts   (v_GNDMin+0), AL
  sts   (v_GNDMin+1), AL
  sts   (v_GNDMin+2), AL
  sts   (v_GNDMin+3), AL
  clr   AL
  sts   (v_GNDMax+0), AL
  sts   (v_GNDMax+1), AL
  sts   (v_GNDMax+2), AL
  sts   (v_GNDMax+3), AL
  ret

ENDP fGNDInit

PROC fGNDDetect

  push  AL

  mClrTimer fInitAllSensor



  LDW   Z               ,(ctGNDMoveList<<1)
  sts   (v_fptrSpeed+0) ,ZL
  sts   (v_fptrSpeed+1) ,ZH

  rcall fGNDInit
  rcall fGNDGetMidLevel
  pop   AL
  ret

ENDP fGNDDetect

PROC fGNDGetMidLevel
  lds   ZL      ,(v_fptrSpeed+0)
  lds   ZH      ,(v_fptrSpeed+1)
  lpm rvSpeedLR ,z+
  tst rvSpeedLR
  brne L_fGNDGML

    inc rvInitFlag

    mClrTimer fGNDMinMax

    rcall fGNDCalcMid
    rcall fSaveGNDSensorLevel

    LDW   Z   ,(sz_Init_GND_OK<<1)
    LDW   Y   ,(v_LCDBuf)
    ldi   AL  ,LCDBUFFSIZE
    rcall krMemCopyF2R
    mSetTimerTask fInitAllSensor,3s


    ret
 L_fGNDGML:
  sts   (v_fptrSpeed+0),ZL
  sts   (v_fptrSpeed+1),ZH
  mSetTimerTask fGNDGetMidLevel,1000ms
  mSendTask fGNDMinMax
  ret


ENDP fGNDGetMidLevel



PROC fGNDMinMax
#define   rTmp CL

  mJmpIfCLR flg_ADC,L_fGNDMinMax_ret ;Converting complete. For all ADC canals
  mFlgClr flg_ADC
  LDW   X   ,(v_ADC)
  LDW   Y   ,(v_GND)

  ldi   rTmp, 4
 L_fGNDMinMax:
    ld  AL, x+

    ;< Find Min
    ldd AH, y+(v_GNDMin-v_GND)
    cp  AL, AH
    brsh (pc+1)+1
      std y+(v_GNDMin-v_GND), AL
    ;> Find Min

    ;< Find Max
    ldd AH, y+(v_GNDMax-v_GND)
    cp  AL, AH
    brlo (pc+1)+1
      std y+(v_GNDMax-v_GND), AL
    ;> Find Max

    adiw  YL,1

    dec   rTmp
  brne L_fGNDMinMax

  rcall fInfoGNDMinMax

 L_fGNDMinMax_ret:

  mSetTimerTask fGNDMinMax, 30ms
  ret
#undef rTmp
ENDP fGNDMinMax

PROC fGNDCalcMid
 #define    rTmp CL

  LDW   Y,  v_GND ; Load addr struct v_GND

  ldi   rTmp, 4
 L_fGNDCalcMid:
    ; MaxLevel = (v_GNDMax - v_GNDMin)/8 + v_GNDMax + 1
    ; MinLevel = v_GNDMin - (v_GNDMax - v_GNDMin)/8 - 1
    ; MinLevel = if( MaxLevel<0, 0, MinLevel )
    ; MaxLevel = if( MaxLevel>255, 255, MaxLevel )

;<  -----------Точность позиционирования-----------------------
    ldd AL, y+SOI(v_GND,Min)
    ldd AH, y+SOI(v_GND,Max)
    add AH, AL                ;(v_GNDMax - v_GNDMin)
    ror AH                    ;(v_GNDMax + v_GNDMin)/2
    lsr AH                    ;(v_GNDMax + v_GNDMin)/2/2-->50%
    lsr AH                    ;(v_GNDMax + v_GNDMin)/2/4-->25%
;   lsr AH                    ;(v_GNDMax + v_GNDMin)/2/8-->12,5%
;>  -----------Точность позиционирования-----------------------


    sub   AL, AH
    brcc (pc+1)+1
      clr AL
    subi  AL, 1
    brcc (pc+1)+1
      clr AL
    std y+SOI(v_GND,Min), AL

    ldd AL, y+SOI(v_GND,Max)
    add AL, AH
    brcc (pc+1)+1
      ser AL
    subi  AL, (-1)
    brcs (pc+1)+1   ;Inverse CARRY logic
      ser AL
    std y+SOI(v_GND,Max), AL

    adiw  YL,1

    dec   rTmp
  brne L_fGNDCalcMid
  ret
 #undef rTmp

ENDP fGNDCalcMid

;###############################################################################
;> fGND..oOo..

;###############################################################################

;< fLS..oOo..
PROC fLSInit
  mPinIn  LightS
  mPinCLR LightS

  mExtIntType INT3,(EXTRIS)
  mFlgClr flg_Lamp
  ret
;< Interrupt
  .set  OldPC = pc
  .org  INT3addr  ;
    rjmp INT_3 ;
  .org  OldPC
;> Interrupt

ENDP fLSInit

;> fLS..oOo..

;###############################################################################


;###############################################################################

;< fBamp..oOo..
PROC fBampState
  mPinState TSOPF
  mFlgLd    flg_BampF
; mPinCpl   BampDir

  ret
ENDP fBampState

PROC fBampInit
  mPinIn  TSOPF ; от датчика переднего бампера  ;INT5
  mPinIn  TSOPR ; от датчика заднего бампера  ;INT6(не используется)

  mPinSET TSOPF ; от датчика переднего бампера  ;INT5
  mPinSET TSOPR ; от датчика заднего бампера  ;INT6(не используется)

; mExtIntType INT5,EXTANY ; BAMP F-TSOP
; mExtIntType INT6,EXTFAL ; BAMP R-TSOP

  ;< Config T2 for TSOP4836
  mInitTC8bit 2,36000
  mPinOut F0
  ;> Config T2 for TSOP4836

  mPinOut BampEN
  mPinSET BampEN

  mPinOut BampDir
  mPinSET BampDir
; mPinCLR BampDir

  ret
;< Interrupt
  .set  OldPC = pc
  .org  INT5addr  ;External Interrupt Request 5
    rjmp INT_5
  .org  INT6addr  ;External Interrupt Request 6
    rjmp INT_6
  .org  OldPC
;> Interrupt

ENDP fBampInit
;> fBamp..oOo..

;###############################################################################

;< fInfo..oOo..

;;----------------+
;    ;|01234567| ;|
; .db "FLx  FRx" ;| max
; .db "RLx  RRx" ;| min
;;----------------+

PROC fInfoGND

    LDW Y     ,(v_LCDBuf)
    lds AL    ,(v_GNDMaxFL)
    mov AH    ,ZERO
    rcall fw2a

    LDW Y     ,(v_LCDBuf2)
    lds AL    ,(v_GNDMaxRL)
    mov AH    ,ZERO
    rcall fw2a

    LDW Y     ,(v_LCDBuf+5)
    lds AL    ,(v_GNDMaxFR)
    mov AH    ,ZERO
    rcall fw2a

    LDW Y     ,(v_LCDBuf2+5)
    lds AL    ,(v_GNDMaxRR)
    mov AH    ,ZERO
    rcall fw2a

  ret
ENDP fInfoGND

PROC fInfoMidLSFM
;Вывод для отладки LS & FM
  rcall fInfoPrintLSFM

  LDW Y   ,(v_LCDBuf+3)
  lds AL  ,(v_LSMidL)
  lds AH  ,(v_LSMidH)
  rcall fw2a

  LDW Y   ,(v_LCDBuf2+3)
  lds AL  ,(v_FMMidL)
  lds AH  ,(v_FMMidH)
  rcall fw2a
  ret
ENDP fInfoMidLSFM

PROC fInfoPrintLSFM
  LDW Y   ,(v_LCDBuf)
  ldi AL  ,'L'
  st  y+  ,AL
  ldi AL  ,'S'
  st  y+  ,AL
  ldi AL  ,':'
  st  y+  ,AL
  LDW Y   ,(v_LCDBuf2)
  ldi AL  ,'F'
  st  y+  ,AL
  ldi AL  ,'M'
  st  y+  ,AL
  ldi AL  ,':'
  st  y+  ,AL

  ret

ENDP fInfoPrintLSFM

PROC fInfoCurLSFM
;Вывод для отладки LS & FM

  rcall fInfoPrintLSFM

  LDW Y   ,(v_LCDBuf+3)
  lds AL  ,(v_LSCurL)
  lds AH  ,(v_LSCurH)
  rcall fw2a

  LDW Y   ,(v_LCDBuf2+3)
  lds AL  ,(v_FMCurL)
  lds AH  ,(v_FMCurH)
  rcall fw2a
  ret
ENDP fInfoCurLSFM


PROC fInfoGNDMinMax
#define   rTmp CL
  push  rTmp
  LDW   X,  (v_GNDMin)
  LDW   Y,  (v_LCDBuf)

  ldi   rTmp, 8
 L_fInfoGNDMinMax:
    ld    AL, x+

    mov   AH, AL
    cbr   AL, 0xF0
    swap  AH
    cbr   AH, 0xF0

    ori   AL, '0'
    ori   AH, '0'

    cpi   AL, '9'+1
    brlo pc+1+1
      subi  AL, -7
    cpi   AH, '9'+1
    brlo pc+1+1
      subi  AH, -7

    st    y+, AH
    st    y+, AL
    dec   rTmp
  brne L_fInfoGNDMinMax
  pop rTmp

#undef rTmp
;;----------------+
;    ;|01234567| ;|
; .db "01020304" ;| min
; .db "01020304" ;| max
;;----------------+
  ret

ENDP fInfoGNDMinMax

PROC fInfoSets
  mLCDBuffCLR (v_LCDBuf)
  mFlgSkipClr flg_AnyKey
    rcall fInfoMidLSFM
  mFlgSkipSet flg_AnyKey
    rcall fInfoGNDMinMax
  mFlgCpl flg_AnyKey
  mSetTimerTask fInfoSets,2500ms
  ret
ENDP fInfoSets


;> fInfo..oOo..

PROC fFM_Init

  mT3SetMode 0,T3Div8,0

  mIn   AL,     ETIMSK
  ori   AL,     (1<<TICIE3)
  mOut  ETIMSK, AL


;< Interrupt
  .set  OldPC = pc
  .org  ICP3addr  ; Timer/Counter3 Capture Event
    rjmp INT_ICP3 ;Timer3 Capture Handler
  .org  OldPC
;> Interrupt

  ret

ENDP fFM_Init



PROC fFMMinMax

    ;< Find Min
    ldd AH, y+(v_GNDMin-v_GND)
    cp  AL, AH
    brsh (pc+1)+1
      std y+(v_GNDMin-v_GND), AL
    ;> Find Min

    ;< Find Max
    ldd AH, y+(v_GNDMax-v_GND)
    cp  AL, AH
    brlo (pc+1)+1
      std y+(v_GNDMax-v_GND), AL
    ;> Find Max

  ret

ENDP fFMMinMax




PROC fReklama
  LDW Z,(ListRekPage<<1)
  rcall krRand
  andi  AL, 0b1111
  brne pc+1+1
  in  r_RND,  TCNT0
  lsl   AL
  add   ZL,   AL
  adc   ZH,   ZERO
  lpm   AL, z+
  lpm   ZH,   z
  mov   ZL,   AL
  rcall fLCDPageZ
  mSetTimerTask fReklama,TReklama
  ret
ENDP fReklama

;--------------------------------------------------------------------------------
;
.include  "EEPROM.ASM"

.include  "RTOSA/RTOSA.asm" ;
.include  "ServoHXT900.inc"
.include  "Melody.asm"
.include  "InfraRedControl.inc"
.include  "BCD_Math.asm"


;--------------------------------------------------------------------------------


;PROC fDebCrawlers
;
;  ;< Вывод для отладки
;    rcall fLCDBuffCLR
;
;    lds AL  ,(v_CrawlerPosL)
;    LDW Y   ,(v_LCDBuf)
;    mov AH  ,ZERO
;    rcall fw2a
;
;    LDW Y   ,(v_LCDBuf2)
;    lds AL  ,(v_CrawlerCurPosL)
;    mov AH  ,ZERO
;    rcall fw2a
;
;    LDW Y   ,(v_LCDBuf+5)
;    lds AL  ,(v_CrawlerPosR)
;    mov AH  ,ZERO
;    rcall fw2a
;
;    LDW Y   ,(v_LCDBuf2+5)
;    lds AL  ,(v_CrawlerCurPosR)
;    mov AH  ,ZERO
;    rcall fw2a
;
;;   rcall fLCDPrint
;  ;>
;
;  ret
;
;ENDP fDebCrawlers



;|01234567| ;|
;"B F  L B" ;|
;"B M  REB" ;|
;------------+

PROC fShowSensorsState
    lds AL, (v_CntMonet)
    ori AL            ,'0'
    sts (v_InfoBuf2+2),AL
    
;    lds   AL  ,(v_ADC+7)
;    ldi   AH  ,39
;    
;cli
;	mul	  BL    ,CL
;	movw	AH:AL    ,r1:r0
;sei
;	
; ; AH:AL - word (int)
; ; Y - SZ
; ; XL - сколько символов выводить
; ; XH - после какого знака десятичная точка 
;  LDWY  (v_InfoBuf2+2)
;  ldi   XL  ,4
;  ldi   XH  ,2
;  rcall fw2aEX

  ;< Ubat bin2hex
      lds   AL  ,(v_ADC+7)
      mov   AH  ,AL
      cbr   AL  ,0xF0
      swap  AH
      cbr   AH  ,0xF0
      ori   AL  ,'0'
      ori   AH  ,'0'
      cpi   AL  ,'9'+1
      brlo (pc+1)+1
        subi  AL, -7
      cpi   AH  ,'9'+1
      brlo (pc+1)+1
        subi  AH, -7
    sts (v_InfoBuf2+4)  ,AH
    sts (v_InfoBuf2+5)  ,AL
  ;> Ubat bin2hex


  ;< Copy page v_InfoBuf into v_LCDBuf
    ldi   AL    ,LCDBUFFSIZE
    LDW   Z     ,(v_InfoBuf)
    LDWY  (v_LCDBuf)
    rcall krMemCopyR2R
  ;> Copy page v_InfoBuf into v_LCDBuf

;--------

  ;< Clear v_InfoBuf
    LDWY  (v_InfoBuf)
    LDW   Z   ,(fLCDBuffCLR)
    icall ;Z
;    mMemFill v_InfoBuf,(v_InfoBuf+LCDBUFFSIZE),' '
  ;> Clear v_InfoBuf

  ldi   AL, 0x81  ; GND = 1
  sts   v_InfoBuf1+0,  AL ; LINE FRONT-L
  sts   v_InfoBuf2+0,  AL ; LINE REAR-L
  sts   v_InfoBuf1+7,  AL ; LINE FRONT-R
  sts   v_InfoBuf2+7,  AL ; LINE REAR-R

  ldi   AL, '.'
  sts   v_InfoBuf1+2,  AL ; Монетка
  sts   v_InfoBuf1+5,  AL ; Источник света

  ldi   AL, '_'
  sts   v_InfoBuf1+4,  AL ; Препятствие спереди
  sts   v_InfoBuf1+3,  AL ; Препятствие спереди

  mSetTimerTask fShowSensorsState,250ms

  ret

ENDP fShowSensorsState

PROC fPrintLineInfo

  ldi   AL, '?'
  mFlgSkipClr flg_LFL     ; LINE FRONT-L
  sts   v_InfoBuf1+0,  AL ; LINE FRONT-L

  mFlgSkipClr flg_LRL     ; LINE REAR-L
  sts   v_InfoBuf2+0,  AL ; LINE REAR-L

  mFlgSkipClr flg_LFR     ; LINE FRONT-R
  sts   v_InfoBuf1+7,  AL ; LINE FRONT-R

  mFlgSkipClr flg_LRR     ; LINE REAR-R
  sts   v_InfoBuf2+7,  AL ; LINE REAR-R
  ret

ENDP fPrintLineInfo


.include  "Songs.inc"
.include  "MoveLists.inc"

;< Reklama
  ListRekPage:
  .dw t_Rek_P0<<1
  .dw t_Rek_P1<<1
  .dw t_Rek_P2<<1
  .dw t_Rek_P3<<1
  .dw t_Rek_P4<<1
  .dw t_Rek_P5<<1
  .dw t_Rek_P6<<1
  .dw t_Rek_P7<<1

  .dw t_Rek_P8<<1
  .dw t_Rek_P9<<1
  .dw t_Rek_PA<<1
  .dw t_Rek_PB<<1
  .dw t_Rek_PC<<1
  .dw t_Rek_PD<<1
  .dw t_Rek_PE<<1
  .dw t_Rek_PF<<1

  ;-------------------------+
               ;|01234567| ;|
  t_Rek_P0: .db "Подходи!" ;|
            .db "Не робей" ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_P1: .db "А Погода" ;|
            .db "хорошая?" ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_P2: .db "-=Tank=-" ;|
            .db "Ver. 0.1" ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_P3: .db "RTOS by " ;|
            .db " S_Alex " ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_P4: .db "  PCB   " ;|
            .db "OpenSys " ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_P5: .db "Тел.0552" ;|
            .db " 326937 " ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_P6: .db "  ХНТУ  " ;|
            .db "Кафед.КТ" ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_P7: .db "А? Чего " ;|
            .db "смотрим?" ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_P8: .db " Детям  " ;|
            .db "3 до 80 " ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_P9: .db "Будьте  " ;|
            .db " ЗДОРОВЫ" ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_PA: .db "Заходите" ;|
            .db "если что" ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_PB: .db "Ребенок " ;|
            .db "скучает?" ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_PC: .db "Чистота-" ;|
            .db "ЗДОРОВЬЕ" ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_PD: .db "-=Demo=-" ;|
            .db "  MODE  " ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_PE: .db "Соблюдай" ;|
            .db "Чистоту." ;|
  ;-------------------------+
  ;-------------------------+
               ;|01234567| ;|
  t_Rek_PF: .db " I LOVE " ;|
            .db "-=AVR=- " ;|
  ;-------------------------+
;> Reklama

;< Strings
;--------------------------+
 sz_Init_GND_OK:          ;|
              ;|01234567| ;|
           .db " GRAUND " ;|
           .db "Saved OK" ;|
;--------------------------+
;--------------------------+
 sz_ButtonLSFM_1:         ;|
              ;|01234567| ;|
           .db "SB4 GND " ;|
           .db "SB2 FMLS" ;|
;--------------------------+
;--------------------------+
 sz_ButtonLSFM_2:         ;|
              ;|01234567| ;|
           .db "SB3 GO! " ;|
           .db " GO! GO!" ;|
;--------------------------+
;--------------------------+
 sz_Init_FM_LS_OK:        ;|
              ;|01234567| ;|
           .db " FM  LS " ;|
           .db "Saved OK" ;|
;--------------------------+

;> Strings


.include "LCD_RecodeTable.asm"
  #message "+--------------------+"
#ifndef DBG
  #message "|  Info: Release...  |"
#else
  #message "| Info: Debugging... |"
#endif
  #message "+--------------------+"


.exit
;S_Alex
