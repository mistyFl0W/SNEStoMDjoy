; RESET
.org 0x0000
                    RJMP            main
; INT0
.org 0x0004
                    RETI
; INT1
.org 0x0008
                    RETI
; PCINT0
.org 0x000C
                    RJMP           PCINT0_vect
; PCINT1
.org 0x0010
                    RETI
; PCINT2
.org 0x0014
                    RETI            
; WDT
.org 0x0018
                    RETI
; TIMER2_COMPA
.org 0x001C
                    RETI
; TIMER2_COMPB
.org 0x0020
                    RETI
; TIMER2_OVF
.org 0x0024
                    RETI
; TIMER1_CAPT
.org 0x0028
                    RETI
; TIMER1_COMPA
.org 0x002C
                    RETI
; TIMER1_COMPB
.org 0x0030
                    RETI
; TIMER1_OVF
.org 0x0034
                    RETI
; TIMER0_COMPA
.org 0x0038
                    RJMP            TIMER0_COMPA
; TIMER0_COMPB
.org 0x003C
                    RETI
; TIMER0_OVF
.org 0x0040
                    RETI
; SPI_STC
.org 0x0044
                    RETI
; USART_RX
.org 0x0048
                    RETI
; USART_UDRE
.org 0x004C
                    RETI
; USART_TX
.org 0x0050
                    RETI
; ADC
.org 0x0054
                    RETI
; EE_READY
.org 0x0058
                    RETI
; ANALOG_COMP
.org 0x005C
                    RETI
; TWI
.org 0x0060
                    RETI
; SPM_READY
.org 0x0064
                    RETI






                    

                    