include(ExternalProject)
# Download a file to the target location
function(download_file URL ARCHIVE DOWNLOAD_TARGET SHA1)
    if(EXISTS ${DOWNLOAD_TARGET}/${ARCHIVE})
        file(SHA1
            ${DOWNLOAD_TARGET}/${ARCHIVE}
            sha1
        )
        if(${sha1} STREQUAL ${SHA1})
            message(STATUS "File `${ARCHIVE}' completed")
            return()
        endif()
    endif()

    message(STATUS "File `${ARCHIVE}' not completed, download now")
    file(DOWNLOAD
        "${URL}/${ARCHIVE}"
        "${DOWNLOAD_TARGET}/${ARCHIVE}"
        SHOW_PROGRESS
        # TLS_VERIFY ${HTTPS}
        STATUS status
        EXPECTED_HASH SHA1=${SHA1}
    )
    list(GET status 0 ret)
    # message("${CMAKE_CURRENT_FUNCTION} return: ${ret}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Failed to download ${ARCHIVE}")
    endif()
endfunction()

function(tar_unpack_to ARCHIVE TARGET_DIR)
    message(STATUS "${CMAKE_CURRENT_FUNCTION}: ${ARCHIVE}")
    file(MAKE_DIRECTORY "${TARGET_DIR}")
    execute_process(
        COMMAND tar xf "${ARCHIVE}" -C "${TARGET_DIR}"
    )
endfunction()
