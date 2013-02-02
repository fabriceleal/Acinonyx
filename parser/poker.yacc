%{

#include <stdio.h>
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


%type <ptr> card_star
%type <ptr> board
%type <ptr> round
%type <i_value> decl_date
%type <i_value> decl_table
%type <i_value> decl_hand
%type <b_value> decl_blinds
%type <h_value> hand;

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
hand_end { 
	hand = malloc(sizeof(Hand));
	hand->id = $1;
	hand->blind.small = $2.f_small;
	hand->blind.big = $2.f_big;

}
           ;

decl_hand: WORD WORD WORD ID NEW_LINE {
	// free unused words!
	free($1); free($2); free($3);

	dprintf("Hand\n"); $$ = $4; 
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
	free($3);
}
           | NUMBER player_type WORD      VALUE CARD CARD NEW_LINE {
	free($3);
}
           ;

player_type: CLOSE_BRACK
           | CLOSE_PARE
           ;

decl_player_star: decl_player decl_player_star
                | decl_player
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
	//Card c;
	//c.rank = $1[0];
	//c.suit = $1[1];
	list_item_Card* r = new_itemCard($1);
	append_itemCard(r, (list_item_Card*) $2);
  $$ = (void*) r;
}
         | CARD {
//--
	//Card c;
	//c.rank = $1[0];
	//c.suit = $1[1];
	list_item_Card* r = new_itemCard($1);
  $$ = (void*) r;
}
         ;

action: WORD WORD WORD WORD VALUE NEW_LINE {
//--
	free($1); free($2); free($3); free($4); 
	
}
      | WORD WORD VALUE NEW_LINE {
// --
	free($1); free($2);
	
}
      | WORD WORD NEW_LINE {
//--
	free($1); free($2);
	
}
      ;

action_star: action action_star
           | action
           ;

hand_end: HAND_END NEW_LINE { dprintf("Hand end\n"); }

%%
