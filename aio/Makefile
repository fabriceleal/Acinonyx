FLAGS=-lrt

.PHONY: clean

aio_tests: aio_tests.c
	gcc $^ -o $@ $(FLAGS)

clean:
	rm -rf aio_tests

