TITLE Dog_Age_Demo     (Project00.asm)

; Author: Chris Kearns
; Course / Project ID: Demo #0     Date: 29 Mar 2016
; Description: Demo assembly program to introcuce programmer, get the user's name and age,
;	calculate the user's "dog age", report the results. 

INCLUDE Irvine32.inc

.data
result	DWORD	0

.code
main PROC
.data
;val1 WORD 2000h
;val2 WORD 0100h
;array  SWORD 8,2,3,5,-4,6,0,4
.code
mov ax,48
mov bx,4
imul bx


;mov dl, 00001010b
;and dl,0Eh
;cmp dl,0Eh
;je  L4
;mov eax, 9
;call writeInt
;L4:
;mov eax, 69
;call writeint

;	mov al,9Ch
;	not al
;	call writeInt
 ;   mov cx,1
  ;  mov esi,2
;    mov ax,array[esi]
;    mov bx,array[esi+4]
;    cmp ax,3
;    jae L2
;    cmp bx,4
;    jb  L1
;    jmp L3
;L1: mov cx,4
;L2: mov dx,5
;    jmp L4
;L3: mov dx,6
;L4:   

;(insert executable instructions here)

	exit	; exit to operating system
main ENDP

; (insert additional procedures here)

END main