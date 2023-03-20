include(helpers/common.cmake)

function(download_lib_files)
    message(STATUS "Downloading coLinux libs")
    download_file(${FLTK_URL} ${FLTK_ARCHIVE} ${DOWNLOADS} ${FLTK_ARCHIVE_SHA1})
    download_file(${W32API_SRC_ARCHIVE} ${W32API_URL} ${DOWNLOADS} ${W32API_SRC_ARCHIVE_SHA1})
    download_file(${WINPCAP_URL} ${WINPCAP_ARCHIVE} ${DOWNLOADS} ${WINPCAP_ARCHIVE_SHA1})
endfunction(download_lib_files)


function(extract_fltk)
    message(STATUS "Extracting FLTK")
    file(REMOVE_RECURSE "${BUILD_DIR}/${FLTK}")
    tar_unpack_to(${DOWNLOADS}/${FLTK_ARCHIVE} ${BUILD_DIR})
endfunction(extract_fltk)


function(patch_fltk)
    message(STATUS "Patching FLTK")
    execute_process(
        COMMAND patch -p1 < "${USER_TOPDIR}/${FLTK_PATCH}"
        WORKING_DIRECTORY "${BUILD_DIR}/${FLTK}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Patch FLTK failed: ${err}")
    endif()
endfunction(patch_fltk)


function(configure_and_build_fltk)
    message(STATUS "Configuring FLTK")
    execute_process(
        COMMAND ./configure "--build=${BUILD}" "--host=${TARGET}" "--prefix=${PREFIX}/${TARGET}" --without-x
        WORKING_DIRECTORY "${BUILD_DIR}/${FLTK}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Configure FLTK failed: ${err}")
    endif()

    message(STATUS "Compiling FLTK")
    execute_process(
        COMMAND make -C src
        WORKING_DIRECTORY "${BUILD_DIR}/${FLTK}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Compile FLTK failed: ${err}")
    endif()
endfunction(configure_and_build_fltk)


function(install_fltk)
    message(STATUS "Installing FLTK")
    execute_process(
        COMMAND make -C src install
        WORKING_DIRECTORY "${BUILD_DIR}/${FLTK}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Install FLTK core lib failed: ${err}")
    endif()

    execute_process(
        COMMAND make -C FL install
        WORKING_DIRECTORY "${BUILD_DIR}/${FLTK}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Install FLTK FL lib failed: ${err}")
    endif()
endfunction(install_fltk)


function(build_fltk)
    message(STATUS "Building FLTK")
    
    execute_process(
        COMMAND grep "${FLTK}-win32.diff" "${W32LIBS_CHECKSUM}" | md5sum -c - >/dev/null 2>&1
        OUTPUT_QUIET
        ERROR_QUIET
        RESULT_VARIABLE ret
    )
    if (${ret} EQUAL 0 
        AND EXISTS "${PREFIX}/${TARGET}/lib/libfltk.a")
        return()
    endif()

    extract_fltk()
    patch_fltk()
    configure_and_build_fltk()
    install_fltk()
    
endfunction(build_fltk)


function(build_colinux_libs)
    message(STATUS "Building coLinux libs")

    download_lib_files()

    build_fltk()

endfunction(build_colinux_libs)

