#include "driver.hpp"
#include "nodes.hpp"
#include "parser.hpp"

calcxx_driver::calcxx_driver (const std::string &f, NodeKeeper& nk)
  : scanner( new scanner_string(this, f)),  nodeKeeper(nk), file("no-file"), str(f), result(nullptr)
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
  int lineb = l.begin.line;
  int linee = l.end.line;
  int colb = l.begin.column;
  int cole = l.end.column;

  //TODO: multiline?

  std::cerr << "  => " << str << std::endl;
  std::cerr << "     ";
  for (int i =0; i < colb-1; ++i) std::cerr << " ";
  std::cerr << "^";
  for (int i =0; i < cole - colb; ++i) std::cerr << "~";
  std::cerr << std::endl;
}

void calcxx_driver::error (const std::string& m)
{
  std::cerr << m << std::endl;
}
