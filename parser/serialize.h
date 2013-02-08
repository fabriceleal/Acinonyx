#ifndef SERIALIZE_H
#define SERIALIZE_H

#include <stdio.h>
#include <stdlib.h>
#include "common.h"

//void do_serialize_test(Hand* hand);
void open_serialize(char* filename);
void serialize(Hand* hand);
void close_serialize();

#endif
