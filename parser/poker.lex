%{

#include <stdio.h>
#include <stdlib.h>
#include "y.tab.h"
#include "common.h"
#include "mem_dbg.h"

int lineno = 1;

#define _POKER_LEX_NO_DEBUG
#ifdef _POKER_LEX_NO_DEBUG
#define ldprintf(...)
#else
#define ldprintf(args...) dprintf(args)
#endif

#define _MEM_NO_DEBUG
#ifdef _MEM_NO_DEBUG
#define dmprintf(...)
#else
#define dmprintf(args...) dprintf(args)
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
	ldprintf(".\n");

	++lineno;

	return NEW_LINE;
}

{allin} {
	ldprintf("allin ", yytext);

	return ALLIN;
}

{sitout} {

	ldprintf("sitout ", yytext);

	return SITOUT;
}

{win} {

	ldprintf("win(%s) ", yytext);

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
	
	ldprintf("action(%s) ", yytext);
	
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

	ldprintf("phase(%d) ", yylval.r_value);
	
	return PHASE;
}

{card} {
	memcpy(yylval.card_value, yytext, sizeof(yylval.card_value));
	ldprintf("card(%c%c) ", yylval.card_value[0], yylval.card_value[1]);
	
	// TODO Pack into a single char
	
	return CARD;
}

{letters} {
	// ATTENTION: malloc without free!
	char* long_string = strdup(yytext);
	dmprintf(".malloc(%d) = %p (%s)\n", strlen(long_string) + 1, long_string, long_string);
	
	yylval.s_value = long_string;

	ldprintf("word(%s) ", yylval.s_value);

	return WORD;
}

\${numeric}(\,{numeric}{3})*(\.{numeric})? {
	// exclude the initial '$' char
	int i, y, len = strlen(yytext);
	char* _id_ptr = malloc(len + 1);
	bzero(_id_ptr, len + 1);

	// Copy only numeric chars and the '.'
	for(i = 1, y = 0; i < len; ++i) {
		if(yytext[i] == '.' || (yytext[i] >= '0' && yytext[i] <= '9')) {
			_id_ptr[y++] = yytext[i];
		}
	}

	yylval.f_value = atof(_id_ptr); 

	ldprintf("value(%.2f) ", yylval.f_value);

	free(_id_ptr);

	return VALUE;
}

#{numeric}(\,{numeric}{3})* {
  // we need to treat the string  
  int i, y, len = strlen(yytext);
  char* _id_ptr = malloc(len + 1);
  bzero(_id_ptr, len + 1);
 
  // Copy only numeric chars
  for(i = 1, y = 0; i < len; ++i) {
		if(yytext[i] >= '0' && yytext[i] <= '9') {
			_id_ptr[y++] = yytext[i];
		}
  }

  yylval.i_value = atoi(_id_ptr);
 
  ldprintf("id(%d) ", yylval.i_value);

  free(_id_ptr);

  return ID;
}

{numeric} {
	yylval.f_value = atof(yytext);

  ldprintf("number(%.2f) ", yylval.f_value);

  return NUMBER;
}

\( {
	ldprintf("open-pare ");

	return OPEN_PARE;
}

\) {
	ldprintf("clos-pare ");

	//	yylval.c_value = ')';

	return CLOSE_PARE;
}

\/ {
	ldprintf("bar ");

	return BAR;
}

\- {
	ldprintf("dash ");

	return DASH;
}

\: {
	ldprintf("colon ");

	return COLON;
}

\} {
	ldprintf("clos-brac ");

	//	yylval.c_value = '}';

	return CLOSE_BRACK;
}

\*{30} {
	ldprintf("hand-end ");

	return HAND_END;
}

\* {
	ldprintf("star ");

	return STAR;
}

\, /* ignore whitespace */;

%%

void yyerror(char *s) {
	fprintf(stderr, "Error lexing: %d: %s at '%s'\n", lineno, s, yytext);
}

int yywrap() {
	//dprintf("yywrap()\n");

	int err = fclose(yyin);
	FAIL_IF(0 != err, "Error closing current file\n");

	return 1; // 0 means more input!
}

int main(int argc, char** argv) {
	int val;
	FILE* file;

	// Check number of arguments
	FAIL_IF(3 != argc, "Invalid number of arguments (%d); usage: %s <input> <output>\n", argc, argv[0]);

	// Open file
	file = fopen(argv[1], "r");
	FAIL_IF(NULL == file, "Error opening file %s for reading\n", argv[1]);
	
	yyin = file;

	hand = NULL;

	pool = init_pool();

	open_serialize(argv[2]);
	
	// Parse!
	yyparse();

	yylex_destroy();

	destroy_pool(pool);

	close_serialize();

	return 0;
}
