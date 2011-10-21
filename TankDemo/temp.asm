	rcall fLCDBuffCLR

	mov	AL,	r12
	clr	AH
	LDW		Y,v_LCDBuf
	rcall	fw2a
	
	ldi	AL,	'<'
	sts	v_LCDBuf2+0,AL
	sts	v_LCDBuf2+1,r12
	ldi	AL,	'>'
	sts	v_LCDBuf2+2,AL


#if 0
	PROC 	fLSInit
		mPinIn	LightS
		mPinCLR	LightS

		mExtIntType INT3,(EXTRIS)
		ret
	;< Interrupt
		.set	OldPC	=	pc
		.org	INT3addr	; Timer/Counter3 Capture Event
			rjmp f_INT3	;Timer1 Capture Handler
		.org	OldPC
	;> Interrupt

	ENDP fLSInit

	PROC f_INT3 ; Calc LS
		in		TmpSREG,	SREG
		;Place your code here

		push	AL
		push	AH
		mIn		AL,			TCNT3L
		lds		AH,			v_LSOldL
		sts		v_LSOldL,	AL
		sub		AL,			AH
		sts		v_LSCurL,	AL

		mIn		AL,			TCNT3H
		lds		AH,			v_LSOldH
		sts		v_LSOldH,	AL
		sbc		AL,			AH
		sts		v_LSCurH,	AL

		pop		AH
		pop		AL
		out		SREG,		TmpSREG
		reti

	ENDP f_INT3
#else
	PROC 	fLSInit
		mPinIn	LightS
		mPinCLR	LightS

		in		AL,			TIMSK
		ori		AL,			(1<<TICIE1)
		out		TIMSK,	AL

		ret
	;< Interrupt
		.set	OldPC	=	pc
		.org	ICP1addr	; Timer/Counter1 Capture Event
			rjmp f_IntICP1	;Timer1 Capture Handler
		.org	OldPC
	;> Interrupt

	ENDP fLSInit

	PROC f_IntICP1
		in		TmpSREG,	SREG
		;Place your code here

		push	AL
		push	AH
		mIn		AL,			TCNT3L
		lds		AH,			v_LS+2
		sts		v_LS+2,	AL
		sub		AL,			AH
		sts		v_LS+0,	AL

		mIn		AL,			TCNT3H
		lds		AH,			v_LS+3
		sts		v_LS+3,	AL
		sbc		AL,			AH
		sts		v_LS+1,	AL

		pop		AH
		pop		AL
		out		SREG,		TmpSREG
		reti

	ENDP f_IntICP1

#endif

									;	Нота.			Частота,Гц.
.equ 	nDO		=	262	; До				261,63
.equ 	nDOD	=	277	; До-диез		277,18
.equ 	nRE		=	294	; Ре				293,67
.equ 	nRED	=	311	; Ре-диез		311,13
.equ 	nMI		=	330	; Ми				329,63
.equ 	nFA		=	349	; Фа				349,22
.equ 	nFAD	=	370	; Фа-диез		369,99
.equ 	nSOL	=	392	; Соль			391,99
.equ 	nSOLD	=	415	; Соль-диез	415,30
.equ 	nLA		=	440	; Ля				440,00
.equ 	nLAD	=	466	; Ля-диез		466,16
.equ 	nSI		=	494	; Си				493,88

.equ  NT0	 =	0
.equ  NT1	 =	1
.equ  NT2	 =	2
.equ  NT4	 =	3
.equ  NT8	 =	4
.equ  NT16 =	5
.equ  NT32 =	6

      
;< BLOK1
NOTE(NSOL,NT8 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NSOL,NT8 ,1)
NOTE(NLA ,NT16,1)
NOTE(NSI ,NT4 ,1)
NOTE(NMI ,NT8 ,1)
NOTE(NMI ,NT8 ,1)
;-
NOTE(NLA ,NT4 ,1)
NOTE(NSOL,NT8 ,1)
NOTE(NFA ,NT16,1)
NOTE(NSOL,NT4 ,1)
NOTE(NDO ,NT8 ,1)
NOTE(NDO ,NT16,1)
;-
NOTE(NRE ,NT4 ,1)
NOTE(NRE ,NT8 ,1)
NOTE(NMI ,NT16,1)
NOTE(NFA ,NT4 ,1)
NOTE(NFA ,NT8 ,1)
NOTE(NSOL,NT8 ,1)
;-
NOTE(NLA ,NT4 ,1)
NOTE(NSI ,NT8 ,1)
NOTE(NDO ,NT16,2)
NOTE(NRE ,NT4 ,2)
NOTE(NSOL,NT8 ,1)
;-
NOTE(NMI ,NT4 ,2)
NOTE(NRE ,NT8 ,2)
NOTE(NDO ,NT16,2)
NOTE(NRE ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NSOL,NT8 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT16,1)
NOTE(NSI ,NT4 ,1)
NOTE(NMI ,NT8 ,1)
NOTE(NMI ,NT8 ,1)
;-
NOTE(NLA ,NT4 ,1)
NOTE(NSOL,NT8 ,1)
NOTE(NFA ,NT16,1)
NOTE(NSOL,NT4 ,1)
NOTE(NDO ,NT8 ,1)
NOTE(NDO ,NT16,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT16,1)
NOTE(NSOL,NT2 ,1)
;-
NOTE(NMI ,NT2 ,2)
NOTE(NRE ,NT8 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NDO ,NT8 ,2)
;-
NOTE(NRE ,NT4 ,2)
NOTE(NSOL,NT8 ,1)
NOTE(NSOL,NT2 ,1)
;-
NOTE(NDO ,NT2 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT8 ,1)
NOTE(NSOL,NT8 ,1)
NOTE(NLA ,NT8 ,1)
;-
NOTE(NSI ,NT4 ,1)
NOTE(NMI ,NT8 ,1)
NOTE(NMI ,NT4 ,1)
NOTE(NP  ,NT4 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NLA ,NT8 ,1)
NOTE(NSI ,NT16,1)
NOTE(NDO ,NT4 ,2)
NOTE(NLA ,NT8 ,1)
NOTE(NSI ,NT16,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NLA ,NT8 ,1)
NOTE(NDO ,NT16,2)
NOTE(NFA ,NT2 ,2)
;-
NOTE(NFA ,NT2 ,2)
NOTE(NMI ,NT8 ,2)
NOTE(NRE ,NT8 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NRE ,NT8 ,2)
;-
NOTE(NMI ,NT4 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NDO ,NT2 ,2)
;-
NOTE(NRE ,NT2 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT8 ,1)
NOTE(NSI ,NT8 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NLA ,NT8 ,1)
NOTE(NLA ,NT2 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT8 ,1)
NOTE(NSOL,NT4 ,1)
NOTE(NDO ,NT8 ,1)
NOTE(NDO ,NT16,1)
;> BLOK1

;< BLOK3
NOTE(NDO ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT16,1)
NOTE(NSOL,NT8 ,1)
NOTE(NP  ,NT8 ,1)
NOTE(NP  ,NT8 ,1)
NOTE(NSOL,NT8 ,1)
;> BLOK3

;< Повтор еще разок 
;< BLOK1
NOTE(NSOL,NT8 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NSOL,NT8 ,1)
NOTE(NLA ,NT16,1)
NOTE(NSI ,NT4 ,1)
NOTE(NMI ,NT8 ,1)
NOTE(NMI ,NT8 ,1)
;-
NOTE(NLA ,NT4 ,1)
NOTE(NSOL,NT8 ,1)
NOTE(NFA ,NT16,1)
NOTE(NSOL,NT4 ,1)
NOTE(NDO ,NT8 ,1)
NOTE(NDO ,NT16,1)
;-
NOTE(NRE ,NT4 ,1)
NOTE(NRE ,NT8 ,1)
NOTE(NMI ,NT16,1)
NOTE(NFA ,NT4 ,1)
NOTE(NFA ,NT8 ,1)
NOTE(NSOL,NT8 ,1)
;-
NOTE(NLA ,NT4 ,1)
NOTE(NSI ,NT8 ,1)
NOTE(NDO ,NT16,2)
NOTE(NRE ,NT4 ,2)
NOTE(NSOL,NT8 ,1)
;-
NOTE(NMI ,NT4 ,2)
NOTE(NRE ,NT8 ,2)
NOTE(NDO ,NT16,2)
NOTE(NRE ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NSOL,NT8 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT16,1)
NOTE(NSI ,NT4 ,1)
NOTE(NMI ,NT8 ,1)
NOTE(NMI ,NT8 ,1)
;-
NOTE(NLA ,NT4 ,1)
NOTE(NSOL,NT8 ,1)
NOTE(NFA ,NT16,1)
NOTE(NSOL,NT4 ,1)
NOTE(NDO ,NT8 ,1)
NOTE(NDO ,NT16,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT16,1)
NOTE(NSOL,NT2 ,1)
;-
NOTE(NMI ,NT2 ,2)
NOTE(NRE ,NT8 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NDO ,NT8 ,2)
;-
NOTE(NRE ,NT4 ,2)
NOTE(NSOL,NT8 ,1)
NOTE(NSOL,NT2 ,1)
;-
NOTE(NDO ,NT2 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT8 ,1)
NOTE(NSOL,NT8 ,1)
NOTE(NLA ,NT8 ,1)
;-
NOTE(NSI ,NT4 ,1)
NOTE(NMI ,NT8 ,1)
NOTE(NMI ,NT4 ,1)
NOTE(NP  ,NT4 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NLA ,NT8 ,1)
NOTE(NSI ,NT16,1)
NOTE(NDO ,NT4 ,2)
NOTE(NLA ,NT8 ,1)
NOTE(NSI ,NT16,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NLA ,NT8 ,1)
NOTE(NDO ,NT16,2)
NOTE(NFA ,NT2 ,2)
;-
NOTE(NFA ,NT2 ,2)
NOTE(NMI ,NT8 ,2)
NOTE(NRE ,NT8 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NRE ,NT8 ,2)
;-
NOTE(NMI ,NT4 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NDO ,NT2 ,2)
;-
NOTE(NRE ,NT2 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT8 ,1)
NOTE(NSI ,NT8 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NLA ,NT8 ,1)
NOTE(NLA ,NT2 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT8 ,1)
NOTE(NSOL,NT4 ,1)
NOTE(NDO ,NT8 ,1)
NOTE(NDO ,NT16,1)
;> BLOK1

;< BLOK3
NOTE(NDO ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT16,1)
NOTE(NSOL,NT8 ,1)
NOTE(NP  ,NT8 ,1)
NOTE(NP  ,NT8 ,1)
NOTE(NSOL,NT8 ,1)
;> BLOK3
;>

NOTE(NDO ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NLA ,NT8 ,1)
NOTE(NSOL,NT4 ,1)
NOTE(NDO ,NT8 ,1)
NOTE(NDO ,NT16,1)
;-

;< BLOK2
NOTE(NSOL,NT2 ,1)
NOTE(NLA ,NT4 ,1)
NOTE(NSI ,NT4 ,1)
;-
NOTE(NDO ,NT1,2)
NOTE(NDO ,NT1,2)
NOTE(NDO ,NT8,2)
;> BLOK2

;--------------------------------------------------------------------
ctOopsI:
;< 
;- 4/4
NOTE(NLA ,NT8 ,1)
NOTE(NP  ,NT8 ,1)
NOTE(NP  ,NT8 ,1)
NOTE(NLA ,NT8 ,1)
NOTE(NP  ,NT2 ,1)
;-
NOTE(NP  ,NT2 ,1)
;-
NOTE(NLA ,NT8 ,1)
NOTE(NDO ,NT8 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NDO ,NT8 ,2)
NOTE(NRE ,NT8 ,1)
NOTE(NDO ,NT8 ,2)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NDO ,NT8 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NDO ,NT8 ,2)
NOTE(NLA ,NT8 ,2)
NOTE(NLA ,NT8 ,2)
;-
NOTE(NLA ,NT4 ,2)
NOTE(NLA ,NT8 ,2)
NOTE(NMI ,NT8 ,2)
NOTE(NMI ,NT8 ,2)
NOTE(NMI ,NT8 ,2)
NOTE(NSOL,NT8 ,1)
;-
NOTE(NSOL,NT4 ,1)
NOTE(NP  ,NT4 ,1)
NOTE(NP  ,NT8 ,1)
NOTE(NDO ,NT8 ,2)
NOTE(NRE ,NT8 ,2)
NOTE(NSOL,NT8 ,1)
;-
NOTE(NDO ,NT4 ,2)
NOTE(NDO ,NT4 ,2)
NOTE(NSI ,NT8 ,1)
NOTE(NDO ,NT8 ,2)
NOTE(NRE ,NT8 ,2)
NOTE(NMI ,NT8 ,2)
NOTE(NRE ,NT8 ,2)


;-
;-
NOTE(0,0,1)
;> 
