#include <stdio.h>

int main(int argc, char *argv[]) {
    int array[] = {11,12,13,14,15};

    int *p = array;

    *(p+4) = 1337;

    printf("array = %p, p = %p\n", array, p);

    for (int i = 0; i < 5; i++){
        printf("array+%d=%p, *(array+%d) = %d\n", i, array+i, i, array[i]);
    }

    return 0;
}
