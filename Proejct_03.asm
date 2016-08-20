TITLE Program 3 Integer Accumulator by Chris Kearns (Project_03.asm)

; Author: Chris Kearns
; Date: 1 May 2016
; Description: MASM program to perform the following tasks:
; Displays the program title and programmer’s name.
; Gets the user’s name and greets the user.
; Displays instructions for the user.
; Repeatedly prompts the user to enter a negative number.
; Validates the user's input to be in [-100, -1] (inclusive).
; Counts and accumulates the valid user numbers until a non-negative number
;    is entered. Non-negative numbers are discarded.
; Calculates the (rounded integer) average of the negative numbers.
; Displays:
;	i. The number of negative numbers entered (Note: if no negative numbers
;		were entered, displays a special message and skips to iv.)
;	ii. The sum of negative numbers entered.
;	iii. The average, rounded to the nearest integer (e.g. -20.5 rounds to -20).
;	iv. A parting message with the user’s name.

INCLUDE Irvine32.inc

; Constant definitions
	UPLIM	=	-1
	LOWLIM	=	-100

.data
	intro_1		BYTE		"Welcome to ""Program_03.asm"" by Chris Kearns",0dh,0ah
			BYTE		"aka ""The Integer Accumulator""",0dh,0ah,0dh,0ah,0
	EC_1		BYTE		"Number the lines during user input.",0dh,0ah,0dh,0ah,0
	EC_2		BYTE		"Program displays the average as a float.",0dh,0ah,0dh,0ah,0
	EC_3		BYTE		"Somewhat creative use of color.",0dh,0ah,0dh,0ah,0
	userMsg_1	BYTE		"Please enter your name, maximum of 30 characters",0dh,0ah,0
	userMsg_2	BYTE		"Hello ",0
	userName	BYTE		31 dup(0)
	userMsg_3	BYTE		", welcome to the Integer Accumulator!",0dh,0ah,0dh,0ah,0
	userMsg_4	BYTE		"Please enter succesive negative integers in the range [",0
	userMsg_5	BYTE		", ",0
	userMsg_6	BYTE		"]",0dh,0ah,0
	userMsg_7	BYTE		" inclusive and I will display for you the following:",0dh,0ah
			BYTE		" i.   The number of negative numbers you entered.",0dh,0ah
			BYTE		" ii.  The sum the the negative numbers you entered.",0dh,0ah
			BYTE		" iii. The avergae, rounded to the nearest integer.",0dh,0ah
			BYTE		" iv.  If you've followed these instructions, a nice parting message!",0dh,0ah,0dh,0ah,0
	userMsg_8	BYTE		"1. Enter your first negative number, or any + int to see the results: ",0
	userMsg_9	BYTE		". Enter your next negative number, or any + int to see the results: ",0
	userMsg_10	BYTE		"I'm sorry, you've input an out of range value!",0dh,0ah
			BYTE		"Please enter a negative intger in the range [",0
	userMsg_11	BYTE		"] inclusive: ",0
	userMsg_Flt	BYTE		"Your rounded average expressed as a float: ",0
	userMsg_dot	BYTE		".",0

	userInt		SDWORD	?	; The user's entered negative int.
	numNegs		SDWORD	0	; The accumlated number of succesfully entered negative numbers.
	numNegs_2	SDWORD	0	; The int division quotient of numNegs / 2 (rounds down).<------------------  Compare
	sumNegs		SDWORD	0	; The accumulated sum of the succesfully entered negative numbers.	    | these for
	avgNeg_Q	SDWORD	0	; The dividened of the avg. calculation of entered negative numbers.	    | rounding!
	avgNeg_R	SDWORD	0	; The remainder of the avg. calculation of entered negative numbers.<-------
	mantissa	DWORD	0	; The mantissa of the calculated average for floating point representation.
	fauxInt		SDWORD	0	; A faux variable used to override avgNeg_R ceiling issue.
	manRounder	DWORD	0	; Utility variable used to facilitate rounding the mantissa as needed in float calc.

	userMsg_spec	BYTE	0dh,0ah,"Special Message from Yoda: ""No numbers entered! This is why you FAIL:""",0dh,0ah,0dh,0ah,0
	userMsg_12	BYTE	"You've entered ",0
	userMsg_13	BYTE	" valid integers.",0dh,0ah,0
	userMsg_14	BYTE	"The sum of your valid integers is ",0
	userMsg_15	BYTE	"The rounded average is ",0

	userMsg_Y	BYTE	"Thank you ",0
	userMsg_Z	BYTE	", for trying ""Integer Accumulator""",0dh,0ah,0dh,0ah,0

.code
main PROC

; Introduction, user name collection, and instructions.
	mov edx, OFFSET	intro_1
	call writeString
	mov eax, 14
	call setTextColor
	mov edx, OFFSET	EC_1
	call writeString
	mov edx, OFFSET	EC_2
	call writeString
	mov edx, OFFSET	EC_3
	call writeString
	mov eax, 7
	call setTextColor
	mov edx, OFFSET	userMsg_1
	call writeString
	mov EDX, OFFSET	userName
	mov ECX, sizeof	userName
	call readString
	call CrLf
	mov edx, OFFSET	userMsg_2
	call writeString
	mov edx, OFFSET	userName
	mov eax, 4				; Colored userName.
	call setTextColor
	call writeString
	mov eax, 7
	call setTextColor
	mov edx, OFFSET	userMsg_3
	call writeString
	mov edx, OFFSET	userMsg_4
	call writeString
	mov eax, LOWLIM
	call writeInt
	mov edx, OFFSET	userMsg_5
	call writeString
	mov eax, UPLIM
	call writeInt
	mov edx, OFFSET	userMsg_6
	call writeString
	mov edx, OFFSET	userMsg_7
	call writeString

; User data entry collection.
	mov edx, OFFSET	userMsg_8		; Initial prompt to collect first negative int.
	call writeString
	call readInt
	jmp TestInput

GoAgain:					; User keeps entering negative ints.
	mov eax, numNegs
	inc eax
	call writeDec
	mov edx, OFFSET	userMsg_9
	call writeString
	call readInt
	jmp TestInput

TooLow:						; Prompt user about entering negatives < -100
	mov edx, OFFSET	userMsg_10
	call writeString
	mov eax, LOWLIM
	call writeInt
	mov edx, OFFSET	userMsg_5
	call writeString
	mov eax, UPLIM
	call writeInt
	mov edx, OFFSET	userMsg_11
	call writeString
	call readInt

TestInput:					; Check user input for in range or jump to calc for +int entered.
	cmp eax, LOWLIM
	jl TooLow

	cmp eax, UPLIM
	jg Calc

	mov userInt, eax			; Process valid input.
	inc numNegs
	mov eax, sumNegs
	add eax, userInt
	mov sumNegs, eax
	jmp GoAgain				; Allow user to continue entering negative ints indefinately.

Calc:						; Process division.
	mov eax, numNegs
	cmp eax, 0				; Check of numNegs == 0, if so, skip the rounding block
	je SpecMsg				; and jump directly to SpecMsg:
	cmp eax, 1				; Check if nunNegs == 1, if so, skip the rounding block
	je OneIntOnlyCase			; and jump to OneIntOnlyCase: and handle one int entered case.

	mov ebx, -2				; Determine the expected number of potential remainders / -2.
	cdq
	idiv ebx
	mov numNegs_2, eax

	mov eax, sumNegs			; divide sum by number of negatives entered.
	mov ebx, numNegs
	cdq
	idiv ebx
	mov avgNeg_Q, eax
	mov fauxInt, eax
	mov avgNeg_R, edx
	cmp edx, 0				; Inhibit divide by zero.
	jz CalcFloat				; Check zero flag, jump to CalcFloat since remainder == 0 so no rounding needed.

	mov eax, avgNeg_R			; We have a remainder, avgNeg_R, so process.
	mov ebx, numNegs_2	
	cmp eax, ebx				; Compare remainder to number of negs/-2
	jge CalcFloat				; if remainder >= to numNegs_2, rounding is correct.
	dec avgNeg_Q				; else off by -1
	jmp CalcFloat				; Skip OneIntOnlyCase block.

OneIntOnlyCase:					; Handles the case of just one negative int entered.
	mov eax, userInt
	mov avgNeg_Q, eax
	mov fauxInt, eax
	cmp eax, 1
	jl Display
	dec avgNeg_Q
	jmp Display

SpecMsg:
	mov eax, 2
	call setTextColor
	mov edx, OFFSET	userMsg_spec
	call writeString
	mov eax, 7
	call setTextColor
	jmp Display
	 
CalcFloat:					; Calculate float and display all results to user.
	mov eax, avgNeg_R			; (remainder x 10,000) / numNegs
	cmp eax, 0
	je Remainder_0				; Remainder == 0 case.
	mov ebx, 10000
	imul ebx
	not eax
	inc eax
	mov ebx, numNegs
	mov edx, 0
	idiv ebx
	mov manRounder, eax

	mov eax, avgNeg_R			; Do over! (remainder x 1,000) / numNegs
	mov ebx, 1000
	imul ebx
	not eax
	inc eax
	mov ebx, numNegs
	mov edx, 0
	idiv ebx
	mov mantissa, eax

	cmp manRounder, 5000			; Compare and increment mantissa for rounding up.
	jle Display
	inc mantissa
	jmp Display

Remainder_0:
	mov mantissa, 0

Display:					; Start main display
	mov edx, OFFSET	userMsg_12
	call writeString
	mov eax, numNegs
	call writeDec
	mov edx, OFFSET	userMsg_13
	call writeString
	mov edx, OFFSET	userMsg_14
	call writeString
	mov eax, sumNegs
	call writeInt
	call CrLf
	mov edx, OFFSET	userMsg_15
	call writeString
	mov eax, avgNeg_Q
	call writeInt
	call CrLf

	mov edx, OFFSET	userMsg_Flt		; Start float display
	call writeString
	mov eax, fauxInt			; Was avgNeg_Q
	call writeInt
	mov edx, OFFSET	userMsg_dot
	call writeString
	mov eax, mantissa
	call writeDec
	call CrLf				; End float display

; Parting Message
	mov edx, OFFSET	userMsg_Y
	call writeString
	mov eax, 4				; colored userName
	call setTextColor
	mov edx, OFFSET	userName
	call writeString
	mov eax, 7
	call setTextColor
	mov edx, OFFSET	userMsg_Z
	call writeString

	exit					; Exit to operating system.
main ENDP
END	main
