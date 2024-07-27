#include <stdio.h>

int main(int argc, char *argv[]){
    int a[] = {11,12,13,14,15};
    short b[] = {11,12,13,14,15};
    char c[] = {11,12,13,14,15};

    for (int i = 0; i < 5; i++){
        printf("a+%d=%p, *(a+%d) = %d\n", i, a+i, i, a[i]);
    }

    printf("\n");

    for (int i = 0; i < 5; i++){
        printf("b+%d = %p, *(b+%d) = %d\n", i, b+i, i, b[i]);
    }

    printf("\n");

    for (int i = 0; i < 5; i++) {
        printf("c+%d=%p, (c+%d) = %d\n", i, c+i, i, c[i]);
    }

    return 0;
}
