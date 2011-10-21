;File "ADC.INC" for Test_IIST use Atmega8
;Updated: "2010-10-02" "00:13"
;Updated: "2010-12-14" "18:52"

.nolist
#ifndef	ADC_INC
	#define	ADC_INC 1

	.set	ADC_NCanal = exp2(3) ; Количество каналов АЦП 2^n

	;REFS1 REFS0 Voltage Reference Selection
	;	0	0		AREF, Internal Vref turned off
	;	0	1		AVCC with external capacitor at AREF pin
	;	1	0		Reserved
	;	1	1		Internal 2.56 V Voltage Reference with external capacitor at AREF pin
	.set	Aref_AREF	=	0
	.set	Aref_AVCC	=	1
	.set	Aref_256	=	3
	;-------------------------------------------------------------------------
	;ADPS2 ADPS1 ADPS0 Division Factor
	;	0	0	0		2
	;	0	0	1		2
	;	0	1	0		4
	;	0	1	1		8
	;	1	0	0		16
	;	1	0	1		32
	;	1	1	0		64
	;	1	1	1		128
	;-------------------------------------------------------------------------
	.set	ADC0	=	0
	.set	ADC1	=	1
	.set	ADC2	=	2
	.set	ADC3	=	3
	.set	ADC4	=	4
	.set	ADC5	=	5
	.set	ADC6	=	6	; only TQFP
	.set	ADC7	=	7	; only TQFP

	.set	VBG		=	0b1110
	.set	GND		=	0b1111
	;====================================================================
	.set	ADCFR	=	1	;ADC Free Running Select
	.set	ADCIE	=	1	;ADC Interrupt Enable

;	.set	DivADC	=	2
;	.set	DivADC	=	4
;	.set	DivADC	=	8
;	.set	DivADC	=	16
;	.set	DivADC	=	32
;	.set	DivADC	=	64
	.set	DivADC	=	128

	.set	FADC	=	Fclk/DivADC
	.if		FADC > 200000
		.error "ADC clock frequency higher than 200 kHz"
	.endif
	.if		FADC < 50000
		.error "ADC clock frequency below than 50 kHz"
	.endif
	;###############################################################################

	;##########################################################
	;#################### DATA RAM ############################
	.nolist
	.dseg
	 v_ADC: .byte 8	; Buffer for ADC data
	.cseg
	.list
	.listmac
	;##########################################################
	;##########################################################

	;###############################################################################
	PROC fADCInit
		clr		AL
		mOut		PORTF-1,	AL
		mOut		PORTF,		AL

;		ldi		AL,		Aref_AREF<<REFS0|1<<ADLAR|ADC0	;Опорное напряжение AREF
		ldi		AL,		Aref_AVCC<<REFS0|1<<ADLAR|ADC0	;Опорное напряжение AVCC
;		ldi		AL,		Aref_256<<REFS0|1<<ADLAR|ADC0	;Опорное напряжение 2.56 V
		out		ADMUX,		AL

		ldi		AL,		(1<<ADEN)|ADCFR<<ADATE|ADCIE<<ADIE|(log2(DivADC)<<ADPS0)
		out		ADCSRA,		AL
		mOut	ADCSRB,		ZERO	;ADC Free Running Select

	;	cbi		ADCSRA,		ADSC	;ADC Start Conversion
		sbi		ADCSRA,		ADSC	;ADC Start Conversion
	;	cbi		ADCSRA,		ADIF

		ret
;.equ ADC0		= 0b00000
;.equ ADC1		= 0b00001
;.equ ADC2		= 0b00010
;.equ ADC3		= 0b00011
;.equ ADC4		= 0b00100
;.equ ADC5		= 0b00101
;.equ ADC6		= 0b00110
;.equ ADC7		= 0b00111
;.equ ADCVBG	= 0b11110	;1.22V (VBG)
;.equ ADCGND	= 0b11111	;0V (GND)
;	 ADCListCanal:
;	 	.db	ADC0,ADC1,ADC2,ADC3,
	 	
	ENDP fADCInit
	;###############################################################################
	;###############################################################################


	;###############################################################################
	;Interrupting routine the ADC change meagering canal
	PROC fADCInt
	#define	TmpADMUX	AH
	#define	CurCanal	AL
	#define	CurVal		TmpADMUX

		in		TmpSREG,	SREG
		;< Place your code here

		push	CurCanal
		push	TmpADMUX

		;< Gets value from the current canal
		mPUSHw	Y
		in		CurCanal,	ADMUX
		dec		AL
		andi	AL,	(ADC_NCanal-1);

		LDW		Y,	(v_ADC)
;		lsl		CurCanal	;CurCanal = CurCanal*2
		add		YL,			CurCanal
		adc		YH,			ZERO
	;	;< Сохраним предыдущее значение в памяти
	;	ld		CurVal,		Y
	;	std		y+1,		CurVal
	;	;> Сохраним предыдущее значение в памяти
		;< Reading and Saving the current value into RAM
		in		CurVal,		ADCL
	;	sbrc	CurCanal,	3
	;	st		y+,			CurVal
		in		CurVal,		ADCH
		st		y,			CurVal
		;> Reading and Saving the current value into RAM
		mPOPw	Y
		;> Gets value from the current canal

		;< Calculating the next canal
		in		TmpADMUX,	ADMUX
		mov		AL,		TmpADMUX
		inc		AL
		andi	AL,	(ADC_NCanal-1)	;
		brne (pc+1)+1
		  mFlgSet flg_ADC ;Converting complete. For all ADC canals
		cbr		TmpADMUX,	(ADC_NCanal-1);
		or		TmpADMUX,	AL
		;> Calculating the next canal

		;< Sets next canal
		out		ADMUX,		TmpADMUX
		;> Sets next canal

		;< Fix Bug AVRStudio
	;	sbi		ADCSRA,		ADSC	;ADC Start Conversion
		;> Fix Bug AVRStudio

		pop		TmpADMUX
		pop		CurCanal

	;	mStop	;Debug into Proteus
		;> Place your code here

		out		SREG,		TmpSREG
		reti
	#undef		TmpADMUX
	#undef		CurCanal
	ENDP fADCInt


;< Interrupt
	.set	OldPC	=	pc
.org	ADCCaddr	;ADC Interrupt Vector Address
	rjmp fADCInt		;ADC Conversion Complete Handler
	.org	OldPC
;> Interrupt

#else
	#warning "----------------------------------------------";
	#message "### Duplicate include file '" __FILE__ "' ###";
	#message "----------------------------------------------";
#endif
;###############################################################################
;###############################################################################

;###############################################################################

;S_Alex
