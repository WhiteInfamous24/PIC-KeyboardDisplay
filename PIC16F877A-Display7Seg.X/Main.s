#include "pic16f877a.inc"
#include "xc.inc"

; CONFIG
CONFIG  FOSC = HS             ; Oscillator Selection bits (HS oscillator)
CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled)
CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
CONFIG  BOREN = OFF           ; Brown-out Reset Enable bit (BOR disabled)
CONFIG  LVP = OFF             ; Low-Voltage (Single-Supply) In-Circuit Serial Programming Enable bit (RB3 is digital I/O, HV on MCLR must be used for programming)
CONFIG  CPD = OFF             ; Data EEPROM Memory Code Protection bit (Data EEPROM code protection off)
CONFIG  WRT = OFF             ; Flash Program Memory Write Enable bits (Write protection off; all program memory may be written to by EECON control)
CONFIG  CP = OFF              ; Flash Program Memory Code Protection bit (Code protection off)

psect RESET_VECT, class=CODE, delta=2	; same as ORG, indicate the start position of the program
RESET_VECT:
	GOTO setup
	
psect INT_VECT, class=CODE, delta=2		; indicate the memory location to go when a interrupt happens
INT_VECT:
	; implement method interruption
	
	RETFIE

; program variables
W_REG   EQU 0
F_REG   EQU 1

CTER_0  EQU 0X20
CTER_1  EQU 0X21
CTER_2  EQU 0X22

setup:
	BSF STATUS, 5	; set bit 5 of STATUS vector, to select the memory bank 1 (01)
	MOVLW 0xFF
	MOVWF TRISB	; set lower nibble bits of TRISB vector, to put all the pin in output mode
 	BCF STATUS, 5	; clear bit 5 of STATUS vector, to select the memory bank 0 (00)

main:
	MOVLW 0xFF
	MOVWF PORTB	; set lower nibble bits of TRISB vector, to put the selected pins in HIGH
	CALL delay
	MOVLW 0x00
	MOVWF PORTB	; clear all bits of TRISB vector, to put the selected pins in LOW
	CALL delay
	
	GOTO main

sevSegDeco:
	ADDWF PCL, 1
	RETLW 0x00
	RETLW 0x01
	RETLW 0x02
	RETLW 0x03
	RETLW 0x04
	RETLW 0x05
	RETLW 0x06
	RETLW 0x07
	RETLW 0x08
	RETLW 0x09

delay:
	MOVLW 0xFF
	MOVWF CTER_0
loop_2:
	MOVLW 0xFF
	MOVWF CTER_1
loop_1:
	MOVLW 0xFF
	MOVWF CTER_2
loop_0:
	DECFSZ CTER_2
	GOTO loop_0
	DECFSZ CTER_1
	GOTO loop_1
	DECFSZ CTER_0
	GOTO loop_2
	RETURN

END RESET_VECT