set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

message(STATUS "CMAKE_CURRENT_BINARY_DIR = ${CMAKE_CURRENT_BINARY_DIR}")

#set(Qt6Core_VERSION 6.9.2)
get_property(QT_ABI_DIR DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY QT_ABI_DIR)
set(CMAKE_PREFIX_PATH "/home/user/Qt/6.9.2/${QT_ABI_DIR}")

find_package(Qt6Core REQUIRED)
find_package(Qt6Gui REQUIRED)
find_package(Qt6Widgets REQUIRED)
find_package(Qt6Xml REQUIRED)
find_package(Qt6Network REQUIRED)
find_package(Qt6 REQUIRED COMPONENTS Multimedia)


file(GLOB_RECURSE LMC_SOURCES
    src/*.cpp
    src/*.h
    src/*.ui
    include/*.h
)

list(APPEND LMC_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/src/settingsdialog.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/settingsdialog.ui
)

# Exclude dialog from lmc to avoid duplicate moc symbols
# list(FILTER LMC_SOURCES EXCLUDE REGEX ".*/dialog\\.cpp$")
# list(FILTER LMC_SOURCES EXCLUDE REGEX ".*/dialog\\.h$")

add_library(lmc STATIC ${LMC_SOURCES})

target_include_directories(lmc PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}/lmc/lmc_autogen/include
)

get_property(OPENSSL_DIR DIRECTORY ${CMAKE_SOURCE_DIR} PROPERTY OPENSSL_DIR)

# Include paths for lmc target
target_include_directories(lmc PRIVATE
    ${CMAKE_CURRENT_BINARY_DIR}/lmc/lmc_autogen/include
    ${OPENSSL_DIR}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_SOURCE_DIR}/lmcapp/include
)

target_include_directories(lmc PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/include
    ${CMAKE_PREFIX_PATH}/include
    ${CMAKE_PREFIX_PATH}/include/QtNetwork
#    /home/user/Qt/6.9.2/android_arm64_v8a/include
#    /home/user/Qt/6.9.2/android_arm64_v8a/include/QtNetwork
)

target_link_libraries(lmc PRIVATE
    ${OPENSSL_DIR}/libcrypto.a
    ${OPENSSL_DIR}/libssl.a
    Qt6::Core
    Qt6::Gui
    Qt6::Multimedia
    Qt6::Network
    Qt6::Widgets
    Qt6::Xml
)


set(CMAKE_AUTOGEN_ORIGIN_DEPENDS
    Qt6::Core
    Qt6::Gui
    Qt6::Network
    Qt6::Widgets
    Qt6::Xml
)


set_target_properties(lmc PROPERTIES AUTOMOC ON AUTOUIC ON AUTORCC ON)
set_target_properties(lmc PROPERTIES AUTOUIC_SEARCH_PATHS "${CMAKE_CURRENT_SOURCE_DIR}/src")

set(CMAKE_STRIP "$ENV{ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/linux-x86_64/bin/llvm-strip")

add_custom_command(TARGET lmc POST_BUILD
    COMMAND ${CMAKE_STRIP} --strip-unneeded ${OPENSSL_DIR}/libcrypto.a
    COMMAND ${CMAKE_STRIP} --strip-unneeded ${OPENSSL_DIR}/libssl.a
    COMMENT "Stripping OpenSSL static libraries to reduce APK size"
)
