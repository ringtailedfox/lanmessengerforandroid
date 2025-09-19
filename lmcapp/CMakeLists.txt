set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

#set(Qt6Core_VERSION 6.9.2)
get_property(QT_ABI_DIR DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY QT_ABI_DIR)
set(CMAKE_PREFIX_PATH "/home/user/Qt/6.9.2/${QT_ABI_DIR}")
set(CMAKE_AUTOGEN_ORIGIN_DEPENDS Qt6::Core Qt6::Gui Qt6::Network Qt6::Widgets Qt6::Xml)

set(CMAKE_AUTOUIC_SEARCH_PATHS "${CMAKE_CURRENT_SOURCE_DIR}/src")

find_package(Qt6Core REQUIRED)
find_package(Qt6Gui REQUIRED)
find_package(Qt6Widgets REQUIRED)
find_package(Qt6Xml REQUIRED)
find_package(Qt6Network REQUIRED)

# Start with your core sources
file(GLOB_RECURSE LMCAPP_SOURCES
    src/*.cpp
    src/*.h
    src/*.ui
    include/*.h
)

# Remove platform-specific variants from the sweep
list(FILTER LMCAPP_SOURCES EXCLUDE REGEX ".*qtlockedfile_win\\.cpp$")
list(FILTER LMCAPP_SOURCES EXCLUDE REGEX ".*qtlockedfile_unix\\.cpp$")

# Add the correct variant based on platform
if(WIN32)
    list(APPEND LMCAPP_SOURCES src/qtlockedfile_win.cpp)
elseif(APPLE)
    list(APPEND LMCAPP_SOURCES src/qtlockedfile_unix.cpp)  # macOS and iOS
elseif(UNIX)
    list(APPEND LMCAPP_SOURCES src/qtlockedfile_unix.cpp)  # Linux/BSD/Android
endif()

add_executable(lmcapp)
target_sources(lmcapp PRIVATE ${LMCAPP_SOURCES})

set_target_properties(lmcapp PROPERTIES AUTOMOC ON AUTOUIC ON AUTORCC ON)

target_include_directories(lmcapp PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_PREFIX_PATH}/include
    ${CMAKE_PREFIX_PATH}/include/QtNetwork
#    /home/user/Qt/6.9.2/android_arm64_v8a/include
#    /home/user/Qt/6.9.2/android_arm64_v8a/include/QtNetwork
)

target_link_libraries(lmcapp PRIVATE
    lmc
    Qt6::Core
    Qt6::Gui
    Qt6::Network
    Qt6::Widgets
    Qt6::Xml
)
