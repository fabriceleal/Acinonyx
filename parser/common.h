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
/*
typedef struct tag_s_blinds {
		float f_small;
		float f_big;
} s_blinds;

typedef enum tag_e_rounds {
		preflop,
		flop,
		turn,
		river
} e_rounds;

typedef struct {
	  int id;
	  s_blinds blinds;
} s_hand;
*/
#endif
