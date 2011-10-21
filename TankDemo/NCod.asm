;File: "EnCoder.asm" for Test_IIST
;Updated: "2010-11-01" "00:31"


.nolist
.dseg
v_ENLast:				.byte	1	;	Хранит последние 4 состояния энкодера.
v_ENState:			.byte	1 ; Хранит только поледние изменения в состоянии энкодера.
v_ENInput:			.byte	1	; (-1; 0; +1) ; Что происходило с энкодером.

.cseg
.list
.listmac

PROC fNCodInit
	mPinIn	NCodL
	mPinIn	NCodR
	mPinCLR NCodL	;Off PullUp resistor
	mPinCLR NCodR	;Off PullUp resistor

	clr		AL
	sts		(v_ENLast),		AL
	sts		(v_ENState),	AL
	sts		(v_ENInput),	AL

	
	mSendTask fENGet

	ret
	
;< Interrupt
	
ENDP fNCodInit
;################################## FUNCTION ###################################
;Name of function:
 ; fENGet
;Input:
 ; -
;Return:
 ; -
;Description:
;

PROC fENGet
#define	rvTmp	r19
	push		rvTmp
	push		AH


	;< Get current state of encoder
	lds		AL,	(v_ENLast)
	lsl		AL
	mPinState	NCodL
	bld		AL,	bit0
	mPinState	NCodR
	bld		AL,	bit4
	sts		(v_ENLast),	AL
	;> Get current state of encoder

	;<	Contact bounce suppression.
	lds		rvTmp,	(v_ENState)
	mov		AH,	AL
	
	;< For NCodL
	andi	AL,	0x0F
	brne	(pc+1)+1
		cbr	rvTmp,	(1<<bit0)
	com		AL
	andi	AL,	0x0F
	brne	(pc+1)+1
		ori	rvTmp,	(1<<bit0)
	;> For NCodL

	;< For NCodR
	andi	AH,	0xF0
	brne	(pc+1)+1
		cbr	rvTmp,	(1<<bit4)
	com		AH
	andi	AH,	0xF0
	brne	(pc+1)+1
		ori	rvTmp,	(1<<bit4)
	;> For NCodR
	;>	Contact bounce suppression
	
	
	
	lds		AL,	(v_ENState)
	eor		AL,	rvTmp
	breq	lENGet_NoChange	;	AL = 0
		andi	rvTmp,	(1<<bit4)|(1<<bit0) ;
		sts		(v_ENState),	rvTmp
		
		mov		AH,	AL
		
		andi	AL,	0x0F
		breq NoMoveL
	 L_Left:
		lds		AL								,(v_CrawlerCurPosL)
		inc		AL
		sts		(v_CrawlerCurPosL),AL
		
		;< Checking the left crawler position
		lds		rvTmp	,(v_CrawlerPosL)
		cp		rvTmp	,AL
		brne (pc+1)+1+2+1
			mFlgSet flg_StepL					;1b
			lds	AL	,(v_Event_StepL)	;2b
			rcall krSendTask					;1b
;			andi	rvSpeedLR,	0x0F

		;> Checking the left crawler position
		 
 NoMoveL:
 	
		andi	AH,	0xF0
		breq NoMoveR
	 L_Right:
		lds		AL								,(v_CrawlerCurPosR)
		inc		AL
		sts		(v_CrawlerCurPosR),AL
		
		;< Checking the right crawler position
		lds		rvTmp	,(v_CrawlerPosR)
		cp		rvTmp	,AL
		brne (pc+1)+1+2+1
			mFlgSet flg_StepR					;1b
			lds	AL	,(v_Event_StepR)	;2b
			rcall krSendTask					;1b
;			andi	rvSpeedLR,	0xF0

		;> Checking the right crawler position

 NoMoveR:
 
 lENGet_NoChange:

 lENGet_Exit:
 ;
 
	mSendTask fENGet
	pop		AH
	pop		rvTmp
	ret
#undef	rvTmp
ENDP fENGet




;S_Alex