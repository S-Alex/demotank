	.ifndef Fclk
		.set	Fclk = 1000000 ;Hz
			.warning ""
			.message "+-----------------------+"
			.message "| Fclk  = 1000000 Hz    |"
			.message "+-----------------------+"
	.else

	.endif

.macro mWaitUS
	.if ((@0*Fclk/10000) - (@0*Fclk/1000000)*100)>= 50;%
		mWait_Cycle (@0*Fclk/1000000+1)
	.else
		mWait_Cycle (@0*Fclk/1000000)
	.endif
.endmacro

.macro mDelay_Us
	.if ((@0*Fclk/10000) - (@0*Fclk/1000000)*100)>= 50;%
		.set Cycles = (@0*Fclk/1000000)+1
	.else
		.set Cycles = (@0*Fclk/1000000)
	.endif
		mWait_Cycle Cycles
.endmacro

.macro mWait_Cycle
	.if @0 == 0
		.message "No left cycles"
	.elif @0 == 1
		nop
	.elif @0 == 2
		rjmp (pc+1)
		
	.elif @0 == 3
		rjmp	pc+1	;2
		nop
		
	.elif @0 == 4
		rjmp	pc+1	;2
		rjmp	pc+1	;2
		
	.elif @0 == 5
		rjmp	pc+1	;2
		rjmp	pc+1	;2
		nop
		
	.elif @0 == 6
		rjmp	pc+1	;2
		rjmp	pc+1	;2
		rjmp	pc+1	;2
		
	.elif @0 == 7
		push	r0		;2
		lpm         ;3
		pop		r0    ;2
		
	.elif (@0>7)&&(@0<=(exp2(8)*3)+4)
		.set Cyc = 3;+4
		.set	Loops = (@0-4)/Cyc
		push	r16              ;c 2
		ldi		r16,	low(Loops) ;c 1   \     
			dec	r16							 ;c 1    > *3
		brne	(pc-1)					 ;c 2/1 /
		pop		r16							 ;c 2     
		.set	Cyc_Left = @0-(Loops*Cyc+4)
		mWait_Cycle Cyc_Left
		
	.elif (@0>exp2(8)*3)&&(@0<=(exp2(16)*4+1))
		.set Cyc = 4;+1
		.set	Loops = (@0-1)/Cyc
		ldi	ZL,		low(Loops)		;c 1   > +1
		ldi	ZH,		high(Loops)		;c 1   \
			sbiw	ZL,1						;c 2    > *4
		brne	(pc-1)						;c 2/1 /
		.set Cyc_Left = @0-(Loops*Cyc+1)
		mWait_Cycle Cyc_Left
		
	.elif (@0>(exp2(16)*4+1))&&(@0<=(exp2(24)*5+2))
		.set Cyc = 5;+2
		.set	Loops = (@0-2)/Cyc
		ldi	ZL,		low(Loops)		;c 1   \
		                        ;       > +2
		ldi	ZH,		high(Loops)		;c 1   /
		ldi	r16,	byte3(Loops)	;c 1   \
			sbiw	ZL,1						;c 2    \
			                      ;        > *5
			sbci	r16,0						;c 1    /
		brne	(pc-1-1)					;c 2/1 /
		.set Cyc_Left = @0-(Loops*Cyc+2)
		mWait_Cycle Cyc_Left
		
	.elif (@0>(exp2(24)*5+2))&&(@0<=(exp2(32)*6+3))
		.set Cyc = 6;+3
		.set	Loops = (@0-3)/Cyc
		ldi		XL,low(Loops)     ;c 1   \
		ldi		XH,high(Loops)    ;c 1    > +3
		ldi		ZL,byte3(Loops)   ;c 1   /
		ldi		ZH,byte4(Loops)   ;c 1   \
			sbiw	Xl              ;c 2    \
		  sbci	ZL,0            ;c 1     > *6
		  sbci	ZH,0            ;c 1    /
		brne	(pc-1-1-1)        ;c 2/1 /
		.set Cyc_Left = @0-(Loops*Cyc+3)
		mWait_Cycle Cyc_Left
	.else
		.message "Delay to big"
		.message "рш врн, я слю яньек?"
	.endif
.endmacro