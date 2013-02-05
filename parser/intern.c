#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "intern.h"

intern_pool* init_pool() {
	intern_pool* r = malloc(sizeof(intern_pool));
	char* empty = malloc(sizeof(char));
	*empty = '\0';
	r->ptr = malloc(sizeof(linked_item));
	r->ptr->value = empty;
	r->ptr->next = NULL;
	return r;
}

// if doesnt exists, insert and return!
char* get_string_from_pool(intern_pool* pool, char* literal) {
	linked_item* ptr = pool->ptr;

	for(; ptr->next != NULL; ptr = ptr->next) {
		if(!strcmp(ptr->value, literal)) {
			//printf("getting %s from pool\n", literal);
			return ptr->value;
		}
	}	

	//printf("inserting %s from pool\n", literal);
	// if we reach this point, we dont have
	// the string in the linked list yet	
	ptr->next = malloc(sizeof(linked_item));
	ptr->next->value = strdup(literal);
	ptr->next->next = NULL;
	
	return ptr->next->value;
}

int put_string_into_pool(intern_pool* pool, char* literal) {
	
}

void destroy_pool(intern_pool* pool) {
	if(pool == NULL)
		return;

	linked_item* ptr = pool->ptr, *tmp;
	
	for(; ptr != NULL; ) {
		free(ptr->value);
		tmp = ptr;
		ptr = ptr->next;
		free(tmp);		
	}
	
	free(pool);
}


