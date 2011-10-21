;File	ServoHXT900.inc
;Updated: "2011-03-07" "19:41"

#ifndef	SERVOHXT900_INC
	#define	SERVOHXT900_INC 1
	
	#ifndef MACROEX_INC
		#include "MacroEX.asm"
	#endif
	#ifndef	TIMERCNTRS_INC
		#include "RTOSA\TimerCntrs.inc"
	#endif
	;<
		;500us 
		;2500us
		;609 344
	#define	Deg			*12.25;us per 1°

	.equ	RELOADT1	=	2500*2
	.equ  CORRECT		= 0
	.equ	SERVOINIT	=	1500+CORRECT
	
	.equ	SERVOMID	=	RELOADT1*SERVOINIT/20000
	.equ	SERVOMIN	=	RELOADT1*(SERVOINIT-(Alf)Deg)/20000
	.equ	SERVOMAX	=	RELOADT1*(SERVOINIT+(Alf)Deg)/20000
	
	
	PROC fServoInit
		;500us 
		;2500us
		;PWM Frequency 50Hz
		
		LDW		Z       ,(RELOADT1)
		mOut	ICR1H   ,ZH
		mOut	ICR1L   ,ZL
		;< Setting Servo0 into MID position
		LDW		Z       ,(SERVOMID)
		mOut	OCR1AH  ,ZH
		mOut	OCR1AL  ,ZL
		;> Setting Servo0 into MID position
		
		;< Setting Servo1 into MID position
;		LDW		Z       ,(SERVOMID)
		mOut	OCR1BH  ,ZH
		mOut	OCR1BL  ,ZL
		;> Setting Servo1 into MID position

  ;< Sets Servo into the centre position
      ldi rvIndxServo     ,8
  ;> Sets Servo into the centre position

	
		;Set MODE 8 - 
;----+-----+-----+-----+-----+---------------------------+------+---------+---------+
;Mode|WGMn3|WGMn2|WGMnl|WGMnO|Timer/Counter Mode of      |TOP   |Update of|TOVn Flag|
;    |     |CTCn |PWMnl|PWMn0|        Operation          |      |OCRnx at | Set on  |
;  8 |  1  |  0  |  0  |  0  |PWM, Phase and Freq Correct|ICRn  |BOTTOM   |BOTTOM   |
;  14|  1  |  1  |  1  |  0  |Fast PWM                   |ICRn  |TOP      |TOP      |
;----+-----+-----+-----+-----+---------------------------+------+---------+---------+
		;
		mT1SetMode 14 ,T1Div64 ,PWM1A_NoInv
	
	mIn AL    ,TIMSK
	ori AL    ,(1<<TOIE1)
	mOut TIMSK,AL
	
		
			;< Interrupt
				.set	OldPC	=	pc
				.org	OVF1addr	;Overflow0 Interrupt Vector Address
					rjmp f_IntOVF1	;Timer0 Overflow Handler
				.org	OldPC
				
			;> Interrupt
		
		ret
	
	ENDP fServoInit



;>
#else
	#message "----------------------------------------------"
	#message "### Duplicate include file '" __FILE__ "' ###"
	#message "----------------------------------------------"
#endif

.exit
;S_ALEX