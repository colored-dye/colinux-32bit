include(helpers/common.cmake)

set(BUILD_CROSS_CFLAGS "CFLAGS=-O2" CACHE STRING "" FORCE)
set(BUILD_CROSS_LDFLAGS "LDFLAGS=-s" CACHE STRING "" FORCE)
set(CHECKING "--enable-checking=release" CACHE STRING "" FORCE)
set(BINUTILS_CROSS_EXISTS OFF CACHE BOOL "" FORCE)
set(GCC_CROSS_EXISTS OFF CACHE BOOL "" FORCE)

# Download needed packages
# for building mingw32 toolchain and libraries
function(download_cross_files)
    download_file(${MINGW_URL} ${MINGW_ARCHIVE} ${DOWNLOADS} ${MINGW_ARCHIVE_SHA1})
    download_file(${BINUTILS_URL} ${BINUTILS_ARCHIVE} ${DOWNLOADS} ${BINUTILS_ARCHIVE_SHA1})
    download_file(${GCC_URL} ${GCC_ARCHIVE1} ${DOWNLOADS} ${GCC_ARCHIVE1_SHA1})
    download_file(${GCC_URL} ${GCC_ARCHIVE2} ${DOWNLOADS} ${GCC_ARCHIVE2_SHA1})
    download_file(${W32API_URL} ${W32API_ARCHIVE} ${DOWNLOADS} ${W32API_ARCHIVE_SHA1})
    download_file(${FLTK_URL} ${FLTK_ARCHIVE} ${DOWNLOADS} ${FLTK_ARCHIVE_SHA1})
    download_file(${WINPCAP_URL} ${WINPCAP_ARCHIVE} ${DOWNLOADS} ${WINPCAP_ARCHIVE_SHA1})
endfunction(download_cross_files)


# Install mingw-runtime and w32api libs to PREFIX
function(install_libs)
    message(STATUS "Installing cross libs and includes")
    tar_unpack_to(${DOWNLOADS}/${MINGW_ARCHIVE} ${PREFIX}/${TARGET})
    tar_unpack_to(${DOWNLOADS}/${W32API_ARCHIVE} ${PREFIX}/${TARGET})
endfunction(install_libs)

# Skip building if already installed
function(check_binutils)
    execute_process(
        COMMAND "${TARGET}-ld -v"
        OUTPUT_QUIET
        ERROR_QUIET
        RESULT_VARIABLE ret
    )
    if (${ret} EQUAL 0)
        set(BINUTILS_CROSS_EXISTS ON CACHE BOOL "" FORCE)
        message(STATUS "Cross binutils already installed")
    else()
        message(STATUS "Cross binutils not installed. Building now")
    endif()
endfunction(check_binutils)

function(extract_binutils)
    message(STATUS "Extracting binutils")
    file(REMOVE_RECURSE "${BUILD_DIR}/${BINUTILS}")
    tar_unpack_to(${DOWNLOADS}/${BINUTILS_ARCHIVE} ${BUILD_DIR})
endfunction(extract_binutils)


function(configure_binutils)
    message(STATUS "Configuring binutils")
    file(REMOVE_RECURSE "${BUILD_DIR}/binutils-${TARGET}")
    file(MAKE_DIRECTORY "${BUILD_DIR}/binutils-${TARGET}")
    execute_process(
        COMMAND "../${BINUTILS}/configure" "--prefix=${PREFIX}" "--target=${TARGET}" "--build=${BUILD}" --disable-nls
        WORKING_DIRECTORY "${BUILD_DIR}/binutils-${TARGET}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Configure binutils failed: ${err}")
    endif()
endfunction(configure_binutils)


function(build_binutils)
    message(STATUS "Building binutils")
    execute_process(
        COMMAND make "${BUILD_CROSS_CFLAGS}" "${BUILD_CROSS_LDFLAGS}" "-j${CPU_THREADS}"
        WORKING_DIRECTORY "${BUILD_DIR}/binutils-${TARGET}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Build binutils failed: ${err}")
    endif()
endfunction(build_binutils)


function(install_binutils)
    message(STATUS "Installing binutils")
    execute_process(
        COMMAND make install
        WORKING_DIRECTORY "${BUILD_DIR}/binutils-${TARGET}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Install binutils failed: ${err}")
    endif()
endfunction(install_binutils)

function(check_gcc)
    execute_process(
        COMMAND "${TARGET}-gcc -v"
        OUTPUT_QUIET
        ERROR_QUIET
        RESULT_VARIABLE ret
    )
    if (${ret} EQUAL 0)
        set(GCC_CROSS_EXISTS ON CACHE BOOL "" FORCE)
        message(STATUS "Cross gcc already installed")
    else()
        message(STATUS "Cross gcc not installed. Building now")
    endif()
endfunction(check_gcc)

function(extract_gcc)
    message(STATUS "Extracting gcc")
    file(REMOVE_RECURSE "${BUILD_DIR}/${GCC}")
    tar_unpack_to(${DOWNLOADS}/${GCC_ARCHIVE1} ${BUILD_DIR})
    tar_unpack_to(${DOWNLOADS}/${GCC_ARCHIVE2} ${BUILD_DIR})
endfunction(extract_gcc)

function(configure_gcc)
    message(STATUS "Configuring gcc")
    file(REMOVE_RECURSE "${BUILD_DIR}/gcc-${TARGET}")
    file(MAKE_DIRECTORY "${BUILD_DIR}/gcc-${TARGET}")
    execute_process(
        COMMAND "../${GCC}/configure" -v "--prefix=${PREFIX}" "--target=${TARGET}" "--build=${BUILD}" "--host=${BUILD}" "--with-headers=${PREFIX}/${TARGET}/include" --with-gnu-as --with-gnu-ld --disable-nls --without-newlib --disable-multilib --enable-languages=c,c++ "${CHECKING}"
        WORKING_DIRECTORY "${BUILD_DIR}/gcc-${TARGET}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Configure gcc failed: ${err}")
    endif()
endfunction(configure_gcc)

function(build_gcc)
    message(STATUS "Building gcc")
    execute_process(
        COMMAND make "${BUILD_CROSS_CFLAGS}" "${BUILD_CROSS_LDFLAGS}" "-j${CPU_THREADS}"
        WORKING_DIRECTORY "${BUILD_DIR}/gcc-${TARGET}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Building gcc failed: ${err}")
    endif()
endfunction(build_gcc)

function(install_gcc)
    message(STATUS "Installing gcc")
    execute_process(
        COMMAND make install
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Installing gcc failed: ${err}")
    endif()
endfunction(install_gcc)

# Top level, called from winnt.cmake
function(build_cross)
    download_cross_files()
    
    message(STATUS "log: ${COLINUX_BUILD_LOG}")
    message(STATUS "err: ${COLINUX_BUILD_ERR}")

    # Install mingw32 & w32api libs
    install_libs()

    # Install cross binutils
    check_binutils()
    if(NOT BINUTILS_CROSS_EXISTS)
        extract_binutils()
        configure_binutils()
        build_binutils()
        install_binutils()
    endif()

    # Install cross gcc
    check_gcc()
    if(NOT GCC_CROSS_EXISTS)
        extract_gcc()
        configure_gcc()
        build_gcc()
        install_gcc()
    endif()

endfunction(build_cross)
