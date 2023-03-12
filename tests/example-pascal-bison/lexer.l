%{
#include <stdio.h>
#include <stdlib.h>

#include "timing.h"

#include "parser.tab.h"

#if (DEBUGLEXER==1)
#define PRINTF printf
#else
#define PRINTF(fmt,...)
#endif

int comment_depth = 0;
int line = 1;
%}

%x COMMENT

STRINGCONST   \'([^']|\'\')*\'
REALCONST     [0-9]+((\.[0-9]+)([Ee][+-][0-9]+)?|(\.[0-9]+)?([Ee][+-][0-9]+))
INTEGERCONST  [0-9]+

%%

<INITIAL,COMMENT>[ \t]+ ;
<INITIAL,COMMENT>[\n]   { line++; }

"true"|"false"       { PRINTF ("BOOLEANCONST:%d\n",line); return _BOOLEANCONST; }
{STRINGCONST}        { PRINTF ("STRINGCONST:%d\n",line); return _STRINGCONST; }
{REALCONST}          { PRINTF ("REALCONST:%d\n",line); return _REALCONST; }
{INTEGERCONST}       { PRINTF ("INTEGERCONST:%d\n",line); return _INTEGERCONST; }

"+"                  { PRINTF ("ADD:%d\n",line); return _ADD; }
":="                 { PRINTF ("ASSIGN:%d\n",line); return _ASSIGN; }
":"                  { PRINTF ("COLON:%d\n",line); return _COLON; }
","                  { PRINTF ("COMMA:%d\n",line); return _COMMA; }
"/"                  { PRINTF ("DIV:%d\n",line); return _DIV; }
"."                  { PRINTF ("DOT:%d\n",line); return _DOT; }
"="                  { PRINTF ("EQU:%d\n",line); return _EQU; }
">="                 { PRINTF ("GEQ:%d\n",line); return _GEQ; }
">"                  { PRINTF ("GTH:%d\n",line); return _GTH; }
".."                 { PRINTF ("INTERVAL:%d\n",line); return _INTERVAL; }
"["                  { PRINTF ("LBRACKET:%d\n",line); return _LBRACKET; }
"("                  { PRINTF ("LPARENT:%d\n",line); return _LPARENT; }
"<="                 { PRINTF ("LEQ:%d\n",line); return _LEQ; }
"<"                  { PRINTF ("LTH:%d\n",line); return _LTH; }
"*"                  { PRINTF ("MUL:%d\n",line); return _MUL; }
"<>"                 { PRINTF ("NEQ:%d\n",line); return _NEQ; }
"^"                  { PRINTF ("PTR:%d\n",line); return _PTR; }
"]"                  { PRINTF ("RBRACKET:%d\n",line); return _RBRACKET; }
")"                  { PRINTF ("RPARENT:%d\n",line); return _RPARENT; }
";"                  { PRINTF ("SEMIC:%d\n",line); return _SEMIC; }
"-"                  { PRINTF ("SUB:%d\n",line); return _SUB; }

"boolean"            { PRINTF ("BOOLEAN:%d\n",line); return _BOOLEAN; }
"char"               { PRINTF ("CHAR:%d\n",line); return _CHAR; }
"real"               { PRINTF ("REAL:%d\n",line); return _REAL; }
"integer"            { PRINTF ("INTEGER:%d\n",line); return _INTEGER; }

"and"                { PRINTF ("AND:%d\n",line); return _AND; }
"array"              { PRINTF ("ARRAY:%d\n",line); return _ARRAY; }
"begin"              { PRINTF ("BEGIN:%d\n",line); return _BEGIN; }
"case"               { PRINTF ("CASE:%d\n",line); return _CASE; }
"const"              { PRINTF ("CONST:%d\n",line); return _CONST; }
"do"                 { PRINTF ("DO:%d\n",line); return _DO; }
"downto"             { PRINTF ("DOWNTO:%d\n",line); return _DOWNTO; }
"else"               { PRINTF ("ELSE:%d\n",line); return _ELSE; }
"end"                { PRINTF ("END:%d\n",line); return _END; }
"file"               { PRINTF ("FILE:%d\n",line); return _FILE; }
"for"                { PRINTF ("FOR:%d\n",line); return _FOR; }
"forward"            { PRINTF ("FORWARD:%d\n",line); return _FORWARD; }
"function"           { PRINTF ("FUNCTION:%d\n",line); return _FUNCTION; }
"goto"               { PRINTF ("GOTO:%d\n",line); return _GOTO; }
"div"                { PRINTF ("IDIV:%d\n",line); return _IDIV; }
"if"                 { PRINTF ("IF:%d\n",line); return _IF; }
"mod"                { PRINTF ("IMOD:%d\n",line); return _IMOD; }
"in"                 { PRINTF ("IN:%d\n",line); return _IN; }
"label"              { PRINTF ("LABEL:%d\n",line); return _LABEL; }
"nil"                { PRINTF ("NIL:%d\n",line); return _NIL; }
"not"                { PRINTF ("NOT:%d\n",line); return _NOT; }
"of"                 { PRINTF ("OF:%d\n",line); return _OF; }
"or"                 { PRINTF ("OR:%d\n",line); return _OR; }
"packed"             { PRINTF ("PACKED:%d\n",line); return _PACKED; }
"procedure"          { PRINTF ("PROCEDURE:%d\n",line); return _PROCEDURE; }
"program"            { PRINTF ("PROGRAM:%d\n",line); return _PROGRAM; }
"record"             { PRINTF ("RECORD:%d\n",line); return _RECORD; }
"repeat"             { PRINTF ("REPEAT:%d\n",line); return _REPEAT; }
"set"                { PRINTF ("SET:%d\n",line); return _SET; }
"step"               { PRINTF ("STEP:%d\n",line); return _STEP; }
"then"               { PRINTF ("THEN:%d\n",line); return _THEN; }
"to"                 { PRINTF ("TO:%d\n",line); return _TO; }
"type"               { PRINTF ("TYPE:%d\n",line); return _TYPE; }
"until"              { PRINTF ("UNTIL:%d\n",line); return _UNTIL; }
"var"                { PRINTF ("VAR:%d\n",line); return _VAR; }
"while"              { PRINTF ("WHILE:%d\n",line); return _WHILE; }
"with"               { PRINTF ("WITH:%d\n",line); return _WITH; }

[A-Za-z][A-Za-z0-9]* { PRINTF ("IDENTIFIER:%d\n",line); return _IDENTIFIER; }

<INITIAL>\{ { comment_depth++; BEGIN(COMMENT); }
<COMMENT>\{ { comment_depth++; }
<COMMENT>\} { comment_depth--; if (comment_depth == 0) BEGIN(INITIAL); }
<COMMENT>.  ;

. {
    printf ("LEX: Unexpected character '%c' [%d].\n", yytext[0], yytext[0]);
    exit (1);
  }

%%

#ifdef MAIN
int main (int argc, char *argv[])
{
  if (argc == 1) {
	  while (yylex () != 0) {
	  }
	  return 0;
  }
  if (argc == 2) {
    BEGCLOCK(LEXER)
    for (int test = 0; test < TESTS; test++) {
      extern FILE *yyin;
      yyin = fopen(argv[1], "r");
      while (1) {
        int token = yylex();
        if (token == 0) break;
      }
      fclose(yyin);
    }
    ENDCLOCK(LEXER)
    printf ("LEXER  : %lf\n", clock_LEXER / TESTS);
    return 0;
  }
}
#endif
