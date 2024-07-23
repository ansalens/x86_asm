#include <stdio.h>
#include <inttypes.h>

uint32_t asm_func(); /* make function prototype for our assembly function */
void print_binary(uint32_t);

int main() {
  /* Note that we store result as UNSIGNED integer */
  uint32_t result = asm_func();

  // printf("SGN: %" PRId32 "\n", (uint32_t) result);
  printf("DEC: %" PRIu32 "\n", result);
  printf("HEX: %" PRIx32 "\n", result);
  printf("BIN: ");
  print_binary(result);

  return 0;
}


void print_binary(uint32_t number) {
  char str[32];

  for (int i = 31; i >= 0; i--) {
    if (number & 1 == 1)
      str[i] = '1';
    else
      str[i] = '0';
    number = number >> 1;
  }

  for (int i = 0; i < 32; i++) {
    printf("%c", str[i]);

    if (i % 8 == 7)
      printf(" ");
  }
  printf("\n");
}
