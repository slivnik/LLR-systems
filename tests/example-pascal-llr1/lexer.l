%{
#include <stdio.h>
#include <stdlib.h>

#include RSH

int comment_depth = 0;
int line = 1;

#if (DEBUGLEXER==1)
#define PRINTF printf
#else
#define PRINTF(fmt,...)
#endif

%}

%x COMMENT

STRINGCONST   \'([^']|\'\')*\'
REALCONST     [0-9]+((\.[0-9]+)([Ee][+-][0-9]+)?|(\.[0-9]+)?([Ee][+-][0-9]+))
INTEGERCONST  [0-9]+

%%

<INITIAL,COMMENT>[ \t]+ ;
<INITIAL,COMMENT>[\n]   { line++; }

"true"|"false"       { PRINTF ("BOOLEANCONST:%d\n",line); return SYMB_BOOLEANCONST; }
{STRINGCONST}        { PRINTF ("STRINGCONST:%d\n",line); return SYMB_STRINGCONST; }
{REALCONST}          { PRINTF ("REALCONST:%d\n",line); return SYMB_REALCONST; }
{INTEGERCONST}       { PRINTF ("INTEGERCONST:%d\n",line); return SYMB_INTEGERCONST; }

"+"                  { PRINTF ("ADD:%d\n",line); return SYMB_ADD; }
":="                 { PRINTF ("ASSIGN:%d\n",line); return SYMB_ASSIGN; }
":"                  { PRINTF ("COLON:%d\n",line); return SYMB_COLON; }
","                  { PRINTF ("COMMA:%d\n",line); return SYMB_COMMA; }
"/"                  { PRINTF ("DIV:%d\n",line); return SYMB_DIV; }
"."                  { PRINTF ("DOT:%d\n",line); return SYMB_DOT; }
"="                  { PRINTF ("EQU:%d\n",line); return SYMB_EQU; }
">="                 { PRINTF ("GEQ:%d\n",line); return SYMB_GEQ; }
">"                  { PRINTF ("GTH:%d\n",line); return SYMB_GTH; }
".."                 { PRINTF ("INTERVAL:%d\n",line); return SYMB_INTERVAL; }
"["                  { PRINTF ("LBRACKET:%d\n",line); return SYMB_LBRACKET; }
"("                  { PRINTF ("LPARENT:%d\n",line); return SYMB_LPARENT; }
"<="                 { PRINTF ("LEQ:%d\n",line); return SYMB_LEQ; }
"<"                  { PRINTF ("LTH:%d\n",line); return SYMB_LTH; }
"*"                  { PRINTF ("MUL:%d\n",line); return SYMB_MUL; }
"<>"                 { PRINTF ("NEQ:%d\n",line); return SYMB_NEQ; }
"^"                  { PRINTF ("PTR:%d\n",line); return SYMB_PTR; }
"]"                  { PRINTF ("RBRACKET:%d\n",line); return SYMB_RBRACKET; }
")"                  { PRINTF ("RPARENT:%d\n",line); return SYMB_RPARENT; }
";"                  { PRINTF ("SEMIC:%d\n",line); return SYMB_SEMIC; }
"-"                  { PRINTF ("SUB:%d\n",line); return SYMB_SUB; }

"boolean"            { PRINTF ("BOOLEAN:%d\n",line); return SYMB_BOOLEAN; }
"char"               { PRINTF ("CHAR:%d\n",line); return SYMB_CHAR; }
"real"               { PRINTF ("REAL:%d\n",line); return SYMB_REAL; }
"integer"            { PRINTF ("INTEGER:%d\n",line); return SYMB_INTEGER; }

"and"                { PRINTF ("AND:%d\n",line); return SYMB_AND; }
"array"              { PRINTF ("ARRAY:%d\n",line); return SYMB_ARRAY; }
"begin"              { PRINTF ("BEGIN:%d\n",line); return SYMB_BEGIN; }
"case"               { PRINTF ("CASE:%d\n",line); return SYMB_CASE; }
"const"              { PRINTF ("CONST:%d\n",line); return SYMB_CONST; }
"do"                 { PRINTF ("DO:%d\n",line); return SYMB_DO; }
"downto"             { PRINTF ("DOWNTO:%d\n",line); return SYMB_DOWNTO; }
"else"               { PRINTF ("ELSE:%d\n",line); return SYMB_ELSE; }
"end"                { PRINTF ("END:%d\n",line); return SYMB_END; }
"file"               { PRINTF ("FILE:%d\n",line); return SYMB_FILE; }
"for"                { PRINTF ("FOR:%d\n",line); return SYMB_FOR; }
"forward"            { PRINTF ("FORWARD:%d\n",line); return SYMB_FORWARD; }
"function"           { PRINTF ("FUNCTION:%d\n",line); return SYMB_FUNCTION; }
"goto"               { PRINTF ("GOTO:%d\n",line); return SYMB_GOTO; }
"div"                { PRINTF ("IDIV:%d\n",line); return SYMB_IDIV; }
"if"                 { PRINTF ("IF:%d\n",line); return SYMB_IF; }
"mod"                { PRINTF ("IMOD:%d\n",line); return SYMB_IMOD; }
"in"                 { PRINTF ("IN:%d\n",line); return SYMB_IN; }
"label"              { PRINTF ("LABEL:%d\n",line); return SYMB_LABEL; }
"not"                { PRINTF ("NOT:%d\n",line); return SYMB_NOT; }
"of"                 { PRINTF ("OF:%d\n",line); return SYMB_OF; }
"or"                 { PRINTF ("OR:%d\n",line); return SYMB_OR; }
"packed"             { PRINTF ("PACKED:%d\n",line); return SYMB_PACKED; }
"procedure"          { PRINTF ("PROCEDURE:%d\n",line); return SYMB_PROCEDURE; }
"program"            { PRINTF ("PROGRAM:%d\n",line); return SYMB_PROGRAM; }
"record"             { PRINTF ("RECORD:%d\n",line); return SYMB_RECORD; }
"repeat"             { PRINTF ("REPEAT:%d\n",line); return SYMB_REPEAT; }
"set"                { PRINTF ("SET:%d\n",line); return SYMB_SET; }
"step"               { PRINTF ("STEP:%d\n",line); return SYMB_STEP; }
"then"               { PRINTF ("THEN:%d\n",line); return SYMB_THEN; }
"to"                 { PRINTF ("TO:%d\n",line); return SYMB_TO; }
"type"               { PRINTF ("TYPE:%d\n",line); return SYMB_TYPE; }
"until"              { PRINTF ("UNTIL:%d\n",line); return SYMB_UNTIL; }
"var"                { PRINTF ("VAR:%d\n",line); return SYMB_VAR; }
"while"              { PRINTF ("WHILE:%d\n",line); return SYMB_WHILE; }
"with"               { PRINTF ("WITH:%d\n",line); return SYMB_WITH; }

[A-Za-z][A-Za-z0-9]* { PRINTF ("IDENTIFIER:%d\n",line); return SYMB_IDENTIFIER; }

<INITIAL>\{ { comment_depth++; BEGIN(COMMENT); }
<COMMENT>\{ { comment_depth++; }
<COMMENT>\} { comment_depth--; if (comment_depth == 0) BEGIN(INITIAL); }
<COMMENT>.  ;

. {
    printf ("LEX: Unexpected character '%c' [%d].\n", yytext[0], yytext[0]);
    exit (1);
  }

%%

/*** "nil"                { printf ("NIL:%d\n",line); return SYMB_NIL; } ***/

int yymode = 0;

int lexer ()
{
  int token;
  switch (yymode) { 
    case 0:
      yymode = 1;
      token = SYMB__LM;
      PRINTF ("LEX: %3d\n", token);
      return token;
    case 1: 
      token = yylex();
      if (token == SYMB__EOF) {
        yymode = 2;
        token = SYMB__RM;
        PRINTF ("LEX: %3d\n", token);
      }
      else {
        // PRINTF ("LEX: %3d %s\n", token, yytext);
      }
      return token;
    case 2:
      PRINTF ("LEX: %3d\n", token);
      return SYMB__EOF;
  }
}

#ifdef MAIN
int main()
{
  while (lexer() != SYMB__EOF) {
  }
  return 0;
}
#endif
