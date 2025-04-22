#!/bin/bash
# Script to analyze segments of the binary

BINARY_FILE="$1"

echo "Segment Sizes:"
size "${BINARY_FILE}"

echo "Variable/Function Sections:"
objdump -t "${BINARY_FILE}" | grep -E "global_var_initialized|global_var_uninitialized|msg|func|main|.L.str" || true

echo "local_var: Stack"
echo "heap_var: Stack (pointer), Heap (memory)"s