#include "driver.hpp"
#include "parser.hpp"

calcxx_driver::calcxx_driver (const std::string &f)
  : scanner( new scanner_string(this, f)), file(f)
{
}

calcxx_driver::~calcxx_driver ()
{
    delete scanner;
}

int calcxx_driver::parse ()
{
  scanner->scan_begin ();
  yy::calcxx_parser parser (*this);
  int res = parser.parse ();
  scanner->scan_end ();
  return res;
}

void calcxx_driver::error (const yy::location& l, const std::string& m)
{
  std::cerr << l << ": " << m << std::endl;
}

void calcxx_driver::error (const std::string& m)
{
  std::cerr << m << std::endl;
}
