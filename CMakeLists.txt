cmake_minimum_required(VERSION 3.19)

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${CMAKE_SOURCE_DIR}/cmake/Modules/")

set(PLATFORM "pc" CACHE STRING "Platform to build for")
set_property(CACHE PLATFORM PROPERTY STRINGS pc vita switch)

set(UNIX_LIKE OFF)
if(UNIX AND NOT APPLE AND NOT ANDROID)
    set(UNIX_LIKE ON)

    set(PORTABLE "AUTO" CACHE STRING "Build location-independent binary?")
    set_property(CACHE PORTABLE PROPERTY STRINGS ON OFF AUTO)
else()
    set(PORTABLE "AUTO" CACHE INTERNAL "Build location-independent binary? (Linux/BSD only)")
endif()

if(PLATFORM STREQUAL "pc")

elseif(PLATFORM STREQUAL "vita")
    include("cmake/PlatformVita.cmake")
elseif(PLATFORM STREQUAL "switch")
    include("cmake/PlatformSwitch.cmake")
else()
    message(FATAL_ERROR "Unsupported platform: ${PLATFORM}")
endif()

project(nx CXX)

set (nx_VERSION_MAJOR 2)
set (nx_VERSION_MINOR 6)
set (nx_VERSION_RELEASE 5)
set (nx_APP_ID org.nxengine.nxengine_evo)

if(PLATFORM STREQUAL "vita")
    find_package(SDL2 CONFIG REQUIRED)
else()
    find_package(SDL2 REQUIRED)
endif()

find_package(SDL2_mixer REQUIRED)
find_package(SDL2_image REQUIRED)
find_package(ZLIB REQUIRED)
find_package(PNG REQUIRED)
find_package(JPEG REQUIRED)

file(GLOB APP_SOURCES "src/[a-zA-Z]*.cpp")
file(GLOB TB_SOURCES "src/TextBox/[a-zA-Z]*.cpp")
file(GLOB_RECURSE AI_SOURCES "src/ai/[a-zA-Z]*.cpp")
file(GLOB AG_SOURCES "src/autogen/[a-zA-Z]*.cpp")
file(GLOB CM_SOURCES "src/common/[a-zA-Z]*.cpp")
file(GLOB UT_SOURCES "src/Utils/[a-zA-Z]*.cpp")
file(GLOB EG_SOURCES "src/endgame/[a-zA-Z]*.cpp")
file(GLOB GR_SOURCES "src/graphics/[a-zA-Z]*.cpp")
file(GLOB IN_SOURCES "src/intro/[a-zA-Z]*.cpp")
file(GLOB PA_SOURCES "src/pause/[a-zA-Z]*.cpp")
file(GLOB SL_SOURCES "src/siflib/[a-zA-Z]*.cpp")
file(GLOB SN_SOURCES "src/sound/[a-zA-Z]*.cpp")
file(GLOB I18N_SOURCES "src/i18n/[a-zA-Z]*.cpp")
file(GLOB EXTR_SOURCES "src/extract/[a-zA-Z]*.cpp")
set(EXTR_SOURCES
    ${EXTR_SOURCES}
    "src/common/misc.cpp"
    "src/Utils/Logger.cpp"
    "src/stagedata.cpp"
)

set(SOURCES
    ${APP_SOURCES}
    ${TB_SOURCES}
    ${AI_SOURCES}
    ${AG_SOURCES}
    ${CM_SOURCES}
    ${EG_SOURCES}
    ${GR_SOURCES}
    ${IN_SOURCES}
    ${PA_SOURCES}
    ${SL_SOURCES}
    ${SN_SOURCES}
    ${I18N_SOURCES}
    ${UT_SOURCES}
)

add_executable(nx ${SOURCES})

target_include_directories(nx PRIVATE
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/deps
)

target_compile_definitions(nx PRIVATE
    $<$<STREQUAL:${PLATFORM},pc>:-std=c++11>
    $<$<STREQUAL:${PLATFORM},vita>:-std=gnu++11 -march=armv7-a+simd -D__VITA__>
    $<$<STREQUAL:${PLATFORM},switch>:-std=gnu++11 -D__SWITCH__>
)

if(CMAKE_BUILD_TYPE MATCHES Debug)
    message(DEBUG "Debug Mode Enabled")
    target_compile_definitions(nx PRIVATE 
        TRACE_SCRIPT 
        DEBUG
    )
endif()

if(PLATFORM STREQUAL "pc")
    if(UNIX_LIKE)
        target_compile_definitions(nx PRIVATE HAVE_UNIX_LIKE)
        if((PORTABLE STREQUAL "AUTO" AND NOT CMAKE_INSTALL_DATAROOTDIR STREQUAL "share") OR NOT PORTABLE)
            target_compile_definitions(nx PRIVATE DATADIR="${CMAKE_INSTALL_FULL_DATADIR}/nxengine/data")
        elseif(PORTABLE STREQUAL "ON")
            target_compile_definitions(nx PRIVATE PORTABLE)
        endif()
    endif()
endif()
    
target_compile_options(nx PRIVATE -Wall)
    
    target_link_libraries(nx PRIVATE
        $<$<STREQUAL:${PLATFORM},vita>:SDL2::SDL2-static>
        $<$<STREQUAL:${PLATFORM},NOT vita>:SDL2::SDL2>
        SDL2_mixer::SDL2_mixer
        SDL2_image::SDL2_image
        PNG::PNG
        JPEG::JPEG
        $<$<STREQUAL:${PLATFORM},vita>:xmp modplug opusfile opus webp pthread z FLAC vorbisfile vorbis ogg mikmod mpg123>
        $<$<STREQUAL:${PLATFORM},switch>:m z FLAC vorbisidec ogg mikmod mpg123 modplug EGL glapi drm_nouveau -lnx opusfile opus>
    )   

if(PLATFORM STREQUAL "pc")
    add_executable(extract ${EXTR_SOURCES})
    target_link_libraries(extract SDL2::SDL2)
    set_property(TARGET extract PROPERTY OUTPUT_NAME nxextract)

    install(TARGETS nx extract RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
    install(DIRECTORY data DESTINATION ${CMAKE_INSTALL_DATADIR}/nxengine)

    # Install XDG metadata on Desktop Linux like platforms
    if(UNIX_LIKE)
        install(FILES platform/xdg/${nx_APP_ID}.desktop     DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications)
        install(FILES platform/xdg/${nx_APP_ID}.png         DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/256x256/apps)
        install(FILES platform/xdg/${nx_APP_ID}.appdata.xml DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metainfo)
    endif()
endif()
