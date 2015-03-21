#ifndef CALCXX_DRIVER_HH
# define CALCXX_DRIVER_HH
# include <string>
# include <iostream>
# include <map>
# include "parser.hpp"

// Tell Flex the lexer's prototype ...
# define YY_DECL \
  yy::calcxx_parser::symbol_type yylex (calcxx_driver& driver)
// ... and declare it for the parser's sake.
YY_DECL;

class scanner_wrapper
{

   scanner_wrapper(const std::string& str)
   {
   }

   scanner_wrapper(const std::istream& str)
   {
   }
};


// Conducting the whole scanning and parsing of Calc++.
class calcxx_driver
{
public:
  calcxx_driver ();
  virtual ~calcxx_driver ();

  std::map<std::string, int> variables;

  int result;

  // Handling the scanner.
  void scan_begin ();   // in scanner.l
  void scan_end ();     // in scanner.l
  bool trace_scanning;

  // Run the parser on file F.
  // Return 0 on success.
  int parse (const std::string& f);
  //int parse (const std::string)

  // The name of the file being parsed.
  // Used later to pass the file name to the location tracker.
  std::string file;

  // Whether parser traces should be generated.
  bool trace_parsing;

  // Error handling.
  void error (const yy::location& l, const std::string& m);
  void error (const std::string& m);
};
#endif // ! CALCXX_DRIVER_HH
