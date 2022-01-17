cmake_minimum_required(VERSION 3.14)
set(PROJECT_NAME "hid_windows")
project(${PROJECT_NAME} LANGUAGES CXX)

set(HIDAPI_VERSION "0.11.2" CACHE STRING "Version of hidapi used")
set(HIDAPI_ARCH "x64" CACHE STRING "Architecture of hidapi used")

# Download hidapi
include(../windows/DownloadProject.cmake)
download_project(
  PROJ
  hidapi
  URL
  "https://github.com/libusb/hidapi/archive/refs/tags/hidapi-${HIDAPI_VERSION}.zip"
  )
add_subdirectory(${hidapi_SOURCE_DIR} ${hidapi_BINARY_DIR})

# This value is used when generating builds using this plugin, so it must not be
# changed
set(PLUGIN_NAME "hid_windows_plugin")

add_library(${PLUGIN_NAME} SHARED "hid_windows_plugin.cpp")
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME}
                           INTERFACE "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME}
                      PRIVATE flutter flutter_wrapper_plugin hidapi::hidapi)

# List of absolute paths to libraries that should be bundled with the plugin
set(hid_windows_bundled_libraries "$<TARGET_FILE:hidapi::hidapi>" PARENT_SCOPE)
