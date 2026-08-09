# MiBench Benchmark (Stripped Version for Dreams)

This repository contains a reduced and customized set of MiBench Benchmarks, originally sourced from the [University of Michigan MiBench website](https://vhosts.eecs.umich.edu/mibench/), optimized for the **DREAMS** architecture simulations.

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

