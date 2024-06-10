#include <stdio.h>
#include <signal.h>

int main(void) {
	kill(25808, 15);
	return 0;
}
