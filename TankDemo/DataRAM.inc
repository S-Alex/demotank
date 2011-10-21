;File DataRAM.inc
.dseg
.nolist
.org	SRAM_START
;###############################################################################
FistUseRAM:;	.byte	1

;
	;< struct v_FM
  	v_FM:
  	v_FMCur:
  	v_FMCurL:	.byte	1
  	v_FMCurH:	.byte	1
  	v_FMOld:
  	v_FMOldL:	.byte	1
  	v_FMOldH:	.byte	1
  	v_FMMid:
  	v_FMMidL:	.byte	1
  	v_FMMidH:	.byte	1
  	
  	
  ;	v_FMMinL:	.byte	1
  ;	v_FMMinH:	.byte	1
  ;	v_FMMaxL:	.byte	1
  ;	v_FMMaxH:	.byte	1
	;> struct v_FM

	v_CntMonet: .byte 1	;	

	;< struct v_LS
	v_LS:
	v_LSCur:
	v_LSCurL:	.byte	1
	v_LSCurH:	.byte	1
	v_LSOld:
	v_LSOldL:	.byte	1
	v_LSOldH:	.byte	1
	v_LSMid:
	v_LSMidL:	.byte	1
	v_LSMidH:	.byte	1
.def	vrLSCnt = r4
	;> struct v_LS

	v_NCoder:	.byte	1

	;< struct v_Crawler
	v_Crawler:
	v_CrawlerCurPosL:	.byte	1
	v_CrawlerPosL:		.byte	1
	v_CrawlerCurPosR:	.byte	1
	v_CrawlerPosR:		.byte	1
	;> struct v_Crawler

	v_fptrMoveEX:			.byte	2	; Указатель на список команд движения во ФЛЕШЕ
	v_fptrSpeed:			.byte	2	; Указатель на список команд движения во ФЛЕШЕ

	;< struct v_GND
	v_GND:
	v_GNDCur:
	v_GNDCurFR:		.byte	1	;FRONT-R
	v_GNDCurFL:		.byte	1	;FRONT-L
	v_GNDCurRR:		.byte	1	;REAR-R
	v_GNDCurRL:		.byte	1	;REAR-L
	v_GNDMin:
	v_GNDMinFR:		.byte	1	;FRONT-R
	v_GNDMinFL:		.byte	1	;FRONT-L
	v_GNDMinRR:		.byte	1	;REAR-R
	v_GNDMinRL:		.byte	1	;REAR-L
	v_GNDMax:
	v_GNDMaxFR:		.byte	1	;FRONT-R
	v_GNDMaxFL:		.byte	1	;FRONT-L
	v_GNDMaxRR:		.byte	1	;REAR-R
	v_GNDMaxRL:		.byte	1	;REAR-L
;	v_GNDMid:
;	v_GNDMidFR:		.byte	1	;FRONT-R
;	v_GNDMidFL:		.byte	1	;FRONT-L
;	v_GNDMidRR:		.byte	1	;REAR-R
;	v_GNDMidRL:		.byte	1	;REAR-L
	;> struct v_GND

;< struct Event
	v_Event:
	v_Event_LFL: 		.byte 1	;	LINE FRONT-L
	v_Event_LRL:		.byte 1	; LINE REAR-L
	v_Event_LFR:		.byte 1	; LINE FRONT-R
	v_Event_LRR:		.byte 1	; LINE REAR-R
	v_Event_BampF:	.byte 1	;	Препятствие спереди
	v_Event_BampR:	.byte 1	;	Препятствие сзади
	v_Event_Lamp: 	.byte 1	; переменна в которой хранитс задача на источник света
	v_Event_Monet:	.byte 1	; задача если найдена монетка
	v_Event_StepL: 	.byte 1	;
	v_Event_StepR:	.byte 1	;
	v_Event_EndMov: .byte 1 ; Task at THE END of current MOVE LIST
	v_Event_Melody: .byte 1 ; Task at THE END of current MELODY


;> struct Event

	v_DivNote:	.byte	2	; Предделитель для тональности ноты
	v_fptrSND:	.byte	2	; Указатель на мелодию во ФЛЕШЕ


LastUseRAM:	.byte	1+5
;###############################################################################

;###############################################################################
.cseg
.list
.listmac
;###############################################################################
;###############################################################################

;###############################################################################
;S_Alex
