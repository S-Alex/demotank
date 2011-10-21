;File Interrupt.inc
;Updated: "2011-03-07" "11:36"
.nolist
#ifndef	INTERRUPT_INC
	#define	INTERRUPT_INC 1
;<
	#ifndef MACROEX_INC
		#include "MacroEX.asm"
	#endif

;Table 50.   Interrupt Sense Control
;ISCn1|ISCn0| Description
;  0  |   0  | The low level of INTn generates an interrupt request.
;  0  |   1  | Any logical change on INTn generates an interrupt request
;  1  |   0  | The falling edge between two samples of INTn generates an interrupt request.
;  1  |   1  | The rising edge between two samples of INTn generates an interrupt request.
	.equ	EXTLOW = 0
	.equ	EXTANY = 1
	.equ	EXTFAL = 2
	.equ	EXTRIS = 3 
	.macro mExtIntType;0-7,(EXTLOW or EXTANY or EXTFAL or EXTRIS)
		push	r16
		.if @0>4
			mIn		r16,	EICRB
			cbr		r16,	@1<<((@0&0b11)*2)
			ori		r16,	@1<<((@0&0b11)*2)
			mOut	EICRB,	r16
		.else
			mIn	r16,	EICRA
;			.equ tempEICRA = 0b11<<((@0&0b11)*2)
;			.equ tempEI = ((@0 & 0b11))
			
			cbr		r16,	@1<<((@0&0b11)*2)
			ori		r16,	@1<<((@0&0b11)*2)
			mOut	EICRA,	r16
		.endif
		mIn		r16,		EIMSK
		sbr		r16,		exp2(@0)
		mOut	EIMSK,	r16
		pop		r16
	.endmacro
	.macro mEI_EXT;0-7
		push	r16
		mIn		r16,		EIMSK
		sbr		r16,		exp2(@0)
		mOut	EIMSK,	r16
		pop		r16
	.endmacro
	.macro mDI_EXT
		push	r16
		in 		r16,		EIMSK
		cbr		r16,		(1<<@0)
		out		EIMSK,	r16
		pop		r16
	.endmacro
	;------------------------------------------------------
;>
#else
	#warning "----------------------------------------------";
	#message "### Duplicate include file '" __FILE__ "' ###";
	#message "----------------------------------------------";
#endif
.list
.listmac
.exit
;S_Alex
