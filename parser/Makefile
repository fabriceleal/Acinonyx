
.PHONY: clean

all: poker

poker: lex.yy.c y.tab.c y.tab.h common.h common.c mem_dbg.c mem_dbg.h
	cc lex.yy.c y.tab.c common.c mem_dbg.c -o $@ -ll -ly -g

lex.yy.c: poker.lex
	lex $^

y.tab.h y.tab.c: poker.yacc
	yacc -d $^

clean:
	rm -rf poker lex.yy.c y.tab.h y.tab.c *.o
