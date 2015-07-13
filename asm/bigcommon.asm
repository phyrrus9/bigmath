%include 'asm/bigglobal.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Text section                                  ;
;Where all of the library code lives           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
bigcmp:	;(FOLLOWS System-V ABI = does not need wrapper.)
	;SRC1=R7
	;SRC2=R6
	;SIZE=R2 (in bytes. MUST be a multiple of 8, but is not checked)
	XOR	R0,R0			;zero the result (they are equal)
	PUSH	R7			;push R7, this will be our index
	PUSH	R8			;R8 is the loop counter
	PUSH	R10			;push R10, used for SRC1 storage
	PUSH	R11			;push R11, used for SRC2 storage
	PUSH	R12			;SRC1 is copied to R12
	PUSH	R13			;SRC2 is copied to R13
	MOV	R12,R7			;copy SRC1 to R12
	ADD	R12,R2			;add them, so we can iterate backwards
	MOV	R13,R6			;same for SRC2
	ADD	R13,R2
	SUB	R12,0x8			;sub 1 quad-word from both
	SUB	R13,0x8
	XOR	R8,R8			;zero our loop counter
	.ltop:				;loop start
	CMP	R8,R2			;if lc is size, we are done
	JE	.eq			;jump out if same
	MOV	R7,R12			;move SRC1 to R7 (8-byte)
	MOV	R10,[R7]		;move [SRC1] to R10
	MOV	R7,R13			;move SRC2 to R7
	MOV	R11,[R7]		;R11=[SRC2]
	CMP	R10,R11			;compare them
	JB	.lt			;if R10 < R11, return -1
	JA	.gt			;else if R10 > R11, return 1
	SUB	R12,0x8			;else --SRC1, --SRC2
	SUB	R13,0x8
	ADD	R8,0x8			;add 8 to the loop counter
	JMP	.ltop			;jump back up
	JMP	.eq
	.lt:
	MOV	R0,-1			;lt=-1
	JMP	.eq
	.gt:
	MOV	R0,1			;gt=1
	JMP	.eq
	.eq:
	POP	R13
	POP	R12
	POP	R11
	POP	R10
	POP	R8
	POP	R7
	RET
