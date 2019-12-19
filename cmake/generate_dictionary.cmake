#----------------------------------------------------------------------------
# function ROOT_GENERATE_DICTIONARY( dictionary
#                                    header1 header2 ...
#                                    LINKDEF linkdef1 ...
#                                    OPTIONS opt1...)
function(ROOT_GENERATE_DICTIONARY dictionary)
  CMAKE_PARSE_ARGUMENTS(ARG "" "" "LINKDEF;OPTIONS" "" ${ARGN})
  #---Get the list of include directories------------------
  get_directory_property(incdirs INCLUDE_DIRECTORIES)
  set(includedirs)
  foreach( d ${incdirs})
     set(includedirs ${includedirs} -I${d})
  endforeach()
  #---Get the list of header files-------------------------
  set(headerfiles)
  foreach(fp ${ARG_UNPARSED_ARGUMENTS})
    if(${fp} MATCHES "[*?]") # Is this header a globbing expression?
      file(GLOB files ${fp})
      foreach(f ${files})
        if(NOT f MATCHES LinkDef) # skip LinkDefs from globbing result
          set(headerfiles ${headerfiles} ${f})
        endif()
      endforeach()
    else()
      if(IS_ABSOLUTE ${fp})
        get_filename_component(file_nopath ${fp} NAME)
        find_file(headerFile ${file_nopath} PATHS ${incdirs})
        set(headerfiles ${headerfiles} ${headerFile})
      else(IS_ABSOLUTE ${fp})
        find_file(headerFile ${fp} PATHS ${incdirs})
        set(headerfiles ${headerfiles} ${headerFile})
      endif(IS_ABSOLUTE ${fp})
      unset(headerFile CACHE)
    endif()
  endforeach()
  #---Get LinkDef.h file------------------------------------
  set(linkdefs)
  foreach( f ${ARG_LINKDEF})
    if(IS_ABSOLUTE ${f})
      get_filename_component(file_nopath ${f} NAME)
      find_file(linkFile ${file_nopath} PATHS ${incdirs})
      set(linkdefs ${linkdefs} ${linkFile})
    else(IS_ABSOLUTE ${f})
      find_file(linkFile ${f} PATHS ${incdirs})
      set(linkdefs ${linkdefs} ${linkFile})
    endif(IS_ABSOLUTE ${f})
    unset(linkFile CACHE)
  endforeach()
  #---call rootcint------------------------------------------
  add_custom_command(OUTPUT ${dictionary}.cxx ${dictionary}.h
                     COMMAND ${ROOTCINT_EXECUTABLE} -cint -f  ${dictionary}.cxx
                                          -c ${ARG_OPTIONS} ${includedirs} ${headerfiles} ${linkdefs}
                     DEPENDS ${headerfiles} ${linkdefs} VERBATIM)
endfunction()