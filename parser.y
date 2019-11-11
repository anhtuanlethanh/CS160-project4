%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <iostream>

    #include "ast.hpp"

    #define YYDEBUG 1
    int yylex(void);
    void yyerror(const char *);

    extern ASTNode* astRoot;
%}

%error-verbose

/* WRITEME: Copy your token and precedence specifiers from Project 3 here */
%token  T_NUMBER
%token  T_IDENTIFIER
%token  T_GREATER T_GEQ
%token  T_LESS
%token  T_EQUALS
%token  T_LEQ
%token  T_PLUS '-'
%token  T_MULT T_DIV
%token  '='
%token  '{'
%token  '}'
%token  '('
%token  ')'
%token  '.'
%token  ','
%token  T_OR T_AND
%token  T_NOT
%token  T_PRINT
%token  T_RETURN
%token  T_IF
%token  T_ELSE
%token  T_WHILE
%token  T_NEW
%token  T_INTEGER
%token  T_BOOL
%token  T_NONE
%token  T_TRUE
%token  T_FALSE
%token  T_EXTENDS
%token  T_DO
%token  ';'
%token T_POINT

/* WRITEME: Specify precedence here */
%left T_OR
%left T_AND
%left T_GREATER T_GEQ T_EQUALS
%left T_PLUS '-'
%left T_MULT T_DIV
%precedence T_NOT unaryminus

/* WRITEME: Specify types for all nonterminals and necessary terminals here */

%type <program_ptr> Start
%type <class_list_ptr> classes
%type <class_ptr> class members_methods
%type <identifier_ptr> T_IDENTIFIER
%type <integer_ptr> T_NUMBER
%type <declaration_list_ptr> members declarations
%type <method_list_ptr> methods
%type <method_ptr> method
%type <parameter_list_ptr> parameters
%type <type_ptr> Type ReturnType
%type <methodbody_ptr> Body
%type <statement_list_ptr> statements Block
%type <returnstatement_ptr> returnStatement
%type <parameter_ptr> parameter
%type <declaration_ptr> declaration member
%type <identifier_list_ptr> identifiers
%type <expression_ptr> Expression
%type <assignment_ptr> assignment
%type <call_ptr> Method_call
%type <methodcall_ptr> methodcall
%type <ifelse_ptr> IfElse
%type <while_ptr> while
%type <dowhile_ptr> do_while_loop
%type <print_ptr> print
%type <expression_list_ptr> Arguments Arguments_
%type <memberaccess_ptr> member_access
/*
%type <booleanliteral_ptr>
%type <integertype_ptr>
%type <booleantype_ptr>
%type <objecttype_ptr>*/
%type <statement_ptr> statement
%%

/* WRITEME: This rule is a placeholder. Replace it with your grammar
            rules from Project 3 */

Start : classes { $$ = new ProgramNode($1); astRoot = $$; }
    ;

classes : classes class { $$ = $1; $$->push_back($2); }
      | class { $$ = new std::list<ClassNode*>(); $$->push_back($1); }
      ;

class : T_IDENTIFIER T_EXTENDS T_IDENTIFIER '{' members_methods '}' { $5->identifier_1 = $1; $5->identifier_2 = $3; $$ = $5; }
    | T_IDENTIFIER '{' members_methods '}' { $3->identifier_1 = $1; $$ = $3; }
	  ;
    ;

members_methods : members { $$ = new ClassNode(NULL, NULL, $1, new std::list<MethodNode*>()); }
              | methods { $$ = new ClassNode(NULL, NULL, new std::list<DeclarationNode*>(), $1); }
              | members methods { $$ = new ClassNode(NULL, NULL, $1, $2); }
              | %empty { $$ = new ClassNode(NULL, NULL, new std::list<DeclarationNode*>(), new std::list<MethodNode*>()); }
              ;

members : members member { $$ = $1; $$->push_back($2); }
      | member { $$ = new std::list<DeclarationNode*>(); $$->push_back($1); }
      ;

methods : methods method { $$ = $1; $$->push_back($2); }
      | method { $$ = new std::list<MethodNode*>(); $$->push_back($1); }
      ;

member : Type T_IDENTIFIER ';' { std::list<IdentifierNode*> *s = new std::list<IdentifierNode*>(); s->push_back($2); $$ = new DeclarationNode($1, s); }
     ;

Type : T_INTEGER { $$ = new IntegerTypeNode; }
   | T_BOOL { $$ = new BooleanTypeNode; }
   | T_IDENTIFIER { $$ = new ObjectTypeNode($1); }
   ;

method : T_IDENTIFIER '(' parameters ')' T_POINT ReturnType '{' Body returnStatement '}' { $$ = new MethodNode($1, $3, $6, $8); }
     ;

ReturnType : T_BOOL { $$ = new BooleanTypeNode; }
         | T_INTEGER { $$ = new IntegerTypeNode; }
         | T_IDENTIFIER { $$ = new ObjectTypeNode($1); }
         | T_NONE { $$ = new NoneNode; }
         ;
parameters : parameters ',' parameter { $$ = $1; $$->push_back($3); }
         | parameter { $$ = new std::list<ParameterNode*>(); $$->push_back($1); }
         | %empty { $$ = NULL; }
         ;

parameter : Type T_IDENTIFIER { $$ = new ParameterNode($1, $2); }
         ;

Body : declarations statements returnStatement { $$ = new MethodBodyNode($1, $2, $3); }
   | declarations returnStatement { $$ = new MethodBodyNode($1, new std::list<StatementNode*>(), $2); }
   | statements returnStatement { $$ = new MethodBodyNode(new std::list<DeclarationNode*>(), $1, $2); }
   | returnStatement { $$ = new MethodBodyNode(new std::list<DeclarationNode*>(), new std::list<StatementNode*>(), $1); }
   ;

declarations : declarations declaration { $$ = $1; $$->push_back($2); }
           | declaration { $$ = new std::list<DeclarationNode*>(); $$->push_back($1); }
           ;

declaration : Type identifiers ';' { $$ = new DeclarationNode($1, $2); }
          ;

identifiers : identifiers ',' T_IDENTIFIER { $$ = $1; $$->push_back($3); }
          | T_IDENTIFIER { $$ = new std::list<IdentifierNode*>(); $$->push_back($1); }
          ;

returnStatement : T_RETURN Expression ';' { $$ = new ReturnStatementNode($2); }
              | %empty { $$ = NULL; }
              ;

statements : statements statement { $$ = $1; $$->push_back($2); }
         | statement { $$ = new std::list<StatementNode*>(); $$->push_back($1); }
         ;

statement : assignment { $$ = $1; }
        | Method_call { $$ = $1; }
        | if_else { $$ = $1; }
        | while_loop { $$ = $1; }
        | do_while_loop { $$ = $1; }
        | print { $$ = $1; }
        ;

assignment : T_IDENTIFIER '=' Expression ';' { $$ = new AssignmentNode($1, NULL, $3); }
         | T_IDENTIFIER '.' T_IDENTIFIER '=' Expression ';' { $$ = new AssignmentNode($1, $3, $5); }
         ;

Method_call : method_call ';' { $$ = new CallNode($1); }
          ;

if_else : T_IF Expression '{' Block '}' { $$ = new IfElseNode($2, $4, NULL); }
      | T_IF Expression '{' Block '}' T_ELSE '{' Block '}' { $$ = new IfElseNode($2, $4, $8); }
      ;

while_loop : T_WHILE Expression '{' Block '}' { $$ = new WhileNode($2, $4); }
         ;

do_while_loop : T_DO '{' Block '}' T_WHILE '(' Expression ')' ';' { $$ = new DoWhileNode($3, $7); }
            ;

Block : statements { $$ = $1; }
    ;

print : T_PRINT Expression ';' { $$ = new PrintNode($2); }
    ;

Expression	:	Expression T_PLUS Expression { $$ = new PlusNode($1, $3); }
          |	Expression '-' Expression { $$ = new MinusNode($1, $3); }
          |	Expression T_MULT Expression { $$ = new TimesNode($1, $3); }
          |	Expression T_DIV Expression { $$ = new DivideNode($1, $3); }
          |	Expression T_GREATER Expression { $$ = new GreaterNode($1, $3); }
          |	Expression T_GEQ Expression { $$ = new GreaterEqualNode($1, $3); }
          |	Expression T_EQUALS Expression { $$ = new EqualNode($1, $3); }
          |	Expression T_AND Expression { $$ = new AndNode($1, $3); }
          |	Expression T_OR Expression { $$ = new OrNode($1, $3); }
          |	T_NOT Expression { $$ = new NotNode($2); }
          |	'-' Expression %prec unaryminus { $$ = new NegationNode($2); }
          | T_IDENTIFIER { $$ = new VariableNode($1); }
          |	member_access { $$ = $1; }
          |	method_call { $$ = $1; }
          |	'(' Expression ')' { $$ = $2; }
          |	T_NUMBER { $$ = new IntegerLiteralNode($1); }
          |	T_TRUE { $$ = new BooleanLiteralNode(new IntegerNode(1)); }
          |	T_FALSE { $$ = new BooleanLiteralNode(new IntegerNode(0)); }
          |	T_NEW T_IDENTIFIER { $$ = new NewNode($2, NULL); }
          |	T_NEW T_IDENTIFIER '(' Arguments ')' { $$ = new NewNode($2, $4); }
          ;

member_access : T_IDENTIFIER '.' T_IDENTIFIER { $$ = new MemberAccessNode($1, $3); }
            ;

method_call : T_IDENTIFIER '(' Arguments ')' { $$ = new MethodCallNode($1, NULL, $3); }
          | T_IDENTIFIER '.' T_IDENTIFIER '(' Arguments ')' { $$ = new MethodCallNode($1, $3, $5); }
          ;

Arguments : Arguments_ { $$ = $1; }
        | %empty { $$ = new std::list<ExpressionNode*>(); }
        ;

Arguments_ : Arguments_ ',' Expression { $$ = $1; $$->push_back($3); }
        | Expression { $$ = new std::list<ExpressionNode*>(); $$->push_back($1); }
        ;

%%

extern int yylineno;

void yyerror(const char *s) {
  fprintf(stderr, "%s at line %d\n", s, yylineno);
  exit(0);
}
