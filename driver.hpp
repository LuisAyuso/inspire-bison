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

class calcxx_driver;

class scanner_wrapper
{
public:
    calcxx_driver* driver;
    scanner_wrapper(calcxx_driver* driver)
    : driver(driver)
    {}
    virtual void scan_begin() =0;
    virtual void scan_end() =0;

    virtual ~scanner_wrapper(){}
};

class scanner_stdin : public scanner_wrapper{
public:
    scanner_stdin(calcxx_driver* driver)
    :scanner_wrapper(driver)
    { }
    void scan_begin();
    void scan_end();
};

class scanner_string : public scanner_wrapper{
    const std::string& str;
public:
    scanner_string(calcxx_driver* driver, const std::string& str)
    :scanner_wrapper(driver), str(str)
    { }
    void scan_begin();
    void scan_end();
};
class scanner_file : public scanner_wrapper{
    const std::string& file;
public:
    scanner_file(calcxx_driver* driver, const std::string& file)
    :scanner_wrapper(driver), file(file)
    { }
    void scan_begin();
    void scan_end();
};

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
