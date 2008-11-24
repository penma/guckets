/*

Guckets Solver
Made 2008 by Lars Stoltenow <penma@penma.de>
License: WTFPL <http://sam.zoy.org/wtfpl>

Recommended FLAGS: -O3 -std=c99 -Wall -Wextra -lm

For usage on one processor (core):
    gcc $FLAGS -o solve solve.c
For usage on two cores:
    gcc $FLAGS -DPARALLEL -DPARALLEL_MASK=0x01 -DPARALLEL_VALUE=0 -o solve_a solve.c
    gcc $FLAGS -DPARALLEL -DPARALLEL_MASK=0x01 -DPARALLEL_VALUE=1 -o solve_b solve.c
For usage on four cores:
    gcc $FLAGS -DPARALLEL -DPARALLEL_MASK=0x03 -DPARALLEL_VALUE=0 -o solve_a solve.c
    gcc $FLAGS -DPARALLEL -DPARALLEL_MASK=0x03 -DPARALLEL_VALUE=1 -o solve_b solve.c
    gcc $FLAGS -DPARALLEL -DPARALLEL_MASK=0x03 -DPARALLEL_VALUE=2 -o solve_c solve.c
    gcc $FLAGS -DPARALLEL -DPARALLEL_MASK=0x03 -DPARALLEL_VALUE=3 -o solve_d solve.c

Running:
    solve min_steps max_steps bucket-specifications...
Where each bucket-specification is:
    available_water maximum_water target_water
Set target_water to -1 in case the bucket is not relevant for solving.
The first specified bucket is the spare bucket; output of steps to the solution
is according to this.

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <math.h>

struct bucket
{
	int water;
	int maximum;
	int target;
};

#define MAXBUCKETS 20
#define MAXSTEPS 100
struct bucket ibuckets[MAXBUCKETS];
int nibuckets = 0;

struct step
{
	int from;
	int to;
};


int steps_min, steps_max;

uint64_t nprogress = 0;
static inline void progress()
{
	uint64_t maximum = pow(nibuckets * nibuckets, steps_max);
	
	if (!(nprogress % (1048576 * 4)))
	{
		fprintf(stderr, "%lld/%lld (%4.1f%%)\n",
			nprogress, maximum, (double) (nprogress * 100) / maximum);
	}
	nprogress++;
}

void pour(struct bucket *from, struct bucket *to)
{
	int sum = to->water + from->water;
	to->water = sum;
	from->water = sum - to->maximum;
	if (to->water > to->maximum) to->water = to->maximum;
	if (from->water < 0) from->water = 0;
}

int solver_check(int nsteps, struct step steps[MAXSTEPS])
{
	struct bucket *buckets;
	buckets = malloc(sizeof(ibuckets));
	memcpy(buckets, ibuckets, sizeof(ibuckets));
	
	progress();
	
	// Simulate
	for (int i = 0; i < nsteps; i++)
	{
		pour(buckets + steps[i].from, buckets + steps[i].to);
	}
	
	// Check goals
	for (int i = 0; i <= nibuckets; i++)
	{
		if ((buckets[i].water != buckets[i].target) && (buckets[i].target != -1))
		{
			free(buckets);
			return 0;
		}
	}
	
	// OMFG this matches
	free(buckets);
	return 1;
}

void dump_steps(int depth, struct step steps[MAXSTEPS])
{
	printf("Steps:");
	for (int i = 0; i < depth; i++)
	{
		// printf(" [%d] %d -> %d", i, steps[i].from, steps[i].to);
		if (steps[i].from == 0)     { printf(" fill %d;", steps[i].to); }
		else if (steps[i].to == 0)  { printf(" empty %d;", steps[i].from); }
		else                        { printf(" pour %d %d;", steps[i].from, steps[i].to); }
	}
	printf("\n");
}

void solver_step(int depth, struct step steps[MAXSTEPS])
{
	// Try what we have
	if (depth >= steps_min)
		if (solver_check(depth, steps))
		{
			dump_steps(depth, steps);
		}
	
	// Go on?
	if (depth == steps_max)
		return;
	
	// Try everything
	for (int from = 0; from < nibuckets; from++)
	{
#ifdef PARALLEL
		if (depth == 0 && (from & PARALLEL_MASK) != PARALLEL_VALUE)
			continue;
#endif
		for (int to = 0; to < nibuckets; to++)
		{
			if (from == to)
				continue;
			steps[depth].from = from;
			steps[depth].to = to;
			solver_step(depth + 1, steps);
		}
	}
}

int main(int argc, char *argv[])
{
	if (argc < 3)
	{
		printf("Usage: %s steps_min steps_max  water1 maximum1 target1  water2 maximum2 target2 ...\n", argv[0]);
		printf("watern = Available Water, maximumn = Bucket Size, targetn = goal or -1\n");
		printf("First specified bucket is the spare bucket\n");
		exit(1);
	}
	
	steps_min = atoi(argv[1]);
	steps_max = atoi(argv[2]);
	
	nibuckets = 0;
	while (argv[3 + nibuckets * 3] != NULL)
	{
		ibuckets[nibuckets].water = atoi(argv[3 + nibuckets * 3]);
		ibuckets[nibuckets].maximum = atoi(argv[3 + nibuckets * 3 + 1]);
		ibuckets[nibuckets].target = atoi(argv[3 + nibuckets * 3 + 2]);
		nibuckets++;
	}
	
	struct step steps[MAXSTEPS];
	
	solver_step(0, steps);
}
