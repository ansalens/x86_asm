#include <stdio.h>

void hello(void);
void world(void);

void hello(void) {
    printf("Hello");
}

int main(int argc, char *argv[]) {
    hello();
    world();
}
