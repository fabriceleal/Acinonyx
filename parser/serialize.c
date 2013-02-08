#include "serialize.h"
#include <stdio.h>
#include <stdlib.h>



void debug_print(char* title, Hand* hand) {

}

void serialize(Hand* hand) {
	FILE* f = fopen("test.tpl", "w");

	// id
	fwrite(&hand->id, sizeof(int), 1, f);

	// blinds
	fwrite(&hand->blinds.small, sizeof(float), 1, f);
	fwrite(&hand->blinds.big, sizeof(float), 1, f);

	// rounds
	// * preflop
	fwrite(&hand->r_0.actions.size, sizeof(char), 1, f);
	fwrite(&hand->r_0.actions.ptr, sizeof(Action), hand->r_0.actions.size, f);

	// * flop
	fwrite(&hand->r_1.actions.size, sizeof(char), 1, f);
	fwrite(&hand->r_1.actions.ptr, sizeof(Action), hand->r_1.actions.size, f);

	// * turn
	fwrite(&hand->r_2.actions.size, sizeof(char), 1, f);
	fwrite(&hand->r_2.actions.ptr, sizeof(Action), hand->r_2.actions.size, f);

	// * river
	fwrite(&hand->r_3.actions.size, sizeof(char), 1, f);
	fwrite(&hand->r_3.actions.ptr, sizeof(Action), hand->r_3.actions.size, f);

	// players

	fclose(f);
}

Hand* deserialize() {
	
}

void do_serialize_test(Hand* hand) {
	//	return;
	debug_print("BEFORE", hand);
	serialize(hand);
	Hand* test = deserialize();
	debug_print("AFTER", test);
	free(test);
}
