%skeleton "lalr1.cc" /* -*- C++ -*- */
%require "3.0.4"
%defines
%define parser_class_name {inspire_parser}
%define api.namespace {insieme::core::parser3}
%define api.token.constructor
%define api.value.type variant
%define parse.assert
%code requires
{
    # include <string>
    # include "nodes.hpp"
    namespace insieme{
    namespace core{
    namespace parser3{
    class inspire_driver;
    } // parser3
    } // core
    } // insieme
}

// The parsing context.
%param { insieme::core::parser3::inspire_driver& driver }
%locations
%initial-action
{
  // Initialize the initial location.
  @$.initialize(&driver.file);
};

// DEBUG
%define parse.trace
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

%type  <NLambdaExpression*> function_decl global_ctx
%type  <NNode*> symbol_reference
%type  <NStatement*> program statement compound_statement decl_stmt
%type  <NVariableDecl*> var_decl 
%type  <std::vector<NVariableDecl*> > param_list  
%type  <NType*> type 
%type  <NExpression*> expression unary_expression binary_expression ternary_expression initialization
%type  <std::vector<NExpression*> > expr_list
%type  <std::vector<NStatement*> > statement_list decl_ctx
%type  <std::vector<NType*> > type_list
%type  <std::string> "Number" 
%type  <std::string> "indentifier" 

%printer { yyoutput << $$; } <std::string>

%%

%start program;
program : expression {driver.result = $1; }
        | statement { driver.result = $1; }
        | global_ctx { driver.result = $1; }
        ;

global_ctx : let_list { driver.scopes.open_scope(); driver.error(@$, "let bindings without use"); $$ = nullptr; }
           | let_list function_decl { std::swap($$, $2); }
           | function_decl { std::swap($$, $1); }
           ;

function_decl : type IDENTIFIER "(" param_list ")" compound_statement { } 
              ;

param_list : var_decl { $$.push_back($1); }
           | param_list "," var_decl { $1.push_back($3); }
           ;

type : symbol_reference { $$ = static_cast<NType*>($1); }
     | INTEGER { $$ = driver.nodeKeeper.getNode<NIntTypeParam>($1); }
     | IDENTIFIER "<" type_list ">" { $$ = driver.nodeKeeper.getNode<NComposedType>($1, $3); }
     | "(" type_list ")" "->" type { $$ = driver.nodeKeeper.getNode<NFuncType>($2, $5); }
     | "(" type_list ")" "=>" type { $$ = driver.nodeKeeper.getNode<NClosureType>($2, $5); }
     ;

type_list : /* empty */ { }
          | type  { $$.push_back($1); }
          | type_list "," type  { $1.push_back($3); }
          ;

let_binding : "let" IDENTIFIER "=" type ";" { driver.scopes.add_symb($2, $4); }
            ;

let_list : let_binding {} 
         | let_list let_binding {}
         ;

statement : compound_statement { std::swap($$, $1); }   
          | decl_stmt   { $$ = $1; }
          | "for" "(" type IDENTIFIER "=" expression ".." expression  ")" statement { $$ = driver.nodeKeeper.getNode<NForLoop>($3, driver.nodeKeeper.getNode<NSynbolExpr>($4),$6,$8,$10); }
          | "while" "(" expression ")"  statement { $$ = driver.nodeKeeper.getNode<NWhileLoop>($3,$5); }
          | expression ";" { $$ = $1; }
          ;

decl_stmt : var_decl "=" initialization{ $1->initialization = $3; $$ = static_cast<NStatement*>($1); }
          ;

initialization : /* empty */ { $$ = nullptr; }
               | expression { $$ = $1; }

var_decl : type IDENTIFIER { $$ = driver.nodeKeeper.getNode<NVariableDecl>($1, $2); }

compound_statement : "{" "}" { $$ = driver.nodeKeeper.getNode<NCompound>(); } 
                   | "{" decl_ctx "}" { driver.scopes.close_scope(); $$ = driver.nodeKeeper.getNode<NCompound>($2); }
                   ;

decl_ctx : let_list { driver.scopes.open_scope(); driver.error(@$, "let bindings without use"); }
         | let_list statement_list { std::swap($$, $2); }
         | statement_list { std::swap($$, $1); }
         ;

statement_list : statement   { driver.scopes.open_scope(); $$.push_back($1); }
               | statement_list statement { $1.push_back($2); std::swap($$, $1); }
               ;

symbol_reference : IDENTIFIER { auto tmp = driver.scopes.find($1); $$ = (tmp)? tmp: driver.nodeKeeper.getNode<NSynbolExpr>($1);}
                 ;

expression : symbol_reference { $$ = static_cast<NExpression*>($1); }
           | INTEGER     { $$ = driver.nodeKeeper.getNode<NLiteralExpr>($1); }
           | REAL     { $$ = driver.nodeKeeper.getNode<NLiteralExpr>($1); }
           |"(" expression ")" { std::swap($$, $2); }
           | expression "(" expr_list ")" { $$ = driver.nodeKeeper.getNode<NCallExpr>($1, $3); }
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

void insieme::core::parser3::inspire_parser::error (const location_type& l, const std::string& m) {
  driver.error (l, m);
}
