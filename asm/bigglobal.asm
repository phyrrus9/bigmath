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
global bigtostr			;System-V ABI c-string conversion
global _arithinit		;arithmatic init flag
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;enable these for debugging;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
global stk_setup
global stk_destroy
global bigtostr_op
global bmemcp
global bmemzr
global bhxadd
global bhxdv
global bstrcmp
global bstrcpy
global bstrwrk
