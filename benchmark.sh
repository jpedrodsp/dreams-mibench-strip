#!/bin/bash

# Configuration and setup
WORKLOAD="small" # Default workload is 'small'
if [ "$1" = "large" ] || [ "$1" = "small" ]; then
    WORKLOAD="$1"
fi

echo "=========================================================="
echo " Starting DREAMS MiBench Benchmark Suite Execution Runner"
echo " Workload: ${WORKLOAD^^}"
echo "=========================================================="

# Clean and recreate root-level output directory
echo "Preparing centralized 'output/' directory..."
rm -rf output
mkdir -p output

# Ensure current directory is in PATH for execution of local binaries
export PATH=".:$PATH"

# List of benchmarks with their relative directories and executable mappings (original_name -> compiled_name)
# Format: "directory;original_binary_name;compiled_binary_name"
declare -a BENCHMARKS=(
    "automotive/bitcount;bitcnts;bitcnts_riscv"
    "automotive/qsort;qsort_small;qsort_small_riscv"
    "automotive/qsort;qsort_large;qsort_large_riscv"
    "automotive/susan;susan;susan"
    "consumer/jpeg;cjpeg;jpeg-6a/cjpeg"
    "consumer/jpeg;djpeg;jpeg-6a/djpeg"
    "network/dijkstra;dijkstra_small;dijkstra_small_riscv"
    "network/dijkstra;dijkstra_large;dijkstra_large_riscv"
    "network/patricia;patricia;patricia_riscv"
    "telecomm/CRC32;crc;crc_riscv"
    "telecomm/FFT;fft;fft"
    "security/sha;sha;sha"
)

# Keep track of execution results
SUCCESS_COUNT=0
FAILED_COUNT=0
SKIPPED_COUNT=0

# Create symlinks for legacy naming compatibility
create_symlinks() {
    local dir=$1
    local orig=$2
    local comp=$3

    cd "$dir"
    # Only create a symlink if the original name doesn't exist and the compiled target exists
    if [ "$orig" != "$comp" ] && [ ! -f "$orig" ] && [ -f "$comp" ]; then
        # Handle cases where compiled target is in a subdirectory (like jpeg-6a/cjpeg)
        ln -sf "$comp" "$orig"
    fi
    cd - > /dev/null
}

# Remove temporary symlinks
cleanup_symlinks() {
    local dir=$1
    local orig=$2
    local comp=$3

    cd "$dir"
    if [ "$orig" != "$comp" ] && [ -L "$orig" ]; then
        rm -f "$orig"
    fi
    cd - > /dev/null
}

# Run execution loop
for BM_ENTRY in "${BENCHMARKS[@]}"; do
    IFS=";" read -r DIR ORIG COMP <<< "$BM_ENTRY"
    
    # Extract benchmark name from directory path
    BM_NAME=$(basename "$DIR")
    
    echo "----------------------------------------------------------"
    echo "▶️ Benchmark: ${BM_NAME^^} (${ORIG})"
    
    # Check if runme script exists
    RUNME_SCRIPT="${DIR}/runme_${WORKLOAD}.sh"
    if [ ! -f "$RUNME_SCRIPT" ]; then
        echo "⚠️ Warning: Run script not found at ${RUNME_SCRIPT}. Skipping."
        SKIPPED_COUNT=$((SKIPPED_COUNT + 1))
        continue
    fi

    # Create temporary symlink if needed for running original runme scripts
    create_symlinks "$DIR" "$ORIG" "$COMP"

    # Start timer
    START_TIME=$(date +%s.%N)

    # Execute the runme script
    echo "🏃 Executing runme_${WORKLOAD}.sh..."
    set +e
    (
        cd "$DIR"
        chmod +x "runme_${WORKLOAD}.sh"
        ./"runme_${WORKLOAD}.sh"
    )
    EXIT_CODE=$?
    set -e

    # Clean up temporary symlink
    cleanup_symlinks "$DIR" "$ORIG" "$COMP"

    # Move produced output files to output/ with benchmark prefix to avoid collisions
    find "$DIR" -maxdepth 1 -name "output*" ! -name "*.sh" -type f | while read -r filepath; do
        filename=$(basename "$filepath")
        mv "$filepath" "output/${BM_NAME}_${filename}"
    done

    # End timer
    END_TIME=$(date +%s.%N)
    
    # Calculate duration
    if command -v bc &> /dev/null; then
        DURATION=$(echo "$END_TIME - $START_TIME" | bc 2>/dev/null)
    else
        # Fallback to integer seconds if 'bc' is not available
        START_SEC=${START_TIME%.*}
        END_SEC=${END_TIME%.*}
        DURATION=$((END_SEC - START_SEC))
    fi

    if [ $EXIT_CODE -eq 0 ]; then
        echo "✅ Success! (Time: ${DURATION}s)"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "❌ Failed! (Exit Code: ${EXIT_CODE})"
        echo "💡 Note: If running on a non-RISCV host, ensure 'qemu-user' or 'binfmt_misc' is enabled for RISC-V binaries."
        FAILED_COUNT=$((FAILED_COUNT + 1))
    fi
done

echo "=========================================================="
echo " Execution Summary"
echo "=========================================================="
echo " Total Benchmarks: $((SUCCESS_COUNT + FAILED_COUNT + SKIPPED_COUNT))"
echo " Successful:      ${SUCCESS_COUNT}"
echo " Failed:          ${FAILED_COUNT}"
echo " Skipped:         ${SKIPPED_COUNT}"
echo "=========================================================="
