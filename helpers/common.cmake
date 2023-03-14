include(ExternalProject)
# Download a file to the target location
function(download_file URL ARCHIVE DOWNLOAD_TARGET SHA1 HTTPS)
    if(EXISTS ${DOWNLOAD_TARGET}/${ARCHIVE})
        file(SHA1
            ${DOWNLOAD_TARGET}/${ARCHIVE}
            sha1
        )
        if(${sha1} STREQUAL ${SHA1})
            message(STATUS "File `${ARCHIVE}' completed")
            return()
        else()
            message(STATUS "File `${ARCHIVE}' not completed, download now")
        endif()
    endif()

    file(DOWNLOAD
        "${URL}/${ARCHIVE}"
        "${DOWNLOAD_TARGET}/${ARCHIVE}"
        SHOW_PROGRESS
        # TLS_VERIFY ${HTTPS}
        STATUS status
        EXPECTED_HASH SHA1=${SHA1}
    )
    list(GET status 0 ret)
    message("${CMAKE_CURRENT_FUNCTION} return: ${ret}")
    if(NOT ${ret} EQUAL 0)
        message(FATAL_ERROR "Failed to download ${ARCHIVE}")
    endif()
endfunction()



function(tar_unpack_to ARCHIVE TARGET_DIR)
    file(ARCHIVE_EXTRACT)
endfunction()