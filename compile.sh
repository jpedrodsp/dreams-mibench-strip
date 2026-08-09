#!/bin/bash

echo "Showing GCC Version..."
gcc -v

echo "Showing GCC (RISC-V) Version..."
riscv64-unknown-linux-gnu-gcc -v

declare -a BMS_DIR=(
	"automotive/bitcount"
	"automotive/qsort"
	"automotive/susan"
	
	"consumer/jpeg/jpeg-6a/"
	
	"network/dijkstra"
	"network/patricia"
	
	"telecomm/CRC32"
	"telecomm/FFT"
	
	"security/sha")

for BM in ${BMS_DIR[@]}; do
	echo "Compiling BM in " ${BM}
	{
		cd ${BM}
		make clean
		make
		cd -
	} #&> /dev/null
done

# Centralize output binaries in dist/bin
echo "----------------------------------------------------"
echo "Centralizing compiled binaries in dist/bin..."
echo "----------------------------------------------------"

# Clean and recreate the target directory
rm -rf dist/bin
mkdir -p dist/bin

# Copy compiled binaries
cp automotive/bitcount/bitcnts_riscv dist/bin/ 2>/dev/null || true
cp automotive/qsort/qsort_small_riscv dist/bin/ 2>/dev/null || true
cp automotive/qsort/qsort_large_riscv dist/bin/ 2>/dev/null || true
cp automotive/susan/susan dist/bin/ 2>/dev/null || true
cp consumer/jpeg/jpeg-6a/cjpeg dist/bin/ 2>/dev/null || true
cp consumer/jpeg/jpeg-6a/djpeg dist/bin/ 2>/dev/null || true
cp consumer/jpeg/jpeg-6a/jpegtran dist/bin/ 2>/dev/null || true
cp consumer/jpeg/jpeg-6a/rdjpgcom dist/bin/ 2>/dev/null || true
cp consumer/jpeg/jpeg-6a/wrjpgcom dist/bin/ 2>/dev/null || true
cp network/dijkstra/dijkstra_small_riscv dist/bin/ 2>/dev/null || true
cp network/dijkstra/dijkstra_large_riscv dist/bin/ 2>/dev/null || true
cp network/patricia/patricia_riscv dist/bin/ 2>/dev/null || true
cp telecomm/CRC32/crc_riscv dist/bin/ 2>/dev/null || true
cp telecomm/FFT/fft dist/bin/ 2>/dev/null || true
cp security/sha/sha dist/bin/ 2>/dev/null || true

echo "Centralization finished! Check 'dist/bin' for outputs."
