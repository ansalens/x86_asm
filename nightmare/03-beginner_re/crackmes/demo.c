#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
    char *str;
    str = argv[1];
    // printf("%d\n", strnlen(str, 1000));
    printf("%c\n", str + 4);

    return 0;
}
