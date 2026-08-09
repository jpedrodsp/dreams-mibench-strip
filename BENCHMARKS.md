# MiBench Benchmarks: Stripped Version for DREAMS Simulation

This document provides a highly detailed overview, compilation, and execution guide for the reduced and adapted set of MiBench benchmarks used in the **DREAMS** architecture simulations.

## Table of Contents
1. [Overview and Objectives](#1-overview-and-objectives)
2. [Global Compilation Guide](#2-global-compilation-guide)
3. [General Toolchain and Architecture Requirements](#3-general-toolchain-and-architecture-requirements)
4. [Benchmark Directory Map](#4-benchmark-directory-map)
5. [Detailed Workload Specification](#5-detailed-workload-specification)
   - [Automotive Category](#automotive-category)
     - [Bitcount](#bitcount)
     - [Qsort](#qsort)
     - [Susan](#susan)
   - [Consumer Category](#consumer-category)
     - [JPEG (cjpeg/djpeg)](#jpeg-cjpegdjpeg)
   - [Network Category](#network-category)
     - [Dijkstra](#dijkstra)
     - [Patricia](#patricia)
   - [Telecommunications Category](#telecommunications-category)
     - [CRC32](#crc32)
     - [FFT](#fft)
   - [Security Category](#security-category)
     - [SHA](#sha)
6. [Known Issues & Workarounds](#6-known-issues--workarounds)

---

## 1. Overview and Objectives

The **MiBench** benchmark suite is a set of free, commercially representative embedded benchmarks. This repository contains a **stripped and optimized version** tailored specifically for the **DREAMS** simulation framework. 

Each program has been compiled statically and cross-compiled (in most cases) for the **RISC-V 64-bit Architecture (`rv64`)** to support execution inside cycle-accurate architecture simulators.

---

## 2. Global Compilation Guide

The workspace includes a global compilation script, [`compile.sh`](compile.sh), which automates the build process across all benchmark directories.

### Compilation Steps:
1. Ensure your RISC-V cross-compiler (`riscv64-unknown-linux-gnu-gcc`) is installed and available in your environment path.
2. Run the main compilation script from the repository root:
   ```bash
   ./compile.sh
   ```

The script iterates through each benchmark directory, runs a `make clean` to remove legacy artifacts, and invokes `make` to compile the targets.

---

## 3. General Toolchain and Architecture Requirements

To run, compile, and analyze these benchmarks, the environment must fulfill the following:
* **Host Compiler**: `gcc` (used for certain native targets like Susan).
* **Cross-Compiler**: `riscv64-unknown-linux-gnu-gcc` (used for RISC-V targets).
* **Compilation Flags**:
  * **`-static`**: Extremely critical. Enables static linking so that compiled binaries are self-contained and run on target simulators without requiring dynamically loaded libraries.
  * **`-O3` or `-O4`**: Enables high compiler optimizations (loop unrolling, inlining, vectorization) to reflect realistic embedded workloads.

---

## 4. Benchmark Directory Map

Below is a summary of the 9 benchmark programs included in this stripped suite:

| Category | Benchmark | Subdirectory | Primary Compiler | Binary Target | Key Workload Characteristics |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Automotive** | Bitcount | `automotive/bitcount` | RISC-V GCC | `bitcnts_riscv` | Heavy bitwise manipulations, branch testing. |
| **Automotive** | Qsort | `automotive/qsort` | RISC-V GCC | `qsort_small_riscv`<br>`qsort_large_riscv` | High memory access, sorting overhead. |
| **Automotive** | Susan | `automotive/susan` | Native GCC | `susan` | Image processing, heavy array and pointer arithmetic. |
| **Consumer** | JPEG | `consumer/jpeg/jpeg-6a` | RISC-V GCC | `cjpeg`, `djpeg` | Media encoding/decoding, floating-point/int conversions. |
| **Network** | Dijkstra | `network/dijkstra` | RISC-V GCC | `dijkstra_small_riscv`<br>`dijkstra_large_riscv` | Graph exploration, priority queues, memory bound. |
| **Network** | Patricia | `network/patricia` | RISC-V GCC | `patricia_riscv` | Prefix tree routing, bitwise shifts, random memory reads. |
| **Telecomm** | CRC32 | `telecomm/CRC32` | RISC-V GCC | `crc_riscv` | Telecomm integrity checking, table-based calculations. |
| **Telecomm** | FFT | `telecomm/FFT` | RISC-V GCC | `fft` | Floating-point heavy, Fast Fourier Transforms. |
| **Security** | SHA | `security/sha` | RISC-V GCC | `sha` | Secure Hashing Algorithm, integer operations, bitwise XORs. |

---

## 5. Detailed Workload Specification

### Automotive Category

#### Bitcount
* **Theoretical Algorithm**: Evaluates processor bit manipulation performance. It executes 7 distinct algorithms to count set bits in an array of integers (e.g., recursive bit-counting, non-recursive, table-lookup, and shift-based algorithms).
* **Core Files**: `bitcnt_1.c`, `bitcnt_2.c`, `bitcnt_3.c`, `bitcnt_4.c`, `bitcnts.c`, `bitfiles.c`, `bitstrng.c`, `bstr_i.c`, `bitops.h`.
* **RISC-V Compilation**:
  ```bash
  riscv64-unknown-linux-gnu-gcc -static <source_files> -O3 -o bitcnts_riscv
  ```
* **Execution Options**:
  * **Small Input**: `75,000` iterations.
    ```bash
    ./bitcnts_riscv 75000 > output_small.txt
    ```
  * **Large Input**: `1,125,000` iterations.
    ```bash
    ./bitcnts_riscv 1125000 > output_large.txt
    ```

---

#### Qsort
* **Theoretical Algorithm**: Sorts an array of 3-dimensional data points (representing geographic or spatial coordinates) using the standard **Quick Sort** algorithm. The points are sorted based on their distance from the origin.
* **Core Files**: `qsort_small.c`, `qsort_large.c`.
* **RISC-V Compilation**:
  * **Small Target**:
    ```bash
    riscv64-unknown-linux-gnu-gcc -static qsort_small.c -O3 -o qsort_small_riscv -lm
    ```
  * **Large Target**:
    ```bash
    riscv64-unknown-linux-gnu-gcc -static qsort_large.c -O3 -o qsort_large_riscv -lm
    ```
* **Execution Options**:
  * **Small Input**: Uses `input_small.dat` (approx. 50 KB).
    ```bash
    ./qsort_small_riscv input_small.dat > output_small.txt
    ```
  * **Large Input**: Uses `input_large.dat` (approx. 1.5 MB).
    ```bash
    ./qsort_large_riscv input_large.dat > output_large.txt
    ```

---

#### Susan
* **Theoretical Algorithm**: **S**mall **U**nimodular **S**egment **A**ssimilating **N**ucleus. An image-recognition/processing algorithm designed for low-level processing. It performs three critical operations on greyscale PGM images:
  1. Image Smoothing (`-s`)
  2. Edge Detection (`-e`)
  3. Corner Detection (`-c`)
* **Core Files**: `susan.c`.
* **Compilation Note**: Built natively by default using `gcc`:
  ```bash
  gcc -static -O4 -o susan susan.c -lm
  ```
* **Execution Options**:
  * **Small Input**: Reads `input_small.pgm`.
    ```bash
    ./susan input_small.pgm output_small.smoothing.pgm -s
    ./susan input_small.pgm output_small.edges.pgm -e
    ./susan input_small.pgm output_small.corners.pgm -c
    ```
  * **Large Input**: Reads `input_large.pgm`.
    ```bash
    ./susan input_large.pgm output_large.smoothing.pgm -s
    ./susan input_large.pgm output_large.edges.pgm -e
    ./susan input_large.pgm output_large.corners.pgm -c
    ```

---

### Consumer Category

#### JPEG (cjpeg/djpeg)
* **Theoretical Algorithm**: Performs JPEG compression (**`cjpeg`**) and decompression (**`djpeg`**). Compression encodes raw portable pixmap (PPM) images into progressive/optimized JPEGs, while decompression reconstructs the PPM from JPEG format. It exercises DCT (Discrete Cosine Transform) algorithms and quantization tables.
* **Core Directory**: `consumer/jpeg/jpeg-6a` (library and applications).
* **RISC-V Compilation**:
  * Configured via pre-generated `Makefile`:
    ```bash
    # Compiles JPEG library (libjpeg.a), cjpeg, and djpeg
    make
    ```
* **Execution Options**:
  * **Small Input**:
    ```bash
    # Encoding:
    ./jpeg-6a/cjpeg -dct int -progressive -opt -outfile output_small_encode.jpeg input_small.ppm
    # Decoding:
    ./jpeg-6a/djpeg -dct int -ppm -outfile output_small_decode.ppm input_small.jpg
    ```
  * **Large Input**:
    ```bash
    # Encoding:
    ./jpeg-6a/cjpeg -dct int -progressive -opt -outfile output_large_encode.jpeg input_large.ppm
    # Decoding:
    ./jpeg-6a/djpeg -dct int -ppm -outfile output_large_decode.ppm input_large.jpg
    ```

---

### Network Category

#### Dijkstra
* **Theoretical Algorithm**: Computes the shortest path tree from a single source node in an adjacency matrix representation of a graph using **Dijkstra's Algorithm**. 
* **Core Files**: `dijkstra_small.c`, `dijkstra_large.c`.
* **RISC-V Compilation**:
  * **Small Target**:
    ```bash
    riscv64-unknown-linux-gnu-gcc -static dijkstra_small.c -O3 -o dijkstra_small_riscv
    ```
  * **Large Target**:
    ```bash
    riscv64-unknown-linux-gnu-gcc -static dijkstra_large.c -O3 -o dijkstra_large_riscv
    ```
* **Execution Options**:
  * **Small Input**:
    ```bash
    ./dijkstra_small_riscv input.dat > output_small.dat
    ```
  * **Large Input**:
    ```bash
    ./dijkstra_large_riscv input.dat > output_large.dat
    ```

---

#### Patricia
* **Theoretical Algorithm**: Uses a **Patricia Trie** (Practical Algorithm to Retrieve Information Coded in Alphanumeric) to perform IP routing table lookups. This is highly reflective of embedded network routing processors.
* **Core Files**: `patricia.c`, `patricia_test.c`, `patricia.h`.
* **RISC-V Compilation**:
  ```bash
  riscv64-unknown-linux-gnu-gcc -static patricia.c patricia_test.c -O3 -o patricia_riscv
  ```
* **Execution Options**:
  * **Small Input**: Processes a small UDP network trace `small.udp`.
    ```bash
    ./patricia_riscv small.udp > output_small.txt
    ```
  * **Large Input**: Processes a large UDP network trace `large.udp`.
    ```bash
    ./patricia_riscv large.udp > output_large.txt
    ```

---

### Telecommunications Category

#### CRC32
* **Theoretical Algorithm**: Calculates the 32-bit Cyclic Redundancy Check (CRC-32) error-detecting checksum on an input binary file stream using a feedback polynomial matrix. 
* **Core Files**: `crc_32.c`, `crc.h`.
* **RISC-V Compilation**:
  ```bash
  riscv64-unknown-linux-gnu-gcc -static crc_32.c -O3 -o crc_riscv
  ```
* **Execution Options**:
  * **Execution syntax**: `crc_riscv <input_file>`
  * *Note: See [Known Issues](#6-known-issues--workarounds) below regarding input dataset requirements.*

---

#### FFT
* **Theoretical Algorithm**: Performs Fast Fourier Transforms (**FFT**) and inverse Fast Fourier Transforms (**IFFT**) on generated wave datasets. It serves as a benchmark for complex floating-point calculations and array indexing patterns.
* **Core Files**: `main.c`, `fftmisc.c`, `fourierf.c`, `fourier.h`.
* **RISC-V Compilation**:
  ```bash
  # Standard C compilation with math library linking:
  riscv64-unknown-linux-gnu-gcc -static -O3 main.c fftmisc.c fourierf.c -o fft -lm
  ```
* **Execution Options**:
  * **Format**: `fft <number_of_waves> <number_of_samples> [-i]`
  * **Small Input**: `4` waves and `4096` samples.
    ```bash
    ./fft 4 4096 > output_small.txt
    ./fft 4 8192 -i > output_small.inv.txt
    ```
  * **Large Input**: `8` waves and `32768` samples.
    ```bash
    ./fft 8 32768 > output_large.txt
    ./fft 8 32768 -i > output_large.inv.txt
    ```

---

### Security Category

#### SHA
* **Theoretical Algorithm**: Secure Hash Algorithm (**SHA-1**). Computes a 160-bit message digest of input files. Highly optimized with nested loop unrolling techniques.
* **Core Files**: `sha_driver.c`, `sha.c`, `sha.h`.
* **RISC-V Compilation**:
  ```bash
  riscv64-unknown-linux-gnu-gcc -O3 -static -Wall -o sha sha_driver.c sha.c
  riscv64-unknown-linux-gnu-strip sha
  ```
* **Execution Options**:
  * **Small Input**: Reads `input_small.asc`.
    ```bash
    ./sha input_small.asc > output_small.txt
    ```
  * **Large Input**: Reads `input_large.asc`.
    ```bash
    ./sha input_large.asc > output_large.txt
    ```

---

## 6. Known Issues & Workarounds

While exploring and executing this reduced/stripped version, take note of the following environment discrepancies:

### 1. Missing `adpcm` dependency in CRC32
* **Problem**: The CRC32 execution scripts (`runme_small.sh` and `runme_large.sh`) refer to a relative input path `../adpcm/data/large.pcm`. Because `adpcm` is not part of this stripped repository, the execution script will fail out-of-the-box.
* **Workaround**: You must supply your own binary/PCM files for validation, or modify the scripts to target other active binaries in the project, e.g.:
  ```bash
  # Change target inside runme_small.sh or runme_large.sh to any valid file:
  ./crc_riscv input_file.dat > output_small.txt
  ```

### 2. Native Compilation of Susan
* **Problem**: The Makefile in `automotive/susan` compiles using native `gcc` rather than `riscv64-unknown-linux-gnu-gcc`.
* **Workaround**: If you require Susan to be simulated in a RISC-V environment (such as gem5 or DREAMS), edit the Makefile in `automotive/susan/Makefile` to change the compiler definition:
  ```diff
  -gcc -static -O4 -o susan susan.c -lm
  +riscv64-unknown-linux-gnu-gcc -static -O4 -o susan_riscv susan.c -lm
  ```
