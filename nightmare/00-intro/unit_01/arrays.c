#include <stdio.h>

int main(int argc, char *argv[]){
    int array[] = {10,11,12,13,14};

    int *p = array;     /* no need for &, they are both memory references */

    p[4] = 1337;

    printf("array = %p, p = %p\n", array, p);

    for (int i = 0; i < 5; i++) {
        printf("array[%d] = %d\n", i, array[i]);
    }

    return 0;
}
