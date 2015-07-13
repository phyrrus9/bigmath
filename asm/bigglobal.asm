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
global bigarithmatic		;C wrapper for arithmatic functions
global bigcmp			;System-V ABI compare function
global _arithinit		;arithmatic init flag
