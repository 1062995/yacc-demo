%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
void debug(char *fmt, ...);
extern int yylex(void);
extern void yyerror(const char *);
extern FILE *yyin;

int enable_debug = 1;
%}


%union {
    int number;
    char *string;
}

%token AND
%token DO
%token ELSE
%token END
%token EQ
%token GE
%token GT
%token IF
%token LE
%token LET
%token LT
%token NE
%token NOT
%token OR
%token PRINT
%token THEN
%token VAR
%token WHILE

%token <number> NUMBER
%token <string> NAME

%left EQ NE LT GT LE GE
%left AND OR
%left '+' '-'
%left '*' '/' '%'
%nonassoc NOT

%%

program: statements              { debug("program -> statements"); }
       ;

statements: statements statement { debug("statements -> statements statement"); }
          | statement            { debug("statements -> statement"); }
          ;

statement: let_statement         { debug("statement -> let_statement"); }
         | print_statement       { debug("statement -> print_statement"); }
         | if_statement          { debug("statement -> if_statement"); }
         | while_statement       { debug("statement -> while_statement"); }
         ;

let_statement: LET NAME EQ exp
        { debug("let_statement -> LET NAME EQ exp"); }

print_statement: PRINT exp
        { debug("print_statement -> PRINT exp"); }

if_statement: IF cond DO statements END
                 { debug("if_statement -> IF cond DO statements END"); }
            | IF cond THEN statements ELSE statements END
                 { debug("if_statement -> IF cond THEN statements ELSE statements END"); }

while_statement: WHILE cond DO statements END
        { debug("while_statement -> WHILE cond DO statements END"); }

cond: exp EQ exp         { debug("cond -> exp EQ exp"); }
    | exp NE exp         { debug("cond -> exp NE exp"); }
    | exp LT exp         { debug("cond -> exp LT exp"); }
    | exp GT exp         { debug("cond -> exp GT exp"); }
    | exp LE exp         { debug("cond -> exp LE exp"); }
    | exp GE exp         { debug("cond -> exp GE exp"); }
    | NOT cond %prec NOT { debug("cond -> NOT cond"); }
    | cond AND cond      { debug("cond -> cond AND cond"); }
    | cond OR cond       { debug("cond -> cond OR cond"); }
    | '(' cond ')'       { debug("cond -> '(' cond ')'"); }
    ;

exp: exp '+' exp         { debug("exp -> exp + exp"); }
   | exp '-' exp         { debug("exp -> exp - exp"); }
   | exp '*' exp         { debug("exp -> exp * exp"); }
   | exp '/' exp         { debug("exp -> exp / exp"); }
   | exp '%' exp         { debug("exp -> exp %% exp"); }
   | '(' exp ')'         { debug("exp -> ( exp )"); }
   | NUMBER              { debug("exp -> NUMBER=%d", $1); }
   | NAME                { debug("exp -> NAME=%s", $1); }
   ;

%%

void debug(char *fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    if (enable_debug) {
        printf(" ** ");
        vprintf(fmt, ap);
        printf("\n");
    }
    va_end(ap);
}

void yyerror(const char *s)
{
    fprintf(stderr, "%s\n", s);
    exit(1);
}

int main(int argc, char *argv[])
{
    if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            perror("Failed to open source file");
            exit(1);
        }
    }
    yyparse();
    printf("parse ok\n");
    return 0;
}
