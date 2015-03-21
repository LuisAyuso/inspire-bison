%{ /* -*- C++ -*- */
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <string>
# include "driver.hpp"
# include "parser.hpp"

// Work around an incompatibility in flex (at least versions
// 2.5.31 through 2.5.33): it generates code that does
// not conform to C89.  See Debian bug 333231
// <http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=333231>.
# undef yywrap
# define yywrap() 1

// The location of the current token.
static yy::location loc;
%}


%option noyywrap nounput batch debug noinput


id    [a-zA-Z][a-zA-Z0-9_]*
int   [0-9]+
float   [0-9]\.[0-9]+
blank [ \t]

%{
  // Code run each time a pattern is matched.
  # define YY_USER_ACTION  loc.columns (yyleng);
%}

%%

%{
  // Code run each time yylex is called.
  loc.step ();
%}

{blank}+   loc.step ();
[\n]+      loc.lines (yyleng); loc.step ();
"-"      return yy::calcxx_parser::make_MINUS(loc);
"+"      return yy::calcxx_parser::make_PLUS(loc);
"*"      return yy::calcxx_parser::make_STAR(loc);
"/"      return yy::calcxx_parser::make_SLASH(loc);
"("      return yy::calcxx_parser::make_LPAREN(loc);
")"      return yy::calcxx_parser::make_RPAREN(loc);
":="     return yy::calcxx_parser::make_ASSIGN(loc);


{int}      {
  errno = 0;
  long n = strtol (yytext, NULL, 10);
  if (! (INT_MIN <= n && n <= INT_MAX && errno != ERANGE))
    driver.error (loc, "integer is out of range");
  return yy::calcxx_parser::make_NUMBER(n, loc);
}

{id}       return yy::calcxx_parser::make_IDENTIFIER(yytext, loc);
.          driver.error (loc, "invalid character");
<<EOF>>    return yy::calcxx_parser::make_END(loc);

%%

// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


void scanner_stdin::scan_begin(){
    yyin=stdin;
}
void scanner_stdin::scan_end(){
}

void scanner_string::scan_begin(){
    yy_flex_debug = 0;
    yy_scan_string(str.c_str());
}
void scanner_string::scan_end(){
    yylex_destroy();
    loc.initialize();
}

void scanner_file::scan_begin(){
    yy_flex_debug = 0;
    if (!(yyin = fopen (file.c_str (), "r")))
    {
      driver->error ("cannot open " + file + ": " + strerror(errno));
      exit (EXIT_FAILURE);
    }
    loc.initialize();
}

void scanner_file::scan_end(){
    fclose (yyin);
    loc.initialize();
}
