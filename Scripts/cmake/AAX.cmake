cmake_minimum_required(VERSION 3.11)

set(AAX_DIR "${IPLUG2_DIR}/Dependencies/IPlug/AAX_SDK" CACHE PATH "AAX SDK directory.")

set(IPLUG2_AAX_ICON
  "${IPLUG2_DIR}/Dependencies/IPlug/AAX_SDK/Utilities/PlugIn.ico"
  CACHE FILEPATH "Path to AAX plugin icon"
)

if (WIN32)
  set(AAX_32_PATH "C:/Program Files (x86)/Common Files/Avid/Audio/Plug-Ins"
    CACHE PATH "Path to install 32-bit AAX plugins")
  set(AAX_64_PATH "C:/Program Files/Common Files/Avid/Audio/Plug-Ins"
    CACHE PATH "Path to install 64-bit AAX plugins")
  set(AAX_LIB_PATH ${AAX_DIR}/Libs/$<CONFIG>/AAXLibrary_x64$<$<CONFIG:Debug>:_D>.lib)
  #set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded")
elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
  set(AAX_INSTALL_PATH "/Library/Application Support/Avid/Audio/Plug-Ins")
  set(AAX_LIB_PATH ${AAX_DIR}/Libs/$<CONFIG>/libAAXLibrary_libcpp.a)
endif()

add_library(iPlug2_AAX INTERFACE)
set(sdk ${IPLUG2_DIR}/IPlug/AAX)
set(SRC_FILES
	"${sdk}/IPlugAAX.h"
	"${sdk}/IPlugAAX.cpp"
	"${sdk}/IPlugAAX_view_interface.h"
	"${sdk}/IPlugAAX_TaperDelegate.h"
	"${sdk}/IPlugAAX_Parameters.h"
	"${sdk}/IPlugAAX_Parameters.cpp"
	"${sdk}/IPlugAAX_Describe.cpp"
	"${AAX_DIR}/Interfaces/AAX_Exports.cpp"
)

set(AAXTARGET iPlug2_AAX)
list(APPEND _inc ${sdk})
iplug_target_add(${AAXTARGET} INTERFACE 
  SOURCE ${SRC_FILES}
  INCLUDE "${sdk}"
  DEFINE "AAX_API" "IPLUG_DSP=1"
  LINK iPlug2_Core
)
if (CMAKE_SYSTEM_NAME MATCHES "Darwin")
  target_compile_options(${AAXTARGET} INTERFACE -Wno-incompatible-ms-struct)
endif()

target_include_directories(${AAXTARGET} INTERFACE 
  "${IPLUG2}/IPlug"
  "${IPLUG2}/IPlug/AAX"
  "${AAX_DIR}/Libs/AAXLibrary/include"
  "${AAX_DIR}/Interfaces"
  "${AAX_DIR}/Interfaces/ACF"
)
target_link_libraries(${AAXTARGET} INTERFACE ${AAX_LIB_PATH})

function(iplug_configure_aax target)
  set(out_dir "${CMAKE_BINARY_DIR}/${PLUG_NAME}.aaxplugin")
  set(install_dir "${AAX_INSTALL_PATH}/${PLUG_NAME}.aaxplugin")
  set(res_dir "${CMAKE_BINARY_DIR}/${PLUG_NAME}.aax/Contents/Resources")
  
  if (WIN32)
    set_target_properties(${target} PROPERTIES
      OUTPUT_NAME "${IPLUG_APP_NAME}"
      LIBRARY_OUTPUT_DIRECTORY "${out_dir}/Contents/"
      PREFIX ""
      SUFFIX ".aaxplugin"
    )
    # After building, we run the post-build script
    add_custom_command(TARGET ${target} POST_BUILD
      COMMAND "${CMAKE_BINARY_DIR}/postbuild-win.bat" 
      ARGS "\"$<TARGET_FILE:${target}>\"" "\".aaxplugin\""
    )

  elseif (CMAKE_SYSTEM_NAME MATCHES "Darwin")
    # Set the Info.plist file we're using and add resources
    set_target_properties(${target} PROPERTIES 
      BUNDLE TRUE
      MACOSX_BUNDLE TRUE
      MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/build-mac/${PLUG_NAME}-AAX-Info.plist
      BUNDLE_EXTENSION "aaxplugin"
	  XCODE_ATTRIBUTE_GENERATE_PKGINFO_FILE "YES"
      PREFIX ""
      SUFFIX ""
    )

    if (CMAKE_GENERATOR STREQUAL "Xcode")
      set(out_dir "${CMAKE_BINARY_DIR}/$<CONFIG>/${PLUG_NAME}.aaxplugin")
      set(res_dir "")
    endif()
    
    add_custom_command(TARGET ${target} POST_BUILD
      COMMAND ${CMAKE_COMMAND} ARGS "-E" "copy_directory" "${out_dir}" "${install_dir}")
  endif()
  
endfunction()
