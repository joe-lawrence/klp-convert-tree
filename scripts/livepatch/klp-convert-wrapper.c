#include <stdlib.h>
#include <string.h>
#include <limits.h>

#define WRAPPER "valgrind --quiet --error-exitcode=1 --leak-check=full"
char cmd[PATH_MAX];

int main(int argc, char **argv)
{
	int ret;

	strcpy(cmd, WRAPPER);
	for (int i=1; i<argc; i++) {
		strcat(cmd, " ");
		strcat(cmd, argv[i]);
	}

	ret = system(cmd);
	if (WIFEXITED(ret))
		return WEXITSTATUS(ret);

	return 1;
}
