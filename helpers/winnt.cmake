set(COLINUX_HOST_OS "winnt" CACHE BOOL "" FORCE)
list(APPEND CMAKE_PROGRAM_PATH "${PREFIX}/bin")
message(STATUS "CMAKE_PROGRAM_PATH: ${CMAKE_PROGRAM_PATH}")

set(CMAKE_TOOLCHAIN_FILE "helpers/Toolchain-mingw.cmake" CACHE BOOL "" FORCE)
include(${CMAKE_TOOLCHAIN_FILE})


include(helpers/download.cmake)
