section .text
;convert a bignum object to a C-string
extern bigcmp
alloc_setup:
	POP	R0		;save return addr
	PUSH	RBP		;preserve anything
	PUSH	R0		;replace return addr
	MOV	RBP,azone	;copy the alloc zone in
	RET
alloc_destroy:
	POP	R0
	POP	RBP
	PUSH	R0
	RET
bigtostr:;(Follows System-V ABI)
	;DST=R7
	;SRC=R6
	;SIZE=R2
	CMP	R2,0x8
	JE	.big64
	CMP	R2,0x10
	JE	.big128
	CMP	R2,0x20
	JE	.big256
	CMP	R2,0x40
	JE	.big512
	CMP	R2,0x80
	JE	.big1024
	CMP	R2,0x100
	JE	.big2048
	CMP	R2,0x200
	JE	.big4096
	CMP	R2,0x400
	JE	.big8192
	MOV	R0,0x1	;error
	RET
	;set the subtract pointer in R10
	.big64:
		MOV	R10,sub64
		JMP	.operate
	.big128:
		MOV	R10,sub128
		JMP	.operate
	.big256:
		MOV	R10,sub256
		JMP	.operate
	.big512:
		MOV	R10,sub512
		JMP	.operate
	.big1024:
		MOV	R10,sub1024
		JMP	.operate
	.big2048:
		MOV	R10,sub2048
		JMP	.operate
	.big4096:
		MOV	R10,sub4096
		JMP	.operate
	.big8192:
		MOV	R10,sub8192
	.operate:
		CALL	alloc_setup
		CALL	bigtostr_op
		CALL	alloc_destroy
	XOR	R0,R0				;status=0
	RET
bigtostr_op:;PART OF bigtostr! DO NOT CALL EXPLICITLY!
	;allocate stack space for input (copy)
	MOV	R11,RBP				;R11 is our copy
	SUB	RBP,R2				;malloc(SIZE)
	;copy data to variable
	CALL	bmemcp
	;save important fields
	PUSH	R11
	PUSH	R7
	CALL	bstrwrk				;call the worker function (with our parameters)
	;restore important fields
	POP	R7
	POP	R11
	;de-allocate
	ADD	RBP,R11				;de-allocate copy
	RET
bmemcp:	;DO NOT CALL OUTSIDE OF bigtostr!
	;DST=R11
	;SRC=R6
	;SIZE=R2
	PUSH	R11
	PUSH	R10
	PUSH	R9
	PUSH	R7
	PUSH	R6
	PUSH	R2
	MOV	R10,0x0
	MOV	R7,R11
	.memcpy_top:
		MOV	QWORD	R9,[R6]			;copy 64 bits into R9 (tmp)
		MOV	QWORD	[R7],R9			;copy 64 bits from R9 to copy
		ADD	R10,0x8				;add 8 to counter (8 bytes per block)
		ADD	R6,0x8				;add 8 to input
		ADD	R7,0x8				;add 8 to output
		CMP	R10,R2				;compare counter to size
		JB	.memcpy_top			;continue loop if we haven't got all blocks
	POP	R2
	POP	R6
	POP	R7
	POP	R9
	POP	R10
	POP	R11
	RET
bmemzr:	;DO NOT CALL OUTSIDE! -- runs in 8-byte chunks
	;DST=R7
	;SIZE=R2
	PUSH	R10
	PUSH	R7
	MOV	R10,0x0
	;MOV	R7,R11 ;;;;;wtf is this doing here?
	.memcpy_top:
		MOV	QWORD	[R7],0x0		;copy 64 zero bits to dst
		ADD	R10,0x8				;add 8 to counter (8 bytes per block)
		ADD	R7,0x8				;add 8 to output
		CMP	R10,R2				;compare counter to size
		JB	.memcpy_top			;continue loop if we haven't got all blocks
	POP	R7
	POP	R10
	RET
bhxadd:	;DO NOT CALL OUTSIDE OF bhxdv!
	CMP	R2,0x8
	JE	.big64
	CMP	R2,0x10
	JE	.big128
	CMP	R2,0x20
	JE	.big256
	CMP	R2,0x40
	JE	.big512
	CMP	R2,0x80
	JE	.big1024
	CMP	R2,0x100
	JE	.big2048
	CMP	R2,0x200
	JE	.big4096
	JMP	.big8192
	;set the subtract pointer in R10
	.big64:
		MOV	R10,add64
		RET
	.big128:
		MOV	R10,add128
		RET
	.big256:
		MOV	R10,add256
		RET
	.big512:
		MOV	R10,add512
		RET
	.big1024:
		MOV	R10,add1024
		RET
	.big2048:
		MOV	R10,add2048
		RET
	.big4096:
		MOV	R10,add4096
		RET
	.big8192:
		MOV	R10,add8192
		RET
bhxdv:	;DO NOT CALL OUTSIDE OF bigtostr!
	;NUM=R11
	;DIVBUF=bdvbf
	;MODBUF=NUM (NUM is modified!)
	;SIZE=R2
	PUSH	R9
	PUSH	R11
	PUSH	R12
	.init:
		PUSH	R2
		MOV	R7,bdvbf			;R7(index)=DIVBUF
		;MOV	R6,R13				;R6(index)=MODBUF
		PUSH	R10
		CALL	bhxadd				;set add function
		MOV	R9,R10
		POP	R10
		POP	R2
		.bhxbs:				;alloc bhxbs and set to 16
			PUSH	R7
			MOV	R7,RBP				;save ptr
			SUB	RBP,R2				;alloc R2 bytes
			PUSH	R2
			PUSH	R7
			CALL	bmemzr
			POP	R7
			MOV	BYTE	[R7],0x0A		;set *ptr=10
			POP	R2
			PUSH	R6
			MOV	R6,bhxbs
			MOV	QWORD	[R6],R7
			POP	R6
			POP	R7
		.btmp:				;alloc btmp and set to 0
			PUSH	R7
			PUSH	R6
			PUSH	R2
			MOV	R7,RBP				;save ptr
			MOV	R6,btmp
			MOV	QWORD	[R6],R7			;write ptr
			SUB	RBP,R2				;alloc R2 bytes
			CALL	bmemzr
			POP	R2
			POP	R6
			POP	R7
		.bdvbf:
			PUSH	R7
			PUSH	R2
			MOV	R7,bdvbf
			CALL	bmemzr
			POP	R2
			POP	R7
	.ltop:
		;if (bigcmp(R11,bhxbs,R2) != -1)
		PUSH	R6
		PUSH	R7
		PUSH	R2
		MOV	R7,R11				;copy SRC1
		MOV	R6,[bhxbs]			;copy SRC2
		CALL	bigcmp
		POP	R2
		POP	R7
		POP	R6
		CMP	R0,-1
		JE	.ldone
		;bigarithmatic(R10,R11,R11,bhxbs,R2)
		PUSH	R2
		PUSH	R6
		PUSH	R7
		PUSH	R8
		PUSH	R9
		MOV	R7,R10				;copy fnc
		MOV	R6,R11				;copy dst
		MOV	R8,R2				;copy SIZE (out of order)
		MOV	R2,R11				;copy src1
		MOV	R9,[bhxbs]			;copy src2
		CALL	bigarithmatic			;do math!
		POP	R9
		POP	R8
		POP	R7
		POP	R6
		POP	R2
		;bigarithmatic(R8,bdvbf,bdvbf,btmp,R2)
		PUSH	R2
		PUSH	R6
		PUSH	R7
		PUSH	R8
		PUSH	R9
		MOV	R7,R9				;copy fnc
		MOV	R6,bdvbf			;copy dst
		MOV	R8,R2				;copy SIZE (out of order)
		MOV	R2,bdvbf			;copy src1
		MOV	R9,[btmp]			;copy src2
		CALL	bigarithmatic			;do math!
		POP	R9
		POP	R8
		POP	R7
		POP	R6
		POP	R2
		JMP	.ltop
	.ldone:
		.dealloc_btmp:
			ADD	RBP,R2
		.dealloc_bhxbs:
			ADD	RBP,R2
	POP	R12
	POP	R11
	POP	R9
	RET
bstrcmp:;wrapper around bigcmp for bstrwrk ONLY!
	;SRCOBJ=R11
	;[OUT]R0=[0x0: lt, 0x1: eq, 0x2: gt, 0x3: invalid]
	PUSH	R11				;ensure we preserve pointer
	PUSH	R2
	PUSH	R6
	PUSH	R7
	MOV	R0,0x3				;take care of default case
	;R6=SRC1,R7=SRC2,R2=SIZE
	.alloc:
		MOV	R7,RBP			;save ptr
		SUB	RBP,R2
		CALL	bmemzr			;zero it
		MOV	BYTE	[R7],0x1	;set tmp to 1
	MOV	R6,R11				;copy SRC1
	CALL	bigcmp				;compare them
	.dealloc:
		ADD	RBP,R2
	POP	R7
	POP	R6
	POP	R2
	POP	R11
	CMP	R0,0
	JB	.ret
	JE	.eq
	MOV	R0,0x2
	JMP	.ret
	.eq:
		MOV	R0,0x1
		JMP	.ret
	.ret:
		RET
bstrcpy:;wrapper around memcp for bstrwrk ONLY!
	;SRC=R11
	;SIZE=R2
	;DST=wrkbf (already allocated)
	PUSH	R11
	PUSH	R6
	PUSH	R2
	MOV	R6,R11				;copy SRC
	MOV	R11,wrkbf			;copy DEST
	CALL	bmemcp				;copy object to dest
	POP	R2
	POP	R6
	POP	R11
	RET
bstrwrk:;wrapper around all the base conversion functions
	;SRCOBJ=R11
	;DSTSTR=R7
	;SIZE=R2
	.init:
		.wrktmp:
			PUSH	R15			;R15=loop counter
			MOV	R15,0x0			;set loop counter to 0
		.algo:
			PUSH	R11			;save src ptr
			CALL	bstrcpy			;copy original data
			MOV	R11,wrkbf		;swap pointers
	.ltop:
		CALL	bstrcmp				;compare SRCOBJ and 1
		CMP	R0,0x0				;SRCOBJ is less than 1
		JE	.ldone
		CALL	bhxdv				;divide
		PUSH	WORD	[wrkbf]			;push 16 bytes to the stack
		INC	R15				;add 1 to loop counter
		PUSH	R11				;DST
		PUSH	R6				;SRC
		PUSH	R2				;SIZE
		MOV	R6,bdvbf			;copy SRC
		CALL	bmemcp				;copy object
		POP	R2
		POP	R6
		POP	R11
		JMP	.ltop				;repeat loop
	.ldone:
	.init_conv:
		PUSH	R7				;save DST
		PUSH	R0				;for AL/X
		PUSH	R14				;R14=conv loop counter
		MOV	R14,0x0				;zero the count
	.convltop:
		CMP	R14,R15
		JNB	.convdone			;while (R14 < R15)
		POP	AX				;copy 16 bits
		ADD	AX,0x30				;convert to ASCII
		MOV	BYTE	[R7],AL			;copy ASCII character to output
		INC	R7				;++dst
		INC	R14				;++lc
		JMP	.convltop
	.convdone:
		POP	R14
		POP	R0				;for AL/X
		MOV	BYTE	[R7],0x0		;terminate C-string
		POP	R7				;restore original DST
	POP	R11					;restore SRC object
	RET
section .text ;testing
;bhxdv:
	;NUM=R11
        ;DIVBUF=bdvbf
        ;MODBUF=NUM (NUM is modified!)
	;SIZE=R2
testdiv:
	CALL	alloc_setup
	MOV	R11,bdvbf
	MOV	R2,0x8
	CALL	bhxdv
	CALL	alloc_destroy
	RET
section .bss
bhxbs:	resb	8					;define pointer to bignum (hex base)
btmp:	resb	8					;define pointer to bignum (tmp var)
bdvbf:	resb	1024					;define 8192-bit bignum (div buffer)
wrkbf:	resb	1024					;define 8192-bit bignum(bstrwrk:BUF)
section .bss
abnd:	resb	1024
	resb	1024
	resb	1024
	resb	1024
	resb	1024
	resb	1024
	resb	1024
	resb	1024
	resb	1024
	resb	1024
azone:
