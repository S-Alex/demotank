;File KBD_3x1.asm
;Updated: "2011-03-07" "19:41"

PROC fKBDInit
	sts		(v_KBD_LK),	ZERO
	ret

ENDP fKBDInit

PROC fKBDScan
#define SREG_ r19
  push  SREG_
  ;< critical section
  in    SREG_,  SREG  ; Critical Section
  cli


	mPinGetDir	SB2
	bld		AH,	bit0
	mPinGetDir	SB3
	bld		AH,	bit1
	mPinGetDir	SB4
	bld		AH,	bit2

	mPinIn	SB2
	mPinIn	SB3
	mPinIn	SB4
	mPinSET	SB2
	mPinSET	SB3
	mPinSET	SB4
	
	ldi AL, 0
	  dec AL
  brne (pc)-1

	ser		AL
	mPinState	SB2
	bld		AL,	bit0
	mPinState	SB3
	bld		AL,	bit1
	mPinState	SB4
	bld		AL,	bit2
	com		AL
	
	bst		AH,	bit0
	mPinSetDir	SB2
	bld		AH,	bit1
	mPinSetDir	SB3
	bld		AH,	bit2
	mPinSetDir	SB4
	
  out   SREG, SREG_ ; leave Critical Section
  ;> critical section
  pop   SREG_
	ret
#undef  SREG_

ENDP fKBDScan

;PROC fKBDGetKey
;  rcall fKBDScan
;  tst		AL
;  breq LfKBDGetKeyNoK
;  
;  lds		AH,					(v_KBD_LK)
;  cp		AL,					AH
;  brne LfKBDGetKeyEnd
;  sts		(v_KBD_LK), AL
;  
;  lds		AH,					(v_KBD_TK)
;  dec		AH
;  sts   (v_KBD_TK), AH
;  
;;
;	brne LfKBDGetKeyEnd
;  mFlgSet	flg_AnyKey
;  lds		AH,					(v_KBD_AR)
;  dec		AH
;  cpi		AH,					KEYAUTOREP
;  brsh (pc+1)+1
;  	ldi	AH,	KEYAUTOREP
;  sts   (v_KBD_TK), AH
;;    
;  rjmp     LfKBDGetKeyEnd
;LfKBDGetKeyNoK:
;  mFlgClr	flg_AnyKey
;  ldi		AL,	KEYREPTIME
;  sts   (v_KBD_TK), AL
;  clr		AL
;LfKBDGetKeyEnd:    
;  
;  sts   (v_KBD_LK), AL
;  
;NoFun:
;  ret
;	
;	ret
;
;ENDP fKBDGetKey


;S_Alex
