#ifndef _POKER_TOKENS_H
#define _POKER_TOKENS_H

typedef enum {
	WHITESPACE = 255,
	CARD,
	NEW_LINE,
	WORD,
	VALUE,
	ID,
	NUMBER,
	OPEN_PARE,
	CLOSE_PARE,
	BAR,
	DASH,
	COLON,
	CLOSE_BRACK,
	HAND_END,
	STAR,
	COMMA
} e_tokens;

#endif