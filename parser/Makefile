
.PHONY: clean

all: poker

poker: lex.yy.c
	cc $^ -o $@ -ll

lex.yy.c: poker.lex
	lex $^

clean:
	rm -rf poker lex.yy.c
