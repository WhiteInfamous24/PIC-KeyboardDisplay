#include "xc.inc"

; CONFIG1
  CONFIG  FOSC = XT             ; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)

; starting position of the program < -pRESET_VECT=0h >
psect RESET_VECT, class=CODE, delta=2
RESET_VECT:
    GOTO    setup

; memory location to go when a interrupt happens < -pINT_VECT=4h >
psect INT_VECT, class=CODE, delta=2
INT_VECT:
    
    ; save context
    MOVWF   W_TMP
    SWAPF   STATUS, W
    MOVWF   STATUS_TMP
    
    ; keypad routine
    CALL    getKeypad
    BANKSEL PORTB
    MOVLW   0b00000000		; put pins RB4 to RB7 in /HIGH
    MOVWF   PORTB
    BCF	    INTCON, 1		; clear INTF flag
    
    ; return previous context
    SWAPF   STATUS_TMP, W
    MOVWF   STATUS
    SWAPF   W_TMP, F
    SWAPF   W_TMP, W
    
    RETFIE

; program variables
W_TMP	    EQU 0x20
STATUS_TMP  EQU	0x21
KYPD_BTN    EQU 0x22
KYPD_FND_F  EQU	0x23

; program setup
setup:
    
    ; PORTC configuration
    BANKSEL TRISC
    MOVLW   0b00000000		; set PORTC pins as output
    MOVWF   TRISC
    
    ; PORTB configuration
    BANKSEL TRISB
    MOVLW   0b00001111		; set 4 outputs and 4 inputs to control 8x8 keyboard in PORTB
    MOVWF   TRISB
    BANKSEL ANSELH
    CLRF    ANSELH		; set PORTB as digital inputs
    
    ; general port configuration
    BANKSEL OPTION_REG		; enable global pull-ups
    MOVLW   0b00000000		; | /RBPU | INTEDG | T0CS | T0SE | PSA | PS2 | PS1 | PS0 |
    MOVWF   OPTION_REG
    BANKSEL WPUB
    MOVLW   0b00001111		; enable RB0 to RB3 pull-ups
    MOVWF   WPUB
    
    ; interruption configuration
    BANKSEL INTCON		; enable global interruptions and interruptions in PORTB
    MOVLW   0b10010000		; | GIE | PEIE | T0IE | INTE | RBIE | T0IF | INTF | RBIF |
    MOVWF   INTCON
    BANKSEL IOCB
    MOVLW   0b00001111		; enable interruptions in pins RB0 to RB3
    MOVWF   IOCB
    
    ; PORTC initialization
    BANKSEL PORTC
    MOVLW   0b00000000
    MOVWF   PORTC
    
    ; PORTB initialization
    BANKSEL PORTB
    MOVLW   0b00000000		; put pins RB4 to RB7 in /HIGH
    MOVWF   PORTB
    
    ; variables initialization
    CLRF    KYPD_BTN
    CLRF    KYPD_FND_F

; main program loop
main:
    
    ; show last pressed button
    CALL    showButton
    
    GOTO    main
    
; show the pressed button subroutine
showButton:
    BANKSEL PORTC
    MOVF    KYPD_BTN, W
    MOVWF   PORTC
    
    RETURN

; get pressed button in keypad subroutine
getKeypad:
    CLRF    KYPD_FND_F
    BANKSEL PORTB
    
    BSF	    PORTB, 7
    BSF	    PORTB, 6
    BSF	    PORTB, 5
    BCF	    PORTB, 4
    MOVLW   0b00010000
    MOVWF   KYPD_BTN
    CALL    getRow
    BTFSC   KYPD_FND_F, 0
    
    RETURN
    
    BSF	    PORTB, 7
    BSF	    PORTB, 6
    BCF	    PORTB, 5
    BSF	    PORTB, 4
    MOVLW   0b00100000
    MOVWF   KYPD_BTN
    CALL    getRow
    BTFSC   KYPD_FND_F, 0
    
    RETURN
    
    BSF	    PORTB, 7
    BCF	    PORTB, 6
    BSF	    PORTB, 5
    BSF	    PORTB, 4
    MOVLW   0b01000000
    MOVWF   KYPD_BTN
    CALL    getRow
    BTFSC   KYPD_FND_F, 0
    
    RETURN
    
    BCF	    PORTB, 7
    BSF	    PORTB, 6
    BSF	    PORTB, 5
    BSF	    PORTB, 4
    MOVLW   0b10000000
    MOVWF   KYPD_BTN
    CALL    getRow
    BTFSC   KYPD_FND_F, 0
    
    RETURN
    
; get row of pressed button subroutine
getRow:
    BTFSC   PORTB, 0
    GOTO    setRow_0
    BTFSC   PORTB, 1
    GOTO    setRow_1
    BTFSC   PORTB, 2
    GOTO    setRow_2
    BTFSC   PORTB, 3
    GOTO    setRow_3
    
    RETURN
    
setRow_0:
    BSF	    KYPD_BTN, 0
    BSF	    KYPD_FND_F, 0
    
    RETURN
    
setRow_1:
    BSF	    KYPD_BTN, 1
    BSF	    KYPD_FND_F, 0
    
    RETURN
    
setRow_2:
    BSF	    KYPD_BTN, 2
    BSF	    KYPD_FND_F, 0
    
    RETURN
    
setRow_3:
    BSF	    KYPD_BTN, 3
    BSF	    KYPD_FND_F, 0
    
    RETURN    

END RESET_VECT