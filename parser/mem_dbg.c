#include <stdlib.h>
#include <stdio.h>
#include "common.h"
#include "mem_dbg.h"

void dfree(void* ptr) {
	dprintf(".free %p", ptr);
	free(ptr);
	dprintf("=OK\n");
}

void* dmalloc(size_t size) {
	void* ret = NULL;
	dprintf(".malloc(%d)", size);
	ret = malloc(size);
	dprintf("=%p\n", ret);
	return ret;
}
