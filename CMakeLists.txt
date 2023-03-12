cmake_minimum_required(VERSION 3.5.1)

include(settings.cmake)

project(coLinux
    LANGUAGES C CXX ASM
    VERSION 0.8.0
)

file(GLOB
    deps
        src/t.c
)

add_library(
    tmp
        OBJECT
        ${deps}
)
