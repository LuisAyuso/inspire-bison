#ifndef CALCXX_DRIVER_HH
#define CALCXX_DRIVER_HH
#include <string>
#include <iostream>
#include <map>

#include "nodes.hpp"
#include "parser.hpp"
#include "scanner.h"

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
  calcxx_driver (const std::string& f);
  virtual ~calcxx_driver ();

  std::map<std::string, int> variables;

  int result;

  // Run the parser on file F.
  // Return 0 on success.
  int parse ();

  // The name of the file being parsed.
  // Used later to pass the file name to the location tracker.
  std::string file;

  // Error handling.
  void error (const yy::location& l, const std::string& m);
  void error (const std::string& m);
};
#endif // ! CALCXX_DRIVER_HH
