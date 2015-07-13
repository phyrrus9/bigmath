;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;This file is meant to be assembled as part of ;
;bigadd.asm to form bigarithmatic.o            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Text section                                  ;
;Where all of the library code lives           ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
section .text
global sub64
global sub128
global sub256
global sub1024
global sub2048
global sub8192
sub64:	;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;64-bit memory sub
	CALL	addinit			;initialize
	PUSH	R1			;push old R1
	PUSH	R7			;push old R7
	MOV	R7,R11			;mov index
	MOV	R0,[R7]			;load the first 8 bytes
	MOV	R7,R12			;mov index
	MOV	R1,[R7]			;load second 8 bytes
	SBB	R0,R1			;do addition with carry
	JNC	.nocarry			;if !CF, don't set C
	MOV	R9B,0x01		;else C=1
	.nocarry:
	MOV	R7,R10			;mov index
	MOV	[R7],R0			;store result
	POP	R7			;restore R7
	POP	R1			;restore R1
	RET				;return from sub
sub128:	;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;128-bit memory sub
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	sub64			;add first 8 bytes (64 bits)
	ADD	R10,0x08		;offset by 8 on DST
	ADD	R11,0x08		;offset by 8 on SRC1
	ADD	R12,0x08		;offset by 8 on SRC2
	CALL	sub64			;sub second 8 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	RET
sub256:	;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;256-bit memory sub
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	sub128			;sub first 16 bytes (128 bits)
	ADD	R10,0x10		;offset by 16 on DST
	ADD	R11,0x10		;offset by 16 on SRC1
	ADD	R12,0x10		;offset by 16 on SRC2
	CALL	sub128			;sub second 16 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	RET
sub1024:;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;1024-bit memory sub
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	sub256			;sub first 32 bytes (256 bits)
	ADD	R10,0x20		;offset by 32 on DST
	ADD	R11,0x20		;offset by 32 on SRC1
	ADD	R12,0x20		;offset by 32 on SRC2
	CALL	sub256			;sub second 32 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	RET
sub2048:;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;2048-bit memory sub
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	sub1024			;sub first 64 bytes (1024 bits)
	ADD	R10,0x40		;offset by 64 on DST
	ADD	R11,0x40		;offset by 64 on SRC1
	ADD	R12,0x40		;offset by 64 on SRC2
	CALL	sub1024			;sub second 64 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	RET
sub4096:;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;4096-bit memory sub
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	sub2048			;sub first 128 bytes (2048 bits)
	ADD	R10,0x80		;offset by 128 on DST
	ADD	R11,0x80		;offset by 128 on SRC1
	ADD	R12,0x80		;offset by 128 on SRC2
	CALL	sub2048			;sub second 128 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	RET
sub8192:;DST=[R10] SRC1=[R11] SRC2=[R12] C=R9B
	;8192-bit memory sub
	CALL	addinit			;initialize
	PUSH	R10			;save old R10
	PUSH	R11			;save old R11
	PUSH	R12			;save old R12
	CALL	sub4096			;sub first 256 bytes (4096 bits)
	ADD	R10,0x100		;offset by 256 on DST
	ADD	R11,0x100		;offset by 256 on SRC1
	ADD	R12,0x100		;offset by 256 on SRC2
	CALL	sub4096			;sub second 256 bytes (with carry)
	POP	R12			;restore R12
	POP	R11			;restore R11
	POP	R10			;restore R10
	RET
