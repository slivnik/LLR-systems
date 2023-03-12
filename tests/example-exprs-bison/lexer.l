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

%%

<INITIAL,COMMENT>[ \t]+ ;
<INITIAL,COMMENT>[\n]   { line++; }

[0-9]                { PRINTF ("_num:%d\n",line); return _NUM; }
[a-z]                { PRINTF ("_id:%d\n",line); return _ID; }
"+"                  { PRINTF ("_add:%d\n",line); return _ADD; }
"*"                  { PRINTF ("_mul:%d\n",line); return _MUL; }
"("                  { PRINTF ("_lpar:%d\n",line); return _LPAR; }
")"                  { PRINTF ("_rpar:%d\n",line); return _RPAR; }

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
