.ifndef flg_IR_OK
	.message "Define  flg_IRStart = 7"
	.set flg_IR_OK	=	7	;	IROK
.endif

.ifndef flg_IRStart
	.message "Define  flg_IRStart = 6"
	.set flg_IRStart	=	6	;	IRStart
.endif

	;##########################################################
	;##########################################################
	.dseg
	.nolist
		v_IR:
		v_IR_Code:	.byte	4
		v_IR_Buff:	.byte	4
		v_IRTCNT0:	.byte 1
		v_IRBits:		.byte 1
		v_IRID:			.byte 1


		v_IR_Addr:	.byte 1	; јдрес устройства
		v_IR_Cmd:		.byte 1	; ”правл€ющий код

	.cseg
	.list
	.listmac
	;##########################################################
	;##########################################################
	
;< defines constants

;	mExtIntType	INT5,EXTANY	;	BAMP F-TSOP
;--------
; RC5
;	The modulated carrier is usually derived from 432kHz and is 1/12 of the
;	frequency with 1/3 duty cycle.
;	When data are transmitted repeatedly, the frame cycle is 113.7ms or 256
;	period.
;	A frame consists of a two-bit syn code, a one-bit control code, a five-bit
;	system code, and a six-bit data code. Len = 14-bit
; Frame = 14 * 4* 444 = 24 864us
;		Data Item         	Time (sec.)     Time (no. of period)
;		Data off time     	0.888ms         2T
;		Data on time      	0.888ms         2T
;		Data period (0)   	3.552ms         4T
;		Data period (1)   	3.552ms         4T
;		Frame output cycle	113.7ms         256T
;		Where T=0.444ms
#define SYNCRC5	888
;--------
; SONY
;	The modulated carrier is usually derived from 480kHz and is 1/12 of the
;	frequency with 1/3 duty cycle.
;	When data are transmitted repeatedly, the frame cycle is 45ms or 150
;	period.
;	A frame consists of a syn pulse, a seven-bit data code and a five-bit custom
;	code.
; Frame = (8+6*13) * 300 = 25 800us
;		Data Item         	Time (sec.)			Time (no. of period)
;		Syn pulse         	2.4ms      			8T
;		Data off time     	0.61ms     			2T
;		Data on time (0)  	0.59ms     			2T
;		Data on time (1)  	1.19ms     			4T
;		Data period (0)   	1.2ms      			4T
;		Data period (1)   	1.8ms      			6T
;		Frame output cycle	45ms       			150T
;		Where T=0.3ms
#define SYNCSONY	2400
;--------
;	Matsushita
;	The modulated carrier is usually derived from 440kHz and is 1/12 of the
;	frequency with 1/2 duty cycle.
;	When data are transmitted repeatedly, the frame cycle is 104.7ms or 240
;	period.
;	A frame consists of a syn pulse, a six-bit custom code, six-bit data code, a
;	six-bit inverted custom code and  a six-bit inverted data code.
; Frame = (8+8+12*4+12*8) * 436 = 69 760us

;	 Data Item          	Time (sec.)			Time (no. of period)
;	 Syn pulse on time  	3.49ms     			8T
;	 Syn pulse off time 	3.49ms     			8T
;	 Data on time (0)   	0.86ms     			2T
;	 Data off time (0)  	0.88ms     			2T
;	 Data on time (1)   	0.86ms     			2T
;	 Data off time (1)  	2.63ms     			6T
;	 Data period (0)    	1.74ms     			4T
;	 Data period (1)    	3.49ms     			8T
;	 Frame output cycle 	104.7ms    			240T
;	 Where T=0.436ms
#define SYNCMATSUSHITA	3490

;--------
; NEC
;	The modulated carrier is usually derived from 455kHz and is 1/12 of the
;	frequency with 1/3 duty cycle.
;	When data are transmitted repeatedly, the frame cycle is 107.9ms or 186
;	period.
;	A frame consists of a syn pulse, an eight-bit custom code, an eight-bit
;	inverted custom code, an eight-bit data code and an eight-bit inverted data
;	code.
; Frame = (15,5+8+16*2+16*4)* 580 = 69 310us

;		Data Item         	Time (sec.)			Time (no. of period)
;		Syn pulse on time 	8.993ms    			15.5T
;		Syn pulse off time	4.642ms    			8T
;		Syn pulse off time	2.321ms    			4T
;		(subsequent frame)
;		Data on time (0)  	0.561ms    			T
;		Data off time (0) 	0.598ms    			T
;		Data on time (1)  	0.561ms    			T
;		Data off time (1) 	1.758ms    			3T
;		Data period (0)   	1.160ms    			2T
;		Data period (1)   	2.321ms    			4T
;		Frame output cycle	107.9ms    			186T
;		Where T=0.58ms
#define SYNCNEC	8993

#define SYNCTIMEOUT	10000

#define IrPulseThershold(Tus) Tus*Fclk/1000000/1024;
;#define IrPulseThershold(Tus) 1100*16000000/1000000/1024;
;> defines constants

PROC fIRInit
	mPinIn	IRC	;	от датчика переднего бампера	;INT5
	mPinSET	IRC	;	от датчика переднего бампера	;INT5
	mExtIntType	INT5,EXTANY	;	BAMP F-TSOP
	mFlgClr	flg_IRStart
	mFlgClr	flg_IR_OK

	ret
ENDP fIRInit

PROC fIRShiftBuff ;Any logical change on INT5 generates an interrupt request

	mIfFlgSET flg_IR_OK,ret

	push	AL
	push	AH

	mIfFlgCLR flg_IRStart,rjmp L_fIRShiftBuff_Start
	;< Continuation the IR pulses
		;< Calc pulse duration
		in	AL,						TCNT0
		lds	AH,						(v_IRTCNT0)
		sts	(v_IRTCNT0),	AL
		sub	AL,	AH
		;> Calc pulse duration

		;< Detect infrared code formats (RC5; SONY; MATSUSHITA; NEC)
		lds		AH,		(v_IRBits)
		inc		AH
		sts		(v_IRBits),	AH

		brne L_fIRShiftBuff_NoSync
			ldi	AH,	'E'; - ERROR
			cpi	AL,	IrPulseThershold (SYNCRC5)-1
			brlo L_fIRShiftBuff_SetID
				ldi	AH,	'5'; - RC5;
				cpi	AL,	IrPulseThershold (SYNCSONY)-1
				brlo L_fIRShiftBuff_SetID
					ldi	AH,	'S'; - SONY;
					cpi	AL,	IrPulseThershold (SYNCMATSUSHITA)-1
					brlo L_fIRShiftBuff_SetID
						ldi	AH,	'M'; - MATSUSHITA
						cpi	AL,	IrPulseThershold (SYNCNEC)-1
						brlo L_fIRShiftBuff_SetID
							ldi	AH,	'N'; - NEC
							cpi	AL,	IrPulseThershold (SYNCTIMEOUT)-1
							brlo L_fIRShiftBuff_SetID
								ldi	AH,	'E'; - ERROR

		L_fIRShiftBuff_SetID:
			sts	(v_IRID),	AH	; '5'-RC5; 'S'-SONY; 'M'-MATSUSHITA; 'N'-NEC; 'E'-ERROR
		rjmp L_fIRShiftBuff_Ret
		;> Detect infrared code formats (RC5; SONY; MATSUSHITA; NEC)

 L_fIRShiftBuff_NoSync:
		lds		AH,		(v_IRBits)
		sbrs	AH,		0
		rjmp L_fIRShiftBuff_Ret
 			;< Shift only even bit
	;		ldi	AH,	IrPulseThershold(1152)
			ldi	AH,	IrPulseThershold(1300)
			cp	AH,	AL	; если длительность импульса/паузы больше пороговой
									; сдвигаем в буфер единицу иначе ноль.

			; LSB is transmitted first
			lds		AL,	(v_IR_Buff+0)
			ror		AL
			sts		(v_IR_Buff+0),	AL
			lds		AL,	(v_IR_Buff+1)
			ror		AL
			sts		(v_IR_Buff+1),	AL
			lds		AL,	(v_IR_Buff+2)
			ror		AL
			sts		(v_IR_Buff+2),	AL
			lds		AL,	(v_IR_Buff+3)
			ror		AL
			sts		(v_IR_Buff+3),	AL
 			;> Shift only even bit
		rjmp L_fIRShiftBuff_Ret
	;> Continuation the IR pulses

 L_fIRShiftBuff_Start:
	;< Starting IR pulse
	ser		AH
	sts		(v_IRBits),	AH
	sts		(v_IR_Buff+0)	,ZERO
	sts		(v_IR_Buff+1)	,ZERO
	sts		(v_IR_Buff+2)	,ZERO
  sts		(v_IR_Buff+3)	,ZERO

	mFlgSet	flg_IRStart	; Ќачало посылки IR кода
	in	AL,						TCNT0
	sts	(v_IRTCNT0),	AL
	mSetTimerTask fIRTimeOut,100ms
	;> Starting IR pulse

L_fIRShiftBuff_Ret:

		pop		AH
		pop		AL
		ret
	;
ENDP fIRShiftBuff

PROC fIRTimeOut
	mDI_EXT	INT5

	mFlgClr	flg_IRStart
	lds		AL	,(v_IRID)
	cpi		AL	,'N';-NEC;
 	brne (pc+1)+1
 		rcall fIRDecodeNEC

	cpi		AL	,'5';-RC5;
 	brne (pc+1)+1
 		rcall fIRDecodeRC5

	cpi		AL	,'S';-SONY;
 	brne (pc+1)+1
 		rcall fIRDecodeSONY

	cpi		AL	,'M';-MATSUSHITA;
 	brne (pc+1)+1
 		rcall fIRDecodeMATSUSHITA

 	mFlgClr	flg_IRStart

 	mEI_EXT	INT5
 	ret
ENDP fIRTimeOut

PROC fIRDecodeRC5
	push	AL
	;
	pop		AL

	ret

ENDP fIRDecodeRC5

PROC fIRDecodeSONY
	push	AL
	;
	pop		AL

	ret

ENDP fIRDecodeSONY

PROC fIRDecodeMATSUSHITA
	push	AL
	;
	pop		AL

	ret

ENDP fIRDecodeMATSUSHITA

PROC fIRDecodeNEC
	push	AL
	;< For NEC only
	clr		AH
	clr		BL
	lds		AL,	(v_IR_Buff+0)
	eor		AH,	AL
	or		BL,	AL
	sts		(v_IR_Code+0)	,AL

	lds		AL,	(v_IR_Buff+1)
	eor		AH,	AL
	or		BL,	AL
	sts		(v_IR_Code+1)	,AL

	lds		AL,	(v_IR_Buff+2)
	eor		AH,	AL
	or		BL,	AL
	sts		(v_IR_Code+2)	,AL

	lds		AL,	(v_IR_Buff+3)
	eor		AH,	AL
	or		BL,	AL
	sts		(v_IR_Code+3)	,AL
  breq (pc+1)+1+1+1+2+2+2+2 ;-----------+
    tst   AH        				;           |
    brne (pc+1)+1+2+2+2+2   ;--------+  |
      mFlgSet flg_IR_OK;    				 |  |
      lds	AL					,(v_IR_Buff+3);|  |
      sts	(v_IR_Addr)	,AL           ;|  |
      lds	AL					,(v_IR_Buff+1);|  |
      sts	(v_IR_Cmd)	,AL           ;|  |
    ;                <---------------+  |
  ;                  <------------------+
	;> For NEC only
	pop		AL
	ret

ENDP fIRDecodeNEC




;< MAP KEY for  VCD/MP3 JX-2001 
;++=======+=====+ +=======+=====+ +=======+=====+ +=======+=====+
;||  Key  | Cmd | |  Key  | Cmd | |  Key  | Cmd | |  Key  | Cmd |
;++=======+=====+ +=======+=====+ +=======+=====+ +=======+=====+
;|| POWER |0x10 | |   b   |0x03 | |   Ш   |0x01 | |   #   |0x06 |
;++-------+-----+ +-------+-----+ +-------+-----+ +-------+-----+
;||   1   |0x09 | |   2   |0x1D | |   3   |0x1F | |   4   |0x0D |
;++-------+-----+ +-------+-----+ +-------+-----+ +-------+-----+
;||   5   |0x19 | |   6   |0x1B | |   7   |0x11 | |   8   |0x15 |
;++-------+-----+ +-------+-----+ +-------+-----+ +-------+-----+
;||   9   |0x17 | | 10/0  |0x12 | |  10+  |0x16 | | Time  |0x4C |
;++-------+-----+ +-------+-----+ +-------+-----+ +-------+-----+
;||  OSD  |0x40 | |REPEAT |0x48 | | SLOW  |0x04 | | MODE  |0x00 |
;++-------+-----+ +-------+-----+ +-------+-----+ +-------+-----+
;||  VOL- |0x02 | | VOL+  |0x05 | |RETURN |0x54 | |  PBC  |0x4D |
;++-------+-----+ +-------+-----+ +-------+-----+ +-------+-----+
;||  <<   |0x0A | |  >>   |0x1E | |  |<<  |0x0E | |  >>|  |0x1A |
;++-------+-----+ +-------+-----+ +-------+-----+ +-------+-----+
;||  R/L  |0x1C | |  >||  |0x14 | | STOP  |0x0F | |  P/N  |0x0C |
;++=======+=====+ +=======+=====+ +=======+=====+ +=======+=====+
;> MAP KEY for  VCD/MP3 JX-2001 

PROC fIR_Command
	mIfFlgCLR flg_IR_OK, rjmp L_fIR_Command_Exit
	rcall	fIRPrint

	lds		AL,	(v_IR_Cmd)

;< Sets rvIndxServo (0..7) at Key "1".."8";OR -90 0 90 at Key "10/0" "9" "10+"
	cpi		AL,	0x09 ; Key 1
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	0
		rjmp L_fIR_Command_Handle
	;>

	cpi		AL,	0x1D ; Key 2
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	1
		rjmp L_fIR_Command_Handle
	;>

	cpi		AL,	0x1F ; Key 3
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	2
		rjmp L_fIR_Command_Handle
	;>

	cpi		AL,	0x0D ; Key 4
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	3
		rjmp L_fIR_Command_Handle
	;>

	cpi		AL,	0x19 ; Key 5
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	4
		rjmp L_fIR_Command_Handle
	;>

	cpi		AL,	0x1B ; Key 6
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	5
		rjmp L_fIR_Command_Handle
	;>

	cpi		AL,	0x11 ; Key 7
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	6
		rjmp L_fIR_Command_Handle
	;>

	cpi		AL,	0x15 ; Key 8
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	7
		rjmp L_fIR_Command_Handle
	;>

	cpi		AL,	0x17 ; Key 9
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	8
		rjmp L_fIR_Command_Handle
	;>
	
	cpi		AL,	0x12 ; Key 10/0
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	9
		rjmp L_fIR_Command_Handle
	;>
	
	cpi		AL,	0x16 ; Key 10+
	;<
	brne (pc+1)+1+1
		ldi	rvIndxServo,	10
		rjmp L_fIR_Command_Handle
	;>

;> Sets rvIndxServo (0..7) at Key "1".."8";OR -90 0 90 at Key "10/0" "9" "10+"

;;< Sets fInit_FM_LS at Key "MODE"
;cpi		AL,	0x00 ; Key "MODE"
;	;<
;	brne (pc+1)+1+1
;		rcall	fInit_FM_LS
;		rjmp L_fIR_Command_Handle
;	;>
;;> Sets fInit_FM_LS at Key "MODE"

;< Sets fSearch_Finish at Key "square"
cpi		AL,	0x01 ; Key "square"
	;<
	brne (pc+1)+1+1
		rcall	fSearch_Finish
		rjmp L_fIR_Command_Handle
	;>
;> Sets fSearch_Finish at Key "square"

;< Sets "flg_Lamp = 1" at Key "b"
cpi		AL,	0x03 ; Key "b"
	;<
	brne (pc+1)+1+1
		mFlgSet flg_Lamp
		rjmp L_fIR_Command_Handle
	;>
;> Sets "flg_Lamp = 1" at Key "b"
		
;< Sets fAdjustAtMonet at Key "Time"
cpi		AL,	0x4C ; Key "Time"
	;<
	brne (pc+1)+1+1
		rcall	fAdjustAtMonet
		rjmp L_fIR_Command_Handle
	;>
;> Sets fAdjustAtMonet at Key "Time"
	
	cpi		AL,	0x06 ; #
	;<
	brne (pc+1)+1+1+1
		rcall	fScanMonet
		rcall	fEvent
		rjmp L_fIR_Command_Handle
	;>


cpi		AL,	0x1C
	;<
	brne (pc+1)+1+1
		ori	rvSpeedLR, 0x40
		rjmp L_fIR_Command_Handle
	;>

cpi		AL,	0x0C
	;<
	brne (pc+1)+1+1
		ori	rvSpeedLR, 0x04
		rjmp L_fIR_Command_Handle
	;>

cpi		AL,	0x0F
	;<
	brne (pc+1)+1+1
		ldi	rvSpeedLR, 0x00
		rjmp L_fIR_Command_Handle
	;>

cpi		AL,	0x54
	;<
	brne (pc+1)+1+1+1
		ldi	AL,	0x80
		eor	rvSpeedLR,	AL
		rjmp L_fIR_Command_Handle
	;>

cpi		AL,	0x4D
	;<
	brne (pc+1)+1+1+1
		ldi	AL,	0x08
		eor	rvSpeedLR,	AL
		rjmp L_fIR_Command_Handle
	;>
cpi		AL,	0x14 ; Key "PLAY"
	;<
	brne (pc+1)+1+1
    rcall fMelodyFinish
  	rjmp L_fIR_Command_Handle
	;>

  rjmp L_fIR_Command_Exit ;The Command No Handle 

 L_fIR_Command_Handle:
	mFlgClr	flg_IR_OK
	
 L_fIR_Command_Exit:
	mSetTimerTask fIR_Command,310ms
	ret
ENDP fIR_Command

PROC fIRPrint
#define		r_Tmp r20
;	mIfFlgCLR flg_IR_OK,ret
;	mFlgClr	flg_IR_OK


;	rcall	fLCDBuffCLR
	mMemFill v_LCDBuf,(v_LCDBuf+LCDBUFFSIZE),' '
	ldi		AL						,'I'
	sts		(v_LCDBuf1+0)	,AL
	ldi		AL						,'R'
	sts		(v_LCDBuf1+1)	,AL

	lds		AL						,	(v_IRID)
	sts		(v_LCDBuf1+3)	,AL

		LDW	Y							,(v_LCDBuf1+5)
		lds	AL						,(v_IRBits)
		mov	AH						,ZERO
		rcall	fw2a


	LDW		Y,	(v_LCDBuf2)
	LDW 	X,	(v_IR_Addr)

	ldi		r_Tmp,	2
 L_fIRPrint:
		ld		AL,	x+

		mov		AH,	AL
		cbr		AL,	0xF0
		swap	AH
		cbr		AH,	0xF0

		ori		AL,	'0'
		ori		AH,	'0'

		cpi		AL,	'9'+1
		brlo pc+1+1
			subi	AL,	-7
		cpi		AH,	'9'+1
		brlo pc+1+1
			subi	AH,	-7

		st		y+,	AH
		st		y+,	AL


		dec		r_Tmp
	brne L_fIRPrint


#undef r_Tmp
;;----------------+
;    ;|01234567| ;|
; .db "01020304" ;|
; .db "05060708" ;|
;;----------------+
	ret

ENDP fIRPrint













