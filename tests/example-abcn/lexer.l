%{
#include <stdio.h>
#include <stdlib.h>

#include RSH
//#ifdef LEXER
//#include RSC
//#endif

%}

%%

[ \n\t]+                    {}

"a"                         { return SYMB_a; }
"b"                         { return SYMB_b; }
"c"                         { return SYMB_c; }

.                           { printf ("LEX: Unexpected character '%c' [%d].\n", yytext[0], yytext[0]); exit (1); }

%%

int yymode = 0;

int lexer ()
{
  int token;
  switch (yymode) { 
    case 0:
      yymode = 1;
      token = SYMB__LM;
      #ifdef MAIN
      printf ("LEX: %3d\n", token);
      #endif
      return token;
    case 1: 
      token = yylex();
      if (token == SYMB__EOF) {
        yymode = 2;
        token = SYMB__RM;
        #ifdef MAIN
        printf ("LEX: %3d\n", token);
        #endif
      }
      else {
        #ifdef MAIN
        printf ("LEX: %3d %s\n", token, yytext);
        #endif
      }
      return token;
    case 2:
      #ifdef MAIN
      printf ("LEX: %3d\n", token);
      #endif
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
