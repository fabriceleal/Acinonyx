#!/bin/bash

valgrind --leak-check=full --show-reachable=yes --track-origins=yes ./poker $1 $2