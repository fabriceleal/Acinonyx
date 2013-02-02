#include <stdlib.h>
#include <string.h>
#include "common.h"

list_item_Card* new_itemCard(char c[2]) {
	list_item_Card* ret = malloc(sizeof(ret));
	ret->card.rank = c[0];
	ret->card.suit = c[1];
	ret->next = NULL;
	return ret;
}

void append_itemCard(list_item_Card* new_head, list_item_Card* tail) {
	new_head->next = tail;
}
