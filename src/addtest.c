#include "../include/libbig.h"
#include <stdio.h>
#include <stdint.h>
#include <limits.h>

uint64_t mul(uint64_t a, uint64_t b)
{
	uint64_t dst = 0;
	uint64_t i;
	int c = 0;
	for (i = 0; i < b; i++)
		c = bigarithmatic(&add64, &dst, &dst, &a, c);
	return dst;
}

int main()
{
	uint64_t dst, a = 5, b = 3;
	int cmp;
	printf("=====mul/cmp test=======\n");
	cmp = bigcmp(&a,&b,8);
	printf("%lu <=> %lu : %d\n", a, b, cmp);
	dst = mul(a, b);
	printf("%lu * %lu = %lu\n", a, b, dst);
	cmp = bigcmp(&a,&dst,8);
	printf("%lu <=> %lu : %d\n", a, dst, cmp);
	a = b = 1;
	printf("1 <=> 1 : %d\n", bigcmp(&a, &b, 8));
	printf("=========sub test=======\n");
	bigarithmatic(&sub64, &dst, &a, &b, 0);
	printf("%lu - %lu = %lu\n", a, b, dst);
}
