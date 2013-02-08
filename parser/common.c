#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "common.h"

#define _POKER_LEX_NO_DEBUG
#ifdef _POKER_LEX_NO_DEBUG
#undef dprintf
#define dprintf(...)
#endif

char makeCard(char c[2]) {
	// rank: 2-9TJQKA
	// suit: shcd (16, 5, 1, 0)

	// rrrr rrrr rrrs ssss	
	return ((0x3F & (c[0] - '2')) << 5) | (0x1F & (c[1] - 'c'));
}

void fillCard(Card *card, const char c[2]) {
	card->rank = c[0];
	card->suit = c[1];
}

list_itemCard* new_itemCard(const char c[2]) {
	list_itemCard *ret = malloc(sizeof(list_itemCard));
	ret->next = NULL;
	fillCard(&ret->value, c);
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

list_itemAction* new_itemAction(const Action* action) {
	list_itemAction *ret = malloc(sizeof(list_itemAction));
	ret->next = NULL;
	ret->value = (Action*) action;
	return ret;
}

void append_itemAction(list_itemAction* new_head, list_itemAction* tail) {
	list_itemAction* end = tail;

	// find end of the tail
	for(; end->next != NULL; end = end->next);
	end->next = new_head;
}


list_itemRawRound* new_itemRawRound(const RawRound* rawRound) {
	list_itemRawRound *ret = malloc(sizeof(list_itemRawRound));
	ret->next = NULL;
	ret->value = (RawRound*) rawRound;
	return ret;
}

void append_itemRawRound(list_itemRawRound* new_head, const list_itemRawRound* tail) {
	new_head->next = (list_itemRawRound*) tail;
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
		print_player(h->players.ptr + i);
	}
	printf("Preflop\n");
	for(i = 0; i < h->r_0.actions.size; ++i) {
		print_action(h->r_0.actions.ptr + i);
	}
	if(h->r_1.actions.size) {
		printf("Flop\n");
		for(i = 0; i < 3; ++i) {
			print_card(&h->r_1.cards[i]);
		}
		for(i = 0; i < h->r_1.actions.size; ++i) {
			print_action(h->r_1.actions.ptr + i);
		}		
	}
	if(h->r_2.actions.size) {
		printf("Turn\n");
		print_card(&h->r_2.card);
		for(i = 0; i < h->r_2.actions.size; ++i) {
			print_action(h->r_2.actions.ptr + i);
		}
	}
	if(h->r_3.actions.size) {
		printf("River\n");
		print_card(&h->r_3.card);
		for(i = 0; i < h->r_3.actions.size; ++i) {
			print_action(h->r_3.actions.ptr + i);
		}
	} /**/
}

void print_action(const Action* a) {
	printf("Action: player %s make ", a->player.name);
	switch(a->type) {
	case a_fold:
		printf("fold\n");
		return;
	case a_call:
		printf("call\n");
		return;
	case a_check:
		printf("check\n");
		return;
	case a_raise:
		printf("raise\n");
		return;
	case a_bet:
		printf("bet\n");
		return;
	case a_small_blind:
		printf("small blind\n");
		return;
	case a_big_blind:
		printf("small blind\n");
		return;
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
		//dest->ptr[i] = curr->value;
		memcpy(dest->ptr + i, curr->value, sizeof(Player));
		free(curr->value);

		// free current node
		tmp = curr->next;
		free(curr);
		curr = tmp;
	}
}

#define DEBUG_COPY_ACTION

void copy_itemAction_to_ActionBuf(const PlayerBuf* players, 
																	ActionBuf* dest, 
																	const list_itemAction* list) {
	//--
	list_itemAction* actions = (list_itemAction*)list;
	list_itemAction* curr = actions, *tmp;
	int len = 0, i, y;
#ifdef DEBUG_COPY_ACTION
	char found;
#endif

	// get action length
	for(; curr != NULL; curr = curr->next, ++len); 

	dprintf("# actions: %d\n", len);	

	// Setup actions
	dest->size = (char) len;
	dest->ptr = malloc(sizeof(Action) * len);

	for(i = 0, curr = actions; i < len; ++i) {
		//dest->ptr[i] = curr->value;
		memcpy(dest->ptr + i, curr->value, sizeof(Action));
/*
#ifdef DEBUG_COPY_ACTION
		found = 0;
#endif
		
		// find player
		for(y = 0; y < players->size; ++y) {
			if(! strcmp(dest->ptr[i].player.name, players->ptr[y].name)) {
				dest->ptr[i].player.ptr = &players->ptr[y];
#ifdef DEBUG_COPY_ACTION
				found = 1;
#endif
			}
		}
		
#ifdef DEBUG_COPY_ACTION
		FAIL_IF((!found), "Unable to find ptr to player!");
#endif
*/
		free(curr->value);

		// free current node
		tmp = curr->next;
		free(curr);
		curr = tmp;
	}
}

#undef DEBUG_COPY_ACTION

// inits and fills the necessary structs
void copy_itemRawRound_to_Hand(Hand* dest, const list_itemRawRound* list) {
	list_itemRawRound* curr_round = (list_itemRawRound*) list;
	list_itemCard* curr_cards = NULL;
	void* tmp;
	int i = 0;
	
	// FLOP
	if(NULL == curr_round) {
		return;
	}
	copy_itemAction_to_ActionBuf(&dest->players, 
															 &dest->r_1.actions, 
															 curr_round->value->actions);
	// Read all cards of the board
	// free as we walk
	for(i = 0, curr_cards = curr_round->value->cards; 
			NULL != curr_cards; 
			++i) {
		//--
		dest->r_1.cards[i] = curr_cards->value;
		tmp = curr_cards;
		curr_cards = curr_cards->next;
		free(tmp);
	}

	// TURN
	tmp = curr_round;
	free(curr_round->value);
	curr_round = curr_round->next;
	// freeing flop
	free(tmp);
	if(NULL == curr_round) {
		return;
	}
	copy_itemAction_to_ActionBuf(&dest->players,
															 &dest->r_2.actions,
															 curr_round->value->actions);
	// Find last card
	// free as we walk
	curr_cards = curr_round->value->cards;
	while(curr_cards->next != NULL) {
		tmp = curr_cards;
		curr_cards = curr_cards->next; 
		free(tmp);
	}
	// card of the river is the last card of the round
	dest->r_2.card = curr_cards->value;
	// free last card
	free(curr_cards);


	// RIVER
	tmp = curr_round;
	free(curr_round->value);
	curr_round = curr_round->next;
	// freeing turn
	free(tmp);
	if(NULL == curr_round) {
		return;
	}
	copy_itemAction_to_ActionBuf(&dest->players,
															 &dest->r_3.actions,
															 curr_round->value->actions);
	// Find last card
	// free as we walk
	curr_cards = curr_round->value->cards;
	while(curr_cards->next != NULL) {
		tmp = curr_cards;
		curr_cards = curr_cards->next; 
		free(tmp);
	}
	// card of the river is the last card of the round
	dest->r_3.card = curr_cards->value;
	// free last card
	free(curr_cards);

	// freeing river
	free(curr_round->value);
	free(curr_round); 
}

void free_hand(Hand* hand) {
	int i;


	if(hand->r_0.actions.ptr) {		
		free(hand->r_0.actions.ptr);
	}

	if(hand->r_1.actions.ptr) {		
		free(hand->r_1.actions.ptr);
	}

	if(hand->r_2.actions.ptr) {		
		free(hand->r_2.actions.ptr);
	}

	if(hand->r_3.actions.ptr) {		
		free(hand->r_3.actions.ptr);
	}

	if(hand->players.size) {		
		// do not free player name, comes from pool
		//free(hand->players.ptr[i]->name);
		free(hand->players.ptr);
	}

	free(hand);
}
