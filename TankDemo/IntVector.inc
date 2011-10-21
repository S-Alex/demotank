;File IntVector.asm
;
;###############################################################################
;#################### Interrupt Vector Table ###################################
;###############################################################################
;
;###############################################################################
#if defined(__ATmega8__)
.cseg
.org 0x00
  rjmp RESET    ;Reset Handler
;----
.org  INT0addr  ;External Interrupt0 Vector Address
  rjmp EXT_INT0 ;IRQ0 Handler
;----
.org  INT1addr  ;External Interrupt1 Vector Address
  rjmp EXT_INT1 ;IRQ1 Handler
;----
.org  OC2addr   ;Output Compare2 Interrupt Vector Address
  rjmp TIM2_COMP  ;Timer2 Compare Handler
;----
.org  OVF2addr  ;Overflow2 Interrupt Vector Address
  rjmp TIM2_OVF ;Timer2 Overflow Handler
;----
.org  ICP1addr  ;Input Capture1 Interrupt Vector Address
  rjmp TIM1_CAPT  ;Timer1 Capture Handler
;----
.org  OC1Aaddr  ;Output Compare1A Interrupt Vector Address
  rjmp TIM1_COMPA ;Timer1 CompareA Handler
;----
.org  OC1Baddr  ;Output Compare1B Interrupt Vector Address
  rjmp TIM1_COMPB ;Timer1 CompareB Handler
;----
.org  OVF1addr  ;Overflow1 Interrupt Vector Address
  rjmp TIM1_OVF ;Timer1 Overflow Handler
;----
;.org OVF0addr  ;Overflow0 Interrupt Vector Address
; rjmp TIM0_OVF ;Timer0 Overflow Handler
;----
.org  SPIaddr   ;SPI Interrupt Vector Address
  rjmp SPI_STC  ;SPI Transfer Complete Handler
;----
.org  URXCaddr  ;USART Receive Complete Interrupt Vector Address
  rjmp USART_RXC  ;USART RX Complete Handler
;----
.org  UDREaddr  ;USART Data Register Empty Interrupt Vector Address
  rjmp USART_UDRE ;UDR Empty Handler
;----
.org  UTXCaddr  ;USART Transmit Complete Interrupt Vector Address
  rjmp USART_TXC  ;USART TX Complete Handler
;----
.org  ADCCaddr  ;ADC Interrupt Vector Address
  rjmp ADCC   ;ADC Conversion Complete Handler
;----
.org  ERDYaddr  ;EEPROM Interrupt Vector Address
  rjmp EE_RDY   ;EEPROM Ready Handler
;----
.org  ACIaddr   ;Analog Comparator Interrupt Vector Address
  rjmp ANA_COMP ;Analog Comparator Handler
;----
.org    TWIaddr   ;Irq. vector address for Two-Wire Interface
  rjmp TWSI   ;2-wire Serial Interface Handler
;----
.org  SPMRaddr  ;SPM complete Interrupt Vector Address
  rjmp SPM_RDY  ;Store Program Memory Ready Handler
#endif

#if defined(__ATmega64__)
.cseg
.org 0x00
  rjmp RESET    ;Reset Handler

.org INT0addr  ;= 0x0002  ; External Interrupt Request 0
  rjmp INT_0
;---
.org INT1addr  ;= 0x0004  ; External Interrupt Request 1
  rjmp INT_1
;---
.org INT2addr  ;= 0x0006  ; External Interrupt Request 2
  rjmp INT_2
;---
;.org INT3addr  ;= 0x0008  ; External Interrupt Request 3
;  rjmp INT_3
;---
.org INT4addr  ;= 0x000a  ; External Interrupt Request 4
  rjmp INT_4
;---
;.org INT5addr  ;= 0x000c  ; External Interrupt Request 5
;  rjmp INT_5
;---
;.org INT6addr  ;= 0x000e  ; External Interrupt Request 6
;  rjmp INT_6
;---
.org INT7addr  ;= 0x0010  ; External Interrupt Request 7
  rjmp INT_7
;---
.org OC2addr   ;= 0x0012  ; Timer/Counter2 Compare Match
  rjmp INT_OC2
;---
.org OVF2addr  ;= 0x0014  ; Timer/Counter2 Overflow
  rjmp INT_OVF2
;---
.org ICP1addr  ;= 0x0016  ; Timer/Counter1 Capture Event
  rjmp INT_ICP1
;---
.org OC1Aaddr  ;= 0x0018  ; Timer/Counter1 Compare Match A
  rjmp INT_OC1A
;---
.org OC1Baddr  ;= 0x001a  ; Timer/Counter Compare Match B
  rjmp INT_OC1B
;---
;.org OVF1addr  ;= 0x001c  ; Timer/Counter1 Overflow
;  rjmp INT_OVF1
;---
;.org OC0addr   ;= 0x001e  ; Timer/Counter0 Compare Match
;  rjmp INT_OC0
;---
.org OVF0addr  ;= 0x0020  ; Timer/Counter0 Overflow
  rjmp INT_OVF0
;---
.org SPIaddr   ;= 0x0022  ; SPI Serial Transfer Complete
  rjmp INT_SPI
;---
.org URXC0addr ;= 0x0024  ; USART0, Rx Complete
  rjmp INT_URXC0
;---
.org UDRE0addr ;= 0x0026  ; USART0 Data Register Empty
  rjmp INT_UDRE0
;---
.org UTXC0addr ;= 0x0028  ; USART0, Tx Complete
  rjmp INT_UTXC0
;---
;.org ADCCaddr  ;= 0x002a  ; ADC Conversion Complete
;  rjmp INT_ADCC
;---
.org ERDYaddr  ;= 0x002c  ; EEPROM Ready
  rjmp INT_ERDY
;---
.org ACIaddr   ;= 0x002e  ; Analog Comparator
  rjmp INT_ACI
;---
.org OC1Caddr  ;= 0x0030  ; Timer/Counter1 Compare Match C
  rjmp INT_OC1C
;---
;.org ICP3addr  ;= 0x0032  ; Timer/Counter3 Capture Event
;  rjmp INT_ICP3
;---
;.org OC3Aaddr  ;= 0x0034  ; Timer/Counter3 Compare Match A
;  rjmp INT_OC3A
;---
;.org OC3Baddr  ;= 0x0036  ; Timer/Counter3 Compare Match B
;  rjmp INT_OC3B
;---
;.org OC3Caddr  ;= 0x0038  ; Timer/Counter3 Compare Match C
;  rjmp INT_OC3C
;---
;.org OVF3addr  ;= 0x003a  ; Timer/Counter3 Overflow
;  rjmp INT_OVF3
;---
.org URXC1addr ;= 0x003c  ; USART1, Rx Complete
  rjmp INT_URXC1
;---
.org UDRE1addr ;= 0x003e  ; USART1, Data Register Empty
  rjmp INT_UDRE1
;---
.org UTXC1addr ;= 0x0040  ; USART1, Tx Complete
  rjmp INT_UTXC1
;---
.org TWIaddr   ;= 0x0042  ; 2-wire Serial Interface
  rjmp INT_TWI
;---
.org SPMRaddr  ;= 0x0044  ; Store Program Memory Read
  rjmp INT_SPMR
;---


#endif


;###############################################################################
;###############################################################################
.org INT_VECTORS_SIZE
;###############################################################################
;S_Alex

