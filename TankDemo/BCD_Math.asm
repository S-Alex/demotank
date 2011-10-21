;File: "BCD_Math.asm"
;Updated: "2011-03-07" "19:41"

;DAA
;(Decimal Adjust for Addition)
;���������� ��������� ����� ��������
;  ����� �������:  daa
;����������: ��������� ������������ ���������� �������� ���� BCD-����� � ����������� �������.
;���������
;�������� ������:
;������� �������� ������ � ��������� al � ����������� ������� ��������� ��������:
;
;�������� 1. � ���������� ���������� ������� �������� ���� HF=1 ��� �������� ������� ������� �������� al>9.
; HF = 1 � ������ �������� ������� �� ���� 3 � 4.
; ������� ������ �� ���� ���� ��������� ������� � ���, ��� �������� ������� ������� ��������� 0x09.
;
;�������� 2. � ���������� ���������� ������� �������� ���� CF=1 ��� �������� �������� al>9fh. ��������, ��� ���� cf ��������������� � 1 � ������ �������� �������� ������� � ������� ��� �������� (���� �������� ��������� 0ffh � ������ �������� al). ������� ������ �� ���� ���� ��������� ������� � ���, ��� �������� � �������� al ��������� 9fh.
;���� ����� ����� ���� �� ���� ���� ��������, �� ������� al �������������� ��������� �������:
;��� �������� 1 ���������� �������� al ������������� �� 6;
;��� �������� 2 ���������� �������� al ������������� �� 60h;
;���� ����� ����� ��� ��������, �� ������������� ���������� � ������� �������.



;.def  AL  = r16
;.def  AH  = r17

;################################## FUNCTION ###################################
;Name of function:
 ; fBCDAdd
;Input:
 ; AL , AH
;Return:
 ; AL = AL + AH. If  (AL + AH) > 99 then CF = 1
;Description:
 ; 2-digit packed BCD addition
 ; This proc adds the two unsigned 2-digit BCD numbers
;

;
; +---------->+---------->+---------------------->+(ret)->
;													!												!
;													!---------------------->!
;

PROC fBCDAdd
	add		AL,		AH
	rjmp	fBCDAdx
ENDP fBCDAdd

;################################## FUNCTION ###################################
;Name of function:
 ; fBCDAdc
;Input:
 ; AL , AH
;Return:
 ; AL = AL + AH + CF. If	(AL + AH) > 99 then CF = 1
;Description:
 ; 2-digit packed BCD addition with carry
 ; This proc adds the two unsigned 2-digit BCD numbers with carry
;

;
; +---------->+---------->+---------------------->+(ret)->
;													!												!
;													!---------------------->!
;

PROC fBCDAdc
	adc		AL,		AH
	rjmp	fBCDAdx
ENDP fBCDAdc


PROC fBCDAdx
	in		AH, SREG		; Seve CF into AH bit0
	subi	AL,		-6		; Add 6 to LSD, Pre correction
	;(!!! inverse logic HF and CF, Because use (subi AL, -(x)) instead of (add AL,(x) )
	brhc (pc+1)+1+1		; if half carry set (LSD > 9), needed correction
		sbrs	AH, HF		; if previous carry not set
			subi	AL, 6		;  cancel Pre correction
	;
	subi	AL, -0x60 ; Add 6 to MSD, Pre correction
	;(!!! inverse logic HF and CF, Because use (subi AL, -(x)) instead of (add AL,(x) )
	brcc (pc+1)+1+1		; if carry set (MSD > 9), needed correction
		sbrs	AH,		CF	; if previous carry not set
			subi	AL, 0x60; cancel Pre correction
	;
	ret
ENDP fBCDAdx


;################################## FUNCTION ###################################
;Name of function:
 ; fBCDSub
;Input:
 ; AL, AH
;Return:
 ; AL = AL - AH
;Description:
 ;2-digit packed BCD subtraction
 ;This subroutine subtracts the two unsigned 2-digit BCD numbers
;

;
; +---------->+---------->+---------------------->+(ret)->
;													!												!
;													!---------------------->!
;


PROC fBCDSub
	sub	AL,AH	;subtract the numbers binary

	in		AH, SREG		; Seve CF into AH bit0

;IF HF ==1 then LSD = LSD - 6
;IF CF == 1 then MSD = MSD - 6

	sbrc	AH,	HF		;if half carry clear skip
		subi	AL,$06	; LSD = LSD - 6
	;
	sbrc	AH,	CF		;if previous carry clear skip
		subi	AL,$60	; MSD = MSD - 6
	ret
ENDP fBCDSub
ret

;################################## FUNCTION ###################################
;Name of function:
 ; fBCDInc
;Input:
 ; AL - BCD
;Return:
 ; AL = AL + 1
;Description:
 ; -
;



PROC fBCDInc
	ldi		AH,	0x01
	rcall	fBCDAdd
	ret
ENDP fBCDInc

;################################## FUNCTION ###################################
;Name of function:
 ; fBCDDec
;Input:
 ; AL - BCD
;Return:
 ; AL = AL - 1
;Description:
 ; -
;


PROC fBCDDec
	ldi		AH,	0x01
	rcall	fBCDSub
	ret
ENDP fBCDDec

;################################## FUNCTION ###################################
;Name of function:
 ; fBin2BCD16
;Input:
 ; AH:AL - 16bit value
;Return:
 ; R15:R14:R13 - BCD
;Description:
 ; 16-bit Binary to BCD conversion
;



PROC fBin2BCD16

.equ	AtBCD0	=13		;address of tBCD0
.equ	AtBCD2	=15		;address of tBCD1

#define	tBCD0	r13	;BCD value digits 1 and 0
#define	tBCD1	r14	;BCD value digits 3 and 2
#define	tBCD2	r15	;BCD value digit 4

#define	rbinL	AL	;binary value Low byte
#define	rbinH	AH	;binary value High byte
#define	rvCNT	r18	;loop counter
#define	rvTmp	r19	;temporary value

; * Code *
	ldi		rvCNT,16	;Init loop counter
	clr		tBCD2		;clear result (3 bytes)
	clr		tBCD1
	clr		tBCD0
	clr		ZH			;clear ZH (not needed for AT90Sxx0x)
 bBCDx_1:
	lsl		rbinL		;shift input value
	rol		rbinH		;through all bytes
	rol		tBCD0		;
	rol		tBCD1
	rol		tBCD2
	dec		rvCNT		;decrement loop counter
	brne	bBCDx_2		;if counter not zero
	ret					;   return

 bBCDx_2:
	ldi		ZL,	AtBCD2+1	;Z points to result MSB + 1
 bBCDx_3:
	ld		rvTmp,	-z		;get (Z) with pre-decrement
	subi	rvTmp,	-$03	;add 0x03
	sbrc	rvTmp,	3		;if bit 3 not clear
	st		z,		rvTmp	;	store back
	ld		rvTmp,	z		;get (Z)
	subi	rvTmp,	-$30	;add 0x30
	sbrc	rvTmp,	7		;if bit 7 not clear
	st		z,		rvTmp	;	store back
	cpi		ZL,		AtBCD0	;done all three?
	brne	bBCDx_3			;loop again if not
	rjmp	bBCDx_1
#undef tBCD0
#undef tBCD1
#undef tBCD2
#undef rbinL
#undef rbinH
#undef rvCNT
#undef rvTmp
ENDP fBin2BCD16

PROC	fw2a_10
	LDW		X,	(0x0405)
	rjmp	fw2aEX
;	rcall fw2aEX
;
;	ret
ENDP fw2a_10

PROC	fw2a
	LDW	X,	(0xFFFF)
;	rcall fw2aEX
;
;	ret
ENDP fw2a

;################################## FUNCTION ###################################
;Name of function:
 ; fw2aEX
;Input:
 ; AH:AL - word (int)
 ; Y - SZ
 ; XL - ������� �������� ��������
 ; XH - ����� ������ ����� ���������� ����� 
;Return:
 ; -
 ;54321
 ;     ;
 ;BCD value digits 1 and 0
 ;BCD value digits 3 and 2
 ;BCD value digit 4
;Description:
 ;
;



PROC fw2aEX
#define	rCNT 	r18
#define	rflgZ	r19
#define	rTmp	r20

	push	rCNT	;
	push	rflgZ	; ���� �������� ����
	push	rTmp
	rcall fBin2BCD16
	ldi		rCNT,	5
	
	ldi		ZH,		5+1
	sub		ZH,		XH
	ldi		ZL,		5+1
	sub		ZL,		XL
	
	clr		rflgZ
	clr		XH
	ldi		XL,		AtBCD2		; X points to result MSB
 lw2a:
 		;< ���� ��������� ������ �� ��� ����� ���������� ���� ���� ��� "0" 
 		ldi		rTmp,	~0x01
		and		rTmp,	rCNT
		brne (pc+1)+1
			ser	rflgZ
		;> ���� ��������� ������ �� ��� ����� ���������� ���� ���� ��� "0"
		
		ld		rTmp,		x
		sbrs	rCNT,		bit0
		 swap	rTmp			; ���� ������ swap
		andi	rTmp,		0x0f
		or		rflgZ,	rTmp
		ori		rTmp,		'0'
		cpse	rflgZ,	ZERO
		 st		y+,			rTmp
		cpse	rflgZ,	ZERO
		 inc	AL
		 
		cp		rCNT,	ZL		; �������� �� ���������� ������ ������
		breq lw2a_ret			; ����� ���� ������ ����������� ����� ��������
		
		cp		rCNT,	ZH		; �������� �� ����� ������� ���������� �����
		brne lw2a_NoDP		; ������� ��� �� �������
		  tst	rflgZ				; ����� ������� ������� ���� ���� ����� ��������� ����� ������
		  brne (pc+1)+1+1+1+1
		  	inc	rflgZ			; ���������  ���� ���������� ������� �����
			  ldi	rTmp,	'0'	; ������� ������� ����
			  st	y+,		rTmp
	  		  inc	AL			; ��������� ������ ������
		  ldi	rTmp,	'.'		; ������� ���������� �����
		  st	y+,		rTmp
  		  inc	AL				; ��������� ������ ������
 lw2a_NoDP:
		dec		rCNT
		sbrs	rCNT,	bit0
		 ld		rTmp,	-x		; ���� ������ swap
	brne lw2a
 lw2a_ret:
	pop		rTmp
	pop		rflgZ
	pop		rCNT
	ret
#undef	rCNT	
#undef	rflgZ
#undef	rTmp
ENDP fw2aEX


