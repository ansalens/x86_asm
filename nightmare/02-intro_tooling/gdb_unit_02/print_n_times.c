#include <stdio.h>

void print_n_times(char * str, int n){
  int i;

  for( i=0 ; i < n ; i++){
    printf("%s",str);
  }

}

int main(){

  int n;

  n = 5;

  print_n_times("Pussy, money, weed!\n",n);

  return 0;
}
