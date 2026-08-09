# MiBench Benchmark (Stripped Version for DREAMS)

This repository contains a reduced and customized set of MiBench Benchmarks, originally sourced from the [University of Michigan MiBench website](https://vhosts.eecs.umich.edu/mibench/), optimized for **DREAMS (Dynamic Reconfigurable Array for Multi-Core Systems)** architecture simulations.

### 🧠 What is DREAMS?
**DREAMS** is a dynamic reconfigurable architecture integrated into a multi-core processor, modeled on top of the **gem5** simulator incorporating a Network-on-Chip (NoC) fabric.
* **Shared Reconfigurable Array**: It features a reconfigurable array shared among 4 processing cores, organized into 4 reconfigurable columns of 3 processing elements and 1 memory access (Load/Store) unit each.
* **Transparent Binary Translator**: It includes a dynamic, hardware-level binary translator that converts standard compiled instructions into optimized configurations for the reconfigurable array at runtime.
* **Software Compatibility**: Because of the transparent binary translator, there is zero need to rewrite or recompile benchmark software. Standard statically-linked RISC-V binaries (like those compiled in this repository) run directly and benefit from reconfigurable acceleration.

## Quick Start & Benchmarks Directory
For a highly detailed compilation, cross-compilation, and execution guide on all **9** included benchmark workloads, please refer to the main documentation file:

👉 **[BENCHMARKS.md](BENCHMARKS.md)**

### Included Workloads:
* **Automotive**: `bitcount`, `qsort`, `susan`
* **Consumer**: `jpeg` (cjpeg/djpeg)
* **Network**: `dijkstra`, `patricia`
* **Telecomm**: `CRC32`, `FFT`
* **Security**: `sha`

---
For global compilation instructions, you can run the [`compile.sh`](compile.sh) script in the root directory.

## Citation

If you use this benchmark suite in your research or publications, please cite the original MiBench paper:

* **[Original Article (IEEE Xplore)](https://ieeexplore.ieee.org/document/990739)**:
  > M. R. Guthaus, J. S. Ringenberg, D. Ernst, T. M. Austin, T. Mudge, and R. B. Brown, *"MiBench: A free, commercially representative embedded benchmark suite,"* Proceedings of the Fourth Annual IEEE International Workshop on Workload Characterization. WWC-4 (Cat. No.01EX538), Austin, TX, USA, 2001, pp. 3-14. doi: 10.1109/WWC.2001.990739.

Additionally, please cite the official DREAMS architecture dissertation if you utilize this specialized stripped suite:

* **[DREAMS Dissertation (UFPI Institutional Repository)](https://repositorio.ufpi.br/xmlui/handle/123456789/1699)**:
  > SILVA JUNIOR, Francisco Carlos. *"DREAMS - Um Array Reconfigurável Dinâmico para Sistemas Multiprocessados."* Dissertação de Mestrado, Mestrado em Ciência da Computação, Universidade Federal do Piauí (UFPI), Teresina, PI, Brasil, 2019. **[PDF Document](https://repositorio.ufpi.br/xmlui/bitstream/handle/123456789/1699/dissertacao-Versao_corrigida.pdf?sequence=1)**.

