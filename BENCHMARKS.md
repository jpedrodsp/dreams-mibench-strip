# MiBench Benchmarks: Stripped Version for DREAMS NoC Architecture (on gem5)

This document provides a highly detailed overview, compilation, and execution guide for the reduced and adapted set of MiBench benchmarks used in simulations of the **DREAMS** NoC-based reconfigurable architecture (modeled on top of gem5).

## Table of Contents
1. [Overview and Objectives](#1-overview-and-objectives)
2. [Global Compilation Guide](#2-global-compilation-guide)
3. [Global Execution Runner](#3-global-execution-runner)
4. [General Toolchain and Architecture Requirements](#4-general-toolchain-and-architecture-requirements)
5. [Benchmark Directory Map](#5-benchmark-directory-map)
6. [Detailed Workload Specification](#6-detailed-workload-specification)
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
7. [Known Issues & Workarounds](#7-known-issues--workarounds)
8. [Citation](#8-citation)


---

## 1. Overview and Objectives

The **MiBench** benchmark suite is a set of free, commercially representative embedded benchmarks, originally sourced from the [University of Michigan MiBench website](https://vhosts.eecs.umich.edu/mibench/). This repository contains a **stripped and optimized version** tailored specifically for the **DREAMS (Dynamic Reconfigurable Array for Multi-Core Systems)** architecture.

### 🧠 The DREAMS Architecture & gem5 Modeling Context
**DREAMS** is a high-performance, area-efficient dynamic reconfigurable architecture integrated into a multi-core processor. It is fully modeled and simulated on top of the **gem5** cycle-accurate simulator, incorporating a Network-on-Chip (NoC) fabric for inter-core communication and memory routing.

Key architectural highlights of DREAMS include:
* **Shared Reconfigurable Array**: Rather than attaching a dedicated reconfigurable array to each processing core (which causes high area overhead), DREAMS features a single reconfigurable array shared among all 4 processing cores.
* **Column-Based Organization**: The shared array is organized into 4 reconfigurable columns. Each column consists of:
  * **3 Processing Elements (PEs)**: Responsible for arithmetic/logic computations.
  * **1 Load and Store Unit (LSU)**: For direct, optimized memory access.
* **Hardware-Level Dynamic Binary Translator**: DREAMS incorporates an on-the-fly, hardware-level binary translator. At runtime, as a core executes native software, the binary translator transparently identifies compute-heavy instruction loops and maps them onto the shared reconfigurable columns.
* **Full Software Transparency**: Because translation and reconfiguration occur entirely in hardware at runtime, there is no need to write custom compiler backends or manually rewrite benchmark software.

Standard, statically-compiled **RISC-V 64-bit Architecture (`rv64`)** binaries—such as those centralized in this repository—are fully compatible out-of-the-box, running directly in gem5 while benefiting from the DREAMS reconfigurable acceleration.

---

The workspace includes a global compilation script, [`compile.sh`](compile.sh), which automates the build process across all benchmark directories. You can compile either natively on your host machine or via a isolated Docker container.

### Method A: Compilation using Docker (Recommended)
This is the cleanest approach, as it does not require installing compilers or libraries on your host system. It uses a lightweight Docker image with all toolchains pre-installed.

1. Ensure Docker is installed and running on your host machine.
2. Run the automatic runner script from the root directory:
   ```bash
   ./build_in_docker.sh
   ```
This script will build the Docker image (`dreams-mibench-build`), mount the current workspace directory into the container, and compile all benchmarks. The output binaries will be automatically centralized in the `dist/bin/` folder on your host machine.

### Method B: Native Compilation on Host Machine
1. Ensure your RISC-V cross-compiler (`riscv64-unknown-linux-gnu-gcc`) is installed and available in your environment path.
2. Run the main compilation script from the repository root:
   ```bash
   ./compile.sh
   ```

The build scripts iterate through each benchmark directory, run a `make clean` to remove legacy artifacts, invoke `make` to compile the targets, and centralize all successfully compiled binaries under the **`dist/bin/`** folder.

### 📁 Centralized Outputs
Regardless of the compilation method used, all compiled executable binaries are collected in:
* **`dist/bin/`**

This directory is ignored by Git and is designed to provide a clean, unified location for simulator deployment (e.g., inside the DREAMS NoC model running on gem5).

---

## 3. Global Execution Runner

The workspace includes a global execution script, [`benchmark.sh`](benchmark.sh), which automates executing the benchmark workloads across all directories.

### Usage
Run the script from the repository root, passing an optional workload size (`small` or `large`). If no workload size is provided, it defaults to `small`:

```bash
# Run all 'small' workloads (default)
./benchmark.sh small

# Run all 'large' workloads
./benchmark.sh large
```

### 💡 Execution Mechanism & gem5 Simulation Guide
Since these binaries are compiled for **RISC-V 64-bit** and **linked statically (`-static`)**, they are 100% compatible with the **gem5** simulator running in Syscall Emulation (SE) mode loaded with the **DREAMS** reconfigurable NoC architecture. 

You do not need an active QEMU installation if you are simulating these binaries inside gem5.

#### Running in gem5 Syscall Emulation (SE) Mode
You can invoke the centralized static RISC-V binaries directly from your gem5 python configurations or shell scripts using the standard `se.py` configuration template:

```bash
# General gem5 command template:
gem5.opt configs/example/se.py \
    -c <path_to_centralized_binary> \
    -o "<arguments_and_inputs>" \
    --output=<redirected_stdout_file>
```

#### 📋 gem5 Simulation Reference Table (Cheat Sheet)
Use this reference table to map the executable binary and workload arguments in your gem5 architecture scripts:

| Benchmark | Target Binary | Small Workload Arguments (`-o`) | Large Workload Arguments (`-o`) | Input File Path |
| :--- | :--- | :--- | :--- | :--- |
| **Bitcount** | `dist/bin/bitcnts_riscv` | `"75000"` | `"1125000"` | *None (algorithmic)* |
| **Qsort** | `dist/bin/qsort_small_riscv` (small)<br>`dist/bin/qsort_large_riscv` (large) | `"automotive/qsort/input_small.dat"` | `"automotive/qsort/input_large.dat"` | Located in `automotive/qsort/` |
| **Susan** | `dist/bin/susan` *(if compiled for RISCV)* | `"automotive/susan/input_small.pgm output_small.smoothing.pgm -s"` | `"automotive/susan/input_large.pgm output_large.smoothing.pgm -s"` | Located in `automotive/susan/` |
| **JPEG Encode** | `dist/bin/cjpeg` | `"-dct int -progressive -opt -outfile output_small_encode.jpg consumer/jpeg/input_small.ppm"` | `"-dct int -progressive -opt -outfile output_large_encode.jpg consumer/jpeg/input_large.ppm"` | Located in `consumer/jpeg/` |
| **JPEG Decode** | `dist/bin/djpeg` | `"-dct int -ppm -outfile output_small_decode.ppm consumer/jpeg/output_small_encode.jpg"` | `"-dct int -ppm -outfile output_large_decode.ppm consumer/jpeg/output_large_encode.jpg"` | Generated dynamically |
| **Dijkstra** | `dist/bin/dijkstra_small_riscv` (small)<br>`dist/bin/dijkstra_large_riscv` (large) | `"network/dijkstra/input_small"` | `"network/dijkstra/input_large"` | Located in `network/dijkstra/` |
| **Patricia** | `dist/bin/patricia_riscv` | `"network/patricia/small.udp"` | `"network/patricia/large.udp"` | Located in `network/patricia/` |
| **CRC32** | `dist/bin/crc_riscv` | `"telecomm/CRC32/input_small.pcm"` | `"telecomm/CRC32/input_large.pcm"` | *Custom PCM files (adpcm missing)* |
| **FFT** | `dist/bin/fft` | `"4 4096"` | `"8 32768"` | *None (algorithmic)* |
| **SHA** | `dist/bin/sha` | `"security/sha/input_small.dat"` | `"security/sha/input_large.dat"` | Located in `security/sha/` |

---

### 📂 Centralized Execution Outputs
Regardless of where you run the execution scripts, **`benchmark.sh`** automatically cleans, prepares, and populates a centralized **`output/`** directory at the project root. 
To prevent name collisions between different benchmarks (as most of them generate files named `output_small.txt` or `output_large.txt`), all files moved to the `output/` directory are prefixed with their respective benchmark's subdirectory name:
* **`output/<benchmark_name>_<original_filename>`**

Examples of generated outputs in `output/`:
* `output/bitcount_output_small.txt`
* `output/qsort_output_small.txt`
* `output/jpeg_output_small_encode.jpg`
* `output/dijkstra_output_small.txt`

This directory is ignored by Git to prevent committing execution files.

---

## 4. General Toolchain and Architecture Requirements

To run, compile, and analyze these benchmarks, the environment must fulfill the following:
* **Host Compiler**: `gcc` (used for certain native targets like Susan).
* **Cross-Compiler**: `riscv64-unknown-linux-gnu-gcc` (used for RISC-V targets).
* **Compilation Flags**:
  * **`-static`**: Extremely critical. Enables static linking so that compiled binaries are self-contained and run on target simulators without requiring dynamically loaded libraries.
  * **`-O3` or `-O4`**: Enables high compiler optimizations (loop unrolling, inlining, vectorization) to reflect realistic embedded workloads.

---

## 5. Benchmark Directory Map

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

## 6. Detailed Workload Specification

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

## 7. Known Issues & Workarounds

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
* **Workaround**: If you require Susan to be simulated in a RISC-V environment (such as the DREAMS NoC model on gem5), edit the Makefile in `automotive/susan/Makefile` to change the compiler definition:
  ```diff
  -gcc -static -O4 -o susan susan.c -lm
  +riscv64-unknown-linux-gnu-gcc -static -O4 -o susan_riscv susan.c -lm
  ```

---

## 8. Citation

If you use this benchmark suite in your research or publications, please cite the original MiBench paper:

* **[Original Article (IEEE Xplore)](https://ieeexplore.ieee.org/document/990739)**:
  > M. R. Guthaus, J. S. Ringenberg, D. Ernst, T. M. Austin, T. Mudge, and R. B. Brown, *"MiBench: A free, commercially representative embedded benchmark suite,"* Proceedings of the Fourth Annual IEEE International Workshop on Workload Characterization. WWC-4 (Cat. No.01EX538), Austin, TX, USA, 2001, pp. 3-14. doi: 10.1109/WWC.2001.990739.

