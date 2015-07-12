#include "bigadd.h"
#include <stdio.h>
#include <stdint.h>
#include <limits.h>

uint64_t mul(uint64_t a, uint64_t b)
{
	uint64_t dst = 0;
	uint64_t i;
	int c = 0;
	for (i = 0; i < b; i++)
		c = wrapper(&add64, &dst, &dst, &a, c);
	return dst;
}

int main()
{
	uint64_t dst, a = 5, b = 3;
	dst = mul(a, b);
	printf("%lu * %lu = %lu\n", a, b, dst);
	;;
	;;
}
