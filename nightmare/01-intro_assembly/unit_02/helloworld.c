#include <stdio.h>

void printhello() {
    char hello[15] = "Hello, World!\n";
    char *p;
    
    for (p = hello; *p; p++)
        putchar(*p);
}

int main() {
    printhello();
    return 0;
}
