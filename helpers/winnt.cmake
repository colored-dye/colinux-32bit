set(COLINUX_HOST_OS "winnt" CACHE BOOL "" FORCE)

include(helpers/common.cmake)
include(helpers/build-cross.cmake)

# Build cross compile toolchain
build_cross()

# Cross-compile mingw32 toolchain
set(CMAKE_TOOLCHAIN_FILE "helpers/Toolchain-mingw.cmake" CACHE BOOL "" FORCE)
include(${CMAKE_TOOLCHAIN_FILE})

execute_process(
    COMMAND ${TARGET}-gcc -v
    RESULT_VARIABLE ret
)
if (${ret} EQUAL 0)
    message(STATUS "Cross toolchain built.")
else()
    message(FATAL_ERROR "Failed to build cross toolchain. Aborting...")
endif()
