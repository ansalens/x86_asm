#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]) {
    char c = 0xba;
    short s = 0xbabe;
    int i = 0xcafebabe;
    long l = 0xdeadbeef;
    long long ll = 0xc0ffeebabe;

    printf("char c = %d, size = %u\n", c, sizeof(c));
    printf("short s = %d, size = %u\n", s, sizeof(s));
    printf("int i = %d, size = %u\n", i, sizeof(i));
    printf("long l = %d, size = %u\n", l, sizeof(l));
    printf("long long ll = %d, size = %u\n", ll, sizeof(ll));

    return 0;
}
