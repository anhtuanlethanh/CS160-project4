%option yylineno
%pointer

%{
    #include <stdlib.h>
    #include <errno.h>
    #include <limits.h>
    #include "ast.hpp"
    #include "parser.hpp"
    void yyerror(const char *);
%}

/* WRITEME: Copy any definitions and start conditions from Project 3 here */

%%

/* WRITEME: Copy your Flex rules from Project 3 here */
%x comment

%%

"/*"                { BEGIN(comment); }
<comment><<EOF>> { yyerror("dangling comment"); }
<comment>.        ;
<comment>\n       ;
<comment>"*/"       { BEGIN(INITIAL); }

0|([1-9][0-9]*)     { yylval.integer_ptr  = new IntegerNode(atoi(yytext)); return T_NUMBER; }
">"                 { return T_GREATER; }
">="                { return T_GEQ; }
"<"                 { return T_LESS; }
"<="                { return T_LEQ; }
"equals"            { return T_EQUALS; }
"+"                 { return T_PLUS; }
"-"                 { return '-'; }
"*"                 { return T_MULT; }
"/"                 { return T_DIV; }
"="                 { return '='; }
"{"                 { return '{'; }
"}"                 { return '}'; }
")"                 { return ')'; }
"("                 { return '('; }
"."                 { return '.'; }
","                 { return ','; }
"or"                { return T_OR; }
"and"               { return T_AND; }
"not"               { return T_NOT; }
"print"             { return T_PRINT; }
"return"            { return T_RETURN; }
"if"                { return T_IF; }
"else"              { return T_ELSE; }
"while"             { return T_WHILE; }
"new"               { return T_NEW; }
"integer"           { return T_INTEGER; }
"boolean"           { return T_BOOL; }
"none"              { return T_NONE; }
"true"              { return T_TRUE; }
"false"             { return T_FALSE; }
"extends"           { return T_EXTENDS; }
"do"                { return T_DO; }
";"                 { return ';'; }
"->"                { return T_POINT; }
[a-zA-Z][0-9a-zA-Z]* { yylval.identifier_ptr = new IdentifierNode(yytext); return T_IDENTIFIER; }
[\t\n]+           ;
[[:space:]]       ;
.                 { yyerror("invalid character"); }

%%

int yywrap(void) {
  return 1;
}
