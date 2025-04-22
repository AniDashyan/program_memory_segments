cmake_minimum_required(VERSION 3.10)
project(program_memory_segments LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(BINARY_NAME segments)

# Detect platform and compiler
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(USE_MSVC TRUE)
        set(FILTER_COMMAND findstr)
        set(BINARY_FILE "${BINARY_NAME}.exe")
    elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(USE_MINGW TRUE)
        set(BINARY_FILE "${BINARY_NAME}.exe")
    endif()
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(USE_LINUX TRUE)
    set(BINARY_FILE "${BINARY_NAME}")
endif()

# Define executable
add_executable(${BINARY_NAME} main.cpp)

# Set optimization flags
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -g")
elseif (CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
endif()

# Analysis tools for each platform
if (USE_LINUX)
    # Default analysis target
    add_custom_target(analyze_segments
        COMMAND ${CMAKE_COMMAND} --build . --target ${BINARY_NAME} --config $<CONFIG>
        COMMAND echo "Segment Sizes:"
        COMMAND size ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_FILE}
        COMMAND echo "Variable/Function Sections:"
        COMMAND bash -c "objdump -t ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_FILE} | grep -E 'global_var_initialized|global_var_uninitialized|msg|func|main|\\.L\\.str' || true"
        COMMAND echo "local_var: Stack"
        COMMAND echo "heap_var: Stack \\(pointer\\), Heap \\(memory\\)"
        DEPENDS ${BINARY_NAME}
        COMMENT "Analyzing ELF binary on Linux/macOS with GNU tools ($<CONFIG>)"
    )

    # Optimized analysis target (-O2)
    add_custom_target(analyze_segments_O2
        COMMAND ${CMAKE_COMMAND} -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS=-O2 ${CMAKE_SOURCE_DIR}
        COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target ${BINARY_NAME} --config Release
        COMMAND echo "Segment Sizes:"
        COMMAND size ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_FILE}
        COMMAND echo "Variable/Function Sections:"
        COMMAND bash -c "objdump -t ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_FILE} | grep -E 'global_var_initialized|global_var_uninitialized|msg|func|main|\\.L\\.str' || true"
        COMMAND echo "local_var: Stack"
        COMMAND echo "heap_var: Stack \\(pointer\\), Heap \\(memory\\)"
        COMMENT "Analyzing ELF binary on Linux/macOS with GNU tools (-O2)"
    )
elseif (USE_MINGW)
    add_custom_target(analyze_segments
        COMMAND ${CMAKE_COMMAND} --build . --target ${BINARY_NAME} --config $<CONFIG>
        COMMAND echo "Segment Sizes:"
        COMMAND size ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_FILE}
        COMMAND echo "Variable/Function Sections:"
        COMMAND objdump -t ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_FILE} | findstr /R "global_var_initialized global_var_uninitialized msg func main"
        COMMAND echo "local_var: Stack"
        COMMAND echo "heap_var: Stack (pointer), Heap (memory)"
        DEPENDS ${BINARY_NAME}
        COMMENT "Analyzing PE binary on Windows with MinGW tools ($<CONFIG>)"
    )
elseif (USE_MSVC)
    add_custom_target(analyze_segments
        COMMAND ${CMAKE_COMMAND} --build . --target ${BINARY_NAME} --config $<CONFIG>
        COMMAND echo "Binary Headers:"
        COMMAND dumpbin /HEADERS ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_FILE}
        COMMAND echo "Symbol Table:"
        COMMAND dumpbin /SYMBOLS ${CMAKE_CURRENT_BINARY_DIR}/${BINARY_FILE}
        COMMAND echo "local_var: Stack"
        COMMAND echo "heap_var: Stack (pointer), Heap (memory)"
        DEPENDS ${BINARY_NAME}
        COMMENT "Analyzing PE binary on Windows with dumpbin ($<CONFIG>)"
    )
endif()