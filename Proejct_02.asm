TITLE Program #2	(Kearns_Project_2.asm)

; Author: Chris Kearns
; Date: 17 Apr 2016
; Description: Program calculates Fibonacci numbers.
;   Displays program title, programmer’s name, gets user’s name, and greets user.
;   Prompts user to enter number of Fibonacci terms to be displayed.
;   Advises user to enter an integer in the range [1 ... 46].
;   Gets and validate user input (n).
;   Calculates and displays Fibonacci numbers from 1 to nth term inclusive.
;   Results displayed 5 terms per line with 5 spaces between terms.
;   Displays parting message including user’s name and terminates.

INCLUDE Irvine32.inc

UPLIM	EQU	46		; Upper Limit of User Input that program will accept.
TAB	=	9		; Ascii code for tab.

.data
	intro_1		BYTE		"Welcome to ""Kearns_Project02.asm"" by Chris Kearns",13,10,13,10,0
	EC_1		BYTE		"Outputted Fibonaccis are aligned in columns!",13,10,13,10,0
	userMsg_1	BYTE		"Please enter your name, maximum of 30 characters",13,10,0
	userMsg_2	BYTE		"Hello ",0
	userName	BYTE		31 dup(0)
	userMsg_3	BYTE		", welcome to the Fibonacci Number Generator!",13,10,13,10,0
	userMsg_4	BYTE		"If you enter an int from 1 to ",0
	userMsg_5	BYTE		" inclusive",13,10
			BYTE		"I will display for you the Fibonacci number sequence",13,10
			BYTE		"from 1 to your entered int.",13,10,0
	userMsg_6	BYTE		"Enter the number of Fibonacci terms you wish to see: ",13,10,0
	userMsg_7	BYTE		"I'm sorry, you've input an out of range value!"
			BYTE		" Please enter an int from 1 to ",0
	userMsg_8	BYTE		" inclusive:",0
	userInt		DWORD	?	; The user's desired number of Fibonacci numbers.
	tabSprs		DWORD	?	; A computed int used to suppress tabs for higher # of digit Fibonaccis (userInt-11). 
	fibEAX		DWORD	?	; Used to temp store EAX as we need this register to check for 5th Fibonacci as mult. of 5.
	fibEBX		DWORD	5	; Used as our divisor for checking ECX for multiple of 5 condition.
	five_		BYTE		"     ",0		;String of 5 spaces.
	userMsg_Y	BYTE		"Thank you, ",0
	userMsg_Z	BYTE		", for trying ""Kearns_Project02.asm,""",13,10
			BYTE		"the Fibonacci Number Generator!",13,10,13,10,0	

.code
main PROC

;Introduction
	mov EDX, OFFSET	intro_1
	call writeString
	mov EDX, OFFSET	EC_1
	call writeString
	mov EDX, OFFSET	usermsg_1
	call writeString
	mov EDX, OFFSET	userName
	mov ECX, sizeof	userName
	call readString
	call CrLf
	mov EDX, OFFSET	userMsg_2
	call writeString
	mov edx, offset	userName
	call writeString
	mov EDX, OFFSET	userMsg_3
	call writeString


;User Instructions
	mov EDX, OFFSET	userMsg_4
	call writeString
	mov EAX, UPLIM
	call writeDec
	mov EDX, OFFSET	userMsg_5
	call writeString
	mov EDX, OFFSET	userMsg_6
	call writeString

;Get User Data
do:
	call readInt
	mov userInt, EAX
;while
	cmp EAX, 0
	jbe inputBad
	cmp EAX, UPLIM
	ja inputBad
	jmp inputOK
inputBad:
	mov EDX, OFFSET	userMsg_7
	call writeString
	mov eax, UPLIM
	call writeDec
	mov EDX, OFFSET	userMsg_8
	call writeString
	jmp do
inputOK:
	call CrLf
;end do while loop

;Process tabSprs (Used to suppress column tab seperators above Fibonacci sequence 35)
	mov eax, userInt
	sub eax, 11
	mov tabSprs, eax

;Display Fibonaccis
	mov ECX, userInt
	mov EAX, 1
	mov EBX, 0
	mov EDX, OFFSET	five_
generate:
	add EAX, EBX
	call writeDec
	call writeString

	pushad					; pushad to store registers.
	mov al, TAB
	call writeChar
	cmp ECX, tabSprs			; skip the tab when displaying > 35 Fibonacci's
	jbe skipTab
	call writeChar
skipTab:
	popad					; popad to restore registers. 

	xchg EAX, EBX
	mov fibEAX, EAX				; store register manually
	mov fibEBX, EBX				; store register manually
	
	xchg EAX, EBX
	mov EBX, 5
	mov EDX,0
	div EBX
	cmp EDX, 0
	jnz notMult5				; skips the newline unless 5 numbers have been displayed.
	call CrLf

notMult5:
	mov EAX, fibEAX				; restore registers manually
	mov EBX, fibEBX				; just to see the difference with pushad & popad.
	mov EDX, OFFSET	five_
	loop generate

;Farewell
	call CrLf
	call CrLf
	mov EDX, OFFSET	userMsg_Y
	call writeString
	mov EDX, OFFSET	userName
	call writeString
	mov EDX, OFFSET	userMsg_Z
	call writeString

	exit
main ENDP
END main
