all:  dijkstra_large dijkstra_small

dijkstra_large: dijkstra_large.c Makefile
	riscv64-unknown-linux-gnu-gcc -static dijkstra_large.c -O3 -o dijkstra_large_riscv

dijkstra_small: dijkstra_small.c Makefile
	riscv64-unknown-linux-gnu-gcc -static dijkstra_small.c -O3 -o dijkstra_small_riscv 

clean:
	rm -rf dijkstra_large_riscv dijkstra_small_riscv output*
