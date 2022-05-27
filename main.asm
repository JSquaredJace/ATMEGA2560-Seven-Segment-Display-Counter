;
; Lab03 - Seven Segment Display Counter
; Authors:	Jace Johnson
; Created:	2/12/2020 1:31:29 PM
; 	 Rev 1	2/12/2020
; Description:	ATMEGA2560 counts from 0 to 9, incrementing each 
;				second, and loops back to 0 after 9. Displays a capital "E"
;				with a period to indicate an error if the counter reaches a
;				number outside of 0 - 9.
;
; Hardware:	ATMega 2560 operating at 16 MHz
;			7 segment display (common cathode) with 330 Ohm resistor to ground
;			Pin connections (and corresponding PORTA bits) between the ATMega
;			and the 7 segment display are shown below. The seven segment 
;			display pins for each segment and the corresponding PORTA bits are
;			also displayed.
;
; Connections:
;   ATMega 2560		   7 segment
;   PORTA  pin			Display			
;	----------		   ----------	Display Pin, PORTA Bit
;	| 0	   22|---------|2		|		 _________
;	| 1	   23|---------|4		|		|  10, A4 |
;	| 2	   24|---------|5		|		|		  |7, A3
;	| 3	   25|---------|7		|		|11, A6	  |
;	| 4	   26|---------|10		|		|_________|
;	| 5	   27|---------|1		|		|  5, A2  |
;	| 6	   28|---------|11		|		|		  |4, A1
;	| 7	   29|---------|3		|		|1, A5	  |     _
;	|	  GND|-330 Ohm-|6		|		|_________|    |_|
;	----------		   ----------	       2, A0	  3, A7
;

.include <m2560def.inc>

.cseg ;place program instructions here
.org 0 ;program location counter

rjmp init

init:
	ser r16
	out DDRA, r16	;set port A as an output

;reset r17 to 0 and re-enter while1 loop
reset:
	ldi r17, 0x00		;set r17 to zero
while1:
	rcall update_LED		;update 7 segment display
	rcall delay_1s		;delay 1 second

	cpi r17, 0x09		;reset r17 if r17 is 9
	breq reset
	
	subi r17, 0xFF		;add 1 to r17
	rjmp while1			;return to top of while1 loop
	
	
;subroutine to delay 1 second
delay_1s:
	push XL		;push X registers used for length of delay
	push XH
	
	ldi XH, 0x03	;delay 999 milliseconds
	ldi XL, 0xE7	;X registers store the count
	
	rcall delay_ms	;delay 999 ms

	;compensation loop for last 1 ms
	ldi XH, 0x0A	;X registers used to store count
	ldi XL, 0xBA
	
	sbiw XH:XL, 0x01	;subtract 1 from count
	brne PC - 0x01		;repeat if word in X is not zero
	
	pop XL		;restore X registers
	pop XH
	nop
	ret			;return from subroutine
	
	
;subroutine that uses value stored in X registers to 
;delay X ms + 1 clock cycle
;value stored in X registers is lost during 
;execution
delay_ms:
	rcall delay_ms_count	;delay 1 ms - 4 clock cycles
	sbiw XH:XL, 0x01		;subtract 1 from count
	brne delay_ms			;repeat 1 ms loop until count is zero
	ret						;return from subroutine


;subroutine to delay 1 ms - 4 clock cycles
delay_ms_count:
	push YL		;push Y registers
	push YH
	
	ldi YL, 0x9B	;Y registers used to store the loop count
	ldi YH, 0x0F	
	
	sbiw YH:YL, 0x01	;subtract 1 from count
	brne PC - 0x01		;repeat if count is not zero
	
	nop
	nop
	nop
	pop YH		;restore Y registers
	pop YL
	ret			;return from subroutine
	
	
;subroutine for updating the 7 segment LED display based on r17 value
update_LED:
	push r16
	
;"switch statement" for r17 value
	cpi r17, 0x00		;break to case0 if r17 = 0
	breq case0
	cpi r17, 0x01		;break to case1 if r17 = 1
	breq case1
	cpi r17, 0x02		;break to case2 if r17 = 2
	breq case2
	cpi r17, 0x03		;break to case3 if r17 = 3
	breq case3
	cpi r17, 0x04		;break to case4 if r17 = 4
	breq case4
	cpi r17, 0x05		;break to case5 if r17 = 5
	breq case5
	cpi r17, 0x06		;break to case6 if r17 = 6
	breq case6
	cpi r17, 0x07		;break to case7 if r17 = 7
	breq case7
	cpi r17, 0x08		;break to case8 if r17 = 8
	breq case8
	cpi r17, 0x09		;break to case9 if r17 = 9
	breq case9
	rjmp default_case	;default case if r17 is outside of its normal range
	
;cases for switch statment
;sets r16 based on r17 value
case0:
	ldi r16, 0x7B	;load r16 with the hex value for the number 0
	rjmp end_case	;end case statement
case1:
	ldi r16, 0x0A	;load r16 with the hex value for the number 1
	rjmp end_case	;end case statement
case2:
	ldi r16, 0x6D	;load r16 with the hex value for the number 2
	rjmp end_case	;end case statement
case3:
	ldi r16, 0x4F	;load r16 with the hex value for the number 3
	rjmp end_case	;end case statement
case4:
	ldi r16, 0x1E	;load r16 with the hex value for the number 4
	rjmp end_case	;end case statement
case5:
	ldi r16, 0x57	;load r16 with the hex value for the number 5
	rjmp end_case	;end case statement
case6:
	ldi r16, 0x77	;load r16 with the hex value for the number 6
	rjmp end_case	;end case statement
case7:
	ldi r16, 0x4A	;load r16 with the hex value for the number 7
	rjmp end_case	;end case statement
case8:
	ldi r16, 0x7F	;load r16 with the hex value for the number 8
	rjmp end_case	;end case statement
case9:
	ldi r16, 0x5F	;load r16 with the hex value for the number 9
	rjmp end_case	;end case statement
default_case:
	ldi r16, 0xF5	;load r16 with the hex value for the letter E and a period

;end case statement and update 7 segment display
end_case:
	out PORTA, r16	;output r16 value to PORTA

	pop r16			;restore r16
	ret				;return from subroutine


;endless loop to prevent errors
end:	rjmp end