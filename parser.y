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
  END  0  "end of stream"
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
  NAMESPACE   "::"

  SEMIC   ";"
  COMA    ","
  DOT     "."
;
%token <std::string> IDENTIFIER "identifier"
%token <std::string> NUMBER "number"

%type  <NExpression*> expression unary_expression binary_expression ternary_expression
%type  <std::vector<NExpression*> > expr_list
%type  <std::vector<NStatement*> > statement_list
%type  <std::string> "Number" 
%type  <std::string> "indentifier" 
%type  <NStatement*> program statement compound_statement

%printer { yyoutput << $$; } <*>;

%%

%start program;
program : statement { $$ = $1; }
        ;

statement : compound_statement { std::swap($$, $1); }
          | expression ";" { $$ = $1; }
          ;

compound_statement : "{" statement_list "}" { $$ = driver.nodeKeeper.getNode<NCompound>($2); }

statement_list : /* empty */ { }
               | statement   { $$.push_back($1); }
               | statement_list ";" statement { $1.push_back($3); std::swap($$, $1); }
               ;

expression : IDENTIFIER { $$ = driver.nodeKeeper.getNode<NSynbolExpr>($1); }
           | NUMBER     { $$ = driver.nodeKeeper.getNode<NLiteralExpr>($1); }
           |"(" expression ")" { std::swap($$, $2); }
           | IDENTIFIER "(" expr_list ")" { $$ = driver.nodeKeeper.getNode<NCallExpr>(driver.nodeKeeper.getNode<NSynbolExpr>($1), $3); }
           | unary_expression  { $$ = $1; }
           | binary_expression { $$ = $1; }
           | ternary_expression { $$ = $1; }
           ;

expr_list : /* empty */{ }
          | expression { $$.push_back($1); }
          | expr_list "," expression { $1.push_back($3); std::swap($$, $1); }
          ;

unary_expression : "!" expression  { $$ = driver.nodeKeeper.getNode<NUnaryExpr>(NOT, $2); }
                  | "*" expression  { $$ = driver.nodeKeeper.getNode<NUnaryExpr>(DEREF, $2); }
                  | "-" expression  { $$ = driver.nodeKeeper.getNode<NUnaryExpr>(MINUS, $2); }
                  ;

binary_expression : expression "*" expression { $$ = driver.nodeKeeper.getNode<NBinaryExpr>(MUL, $1, $3); }
                  | expression "/" expression { $$ = driver.nodeKeeper.getNode<NBinaryExpr>(DIV, $1, $3); }
                  | expression "+" expression { $$ = driver.nodeKeeper.getNode<NBinaryExpr>(SUM, $1, $3); }
                  | expression "-" expression { $$ = driver.nodeKeeper.getNode<NBinaryExpr>(SUB, $1, $3); }
                  | expression "%" expression { $$ = driver.nodeKeeper.getNode<NBinaryExpr>(MOD, $1, $3); }
                  ;

ternary_expression : expression "?" expression ":" expression { $$ = driver.nodeKeeper.getNode<NTernaryExpr>($1, $3, $5); }
                   ;

%left "+" "-";
%left "*" "/";

%%

void yy::calcxx_parser::error (const location_type& l, const std::string& m) {
  driver.error (l, m);
}
