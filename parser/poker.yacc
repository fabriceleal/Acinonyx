
%union {
	float f_value;
	int i_value;
	char card_value[2];
}

%token WHITESPACE
%token <card_value> CARD
%token NEW_LINE
%token WORD
%token <f_value> VALUE
%token <i_value> ID
%token <f_value> NUMBER
%token OPEN_PARE
%token CLOSE_PARE
%token BAR
%token DASH
%token COLON
%token CLOSE_BRACK
%token HAND_END
%token STAR
%token COMMA
%token PHASE


%%

hand:      decl_hand
           decl_blinds
           decl_table
           decl_date
           NEW_LINE
           decl_player
           ;

decl_hand: WORD WORD WORD ID NEW_LINE
           ;

decl_blinds: WORD WORD WORD OPEN_PARE VALUE BAR VALUE CLOSE_PARE NEW_LINE
           ;

decl_table: WORD WORD WORD NUMBER DASH WORD NEW_LINE
           ;

decl_date: WORD NUMBER COMMA NUMBER DASH NUMBER COLON NUMBER COLON NUMBER OPEN_PARE WORD CLOSE_PARE NEW_LINE
           ;

decl_player: NUMBER player_type CLOSE_BRACK STAR WORD VALUE CARD CARD NEW_LINE
           ;

player_type: CLOSE_BRACK
           | CLOSE_PARE
           ;

%%
