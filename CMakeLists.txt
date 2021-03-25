cmake_minimum_required(VERSION 2.8.12 FATAL_ERROR)
cmake_policy(SET CMP0042 NEW)
cmake_policy(SET CMP0048 NEW)

# project title
project(tstarjetpicoreader  VERSION 0.1.0)

set(CMAKE_BUILD_TYPE RELEASE)

# options
option(BUILD_SHARED_LIBS "Build shared libs" ON)
option(BUILD_32BIT "Build 32 bit shared library" OFF)
option(INSTALL_HEADERS "Install TStarJetPico headers" ON)

# compiler & system checks
include(cmake/SysCheck.cmake)

# helper functions
include(cmake/Utils.cmake)

# dependencies
include(cmake/Dependencies.cmake)

# build options
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2 -fPIC")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-narrowing")

if(BUILD_32BIT)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -m32")
endif(BUILD_32BIT)

# start the build - define source file and header variables
set(PICO_SRCS)
set(PICO_HDRS)
set(PICO_LINKDEF)

# add the source tree
add_subdirectory(TStarJetPicoReader)
set(PICO_INCLUDE ${CMAKE_CURRENT_SOURCE_DIR}/TStarJetPicoReader)
include_directories(${PICO_INCLUDE})

# use ROOT to generate the dictionary file
set(PICO_DICT_NAME tstarjetpico_dict)
set(PICO_DICT_TARGET tstarjetpico_dict.cxx)
if(COMMAND ROOT_GENERATE_DICTIONARY)
ROOT_GENERATE_DICTIONARY(${PICO_DICT_NAME} ${PICO_HDRS} LINKDEF ${PICO_LINKDEF})
set(PICO_SRCS ${PICO_SRCS} ${PICO_DICT_TARGET})
else(COMMAND ROOT_GENERATE_DICTIONARY)
message(FATAL_ERROR "Could not generate dictionary for TStarJetPico library")
endif (COMMAND ROOT_GENERATE_DICTIONARY)

# build target library
add_library(TStarJetPico ${PICO_SRCS})
target_link_libraries(TStarJetPico PRIVATE ${PICO_DEPENDENCY_LIBS})
target_include_directories(TStarJetPico INTERFACE $<INSTALL_INTERFACE:include>)
install(TARGETS TStarJetPico EXPORT TStarJetPico DESTINATION lib)
install(EXPORT TStarJetPico DESTINATION lib/TStarJetPico)

# install headers

set (PICO_LIBRARIES TStarJetPico)

# add an uninstall option, since cmake does not provide one by default
if(NOT TARGET uninstall)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/cmake/cmake_uninstall.cmake.in
                 ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake
                 IMMEDIATE
                 @ONLY)

  add_custom_target(uninstall
                    COMMAND ${CMAKE_COMMAND} -P
                            ${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake)
endif()

# export the analysis variables if not root directory
if(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
	set(PICO_INCLUDE_DIRS ${PICO_INCLUDE} PARENT_SCOPE)
#	set(PICO_LIBS ${PICO_LIBRARIES} PARENT_SCOPE)
#    set(PICO_DEPENDENCY_LIBS ${PICO_DEPENDENCY_LIBS} PARENT_SCOPE)
endif(NOT CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
