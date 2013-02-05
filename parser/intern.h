#ifndef INTERN_H
#define INTERN_H

typedef struct _linked_item {
	char* value;
	struct _linked_item* next;
} linked_item;

typedef struct {
	linked_item* ptr;
} intern_pool;

intern_pool* init_pool();

char* get_string_from_pool(intern_pool* pool, char* literal);

int put_string_into_pool(intern_pool* pool, char* literal);

void destroy_pool(intern_pool* pool);

#endif
