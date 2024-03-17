cmake_minimum_required (VERSION 3.21.1)

project(cmakedoc_test VERSION 0.0.1 LANGUAGES CXX)

add_executable(${PROJECT_NAME}
    test.hpp
    test.cpp
    spell_dictionary.txt
)

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

include(../cmakedoc.cmake)
set(DOCUMENTATION_DOXYGEN_DOCUMENTS test.hpp )
add_doxygen(${PROJECT_NAME})
set(CMAKEDOC_SPELL_DICTIONARY "spell_dictionary.txt")
set(CMAKEDOC_SPELL_EXCLUDE_DIRS build)
add_spellcheck(${PROJECT_NAME})    


