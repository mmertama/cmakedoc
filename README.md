# CMakeDoc
Utility to add doxygen and spell checker into a cmake project.

#### Requirements
* aspell
* doxygen
* graphviz

### add_doxygen(${PROJECT_NAME})
Adds Doxygen in the project. Doxygen documentation will be in the documentation appears in ${CMAKE_BINARY_DIR}/html.
#### variables
* CMAKEDOC_DOXYGEN_DOCUMENTS
    * List files to document.
* Common DOXYGEN_* variables 
    * [See e.g.](https://r2devops.io/marketplace/gitlab/r2devops/hub/doxygen)

### add_spellcheck(${PROJECT_NAME})
Adds spellchecker in the project. The add_doxygen generated files are spellchecked.
On error the build error looks like 

```
Spelling errors:
looking for fengine:
/home/markus/Development/FigmaQML/app_figma/FigmaQmlInterface/FigmaQmlInterface.hpp:26:     * @brief Static to fetch this instance from fengine


```

Which tells the misspelled word and it's location. If there is an error you either fix spelling or add the word in the dictionary file. 

The spellcheck is done only against doxygen documentation, but the used (misspelled) words are searched from the source folder. Hence the CMAKEDOC_SPELL_EXCLUDE_FILES and CMAKEDOC_SPELL_EXCLUDE_DIRS only affects to where misspelled words are looked for, not what files are actually
processed.

#### variables 
* CMAKEDOC_SPELL_EXCLUDE_FILES
    * Files to exclude.
* CMAKEDOC_SPELL_EXCLUDE_DIRS
    * Directories to exclude.
* CMAKEDOC_SPELL_DICTIONARY
    * Dictionary file to use.
* CMAKEDOC_SPELL_CONFIG
    * Config file to override (if needed) - see aspell documentation.    

## Example

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


# Exclude folders you do not want to be spellchecked     

    set(CMAKEDOC_SPELL_EXCLUDE_DIRS
        build
        aspell
        modules
        res
        .git
        FigmaQML
        OpenSSL*)

# Exclude files you do not want to be spellchecked        
        
    set(CMAKEDOC_SPELL_EXCLUDE_FILES
        \*.qmlproject*)
        
# Add spellchecker in the project
    set(CMAKEDOC_SPELL_DICTIONARY "spell_dictionary.txt")
    add_spellcheck(${PROJECT_NAME})
endif()
```


