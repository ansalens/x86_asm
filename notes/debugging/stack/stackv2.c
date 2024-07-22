#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct Data {
    char stackstring[10];
    int x;
    char *heapstring;
};

int main(void) {
    struct Data data;
    data.x = 100;
    strncpy(data.stackstring, "pumpkin", sizeof(data.stackstring) - 1);
    data.stackstring[sizeof(data.stackstring) - 1] = '\0';

    printf("Address of stackstring: %p\n", (void*)data.stackstring);
    printf("Address of x: %p\n", (void*)&data.x);
    printf("Address of heapstring: %p\n", (void*)&data.heapstring);

    printf("Enter stack string: ");
    gets(data.stackstring);  // Dangerous: No bounds checking

    data.heapstring = malloc(50);

    printf("Enter heap string: ");
    gets(data.heapstring);  // Dangerous: No bounds checking

    printf("String on stack is %s\n", data.stackstring);
    printf("String on heap is %s\n", data.heapstring);
    printf("x is %d\n", data.x);

    return 0;
}
