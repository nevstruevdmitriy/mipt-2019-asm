#include <stdio.h>

void test();
void run(const char * format, ...);


int main(int argc, char* argv[]) {
	if (argc != 2 || argv[1][0] == 's') {
		run("hmm, %d dec = %b binary and %s, and I %s %x %d %% %c\n", 
				113113,
				113113,
				"it's not surprising\n",
				"love\n",
				3802,
				100,
				31);
		return 0;
	}

	test();

	return 0;
}
