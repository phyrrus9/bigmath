;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Global definitions                            ;
;These are used to make NASM understand our    ;
;register naming conventions (and make the code;
;look cleaner                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%define R0 RAX
%define R1 RCX
%define R2 RDX
%define R6 RSI
%define R7 RDI
[BITS 64]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;BSS Section                                   ;
;This is used to define all global variables   ;
;used within this library                      ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .bss
global initflag
initflag:RESB	1			;flag set to 1 after init
					;MAKE SURE TO SET THIS FIRST!
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Text section                                  ;
;Where all of the library code lives           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
global add64
global add128
global add256
global add1024
global add2048
global add8192
global wrapper
addinit:;do common inits for addxxx functions
	MOV	R0,[initflag]		;copy init value
	CMP	R0,0x01			;check
	JE	.done			;if we already initialized, skip it
	CLC				;clear old carry
	CMP	R9B,0			;check for input carry
	JE	.doadd			;if no carry, do the operation
	STC				;else, set the carry first
	.doadd:				;begin add block
	MOV	R9B,0x00		;clear C
	MOV byte [initflag],0x01	;set init to true (prevent further calls to init)
	.done:
	RET
add64:	;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;64-bit memory add
	CALL	addinit			;initialize
	PUSH	R1			;push old R1
	PUSH	R7			;push old R7
	MOV	R7,R11			;mov index
	MOV	R0,[R7]			;load the first 8 bytes
	MOV	R7,R12			;mov index
	MOV	R1,[R7]			;load second 8 bytes
	.adding:
	ADC	R0,R1			;do addition with carry
	JNC	.nocarry			;if !CF, don't set C
	MOV	R9B,0x01		;else C=1
	.nocarry:
	MOV	R7,R10			;mov index
	MOV	[R7],R0			;store result
	POP	R7			;restore R7
	POP	R1			;restore R1
	XOR	R0,R0			;set return=0 (success)
	RET				;return from sub
add128:	;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;128-bit memory add
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	add64			;add first 8 bytes (64 bits)
	ADD	R10,0x08		;offset by 8 on DST
	ADD	R11,0x08		;offset by 8 on SRC1
	ADD	R12,0x08		;offset by 8 on SRC2
	CALL	add64			;add second 8 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	XOR	R0,R0			;return=success
	RET
add256:	;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;256-bit memory add
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	add128			;add first 16 bytes (128 bits)
	ADD	R10,0x10		;offset by 16 on DST
	ADD	R11,0x10		;offset by 16 on SRC1
	ADD	R12,0x10		;offset by 16 on SRC2
	CALL	add128			;add second 16 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	XOR	R0,R0			;return=success
	RET
add1024:;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;1024-bit memory add
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	add256			;add first 32 bytes (256 bits)
	ADD	R10,0x20		;offset by 32 on DST
	ADD	R11,0x20		;offset by 32 on SRC1
	ADD	R12,0x20		;offset by 32 on SRC2
	CALL	add256			;add second 32 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	XOR	R0,R0			;return=success
	RET
add2048:;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;2048-bit memory add
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	add1024		;add first 64 bytes (1024 bits)
	ADD	R10,0x40		;offset by 64 on DST
	ADD	R11,0x40		;offset by 64 on SRC1
	ADD	R12,0x40		;offset by 64 on SRC2
	CALL	add1024		;add second 64 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	XOR	R0,R0			;return=success
	RET
add4096:;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;4096-bit memory add
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	add2048		;add first 128 bytes (2048 bits)
	ADD	R10,0x80		;offset by 128 on DST
	ADD	R11,0x80		;offset by 128 on SRC1
	ADD	R12,0x80		;offset by 128 on SRC2
	CALL	add2048		;add second 128 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	XOR	R0,R0			;return=success
	RET
add8192:;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;8192-bit memory add
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	add4096		;add first 256 bytes (4096 bits)
	ADD	R10,0x100		;offset by 256 on DST
	ADD	R11,0x100		;offset by 256 on SRC1
	ADD	R12,0x100		;offset by 256 on SRC2
	CALL	add4096		;add second 256 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	XOR	R0,R0			;return=success
	RET
wrapper:;C wrapper for calling add functions
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
	MOV BYTE [initflag], 0x00	;set the init flag (THIS HAS TO HAPPEN)
	CALL	R0			;call the function
	MOV	R0, R9			;move C into R0
	POP	R12
	POP	R11
	POP	R10
	POP	R9
	RET
