;File:  "MoveLists.inc"
;Updated: "2011-04-06" "10:56"
;

#define LEFT  1
#define RIGHT 0

.macro m4Move ;SpeedL,LenL,SpeedR,LenR,Time
  .if @4<256
    .if (@1<256) && (@3<256)
      .db  ((@0&0b1111)<<4)|(@2&0b1111),@1,@3,@4 ;.db rvSpeedLR,LenL,LenR,Time
    .else
      .error "m4Move: Distance is big!"
    .endif
  .else
    .error "m4Move: Time is big!"
  .endif
.endmacro

.macro m4Rotate ;Left/Right,Speed,Deg,Method

    .if @2>255
      .error "m4Rotate: Distance is big!"
    .endif
  
  .if @3==1 ;Method
    ;< Rotate use 1 Crawler
    .if @0==(LEFT)  ;Left/Right
      ;Left
     .db  ((0&0b1111)<<4)|(@1&0b1111),0,@2,40 ;.db rvSpeedLR,LenL,LenR,Time
    .else
      ;Right
     .db  ((@1&0b1111)<<4)|(0&0b1111),@2,0,40 ;.db rvSpeedLR,LenL,LenR,Time
    .endif
    ;> Rotate use 1 Crawler
  .else
    ;< Rotate use 2 Crawlers
    .if @0==(LEFT)  ;Left/Right
      ;Left
     .db  ((-@1&0b1111)<<4)|(@1&0b1111),@2/2,@2/2,40 ;.db rvSpeedLR,LenL,LenR,Time
    .else
      ;Right
     .db  ((@1&0b1111)<<4)|(-@1&0b1111),@2/2,@2/2,40 ;.db rvSpeedLR,LenL,LenR,Time
    .endif
    ;> Rotate use 2 Crawlers
  .endif
  
  
.endmacro



ct_RR_45:
    m4Rotate RIGHT ,5,45degT,1 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
    
ct_RL_45:
    m4Rotate LEFT,5,45degT,1 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
    
ct_RR_90:
    m4Rotate RIGHT ,5,90degT,1 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
    
ct_RL_90:
    m4Rotate LEFT,5,90degT,1 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
    
ct_RR_180:
  m4Rotate RIGHT ,5,180degT,1 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves

ct_RL_180:
    m4Rotate LEFT,5,180degT,1 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
    
ct_RR_360_2:
  m4Rotate RIGHT ,5,360degT,2 ;Left/Right,Speed,Deg,Method
  m4Move 0,0,0,0,0; End Moves
  
ct_SearchFinishMove:
  m4Rotate RIGHT ,5,360degT,2 ;Left/Right,Speed,Deg,Method
  m4Rotate RIGHT  ,5,360degT,2 ;Left/Right,Speed,Deg,Method
  m4Move 0,0,0,0,0; End Moves


ct_SearchMove:
    m4Move  6,7mm, 6,7mm,255;*2.55s
    m4Move 0,0,0,0,0; End Moves
    
ct_OutLineMoveR:
    m4Move  -6,75mm, -6,75mm,20;*2.55s
    m4Rotate RIGHT ,6,90degT,1 ;Left/Right,Speed,Deg,Method
    m4Move   6,60mm,  6,60mm,20;*2.55s
    m4Move 0,0,0,0,0; End Moves
    
ct_OutLineMoveL:
    m4Move  -6,75mm, -6,75mm,20;*2.55s
    m4Rotate LEFT ,6,90degT,1 ;Left/Right,Speed,Deg,Method
    m4Move   6,60mm,  6,60mm,20;*2.55s
    m4Move 0,0,0,0,0; End Moves


ct_TstMove:
    m4Move  4,650mm, 4,650mm,20;*2.55s
    m4Move  4,650mm, 4,650mm,20;*2.55s    
    m4Move 0,0,0,0,0; End Moves
    
ct_Rotate:
    m4Rotate LEFT,7,360degT,2 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
    
ct_Rotate2R:
    m4Rotate RIGHT,6,360degT,2 ;Left/Right,Speed,Deg,Method
    m4Rotate RIGHT ,5,360degT,2 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
    
ct_Rotate2L:
    m4Rotate LEFT ,6,360degT,2 ;Left/Right,Speed,Deg,Method
    m4Rotate LEFT,5,360degT,2 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
    
ct_MoveCover:
    m4Move  7,150mm, 7,150mm,20;*2.55s
    m4Move 0,0,0,0,0; End Moves


    
;< MoveList for ADC calibration. Graund detection
#define mSpeed(SpeedL,SpeedR) ((SpeedL&0b1111)<<4)|(SpeedR&0b1111)  ; rvSpeedLR
ctGNDMoveList:
;  Speed  L  R Crawlers
  .db mSpeed( 5,-5),mSpeed(-5, 5)
  .db mSpeed( 3, 3),mSpeed(-3,-3)
  .db mSpeed(-5, 5),mSpeed(-5, 5)
  .db mSpeed( 0, 0),mSpeed( 0, 0) ; Stop marker
;> MoveList for ADC calibration. Graund detection

;<  таблица поворотов танка в зависимости от ctrnjhf
  ct_Sec_0:
    m4Rotate RIGHT,7,(Alf*(7-0))degTM/8,2 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
  ct_Sec_1:
    m4Rotate RIGHT,7,(Alf*(7-1))degTM/8,2 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
  ct_Sec_2:
    m4Rotate RIGHT,7,(Alf*(7-2))degTM/8,2 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
  ct_Sec_3:
    ;No rotate
    m4Move 0,0,0,0,0; End Moves
    
  ct_Sec_4:
    ;No rotate
    m4Move 0,0,0,0,0; End Moves
  ct_Sec_5:   
    m4Rotate LEFT,7,(Alf*(7-2))degTM/8,2 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
  ct_Sec_6:   
    m4Rotate LEFT,7,(Alf*(7-1))degTM/8,2 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
  ct_Sec_7:   
    m4Rotate LEFT,7,(Alf*(7-0))degTM/8,2 ;Left/Right,Speed,Deg,Method
    m4Move 0,0,0,0,0; End Moves
    
ct_List_Sec:
  .dw ct_Sec_0<<1
  .dw ct_Sec_1<<1
  .dw ct_Sec_2<<1
  .dw ct_Sec_3<<1
  .dw ct_Sec_4<<1
  .dw ct_Sec_5<<1
  .dw ct_Sec_6<<1
  .dw ct_Sec_7<<1
  
;>


ct_Servo4Scan:
  .dw SERVOMIN                           ;0
  .dw (SERVOMIN+(SERVOMIN+SERVOMID)/2)/2 ;1
  .dw (SERVOMIN+SERVOMID)/2              ;2
  .dw (SERVOMID+(SERVOMIN+SERVOMID)/2)/2 ;3
; .dw SERVOMID                           ;-
  .dw (SERVOMID+(SERVOMAX+SERVOMID)/2)/2 ;4
  .dw (SERVOMAX+SERVOMID)/2              ;5
  .dw (SERVOMAX+(SERVOMAX+SERVOMID)/2)/2 ;6
  .dw SERVOMAX                           ;7
  ;---
  .dw SERVOMID                           ;8
  .dw RELOADT1*(SERVOINIT-75Deg)/20000   ;9   MAX RIGHT
  .dw RELOADT1*(SERVOINIT+75Deg)/20000   ;10  MAX LEFT


.exit
;S_Alex
