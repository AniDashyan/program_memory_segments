@echo off
:: Script to analyze segments of the binary on Windows with MSVC

set BINARY_FILE=%1

echo Binary Headers:
dumpbin /HEADERS "%BINARY_FILE%"

echo Symbol Table:
dumpbin /SYMBOLS "%BINARY_FILE%"

echo local_var: Stack
echo heap_var: Stack (pointer), Heap (memory)