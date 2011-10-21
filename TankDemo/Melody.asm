									;	Нота.			Частота,Гц.
.equ 	F_DO	=	262	; До				261,63
.equ 	F_DOD	=	277	; До-диез		277,18
.equ 	F_RE	=	294	; Ре				293,67
.equ 	F_RED	=	311	; Ре-диез		311,13
.equ 	F_MI	=	330	; Ми				329,63
.equ 	F_FA	=	349	; Фа				349,22
.equ 	F_FAD	=	370	; Фа-диез		369,99
.equ 	F_SOL	=	392	; Соль			391,99
.equ 	F_SOLD=	415	; Соль-диез	415,30
.equ 	F_LA	=	440	; Ля				440,00
.equ 	F_LAD	=	466	; Ля-диез		466,16
.equ 	F_SI	=	494	; Си				493,88

.equ NP    = 0 ;	Пауза
.equ NDO   = 1 ;
.equ NDOD  = 2 ;
.equ NRE   = 3 ;
.equ NRED  = 4 ;
.equ NMI   = 5 ;
.equ NFA   = 6 ;
.equ NFAD  = 7 ;
.equ NSOL  = 8 ;
.equ NSOLD = 9 ;
.equ NLA   = 10;
.equ NLAD  = 11;
.equ NSI   = 12;

.equ  NT0	 =	0
.equ  NT1	 =	1
.equ  NT2	 =	2
.equ  NT4	 =	3
.equ  NT8	 =	4
.equ  NT16 =	5
.equ  NT32 =	6

;< Use this code as interrupts handler
;PROC INT_OC3C ;"Buzer"
;
;  in    TmpSREG   ,SREG
;  ;Place your code here
;  mPinCpl pBuzer  ; Инверсия состояния для вывода "Buzer"
;
;  push  AL
;  push  AH
;  mIn   AL    ,OCR3CL
;  lds   AH    ,v_DivNote+0
;  add   AL    ,AH
;
;  push  AL
;  mIn   AL    ,OCR3CH
;  lds   AH    ,v_DivNote+1
;  adc   AH    ,AL
;  pop   AL
;
;  mOut OCR3CH ,AH
;  mOut OCR3CL ,AL
;
;  pop   AH
;  pop   AL
;  out   SREG  ,TmpSREG
;  reti
;
;ENDP INT_OC3C
;> Use this code as interrupts handler


PROC fBuzerInit
	mPinCLR	pBuzer
	mPinOut	pBuzer
.equ	FTC3 = Fclk / 8 ; 2 000 000 Hz

	ret
	;< Interrupt
		.set	OldPC	=	pc
		.org	OC3Caddr				; Timer/Counter3 Compare Match C
			rjmp INT_OC3C	;
		.org	OldPC
	;> Interrupt

ENDP fBuzerInit


PROC fNoteSetF
.ifdef	PROTEUS
	mStop
.endif

	LDW	X,	(FTC3/2/F_DO)
	sts	(v_DivNote+0),	XL
	sts	(v_DivNote+1),	XH


	ret

 ctDivNotes: ; Значение частоты выше вдвое, т.к. прим. инверсия вывода "Buzer"
	.dw FTC3/2/F_DO		; До				261,63
	.dw FTC3/2/F_DOD	; До-диез		277,18
	.dw FTC3/2/F_RE		; Ре				293,67
	.dw FTC3/2/F_RED	; Ре-диез		311,13
	.dw FTC3/2/F_MI		; Ми				329,63
	.dw FTC3/2/F_FA		; Фа				349,22
	.dw FTC3/2/F_FAD	; Фа-диез		369,99
	.dw FTC3/2/F_SOL	; Соль			391,99
	.dw FTC3/2/F_SOLD	; Соль-диез	415,30
	.dw FTC3/2/F_LA		; Ля				440,00
	.dw FTC3/2/F_LAD	; Ля-диез		466,16
	.dw FTC3/2/F_SI		; Си				493,88

 ctDNotes: ; Таблица значений для длительности нот
#if 1
	.dw 1s
	.dw 1s /2
	.dw 1s /4
	.dw 1s /8
	.dw	1s /16
	.dw	1s /32

#else
	.dw 1s *2
	.dw 1s *2 /2
	.dw 1s *2 /4
	.dw 1s *2 /8
	.dw	1s *2 /16
	.dw	1s *2 /32

#endif

ENDP fNoteSetF

PROC fMelodyFinish
	LDW	Z             ,(ctGimn_UA<<1)
	sts	(v_fptrSND+0) ,ZL
	sts	(v_fptrSND+1) ,ZH
	mSendTask	fMelodyPlay
	ret
ENDP fMelodyFinish

PROC fMelodyMoneta

  ;< Decrement v_CntMonet
    lds AL          ,(v_CntMonet)
    dec AL
    sts (v_CntMonet),AL
  ;> Decrement v_CntMonet

	LDW	Z             ,(ct_monet<<1)

	sts	(v_fptrSND+0) ,ZL
	sts	(v_fptrSND+1) ,ZH
	mSendTask	fMelodyPlay
	ret
ENDP fMelodyMoneta


PROC fMelodyPlay
;	LDW	Z,	(ctMelody<<1)
;	sts	(v_fptrSND+0),	ZL
;	sts	(v_fptrSND+1),	ZH

	lds	ZL            ,(v_fptrSND+0)
	lds	ZH            ,(v_fptrSND+1)

	lpm	AL            ,z+	; Read octave and note (octave bit7-4)|(note bit3-0)
	lpm	AH            ,z+	; Read duration
	sts	(v_fptrSND+0) ,ZL
	sts	(v_fptrSND+1) ,ZH

	push	AL

	rcall fBuzerOn	;
	;< Test PAUSE
	andi	AL, 0b1111	; Test PAUSE
	brne L_fMelodyPlay_NoPause
		rcall fBuzerOff	;
 L_fMelodyPlay_NoPause:
	;> Test PAUSE

	;< Settings prediv for current note
	;< Read prediv for current note
	LDW	  Z   ,(ctDivNotes<<1)
	dec		AL
	lsl		AL
	add		ZL,	AL
	adc		ZH,	ZERO
	lpm		XL,	z+
	lpm		XH,	z+
	;> Read prediv for current note

	pop		AL

	;< Correct prediv for current octave
	swap	AL
	andi	AL, 0b1111
 L_fMelodyPlay_CO:
	dec		AL
	breq L_fMelodyPlay_NoCO
		lsr	XH
		ror	XL
		rjmp L_fMelodyPlay_CO
L_fMelodyPlay_NoCO:
	;> Correct prediv for current octave

	sts	(v_DivNote+0),	XL
	sts	(v_DivNote+1),	XH
	;> Settings prediv for current note

	;< Read & settings duration
	tst		AH ;AH - Inex of Duration into ctDNotes tables
	brne L_fMelodyPlay_Cont ;
		rcall fBuzerOff	;	THE END
		lds   AL    ,(v_Event_Melody)
		rcall krSendTask

		ret
 L_fMelodyPlay_Cont:
	dec		AH
	lsl		AH
	LDW		Z,	(ctDNotes<<1)
	add		ZL,	AH
	adc		ZH,	ZERO
	lpm		XL,	z+                      ; init Timer
	lpm		XH,	z+                      ; init Timer
	ldi		AL,	GetTaskID(fMelodyPlay)	; TaskID
	rcall krSetTimer
	;> Read & settings duration

 L_fMelodyPlay_Ret:
	ret

ENDP fMelodyPlay


PROC fBuzerOn
	push	AL
	mIn		AL,			ETIMSK
	ori		AL,			(1<<OCIE3C)
	mOut	ETIMSK,	AL
	pop		AL
	ret
ENDP fBuzerOn

PROC fBuzerOff
	push	AL
	mIn		AL,			ETIMSK
	cbr		AL,			(1<<OCIE3C)
	mOut	ETIMSK,	AL
	mPinCLR	pBuzer
	pop		AL
	ret
ENDP fBuzerOff

