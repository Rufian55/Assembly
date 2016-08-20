TITLE Program 1     (Project_01.asm)

; Author: Chris Kearns (traveler-403@msn.com)
; Date: 10 April 2016
; Description: Simple assembly program to demo strings and
; elementary arithmetic operations with some fairly robust
; user input validation!

INCLUDE Irvine32.inc

.386
;.model flat, stdcall	;commented out as Irvine32 library included.
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

;(Constant Definitions)

;(Variable Definitions)
.data
	banner		BYTE		"Welcome to Project_01.asm by Chris Kearns.",13,10,13,10,0
	intro_1		BYTE		"Enter two numbers, and I'll show you the sum,",13,10
			BYTE		"difference, product, quotient and remainder!",13,10,13,10,0
	prompt_1	BYTE		"Please enter your first positive integer: ",0
	prompt_2	BYTE		"Please enter your second positive integer: ",0
	prompt_3	BYTE		"Error! Second number must be <= the first. Try again!",13,10,0
	prompt_4	BYTE		"Error! 0 entered! Please enter your second positive int.",0
	prompt_5	BYTE		"Error! You cannot divide by zero! Enter second number again!",13,10,0
	firstNum	DWORD	0
	secondNum	DWORD	0
	result_1	DWORD	0
	result_2	DWORD	0
	result_3	DWORD	0
	result_Q	DWORD	0							;Quotient
	result_R	DWORD	0							;Remainder
	result_FP	REAL4	0.0							;Floating Point
	plus		BYTE		" + ",0
	minus		BYTE		" - ",0
	times		BYTE		" x ",0
	divide		BYTE		" ö ",0						;ALT 0246 generates "÷"
	equals		BYTE		" = ",0
	ore		BYTE		" or ",0
	remainder	BYTE		" remainder ",0
	calcAgain	BYTE		"Calculate another? Enter 1 for yes, any other int for quit.",13,10,0
	yesNo		DWORD	0
	sayBye		BYTE		"Darth Vader: Impressive! Goodbye.",13,10,0
	eCredit_1	BYTE		"Program repeats until user user chooses to quit.",13,10,13,10,0
	eCredit_2	BYTE		"Program calculates and displays the quotient as a float rounded to .001",13,10,13,10,0
	eCredit_3	BYTE		"Program verifies second number less than the first and has user",13,10
			BYTE		"re-enter until corrected.",13,10,13,10,0
	eCredit_4 	BYTE		"Program inhibits divide by 0 in all cases and has user re-enter until",13,10
			BYTE		"corrected.",13,10,13,10,0
	eCredit_5	BYTE		"Program allows second number > first if first number == 0.",13,10,13,10,0	
	contWord	WORD		?
	thousand	WORD		1000

;(Executable Instructions)
.code
main PROC

;Initialize the FPU and set for 3 place rounding.
	finit
	fnstcw contWord				;Store control word in WORD contWord.
	mov ax, contWord
	or ax, 03h				;Set rounding control to round to 3 hex (2nd operand).
	mov contWord, ax
	fldcw contWord				;Load control word

;Introduction.
	mov EDX, OFFSET	banner
	call writeString
	mov EDX, OFFSET	eCredit_1
	call writeString
	mov EDX, OFFSET	eCredit_2
	call writeString
	mov EDX, OFFSET	eCredit_3
	call writeString
	mov EDX, OFFSET	eCredit_4
	call writeString
	mov EDX, OFFSET	eCredit_5
	call writeString
	mov EDX, OFFSET	intro_1
	call writeString

top:		;Calculate another selected by user.

;Get the data.
	mov EDX, OFFSET	prompt_1
	call writeString
	call ReadInt
	mov firstNum, EAX
	mov EDX, OFFSET	prompt_2
	call writeString
	call ReadInt
	mov secondNum, EAX

;Limit user from attempting 0 ÷ 0.
	mov EAX, 0
	cmp EAX, firstNum
	je firstNumZero

;Limit user from entering second number > than first on 1st and subsequent attempts.
sec2low2:
	mov EAX, firstNum
	cmp EAX, secondNum
	jb sec2low
	jmp secOK

sec2low:
	mov EDX, OFFSET	prompt_3
	call writeString
	call ReadInt
	mov secondNum, EAX
	jmp sec2low2

secOK:	;End limit user from entering second number > than first.

;Limit user from incurring a divide by zero condition.
divzero:
	mov EAX, secondNum
	cmp EAX, 0
	je secIsZero
	jmp secNotZero

secIsZero:
	mov EDX, OFFSET	prompt_4
	call writeString
	call ReadInt
	mov secondNum, EAX
	jmp divZero

;Check again for secondNum > firstNum.
secNotZero:
	mov EAX, firstNum
	cmp EAX, secondNum
	jb sec2low

firstNumZero:	;So we allow a secondNum > than firstNum but still not zero.
	mov EAX, secondNum
	cmp EAX, 0
	je secNumGTF				;second_Number_Greater_Than_First
	jmp firstNumNotZero

secNumGTF:
	mov EDX, OFFSET	prompt_5
	call writeString
	call readInt
	cmp EAX, 0
	je firstNumZero
	mov secondNum, EAX

firstNumNotZero:

;Calculate the required results.

;Addition.
	mov EAX, firstNum
	add EAX, secondNum
	mov result_1, EAX

;Subtration.
	mov EAX, firstNum
	sub EAX, secondNum
	mov result_2, EAX

;Multiplication.
	mov EAX, firstNum
	mov EBX, secondNum
	mul EBX
	mov result_3, EAX

;Division. [2]
	mov EAX, firstNum
	mov EDX, 0
	mov EBX, secondNum
	div EBX
	mov result_Q, EAX
	mov result_R, EDX

;FPU Division. [3]
	fld firstNum
	fld secondNum
	fdiv
	fst result_FP				;capture div result but don't pop the FPU stack

;Display the results.
	call CrLf
;Display Addition
	mov EAX, firstNum
	call writeDec
	mov EDX, OFFSET	plus
	call writeString
	mov EAX, secondNum
	call writeDec
	mov EDX, OFFSET	equals
	call writeString
	mov EAX, result_1
	call writeDec
	call CrLf

;Display Subtraction
	mov EAX, firstNum
	call writeDec
	mov EDX, OFFSET	minus
	call writeString
	mov EAX, secondNum
	call writeDec
	mov EDX, OFFSET	equals
	call writeString
	mov EAX, result_2
	call writeInt				;writeInt so -result_2 displays correctly.
	call CrLf

;Display Multiplication
	mov EAX, firstNum
	call writeDec
	mov EDX, OFFSET	times
	call writeString
	mov EAX, secondNum
	call writeDec
	mov EDX, OFFSET	equals
	call writeString
	mov EAX, result_3
	call writeDec
	call CrLf

;Display Division
	mov EAX, firstNum
	call writeDec
	mov EDX, OFFSET	divide
	call writeString
	mov EAX, secondNum
	call writeDec
	mov EDX, OFFSET	equals
	call writeString
	mov EAX, result_Q
	call writeDec
	mov EDX, OFFSET	remainder
	call writeString
	mov EAX, result_R
	call writeDec
	mov EDX, OFFSET	ore
	call writeString

	fimul thousand				;Multiply by 1000 to preserve 3 decimal digits of the fractional part
	frndint					;Round to integer.
	fidiv thousand				;Multiply by 1000 to recreate 3 decimal digits.
	call writeFloat
	call CrLf

;Poll user for calcAgain?
	mov EDX, OFFSET	calcAgain
	call writeString
	call readInt
	cmp EAX, 1
	je top	

;Say goodbye.
	call CrLf
	mov EDX, OFFSET	sayBye
	call WriteString

	INVOKE ExitProcess,0
main ENDP

END main
