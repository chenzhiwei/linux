#include <stdio.h>

int add(int m, int n)
{
    return m + n;
}

int square(int n)
{
    return n * n;
}

void message(char *str, int n)
{
    printf("MSG: %s\tINT: %d\n", str, n);
}
