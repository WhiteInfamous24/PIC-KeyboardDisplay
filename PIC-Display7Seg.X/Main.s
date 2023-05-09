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

; starting position of the program
psect RESET_VECT, class=CODE, delta=2
RESET_VECT:
    GOTO    setup

; memory location to go when a interrupt happens
psect INT_VECT, class=CODE, delta=2
INT_VECT:
    
    ; IMPLEMENT METHOD INTERRUPTION
    
    RETFIE

; program variables
W_REG   EQU 0
F_REG   EQU 1
CTER_0  EQU 0X20
CTER_1  EQU 0X21
CTER_2  EQU 0X22

setup:
    BSF	    STATUS, 5	; set bit 5 of STATUS vector, to select the memory bank 1 (01)
    MOVLW   0xFF
    MOVWF   TRISB	; set lower nibble bits of TRISB vector, to put all the pin in output mode
    BCF	    STATUS, 5	; clear bit 5 of STATUS vector, to select the memory bank 0 (00)

main:
    MOVLW   0x02	; load in W_REG the value that i want to search in sevSegDeco
    CALL    sevSegDeco
    MOVWF   PORTB	; set the bits of PORTB vector with the values returned from the sevSegDeco
    CALL    delay
    
    GOTO    main

sevSegDeco:
    ADDWF   PCL, 1
    RETLW   0x00
    RETLW   0x01
    RETLW   0x02
    RETLW   0x03
    RETLW   0x04
    RETLW   0x05
    RETLW   0x06
    RETLW   0x07
    RETLW   0x08
    RETLW   0x09

delay:
    MOVLW   0xFF
    MOVWF   CTER_0
loop_2:
    MOVLW   0xFF
    MOVWF   CTER_1
loop_1:
    MOVLW   0xFF
    MOVWF   CTER_2
loop_0:
    DECFSZ  CTER_2
    GOTO    loop_0
    DECFSZ  CTER_1
    GOTO    loop_1
    DECFSZ  CTER_0
    GOTO    loop_2
    RETURN

END RESET_VECT