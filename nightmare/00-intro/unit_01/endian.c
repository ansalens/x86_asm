#include <stdio.h>

int main(int argc, char *argv[]){
    int a = 0xdeadbeef;

    char *p = (char *) &a;      /* cast variable a into char array */

    for (int i = 0; i < 4; i++) {
        /* take each byte from that array and print it */
        printf("p[%d] = 0x%hhx\n", i, p[i]);
    }

    return 0;
}
