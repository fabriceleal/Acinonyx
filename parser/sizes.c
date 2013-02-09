/*
	Prints the sizes of datatypes used in serialization
*/

#include <stdio.h>
#include "common.h"

#define P_SIZEOF(x)															\
	printf("sizeof(%s): %d\n", #x, sizeof(x))


int main(int argc, char** argv) {
	printf("This is only an auxilary tool. Nothing fancy\n");
	
	P_SIZEOF(int);
	P_SIZEOF(char);
	P_SIZEOF(float);
	P_SIZEOF(Card);
	P_SIZEOF(ActionType);

	return 0;
}
