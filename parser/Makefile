
.PHONY: clean all

all: poker sizes

poker: lex.yy.c y.tab.c y.tab.h common.h common.c mem_dbg.c mem_dbg.h intern.c intern.h serialize.c serialize.h
	cc lex.yy.c y.tab.c common.c mem_dbg.c intern.c serialize.c -o $@ -ll -ly -g

sizes: sizes.c common.h
	cc sizes.c -o $@

lex.yy.c: poker.lex
	lex $^

y.tab.h y.tab.c: poker.yacc
	yacc -d $^

clean:
	rm -rf poker sizes lex.yy.c y.tab.h y.tab.c *.o
