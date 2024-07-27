#include <stdio.h>

int main(int argc, char *argv[]) {
    char str[] = "The world is yours.\n";

    char *p;

    for ( p = str; *p; p++) {
        putchar(*p);
    }

    return 0;
}
