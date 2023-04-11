#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <syscall.h>
#include <unistd.h>
#include <linux/futex.h>
#include <sys/types.h>
#include <sys/syscall.h>

int main(int argc, char *argv[])
{
	struct robust_list_head *ptr = NULL;
	size_t len = 0;
	pid_t myself = gettid();
	pid_t pid;
	long rc;

	if (argc > 1)
		pid = atoi(argv[1]);
	else
		pid = myself;

	errno = 0;
	rc = syscall(SYS_get_robust_list, pid, &ptr, &len);
	if (rc != 0) {
		perror("get_robust_list");
		exit(1);
	}
	if (len == sizeof(*ptr))
		printf("%d:%d: %p (%zu)\n", myself, pid, ptr, len);
	else
		printf("%d:%d: unset\n", myself, pid);

	return 0;
}

