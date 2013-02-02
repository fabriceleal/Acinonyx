
.PHONY: clean

all: poker

poker: lex.yy.c
	cc $^ -o $@ -ll

lex.yy.c: poker.lex
	lex $^

y.tab.h y.tab.c: poker.yacc
	yacc -d $^

clean:
	rm -rf poker lex.yy.c y.tab.h y.tab.c
