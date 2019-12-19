# collect headers and source files, find linkdef file

# get source files for libTStarJetPico
file(GLOB tmp *.cxx)
set(PICO_SRCS ${PICO_SRCS} ${tmp})

# get header files for libTStarJetPico
file(GLOB tmp *.h)
set(PICO_HDRS ${tmp})

# exclude linkdef from header
file(GLOB PICO_LINKDEF *LinkDef*)

if (PICO_LINKDEF)
  list(REMOVE_ITEM PICO_HDRS ${PICO_LINKDEF})
endif(PICO_LINKDEF)

# install headers
if (INSTALL_HEADERS)
    install(FILES ${PICO_HDRS} DESTINATION include/TStarJetPico)
endif (INSTALL_HEADERS)

# export file lists to parent scope
set(PICO_SRCS ${PICO_SRCS} PARENT_SCOPE)
set(PICO_HDRS ${PICO_HDRS} PARENT_SCOPE)
set(PICO_LINKDEF ${PICO_LINKDEF} PARENT_SCOPE)
