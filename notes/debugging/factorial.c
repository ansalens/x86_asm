#include <stdio.h>
#include <stdlib.h>

long long factorial(int n) {
    long long f = 1;
    int i = 1;

    while (i <= n) {
        f = f * i;
        i++;
    }

    return f;
}

int main(void) {
    int n = 17;
    long long f = factorial(n);
    printf("The factorial of %d is %lld\n", n, f);
}
