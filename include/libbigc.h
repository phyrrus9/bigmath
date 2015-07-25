#include "bigarithmatic.h"

typedef void (*libbig_fnc)(void);
#define BIG64	0
#define BIG128	1
#define BIG256	2
#define BIG512	3
#define BIG1024	4
#define BIG2048	5
#define BIG8192	6
typedef unsigned char bigintsize;
struct biginteger
{
	bigintsize size;
	void *data;
};
const static libbig_fnc bigadd[] = { &add64, &add128, &add256, &add512, &add1024, &add2048, &add4096, &add8192 };
const static libbig_fnc bigsub[] = { &sub64, &sub128, &sub256, &sub512, &sub1024, &sub2048, &sub4096, &sub8192 };
