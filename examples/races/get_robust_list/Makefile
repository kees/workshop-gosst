CFLAGS = -Wall -O2

EXES = set_robust_list get_robust_list-race

all: $(EXES)
clean:
	rm -f *.o $(EXES)

set_robust_list: set_robust_list.c Makefile
	$(CC) -static -nostdlib $< -o $@

setuid: set_robust_list
	sudo chown root:root $<
	sudo chmod u+s $<
