# Acinonyx

Parser for poker hand histories written with lex/yacc.

## Assume:
* No whitespace inside user names. Only [a-zA-Z]+
* Ignore hero

## Lessons learned

* Try to use left recursion instead of right recursion.

## ...

Do test:
`valgrind --leak-check=full --show-reachable=yes --track-origins=yes <exe> <args...>`
