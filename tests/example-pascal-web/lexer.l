%{
#include <stdio.h>
#include <stdlib.h>

int comment_depth = 0;
int prev_is_digit = 0;

int buffer[10];
int buffer_head = 0;
int buffer_free = 0;

int action(char *scrap, int token, char *lexeme)
{
  prev_is_digit = 0;
  buffer[buffer_free] = token;
  buffer_free = (buffer_free + 1) % 10;
  #ifdef MAIN
  printf ("LEX: %3d %s(%s)\n", token, scrap, yytext);
  #endif
}

#include RSH
//#ifdef LEXER
//#include RSC
//#endif
%}

%x COMMENT

%%

<INITIAL,COMMENT>[ \t\n]+ ;

"<>"                  action ("math", SYMB_math, yytext); return 0;
"<="                  action ("math", SYMB_math, yytext); return 0;
">="                  action ("math", SYMB_math, yytext); return 0;
":="                  action ("math", SYMB_math, yytext); return 0;
"=="                  action ("math", SYMB_math, yytext); return 0;
"^"                   action ("math", SYMB_math, yytext); return 0;
"("                   action ("open", SYMB_open, yytext); return 0;
")"                   action ("close", SYMB_close, yytext); return 0;
"["                   action ("open", SYMB_open, yytext); return 0;
"]"                   action ("close", SYMB_close, yytext); return 0;
"*"                   action ("math", SYMB_math, yytext); return 0;
","                   action ("math", SYMB_math, yytext); return 0;
".."                  action ("math", SYMB_math, yytext); return 0;
"."                   action ("simp", SYMB_simp, yytext); return 0;
":"                   action ("colon", SYMB_colon, yytext); return 0;
";"                   action ("semi", SYMB_semi, yytext); return 0;

"="                   action ("math", SYMB_math, yytext); return 0;
"-"                   action ("math", SYMB_math, yytext); return 0;
"+"                   action ("math", SYMB_math, yytext); return 0;
"/"                   action ("math", SYMB_math, yytext); return 0;
"<"                   action ("math", SYMB_math, yytext); return 0;
">"                   action ("math", SYMB_math, yytext); return 0;

"and"                 action ("math", SYMB_math, yytext); return 0;
"array"               action ("alpha", SYMB_alpha, yytext); return 0;
"begin"               action ("beginning", SYMB_beginning, yytext); action ("intro", SYMB_intro, yytext); return 0;
"case"                action ("casey", SYMB_casey, yytext); action ("alpha", SYMB_alpha, yytext); return 0;
"const"               action ("intro", SYMB_intro, yytext); return 0;
"div"                 action ("math", SYMB_math, yytext); return 0;
"do"                  action ("omega", SYMB_omega, yytext); return 0;
"downto"              action ("math", SYMB_math, yytext); return 0;
"else"                action ("terminator", SYMB_terminator, yytext); action ("elsie", SYMB_elsie, yytext); return 0;
"end"                 action ("terminator", SYMB_terminator, yytext); action ("close", SYMB_close, yytext); return 0;
"file"                action ("alpha", SYMB_alpha, yytext); return 0;
"for"                 action ("alpha", SYMB_alpha, yytext); return 0;
"forward"             action ("beginning", SYMB_beginning, yytext); action ("close", SYMB_close, yytext); return 0;
"function"            action ("proc", SYMB_proc, yytext); action ("intro", SYMB_intro, yytext); return 0;
"goto"                action ("intro", SYMB_intro, yytext); return 0;
"if"                  action ("cond", SYMB_cond, yytext); action ("alpha", SYMB_alpha, yytext); return 0;
"in"                  action ("math", SYMB_math, yytext); return 0;
"label"               action ("intro", SYMB_intro, yytext); return 0;
"mod"                 action ("math", SYMB_math, yytext); return 0;
"nil"                 action ("simp", SYMB_simp, yytext); return 0;
"not"                 action ("math", SYMB_math, yytext); return 0;
"of"                  action ("omega", SYMB_omega, yytext); return 0;
"or"                  action ("math", SYMB_math, yytext); return 0;
"packed"              action ("intro", SYMB_intro, yytext); return 0;
"procedure"           action ("proc", SYMB_proc, yytext); action ("intro", SYMB_intro, yytext); return 0;
"program"             action ("proc", SYMB_proc, yytext); action ("intro", SYMB_intro, yytext); return 0;
"record"              action ("record_head", SYMB_record_head, yytext); return 0;
"repeat"              action ("beginning", SYMB_beginning, yytext); action ("intro", SYMB_intro, yytext); return 0;
"set"                 action ("alpha", SYMB_alpha, yytext); return 0;
"then"                action ("omega", SYMB_omega, yytext); return 0;
"to"                  action ("math", SYMB_math, yytext); return 0;
"type"                action ("intro", SYMB_intro, yytext); return 0;
"until"               action ("terminator", SYMB_terminator, yytext); action ("close", SYMB_close, yytext); action ("clause", SYMB_clause, yytext); return 0;
"var"                 action ("var_head", SYMB_var_head, yytext); action ("intro", SYMB_intro, yytext); return 0;
"while"               action ("alpha", SYMB_alpha, yytext); return 0;
"with"                action ("alpha", SYMB_alpha, yytext); return 0;

[0-9]                 action ("simp", SYMB_simp, yytext); prev_is_digit = 1; return 0;
"E"                   if (prev_is_digit == 1) action ("exp", SYMB_exp, yytext); else action ("simp", SYMB_simp, yytext); prev_is_digit = 0; return 0;
[A-Za-z][A-Za-z0-9]*  action ("simp", SYMB_simp, yytext); return 0;
\'([^']|\'\')*\'      action ("simp", SYMB_simp, yytext); return 0;


<INITIAL>\{ { comment_depth++; BEGIN(COMMENT); }
<COMMENT>\{ { comment_depth++; }
<COMMENT>\} { comment_depth--;
               if (comment_depth == 0) BEGIN(INITIAL); }
<COMMENT>.  ;

. {
    fprintf (stderr, "LEX: Unexpected character '%c' [%d].\n", yytext[0], yytext[0]);
    exit (1);
  }

%%

int yymode = 0;

int lexer ()
{
  switch (yymode) {
    case 0:
      yymode = 1;
      #ifdef MAIN
      printf ("LEX: %3d\n", SYMB__LM);
      #endif
      return SYMB__LM;
    case 1:
      if (buffer_head == buffer_free)
        yylex ();
      if ((buffer_head == buffer_free) || (buffer[buffer_head] == SYMB__EOF)) {
        yymode = 2;
        #ifdef MAIN
        printf ("LEX: %3d\n", SYMB__RM);
        #endif
        return SYMB__RM;
      }
      else {
        int token = buffer[buffer_head];
        buffer_head = (buffer_head + 1) % 10;
        return token;
      }
    case 2:
      #ifdef MAIN
      printf ("LEX: %3d\n", SYMB__EOF);
      #endif
      return SYMB__EOF;
  }
}

#ifdef MAIN
int main ()
{
	while (lexer () != SYMB__EOF) {
	}
	return 0;
}
#endif
