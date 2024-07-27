#include <stdio.h>

int main(int argc, char *argv[]){
    int a = 10;
    int b = 20;
    int *p = &a;

    *p = b;

    p = &b;
    b = 30;

    printf("a = %d, &a = %p\n", a, &a);
    printf("b = %d, &b = %p\n", b, &b);
    printf("p = %p, &p = %p, *p = %d\n", p, &p, *p);

    return 0;
}
