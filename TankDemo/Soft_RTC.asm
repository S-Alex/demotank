;File: "Soft_RTC.asm" for Test_IIST
;Updated: "2010-11-01" "00:31"

.nolist
.dseg
v_Time:
v_BCD_Hour:	.byte	1
v_BCD_Min:	.byte	1
v_BCD_Sec:	.byte	1
.cseg
.listmac

PROC fRTC_Init
	clr		AL
	ldi		AL,	0x00
	sts		(v_BCD_Hour),	AL
	sts		(v_BCD_Min),	AL
	sts		(v_BCD_Sec),	AL
	ret
ENDP fRTC_Init


PROC fRTC_Inc
	lds		AL,	(v_BCD_Sec)
	rcall fBCDInc
	sts		(v_BCD_Sec),AL
	cpi		AL,	0x60
	brne NoIncMin
		;Inc Min
		sts		(v_BCD_Sec),ZERO
		lds		AL,	(v_BCD_Min)
		rcall fBCDInc
		sts		(v_BCD_Min),AL
		cpi		AL,	0x60
		brne NoIncHour
			;Inc Hour
			sts		(v_BCD_Min),ZERO
			lds		AL,	(v_BCD_Hour)
			rcall fBCDInc
			sts		(v_BCD_Hour),AL
		NoIncHour:
	NoIncMin:
	
	ret
ENDP fRTC_Inc

PROC fRTC_Dec
	lds		AL,	(v_BCD_Sec)
	rcall fBCDDec
	sts		(v_BCD_Sec),AL
	cpi		AL,	0x99
	brne NoDecMin
		;Inc Min
		ldi		AL,	0x59
		sts		(v_BCD_Sec),AL
		lds		AL,	(v_BCD_Min)
		rcall fBCDDec
		sts		(v_BCD_Min),AL
		cpi		AL,	0x99
		brne NoDecHour
			;Inc Hour
			ldi		AL,	0x59
			sts		(v_BCD_Min),AL
			lds		AL,	(v_BCD_Hour)
			rcall fBCDDec
			sts		(v_BCD_Hour),AL
		NoDecHour:
	NoDecMin:
	
	ret
ENDP fRTC_Dec


PROC fRTC2Str
	lds		AL,	(v_BCD_Hour)
	andi	AL,	0x0F
	ori		AL,	'0'
	st		y+,	AL
	
	ldi		AL,	':'
	st		y+,	AL
	
	lds		AL,	(v_BCD_Min)
	swap	AL
	andi	AL,	0x0F
	ori		AL,	'0'
	st		y+,	AL

	lds		AL,	(v_BCD_Min)
	andi	AL,	0x0F
	ori		AL,	'0'
	st		y+,	AL
	
	ldi		AL,	':'
	st		y+,	AL

	lds		AL,	(v_BCD_Sec)
	swap	AL
	andi	AL,	0x0F
	ori		AL,	'0'
	st		y+,	AL

	lds		AL,	(v_BCD_Sec)
	andi	AL,	0x0F
	ori		AL,	'0'
	st		y+,	AL

	ret

ENDP fRTC2Str


;S_Alex