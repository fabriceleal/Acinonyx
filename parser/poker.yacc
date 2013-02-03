%{

#include <stdio.h>
#include <string.h>
#include "common.h"

%}

%union {
	// Raw
	float f_value;
	int i_value;
	char c_value;
	char card_value[2];
	char *s_value;

	// 
	struct {
		float f_small;
		float f_big;
	} b_value;

	enum {
		preflop,
		flop,
		turn,
		river
	} r_value;

	enum {
		post,
		call,
		check,
		bet,
		raise,
		fold
	} a_value;

	void *ptr;
}

//%token WHITESPACE
%token <card_value> CARD
%token NEW_LINE
%token <s_value> WORD
%token <f_value> VALUE
%token <i_value> ID
%token <f_value> NUMBER
%token OPEN_PARE
%token <c_value> CLOSE_PARE
%token BAR
%token DASH
%token COLON
%token <c_value> CLOSE_BRACK
%token HAND_END
%token STAR
%token COMMA
%token <r_value> PHASE
%token <a_value> ACTION
%token WIN

%type <ptr> card_star
%type <ptr> board
%type <ptr> round
%type <i_value> decl_date
%type <i_value> decl_table
%type <ptr> decl_player
%type <i_value> decl_hand
%type <b_value> decl_blinds
%type <h_value> hand;
%type <ptr> decl_player_star;

%%

hand:      decl_hand
           decl_blinds
           decl_table
           decl_date
           NEW_LINE
           decl_player_star
           NEW_LINE
           action_star
           NEW_LINE
           round_star
           summary
           NEW_LINE
hand_end { 
	hand = malloc(sizeof(Hand));
	bzero(hand, sizeof(Hand));

	hand->id = $1;
	hand->blinds.small = $2.f_small;
	hand->blinds.big = $2.f_big;

	copy_itemPlayer_to_PlayerBuf(&hand->players, ($6));
	
}
           ;

decl_hand: WORD WORD WORD ID NEW_LINE {
	// free unused words!
	free($1); free($2); free($3);

	//dprintf(".. Hand\n"); 
	$$ = $4; 
}
           ;

decl_blinds: WORD WORD WORD OPEN_PARE VALUE BAR VALUE CLOSE_PARE NEW_LINE { 
	// free unused words!
	free($1); free($2); free($3);

	$$.f_small = $5; 
	$$.f_big = $7; 
}
           ;

decl_table: WORD WORD WORD NUMBER DASH WORD NEW_LINE {
	free($1); free($2); free($3); free($6);

	$$ = 0;
}
           ;

decl_date: WORD NUMBER COMMA NUMBER DASH NUMBER COLON NUMBER COLON NUMBER OPEN_PARE WORD CLOSE_PARE NEW_LINE {
	free($1); free($12);

	$$ = 0;
}
           ;

decl_player: NUMBER player_type WORD STAR VALUE CARD CARD NEW_LINE {
	// Do not free $3 here!
	Player* player = malloc(sizeof(Player));

	player->name = $3;
	player->stack = $5;
	player->card_0.rank = $6[0];
	player->card_0.suit = $6[1];
	player->card_1.rank = $7[0];
	player->card_1.suit = $7[1];
	player->button = (char)1;

	$$ = (void*) player;
}
           | NUMBER player_type WORD      VALUE CARD CARD NEW_LINE {
	// Do not free $3 here!
	Player* player = malloc(sizeof(Player));

	player->name = $3;
	player->stack = $4;
	player->card_0.rank = $5[0];
	player->card_0.suit = $5[1];
	player->card_1.rank = $6[0];
	player->card_1.suit = $6[1];
	player->button = (char)0;

	$$ = (void*) player;
}
           ;

player_type: CLOSE_BRACK // hero, but we dont care
           | CLOSE_PARE
           ;

decl_player_star: decl_player decl_player_star {
	list_itemPlayer* r = new_itemPlayer($1);
	append_itemPlayer(r, $2);
	$$ = (void*) r;
}
| decl_player {
	list_itemPlayer* r = new_itemPlayer($1);
	$$ = (void*) r;
}
                ;

round: board action_star NEW_LINE {
	$$ = $1;
}
     ;

round_star: round round_star
          | round
          ;

board: PHASE COLON card_star NEW_LINE {
	
	$$ = $3;
}
     ;

card_star: CARD card_star {
//--
	list_itemCard* r = new_itemCard($1);
	append_itemCard(r, (list_itemCard*) $2);
  $$ = (void*) r;
}
         | CARD {
//--
	list_itemCard* r = new_itemCard($1);
  $$ = (void*) r;
}
         ;

action: WORD ACTION WORD WORD VALUE NEW_LINE {
//--
	free($1); free($3); free($4); 
	
}
      | WORD ACTION VALUE NEW_LINE {
// --
	free($1);
	
}
      | WORD ACTION NEW_LINE {
//--
	free($1);
	
}
      ;

action_star: action action_star
           | action
           ;

summary: WORD WIN VALUE WORD NEW_LINE {
	free($1); free($4);
}
       ;

hand_end: HAND_END NEW_LINE { 
	dprintf(".. Hand end\n"); 
}

%%
