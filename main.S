#define IS_6_BUTTONS 1

#define SNES_B (1<<7)
#define SNES_Y (1<<6)
#define SNES_SEL (1<<5)
#define SNES_START (1<<4)
#define SNES_UP (1<<3)
#define SNES_DOWN (1<<2)
#define SNES_LEFT (1<<1)
#define SNES_RIGHT (1<<0)

#define SNES_A (1<<7)
#define SNES_X (1<<6)
#define SNES_L (1<<5)
#define SNES_R (1<<4)

.set port_hi_state, r10
.set port_low_state, r11
.set portD_state, r7

.section .data

var1: .BYTE 1
low_state: .BYTE 0b110011, 0b110011, 0b000011, 0b111111
hi_state: .BYTE 0b111111, 0b111111, 0b111111, 0b111111


cycle_number: .BYTE 0

snes_btns_h: .BYTE 0
snes_btns_l: .BYTE 0

is_6_button_pad: .BYTE 1

.equ md_low_test_state, 0b11110011
.equ md_hi_test_state, 0b11111111

.balign 2

.section .bss

.section .text

#include "include/io.inc"
#include "include/vectors.inc"

.global main
.global inf_loop
.global PCINT0_vect
.global TIMER0_COMPA

main:
    cli
    /*
        GPIO SETUP
    */

    ; SNES Controller
    ;   A0 - Clk (o) - PC0
    ;   A1 - Latch (o) - PC1
    ;   A2 - Serial Data (i) - PC2 (pull up enabled)

    ldi r16, (1<<0) | (1<<1)
    out DDRC, r16
    ldi r16, (1<<0) | (1<<2)
    out PORTC, r16

    ; MD controller
    ;   PB0 (D8) - select source (PCINT0) (pull up enabled)
    ldi r16, (1<<0)
    sbi PORTB, 0

    ;   PD2-PD7 - output signals
    ;   DDRD |= (1<<PD2) | (1<<PD3) | (1<<PD4) | (1<<PD5) | (1<<PD6) | (1<<PD7)
    ldi r16, 0b11111100
    out DDRD, r16
    out PORTD, r16

    ; -----------------------------

    ; check if select button was pressed durring startup: 
    ; if so, turn controller to 3-button mode
test_read:
    call read_snes_controller
    lds r2, snes_btns_h
    lds r3, snes_btns_l
    ; check if controller present. If not - loop
    sbrs r3, 3
    rjmp test_read
    sbrc r2, 5
    rjmp past_mode_select
    clr r5
    sts is_6_button_pad, r5
    rjmp skip_timer_init

past_mode_select:

    ; _____________________________
    ; Timer 0 init
    ldi r16, 2
    out TCCR0A, r16 ; set timer to CTC mode
    
    ; clear timer counter value
    clr r16
    out TCNT0, r16
    ; set compare value to 32 (~2ms)
    ldi r16, 0x20
    out OCR0A, r16

    ; enable CTC interrupt
    ldi r16, 0x02
    sts TIMSK0, r16

    ; set prescaler to Fclk/1024
    ldi r16, 0x05
    out TCCR0B, r16 ; start timer
    ; _____________________________

skip_timer_init:
    ldi r16, md_hi_test_state
    sts hi_state, r16
    mov r10, r16
    ldi r16, md_low_test_state
    sts low_state, r16
    mov r11, r16


    ; init select pin change interrupt
    ;   Enable pin change PCINT0 interrupt
    ldi r16, 1
    sts PCICR, r16
    ;   Unmask interrupt for PCINT0 (PB0)
    sts PCMSK0, r16

    ; PORTD mask
    in r7, PORTD
    in r8, 0b00000011
    and r7, r8

    clr r4
    ldi r30, lo8(hi_state)
    ldi r31, hi8(hi_state)
    ldi r28, lo8(low_state)
    ldi r29, hi8(low_state)
    ; enable global interrupts
    sei

inf_loop:

    call read_snes_controller
    ; snes buttons state
    ;   Right Left Down Up Sta Sel Y B
    lds r2, snes_btns_h
    ;   1 1 1 1 R L X A
    lds r3, snes_btns_l
    
    ; debug-----------
    ; lsl r16
    ; lsl r16
    ; andi r16, 0b11111100
    ; or r16, r7
    ; out PORTD, r16
    ; endof debug---------
    
    clr r16 ; sel hi 
    clr r17 ; sel low

    sbrc r2, 7 ; snes - B
    sbr r16, (1<<6) ; md - B
    sbrc r2, 6 ; snes - y
    sbr r17, (1<<6) ; md - A
    sbrc r2, 4 ; snes - Start
    sbr r17, (1<<7) ; md - Start
    sbrc r3, 7 ; snes - A
    sbr r16, (1<<7) ; md - C

    
    ; md - directions:
    sbrc r2, 3 ; snes - up
    sbr r16, (1<<2) ; md - up
    sbrc r2, 2 ; snes - down
    sbr r16, (1<<3) ; md - down
    sbrc r2, 1 ; snes - left
    sbr r16, (1<<4) ; md - left
    sbrc r2, 0 ; snes - right
    sbr r16, (1<<5) ; md - right

    mov r25, r16
    andi r25, 0b00001100
    or r17, r25

    or r16, r7
    mov r10, r16
    or r17, r7
    mov r11, r17
    
    ; save port states in RAM (hi_state[h] - low-state[h])
    ; md: Up Dw Lt Rt B  C
    sts hi_state, r16
    ; md: Up Dw 0  0  B  C
    sts low_state, r17
    sts hi_state+1, r16
    sts low_state+1, r17
    sts hi_state+3, r16


    ; check for Z Y X Mode buttons presses and store rest of the button states
    andi r16, 0b11000011
    
    sbrc r2, 5 ; snes - select
    sbr r16, (1<<5) ; md - mode
    sbrc r3, 5 ; snes - L
    sbr r16, (1<<4) ; md - X
    sbrc r3, 6 ; snes - X
    sbr r16, (1<<3) ; md - y
    sbrc r3, 4 ; snes - R
    sbr r16, (1<<2) ; md - z
    
    ; md: Z  Y  X  Md B  C
    sts hi_state+2, r16
    ; md: 0  0  0  0  B  C
    andi r17, 0b11000011
    sts low_state+2, r17

    ; md: 1  1  1  1  A  St
    ori r17, 0b00111100
    sts low_state+3, r17

    rjmp inf_loop

PCINT0_vect:
    ; push status register into stack
    ; lds r5, SREG
    ; push r5
    ; lds r5, is_6_button_pad

    cycle:
        sbis PINB, 0
        rjmp cycle_low
        ld r10, z
        out PORTD, r10
        sbrc r5, 0
        inc r30
        out TCNT0, r4
        reti
        
        cycle_low:
        ld r11, y
        out PORTD, r11
        sbrc r5, 0
        inc r28
        
    cycle_end:
    ; pop r5
    ; sts SREG, r5
    reti


TIMER0_COMPA:
    ; clear cycle count and timer counter
    ldi r30, lo8(hi_state)
    ldi r28, lo8(low_state)
    out TCNT0, r4
    reti


; read snes controller
read_snes_controller:
    ; -------------------
    sbi PORTC, 1 ; latch high
    ldi r18, 6 ; delay ~6us
    call delay_us
    cbi PORTC, 1 ; latch low

    ldi r26, lo8(snes_btns_h)
    ldi r27, hi8(snes_btns_h)

    ldi r18, 2 ; delay ~2us
    call delay_us

    ldi r23, 2 ; two iterations loop
    read_snes_loop:
        clr r22

        cbi PORTC, 0 ; clock pulse low
        ldi r18, 0x2 ; delay ~2us
        call delay_us
        sbic PINC, 2 ; if btn not pressed skip next instruction
        sbr r22, 1
        sbi PORTC, 0 ; clock pulse high
        ldi r18, 0x2 ; delay ~2us
        call delay_us

        ldi r24, 7
        read_snes_clock:
            rol r22
            cbi PORTC, 0 ; clock pulse low
            ldi r18, 0x2 ; delay ~2us
            call delay_us
            sbic PINC, 2 ; if btn not pressed skip next instruction
            sbr r22, 1
            sbi PORTC, 0 ; clock pulse high
            ldi r18, 0x2 ; delay ~2us
            call delay_us
            dec r24
            brne read_snes_clock
        st x+, r22
        
        dec r23
        brne read_snes_loop
    ret
    ; --------------------


; PARAMS:
;   r18 - us
delay_us:
    cpi r18, 1 ; 1
    breq last_us_loop_start    ; 1 - false / 2 - true

    ldi r19, 7 ; 1
    cont_us_loop:
        dec r19 ; 1
        cpi r19, 5 ; 1
        brne cont_us_loop ; 1 - false / 2 - true
    dec r18 ; 1
    rjmp delay_us ; 2

    last_us_loop_start:
        ldi r19, 7 ; 1
        last_us_loop:
            dec r19 ; 1
            cpi r19, 6 ; 1
            brne last_us_loop ; 1 - false / 2 - true
    ret ; 4
            
; PARAMS:
;   r20 - ms
delay_ms:
    cpi r20, 1 ; 1
    breq last_ms_loop_start ; 1 - false / 2 - true

    ldi r21, 4 ; 1
    cont_ms_loop:
        ldi r18, 248 ; 1
        call delay_us ; 3
        dec r21 ; 1
        brne cont_ms_loop ; 1 - false / 2 - true
    dec r20 ; 1
    rjmp delay_ms ; 2

    last_ms_loop_start:
        ldi r21, 4 ; 1
        last_ms_loop:
            ldi r18, 248 ; 1
            call delay_us ; 3
            dec r21 ; 1
            brne last_ms_loop ; 1 - false / 2 - true
    ret ; 4
