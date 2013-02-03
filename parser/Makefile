
.PHONY: clean

all: poker

poker: lex.yy.c y.tab.c y.tab.h common.h common.c
	cc lex.yy.c y.tab.c common.c -o $@ -ll -ly -g

lex.yy.c: poker.lex
	lex $^

y.tab.h y.tab.c: poker.yacc
	yacc -d $^

clean:
	rm -rf poker lex.yy.c y.tab.h y.tab.c
