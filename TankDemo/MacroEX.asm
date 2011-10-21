;File:  "MacroEX.asm"
;Updated: "2011-03-07" "19:41"
;
#ifndef MACROEX_INC
#define MACROEX_INC 1
 #define sz(Name,String) sz_ ## Name: .db String,0
;<
  ;###############################################################################
  ;###################### Common Macros ##########################################
  ;###############################################################################
  ;
  .macro  SetStack
      ldi    r16,   low(@0)
      out    SPL,   r16
      ldi    r16,   high(@0)
      out    SPH,   r16
  .endmacro
  ;###############################################################################
  ;###############################################################################
  
  .macro LDW
    ldi @0H,high(@1)
    ldi @0L,low(@1)
  .endmacro
  
   .macro LDWY
    ldi YH,high(@0)
    ldi YL,low(@0)
  .endmacro
 
  ;###############################################################################
  ;###############################################################################
  .macro mPUSHw
      push    @0H
      push    @0L
  .endmacro
  .macro mPOPw
    pop   @0L
    pop   @0H
  .endmacro
  .macro alignD
  .if (@0==2)||(@0==4)||(@0==8)||(@0==16)
    LA:
    .if LA & (@0-1)
      .warning ""
      .message "+---------------------------------------+";
      .message "| Not used DATA. See NoUse in map file. |"
      .message "+---------------------------------------+";
      .set NoUse = ((LA + (@0-1)) & ~(@0-1))-LA
    .endif
    .org  ((LA + (@0-1)) & ~(@0-1))
  .else
    .error "Align not valid."
  .endif
    ;
  .endmacro
  ;###############################################################################
  ;############################ High Level Macro #################################
  ;###############################################################################
  .macro  PROC
    .equ @0 = (pc)
  .endmacro
  
  .macro  CPROC
    .equ @0 = (pc)
  .endmacro
  
  .macro  ENDP
    .equ  SizeOf_@0=(pc-@0)
  .endmacro
  ;###############################################################################
  ;###############################################################################
  
  ;###############################################################################
  ;------------------------------------------------;
  ; Long branch
  .macro  rjne
      breq  (pc+1)+1
      rjmp  @0
  .endmacro
  
  .macro  rjeq
    brne  (pc+1)+1
    rjmp  @0
  .endmacro
  
  .macro  rjcc
    brcs  (pc+1)+1
    rjmp  @0
  .endmacro
  
  .macro  rjcs
    brcc  (pc+1)+1
    rjmp  @0
  .endmacro
  
  .macro  rjtc
    brts  (pc+1)+1
    rjmp  @0
  .endmacro
  
  .macro  rjts
    brtc  (pc+1)+1
    rjmp  @0
  .endmacro
  
  .macro  rjge
    brlt  (pc+1)+1
    rjmp  @0
  .endmacro
  
  .macro  rjlt
    brge  (pc+1)+1
    rjmp  @0
  .endmacro
  
  
  .macro  retcc
    brcs  (pc+1)+1
    ret
  .endmacro
  
  .macro  retcs
    brcc  (pc+1)+1
    ret
  .endmacro
  
  .macro  reteq
    brne  (pc+1)+1
    ret
  .endmacro
  
  .macro  retne
    breq  (pc+1)+1
    ret
  .endmacro
  
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  .macro  rr
    bst   @0, 0
    lsr   @0
    bld   @0, 7
  .endmacro
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  .macro  rl
    bst   @0, 7
    lsl   @0
    bld   @0, 0
  .endmacro
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  .macro stsi
    push  r16
    ldi   r16,  @1
    sts   @0, r16
    pop   r16
  .endmacro
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  .macro  sbm
    lds   r16,  @0
    ori   r16,  1<<@1
    sts   @0,   r16
  .endmacro
  
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  .macro  cbm
    lds   r16,  @0
    andi  r16,  ~(1<<@1)
    sts   @0,   r16
  .endmacro
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  .macro  addi
    subi  @0, -@1
  .endmacro

  ;/////////////////////////////////////////////////////////////////
  .macro mEquPin  ;NameOfPin,Port,BitNumber
  .equ  P_@0  = @1
  .equ  @0    = @2
  .endmacro
  ;--------------------------------------------------------------------------------
  .macro  mPinOut ;NameOfPin
    .if (P_@0-1)>(0x3f)
      push  r16
      lds   r16,    P_@0-1
      sbr   r16,    (1<<@0)
      sts   P_@0-1, r16
      pop   r16
    .else
      sbi   P_@0-1, @0
    .endif
  .endmacro
  ;--------------------------------------------------------------------------------
  .macro  mPinIn  ;NameOfPin
    .if (P_@0-1)>(0x3f)
      push  r16
      lds   r16,    P_@0-1
      cbr   r16,    (1<<@0)
      sts   P_@0-1, r16
      pop   r16
    .else
      cbi   P_@0-1, @0
    .endif
  .endmacro
  ;--------------------------------------------------------------------------------
  
  ;-----------------------------------------------------------------
  .macro  mPinGetDir  ;NameOfPin
    push  r16
    .if (P_@0-1)>(0x3f)
      lds   r16,  P_@0-1
    .else
      in    r16,  P_@0-1
    .endif
      bst   r16,  @0
    pop   r16
  .endmacro

  .macro  mPinSetDir  ;NameOfPin
    .if (P_@0-1)>(0x3f)
      push  r16
      lds   r16,    P_@0-1
      brtc (pc+1)+1
        sbr   r16,    (1<<@0)
      brts (pc+1)+1
        cbr   r16,    (1<<@0)
      sts   P_@0-1, r16
      pop   r16
    .else
      brtc (pc+1)+1
      sbi   P_@0-1, @0
      brts (pc+1)+1
      cbi   P_@0-1, @0
    .endif
      
  .endmacro
  
  
  .macro  mPinSET ;NameOfPin
    .if P_@0 > (0x3f);
      push  r16
      push  r17
      in    r17   ,SREG
      lds   r16   ,P_@0
      sbr   r16   ,(1<<@0)
      sts   P_@0  ,r16
      out   SREG  ,r17
      pop   r17
      pop   r16
    .else
      sbi   P_@0  ,@0
    .endif
  .endmacro
  ;-----------------------------------------------------------------
  .macro  mPinCLR
    .if P_@0 > (0x3f);
      push  r16
      push  r17
      in    r17   ,SREG
      lds   r16   ,P_@0
      cbr   r16   ,(1<<@0)
      sts   P_@0  ,r16
      out   SREG  ,r17
      pop   r17
      pop   r16
    .else
      cbi   P_@0  ,@0
    .endif
  .endmacro
  
  .macro  mPinCpl
    push  r16
    push  r17
    push  r18
    in    r18   ,SREG
    .if P_@0>(0x3f)
      lds   r16,  P_@0
      ldi   r17,  1<<@0
      eor   r16,  r17
      sts   P_@0, r16
    .else
      in    r16,  P_@0
      ldi   r17,  1<<@0
      eor   r16,  r17
      out   P_@0, r16
    .endif
    out   SREG  ,r18
    pop   r18
    pop   r17
    pop   r16
  .endmacro
  
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  .macro  mPinState
    push  r16
    .if (P_@0-2)>(0x3f)
      lds   r16,  P_@0-2
    .else
      in    r16,  P_@0-2
    .endif
      bst   r16,  @0
    pop   r16
  .endmacro
  
  ;/////////////////////////////////////////////////////////////////
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  .ifdef  PROTEUS
    .macro  mStop
      mPinCLR Stop
      mPinSET Stop
  ;   sbi   Stop_P,Stop_Bit
  ;   cbi   Stop_P,Stop_Bit
    .endmacro
  .endif
  ;/////////////////////////////////////////////////////////////////
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  
  ;###############################################################################
  ;< Flags. New version.
  .ifndef r_Flags
    .def  r_Flags   = r22
    .def  r_FlagsH  = r22
    .message "+---------------------+"
    .message "| Info: r_Flags = r22 |"
    .message "| Info: r_FlagsH= r23 |"
    .message "+---------------------+"
  .else
  
  .endif
  .macro  mFlgSet
    ;Установим флаг
    .if @0<8
      ori   r_Flags,  1<<@0
    .else
      ori   r_FlagsH, 1<<(@0&0b111)
    .endif
  .endmacro
  
  .macro  mFlgClr
    ;Сбросим флаг
    .if @0<8
      cbr   r_Flags,  (1<<@0)
    .else
      cbr   r_FlagsH, 1<<(@0&0b111)
    .endif
  .endmacro
  
  .macro  mFlgCpl
    push  r16
    .if @0<8
      ldi   r16,    1<<@0
      eor   r_Flags,  r16
    .else
      ldi   r16,    1<<(@0&0b111)
      eor   r_FlagsH, r16
    .endif
    pop   r16
  .endmacro

  .macro  mFlgSkipClr
    .if @0<8
      sbrc  r_Flags,  @0
    .else
      sbrc  r_FlagsH, @0&0b111
    .endif
  .endmacro
  
  .macro  mFlgSkipSet
    .if @0<8
      sbrs  r_Flags,  @0
    .else
      sbrs  r_FlagsH, @0&0b111
    .endif
  .endmacro

  
  .macro  mFlgLd
    .if @0<8
      bld   r_Flags,  @0
    .else
      bld   r_FlagsH, @0&0b111
    .endif
  .endmacro
  ; Store Flag to T Flag
  .macro  mFlgSt
    .if @0<8
      bst   r_Flags,  @0
    .else
      bst   r_FlagsH, @0&0b111
    .endif
  .endmacro
  ;> Flags. New version.
  ;###############################################################################
  
  .macro  mTestFlag
    .if @0<8
      sbrc  r_Flags,  @0
    .else
      sbrc  r_FlagsH, @0&0b111
    .endif
  .endmacro
  
  .macro  mCallIfSET
    .if @0<8
      sbrc  r_Flags,  @0
      rcall @1
    .else
      sbrc  r_FlagsH, @0&0b111
      rcall @1
    .endif
  .endmacro
  
  .macro  mCallIfSETC
    .if @0<8
      sbrc  r_Flags,  @0
      rcall @1
      sbrc  r_Flags,  @0
      cbr   r_Flags,  1<<@0
    .else
      sbrc  r_FlagsH, @0&0b111
      rcall @1
      sbrc  r_FlagsH, @0
      cbr   r_FlagsH, 1<<(@0&0b111)
    .endif
  .endmacro
  
  .macro  mJmpIfSET
    .if @0<8
      sbrc  r_Flags,  @0
      rjmp  @1
    .else
      sbrc  r_FlagsH, @0&0b111
      rjmp @1
    .endif
  .endmacro
  
  .macro  mCallIfCLR
    .if @0<8
      sbrs  r_Flags,  @0
      rcall @1
    .else
      sbrs  r_FlagsH, @0&0b111
      rcall @1
    .endif
  .endmacro
  
  .macro  mJmpIfCLR
    .if @0<8
      sbrs  r_Flags,  @0
      rjmp  @1
    .else
      sbrs  r_FlagsH, @0&0b111
      rjmp @1
    .endif
  .endmacro
  
  .macro  mIfFlgSET
  ; mIfFlgSET flg_ADC,rjmp MainLoop
  ; mIfFlgSET flg_ADC,rcall MainLoop
    .if @0<8
      sbrc  r_Flags,  @0
      @1
    .else
      sbrc  r_FlagsH, @0&0b111
      @1
    .endif
  .endmacro
  
  .macro  mIfFlgCLR
  ; mIfFlgCLR flg_ADC,rjmp MainLoop
  ; mIfFlgCLR flg_ADC,rcall MainLoop
    .if @0<8
      sbrs  r_Flags,  @0
      @1
    .else
      sbrs  r_FlagsH, (@0&0b111)
      @1
    .endif
  .endmacro

  ;/////////////////////////////////////////////////////////////////
  ;\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  .macro mstiw
    push  r16
    ldi   r16,  low (@1)
    sts   (@0), r16
    ldi   r16,  high(@1)
    sts   (@0+1), r16
    pop   r16
  .endmacro
  
  
  ;mMemFill SRAM_START,RAMEND,$00
  .macro mMemFill
    .if @0<SRAM_START || @1>RAMEND
      .error "mMemFill: Parameter(s) out of range!"
    .else
      .message "Ok"
      ldi   YL,   low(@0)
      ldi   YH,   high(@0)
      ldi   ZL, @2
     LMemClr_Loop:
      st    y+,   ZL
      cpi   YL,   low(@1)   ;Compare low byte
      ldi   r16,  high(@1)  ;
      cpc   YH,   r16     ;Compare high byte
      brlo LMemClr_Loop
  
    .endif
  
  .endmacro

  .macro mAllRegZero
      ldi   YL,   28
      clr   YH
      clr   ZL
      clr   ZH
     L_AllRegZero:
      st    -y,   ZL
      tst   YL
      brne L_AllRegZero
  .endmacro

  .macro mOuti
    push  r16
      ldi   r16,  @1
    .if @0>(0x3f)
      sts   @0,   r16
    .else
      out   @0,   r16
    .endif
    pop   r16
  .endmacro 
  
  .macro mOut
    .if @0 > (0x3f)
      sts   @0,   @1
    .else
      out   @0,   @1
    .endif
  .endmacro 

  .macro mIn
    .if @1 > (0x3f)
      lds   @0,   @1
    .else
      in    @0,   @1
    .endif
  .endmacro 

  ;< FOR STRUCTURE
  #define SOI(Struc,Item) Struc##Item-Struc ;
  
  ;< FOR STRUCTURE
  #define GetEventID(Struc,Item) Struc##_##Item-Struc ;
  
  ; ;< struct v_GND
  ; v_GND:
  ; v_GNDCur:   .byte 4 ;
  ; v_GNDMin:   .byte 4 ;
  ; v_GNDMax:   .byte 4 ;
  ; ;> struct v_GND
  ; 
  ; ldd AH, y+SOI(v_GND,Min)
  ;> OR STRUCTURE

;>
#else
  #warning "----------------------------------------------";
  #message "### Duplicate include file '" __FILE__ "' ###";
  #message "----------------------------------------------";
#endif

.exit
;S_Alex
