;File KBD_3x1.inc
;Updated: "2011-03-07" "11:36"




.nolist
#ifndef	KBD_3X1_INC
	#define	KBD_3X1_INC 1
;<
	#ifndef MACROEX_INC
		#include "MacroEX.asm"
	#endif
	
	#define	KEYREPTIME	10
	#define	KEYAUTOREP	3
	
	;##########################################################
	;##########################################################
	.dseg
	.nolist
		v_KBD_LK:	.byte	1
		v_KBD_TK:	.byte	1
		v_KBD_AR:	.byte	1
		
	.cseg
	.list
	.listmac
	;##########################################################
	;##########################################################

	
	.include	"KBD_3x1.asm"
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
