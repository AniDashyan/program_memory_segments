# Program Memory Segments Analyzer

## Overview

This project demonstrates how different types of variables and functions are stored in distinct memory segments of a compiled C++ binary. It uses CMake to build the project and employs platform-specific tools such as `objdump`, `size`, `dumpbin`, and `findstr` (or `grep`) to inspect and print memory segment information. The project is fully cross-platform, supporting Linux, macOS, and Windows with MSVC or MinGW compilers, and integrates seamlessly with GitHub Actions CI workflows.

It provides detailed memory analysis of variables defined in `main.cpp`, identifying which segment (such as `.text`, `.data`, `.bss`, etc.) each variable or function is stored in within the binary.

## Memory Segments in a C++ Program

A compiled C++ program typically consists of several memory segments:

1. **.text** (Code Segment): Contains the compiled machine code of functions. For example, the `main()` function or user-defined functions like `func()` are stored here.

2. **.data** (Initialized Data Segment): Stores global and static variables that are explicitly initialized. E.g., `int global_var_initialized = 42;`.

3. **.bss** (Uninitialized Data Segment): Stores global and static variables that are declared but not initialized. E.g., `int global_var_uninitialized;`.

4. **.rodata** (Read-only Data): Stores read-only constants such as string literals and `const`-qualified global variables. E.g., `const char* msg = "Hello";`.

5. **Heap**: Dynamically allocated memory during program execution (e.g., `new int(20);`). Managed via `malloc`, `new`, etc.

6. **Stack**: Contains local variables declared inside functions. E.g., `int local_var = 10;`.

## Build and Run

### Prerequisites

- CMake (version 3.10 or higher)
- C++ compiler (GCC, Clang, MSVC)
- Git
- Optional tools for analysis:
  - `size`, `objdump`, `readelf` (on Linux/macOS)
  - `dumpbin`, `findstr` (on Windows with MSVC)
  - `objdump` from MinGW (on Windows with MinGW)

### Clone and Build

```bash
# Clone the repository
git clone https://github.com/AniDashyan/program_memory_segments
cd program_memory_segments

# Create build directory and run CMake
cmake -S . -B build
cmake --build build --target analyze_segments --config Relese
```

### Example Output

```
Segment Sizes:
   text    data     bss     dec     hex filename
  11456    2592     416   14464    3880 C:/Users/AniDashyan/Desktop/program_memory_segments/build/segments.exe

Variable/Function Sections:
[ 32](sec  1)(fl 0x00)(ty   20)(scl   3) (nx 0) 0x0000000000000180 __tmainCRTStartup
[ 44](sec  6)(fl 0x00)(ty    0)(scl   3) (nx 0) 0x000000000000000c mainret
[ 56](sec  1)(fl 0x00)(ty   20)(scl   2) (nx 0) 0x00000000000003e0 mainCRTStartup
[111](sec -2)(fl 0x00)(ty    0)(scl 103) (nx 1) 0x00000000000000ac main.cpp
[113](sec  1)(fl 0x00)(ty   20)(scl   2) (nx 1) 0x0000000000000430 _Z4funcv
[115](sec  1)(fl 0x00)(ty   20)(scl   2) (nx 0) 0x0000000000000437 main
[230](sec -2)(fl 0x00)(ty    0)(scl 103) (nx 1) 0x000000000000010a gccmain.c
[238](sec  1)(fl 0x00)(ty   20)(scl   2) (nx 0) 0x00000000000005d0 __main
[916](sec -2)(fl 0x00)(ty    0)(scl 103) (nx 1) 0x00000000000003b4 ucrt_amsg_exit
[918](sec  1)(fl 0x00)(ty   20)(scl   2) (nx 1) 0x0000000000001680 _amsg_exit
[948](sec -2)(fl 0x00)(ty    0)(scl 103) (nx 1) 0x00000000000003e2 ucrt__getmainargs.c
[950](sec  1)(fl 0x00)(ty   20)(scl   2) (nx 1) 0x00000000000016b0 __getmainargs
[1497](sec  6)(fl 0x00)(ty    0)(scl   2) (nx 0) 0x0000000000000030 global_var_uninitialized
[1509](sec  2)(fl 0x00)(ty    0)(scl   2) (nx 0) 0x0000000000000080 __imp__amsg_exit
[1511](sec  2)(fl 0x00)(ty    0)(scl   2) (nx 0) 0x0000000000000000 global_var_initialized
[1537](sec  2)(fl 0x00)(ty    0)(scl   2) (nx 0) 0x0000000000000008 msg
[1564](sec  2)(fl 0x00)(ty    0)(scl   2) (nx 0) 0x0000000000000024 __native_dllmain_reason
[1579](sec  2)(fl 0x00)(ty    0)(scl   2) (nx 0) 0x0000000000000090 __imp___getmainargs
[1592](sec  1)(fl 0x00)(ty   20)(scl   2) (nx 0) 0x0000000000001720 __acrt_iob_func
[1661](sec  7)(fl 0x00)(ty    0)(scl   2) (nx 0) 0x0000000000000398 __imp___acrt_iob_func
```

### Output Explanation

- The `size` command prints the total size of the `.text`, `.data`, and `.bss` segments.
- `objdump` or `dumpbin` shows symbol table entries, identifying which section each symbol (variable or function) belongs to:
  - Section `1` usually corresponds to `.text` (executable code)
  - Section `2` is often `.data` (initialized globals)
  - Section `6` commonly represents `.bss` (uninitialized globals)
  - Negative section numbers or `sec -2` represent file-level or debug entries

For example:
- `global_var_initialized` appears in section `2`, which is `.data`
- `global_var_uninitialized` appears in section `6`, which is `.bss`
- `msg` also appears in section `2`, indicating `.data` or `.rodata`
- `main` and `func` appear in section `1`, corresponding to `.text`

## Conclusion

This project provides a practical and educational demonstration of memory segmentation in C++ programs. By building and analyzing the compiled binary, you can clearly observe how different variables and functions are laid out in memory. The use of platform-specific tools makes the analysis relevant across operating systems, while CMake ensures portability and ease of integration.

