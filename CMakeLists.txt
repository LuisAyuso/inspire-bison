cmake_minimum_required(VERSION 2.8)
   

    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag( -std=c++11 CXX11_Support )
    if(CXX11_Support)
        set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")
    else()
        message( "WARNING: --std=c++11 not supported by your compiler!" )
    endif()

# Create a variable called insieme_compiler_core_SOURCES containing all .cpp files:
file(GLOB_RECURSE inspire_parser_srcs src/*.cpp )
file(GLOB_RECURSE inspire_parser_incs include/*.h )
file(GLOB_RECURSE main src/*.cxx)

#################################### BISON ##################################################

FIND_PACKAGE(BISON 3.0 REQUIRED)

IF(BISON_FOUND)

    set(BISON_INPUT ${CMAKE_SOURCE_DIR}/src/parser.y)
    set(BISON_OUTPUT_PATH ${CMAKE_BINARY_DIR}/)
    set(BISON_O_FILE parser.cpp)
    set(BISON_OUTPUT ${BISON_OUTPUT_PATH}/${BISON_O_FILE})

    ADD_CUSTOM_COMMAND(
      SOURCE ${BISON_INPUT}
      COMMAND ${BISON_EXECUTABLE}
      ARGS -d
            --file-prefix=${BISON_OUTPUT_PATH}
           -o ${BISON_O_FILE}
          ${BISON_INPUT} 
      COMMENT "Generating parser.cpp"
      DEPENDS ${BISON_INPUT}
      OUTPUT ${BISON_OUTPUT}
)
ENDIF(BISON_FOUND)

#################################### FLEX ##################################################

FIND_PACKAGE(FLEX 2.5 REQUIRED)
IF(FLEX_FOUND)

    set(FLEX_INPUT ${CMAKE_SOURCE_DIR}/src/scanner.l)
    set(FLEX_OUTPUT ${CMAKE_BINARY_DIR}/scanner.cpp)

    ADD_CUSTOM_COMMAND(
      SOURCE ${FLEX_INPUT}
      COMMAND ${FLEX_EXECUTABLE}
      ARGS -o ${FLEX_OUTPUT}
          ${FLEX_INPUT} 
      COMMENT "Generating scanner.cpp"
      DEPENDS ${FLEX_INPUT}
      OUTPUT ${FLEX_OUTPUT}
)
ENDIF(FLEX_FOUND)

######################################################################################

include_directories(${CMAKE_SOURCE_DIR}/include)
include_directories(${BISON_OUTPUT_PATH})
include_directories(${FLEX_OUTPUT_PATH})
add_executable(exec ${main} ${inspire_parser_srcs} ${inspire_parser_incs} ${BISON_OUTPUT} ${FLEX_OUTPUT} ) 
add_dependencies(exec inspire_scanner)
