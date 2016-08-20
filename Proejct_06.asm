TITLE Macro Demo      (Project_06.asm)

Comment !
Author: Chris Kearns			traveler-403@msn.com
Date: 05 Jun 2016

Description: Program gets 10 valid integers from a user and stores the
numeric values in an array. The program then displays the integers, their
sum, and their average. Program uses custom procedures and macros as follows:

ReadVal - invokes getString macro to get user’s string of digits. It then
converts the digit string to numeric, while validating the user’s input.

WriteVal - converts numeric values to a string of digits, and invokes the
displayString macro to produce the output.

getString - displays prompt to get the user’s keyboard input into a memory location.
displayString - displays string stored in a specified memory location.
!

INCLUDE Irvine32.inc
	LEN = 0ah		; 10
	MIN = 0			; No negatives allowed.
	LOW_ = 30h		; ASCII 0
	HIGH_ = 39h		; ASCII 9
	MAXIN = 0BEBC200h	; 200,000,000 selected to inhibit program integer overflow at line 328 div instruction.
				; 214,748,364 is the actual limit, but 200,000,000 is easier for user to keep in mind.

.data
	userMsg_1	BYTE		"Welcome to Project6_KearnsC.asm by Chris Kearns",0dh,0ah
			BYTE		"Please provide 10 unsigned decimal integers.",0dh,0ah
			BYTE		"Each number needs to be small enough to enable 32-bit division on the sum",0dh,0ah
			BYTE		"and since we're summing your 10 numbers, max allowable input is 200,000,000.",0dh,0ah
			BYTE		"After you have finished inputting the raw numbers I will display a list",0dh,0ah
			BYTE		"of the integers, their sum, and their average value.",0dh,0ah,0dh,0ah
			BYTE		"**EC-1: User input line numbered and displays running subtotal with",0dh,0ah
			BYTE		"	displayString Macro.",0dh,0ah,0dh,0ah,0

	userMsg_a	BYTE		"Subtotal so far = ",0
	userMsg_2	BYTE		". Please enter an unsigned number: ",0
	userMsg_3	BYTE		"ERROR: You did not enter an unsigned number or your number was too big.",0dh,0ah
			BYTE		"Please try again: ",0dh,0ah,0

	userMsg_4	BYTE		"You entered the following numbers: ",0dh,0ah,0
	comSpace	BYTE		", ",0
	userMsg_5	BYTE		"The sum of these numbers is: ",0
	userMsg_6	BYTE		"The average is: ",0
	userMsg_7	BYTE		"Thanks for playing!",0dh,0ah,0dh,0ah,0

	array		DWORD	LEN dup(0)	; array to hold the users validated inputs.
	arrCnt		DWORD	LEN dup(0)	; array to hold the digits count of users validated inputs (used in writeVal).
	user_str	DWORD	11 DUP(0)	; Temp memory location for capturing user's string input.
	holder		BYTE	11 DUP(0)	; Temp memory location for displaying ints as strings.
	count		DWORD	?		; Number of char's in each individual user string input.
	lineNum		DWORD	0		; Line number counter.
 

;--------------------------------------------------------------------------------------------
; getString Macro gets a user inputted string into user_string and # of chars entered into
;			   count variable using ReadString.
; Receives @user_str, @count
; Uses eax, ebx, ecx, edx but all are preserved with pushad/popad.
;--------------------------------------------------------------------------------------------
getString MACRO user_str_, count_
	pushad
	mov edx, OFFSET userMsg_2
	call WriteString
	mov edx, user_str_			;; edx gets @user_str.
	mov ecx, 11
	call ReadString				;; user_str gets user's string.
	mov ebx, count_				;; ebx gets @count.
	mov [ebx], eax				;; Memory location "count" gets the user's string length.
	popad
ENDM 


;--------------------------------------------------------------------------------------------
; displayString Macro displays user inputted integer using WriteString.
; Receives @holder
; Uses edx but preserved with push/pop edx.
;--------------------------------------------------------------------------------------------
displayString MACRO	holder_
	push edx
	mov edx, holder_
	call WriteString
	pop edx
ENDM
 
.code 
main PROC 
	mov edx, OFFSET userMsg_1
	call WriteString

	push OFFSET array
	push OFFSET user_str
	push OFFSET count
	push lineNum					; pass by value since macros are not passed this variable.
	push OFFSET arrCnt
	call readVal
	call CrLf
	mov edx, OFFSET userMsg_4
	call WriteString

	push OFFSET holder
	push OFFSET array
	push OFFSET arrCnt
	call writeVal

	call CrLf
	push OFFSET array
	call showSumAvg

	call CrLf
	mov edx, OFFSET userMsg_7
	call WriteString
	call CrLF
exit
main	ENDP

 
;**********************************************************************************************
; readVal - Procedure that uses getString MACRO to get and validate user numerical input as a
;			string, validates the string to corresponding ints, and stores in array.
; Receives:	@array (stores the input), @user_str (buffer), @count (digits per user input),
;			lineNum (for displaying line numbers), @arrCnt (digits per user input storage).
; Returns:	Nothing, but user's strings stored as ints in array.
; Preconditions:	push array, user_str, and count prior to calling readVal.
; Registers Changed: eax, ebx, ecx, edx, edi, esi but all are preserved with pushad/popad
;**********************************************************************************************
readVal PROC
	push ebp
	mov ebp, esp
	pushad
	mov ecx, LEN				; Set ecx to LENgth of array.
	mov edi, [ebp+24]			; edi gets @array - sets up stosd call.

outerLoop:
	push OFFSET array
	call subTot				; Display running subtotal.
	call CrLf
	mov eax, [ebp+12]			; eax has lineNum = 0.
	inc eax
	mov [ebp+12], eax			; lineNum incremented.
	
	push eax
	push OFFSET holder
	call int2string

	getString [ebp+20], [ebp+16]		; Pass user_str and count by reference to getString Macro.

	push ecx
	mov esi, [ebp+20]			; esi gets @user_str.
	mov ecx, [ebp+16]			; ecx gets @count (# of digits entered by user). 
	mov ecx, [ecx]				; Dereference count to ecx.
	cld 
	xor ebx, ebx				; Set ebx accumulator to 0 for validate_convert loop.

	jmp validate_convert			; workaround jmp destination too far error at loop outerloop instruction.
loopExtender:	
	jmp outerloop

validate_convert:
	lodsb					; eax gets 1 BYTE of user_str loaded in esi. **********[lodsb call is here]********** 
	cmp al, LOW_
	jb reportError
	cmp al, HIGH_
	ja reportError 
	sub al, LOW_

	push eax				; See Citation 1 under Program Description above.
	mov eax, ebx
	mov ebx, 10
	mul ebx
	mov ebx, eax
	pop eax
	add ebx, eax
	loop validate_convert

	mov eax, ebx				; Final answer!
	cmp eax, MAXIN				; One last check for input too big to enable 32-bit division on the sum (line 328).
	ja reportError

	stosd					; Put user's int string (eax) into array loaded @edi.

	push eax				; Capture count of user inputed digits to arrCnt array.
	push ebx
	mov eax, [ebp+8]			; eax gets @arrCnt.
	mov ebx, [ebp+16]			; ebx gets @count.
	mov ebx, [ebx]
	mov [eax], ebx				; arrCnt gets ecx (user input digit count, this pass).
	add eax, TYPE DWORD
	mov [ebp+8], eax			; Increment @arrCnt on the stack by 4 for next pass.
	pop ebx
	pop eax

	add esi, TYPE DWORD			; Move to next array index.
	pop ecx
	loop loopExtender			; Equivalent to loop outerLoop.
	jmp toTheEnd

reportError:
	pop ecx
	mov edx, OFFSET userMsg_3
	call WriteString
	call CrLf
	mov eax, [ebp+12]			; eax gets lineNum value.
	dec eax					; lineNum decremented due to error condition.
	mov [ebp+12], eax
	jmp outerLoop

toTheEnd:
	popad
	pop ebp			 
	ret 20
readVal ENDP 


; ****************************************************************************************************** 
; writeVal - procedure to convert int array to ASCII with a known # of digits at each array element and
;		   then uses displayString Macro to print to the console.
; Receives:	@array (user's inputed string/ints), @arrCnt (digits per use input storage), and  @holder.
; Returns:		Nothing.
; Preconditions:	array must have user inputed strings stored as ints, arrCnt must have digit counts.  
; Registers Changed: eax, ebx, ecx, edx, edi, esi but all are preserved with pushad/popad.
; ****************************************************************************************************** 
writeVal PROC 
	push ebp
	mov ebp, esp
	pushad

	mov ecx, LEN
	xor ebx, ebx				; Used to increment array[] and arrCnt[].

topOfLoop:

	push eax
	push ecx
	push edi
	xor al, al				; Clear holder of residual string BYTES.
	mov edi, [ebp+16]
	mov ecx, 11
	cld
	rep stosb
	pop edi
	pop ecx
	pop eax

	push ecx				; used to control last comSpace.
	mov edi, [ebp+16]			; edi gets @holder.
	mov esi, [ebp+8]			; esi gets @arrCnt.
	add esi, ebx				; esi gets incremented @arrCnt.
	mov esi, [esi]				; Dereference arrCnt
	add  edi, esi				; Add arrCnt[] to edi. See Citation 2 under Program Description above.
	dec edi					; edi now has the string's ending BYTE address.
	std
	mov esi, [ebp+12]			; eax gets @array.
	add esi, ebx
	mov eax, [esi]				; Dereference array[].
	push ebx

convertInt:
	mov ebx, 10
	cdq
	div ebx
	add edx, 48				; Convert to ASCII.
	push eax
	mov al, dl				; al gets converted ASCII value.
	stosb 
	pop eax
	cmp eax, 0
	je display
	jmp convertInt				; Loops until dividend in eax = 0.

display:
	pop ebx					; From line 264.
	displayString [ebp+16]			; Print converted string in holder.
	pop eax					; eax gets previously pushed ecx.
	cmp eax, 1				; Don't print a trailing comma.
	je skipComSpace
	mov edx, OFFSET comSpace
	call WriteString

skipComSpace:
	add ebx, TYPE DWORD
	loop topOfLoop

	popad
	pop ebp
	ret 12
writeVal ENDP
 

;******************************************************************************************* 
; showSumAvg - procedure calculates the sum and average of array and prints to the console.
; Receives:	@array (in int format)
; Returns:	Nothing. 
; Preconditions:	array must contain ints, not strings!!  
; Registers Changed: eax, ebx, ecx, edx, esi but all are preserved with pushad/popad
; ****************************************************************************************** 
showSumAvg PROC 
	push ebp
	mov ebp, esp
	pushad

	mov esi, [ebp+8]				; esi gets @array.
	xor eax, eax					; eax sum accumulator initialized to 0.
	mov ecx, LEN

sumLoop: 
	mov ebx, [esi]					; esi gets array[index].
	add eax, ebx
	add esi, TYPE DWORD
	loop sumLoop					; Loop terminates and eax now has sum.

	mov edx, OFFSET userMsg_5			; Display sum
	call WriteString
	push eax					; Sets up call to int2string
	push OFFSET holder
	call int2String
	call CrLf
	mov ebx, LEN	
	cdq
	div ebx						; Integer division and client wants round down.

	push eax					; eax has quotient and sets up call to int2string.
	push OFFSET holder
	mov edx, OFFSET userMsg_6			; Display average.
	call WriteString
	call int2String
	call CrLf
 
	popad
	pop ebp
	ret 4
showSumAvg ENDP


;******************************************************************************************* 
; subTot - procedure calculates and prints the subtotal of numbers entered by user so far.
; Receives:	@array (in int format)
; Returns:	Nothing. 
; Preconditions:	array must contain ints, not strings!!  
; Registers Changed: eax, ebx, ecx, edx, esi but all are preserved with pushad/popad
; ****************************************************************************************** 
subTot	PROC
	push ebp
	mov ebp, esp
	pushad
	call CrLf
	mov edx, OFFSET userMsg_a
	call WriteString
	mov esi, [ebp+8]				; esi gets @array.
	xor eax, eax					; eax sum accumulator initialized to 0.
	mov ecx, LEN

sumLoop:
	mov ebx, [esi]					; ebx gets array[index].
	add eax, ebx
	add esi, TYPE DWORD
	loop sumLoop					; Loop terminates and eax now has sum.

	push eax
	push OFFSET holder
	call int2string
	call CrLf

	popad
	pop ebp
	ret 4
subTot	ENDP


;*******************************************************************************************
; int2string - procedure converts a single int with an unknown # of digits to a string and
;			displays it with displayString Macro.
; Receives:	decimal int for processing from a stack push, @holder (string print helper).
; Returns:	Nothing. 
; Preconditions:	Stack must contain int to be converted/displayed and @holder. 
; Registers Changed: al, eax, ebx, ecx, edx, edi esi but all are preserved with pushad/popad
; ******************************************************************************************
int2String	PROC
	push ebp
	mov ebp, esp
	pushad

	xor al, al				; Clear holder of residual string BYTES.
	mov edi, [ebp+8]
	mov ecx, 11
	cld
	rep stosb

	xor ebx, ebx				; Set digit counter to 0.
	mov eax, [ebp+12]			; eax gets the int to be converted (from stack:)
countDigits:
	inc ebx
	mov esi, 10
	cdq
	div esi
	cmp eax, 0
	je gotDigitCount
	jmp countDigits

gotDigitCount:
	mov eax, ebx				; eax now has number of digits in the integer.
	mov edi, [ebp+8]
	add edi, eax
	dec edi					; edi now has the string's ending BYTE address.
	std
	mov eax, [ebp+12]			; eax gets the int to be converted (again).

cnvrtInt:
	mov ebx, 10
	cdq
	div ebx
	add edx, 48
	push eax
	mov al, dl
	stosb
	pop eax
	cmp eax, 0
	je fnshd
	jmp cnvrtInt

fnshd:
	displayString [ebp+8]

	popad
	pop ebp
	ret 8
int2String	ENDP

exit
END main
