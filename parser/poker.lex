%{

	//#include "poker.tokens.h"
#include "y.tab.h"
#include "common.h"
#include <stdio.h>
#include <stdlib.h>

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

%%

\r     /* ignore carriage return */ ;

[\t ]+ ; /* {
	dprintf("whitespace ");
	return WHITESPACE;
	}*/

\n {
	dprintf(".\n");

	++lineno;

	return NEW_LINE;
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

\, {
	dprintf("comma ");

	return COMMA;
}

%%

void yyerror(char *s) {
	fprintf(stderr, "%d: %s at '%s'\n", lineno, s, yytext);
}

int main(int argc, char** argv) {
	int val;

	// Parse!
	yyparse();

	//printf("HAND\n");
	//	printf("Id: %d\n", hand.id);

	// Lex!
	//while(val = yylex()) {
		//		dprintf("value is %d\n", val);
	//}
	return 0;
}

/*
int main(int argc, char** argv) {
	int val;
	FILE* file;

	// Check number of arguments
	FAIL_IF(2 != argc, "Invalid number of arguments (%d)\n", argc);

	// Open file
	file = fopen(argv[1], "r");
	FAIL_IF(NULL == file, "Error opening file %s\n", argv[1]);
	
	yyin = file;

	while(val = yylex()) {
		//		dprintf("value is %d\n", val);
	}

	return 0;
}

int yywrap() {
	dprintf("yywrap()\n");

	int err = fclose(yyin);
	FAIL_IF(0 != err, "Error closing current file\n");

	return 1; // 0 means more input!
}
*/
