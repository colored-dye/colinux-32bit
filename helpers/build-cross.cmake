include(helpers/common.cmake)

set(BUILD_CROSS_FLAGS "CFLAGS=-O2 LDFLAGS=-s")

# Download needed packages
# for building mingw32 toolchain and libraries
function(download_cross_files)
    download_file(${MINGW_URL} ${MINGW_ARCHIVE} ${DOWNLOADS} ${MINGW_ARCHIVE_SHA1} TRUE)
    download_file(${BINUTILS_URL} ${BINUTILS_ARCHIVE} ${DOWNLOADS} ${BINUTILS_ARCHIVE_SHA1} TRUE)
    download_file(${GCC_URL} ${GCC_ARCHIVE1} ${DOWNLOADS} ${GCC_ARCHIVE1_SHA1} TRUE)
    download_file(${GCC_URL} ${GCC_ARCHIVE2} ${DOWNLOADS} ${GCC_ARCHIVE2_SHA1} TRUE)
    download_file(${W32API_URL} ${W32API_ARCHIVE} ${DOWNLOADS} ${W32API_ARCHIVE_SHA1} TRUE)
    download_file(${FLTK_URL} ${FLTK_ARCHIVE} ${DOWNLOADS} ${FLTK_ARCHIVE_SHA1} TRUE)
    download_file(${WINPCAP_URL} ${WINPCAP_ARCHIVE} ${DOWNLOADS} ${WINPCAP_ARCHIVE_SHA1} TRUE)
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
        COMMAND "../${BINUTILS}/configure" "--prefix=${PREFIX}" "--target=${TARGET}" --disable-nls
        WORKING_DIRECTORY "${BUILD_DIR}/binutils-${TARGET}"
        OUTPUT_FILE "${COLINUX_BUILD_LOG}"
        ERROR_FILE "${COLINUX_BUILD_ERR}"
        RESULT_VARIABLE ret
    )
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Configure binutils failed")
    endif()
endfunction(configure_binutils)


function(build_binutils)
    message(STATUS "Building binutils")
    execute_process(
        COMMAND make "${BUILD_CROSS_FLAGS}"
        WORKING_DIRECTORY "${BUILD_DIR}/binutils-${TARGET}"
        OUTPUT_FILE "${COLINUX_BUILD_LOG}"
        ERROR_FILE "${COLINUX_BUILD_ERR}"
        RESULT_VARIABLE ret
    )
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Build binutils failed")
    endif()
endfunction(build_binutils)


function(install_binutils)
    message(STATUS Installing binutils)
    execute_process(
        COMMAND make install
        WORKING_DIRECTORY "${BUILD_DIR}/binutils-${TARGET}"
        OUTPUT_FILE "${COLINUX_BUILD_LOG}"
        ERROR_FILE "${COLINUX_BUILD_ERR}"
        RESULT_VARIABLE ret
    )
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Install binutils failed")
    endif()
endfunction(install_binutils)


# Top level, called from winnt.cmake
function(build_cross)
    # download_cross_files()
    
    message(STATUS "log: ${COLINUX_BUILD_LOG}")
    message(STATUS "err: ${COLINUX_BUILD_ERR}")

    # install_libs()

    extract_binutils()
    configure_binutils()

endfunction(build_cross)
