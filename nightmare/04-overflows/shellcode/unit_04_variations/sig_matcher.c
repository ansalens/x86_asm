#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[]){
    if (argc < 2) {
        printf("Supply one more argument atleast\n");
        exit(1);
    }

    char *p;
    for (p = argv[1]; *p; p++) {
        if (strncmp(p, "sh", 2) == 0) {
            printf("Nope!\n");
            exit(2);
        }
    }

    ((void(*)(void)) argv[1])();
    return 0;
}
