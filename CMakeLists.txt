cmake_minimum_required(VERSION 3.5.1)

# Set paths, packages, and build settings
include(settings.cmake)

project(coLinux
    LANGUAGES C CXX ASM
    VERSION ${CO_VERSION}
)

# HostOS-specific
include(helpers/${COLINUX_HOST_OS}.cmake)

file(
    GLOB
    deps
        src/t.c
)

add_library(
    tmp
        OBJECT
        ${deps}
)
