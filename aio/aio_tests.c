#include <aio.h>
#include <stdlib.h>
#include <strings.h>
#include <stdio.h>
#include <errno.h>

const int BUFF_SIZE = 2048;

void aio_completion_handler(sigval_t sigval);

int main(int argc, char** argv) {
	int f_in; 
	//char c;
	struct aiocb aio_cb;

	// open file, suicide if fails
	if( 0 >= (f_in = open("tests/0.txt", O_RDONLY)) ) {
		perror("Error on open file\n");
	}
	
	// init aio_cb
	bzero(&aio_cb, sizeof(struct aiocb));

	// allocate a data buf for the request
	if( NULL == (aio_cb.aio_buf = malloc(BUFF_SIZE + 1)) ) {
		perror("Error malloc'ing\n");
	}

	// init buffer
	bzero((void*) aio_cb.aio_buf, BUFF_SIZE + 1);

	aio_cb.aio_fildes = f_in;
	aio_cb.aio_nbytes = BUFF_SIZE;
	aio_cb.aio_offset = 0;

	// set up thread callback
	aio_cb.aio_sigevent.sigev_notify = SIGEV_THREAD;
	aio_cb.aio_sigevent.sigev_notify_function = aio_completion_handler;
	aio_cb.aio_sigevent.sigev_notify_attributes = NULL;
	aio_cb.aio_sigevent.sigev_value.sival_ptr = &aio_cb;

	if( 0 > (aio_read(&aio_cb)) ) {
		perror("Error aio_read'ing\n");
	}

	//while( EINPROGRESS == aio_error(&aio_cb) );

	getchar();

	return 0;
}

void aio_completion_handler(sigval_t sigval) {
	struct aiocb *req;
	ssize_t r_bytes;
	
	req = (struct aiocb*) sigval.sival_ptr;
	
	// request complete?
	if( 0 == aio_error(req) ) {
		if( 0 >= (r_bytes = aio_return(req)) ) {
			//		printf("%d\n", EINPROGRESS);
			printf("Error: aio_returning: %s\n", strerror(aio_error(req)) );
			//perror("Error aio_return'ing\n");
		} else {
			//printf("Read ok (%d)\n", r_bytes);
			printf("'%s'", (char*) req->aio_buf);
		}
	}
}
