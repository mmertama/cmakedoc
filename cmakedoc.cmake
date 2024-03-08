function (add_doxygen MAIN_TARGET)

    find_program(DOCX doxygen)
    if(NOT DOCX)
        message(FATAL_ERROR "Doxygen is not found - try apt-get install doxygen")
    endif()

    find_program(GRPHZ dot)
    if(NOT GRPHZ)
        message(FATAL_ERROR "graphviz for doxygen is not found - try apt-get install graphviz")
    endif()

    find_program(SPELL aspell)
    if(NOT SPELL)
        message(FATAL_ERROR "aspell for doxygen is not found - try apt-get install aspell")
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
        set(DOXYGEN_PROJECT_NAME ${MAIN_TARGET})
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
        doxygen_add_docs(DOXY_TARGET
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

    add_dependencies(${MAIN_TARGET} doxy)

endfunction()

function (add_spellcheck MAIN_TARGET)
    
    set(SPELL_EXCLUDE_DIRS 
        aspell
        .git
    )
    set(SPELL_EXCLUDE_FILES 
        doxygen.cmake
        graph_legend.html
        jquery.js
        \*.png
        \*.ttf
        \*.svg
        \*.jpg
    )

    set(SPELL_EXCLUDE_FILES_INTERNAL 
        doxygen.cmake
        graph_legend.html
        \*.png
        \*.ttf
        \*.svg
        \*.jpg
        \*.js
    )

    
    foreach(DE ${SPELL_EXCLUDE_DIRS})
        set(GREP_SPELL_EXCLUDE "${GREP_SPELL_EXCLUDE} --exclude-dir=${DE} ")
    endforeach()
    
    foreach(FE ${SPELL_EXCLUDE_FILES})
        set(GREP_SPELL_EXCLUDE "${GREP_SPELL_EXCLUDE} --exclude-dir=${FE} ")
    endforeach()
    
    foreach(DE ${CMAKEDOC_SPELL_EXCLUDE_DIRS})
        set(GREP_SPELL_EXCLUDE "${GREP_SPELL_EXCLUDE} --exclude-dir=${DE} ")
    endforeach()
    
    foreach(FE ${CMAKEDOC_SPELL_EXCLUDE_FILES})
        set(GREP_SPELL_EXCLUDE "${GREP_SPELL_EXCLUDE} --exclude=${FE} ")
    endforeach()

    foreach(FE ${SPELL_EXCLUDE_FILES_INTERNAL})
        set(FIND_SPELL_EXCLUDE "${FIND_SPELL_EXCLUDE} ! -name '${FE}' ")
    endforeach()

    if(FALSE) # todo in later versions if there is need to look beyond doxygendocs

    foreach(DE ${SPELL_EXCLUDE_DIRS})
        set(FIND_SPELL_EXCLUDE "${FIND_SPELL_EXCLUDE} ! -path '*/${DE}/*' ")
    endforeach()

    foreach(FE ${SPELL_EXCLUDE_FILES})
        set(FIND_SPELL_EXCLUDE "${FIND_SPELL_EXCLUDE} ! -name '${FE}' ")
    endforeach()
    
    foreach(DE ${CMAKEDOC_SPELL_EXCLUDE_DIRS})
        set(FIND_SPELL_EXCLUDE "${FIND_SPELL_EXCLUDE} ! -path '*/${DE}/*' ")
    endforeach()

    foreach(FE ${CMAKEDOC_SPELL_EXCLUDE_FILES})
        set(FIND_SPELL_EXCLUDE "${FIND_SPELL_EXCLUDE} ! -name '${FE}' ")
    endforeach()
    endif()

    set(SPELL_FILE_TYPE '*.html')
    
    set(CMAKEDOC_SPELL_WORKING_FOLDER "${CMAKE_BINARY_DIR}/html")
    set(CMAKEDOC_SPELL_DICTIONARY_FOLDER "${CMAKE_SOURCE_DIR}/aspell")
    set(CMAKEDOC_SPELL_DICTIONARY_FILE "${CMAKEDOC_SPELL_DICTIONARY_FOLDER}/spell_words.txt")
    file(MAKE_DIRECTORY ${CMAKEDOC_SPELL_DICTIONARY_FOLDER})
    if(NOT EXISTS ${CMAKEDOC_SPELL_DICTIONARY_FILE} )
        file(WRITE ${CMAKEDOC_SPELL_DICTIONARY_FILE}  "personal_ws-1.1 en 84 utf-8\nforwhich\nPrivateBase\nProtectedBase\nPublicBase\nTempl\nusedClass")
    endif()
    # if spellchecker lists any words, either fix that or add into ${CMAKEDOC_SPELL_DICTIONARY_FILE}
    set(SPELL_CMD "find . -type f -name ${SPELL_FILE_TYPE} ${FIND_SPELL_EXCLUDE} -exec cat {} \; | ${SPELL} list -H -p ${CMAKEDOC_SPELL_DICTIONARY_FILE} | sort | uniq | while read -r word; do grep -r ${GREP_SPELL_EXCLUDE} -n -m 1  \"\$word\" ${CMAKE_SOURCE_DIR}; echo \"when looking for $word\"; done")
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


    if(NOT TARGET doxy)
         add_custom_target(doxy)
    endif()
    add_dependencies(doxy doxy_spell_bin)

    if(TARGET doxy_docs)
        add_dependencies(doxy_spell_bin doxy_docs)
    endif()

endfunction()


