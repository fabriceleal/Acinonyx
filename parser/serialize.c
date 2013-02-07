#include "serialize.h"
#include <stdio.h>
#include <stdlib.h>
#include <tpl.h>

#define TPL_FORMAT "S(i$(ff))"

void debug_print(char* title, Hand* hand) {
	printf("%s\n", title);
	printf(" id: %d\n", hand->id);
	printf(" small: %f\n", hand->blinds.small);
	printf(" big: %f\n", hand->blinds.big);
}

void serialize(Hand* hand) {
	debug_print("BEFORE", hand);

	tpl_node *tn;
	tn = tpl_map(TPL_FORMAT, hand);
	tpl_pack(tn, 0);
	tpl_dump(tn, TPL_FILE, "tmp.tpl");
	tpl_free(tn);
}

void deserialize() {
	Hand* hand = malloc(sizeof(Hand));
	tpl_node *tn;
	tn = tpl_map(TPL_FORMAT, hand);
	tpl_load(tn, TPL_FILE, "tmp.tpl");
	tpl_unpack(tn, 0);
	tpl_free(tn);

	debug_print("AFTER", hand);
}

void do_serialize_test(Hand* hand) {
	return;

	serialize(hand);
	deserialize();
}
