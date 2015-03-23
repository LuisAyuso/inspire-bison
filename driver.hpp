#pragma once
#ifndef CALCXX_DRIVER_HH
#define CALCXX_DRIVER_HH
#include <string>
#include <iostream>
#include <map>

#include "nodes.hpp"
#include "parser.hpp"
#include "scanner.h"

// FLex is still a primitive tool using macros:
// Tell Flex the lexer's prototype ...
# define YY_DECL \
  yy::calcxx_parser::symbol_type yylex (calcxx_driver& driver)
// ... and declare it for the parser's sake.
YY_DECL;
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


// Conducting the whole scanning and parsing of Calc++.
class calcxx_driver
{
    scanner_wrapper* scanner;    
public:
    calcxx_driver (const std::string& f, NodeKeeper& nk);
    virtual ~calcxx_driver ();

    NodeKeeper& nodeKeeper;
    std::string file;
    const std::string& str;       
    int result;

    int parse ();

    // Error handling.
    void error (const yy::location& l, const std::string& m);
    void error (const std::string& m);
};
#endif // ! CALCXX_DRIVER_HH
