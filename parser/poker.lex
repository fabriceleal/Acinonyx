%{

	//#include "poker.tokens.h"
#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>

	//extern int yylval;

#define __DEBUG_INFO

// debug print
#ifdef __DEBUG_INFO

#  define dprintf(s, args...)	fprintf(stderr, (s), ##args)

#else

#  define dprintf(s, ...)

#endif

// Check condition, fail if true
// print messages
#define FAIL_IF(cond, msg, args...)											\
	if(cond) {																						\
		fprintf(stderr, "Condition (%s) failed!\n", #cond); \
		fprintf(stderr, msg, ##args);												\
		exit(-1);																						\
	}


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
	dprintf("\n");
	return NEW_LINE;
}

{flop}|{turn}|{river} {
	dprintf("phase ");
	return PHASE;
}

{card} {
	dprintf("card(%s) ", yytext);
	return CARD;
}

{letters} {
	dprintf("word(%s) ", yytext);
	return WORD;
}

\${numeric}(\.{numeric})? {
	// exclude the initial '$' char
	yylval.f_value = atof(yytext + 1); 

	dprintf("value(%s parsed as %.2f) ", yytext, yylval.f_value);

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
 
  dprintf("id(%s parsed as %d) ", yytext, yylval.i_value);

  free(_id_ptr);

  return ID;
}

{numeric} {
	yylval.f_value = atof(yytext);
  dprintf("number(%s parsed as %.2f) ", yytext, yylval.f_value);
  return NUMBER;
}

\( {
	dprintf("open-pare ");
	return OPEN_PARE;
}

\) {
	dprintf("clos-pare ");
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
