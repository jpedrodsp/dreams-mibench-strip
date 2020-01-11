FILE1 = qsort_small.c
FILE2 = qsort_large.c

all: qsort_small qsort_large

qsort_small: qsort_small.c Makefile
	riscv64-unknown-linux-gnu-gcc -static qsort_small.c -O3 -o qsort_small_riscv -lm
qsort_large: qsort_large.c Makefile
	riscv64-unknown-linux-gnu-gcc -static qsort_large.c -O3 -o qsort_large_riscv -lm

clean:
	rm -rf qsort_small_riscv qsort_large_riscv output*
