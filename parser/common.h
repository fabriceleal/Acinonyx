#ifndef COMMON_H
#  define COMMON_H


#  define __DEBUG_INFO

// debug print
#  ifdef __DEBUG_INFO

#    define dprintf(s, args...)	fprintf(stderr, (s), ##args)

#  else

#    define dprintf(...)

#  endif

// Check condition, fail if true
// print messages
#  define FAIL_IF(cond, msg, args...)											\
	if(cond) {																						\
		fprintf(stderr, "Condition (%s) failed!\n", #cond); \
		fprintf(stderr, msg, ##args);												\
		exit(-1);																						\
	}

typedef struct {
	char rank;
	char suit;
} Card;

/*typedef struct {
	int size;
	Card* ptr;
} CardBuf;*/

typedef struct {
	float small;
	float big;
} Blind;

typedef struct {
	char* name;
	float stack;
	char button;

	Card card_0;
	Card card_1;

	//	long long _;
} Player;

typedef struct {
	char size;
	Player** ptr;
} PlayerBuf;


typedef struct {
	
} Action;

typedef struct {
	char size;
	Action* ptr;
} ActionBuf;

/*typedef struct {
	ActionBuf actions;
	CardBuf cards; 
	} Round;*/

/*typedef struct {
	int size;
	Round* ptr;
	} RoundBuf;*/

typedef struct {
	ActionBuf actions;
} Preflop;

typedef struct {
	ActionBuf actions;
	Card cards[3];
} Flop;

typedef struct {
	ActionBuf actions;
	Card card;
} Turn;

typedef struct {
	ActionBuf actions;
	Card card;
} River;

typedef struct {
	int id;
	Blind blinds;
	Preflop r_0;
	Flop r_1;
	Turn r_2;
	River r_3;
	PlayerBuf players;
} Hand;

Hand *hand;

void print_hand(const Hand* h);
void print_player(const Player* p);
void print_card(const Card* c);
void print_pocket_hand(const Card* c1, const Card* c2);
/*
 * hand
 * -id
 * -blinds
 * -rounds
 * -- preflop
 * --- actions
 * -- flop
 * --- board
 * --- actions
 * -- turn
 * --- board
 * --- actions
 * -- river
 * --- board
 * --- actions
 */


typedef struct _list_itemCard {
	Card value;
	struct _list_itemCard *next;
} list_itemCard;
void append_itemCard(list_itemCard* new_head, const list_itemCard* tail);
list_itemCard* new_itemCard(const char c[2]);

typedef struct _list_itemPlayer {
	Player* value;
	struct _list_itemPlayer *next;
} list_itemPlayer;
void append_itemPlayer(list_itemPlayer* new_head, const list_itemPlayer* tail);
list_itemPlayer* new_itemPlayer(const Player* player);

void print_bytes(const void *ptr, const int len);

void copy_itemPlayer_to_PlayerBuf(PlayerBuf* dest, const list_itemPlayer* list);

#endif
