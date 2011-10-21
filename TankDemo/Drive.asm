;File: "Drive.asm" for TankDemo
;Updated: "2010-11-01" "00:31"

PROC fDrvInit
	;< Sets the directions of Pin 
  	mPinCLR	DrvRF	;	Right Crawler motor
  	mPinCLR	DrvRR	;	Right Crawler motor
  	mPinCLR	DrvLR	;	Left Crawler motor
  	mPinCLR	DrvLF	;	Left Crawler motor
  
  	mPinOut	DrvRF	;	Right Crawler motor
  	mPinOut	DrvRR	;	Right Crawler motor
  	mPinOut	DrvLR	;	Left Crawler motor
  	mPinOut	DrvLF	;	Left Crawler motor
	;> Sets the directions of Pin


	mIn		AL,			ETIMSK
	ori		AL,			(1<<OCIE3A)|(1<<OCIE3B)|(1<<TOIE3)
	mOut	ETIMSK,	AL

	ldi		rvSpeedLR,	0x00	; "СТОП МАШИНА"

	ret
	;< Interrupt
		.set	OldPC	=	pc
		.org	OVF3addr				;Overflow3 Interrupt Vector Address
			rjmp fIntTC3_OVF		;Timer3 Overflow Handler
		.org	OC3Aaddr				; Timer/Counter1 Compare Match B
			rjmp fIntTC3_COMPA	;
		.org	OC3Baddr				; Timer/Counter1 Compare Match B
			rjmp fIntTC3_COMPB	;
;		.org	OC1Caddr				; Timer/Counter1 Compare Match C
;			rjmp fIntTC1_COMPC	;
		.org	OldPC
	;> Interrupt

ENDP fDrvInit



PROC fIntTC3_COMPA;Timer3 CompareA Handler
	in		TmpSREG,	SREG
	;< Stop Left Crawler motor
	mPinCLR	DrvLF	;	Left Crawler motor
	mPinCLR	DrvLR	;	Left Crawler motor
	;> Stop Left Crawler motor
	out		SREG,		TmpSREG
	reti
ENDP fIntTC3_COMPA

PROC fIntTC3_COMPB;Timer3 CompareB Handler
	in		TmpSREG,	SREG
	;< Stop Right Crawler motor
  	mPinCLR	DrvRR	;	Right Crawler motor
  	mPinCLR	DrvRF	;	Right Crawler motor
	;> Stop Right Crawler motor
	out		SREG,		TmpSREG
	reti
ENDP fIntTC3_COMPB

PROC fIntTC3_OVF	;Timer1 Overflow Handler
	in		TmpSREG ,SREG
	push	AL
	;Place your code here
	rcall	fDrvOnLeft
	rcall	fDrvOnRight
	pop		AL
	out		SREG    ,TmpSREG
	reti
ENDP fIntTC3_OVF

;###############################################################################

PROC fDrvOnLeft
;	mIfFlgSET	flg_BlockL,	rjmp L_DrvL_Stop
	;< Проверка на нулевую скорость левой гусеницы
	mov		AL,	rvSpeedLR
	andi	AL,	0b01110000
	;> Проверка на нулевую скорость левой гусеницы
	breq L_DrvL_Stop				; Скорость равна 0 двигатель не включаем.
	
		;< Setting speed for Left Crawler
		sbrc	rvSpeedLR	,bit7
			neg	AL
		lsl		AL
		mOut	OCR3AH		,AL
		mOut	OCR3AL		,ZERO
		;> Setting speed for Left Crawler

		;< Enable Left Crawler motor
			;< Stop Left Crawler motor
			mPinCLR	DrvLR		;	Left Crawler motor
			mPinCLR	DrvLF		;	Left Crawler motor
			;> Stop Left Crawler motor
		sbrc rvSpeedLR,	bit7
		rjmp L_DrvOnLeftRear
			mPinSET	DrvLF	;	Forward
			ret
		L_DrvOnLeftRear:
		mPinSET	DrvLR		;	Rear
		;> Enable Left Crawler motor
	L_DrvL_Stop:
	ret
ENDP fDrvOnLeft


PROC fDrvOnRight
;	mIfFlgSET	flg_BlockR,	rjmp L_DrvR_Stop
	;< Проверка на нулевую скорость правой гусеницы
	mov		AL,	rvSpeedLR
	andi	AL,	0b00000111
	;> Проверка на нулевую скорость правой гусеницы
	breq L_DrvR_Stop				; Скорость равна 0 двигатель не включаем.

		;< Setting speed for Right Crawler
		swap	AL
		sbrc	rvSpeedLR	,bit3
			neg	AL
		lsl		AL
		mOut	OCR3BH		,AL
		mOut	OCR3BL		,ZERO
		;> Setting speed for Right Crawler

		;< Enable Right Crawler motor
			;< Stop Right Crawler motor
			mPinCLR	DrvRR	;	Right Crawler motor
			mPinCLR	DrvRF	;	Right Crawler motor
			;> Stop Right Crawler motor
		sbrc rvSpeedLR,	bit3
		rjmp L_DrvOnRightRear
			mPinSET	DrvRF	;	Forward
			ret
		L_DrvOnRightRear:
		mPinSET	DrvRR	;	Rear
		;> Enable Right Crawler motor
	L_DrvR_Stop:
	ret
ENDP fDrvOnRight


PROC fMoveEX_Run
  mFlgSet flg_StepL
  mFlgSet flg_StepR
  sts   (v_fptrMoveEX+0),YL
  sts   (v_fptrMoveEX+1),YH
;  rcall fMoveEX
;  ret

ENDP fMoveEX_Run


PROC fMoveEX

	lds		ZL,(v_fptrMoveEX+0)
	lds		ZH,(v_fptrMoveEX+1)

	mIfFlgCLR	flg_StepL,rjmp LMoveListEX_ret
	mIfFlgCLR	flg_StepR,rjmp LMoveListEX_ret

	;< Read speed LR
	lpm		rvSpeedLR,	z+
	;> Read speed LR

	;< if SpeedL == 0 then no clear flag flg_StepL
	ldi		AL  ,0xF0
	and		AL  ,rvSpeedLR
	breq (pc+1)+1
		mFlgClr	flg_StepL
	;> if SpeedL == 0 then no clear flag flg_StepL
	
	;< if SpeedR == 0 then no clear flag flg_StepR
	ldi		AL  ,0x0F
	and		AL  ,rvSpeedLR
	breq (pc+1)+1
		mFlgClr	flg_StepR
	;> if SpeedR == 0 then no clear flag flg_StepR



	lpm		AL  ,z+
	lds		AH  ,(v_CrawlerCurPosL)
	add		AH  ,AL
	sts		(v_CrawlerPosL),	AH

	lpm		AL  ,z+
	lds		AH  ,(v_CrawlerCurPosR)
	add		AH  ,AL
	sts		(v_CrawlerPosR),	AH

	lpm		XH  ,z+
	clr		XL  
	ldi		AL  ,GetTaskID(fDrvStop)
	rcall	krSetTimer

	tst		XH
	brne (pc+1)+2+1+1
  ;< ### записать событие по окончанию плейлиста
  	lds	AL			        ,(v_Event_EndMov)
  	rcall krSendTask
  ;> 
	ret

 LMoveListEX_ret:
	sts		(v_fptrMoveEX+0),ZL
	sts		(v_fptrMoveEX+1),ZH
	
	mSetTimerTask fMoveEX,155ms

	ret

ENDP fMoveEX

PROC fDrvStopL
	andi	rvSpeedLR,0x0F
	ret
ENDP fDrvStopL

PROC fDrvStopR
	andi	rvSpeedLR,0xF0
	ret
ENDP fDrvStopR

PROC fDrvStop
	ldi	rvSpeedLR,0x00
	mClrTimer fMoveEX
	mClrTimer fDrvStop
	ret
ENDP fDrvStop




.exit
;S_Alex