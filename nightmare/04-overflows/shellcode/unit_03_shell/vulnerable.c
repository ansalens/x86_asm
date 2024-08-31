#include <stdio.h>
#include <string.h>
#include <stdlib.h>

void bad(){
  printf("You've been naughty!\n");
}

void good(){
  printf("The world is yours.\n");
}

void vuln(int n, char * str){
  int i = 0;  
  char buf[32];

  strcpy(buf,str);

  while( i < n ){
    printf("%d %s\n",i++, buf);
  }

}

int main(int argc, char *argv[]){
  vuln(atoi(argv[1]), argv[2]);

  return 0;
}
