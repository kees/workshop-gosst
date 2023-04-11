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

static __inline long __syscall1(long n, long a1)
{
	unsigned long ret;
	__asm__ __volatile__ ("syscall" : "=a"(ret) : "a"(n), "D"(a1) : "rcx", "r11", "memory");
	return ret;
}

static __inline long __syscall2(long n, long a1, long a2)
{
	unsigned long ret;
	__asm__ __volatile__ ("syscall" : "=a"(ret) : "a"(n), "D"(a1), "S"(a2)
						  : "rcx", "r11", "memory");
	return ret;
}

void _start(void)
{
	unsigned long ptr = 0xC0DECAFE;
	struct timespec delay = {
               .tv_nsec = 250000,
	};
	long rc = 0;

	rc |= __syscall2(SYS_set_robust_list, ptr, sizeof(struct robust_list_head));
	rc |= __syscall2(SYS_nanosleep, (long)&delay, (long)NULL);
	__syscall1(SYS_exit, rc);
}
