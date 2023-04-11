#define _GNU_SOURCE
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <syscall.h>
#include <unistd.h>
#include <linux/futex.h>
#include <sys/types.h>
#include <sys/syscall.h>
#include <sys/wait.h>


void launch(void)
{
	pid_t pid;

	pid = fork();
	if (pid < 0) {
		perror("fork");
		exit(1);
	} else if (pid == 0) {
		/* Child process */
		/*
		unsigned long ptr = 0xC0DECAFE;

		syscall(SYS_set_robust_list, ptr, sizeof(struct robust_list_head));
		*/
		printf(".");
		fflush(NULL);
		execl("./set_robust_list", "set_robust_list", NULL);

		_exit(2);
	}

	/* Parent process */
	for (;;) {
		int waitrc, status;
		void *seen = NULL;

		for (;;) {
			struct robust_list_head *ptr = NULL;
			size_t len;

			errno = 0;
			len = 0;
			syscall(SYS_get_robust_list, pid, &ptr, &len);
			if (errno == ESRCH || errno == EPERM) {
				/* Child gone or we lost permissions check race. */
				break;
			}
			if (errno != 0 || len != sizeof(*ptr)) {
				perror("get_robust_list");
				exit(1);
			}
			/* Ignore post-fork clearing. */
			if (ptr == NULL) {
				//printf("ignored\n");
				continue;
			}
			/* Ignore first post-fork glibc setup. */
			if (seen == NULL) {
				seen = ptr;
				//printf("saw %p\n", seen);
				continue;
			}
			/* Report if the value changes! */
			if (ptr != seen) {
				printf("LEAKED: %p\n", ptr);
				exit(0);
			}
		}

		/* Reap child. */
		waitrc = waitpid(pid, &status, WNOHANG);
		if (waitrc == pid) {
			/* Child died. */
			return;
		}
		if (waitrc == 0) {
			/* Child still running. */
			continue;
		}
		perror("waitpid");
		exit(3);
	}
}

int main(int argc, char *argv[])
{
	for (;;) {
		launch();
	}

	return 0;
}

