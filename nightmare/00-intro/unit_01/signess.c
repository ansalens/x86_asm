#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[]){
    /* largest positive signed integer */
    int l_pos = 0x7fffffff;
    /* smallest positive signed integer */
    int s_pos = 0x00000000;
    /* smallest negative signed integer 
     * binary: 1000 0000 0000 0000 0000 0000 0000 0000 */
    int s_neg = 0x80000000;
    /* largest negative signed integer */
    int l_neg = 0xffffffff;

    printf("largest positive = %d \t (0x%08x)\n", l_pos, l_pos);
    printf("smallest positive = %d \t\t (0x%08x)\n", s_pos, s_pos);
    printf("\n");

    printf("largest negative = %d \t\t (0x%08x)\n", l_neg, l_neg);
    printf("smallest negative = %d \t (0x%08x)\n", s_neg, s_neg);
    printf("\n");

    return 0;
}
