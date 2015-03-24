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
  ASSIGN  "="
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

  ARROW   "->"
  DARROW  "=>"

  SEMIC   ";"
  COMA    ","
  RANGE   ".."
  DOT     "."

  LET   "let"    
  AUTO   "auto"    
  IF     "if"      
  ELSE   "else"    
  FOR    "for"     
  WHILE  "while"   
  RETURN "return"  
;

%token <std::string> IDENTIFIER "identifier"
%token <std::string> INTEGER "integer"
%token <std::string> REAL "real"

%type  <NStatement*> program statement compound_statement 
%type  <NType*> type 
%type  <NExpression*> expression unary_expression binary_expression ternary_expression
%type  <std::vector<NExpression*> > expr_list
%type  <std::vector<NStatement*> > statement_list decl_ctx
%type  <std::vector<NType*> > type_list
%type  <std::string> "Number" 
%type  <std::string> "indentifier" 

%printer { yyoutput << $$; } <*>;

%%

%start program;
program : statement { driver.result = $1; }
        ;

type : IDENTIFIER { $$ = driver.nodeKeeper.getNode<NLitType>($1); }
     | INTEGER { $$ = driver.nodeKeeper.getNode<NIntTypeParam>($1); }
     | IDENTIFIER "<" type_list ">" { $$ = driver.nodeKeeper.getNode<NComposedType>($1, $3); }
     | "(" type_list ")" "->" type { $$ = driver.nodeKeeper.getNode<NFuncType>($2, $5); }
     ;

type_list : /* empty */ { }
          | type  { $$.push_back($1); }
          | type_list "," type  { $1.push_back($3); }
          ;

let_binding : "let" IDENTIFIER "=" type { driver.scopes.add_symb($2, $4); }
            ;

let_list : let_binding {} 
         | let_list let_binding {}
         ;

statement : compound_statement { std::swap($$, $1); }   
          | "for" "(" type IDENTIFIER "=" expression ".." expression  ")" statement { $$ = driver.nodeKeeper.getNode<NForLoop>($3, driver.nodeKeeper.getNode<NSynbolExpr>($4),$6,$8,$10); }
          | "while" "(" expression ")"  statement { $$ = driver.nodeKeeper.getNode<NWhileLoop>($3,$5); }
          | expression ";" { $$ = $1; }
          ;

compound_statement : "{" "}" { $$ = driver.nodeKeeper.getNode<NCompound>(); } 
                   | "{" decl_ctx "}" { driver.scopes.close_scope(); $$ = driver.nodeKeeper.getNode<NCompound>($2); }
                   ;

decl_ctx : let_list statement_list { std::swap($$, $2); }
         | statement_list { std::swap($$, $1); }
         ;

statement_list : statement   { driver.scopes.open_scope(); $$.push_back($1); }
               | statement_list statement { $1.push_back($2); std::swap($$, $1); }
               ;

expression : IDENTIFIER { $$ = driver.nodeKeeper.getNode<NSynbolExpr>($1); }
           | INTEGER     { $$ = driver.nodeKeeper.getNode<NLiteralExpr>($1); }
           | REAL     { $$ = driver.nodeKeeper.getNode<NLiteralExpr>($1); }
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
                  | expression "[" expression "]"  { $$ = driver.nodeKeeper.getNode<NBinaryExpr>(SUBSCRIPT, $1, $3); }
                  ;

ternary_expression : expression "?" expression ":" expression { $$ = driver.nodeKeeper.getNode<NTernaryExpr>($1, $3, $5); }
                   ;

%left "+" "-";
%left "*" "/";

%%

void yy::calcxx_parser::error (const location_type& l, const std::string& m) {
  driver.error (l, m);
}
