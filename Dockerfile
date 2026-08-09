# Use official stable Ubuntu 22.04 LTS as the base image
FROM ubuntu:22.04

# Avoid prompt questions during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Update repository and install required packages:
# - build-essential: includes native gcc, make, and core development tools
# - gcc-riscv64-linux-gnu, g++-riscv64-linux-gnu, binutils-riscv64-linux-gnu: the official precompiled RISC-V 64-bit cross-compiler tools
# - clean up apt cache to keep the image slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc-riscv64-linux-gnu \
    g++-riscv64-linux-gnu \
    binutils-riscv64-linux-gnu \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create POSIX-compliant symlinks from riscv64-linux-gnu-* to riscv64-unknown-linux-gnu-*
# to support the exact compiler naming convention used in this project's Makefiles.
RUN for f in /usr/bin/riscv64-linux-gnu-*; do \
        name=$(basename "$f"); \
        new_name=$(echo "$name" | sed 's/riscv64-linux-gnu-/riscv64-unknown-linux-gnu-/'); \
        ln -s "$f" "/usr/bin/$new_name"; \
    done

# Set the working directory inside the container
WORKDIR /workspace

# Default command to run when the container is started
CMD ["./compile.sh"]
