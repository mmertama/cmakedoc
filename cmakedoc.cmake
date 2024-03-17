
set(CMAKEDOC_HOME ${CMAKE_CURRENT_LIST_DIR})

function (add_doxygen)

    find_program(DOCX_APP doxygen)
    if(NOT DOCX_APP)
        message(FATAL_ERROR "Doxygen is not found - try apt-get install doxygen")
    endif()

    find_program(GRPHZ_APP dot)
    if(NOT GRPHZ_APP)
        message(FATAL_ERROR "graphviz for doxygen is not found - try apt-get install graphviz")
    endif()

    find_program(ASPELL_APP aspell)
    if(NOT ASPELL_APP)
        message(FATAL_ERROR "aspell for doxygen is not found - try apt-get install aspell")
    endif()

    if(NOT TARGET ${CMAKEDOC_TARGET})
        set(CMAKEDOC_TARGET ${PROJECT_NAME})
    endif()


    find_package(Doxygen REQUIRED dot)
    set(DOXYGEN_EXTRACT_ALL FALSE)
    set(DOXYGEN_INTERNAL_DOCS NO)
    set(DOXYGEN_EXTRACT_PRIVATE NO)
    set(DOXYGEN_BUILTIN_STL_SUPPORT TRUE)

    set(DOXYGEN_USE_MDFILE_AS_MAINPAGE "${CMAKE_SOURCE_DIR}/README.md")
    set(DOXYGEN_DOT_IMAGE_FORMAT svg) # use vector graphics, not png
    set(DOXYGEN_DOT_TRANSPARENT YES) # especially good for dark mode (at least in firefox, currently not chrome)

    set(DOXYGEN_GENERATE_TREEVIEW YES)
    if(NOT DEFINED DOXYGEN_PROJECT_NAME)
        set(DOXYGEN_PROJECT_NAME ${CMAKEDOC_TARGET})
    endif()
    set(DOXYGEN_MARKDOWN_SUPPORT YES)
    set(ENABLE_PREPROCESSING TRUE)

    if(NOT DEFINED DOXYGEN_FILE_PATTERNS)
        set(DOXYGEN_FILE_PATTERNS           *.c *.cc *.cxx *.cpp *.c++ *.ii *.ixx *.ipp *.i++ *.inl *.h *.hh *.hxx *.hpp *.h++ *.inc *.md *.txt)
    endif()

    #set(DOXYGEN_WARN_NO_PARAMDOC        YES)

    set(DOXYGEN_RECURSIVE YES)

    if(NOT EXISTS "${CMAKE_SOURCE_DIR}/README.md")
        message(FATAL_ERROR "${CMAKE_SOURCE_DIR}/README.md not found!")
    endif()

    set(DOXYGEN_HTML_OUTPUT            ${CMAKE_BINARY_DIR}/html)
    set(DOXYGEN_JAVADOC_AUTOBRIEF      YES)
    set(DOXYGEN_GENERATE_HTML          YES)
    set(DOXYGEN_HAVE_DOT               YES)

    set(DOXYGEN_DOT_MULTI_TARGETS  YES)

    file(MAKE_DIRECTORY ${DOXYGEN_HTML_OUTPUT})

    if(DEFINED CMAKEDOC_DOXYGEN_DOCUMENTS)
        doxygen_add_docs(doxy_docs
            USE_STAMP_FILE
            ${CMAKE_SOURCE_DIR}/README.md
            ${CMAKEDOC_DOXYGEN_DOCUMENTS})
    else()
        doxygen_add_docs(doxy_docs
            ${CMAKE_SOURCE_DIR}/README.md
            ${CMAKE_CURRENT_SOURCE_DIR}/.)
    endif()

    if(NOT TARGET doxy)
        add_custom_target(doxy)
    endif()

    add_dependencies(doxy doxy_docs)


    if(TARGET doxy_spell)
        add_dependencies(doxy_spell doxy_docs)
    endif()

    if(NOT TARGET ${CMAKEDOC_TARGET})
        message(FATAL_ERROR "Target not found ${CMAKEDOC_TARGET}")
    endif()  

    add_dependencies(${CMAKEDOC_TARGET} doxy)  

endfunction()

function (add_spellcheck)

    if(NOT DEFINED CMAKEDOC_SPELL_DICTIONARY)
        message(FATAL_ERROR "CMAKEDOC_SPELL_DICTIONARY ${CMAKEDOC_SPELL_DICTIONARY} file is not defined! - please define!")
    endif()    

    if(NOT EXISTS ${CMAKEDOC_SPELL_DICTIONARY})
        find_file(FF ${CMAKEDOC_SPELL_DICTIONARY} HINTS ${CMAKE_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR} REQUIRED)
        set(CMAKEDOC_SPELL_DICTIONARY ${FF})
        if(NOT EXISTS ${CMAKEDOC_SPELL_DICTIONARY})
            message(FATAL_ERROR "CMAKEDOC_SPELL_DICTIONARY, ${CMAKEDOC_SPELL_DICTIONARY} file does not exists! - please create!")
        endif()    
    endif()    
    
    set(GREP_SPELL_EXCLUDE_DIRS 
        aspell
        .git
    )
    set(GREP_SPELL_EXCLUDE_FILES 
        doxygen.cmake
        graph_legend.html
        jquery.js
        *.png
        *.ttf
        *.svg
        *.jpg
        *.js
    )

    set(FIND_SPELL_EXCLUDE_FILES_INTERNAL 
        doxygen.cmake
        graph_legend.html
        \*.png
        \*.ttf
        \*.svg
        \*.jpg
        \*.js
    )

    
    foreach(DE ${GREP_SPELL_EXCLUDE_DIRS})
        set(GREP_SPELL_EXCLUDE "${GREP_SPELL_EXCLUDE} --exclude-dir=${DE} ")
    endforeach()
    
    foreach(FE ${GREP_SPELL_EXCLUDE_FILES})
        set(GREP_SPELL_EXCLUDE "${GREP_SPELL_EXCLUDE} --exclude=${FE} ")
    endforeach()
    
    foreach(DE ${CMAKEDOC_SPELL_EXCLUDE_DIRS})
        set(GREP_SPELL_EXCLUDE "${GREP_SPELL_EXCLUDE} --exclude-dir=${DE} ")
    endforeach()
    
    foreach(FE ${CMAKEDOC_SPELL_EXCLUDE_FILES})
        set(GREP_SPELL_EXCLUDE "${GREP_SPELL_EXCLUDE} --exclude=${FE} ")
    endforeach()

    foreach(FE ${FIND_SPELL_EXCLUDE_FILES_INTERNAL})
        set(FIND_SPELL_EXCLUDE "${FIND_SPELL_EXCLUDE} ! -name '${FE}' ")
    endforeach()

    set(SPELL_FILE_TYPE *.html) 
    set(DOXYGEN_HTML_OUTPUT            ${CMAKE_BINARY_DIR}/html)
    set(CMAKEDOC_SPELL_WORKING_FOLDER "${CMAKE_BINARY_DIR}/html")
    set(SPELL_DICTIONARY_FOLDER "${CMAKE_BINARY_DIR}/aspell")
    set(SPELL_DICTIONARY_FILE "${SPELL_DICTIONARY_FOLDER}/spell_words.txt")
    file(MAKE_DIRECTORY ${SPELL_DICTIONARY_FOLDER})

    # do
    #if(NOT EXISTS ${SPELL_DICTIONARY_FILE} )
    #    configure_file(${CMAKEDOC_HOME}/spell_words.txt.in ${SPELL_DICTIONARY_FILE} COPYONLY)
    #endif()

    # if spellchecker lists any words, either fix that or add into ${CMAKEDOC_SPELL_DICTIONARY_FILE}
    #set(SPELL_CMD "find . -type f -name ${SPELL_FILE_TYPE} ${FIND_SPELL_EXCLUDE} -exec cat {} \; | ${ASPELL_APP} list -H -p ${CMAKEDOC_SPELL_DICTIONARY_FILE} || { echo 'Error: Aspell failed. Exiting script.'; exit 1; }  | sort | uniq | while read -r word; do grep -r ${GREP_SPELL_EXCLUDE} -n -m 1  \"\$word\" ${CMAKE_SOURCE_DIR}; echo \"when looking for $word\"; done")
    set(SPELL_CMD "${CMAKEDOC_HOME}/dospell.sh \"${DOXYGEN_HTML_OUTPUT}\" \"${CMAKE_SOURCE_DIR}\" \"${SPELL_DICTIONARY_FILE}\" \"${SPELL_FILE_TYPE}\" \"${FIND_SPELL_EXCLUDE}\" \"${ASPELL_APP}\" \"${GREP_SPELL_EXCLUDE}\"")

    set(SPELL_CMD_TEST_0 "if [[ $( ${SPELL_CMD} | wc -l) -ne 0 ]]; then echo Spelling errors:; fi")
    set(SPELL_CMD_TEST_1 "if [[ $( ${SPELL_CMD} | wc -l) -ne 0 ]]; then exit 1; fi")
    
    add_custom_target(doxy_spell_bin
        COMMAND bash -c "${SPELL_CMD_TEST_0}"
        
        COMMAND bash -c "${SPELL_CMD}"
        COMMAND bash -c "${SPELL_CMD_TEST_1}"
        COMMAND echo ""
        WORKING_DIRECTORY "${CMAKEDOC_SPELL_WORKING_FOLDER}"
        VERBATIM
    )

    add_custom_target(doxy_spell_dict
        COMMAND ${CMAKEDOC_HOME}/doaddtrim.sh "${CMAKEDOC_SPELL_DICTIONARY}" "${SPELL_DICTIONARY_FILE}" "${CMAKEDOC_HOME}/spell_words.txt.in"
        DEPENDS ${CMAKEDOC_SPELL_DICTIONARY}
    )

    if(NOT TARGET doxy)
        if(NOT TARGET ${CMAKEDOC_TARGET})
            message(FATAL_ERROR "Target not found ${CMAKEDOC_TARGET}")
        endif()    
        add_custom_target(doxy)
        add_dependencies(${CMAKEDOC_TARGET} doxy)        
    endif()

    add_dependencies(doxy_spell_bin doxy_spell_dict)
    add_dependencies(doxy doxy_spell_bin)

    if(TARGET doxy_docs)
        add_dependencies(doxy_spell_bin doxy_docs)
    endif()

endfunction()


