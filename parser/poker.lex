%{

#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "common.h"

int lineno = 0;

#define _POKER_LEX_NO_DEBUG
#ifdef _POKER_LEX_NO_DEBUG
#undef dprintf
#define dprintf(...)
#endif

%}

numeric [0-9]+
letters [a-zA-Z]+
card [AKQJT2-9][hscd]
flop FLOP
turn TURN
river RIVER
bet bets
raise raises
call calls
check checks
fold folds
post posts
win wins
show shows
muck mucks
sitout "(sitting out)"
allin "(all-in)"

%%

\r     /* ignore carriage return */ ;

[\t ]+ /* ignore whitespace */;

\n {
	dprintf(".\n");

	++lineno;

	return NEW_LINE;
}

{allin} {
	dprintf("allin ", yytext);

	return ALLIN;
}

{sitout} {

	dprintf("sitout ", yytext);

	return SITOUT;
}

{win} {

	dprintf("win(%s) ", yytext);

	return WIN;
}

{post}|{raise}|{bet}|{call}|{check}|{fold}|{show}|{muck} {
	if(!strcmp(yytext, "posts")) {
		yylval.a_value = post;
	} else if(!strcmp(yytext, "raises")) {
		yylval.a_value = raise;		
	} else if(!strcmp(yytext, "bets")) {
		yylval.a_value = bet;
	} else if(!strcmp(yytext, "calls")) {
		yylval.a_value = call;
	} else if(!strcmp(yytext, "checks")) {
		yylval.a_value = check;
	} else if(!strcmp(yytext, "folds")) {
		yylval.a_value = fold;
	} else {
		yylval.a_value = IGNORE;
	}
	
	dprintf("action(%s) ", yytext);
	
	return ACTION;

}

{flop}|{turn}|{river} {

	if(!strcmp(yytext, "FLOP")) {
		yylval.r_value = flop;
	} else if(!strcmp(yytext, "TURN")) {
		yylval.r_value = turn;		
	} else if(!strcmp(yytext, "RIVER")) {
		yylval.r_value = river;
	} else {
		yylval.r_value = 0;
	}

	dprintf("phase(%d) ", yylval.r_value);
	
	return PHASE;
}

{card} {
	memcpy(yylval.card_value, yytext, sizeof(yylval.card_value));

	dprintf("card(%c%c) ", yylval.card_value[0], yylval.card_value[1]);

	return CARD;
}

{letters} {
	// ATTENTION: malloc without free!
	int len = strlen(yytext);
	char* long_string = malloc(len + 1);

	bzero(long_string, len + 1);
	strcpy(long_string, yytext);
	
	yylval.s_value = long_string;

	dprintf("word(%s) ", yylval.s_value);

	return WORD;
}

\${numeric}(\.{numeric})? {
	// exclude the initial '$' char
	yylval.f_value = atof(yytext + 1); 

	dprintf("value(%.2f) ", yylval.f_value);

	return VALUE;
}

#{numeric}(\,{numeric}{3})* {
  // we need to treat the string  
  int i = 0, y = 0, len = strlen(yytext);
  char* _id_ptr = malloc(len + 1);
  bzero(_id_ptr, len + 1);
 
  // Copy only numeric chars
  for(; i < len; ++i) {
		if(yytext[i] >= '0' && yytext[i] <= '9') {
			_id_ptr[y++] = yytext[i];
		}
  }

  yylval.i_value = atoi(_id_ptr);
 
  dprintf("id(%d) ", yylval.i_value);

  free(_id_ptr);

  return ID;
}

{numeric} {
	yylval.f_value = atof(yytext);

  dprintf("number(%.2f) ", yylval.f_value);

  return NUMBER;
}

\( {
	dprintf("open-pare ");

	return OPEN_PARE;
}

\) {
	dprintf("clos-pare ");

	//	yylval.c_value = ')';

	return CLOSE_PARE;
}

\/ {
	dprintf("bar ");

	return BAR;
}

\- {
	dprintf("dash ");

	return DASH;
}

\: {
	dprintf("colon ");

	return COLON;
}

\} {
	dprintf("clos-brac ");

	//	yylval.c_value = '}';

	return CLOSE_BRACK;
}

\*{30} {
	dprintf("hand-end ");

	return HAND_END;
}

\* {
	dprintf("star ");

	return STAR;
}

\, /* ignore whitespace */;

%%

void yyerror(char *s) {
	fprintf(stderr, "%d: %s at '%s'\n", lineno, s, yytext);
}

int yywrap() {
	dprintf("yywrap()\n");

	int err = fclose(yyin);
	FAIL_IF(0 != err, "Error closing current file\n");

	return 1; // 0 means more input!
}

int main(int argc, char** argv) {
	int val;
	FILE* file;

	// Check number of arguments
	FAIL_IF(2 != argc, "Invalid number of arguments (%d)\n", argc);

	// Open file
	//file = fopen("../tests/000.txt" /*argv[1]*/, "r");
	file = fopen(argv[1], "r");
	FAIL_IF(NULL == file, "Error opening file %s\n", argv[1]);
	
	yyin = file;

	hand = NULL;

	// Lex!
	//while(val = yylex()) {
	//		dprintf("value is %d\n", val);
	//}
	
	// Parse!
	yyparse();

	if(hand != NULL) {
		//print_hand(hand);
	}

	return 0;
}
