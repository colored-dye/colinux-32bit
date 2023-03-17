set(COLINUX_HOST_OS "winnt" CACHE BOOL "" FORCE)

# Cross-compile mingw32 toolchain
set(CMAKE_TOOLCHAIN_FILE "helpers/Toolchain-mingw.cmake" CACHE BOOL "" FORCE)
include(${CMAKE_TOOLCHAIN_FILE})

include(helpers/common.cmake)
include(helpers/build-cross.cmake)

# Build cross compile toolchain
build_cross()
