#include <stdio.h>
#include <math.h>

int main(){

  char c;
  short s;
  int a,i;
  float f;
  double d;


  c = 'a';
  s = 0x1001;
  f = 3.1415926 ;
  d = exp(exp(1));

  for(i=0;i<10;i++){
    printf("i:%d c:%c s:%d f:%f d:%f\n",
    i,c,s,f,d);
  }

}
