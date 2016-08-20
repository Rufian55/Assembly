TITLE Program 4 Composite Numbers by Chris Kearns (Kearns_Project_4.asm)

; Author: Chris Kearns
; Date: 8 May 2016
; Description: MASM program to perform the following tasks:
; Displays the program title and programmer’s name.
; Displays instructions for the user.
; Repeatedly prompts the user to enter an in range number.
; Validates the user's input to be in [1, 1,000,000] (inclusive).
; Calculates and displays all composite to user entered int, inclusive.
; Includes appropriate error and farewell messages and a few extras ;).

INCLUDE Irvine32.inc

; Constants
	LOWLIM = 01h		; 1 decimal
	HIGHLIM = 0F4240h	; 1,000,000 decimal
	NUMPRIME = 132A3h	; (78,498 + 1)d = number of primes to 1,000,000d (+1 for good measure only ;).
	TAB = 9			; Ascii code for tab.

.data
; Message Strings.
	userMsg_1	BYTE		"Welcome to Kearns_Project04.asm by Chris Kearns",0dh,0ah
			BYTE		"aka, The Composite Number Generator",0dh,0ah,0dh,0ah
			BYTE		"If you enter a positive integer in the range of [",0
	userMsg_2	BYTE		", ",0
	userMsg_3	BYTE		"] inclusive,",0dh,0ah
			BYTE		"I will display all composite numbers from ",0
	userMsg_4	BYTE		" to the integer you enter.",0dh,0ah,0dh,0ah,0
	userMsg_5	BYTE		"Please enter a positve integer in the range [",0
	userMsg_6	BYTE		"] inclusive: ",0

	userMsg_E	BYTE		"I'm sorry, you have entered an out of range integer.",0dh,0ah,0dh,0ah,0
	userMsg_K	BYTE		"Your entered integer of ",0
	userMsg_L	Byte		" is not a composite number and has no",0dh,0ah
			BYTE		"preceeding composite numbers. :(",0dh,0ah,0
	userMsg_Z	BYTE		"Thank you for trying The Composite Number Generator!",0dh,0ah,0dh,0ah,0
	spacer		BYTE		" ",0	; 1 space
	again_		BYTE		"Bartender in The Fifth Element: You want some more?",0dh,0ah
			BYTE		"Enter 1 for yes, any other int for quit: ",0

	EC_1		BYTE		"**EC-1: Output is aligned in columns.",0dh,0ah,0dh,0ah,0
	EC_2		BYTE		"**EC-2: Scrolls Display every 23 lines. As such, please note:",0dh,0ah
			BYTE		"  1. Upper Limit set 1,000,000.",0dh,0ah
			BYTE		"  2. Composites are displayed 5 per line (6, 7, 8, & 9 seem less useful).",0dh,0ah
			BYTE		"  3. Composites are seperated by 1 space and a tab.",0dh,0ah,0dh,0ah,0
	EC_3		BYTE		"**EC-3: An extra: User offered opportunity to continue until quit.",0dh,0ah,0dh,0ah,0
	EC_4		BYTE		"**EC-4: Creative use of color.",0dh,0ah,0dh,0ah,0
	EC_5		BYTE		"**EC-5: Special handling routine & message for valid userInt < 4.",0dh,0ah,0dh,0ah,0
	EC_6		BYTE		"**EC-6: Generated Primes saved as array and used to process int",0dh,0ah
			BYTE		"  sequences upto user entered int via divide by primes to n/2.",0dh,0ah,0dh,0ah,0

; Variable Declarations.
	userInt		DWORD	0		; User inputed variable.
	counter		DWORD	1		; Our sequence variable used in showComposites loop for Cr at multiples of 5.
	aCompInt	DWORD	0		; Boolean result generated from isComposite Process.
	intInQue	DWORD	4		; Variable passed to isComposite for testing, set to 4 as 1,2, & 3 are special cases.
	arrPrime	DWORD	NUMPRIME dup(?)	; Array to store primes from 0 to HIGHLIM = 0F4240h (there's a few extra).
	arrCount	DWORD	8		; Index count for arrPrime[] set to 8, as we manually initialize arrPrime for base case 2&3.
	increment	DWORD	TYPE DWORD	; Instead of the literal 4, so program can be modifed later as needed.
	arrItr		DWORD	increment	; Iterator for walking through arrPrime set to first element.

.code
main PROC
		call	introduction
	again:
		call	getUserData
		call	showComposites
		call	goAgain
		cmp	eax, 1
		je	again
		call	farewell
	exit					; Exit to operating system
main ENDP

;****************************************************************************
; Procedure to display introductory messages.
; Receives: Nothing
; Returns: Nothing
; Preconditions: None
; Registers changed: eax, edx
;****************************************************************************
introduction	PROC
	mov	edx,	OFFSET	userMsg_1
	call	writeString
	mov	eax, LOWLIM
	call	writeDec
	mov	edx,	OFFSET	userMsg_2
	call	writeString
	mov	eax, HIGHLIM
	call	writeDec
	mov	edx,	OFFSET	userMsg_3
	call	writeString
	mov	eax,	LOWLIM
	call	writeDec
	mov	edx,	OFFSET	userMsg_4
	call	writeString
	mov	eax, 14
	call	setTextColor
	mov	edx,	OFFSET	EC_1
	call	writeString
	mov	edx,	OFFSET	EC_2
	call	writeString
	mov	edx,	OFFSET	EC_3
	call	writeString
	mov	edx,	OFFSET	EC_4
	call	writeString
	mov	edx,	OFFSET	EC_5
	call	writeString
	mov	edx,	OFFSET	EC_6
	call	writeString
	mov	eax,	7
	call	setTextColor
	ret
introduction	ENDP

;****************************************************************************
; Procedure to get and call validate on the user data.
; Receives: user input for global userInt, LOWLIM, HIGHLIM
; Returns: Nothing
; Preconditions: None.
; Subroutines: validate
; Registers changed: eax, edx
;****************************************************************************
getUserData	PROC
	mov	edx,offset	userMsg_5
	call	writeString
	mov	eax,	LOWLIM
	call	writeDec
	mov	edx,	OFFSET	userMsg_2
	call	writeString
	mov	eax,	HIGHLIM
	call	writeDec
	mov	edx,	OFFSET	userMsg_6
	call	writeString
	call	readInt
	mov	userInt, eax
	call	validate						; Procedure call to validate user data.
	ret
getUSerData	ENDP

;****************************************************************************
; Procedure to validate user input.
; Receives: LOWLIM, HIGHLIM, eax register with userInt value.
; Returns: Nothing
; Preconditions: userInt, valid or not.
; Subroutines:	getUSerData
; Registers changed: edx
;****************************************************************************
validate		PROC
		cmp	eax, LOWLIM
		jl	error
		cmp	eax,	HIGHLIM
		jg	error
		jmp	noError
	error:
		mov	edx, OFFSET	userMsg_E
		call	writeString
		call	getUSerData				; Re-call procedure due to out of range user input.
	noError:
	ret
validate		ENDP

;****************************************************************************
; Procedure to display valid composites in formatted style.
; Receives: userInt, 
; Returns: Nothing
; Preconditions: validated userInt
; Subroutines:	is_1_2or3
; Registers changed: eax, ebx, ecx, edx
;****************************************************************************
showComposites	PROC
		mov	eax, userInt				; Handle base case of valid userInt < 4.
		cmp	eax,	3
		jg	print
		call is_1_2or3					; Procedure call to display special message.
		jmp	done
	print:
		mov	eax, 2					; Initialize arrPrime[] with base case primes 2 and 3.
		mov	arrPrime[4], eax
		mov	eax, 3
		mov	arrPrime[8], eax
		mov	ecx,	userInt
	top:
		pushad
		call	isComposite				; Procedure call, returns bool 1 or 0.
		popad
		mov	eax, aCompInt
		cmp	aCompInt, 1
		jnz	noPrint
		mov	edx, OFFSET	spacer
		call writeString
		mov	eax, intInQue
		call	writeDec
		mov al, TAB
		call writeChar
		mov	eax,	counter				; Begin test for EOL
		inc	counter
		mov	ebx, 5					; Change here for composites per line.
		cdq
		div	ebx
		cmp	edx, 0
		je	printEOL
		jmp	noPrint
	printEOL:
		call CrLf
		mov	eax, counter				; Begin test for freeze results display
		dec	eax
		mov	ebx, 23					; Change here for different lines per page display - 23 fits default window.
		cdq
		div	ebx
		cmp	edx, 0
		je	freeze
		jmp	noPrint
	freeze:							; Page scroll display message.
		call WaitMsg
		call	CrLf
	noPrint:							; intInQue was a prime.
		inc	intInQue
		cmp	ecx, 4					; Interupt the ecx countdown as < 4 is handled by is1_2or3 procedure.
		je	done
		loop	top
	done:
	ret
showComposites	ENDP

;****************************************************************************
; Procedure to determine if intInQue is composite via an array of primes.
; Receives: intInQue, increment, arrPrime[], arrCount, arrItr.
; Returns: bool aCmpInt set 1 for true, 0 for false.
; Preconditions: validated userInt
; Registers changed: eax, ebx, ecx, edx, edi
;****************************************************************************
isComposite	PROC
		mov	eax, increment			; Reset array Iterator. 		
		mov	arrItr, eax

		mov	eax, arrCount			; Divide arrCount (BYTE) by increment for ecx counter.
		mov	ebx,	increment
		cdq
		div	ebx
		mov	ecx,	eax				; ecx now contains the maximum times to iterate intInQue to conclude "it's prime".
	isCompStart:
		mov	aCompInt, 0			; Default to false.
		mov	eax, intInQue
		mov	edi,	arrItr
		mov	ebx, arrPrime[edi]		; Starts at 2, 3, 5, 7, 11, etc. which gets vast majority of composites early.  
		cdq
		div	ebx
		cmp	edx, 0
		je	True_
		cmp	ecx, 1				; Interupt the ecx countdown to avoid division by 1, else always returns true.
		je	False_
		mov	eax,	increment
		add arrItr, eax
		loop	isCompStart
		jmp	False_
	True_:
		mov	aCompInt, 1
		jmp	finish	
	False_:						; It's a prime, so we must add it to arrPrime[] at the correct index location.
		mov	eax, increment
		add	arrCount, eax
		mov	eax, intInQue
		mov	ebx, arrCount
		mov	arrPrime[ebx], eax
	finish:
		ret
isComposite	ENDP

;****************************************************************************
; Procedure to handle base case display of in range userInts 1, 2, and 3.
; Receives: Nothing
; Returns: Nothing
; Preconditions: validated userInt == 1, 2, or 3
; Registers changed: eax, edx
;****************************************************************************
is_1_2or3		PROC
		call	CrLf
		mov	edx,	OFFSET	userMsg_K
		call	writeString
		mov	eax,	userInt
		call	writeDec
		mov	edx,	OFFSET	userMsg_L
		call	writeString
	ret
is_1_2or3		ENDP

;****************************************************************************
; Procedure to offer user chance to run program again.
; Receives: Nothing
; Returns: eax with users answer and resets variables as noted below.
; Preconditions: Progarm has run at least once.
; Registers changed: eax, edx
;****************************************************************************
goAgain	PROC
	mov	counter, 1			; resets counter.
	mov	aCompInt, 0			; resets aCompInt.
	mov	intInQue, 4			; resets intInQue.
	mov	arrCount, 8			; resets arrCount
	mov	eax, increment
	mov	arrItr, eax			; resets arrItr
	call CrLf
	mov	edx, OFFSET	again_
	mov	eax, 12
	call setTextColor
	call writeString
	mov	eax, 7
	call setTextColor
	call readInt
	ret
goAgain	ENDP

;****************************************************************************
; Procedure to display farewell message.
; Receives: Nothing
; Returns: Nothing
; Preconditions: Composites displayed.
; Registers changed: eax, edx
;****************************************************************************
farewell		PROC
		call	CrLf
		call CrLf
		mov	edx,	OFFSET	userMsg_Z
		mov	eax, 10
		call setTextColor
		call	writeString
		mov	eax, 7
		call	setTextColor
	ret
farewell		ENDP

END main
