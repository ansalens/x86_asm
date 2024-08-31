#include <string.h>

int main(int argc, char *argv[]){

  char code[1024];

  strncpy(code,argv[1],1024);

  //cast pointer to function pointer and call
  ((void(*)(void)) code)();
}
