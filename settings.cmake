cmake_minimum_required(VERSION 3.5.1)

set(COLINUX_HOST_OS "winnt" CACHE BOOL "" FORCE)
set(USER_TOPDIR "${CMAKE_CURRENT_LIST_DIR}" CACHE BOOL "" FORCE)
set(DOWNLOADS "${USER_TOPDIR}/download" CACHE BOOL "" FORCE)
set(BUILD_DIR "${USER_TOPDIR}/build" CACHE BOOL "" FORCE)
set(PREFIX "${USER_TOPDIR}/mingw32" CACHE BOOL "" FORCE)
set(COLINUX_KERNEL_UNTAR FALSE CACHE BOOL "" FORCE)
set(COLINUX_KERNEL_STRIP FALSE CACHE BOOL "" FORCE)
# set(COLINUX_DEPMOD /sbin/depmod CACHE BOOL "" FORCE)
set(TARGET "i686-pc-mingw32" CACHE STRING "" FORCE)
set(BUILD "i686-linux-gnu" CACHE STRING "" FORCE)
set(TARGE_ARCH "i386" CACHE STRING "" FORCE)

file(READ "src/colinux/VERSION" CO_VERSION)
message(STATUS "coLinux version: ${CO_VERSION}")

#
# GCC guest compiler prefix & toolchain
#
set(COLINUX_GCC_GUEST_TARGET "i686-co-linux" CACHE BOOL "" FORCE)
set(COLINUX_GCC_GUEST_PATH "${PREFIX}/${COLINUX_GCC_GUEST_TARGET}/bin")


#
# Kernel related
#
set(KERNEL_VERSION "2.6.33")
string(REPLACE "." ";" VERSION_LIST ${KERNEL_VERSION})
list(GET VERSION_LIST 0 KERNEL_VERSION_MAJOR)
list(GET VERSION_LIST 1 KERNEL_VERSION_MINOR)
set(KERNEL_DIR "${KERNEL_VERSION_MAJOR}.${KERNEL_VERSION_MINOR}" CACHE STRING "" FORCE)
set(KERNEL "linux-${KERNEL_VERSION}" CACHE STRING "" FORCE)
set(KERNEL_URL "https://www.kernel.org/pub/linux/kernel/${KERNEL_DIR}" CACHE STRING "" FORCE)

set(COMPLETE_KERNEL_NAME "${KERNEL_VERSION}-co-${CO_VERSION}" CACHE STRING "" FORCE)

# set(COLINUX_TARGET_KERNEL_PATH "${BUILD_DIR}/${KERNEL}")
set(COLINUX_TARGET_KERNEL_SOURCE "${BUILD_DIR}/${KERNEL}-source" CACHE BOOL "" FORCE)
set(COLINUX_TARGET_KERNEL_BUILD "${BUILD_DIR}/${KERNEL}-build" CACHE BOOL "" FORCE)
set(COLINUX_TARGET_MODULE_PATH "${COLINUX_TARGET_KERNEL_BUILD}/_install" CACHE BOOL "" FORCE)
# set(COLINUX_HOST_KERNEL_DIR /lib/modules/`uname -r`/build CACHE BOOL "" FORCE)
set(COLINUX_INSTALL_DIR "${USER_TOPDIR}/dist" CACHE BOOL "" FORCE)


#
# Packages
#
set(MINGW_VERSION "3.14" CACHE STRING "" FORCE)
set(MINGW "mingw-runtime-${MINGW_VERSION}" CACHE STRING "" FORCE)
set(MINGW_URL "https://sourceforge.net/projects/mingw/files/OldFiles/${MINGW}" CACHE STRING "" FORCE)
set(MINGW_ARCHIVE "${MINGW}.tar.gz" CACHE STRING "" FORCE)
set(MINGW_ARCHIVE_SHA1 "ebd523dff5cb5bc476124a283b3ba9781f907fea" CACHE STRING "" FORCE)

set(BINUTILS_VERSION "2.19.1" CACHE STRING "" FORCE)
set(BINUTILS_URL "https://ftp.gnu.org/pub/gnu/binutils" CACHE STRING "" FORCE)
set(BINUTILS "binutils-${BINUTILS_VERSION}" CACHE STRING "" FORCE)
set(BINUTILS_ARCHIVE "${BINUTILS}.tar.bz2")
set(BINUTILS_ARCHIVE_SHA1 "3d3aa0a586dde416b1883d245f51c2335b621e3d" CACHE STRING "" FORCE)

set(GCC_VERSION "4.1.2" CACHE STRING "" FORCE)
set(GCC "gcc-${GCC_VERSION}" CACHE STRING "" FORCE)
set(GCC_ARCHIVE1 "gcc-core-${GCC_VERSION}.tar.bz2" CACHE STRING "" FORCE)
set(GCC_ARCHIVE1_SHA1 "d6875295f6df1bec4a6f4ab8f0da54bfb8d97306" CACHE STRING "" FORCE)
set(GCC_ARCHIVE2 "gcc-g++-${GCC_VERSION}.tar.bz2" CACHE STRING "" FORCE)
set(GCC_URL "https://ftp.gnu.org/pub/gnu/gcc/${GCC}" CACHE STRING "" FORCE)
set(GCC_ARCHIVE2_SHA1 "e29c6e151050f8b5ac5d680b99483df522606143" CACHE STRING "" FORCE)

set(W32API_VERSION "3.13" CACHE STRING "" FORCE)
set(W32API "w32api-${W32API_VERSION}-mingw32" CACHE STRING "" FORCE)
set(W32API_URL "https://sourceforge.net/projects/mingw/files/OldFiles/w32api-${W32API_VERSION}" CACHE STRING "" FORCE)
set(W32API_ARCHIVE "${W32API}-dev.tar.gz" CACHE STRING "" FORCE)
set(W32API_ARCHIVE_SHA1 "5eb7d8ec0fe032a92bea3a2c8282a78df2f1793c" CACHE STRING "" FORCE)

set(FLTK_VERSION "1.1.10" CACHE STRING "" FORCE)
set(FLTK "fltk-${FLTK_VERSION}" CACHE STRING "" FORCE)
set(FLTK_URL "https://www.fltk.org/pub/fltk/${FLTK_VERSION}" CACHE STRING "" FORCE)
set(FLTK_ARCHIVE "${FLTK}-source.tar.bz2" CACHE STRING "" FORCE)
set(FLTK_ARCHIVE_SHA1 "0d2b34fede91fa78eeaefb893dd70282f73908a8" CACHE STRING "" FORCE)
set(FLTK_PATCH "patch/${FLTK}.diff" CACHE STRING "" FORCE)

set(WINPCAP_VERSION "4.0.1" CACHE STRING "" FORCE)
set(WINPCAP_SRC "WpdPack" CACHE STRING "" FORCE)
set(WINPCAP_URL "https://www.winpcap.org/archive" CACHE STRING "" FORCE)
set(WINPCAP_SRC_ARCHIVE "${WINPCAP_VERSION}-${WINPCAP_SRC}.zip" CACHE STRING "" FORCE)
set(WINPCAP_ARCHIVE "${WINPCAP_SRC_ARCHIVE}" CACHE STRING "" FORCE)
set(WINPCAP_ARCHIVE_SHA1 "e754575c572de63d35afb0205c4b5b79e8f68cf5" CACHE STRING "" FORCE)

#
# Logs
#
string(
    RANDOM
    ALPHABET 0123456789
    LENGTH 4
    RAND_ID
)
set(COLINUX_BUILD_LOG "${USER_TOPDIR}/log/build-colinux-${RAND_ID}.log" CACHE BOOL "" FORCE)
set(COLINUX_BUILD_ERR "${USER_TOPDIR}/log/build-colinux-${RAND_ID}.err" CACHE BOOL "" FORCE)
file(MAKE_DIRECTORY "${USER_TOPDIR}/log")
execute_process(
    COMMAND touch "${COLINUX_BUILD_LOG}"
    COMMAND touch "${COLINUX_BUILD_ERR}"
)

#
# Checksum settings, used to track build changes
#
set(MD5DIR ${BUILD_DIR} CACHE STRING "" FORCE)
set(W32LIBS_CHECKSUM "${MD5DIR}/.build-colinux-libs.md5" CACHE BOOL "" FORCE)
set(KERNEL_CHECKSUM "${MD5DIR}/.build-kernel.md5" CACHE STRING "" FORCE)

#
# Set cross compile path
#
list(APPEND CMAKE_PROGRAM_PATH "${PREFIX}/bin")
message(STATUS "CMAKE_PROGRAM_PATH: ${CMAKE_PROGRAM_PATH}")
