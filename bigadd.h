/* definitions for bigadd.asm wrapped in C */

int wrapper(void *fnc, void *dst, void *src1, void *src2, int c);

/* DO NOT CALL ANY OF THESE! */
void add64(void);
void add128(void);
void add256(void);
void add512(void);
void add1024(void);
void add2048(void);
void add4096(void);
void add8192(void);
