#include <stdio.h>

extern void test();
extern void run();

int main(int argc, char* argv[]) {
	if (argc != 2) {
		run();
		return 0;
	}

	if (argv[1][0] == 's') {
		run();
		return 0;
	}

	test();

	return 0;
}
