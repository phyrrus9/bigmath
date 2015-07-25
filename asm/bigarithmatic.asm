%include 'asm/bigglobal.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BSS Section                                   ;
;This is used to define all global variables   ;
;used within this library                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss
_arithinit:RESB	1			;flag set to 1 after init
					;MAKE SURE TO SET THIS FIRST!
%include 'asm/bigadd.asm'
%include 'asm/bigsub.asm'
%include 'asm/bigtostr.asm'
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Text section                                  ;
;Where all of the library code lives           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
addinit:;do common inits for addxxx functions
	MOV	R0,[_arithinit]		;copy init value
	CMP	R0,0x01			;check
	JE	.done			;if we already initialized, skip it
	CLC				;clear old carry
	CMP	R9B,0			;check for input carry
	JE	.doadd			;if no carry, do the operation
	STC				;else, set the carry first
	.doadd:				;begin add block
	XOR	R9B,R9B			;clear C
	MOV byte [_arithinit],0x01	;set init to true (prevent further calls to init)
	.done:
	RET
bigarithmatic:;C wrapper for calling add functions
	PUSH	R9
	PUSH	R10
	PUSH	R11
	PUSH	R12
	MOV	R0,R7			;move the function into R0
	MOV	R10,R6			;move DST into R10
	MOV	R11,R2			;move SRC1 into R11
	MOV	R12,R1			;move SRC1 into R12
	MOV	R9,R8			;move C into R9
	CMP	R9,0x0
	JE	.callfnc
	MOV	R9,0x1			;set R9=1 (R9B=0x01)
	.callfnc:
	MOV BYTE [_arithinit], 0x00	;set the init flag (THIS HAS TO HAPPEN)
	CALL	R0			;call the function
	MOV	R0, R9			;move C into R0
	POP	R12
	POP	R11
	POP	R10
	POP	R9
	RET
