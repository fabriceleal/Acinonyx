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
%%

\r     /* ignore carriage return */ ;

[\t ]+ {
	dprintf("whitespace ");
	return WHITESPACE;
}

\n {
	dprintf("\n");
	return NEW_LINE;
}

[a-zA-Z]+ {
	dprintf("word ");
	return WORD;
}

\$[0-9]+(\.[0-9]+)? {
	dprintf("value "); 
	return VALUE;
}

#[0-9]+(\,[0-9]{3})* {
	dprintf("id ");
	return ID;
}

[0-9]+ {
	dprintf("number ");
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
	dprintf("clos-bracket ");
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
