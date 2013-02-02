%{

#include "poker.tokens.h"
#include <stdio.h>

#define __DEBUG_INFO
#ifdef __DEBUG_INFO

#  define dprintf(s, args...)	fprintf(stderr, (s), ##args)

#else

#  define dprintf(s, ...)

#endif

%}

numeric [0-9]+
letters [a-zA-Z]+
card [AKQJT2-9][hscd]

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

{card} {
	dprintf("card(%s) ", yytext);
	return CARD;
}

{letters} {
	dprintf("word(%s) ", yytext);
	return WORD;
}

\${numeric}(\.{numeric})? {
	dprintf("value(%s) ", yytext); 
	return VALUE;
}

#{numeric}(\,{numeric}{3})* {
  dprintf("id(%s) ", yytext);
	return ID;
}

{numeric} {
	dprintf("number(%s) ", yytext);
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
	while(val = yylex()) {
		//		dprintf("value is %d\n", val);
	}
	return 0;
}
