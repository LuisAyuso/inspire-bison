%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.0.4"
%defines
%define parser_class_name {calcxx_parser}
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%code requires
{
# include <string>
# include "nodes.hpp"
class calcxx_driver;
}

// The parsing context.
%param { calcxx_driver& driver }
%locations
%initial-action
{
  // Initialize the initial location.
  @$.initialize(&driver.file);
};

// DEBUG
//%define parse.trace
%define parse.error verbose
%code
{
#include "driver.hpp"
#include "nodes.hpp"
}

%define api.token.prefix {TOK_}
%token 
  END  0  "end of file"
  ASSIGN  ":="
  MINUS   "-"
  PLUS    "+"
  STAR    "*"
  SLASH   "/"

  LPAREN  "("
  RPAREN  ")"
  LCURBRACKET  "{"
  RCURBRACKET  "}"
  LBRACKET  "["
  RBRACKET  "]"

  LT        "<"     
  GT        ">"     
  LEQ       "<="    
  GEQ       ">="    
  EQ        "=="    
  NEQ       "!="    

  LNOT      "!"
                                         
  QMARK   "?"
  COLON   ":"
  SEMIC   ";"
;
%token <std::string> IDENTIFIER "identifier"
%token <int> NUMBER "number"

%type  <NExpression*> expression unary_expression binary_expression ternary_expression
%type  <int> "Number" 
%type  <std::string> "indentifier" 
%type  <NStatement*> program statement

%printer { yyoutput << $$; } <*>;

%%

%start program;
program : statement { $$ = $1; }
        ;

statement : expression { $$ = $1; }
          ;

expression : IDENTIFIER { $$ = driver.nodeKeeper.getNode<NSynbolExpr>($1); }
           | NUMBER     { $$ = driver.nodeKeeper.getNode<NLiteralExpr>($1); }
           |"(" expression ")" { std::swap($$, $2); }
           | unary_expression  { $$ = $1; }
           | binary_expression { $$ = $1; }
           | ternary_expression { $$ = $1; }
           ;

unary_expression : "!" expression  { $$ = driver.nodeKeeper.getNode<NUnaryExpr>(1, $2); }
                  | "*" expression  { $$ = driver.nodeKeeper.getNode<NUnaryExpr>(2, $2); }
                  ;

binary_expression : expression "+" expression { $$ = driver.nodeKeeper.getNode<NBinaryExpr>(1, $1, $3); }
                  | expression "-" expression { $$ = driver.nodeKeeper.getNode<NBinaryExpr>(2, $1, $3); }
                  | expression "*" expression { $$ = driver.nodeKeeper.getNode<NBinaryExpr>(3, $1, $3); }
                  | expression "/" expression { $$ = driver.nodeKeeper.getNode<NBinaryExpr>(4, $1, $3); }
                  ;

ternary_expression : expression "?" expression ":" expression { $$ = driver.nodeKeeper.getNode<NTernaryExpr>($1, $3, $5); }
                   ;

%left "+" "-";
%left "*" "/";

%%

void yy::calcxx_parser::error (const location_type& l, const std::string& m) {
  driver.error (l, m);
}
