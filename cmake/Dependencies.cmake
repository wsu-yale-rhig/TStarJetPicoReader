# currently, StPicoEvent only depends on ROOT

set(PICO_DEPENDENCY_LIBS "")

# ROOT
list(APPEND CMAKE_PREFIX_PATH $ENV{ROOTSYS})
list(APPEND CMAKE_MODULE_PATH $ENV{ROOTSYS}/etc/cmake)
find_package(ROOT
    COMPONENTS MathCore
    RIO
    Hist
    Tree
    Net)

if(EXISTS ${ROOT_USE_FILE})
    include(${ROOT_USE_FILE})
endif(EXISTS ${ROOT_USE_FILE})

if(NOT ROOT_FOUND)
    # we will look using root-config
    find_program(ROOT_CONFIG root-config PATHS
        ${ROOTSYS}/bin
        )

    if(ROOT_CONFIG)
        set(ROOT_FOUND TRUE)

        execute_process(
            COMMAND ${ROOT_CONFIG} --prefix
            OUTPUT_VARIABLE ROOT_PREFIX
            OUTPUT_STRIP_TRAILING_WHITESPACE
            )

        execute_process(
            COMMAND ${ROOT_CONFIG} --incdir
            OUTPUT_VARIABLE ROOT_INCLUDE_DIRS
            OUTPUT_STRIP_TRAILING_WHITESPACE
            )

        execute_process(
            COMMAND ${ROOT_CONFIG} --libs
            OUTPUT_VARIABLE ROOT_LIBRARIES
            OUTPUT_STRIP_TRAILING_WHITESPACE
            )

        execute_process(
            COMMAND ${ROOT_CONFIG} --libdir
            OUTPUT_VARIABLE ROOT_LIBRARY_DIRS
            OUTPUT_STRIP_TRAILING_WHITESPACE
            )

        execute_process(
            COMMAND ${ROOT_CONFIG} --version
            OUTPUT_VARIABLE ROOT_VERSION
            OUTPUT_STRIP_TRAILING_WHITESPACE
            )
    endif(ROOT_CONFIG)

endif(NOT ROOT_FOUND)

if(NOT ROOT_FOUND)
  MESSAGE(FATAL_ERROR "could not find root")
endif(NOT ROOT_FOUND)

string(SUBSTRING ${ROOT_VERSION} 0 1 ROOT_MAJOR_VERSION)
if(${ROOT_MAJOR_VERSION} STREQUAL "5")
    include("cmake/generate_dictionary.cmake")
endif(${ROOT_MAJOR_VERSION} STREQUAL "5")

link_directories(${ROOT_LIBRARY_DIRS})
pico_include_directories(${ROOT_INCLUDE_DIRS})
list(APPEND PICO_DEPENDENCY_LIBS ${ROOT_LIBRARIES})
message(STATUS "Found ROOT")