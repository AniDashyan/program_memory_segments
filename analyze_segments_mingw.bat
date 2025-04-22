@echo off
:: Script to analyze segments of the binary on Windows with MinGW

set BINARY_FILE=%1

echo Segment Sizes:
size "%BINARY_FILE%"

echo Variable/Function Sections:
objdump -t "%BINARY_FILE%" | findstr "global_var_initialized global_var_uninitialized msg func main"

echo local_var: Stack
echo heap_var: Stack (pointer), Heap (memory)