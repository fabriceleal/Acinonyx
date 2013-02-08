%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "common.h"
#include "mem_dbg.h"

#define _POKER_LEX_NO_DEBUG
#ifdef _POKER_LEX_NO_DEBUG
#undef dprintf
#define dprintf(...)
#endif

#define _MEM_NO_DEBUG
#ifndef _MEM_NO_DEBUG
#define free(x) dfree(x)
#endif

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
		fold = 0,

		call = 1,
		check = 2,

		raise = 3,
		bet = 4,

		post,
		
		IGNORE
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
%token <r_value> PHASE
%token <a_value> ACTION
%token WIN
%token SITOUT
%token ALLIN

%type <ptr> card_plus
%type <ptr> board
%type <ptr> round
%type <i_value> decl_date
%type <i_value> decl_table
%type <ptr> decl_player
%type <i_value> decl_hand
%type <b_value> decl_blinds
%type <h_value> hand;
%type <ptr> decl_player_plus;
%type <ptr> action;
%type <ptr> action_plus;
%type <ptr> round_plus;


%%


hand_plus: hand
         | hand_plus hand
         ;

hand:      decl_hand
           decl_blinds
           decl_table
           decl_date
           NEW_LINE
           decl_player_plus
           NEW_LINE
           action_plus
           NEW_LINE
           round_plus
           summary_plus
           NEW_LINE
hand_end { 
	hand = malloc(sizeof(Hand));
	bzero(hand, sizeof(Hand));

	hand->id = $1;
	hand->blinds.small = $2.f_small;
	hand->blinds.big = $2.f_big;

	dprintf("copying stuff from linked lists ...\n");

	copy_itemPlayer_to_PlayerBuf(&hand->players, ($6));

	dprintf("copying actions\n");
	
	copy_itemAction_to_ActionBuf(&hand->players, &hand->r_0.actions, ($8));

	dprintf("\n");

	copy_itemRawRound_to_Hand(hand, ($10));

	// do something with hand
	dprintf("printing hand\n");
	//print_hand(hand);
	serialize(hand);

	// free hand
	dprintf("freeing hand\n");
	free_hand(hand);
} | decl_hand
           decl_blinds
           decl_table
           decl_date
           NEW_LINE
           decl_player_plus
           NEW_LINE
           action_plus
           NEW_LINE
           summary_plus
           NEW_LINE
hand_end { 
	hand = malloc(sizeof(Hand));
	bzero(hand, sizeof(Hand));

	hand->id = $1;
	hand->blinds.small = $2.f_small;
	hand->blinds.big = $2.f_big;

	dprintf("copying stuff from linked lists ...\n");

	copy_itemPlayer_to_PlayerBuf(&hand->players, ($6));

	dprintf("copying actions\n");
	
	copy_itemAction_to_ActionBuf(&hand->players, &hand->r_0.actions, ($8));

	// do something with hand
	dprintf("printing hand\n");
	//print_hand(hand);
	serialize(hand);

	// free hand
	dprintf("freeing hand\n");
	free_hand(hand);
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

decl_date: WORD NUMBER NUMBER DASH NUMBER COLON NUMBER COLON NUMBER OPEN_PARE WORD CLOSE_PARE NEW_LINE {
	free($1); free($11);

	$$ = 0;
}
           ;

decl_player: NUMBER player_type WORD STAR VALUE CARD CARD NEW_LINE {	
	// Do not free $3 here!
	//free($3);
	Player* player = malloc(sizeof(Player));

	//player->name = $3;
	player->name = get_string_from_pool(pool, $3);
	free($3);
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

	//player->name = $3;
	player->name = get_string_from_pool(pool, $3);
	free($3);
	player->stack = $4;
	player->card_0.rank = $5[0];
	player->card_0.suit = $5[1];
	player->card_1.rank = $6[0];
	player->card_1.suit = $6[1];
	player->button = (char)0;

	$$ = (void*) player;
}
           | NUMBER player_type WORD SITOUT NEW_LINE {
	//
	free($3);
	
	$$ = NULL;
}
           ;

player_type: CLOSE_BRACK // hero, but we dont care
           | CLOSE_PARE
           ;

decl_player_plus: decl_player {
	if($1 == NULL) {
		$$ = NULL;
	} else {
		list_itemPlayer* r = new_itemPlayer($1);
		$$ = (void*) r;
	}
}
                | decl_player_plus decl_player {
	if(NULL == $2) {
		$$ = $1;
	} else {
		list_itemPlayer* r = new_itemPlayer($2);
		if(NULL != $1) {
			append_itemPlayer(r, $1);
		}
		$$ = (void*) r;
	}
}
                ;

round: board action_plus NEW_LINE {
	RawRound* r = malloc(sizeof(RawRound));
	r->cards = $1;
	r->actions = $2;

	$$ = (void*) r;
}
     | board NEW_LINE {
  //--
	RawRound* r = malloc(sizeof(RawRound));
	r->cards = $1;
	r->actions = NULL;

	$$ = (void*) r;
}
     ;

round_plus: round round_plus {
	list_itemRawRound* r = new_itemRawRound($1);
	append_itemRawRound(r, $2);
	$$ = (void*) r;
}
          | round {
	list_itemRawRound* r = new_itemRawRound($1);
	$$ = (void*) r;
}
          ;

board: PHASE COLON card_plus NEW_LINE {
	$$ = $3;
}
     ;

card_plus: CARD {
//--
	list_itemCard* r = new_itemCard($1);
  $$ = (void*) r;
}
         | card_plus CARD {
//--
	list_itemCard* r = new_itemCard($2);
	append_itemCard(r, (list_itemCard*) $1);
  $$ = (void*) r;
}
         ;

action: WORD ACTION WORD WORD VALUE ALLIN NEW_LINE {
//--
  // <player> posts big blind <value> (all-in)
  // <player> posts small blind <value> (all-in)
	free($4); 

	Action* action = malloc(sizeof(Action));

	action->player.name = get_string_from_pool(pool, $1);
	FAIL_IF((!action->player.name), "Unable to get string %s from pool", $1);
	free($1);

	if(! strcmp($3, "small")) {
		action->type = a_small_blind;
	} else if(! strcmp($3, "big")) {
		action->type = a_big_blind;
	} else {
		FAIL_IF(1, "Unexpected post %s\n", $3);
	}

	free($3);

	$$ = (void*) action;
}
      | WORD ACTION WORD WORD VALUE NEW_LINE {
//--
  // <player> posts big blind <value>
  // <player> posts small blind <value>
	free($3); free($4); 

	Action* action = malloc(sizeof(Action));

	action->player.name = get_string_from_pool(pool, $1);
	FAIL_IF((!action->player.name), "Unable to get string %s from pool", $1);
	free($1);

	action->type = (ActionType)($2);

	$$ = (void*) action;
}
      | WORD ACTION VALUE ALLIN NEW_LINE {
// --	
  // <player> calls <value> (all-in)
  // <player> raises <value> (all-in)
	Action* action = malloc(sizeof(Action));

	action->player.name = get_string_from_pool(pool, $1);
	FAIL_IF((!action->player.name), "Unable to get string %s from pool", $1);
	free($1);

	action->type = $2;

	$$ = (void*) action;
}
      | WORD ACTION VALUE NEW_LINE {
// --	
  // <player> calls <value>
  // <player> raises <value>
	Action* action = malloc(sizeof(Action));

	action->player.name = get_string_from_pool(pool, $1);
	FAIL_IF((!action->player.name), "Unable to get string %s from pool", $1);
	free($1);

	action->type = $2;

	$$ = (void*) action;
}
      | WORD ACTION CARD CARD NEW_LINE {
//--
	// <player> shows <cards>
	free($1);

	$$ = NULL;	
}
      | WORD ACTION NEW_LINE {
//--
  // <player> folds
  // <player> mucks
  if(IGNORE == $2) {
		$$ = NULL;
	} else {
		Action* action = malloc(sizeof(Action));

		action->player.name = get_string_from_pool(pool, $1);
		FAIL_IF((!action->player.name), "Unable to get string %s from pool", $1);

		action->type = $2;

		$$ = (void*) action;	
	}
	free($1);
}
      ;

action_plus: action {
	if(NULL == $1) {
		$$ = NULL;
	} else {
		dprintf("single ...\n");
		list_itemAction* r = new_itemAction($1);
		$$ = (void*) r;
	}
}
           | action_plus action {
	//--
	if(NULL == $2) {
		$$ = $1;
	} else {
		list_itemAction* r = new_itemAction($2);
		if(NULL != $1) {
			append_itemAction(r, $1);
		}
		$$ = (void*) $1;
	}
}
           ;

/* when some player is allin and there are side pots, some 'shows' may happen 
in the middle of the summary*/

summary: WORD WIN VALUE word_plus NEW_LINE {
  free($1);
}
       |
       action
       ;

summary_plus: summary
            | summary_plus summary
            ;

word_plus: WORD {
	free($1);
}
         | word_plus WORD {
	//--
	free($2);
}
         ;

hand_end: HAND_END NEW_LINE { 
	dprintf(".. Hand end\n"); 
}


%%
