# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

# Set C++ standard globally
# set(CMAKE_CXX_STANDARD 14)
# set(CMAKE_CXX_STANDARD_REQUIRED ON)
# set(CMAKE_CXX_EXTENSIONS OFF)

# Project with better version handling
project(qr_track_library 
    VERSION 0.0.1 
    DESCRIPTION "QR Track Library"
    LANGUAGES C CXX
)

# Define source files
set(SOURCES
    common.cpp
    qr_track.cpp
)

# Build options
option(BUILD_WRITERS "Enable ZXing writers" ON)

# Create library
add_library(qr_track ${SOURCES})

# ZXing dependency
add_subdirectory(zxing/core EXCLUDE_FROM_ALL)

# Library properties
set_target_properties(qr_track PROPERTIES
    PUBLIC_HEADER "qr_track.h"
    OUTPUT_NAME "qr_track"
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
)

# Link libraries
target_link_libraries(qr_track ZXing)

# Compile definitions
target_compile_definitions(qr_track 
    PUBLIC 
        DART_SHARED_LIB
)

# Platform specific settings
if (ANDROID)
  find_library(log-lib log)
  target_link_libraries(qr_track ${log-lib})
  # Support Android 15 16k page size
  target_link_options(qr_track PRIVATE "-Wl,-z,max-page-size=16384")
endif()
