#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]){
    int s_neg = 0x80000000;
    int l_neg = 0xffffffff;

    printf("largest negative = %d  (0x%08x)\n", l_neg, l_neg);
    printf("largest negative-1 = %d  (0x%08x)\n", l_neg-1, l_neg-1);
    printf("largest negative-2 = %d  (0x%08x)\n", l_neg-2, l_neg-2);
    printf("\n");

    printf("smallest negative+3 = %d (0x%08x)\n", s_neg+3, s_neg+3);
    printf("smallest negative+2 = %d (0x%08x)\n", s_neg+2, s_neg+2);
    printf("smallest negative+1 = %d (0x%08x)\n", s_neg+1, s_neg+1);
    printf("smallest negative = %d (0x%08x)\n", s_neg, s_neg);


    return 0;
}
