TITLE Random Integer Sorter (Project5_KearnsC.asm)

Comment !
Author: Chris Kearns
CS-271-400-S16 / Project 5	Date: 22 May 2016
 
Description: Program accomplishes the following tasks:
1. Introduces the program and instructions.
2. Gets user requested for 3 of random ints: range [min = 10 .. max = 200].
3. Generates requested random integers each in the range [lo = 100 .. hi = 999],
	storing them in consecutive elements of an array.
4. Displays the list of integers before sorting, 10 numbers per line.
5. Sorts the list in descending order (i.e., largest first).
6. Calculates and displays the median value, rounded to the nearest integer.
7. Displays the sorted list, 10 numbers per line.
!

INCLUDE Irvine32.inc

; Constants:
	MIN	= 10			; Minimum allowable user request for number of random ints to generate.
	MAX	= 200		; Maximum allowable user request for number of random ints to generate.
	LO	= 100		; Minimum range of random ints to be generated.
	HI	= 999		; Maximum range of random ints to be generated.

.data
;----Strings:
	userMsg_1	BYTE		"Welcome to the Random Integer Sorter, aka Project5_KearnsC.asm",0dh,0ah
			BYTE		"by Chris Kearns",0dh,0ah,0dh,0ah
			BYTE		"This program generates random numbers in the range [",0
	userMsg_2	BYTE		" .. ",0
	userMsg_3	BYTE		"],",0dh,0ah
			BYTE		"displays the original list, sorts the list, and calculates the",0dh,0ah
			BYTE		"median value. Finally, it displays the list sorted in descending order.",0dh,0ah,0dh,0ah,0
	userMsg_4	BYTE		"How many numbers should be generated? [",0
	userMsg_5	BYTE		"]: ",0
	userMsg_6	BYTE		"The unsorted random numbers:",0dh,0ah,0dh,0ah,0
	userMsg_7	BYTE		"The median is ",0
	userMsg_8	BYTE		".",0dh,0ah,0dh,0ah,0
	userMsg_9	BYTE		"The sorted list:",0dh,0ah,0
	UserMsg_e	BYTE		"Invalid Input!",0dh,0ah,0
	spaces	BYTE		"     ",0
	title_U	BYTE		"The unsorted random numbers:",0dh,0ah,0
	title_S	BYTE		"The sorted list:",0dh,0ah,0


;----Variables:
	median	DWORD	?			; Calculated median of the sorted array.
	list		DWORD	MAX	dup(?)	; The list array with MAX # of elements, uninitialized.
	request	DWORD	?			; User's requested # of randoms - used as list's count for ecx.

.code
main PROC
	call	Randomize
	call	Intro

	push OFFSET	request				; Pass by reference.
	call	GetData

	push	OFFSET	list					; Pass by reference.
	push	request						; Pass by value.
	call	FillArray

	push	OFFSET	list					; Pass by reference.
	push	request						; Pass by value.
	push	OFFSET	title_U				; Pass by reference.
	call	DisplayList

	push	request						; Pass by value.
	push	OFFSET	list					; Pass by reference.
	call	SortList

	push	OFFSET	userMsg_7				; Pass by reference.
	push	request						; Pass by value.
	push	OFFSET	list					; Pass by reference.
	call	DisplayMedian

	push	OFFSET	list					; Pass by reference.
	push	request						; Pass by value.
	push OFFSET	title_S				; Pass by reference.
	call	DisplayList

	exit								; Exit to operating system
main ENDP
;****************************************************************************
; Intro - Procedure to display introductory messages.
; Receives: Nothing
; Returns: Nothing
; Preconditions: None
; Registers changed: eax, edx [NOT preserved].
;****************************************************************************
Intro PROC
	mov	edx, OFFSET	userMsg_1
	call	writeString
	mov	eax,	LO
	call	writeDec
	mov	edx, OFFSET	userMsg_2
	call	writeString
	mov	eax,	HI
	call	writeDec
	mov	edx,	OFFSET	userMsg_3
	call	writeString
	ret
Intro ENDP

;****************************************************************************
; GetData - Procedure to get user's input data.
; Receives: request
; Returns: request - containing validated user input
; Preconditions: None.
; Registers changed:	eax, ebx, edx [NOT preserved].
;****************************************************************************
GetData	PROC
	push	ebp
	mov	ebp,esp
	jmp	skip						; skip over BadInput first time through.
BadInput:
	mov	edx,	OFFSET	userMsg_e
	call	writeString
skip:
	mov	edx,	OFFSET	userMsg_4
	call	WriteString
	mov	eax,	MIN
	call	writeDec
	mov	edx,	OFFSET	userMsg_2
	call	writeString
	mov	eax,	MAX
	call	writeDec
	mov	edx,	OFFSET	userMsg_5
	call	writeString
	call	ReadInt					; Get user's desired number of random ints.
	mov	ebx, [ebp+8]				; Put @request in ebx to pass to Validate and,
	mov	[ebx], eax				;   store user input in request.
	call	validate
	cmp	eax, 1					; Check for valid input, if not, start over!
	jne	BadInput

	pop	ebp
	ret	4
GetData	ENDP

;****************************************************************************
; Validate - Procedure to valdidate user input against MIN & MAX.
; Receives: [ebx] (== request), MIN, MAX
; Returns: 0 or 1 in eax register as appropriate.
; Preconditions: user int captured in request, @request in ebx register.
; Registers changed:	eax, edi [NOT preserved].
;****************************************************************************
Validate	PROC
	mov	eax, 1
	mov	edi, [ebx]				; Check request for in range.
	cmp	edi, MIN
	jl	Fail
	cmp	edi, MAX
	jg	Fail
	jmp	Pass
Fail:
	mov	eax, 0
Pass:
	ret	
Validate	ENDP

;****************************************************************************
; FillArray - Procedure to fill the array with unsorted random numbers.
; Receives: OFFSET list, request, LO, HI
; Returns: Nothing
; Preconditions: Validated user input
; Registers changed:	eax, ecx, edi [NOT preserved].
; See citation [1] & [2] at end of this file.
;****************************************************************************
FillArray	PROC
	push	ebp
	mov	ebp, esp
	mov	ecx,	[ebp+8]			; Set ecx counter.
	mov	edi, [ebp+12]			; position list[0] for accepting randoms
	mov	eax,	HI
	sub	eax,	LO
	inc	eax
top:
	call	RandomRange
	add	eax, LO				; To get our required range
	mov	[edi], eax			; Add eax to list[edi].
	add	edi, TYPE DWORD
	loop	top

	pop	ebp
	ret 8
FillArray	ENDP

;****************************************************************************
; SortList - Selection Sort procedure.
; Receives: OFFSET list, request
; Returns: Nothing - sorts array in place.
; Preconditions: valid array and length of array pushed onto stack.
; Registers changed:	eax, ebx, ecx, esi, edi [NOT preserved].
;****************************************************************************
SortList	PROC
	push	ebp
	mov	ebp, esp
	mov	esi, [ebp+8]			; esi points to list[0].
	mov	ecx, [ebp+12]			; ecx = request.
	dec	ecx					; ecx = request - 1.
	mov	ebx, 0				; ebx is set to k = 0.

OuterLoop:					; for(k = 0, k < request-1; k++).
	mov	eax, ebx				; eax = i = k.
	mov	edx, eax
	inc	edx					; edx = j = k + 1.
	push	ecx					; Save outer loop counter to stack.

InnerLoop:					; for(j = k + 1; j < request; j++).
	mov	edi, [esi+edx*4]
	cmp	edi, [esi+eax*4] 
	jle	endInnerLoop			; if(list[j] > list[k]).
	mov	eax, edx 
endInnerLoop: 
	inc	edx					; Increment J.
	loop	InnerLoop 

; Setup for Exchange call.
	lea	edi, [esi+ebx*4]		; Put address of list[k] in edi.
	push	edi
	lea	edi, [esi+eax*4]		; Put address of list[j] in edi.
	push	edi 
	call	Exchange

	pop	ecx					; Restore OuterLoop counter from stack. 
	inc	ebx					; Increment K. 
	loop	OuterLoop

	pop	ebp
	ret	8
SortList	ENDP

;****************************************************************************
; Exchange - Utility Procedure to exchange list[k] & list[i] for PROC SortList.
; Receives: k, i
; Returns: i, k, (swapped).
; Preconditions: populated list (array), stack has @k & @i pushed.
; Registers changed:	eax, ebx, ecx, edx, [all preserved].
; See citation [3] and [4]
;****************************************************************************
Exchange	PROC
	pushad
	mov ebp, esp
	mov	eax, [ebp+40]			; eax gets @k.
	mov	ecx,	[eax]			; ecx gets k.
	mov	ebx, [ebp+36]			; ebx gets @i.
	mov	edx, [ebx]			; edx gets i.
	mov	[eax], edx			; k = i.
	mov	[ebx], ecx			; i = k.
	popad
	ret 8
Exchange	ENDP

;****************************************************************************
; DisplayMedian - Procedure to calculate and display sorted array's median.
; Receives: @userMsg_7, @list, request
; Returns: Nothing.
; Preconditions: sorted list (array) with known length.
; Registers changed: eax, ebx, edx, edi, esi [NOT preserved].
;****************************************************************************
DisplayMedian	PROC
	push	ebp
	mov	ebp, esp
	mov	edx,	[ebp+16]				; Prints userMsg_7
	call	writeString
	mov	eax, [ebp+12]				; eax = request.
	shr	eax, 1					; Divide by 2
	jnc	even_
	mov	ebx, TYPE DWORD
	mul ebx						; eax now contains our target index.
	mov	edi, [ebp+8]
	mov	eax, [edi+eax]				; Access list[eax].
	call	writeDec
	jmp toTheEnd
even_:
	mov	ebx, TYPE DWORD
	mul ebx						; eax now contains our target index.
	mov	edi, [ebp+8]				; edi now contains @list[0].
	mov	eax, [edi+eax-4]			; Dereferences list[left] so a value is in eax.
	mov	esi, eax					; Save eax (value left of straddle).
	mov	eax, [ebp+12]				; eax = request.
	shr	eax, 1
	mov	ebx, TYPE DWORD
	mul ebx						; eax now contains our target index.
	mov	edi, [ebp+8]
	mov	eax, [edi+eax]				; Access list[right] (value right of straddle).
	add	eax,	esi					; list[eax-1] + list[eax].
	shr	eax, 1
	jnc	noRound					; test for round up.
	inc	eax
noRound:
	call WriteDec
toTheEnd:
	call	CrLf
	call	CrLf
	pop	ebp
	ret 12
DisplayMedian	ENDP

; A tested alternate DisplayMedian PROC. Clearly much more efficient (BUT NOT MY WORK) so saved here for future use.
;	mov	ecx, [esp+8]			; ecx = request.
;	mov	edx, [esp+4]			; edx = list[0].
;	shr	ecx, 1				; ecx = request/2.  CF = the bit shifted out where 0 means even, 1 means odd.
;	mov	eax, [edx + ecx*4]		; eax = list[request/2].
;	sbb	ecx, -1				; ecx += 1 - CF.
;	add	eax, [edx + ecx*4]		; eax += list[request/2] + list[(request/2)+1].
;	shr	eax, 1				; eax = median.


;****************************************************************************
; DisplayList - Procedure to display the list array.
; Receives: @title_U or @title_S, @list, request
; Returns: Nothing
; Preconditions: validated user request and a populated list.
; Registers changed:	eax, ebx, ecx, edx, esi [NOT preserved].
; See citation [1] at end of this file.
;****************************************************************************
DisplayList	PROC
	push	ebp
	mov	ebp, esp
	mov	edx, [ebp+8]			; OFFSET of title_U or title_S string.
	call	writeString
	mov	esi, [ebp+16]			; Position list[0] for iteration.
	mov	ecx,	[ebp+12]			; Initialize counter with request.
	mov	edi, 0				; Our CrLf at ebx == multiple of 10 counter.
moreElements:
	mov	eax, [esi]
	call	writeDec
	inc	edi
	mov eax, edi
	mov ebx, 10
	cdq
	div ebx
	cmp edx,0
	je	newLine
	mov	edx,	OFFSET	spaces
	call	writeString
	jmp noNewLine
newLine:
	call CrLf
noNewLine:
	add	esi, 4
	loop	moreElements
	call	CrLf
	pop	ebp
	ret 12
DisplayList	ENDP

END main

; [1] Range determination procedure found at CS271 lecture 20.
; [2] ArrayFill procedure adapted from Assembly Language for x86 Processers, 7th Ed., K. Irvine, pg. 297-298.
; [3] Exchange procedure adapted from h ttp://stackoverflow.com/questions/13407151/selection-sort-procedure-in-assembly?rq=1
; [4] ...and then perfected with h ttp://stackoverflow.com/questions/37330431/exhange-two-variables-passed-by-reference-wont-cooperate