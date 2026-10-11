
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin/plugins")

# browser:e8y6 lightweight plugin configuration
option(BROWSER_E8Y6_LITE "Build browser:e8y6 with minimal optional plugins" ON)

if (BROWSER_E8Y6_LITE)
    message(STATUS "browser:e8y6 Lite mode enabled")

    # Retained optional plugins
    add_subdirectory(GreaseMonkey)
    add_subdirectory(TabManager)
    add_subdirectory(VerticalTabs)
else()
    message(STATUS "browser:e8y6 Lite mode disabled - building standard Falkon plugins")

    add_subdirectory(AutoScroll)
    add_subdirectory(FlashCookieManager)
    add_subdirectory(GreaseMonkey)
    add_subdirectory(MouseGestures)
    add_subdirectory(PIM)
    add_subdirectory(StatusBarIcons)
    add_subdirectory(TabManager)
    add_subdirectory(VerticalTabs)
endif()

# Preserve optional password-storage integration
if (GNOME_KEYRING_FOUND)
    add_subdirectory(GnomeKeyringPasswords)
endif()

# Preserve KDE desktop integration
if (ENABLE_KDE_FRAMEWORKS_INTEGRATION_PLUGIN)
    add_subdirectory(KDEFrameworksIntegration)
endif()

# Python plugins, controlled separately
if (ENABLE_PYTHON_PLUGINS)
    add_subdirectory(PyFalkon)
endif()

# Development-only plugins
if (CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_subdirectory(TestPlugin)
    add_subdirectory(SiteSettingsView)
endif()
