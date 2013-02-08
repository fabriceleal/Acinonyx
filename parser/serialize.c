#include "serialize.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void serialize_action(Action* action, FILE* f) {
	char len = (char) strlen(action->player.name);
	fwrite(action->player.name, sizeof(char), len, f);
	fwrite(&action->type, sizeof(ActionType), 1, f);
}

void serialize_player(Player* player, FILE* f) {
	char len = (char) strlen(player->name);
	fwrite(&len, sizeof(char), 1, f);
	fwrite(player->name, sizeof(char), len, f);
	fwrite(&player->stack, sizeof(float), 1, f);
	fwrite(&player->button, sizeof(char), 1, f);
	fwrite(&player->card_0, sizeof(Card), 1, f);
	fwrite(&player->card_1, sizeof(Card), 1, f);
}

FILE* f;

void open_serialize(char* filename) {
	f = fopen(filename, "w");
}

void close_serialize() {
	fclose(f);
}

void serialize(Hand* hand) {
	char i;

	// id
	fwrite(&hand->id, sizeof(int), 1, f);

	// blinds
	fwrite(&hand->blinds.small, sizeof(float), 1, f);
	fwrite(&hand->blinds.big, sizeof(float), 1, f);

	// rounds
	// * preflop
	fwrite(&hand->r_0.actions.size, sizeof(char), 1, f);
	for(i=0; i < hand->r_0.actions.size; ++i) {
		serialize_action(&hand->r_0.actions.ptr[i], f);
	}

	// * flop
	fwrite(&hand->r_1.actions.size, sizeof(char), 1, f);
	for(i=0; i < hand->r_1.actions.size; ++i) {
		serialize_action(&hand->r_1.actions.ptr[i], f);
	}
	fwrite(hand->r_1.cards, sizeof(Card), 3, f);

	// * turn
	fwrite(&hand->r_2.actions.size, sizeof(char), 1, f);
	for(i=0; i < hand->r_2.actions.size; ++i) {
		serialize_action(&hand->r_2.actions.ptr[i], f);
	}
	fwrite(&hand->r_2.card, sizeof(Card), 1, f);

	// * river
	fwrite(&hand->r_3.actions.size, sizeof(char), 1, f);
	for(i=0; i < hand->r_3.actions.size; ++i) {
		serialize_action(&hand->r_3.actions.ptr[i], f);
	}
	fwrite(&hand->r_3.card, sizeof(Card), 1, f);

	// players
	fwrite(&hand->players.size, sizeof(char), 1, f);
	for(i=0; i < hand->players.size; ++i) {
		serialize_player(&hand->players.ptr[i], f);
	}
}

Hand* deserialize() {
	
}
