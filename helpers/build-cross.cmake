include(helpers/common.cmake)

set(BUILD_CROSS_CFLAGS "CFLAGS=-O2")
set(BUILD_CROSS_LDFLAGS "LDFLAGS=-s")
set(CHECKING "--enable-checking=release")

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
        message(FATAL_ERROR "Configure binutils failed")
    endif()
endfunction(configure_binutils)


function(build_binutils)
    message(STATUS "Building binutils")
    execute_process(
        COMMAND make "${BUILD_CROSS_CFLAGS}" "${BUILD_CROSS_LDFLAGS}"
        WORKING_DIRECTORY "${BUILD_DIR}/binutils-${TARGET}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Build binutils failed")
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
        message(FATAL_ERROR "Install binutils failed")
    endif()
endfunction(install_binutils)

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
        message(FATAL_ERROR "Configure gcc failed")
    endif()
endfunction(configure_gcc)

function(build_gcc)
    message(STATUS "Building gcc")
    execute_process(
        COMMAND make "${BUILD_CROSS_CFLAGS}" "${BUILD_CROSS_LDFLAGS}"
        WORKING_DIRECTORY "${BUILD_DIR}/gcc-${TARGET}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Building gcc failed")
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
        message(FATAL_ERROR "Installing gcc failed")
    endif()
endfunction(install_gcc)

# Top level, called from winnt.cmake
function(build_cross)
    # download_cross_files()
    
    message(STATUS "log: ${COLINUX_BUILD_LOG}")
    message(STATUS "err: ${COLINUX_BUILD_ERR}")

    # Install mingw32 & w32api libs
    # install_libs()

    # Install cross binutils
    # extract_binutils()
    # configure_binutils()
    # build_binutils()
    # install_binutils()

    # Install cross gcc
    # extract_gcc()
    # configure_gcc()
    # build_gcc()
    # install_gcc()

endfunction(build_cross)
