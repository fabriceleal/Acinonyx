%token WHITESPACE CARD NEW_LINE WORD VALUE ID NUMBER OPEN_PARE CLOSE_PARE BAR DASH COLON CLOSE_BRACK HAND_END STAR COMMA FLOP TURN RIVER
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
