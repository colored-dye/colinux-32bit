include(ExternalProject)
function(download_file URL ARCHIVE DOWNLOAD_TARGET HTTPS)
    file(DOWNLOAD
        "${URL}/${ARCHIVE}"
        "${DOWNLOAD_TARGET}/${ARCHIVE}"
        SHOW_PROGRESS
        TLS_VERIFY ${HTTPS}
        STATUS status
    )
endfunction()
