if(NOT DEFINED ENV{DEVKITPRO})
    message(FATAL_ERROR "Please define DEVKITPRO to point to your SDK path!")
endif()

include("switch.toolchain.cmake" REQUIRED)
include("switch.tools.cmake" REQUIRED)

set(SWITCH_APP_NAME     "NXEngine-evo")
set(SWITCH_APP_AUTHOR   "NXEngine team")
set(SWITCH_APP_VERSION  "${nx_VERSION_MAJOR}.${nx_VERSION_MINOR}.${nx_VERSION_RELEASE}")
set(SWITCH_APP_ICON     "${CMAKE_SOURCE_DIR}/platform/switch/icon.jpg")
set(SWITCH_APP_ROMFS    "${CMAKE_SOURCE_DIR}/release")

add_nro_target(nx ${SWITCH_APP_NAME} ${SWITCH_APP_AUTHOR} ${SWITCH_APP_VERSION} ${SWITCH_APP_ICON} ${SWITCH_APP_ROMFS})

set(NRO_OUTPUT ${CMAKE_SOURCE_DIR}/release/NXEngine-Evo-${nx_VERSION_MAJOR}.${nx_VERSION_MINOR}.${nx_VERSION_RELEASE}.nro)

add_custom_command(OUTPUT ${NRO_OUTPUT}
    COMMAND cp nx.nro ${NRO_OUTPUT}
    DEPENDS nx.nro
    COMMENT "Moving nro to release"
)
    
add_custom_target(nxbinnro_ ALL DEPENDS ${NRO_OUTPUT})