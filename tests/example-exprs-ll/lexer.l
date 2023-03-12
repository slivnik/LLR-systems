%{
#include <stdio.h>
#include <stdlib.h>

#include "timing.h"

#include RSH

int comment_depth = 0;
int line = 1;

#if (DEBUGLEXER==1)
#define PRINTF printf
#else
#define PRINTF(fmt,...)
#endif

%}

%%

<INITIAL,COMMENT>[ \t]+ ;
<INITIAL,COMMENT>[\n]   { line++; }

[0-9]                { PRINTF ("_num:%d\n",line); return SYMB_NUM; }
[a-z]                { PRINTF ("_id:%d\n",line); return SYMB_ID; }
"+"                  { PRINTF ("_add:%d\n",line); return SYMB_ADD; }
"*"                  { PRINTF ("_mul:%d\n",line); return SYMB_MUL; }
"("                  { PRINTF ("_lpar:%d\n",line); return SYMB_LPAR; }
")"                  { PRINTF ("_rpar:%d\n",line); return SYMB_RPAR; }

. {
    printf ("LEX: Unexpected character '%c' [%d].\n", yytext[0], yytext[0]);
    exit (1);
  }

%%

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
        int token = lexer();
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
