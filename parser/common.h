#ifndef COMMON_H
#define COMMON_H


#define __DEBUG_INFO

// debug print
#ifdef __DEBUG_INFO

#  define dprintf(s, args...)	fprintf(stderr, (s), ##args)

#else

#  define dprintf(s, ...)

#endif

// Check condition, fail if true
// print messages
#define FAIL_IF(cond, msg, args...)											\
	if(cond) {																						\
		fprintf(stderr, "Condition (%s) failed!\n", #cond); \
		fprintf(stderr, msg, ##args);												\
		exit(-1);																						\
	}

typedef struct {
	char rank;
	char suit;
} Card;

typedef struct {
	float small;
	float big;
} Blind;

typedef struct {
	char* name;
	float stack;
	Card card[2];
} Player;

typedef struct {
	
} Action;

typedef struct {

} Round;

typedef struct {
	int id;
	Blind blind;
} Hand;

Hand *hand;

#endif
