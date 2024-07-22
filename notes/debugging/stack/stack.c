#include <stdio.h>
#include <stdlib.h>

int main(void) {
    char stackstring[10] = "hello";
    char *heapstring;
    int x = 1337;

    heapstring = malloc(50);

    printf("Enter stack string: ");
    gets(stackstring);
    printf("Enter malloc string: ");
    gets(heapstring);
    printf("Stack string is %s\n", stackstring);
    printf("Heap string is %s\n", heapstring);
    printf("x is %d\n", x);

    return 0;
}
