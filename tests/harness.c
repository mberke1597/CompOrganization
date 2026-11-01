#include <stdio.h>

#define main program_main
#include "../src/main.c"
#undef main

int main(void)
{
    program_main();
    for (int i = 0; i < N; i++)
        printf("%d ", data[i]);
    printf("\nmedian = %d\nmin_v = %d\nmax_v = %d\nswaps = %d\n", median, min_v, max_v, swaps);
    return 0;
}
