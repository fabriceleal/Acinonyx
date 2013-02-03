#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "common.h"

list_itemCard* new_itemCard(const char c[2]) {
	list_itemCard *ret = malloc(sizeof(list_itemCard));
	ret->next = NULL;
	ret->value.rank = (char) c[0];
	ret->value.suit = (char) c[1];
	return ret;
}

void append_itemCard(list_itemCard* new_head, const list_itemCard* tail) {
	new_head->next = (list_itemCard*) tail;
}

list_itemPlayer* new_itemPlayer(const Player* player) {
	list_itemPlayer *ret = malloc(sizeof(list_itemPlayer));
	ret->next = NULL;
	ret->value = (Player*) player;
	return ret;
}

void append_itemPlayer(list_itemPlayer* new_head, const list_itemPlayer* tail) {
	new_head->next = (list_itemPlayer*) tail;
}

// print_*

void print_hand(const Hand *h) {
	int i;
	printf("HAND\n");
	printf("Id: %d\n", h->id);
	printf("Small: %.2f\n", h->blinds.small);
	printf("Big: %.2f\n", h->blinds.big);
	printf("Players: %d\n", h->players.size);
	for(i = 0; i < h->players.size; ++i) {
		print_player(h->players.ptr[i]);
	}
}

void print_player(const Player* p) {
	printf("Player %s (%.2f) %s\n", 
				 p->name, p->stack,
				 (p->button ? "(button)" : ""));
	print_pocket_hand(&p->card_0, &p->card_1);
}

void print_card(const Card* c) {
	printf("Card %c%c\n", c->rank, c->suit);
}

void print_pocket_hand(const Card* c1, const Card* c2) {
	printf("Pocket hand %c%c,%c%c\n", 
				 c1->rank, c1->suit,
				 c2->rank, c2->suit);
}

void print_bytes(const void *ptr, const int len) {
	int i = 0;
	char* w_ptr = (char*) ptr;

	for(; i < len; ++i) {
		printf("-%d", (int) (char) (w_ptr[i]));
		if(i % 8 == 0)
			printf("\n");
	}
}

void copy_itemPlayer_to_PlayerBuf(PlayerBuf* dest, const list_itemPlayer* list) {
	list_itemPlayer* players = (list_itemPlayer*)list;
	list_itemPlayer* curr = players, *tmp;
	int len = 0, i = 0;

	for(; curr != NULL; curr = curr->next, ++len); 

	dprintf("# players: %d\n", len);	

	// Setup players
	dest->size = (char) len;
	dest->ptr = malloc(sizeof(Player) * len);

	for(i=0, curr = players; i < len; ++i) {
		dest->ptr[i] = curr->value;
		// free current node
		tmp = curr->next;
		free(curr);
		curr = tmp;
	}

}
