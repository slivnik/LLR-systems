#include <stdio.h>
#include <stdlib.h>
#include "timing.h"

#include RSH
#include RSC

#if RDEBUG==1
#define REDGEN_DEBUG(code) code
#else
#define REDGEN_DEBUG(code)
#endif

#if RTRACE==1
#define REDGEN_TRACE(code) code
#else
#define REDGEN_TRACE(code)
#endif

extern int yylex();
extern char *yytext;

typedef struct cell {
  int symb;
  int state;
  struct cell *link;
} cell;

cell heap[1000000];
cell *heap_free;
int heap_used;

void dump_prev (cell *prev, int len)
{
  if (prev == NULL) return;
  dump_prev (prev->link, len - 1);
  if (len == 1) printf ("* ");
  printf ("%d:%s ", prev->state, prev->symb == -1 ? "$" : redgen_token_names[prev->symb]);
}

void dump_next (cell *next, int len)
{
  if (len == 0) {
    if (next != NULL) printf ("...");
    return;
  }
  if (next == NULL) return;
  printf ("%s ", next->symb == -1 ? "$" : redgen_token_names[next->symb]);
  dump_next (next->link, len - 1);
}

cell *result_prev;
cell *result_next;

void *my_malloc(size_t size)
{
  if (heap_free == NULL) {
    heap_used += 1;
    return &heap[heap_used - 1];
  }
  else {
    cell *tmp = heap_free;
    heap_free = heap_free->link;
    return tmp;
  }
}

void my_free(void *ptr)
{
  ((cell*)ptr)->link = heap_free;
  heap_free = ((cell*)ptr);
}

#define MY_MALLOC(ptr) {if(heap_free==NULL){heap_used+=1;ptr=&heap[heap_used - 1];}else{ptr=heap_free;heap_free=heap_free->link;};}
#define MY_FREE(ptr) {((cell*)ptr)->link = heap_free;heap_free = ((cell*)ptr);}

int parser ()
{
  heap_free = NULL;
  heap_used = 0;

  extern int lexer ();

  cell *prev; MY_MALLOC(prev);
  prev->symb = -1;
  prev->state = 0;
  prev->link = NULL;
  cell *next = NULL;

  int total_cmps = 0;
  int cmps = 0;
  do {
    if (prev->symb == SYMB__RM) {
      break;
    }

    if (next == NULL) {
      MY_MALLOC(next);
      next->symb = lexer ();
      next->link = NULL;
    }
    int next_state_or_red = redgen_transitions[prev->state][next->symb];
    REDGEN_DEBUG(printf ("\n\nnext_state_or_red=%d\n", next_state_or_red);)
    REDGEN_DEBUG(dump_prev (prev, 0);)
    REDGEN_DEBUG(printf(". ");)
    REDGEN_DEBUG(dump_next (next, 1000);)
    REDGEN_DEBUG(printf("\n");)
    cmps++; total_cmps++;

    if (next_state_or_red == 0) break;

    if (next_state_or_red > 0) {
      int state = next_state_or_red - 1;
      REDGEN_DEBUG(printf ("%d x %s -> %d\n", prev->state, redgen_token_names[next->symb], state);)
      next->state = state;
      {
        cell *tmp = next;
        next = next->link;
        tmp->link = prev;
        prev = tmp;
      }
    }
    else {
      int red = (-(next_state_or_red + 1)) & 0xffff;
      int flw = (-(next_state_or_red + 1)) >> 16;
      int src = redgen_reduction_src_side_len[red];
      int dst = redgen_reduction_dst_side_len[red];
      //REDGEN_DEBUG(printf ("red=%d\n  %s\n  %s\n", red, redgen_reduction_names[red], redgen_reduction_orig_names[red]);)
      //REDGEN_DEBUG(printf ("flw=%d\n", flw);)
      REDGEN_TRACE(printf ("\n");)
      REDGEN_TRACE(dump_prev (prev, src + flw);)
      REDGEN_TRACE(printf (". ");)
      REDGEN_TRACE(dump_next (next, 3);)
      REDGEN_TRACE(printf ("\n");)
      {
        cell *tmp = next;
        next = next->link;
        tmp->link = prev;
        prev = tmp;
      }
      for (int f = 0; f < flw; f++) {
        cell *tmp = prev;
        prev = prev->link;
        tmp->link = next;
        next = tmp;
      }
      for (int s = 0; s < src; s++) {
        if (prev->symb != redgen_reduction_src_side[red][src - s - 1]) {
          printf ("%s != %s\n", redgen_token_names[prev->symb], redgen_token_names[redgen_reduction_src_side[red][src - s - 1]]);
          exit (1);
        }
        cell *tmp = prev->link;
        MY_FREE (prev);
        prev = tmp;
      }
      REDGEN_TRACE(printf ("\tREDUCING %s\n", redgen_reduction_names[red]);)
      REDGEN_TRACE(printf ("\t         %s\n", redgen_reduction_orig_names[red]);)
      REDGEN_TRACE(printf ("\t         %d COMPARES\n", cmps));
      for (int d = dst - 1; d >= 0; d--) {
        cell *new_cell; MY_MALLOC(new_cell);
        new_cell->symb = redgen_reduction_dst_side[red][d];
        new_cell->link = next;
        next = new_cell;
      }
      if (0) {
        REDGEN_DEBUG(printf("prev == NULL");)
        cell *tmp = next;
        next = next->link;
        tmp->link = prev;
        prev = tmp;
        prev->state = 0;
      }
      REDGEN_TRACE(dump_prev (prev, 0);)
      REDGEN_TRACE(printf (". ");)
      REDGEN_TRACE(dump_next (next, dst + 3);)
      REDGEN_TRACE(printf ("\n\n");)
      cmps = 0;
    }
  } while (1);
  REDGEN_TRACE(printf ("\n");)
  REDGEN_TRACE(dump_prev (prev, 0);)
  REDGEN_TRACE(printf (". ");)
  REDGEN_TRACE(dump_next (next, 3);)
  REDGEN_TRACE(printf ("\n");)

  result_prev = prev;
  result_next = next;

  return total_cmps;
}

int main(int argc, char *argv[])
{
  int tot_cmps;
  if (argc == 1) {
    extern FILE *yyin;
    extern int yymode;
    yyin = stdin;
    yymode = 0;
    tot_cmps = parser();
    REDGEN_TRACE(printf("\n%8d TOTAL COMPARES\n\n", tot_cmps);)
  }
  if (argc == 2) {
    BEGCLOCK(LEXER)
    for (int test = 0; test < TESTS; test++) {
      extern FILE *yyin;
      extern int yymode;
      yyin = fopen(argv[1], "r");
      yymode = 0;
      while (1) {
        int token = yylex();
        //printf("%d = %s [%s]\n", token, redgen_token_names[token], yytext);
        if (token == SYMB__EOF) break;
      }
      fclose(yyin);
    }
    ENDCLOCK(LEXER)
    printf ("LEXER  : %lf\n", clock_LEXER / TESTS);

    BEGCLOCK(PARSER)
    for (int test = 0; test < TESTS; test++) {
      extern FILE *yyin;
      extern int yymode;
      yyin = fopen(argv[1], "r");
      yymode = 0;
      tot_cmps = parser();
      REDGEN_TRACE(printf("\n%8d TOTAL COMPARES\n\n", tot_cmps);)
      fclose(yyin);
    }
    ENDCLOCK(PARSER)
    printf ("PARSER : %lf\n", clock_PARSER / TESTS);
    printf("\n%d TOTAL COMPARES\n\n", tot_cmps);

    printf ("\n");
    dump_prev (result_prev, 0);
    printf (". ");
    dump_next (result_next, 3);
    printf ("\n");
  }

  return 0;
}
