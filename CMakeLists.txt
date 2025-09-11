cmake_minimum_required(VERSION 3.22)
project(LANMessenger)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

set(Qt6_VERSION 6.9.2)
find_package(Qt6 ${Qt6_VERSION} REQUIRED COMPONENTS Core Gui Widgets Network)

add_subdirectory(lmc)
add_subdirectory(lmcapp)


set(PROJECT_SOURCES
    lmc/src/main.cpp
    lmcapp/src/mainwindow.cpp
    lmcapp/src/mainwindow.ui
    lmcapp/src/dialog.ui
    # Add other .cpp/.ui files here
)


# === Target Definition ===
if(ANDROID)
    qt_add_library(LANMessengerForAndroid SHARED
        ${PROJECT_SOURCES}
    )

    target_link_libraries(LANMessengerForAndroid PRIVATE
        Qt6::Core
        Qt${QT_VERSION_MAJOR}::Widgets
        lmc
        lmcapp
    )

    target_include_directories(LANMessengerForAndroid PRIVATE
        ${CMAKE_SOURCE_DIR}/lmc/include
        ${CMAKE_SOURCE_DIR}/lmc/src
        ${CMAKE_SOURCE_DIR}/lmcapp/include
    )

    set_property(TARGET LANMessengerForAndroid APPEND PROPERTY QT_ANDROID_PACKAGE_SOURCE_DIR
                 ${CMAKE_CURRENT_SOURCE_DIR}/android)

    qt_finalize_target(LANMessengerForAndroid)

else()
    qt_add_executable(LANMessengerForAndroid
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
    )

    target_include_directories(LANMessengerForAndroid PRIVATE
        ${CMAKE_SOURCE_DIR}/lmc/include
        ${CMAKE_SOURCE_DIR}/lmc/src
        ${CMAKE_SOURCE_DIR}/lmcapp/include
        ${CMAKE_SOURCE_DIR}/lmcapp/src
    )

    qt_finalize_executable(LANMessengerForAndroid)
endif()

