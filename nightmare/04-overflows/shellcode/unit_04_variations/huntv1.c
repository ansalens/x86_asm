#include <stdio.h>
#include <unistd.h>
#include <errno.h>

int main(int argc, char *argv[]) {
    /* start at 0x00 and look for an egg */
    unsigned int p = 0x00000000;
    unsigned int egg = 0x90509050;

    while (1) {
        access((char *) p+4, 0);

        if (errno != EFAULT) {
            unsigned int *q = (unsigned int *) p;
            if (q[0] == egg && q[1] == egg) {
                ((void(*)(void)) q)();
                break;
            }

            p++;
        } else {
            p |= 0xfff;     /* 1 out last 12 bits, in other words 4096 */
            p++;
        }
    }

    return 0;
}
