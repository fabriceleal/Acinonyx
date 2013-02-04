
Assume:
* No whitespace inside user names
* Ignore hero


Do test:
`valgrind --leak-check=full --show-reachable=yes --track-origins=yes <exe> <args...>`
