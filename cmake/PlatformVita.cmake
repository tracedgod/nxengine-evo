if(NOT DEFINED ENV{VITASDK})
    message(FATAL_ERROR "Please define VITASDK to point to your SDK path!")
endif()

include("$ENV{VITASDK}/share/vita.toolchain.cmake" REQUIRED)
include("$ENV{VITASDK}/share/vita.cmake" REQUIRED)

set(VITA_APP_NAME       "NXENGINE-EVO")
set(VITA_TITLEID        "NXEV00001")
set(VITA_VERSION        "01.00")
set(VITA_MKSFOEX_FLAGS  "${VITA_MKSFOEX_FLAGS} -d PARENTAL_LEVEL=1")

vita_create_self(${PROJECT_NAME}.self nx UNSAFE)
vita_create_vpk(${PROJECT_NAME}.vpk ${VITA_TITLEID} ${PROJECT_NAME}.self
  VERSION ${VITA_VERSION}
  NAME ${VITA_APP_NAME}
  FILE platform/vita/sce_sys sce_sys
  FILE release/data data
)

set(VPK_OUTPUT ${CMAKE_SOURCE_DIR}/release/NXEngine-Evo-${nx_VERSION_MAJOR}.${nx_VERSION_MINOR}.${nx_VERSION_RELEASE}.vpk)

add_custom_command(OUTPUT ${VPK_OUTPUT}
  COMMAND cp nx.vpk ${VPK_OUTPUT}
  DEPENDS nx.vpk
  COMMENT "Moving vpk to release"
)

add_custom_target(nxbinvpk_ ALL DEPENDS ${VPK_OUTPUT})