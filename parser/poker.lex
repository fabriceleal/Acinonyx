%{

#include "poker.tokens.h"
	
%}
%%

\r                   /* ignore */ ;
[\t ]+               { /*printf("whitespace ");*/ return WHITESPACE; }
\n                   { /*printf("new-line ");*/ return NEW_LINE; }
[a-zA-Z]+            { /*printf("word ");*/ return WORD;}
\$[0-9]+(\.[0-9]+)?  { /*printf("value ");*/ return VALUE; }
#[0-9]+(\,[0-9]{3})* { /*printf("id ");*/ return ID; }
[0-9]+               { /*printf("number ");*/ return NUMBER; }
\(                   { /*printf("open-pare ");*/ return OPEN_PARE; }
\)                   { /*printf("clos-pare ");*/ return CLOSE_PARE; }
\/                   { /*printf("bar ");*/ return BAR; }
\-                   { /*printf("dash ");*/ return DASH; }
\:                   { /*printf("colon ");*/ return COLON; }
\}                   { /*printf("clos-bracket ");*/ return CLOSE_BRACK; }
\*{30}               { /*printf("hand-end ");*/ return HAND_END; }
\*                   { /*printf("star ");*/ return STAR; }
\,                   { /*printf("comma ");*/ return COMMA; }

%%

int main(int argc, char** argv) {
	int val;
	while(val = yylex()) {
		printf("value is %d\n", val);
	}
	return 0;
}
