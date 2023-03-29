include(helpers/common.cmake)

function(download_lib_files)
    message(STATUS "Downloading coLinux libs")
    download_file(${FLTK_URL} ${FLTK_ARCHIVE} ${DOWNLOADS} ${FLTK_ARCHIVE_SHA1})
    download_file(${W32API_URL} ${W32API_SRC_ARCHIVE} ${DOWNLOADS} ${W32API_SRC_ARCHIVE_SHA1})
    download_file(${WINPCAP_URL} ${WINPCAP_ARCHIVE} ${DOWNLOADS} ${WINPCAP_ARCHIVE_SHA1})
endfunction(download_lib_files)


#
# FLTK
#

function(extract_fltk)
    message(STATUS "Extracting FLTK")
    file(REMOVE_RECURSE "${BUILD_DIR}/${FLTK}")
    tar_unpack_to(${DOWNLOADS}/${FLTK_ARCHIVE} ${BUILD_DIR})
endfunction(extract_fltk)


function(patch_fltk)
    message(STATUS "Patching FLTK")
    execute_process(
        COMMAND patch -p 1
        INPUT_FILE "${USER_TOPDIR}/${FLTK_PATCH}"
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
        COMMAND ./configure "--build=${BUILD}" "--host=${TARGET}" "--prefix=${PREFIX}/${TARGET}" --without-x "CC=${TARGET}-gcc" "CXX=${TARGET}-g++"
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

    if (XISTS "${PREFIX}/${TARGET}/lib/libfltk.a")
        return()
    endif()

    extract_fltk()
    patch_fltk()
    configure_and_build_fltk()
    install_fltk()
    
endfunction(build_fltk)

#
# W32API
#

function(extract_w32api_src)
    message(STATUS "Extracting W32API source")

    file(REMOVE_RECURSE "${BUILD_DIR}/${W32API_SRC}")
    tar_unpack_to(${DOWNLOADS}/${W32API_SRC_ARCHIVE} ${BUILD_DIR})
endfunction(extract_w32api_src)


function(configure_w32api_src)
    message(STATUS "Configuring W32API source")

    execute_process(
        COMMAND ./configure "--build=${BUILD}" "--host=${TARGET}" "--prefix=${PREFIX}/${TARGET}" "CC=${TARGET}-gcc"
        WORKING_DIRECTORY "${BUILD_DIR}/${W32API_SRC}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Configure W32API source failed: ${err}")
    endif()

    message(STATUS "Compiling W32API source")
    execute_process(
        COMMAND make
        WORKING_DIRECTORY "${BUILD_DIR}/${W32API_SRC}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Compile W32API source failed: ${err}")
    endif()
endfunction(configure_w32api_src)


function(install_w32api_src)
    message(STATUS "Installing W32API source")

    execute_process(
        COMMAND make install
        WORKING_DIRECTORY "${BUILD_DIR}/${W32API_SRC}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Install W32API source failed: ${err}")
    endif()
endfunction(install_w32api_src)


function(build_w32api_src)
    message(STATUS "Building W32API from source")

    if (EXISTS "${PREFIX}/${TARGET}/lib/libwin32k.a")
        return()
    endif()

    extract_w32api_src()
    configure_w32api_src()
    install_w32api_src()

endfunction(build_w32api_src)


#
# WINPCAP
#

function(extract_winpcap)
    message(STATUS "Extracting WinPCAP")
    
    file(REMOVE_RECURSE "${BUILD_DIR}/${WINPCAP_SRC}")
    execute_process(
        COMMAND unzip "${DOWNLOADS}/${WINPCAP_SRC_ARCHIVE}"
        WORKING_DIRECTORY "${BUILD_DIR}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Extract WinPCAP failed: ${err}")
    endif()
endfunction(extract_winpcap)


function(install_winpcap)
    message(STATUS "Installing WinPCAP")

    execute_process(
        COMMAND cp -p Include/pcap.h Include/pcap-stdinc.h Include/pcap-bpf.h Include/bittypes.h Include/ip6_misc.h "${PREFIX}/${TARGET}/include"
        WORKING_DIRECTORY "${BUILD_DIR}/${WINPCAP_SRC}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Install WinPCAP headers failed: ${err}")
    endif()

    execute_process(
        COMMAND cp -p Lib/libwpcap.a "${PREFIX}/${TARGET}/lib"
        WORKING_DIRECTORY "${BUILD_DIR}/${WINPCAP_SRC}"
        OUTPUT_VARIABLE log
        ERROR_VARIABLE err
        RESULT_VARIABLE ret
    )
    file(APPEND "${COLINUX_BUILD_LOG}" "${log}")
    file(APPEND "${COLINUX_BUILD_ERR}" "${err}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Install WinPCAP library failed: ${err}")
    endif()
endfunction(install_winpcap)


function(build_winpcap)
    message(STATUS "Building WinPCAP")
    if (EXISTS "${PREFIX}/${TARGET}/lib/libwpcap.a")
        return()
    endif()

    extract_winpcap()
    install_winpcap()
endfunction(build_winpcap)


# Main entry function
function(build_colinux_libs)
    message(STATUS "Building coLinux libs")

    download_lib_files()

    build_fltk()
    build_w32api_src()
    build_winpcap()

endfunction(build_colinux_libs)
