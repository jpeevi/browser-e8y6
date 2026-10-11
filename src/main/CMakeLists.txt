include_directories(
        ../lib/3rdparty
        ../lib/app
        ../lib/session
        ../lib/webengine
        ../lib/webtab
)

set(SRCS main.cpp)

if (WIN32)
    set(SRCS ${SRCS} version.rc)
    configure_file(
            falkonversion.h.cmake
            ${CMAKE_CURRENT_BINARY_DIR}/falkonversion.h
    )
endif ()

if(UNIX AND NOT APPLE)
    set(QM_LOADER_CATALOG_NAME "falkon_qt")
    set(QM_LOADER_CPP_FILE "${CMAKE_CURRENT_BINARY_DIR}/BrowserE8y6QmLoader.cpp")
    configure_file(
        "${CMAKE_SOURCE_DIR}/cmake/BrowserE8y6QmLoader.cpp.in"
        "${QM_LOADER_CPP_FILE}"
        @ONLY
    )
    list(APPEND SRCS "${QM_LOADER_CPP_FILE}")
else()
    ecm_create_qm_loader(SRCS falkon_qt)
endif()

# Keep the internal Falkon target for source compatibility.
add_executable(falkon ${SRCS})

# browser:e8y6 - Linux executable branding.
if (UNIX AND NOT APPLE)
    set_target_properties(falkon PROPERTIES
            OUTPUT_NAME "browser:e8y6"
    )
endif ()

target_link_libraries(falkon FalkonPrivate)

# macOS configuration.
if (APPLE)
    set_target_properties(falkon PROPERTIES
            MACOSX_BUNDLE_INFO_PLIST
            ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist
            MACOSX_BUNDLE_GUI_IDENTIFIER
            "org.kde.falkon"
            MACOSX_BUNDLE_BUNDLE_NAME
            "Falkon"
    )

    install(
            FILES lib/data/icons/exeicons/falkon.icns
            DESTINATION ${BUNDLE_INSTALL_DIR}/falkon.app/Contents/Resources
    )

    install(
            DIRECTORY ${CMAKE_SOURCE_DIR}/themes
            DESTINATION ${BUNDLE_INSTALL_DIR}/falkon.app/Contents/Resources
    )

    install(
            DIRECTORY ${CMAKE_BINARY_DIR}/bin/plugins
            DESTINATION ${BUNDLE_INSTALL_DIR}/falkon.app/Contents/Resources
    )
endif ()

# BSD compatibility.
if (CMAKE_SYSTEM_NAME MATCHES FreeBSD OR
        CMAKE_SYSTEM_NAME MATCHES OpenBSD)
    target_link_libraries(falkon execinfo)
endif ()

# Linux and other Unix installation.
if (UNIX AND NOT APPLE)

    # Install browser:e8y6 executable.
    install(
            TARGETS falkon
            ${KDE_INSTALL_TARGETS_DEFAULT_ARGS}
    )

    # Install browser:e8y6 desktop launcher.
    install(
            FILES
            "${CMAKE_SOURCE_DIR}/linux/applications/browser-e8y6.desktop"
            DESTINATION
            "${KDE_INSTALL_APPDIR}"
    )


    # Install browser:e8y6 themes independently of Falkon.
    install(
            DIRECTORY ${CMAKE_SOURCE_DIR}/themes
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/browser-e8y6
    )


    # Install gettext translations privately for browser:e8y6.
    if (KF6I18n_FOUND)
        set(KDE_INSTALL_LOCALEDIR
            "${CMAKE_INSTALL_DATAROOTDIR}/browser-e8y6/locale"
        )
        ki18n_install(${CMAKE_SOURCE_DIR}/po)
        unset(KDE_INSTALL_LOCALEDIR)
    endif ()

    # Keep Linux translations separate from Falkon.
    set(LOCALE_INSTALL_DIR
        "${CMAKE_INSTALL_DATAROOTDIR}/browser-e8y6/locale"
    )
    ecm_install_po_files_as_qm(${CMAKE_SOURCE_DIR}/poqm)
    unset(LOCALE_INSTALL_DIR)

    # browser:e8y6 icons are installed by the root CMakeLists.txt.
    #
    # Do not install the legacy Falkon desktop launcher,
    # application icons, Bash completion, or AppStream metadata.

    # Windows installation.
elseif (WIN32)

    install(
            TARGETS falkon
            ${KDE_INSTALL_TARGETS_DEFAULT_ARGS}
    )

    install(
            DIRECTORY ${CMAKE_SOURCE_DIR}/themes
            DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/falkon
    )

    if (KF6I18n_FOUND)
        ki18n_install(${CMAKE_SOURCE_DIR}/po)
    endif ()

    ecm_install_po_files_as_qm(${CMAKE_SOURCE_DIR}/poqm)

    # Preserve existing Windows icon installation.
    ecm_install_icons(
            ICONS
            ../../linux/hicolor/16-apps-falkon.png
            ../../linux/hicolor/32-apps-falkon.png
            ../../linux/hicolor/48-apps-falkon.png
            ../../linux/hicolor/64-apps-falkon.png
            ../../linux/hicolor/128-apps-falkon.png
            ../../linux/hicolor/256-apps-falkon.png
            ../../linux/hicolor/sc-apps-falkon.svg
            DESTINATION ${KDE_INSTALL_ICONDIR}
            THEME hicolor
    )

endif ()
