#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int matcher(char *string, char *sig1, char *sig2) {
    /* Returns:
     * 1: If signatures match
     * 0: If signatures don't match */
    char *p, *q;

    for (p = string; *p; p++) {
        if (strncmp(p, sig1, strlen(sig1)) == 0) {
            for (q = p; *q; q++) {
                if (strncmp(q, sig2, strlen(sig2)) == 0) {
                    return 1;
                }
            }
        }
    }

    return 0;
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Supply atleast one argument\n");
        exit(1);
    }
    /*                    mov al, 0xb int 0x80 */
    if (matcher(argv[1], "\xb0\x0b", "\xcd\x80") ||
            /*                xor ecx, ecx int 0x80 */
            matcher(argv[1], "\x31\xc9", "\xcd\x80")) {
        printf("NOPE!\n");
        exit(2);
    }

    ((void(*)(void)) argv[1])();

    return 0;
}
