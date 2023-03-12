%{
#include <stdio.h>
#include <stdlib.h>

#include "timing.h"

  int yylex ();
  int yyerror (char *msg);
  
#if (DEBUGPARSER==0)
#define printf(fmt,...)
#endif

%}

%token _NUM _ID _ADD _MUL _LPAR _RPAR ;

%%
