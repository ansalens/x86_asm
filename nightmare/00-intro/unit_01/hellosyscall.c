#include <unistd.h>

int strlen(char *str) {
    int i;

    for (i=0; str[i]; i++);

    return i;
}

int main(int argc, char *argv[]) {
    char str[] = "Hello world!\n";

    write(1, str, strlen(str));
}
