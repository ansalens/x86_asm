#include <stdio.h>
#include <stdint.h>

int main(void) {
    uint8_t integer0, integer1;
    integer0 = 255;
    integer1 = 45;

    uint16_t sum = (uint16_t)integer0 + (uint16_t)integer1;
    uint8_t result = (uint8_t)sum;
    uint8_t carry = (sum >> 8) & 1;

    printf("%u\n", sum);
    printf("%u\n", result);


    if (carry)
        puts("CF is set, execute this block");
    else 
        puts("CF not set, execute this block");
    

    return 0;
}
