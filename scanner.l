%{ /* -*- C++ -*- */
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <string>
# include "driver.hpp"
# include "nodes.hpp"
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


id    [a-zA-Z_][a-zA-Z0-9_]*
float   [0-9]*"."[0-9]+
int   [0-9]+
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
"{"      return yy::calcxx_parser::make_LCURBRACKET(loc);
"}"      return yy::calcxx_parser::make_RCURBRACKET(loc);
"["      return yy::calcxx_parser::make_LBRACKET(loc);
"]"      return yy::calcxx_parser::make_RBRACKET(loc);

"<"      return yy::calcxx_parser::make_LT(loc);
">"      return yy::calcxx_parser::make_GT(loc);
"<="     return yy::calcxx_parser::make_LEQ(loc);
">="     return yy::calcxx_parser::make_GEQ(loc);
"=="     return yy::calcxx_parser::make_EQ(loc);
"!="     return yy::calcxx_parser::make_NEQ(loc);

"!"      return yy::calcxx_parser::make_LNOT(loc);

"="      return yy::calcxx_parser::make_ASSIGN(loc);
"?"      return yy::calcxx_parser::make_QMARK(loc);
"::"      return yy::calcxx_parser::make_NAMESPACE(loc);
":"      return yy::calcxx_parser::make_COLON(loc);

"->"     return yy::calcxx_parser::make_ARROW(loc);
"=>"     return yy::calcxx_parser::make_DARROW(loc);

";"      return yy::calcxx_parser::make_SEMIC(loc);
","      return yy::calcxx_parser::make_COMA(loc);
".."      return yy::calcxx_parser::make_RANGE(loc);
"."      return yy::calcxx_parser::make_DOT(loc);

"let"    return yy::calcxx_parser::make_LET(loc);
"auto"    return yy::calcxx_parser::make_AUTO(loc);
"if"      return yy::calcxx_parser::make_IF(loc);
"else"    return yy::calcxx_parser::make_ELSE(loc);
"for"     return yy::calcxx_parser::make_FOR(loc);
"while"   return yy::calcxx_parser::make_WHILE(loc);
"return"   return yy::calcxx_parser::make_RETURN(loc);


{int}      {
  return yy::calcxx_parser::make_INTEGER(yytext, loc);
}

{float}      {
  return yy::calcxx_parser::make_REAL(yytext, loc);
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
