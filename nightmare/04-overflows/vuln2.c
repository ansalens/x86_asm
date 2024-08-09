#include <stdio.h>
#include <string.h>

int vulnfunction(char* argument) {
    char buffer[500];
    strcpy(buffer, argument);

    return 0;
}

int main(int argc, char **argv) {
    vulnfunction(argv[1]);
    return 0;
}
