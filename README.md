# cmakedoc
Utility to add doxygen and spell checker into a cmake project

### add_doxygen(${PROJECT_NAME})
Adds Doxygen in the project, the documenation appears in ${CMAKE_BINARY_DIR}/html.
#### variables
* CMAKEDOC_DOXYGEN_DOCUMENTS
* Common DOXYGEN_* 

### add_spellcheck(${PROJECT_NAME})
Adds spellcheker in the project.
#### variables 
* CMAKEDOC_SPELL_EXCLUDE_FILES
* CMAKEDOC_SPELL_EXCLUDE_DIRS

## example

```
# Include Fetch content to retrieve repos on configuration time.

include(FetchContent)

# run only in LINUX and when NO_DOC is not defined.
if(LINUX AND NOT NO_DOC)

# Get cmakedoc.	

    FetchContent_Declare(
      cmakedoc
      GIT_REPOSITORY https://github.com/mmertama/cmakedoc.git
      GIT_TAG        main
    )
    
# Enable cmakedoc.    

    FetchContent_MakeAvailable(cmakedoc)
    
# Make cmakedoc functions available.
    
    include(${cmakedoc_SOURCE_DIR}/cmakedoc.cmake)

# Set sources you want to apply Doxygen    
    
    set(DOCUMENTATION_DOXYGEN_DOCUMENTS
        app_figma/FigmaQmlInterface/FigmaQmlInterface.hpp
        mcu_figma/FigmaQmlInterface/FigmaQmlInterface.hpp
    )

# Add Doxygen documents in the project
    
    add_doxygen(${PROJECT_NAME})
    set(CMAKEDOC_DOXYGEN_DOCUMENTS
        build
        aspell
        modules
        res
        .git
        FigmaQML
        OpenSSL*)

# Excude files you do not want to be spellchecked        
        
    set(CMAKEDOC_SPELL_EXCLUDE_FILES
        \*.qmlproject*)
        
# Add spellchecker in the project
        
    add_spellcheck(${PROJECT_NAME})
endif()
```


