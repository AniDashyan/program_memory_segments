cmake_minimum_required(VERSION 3.10)
project(program_memory_segments LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(BINARY_NAME segments)
if (CMAKE_SYSTEM_NAME STREQUAL "Windows")
    if (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
        set(USE_MSVC TRUE)
        set(BINARY_FILE "${BINARY_NAME}.exe")
    elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        set(USE_MINGW TRUE)
        set(BINARY_FILE "${BINARY_NAME}.exe")
    endif()
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux" OR CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(USE_LINUX TRUE)
    set(BINARY_FILE "${BINARY_NAME}")
endif()
add_executable(${BINARY_NAME} main.cpp)
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -g")
elseif (CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
endif()

# Analysis tools for each platform
if (USE_LINUX)
    # Make the script executable at configure time
    execute_process(
        COMMAND chmod +x "${CMAKE_CURRENT_SOURCE_DIR}/analyze_segments_linux.sh"
    )
    
    # Use the bash script directly
    add_custom_target(analyze_segments
        COMMAND ${CMAKE_COMMAND} --build . --target ${BINARY_NAME} --config $<CONFIG>
        COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/analyze_segments_linux.sh" "${CMAKE_CURRENT_BINARY_DIR}/${BINARY_FILE}"
        DEPENDS ${BINARY_NAME}
        COMMENT "Analyzing ELF binary on Linux/macOS with GNU tools ($<CONFIG>)"
    )
elseif (USE_MINGW)
    # For MinGW, use the batch script directly
    add_custom_target(analyze_segments
        COMMAND ${CMAKE_COMMAND} --build . --target ${BINARY_NAME} --config $<CONFIG>
        COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/analyze_segments_mingw.bat" "${CMAKE_CURRENT_BINARY_DIR}/${BINARY_FILE}"
        DEPENDS ${BINARY_NAME}
        COMMENT "Analyzing PE binary on Windows with MinGW tools ($<CONFIG>)"
    )
elseif (USE_MSVC)
    # For MSVC, use the batch script directly
    add_custom_target(analyze_segments
        COMMAND ${CMAKE_COMMAND} --build . --target ${BINARY_NAME} --config $<CONFIG>
        COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/analyze_segments_msvc.bat" "${CMAKE_CURRENT_BINARY_DIR}/$<CONFIG>/${BINARY_FILE}"
        DEPENDS ${BINARY_NAME}
        COMMENT "Analyzing PE binary on Windows with dumpbin ($<CONFIG>)"
    )
endif()