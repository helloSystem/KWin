#include <stdio.h>
#include <stdlib.h>

extern "C" {

void FNAME () {
	fprintf(stderr, "Using stub for %s\n", __func__);
}

#define QH(x) #x
#define QUOTED_FNAME QH(FNAME)
static int mark_env() {
	setenv(QUOTED_FNAME, "1", 1);
	return 222;
}

static int dummy = mark_env();

}

