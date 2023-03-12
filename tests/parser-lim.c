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
  struct cell *link;
} cell;

#define BLOCK_SIZE 2
typedef struct block {
  cell *cells;
  struct block *next;
} block;

block *blocks;

cell *fst_full_cell;
cell *fst_free_cell;
int num_used_cells;

cell *get_new_cell () {
  if (fst_free_cell == NULL) {
    REDGEN_DEBUG(printf ("NO FREE\n");)
    if (num_used_cells == BLOCK_SIZE) {
      REDGEN_DEBUG(printf ("NEW BLOCK\n");)
      block *new_block = (block*)malloc (sizeof(block));
      new_block->cells = (cell*)malloc (BLOCK_SIZE * sizeof(cell));
      new_block->next = blocks;
      blocks = new_block;
      num_used_cells = 1;
      return &blocks->cells[num_used_cells - 1];
    }
    else {
      REDGEN_DEBUG(printf ("OLD BLOCK\n");)
      num_used_cells++;
      return &blocks->cells[num_used_cells - 1];
    }
  }
  else {
    REDGEN_DEBUG(printf ("FROM FREE\n");)
    cell *new_cell= fst_free_cell;
    fst_free_cell = fst_free_cell->link;
    return new_cell;
  }
}

void print_prev (cell *prev)
{
  if (prev == NULL) return;
  print_prev(prev->link);
  printf("%s ", redgen_token_names[prev->symb]);
}

void print_next (cell *next, cell *cur)
{
  if ((next == NULL) && (cur == NULL)) printf(" .");
  if (next == NULL) return;
  if (next == cur) printf(" .");
  printf(" %s", redgen_token_names[next->symb]);
  print_next(next->link, cur);
}

int parser ()
{
  extern int lexer ();

  blocks = NULL;
  // fst_full_cell = NULL;
  fst_free_cell = NULL;
  num_used_cells = BLOCK_SIZE;

  int total_cmps = 0;
  int cmps = 0;

  // A loop over all positions.
  cell *prev = NULL;
  cell *next = NULL;
  while (1) {
    REDGEN_DEBUG(printf ("OUTER "); print_prev (prev); printf ("*"); print_next (next, (cell*)(-1)); printf ("\n");)

    // Look for the longest left side starting at 'next'.
    cell **cur = &next;
    int state = 0;
    int red = -1;
    while (1) {
      REDGEN_DEBUG(printf ("INNER "); print_prev (prev); printf ("*"); print_next (next, *cur); printf ("\n");)

      // Register the reduction if possible.
      if (redgen_selected_reduction[state] != -1) {
        red = redgen_selected_reduction[state];
        REDGEN_DEBUG(printf ("SELECTED: %s\n", redgen_reduction_names[red]);)
      }

      // Ensure the cell pointed to by '*cur' exists.
      if (*cur == NULL) {
        int token = lexer();
        if (token != SYMB__EOF) {
          *cur = get_new_cell ();
          (*cur)->symb = token;
          (*cur)->link = NULL;
          REDGEN_DEBUG(printf ("NEW CELL: %s\n", redgen_token_names[(*cur)->symb]);)
        }
        else {
          break;
        }
      }

      if (redgen_number_of_transitions[state] == 0) {
        // No transitions at all.
        REDGEN_DEBUG(printf ("NO TRANSITIONS AT ALL\n");)
        break;
      }

      REDGEN_DEBUG(printf ("COMPARING %d %s -> %d\n", state, redgen_token_names[(*cur)->symb], redgen_transitions[state][(*cur)->symb]);)
      state = redgen_transitions[state][(*cur)->symb];
      cmps += 1;

      if (state == -1) {
        // No more transitions.
        REDGEN_DEBUG(printf ("NO MORE TRANSITIONS\n");)
        break;
      }

      cur = &(*cur)->link;
    }

    // Depending on whether the reduction has been selected at 'next' or not...
    if (red == -1) {
      if (*cur == NULL) {
        total_cmps += cmps; cmps = 0;
        break;
      }
      cell *tmp = next;
      next = next->link;
      tmp->link = prev;
      prev = tmp;
    }
    else {
      // Reduction selected.
      REDGEN_TRACE(printf ("\n"); print_prev (prev); printf ("*"); print_next (next, *cur); printf ("\n");)
      {
        for (int src = 0; src < redgen_reduction_src_side_len[red]; src++) {
          cell *tmp = next;
          next = next->link;
          tmp->link = fst_free_cell;
          fst_free_cell = tmp;
        }
        /* {
          cell *tmp = next;
          while (tmp != NULL) { printf ("%p ", tmp); tmp = tmp->link; } printf ("\n");
        } */
        REDGEN_DEBUG(printf ("DEL "); print_prev (prev); printf ("*"); print_next(next, (cell*)(-1)); printf ("\n");)
      }
      REDGEN_TRACE(printf ("\tREDUCING %s\n", redgen_reduction_names[red]);)
      REDGEN_TRACE(printf ("\t         %s\n", redgen_reduction_orig_names[red]);)
      REDGEN_TRACE(printf ("\t         %d COMPARES\n", cmps));
      {
        for (int dst = redgen_reduction_dst_side_len[red] - 1; dst >= 0; dst--) {
          cell *tmp = get_new_cell();
          tmp->symb = redgen_reduction_dst_side[red][dst];
          tmp->link = next;
          next = tmp;
        }
        REDGEN_DEBUG(printf ("INS "); print_prev (prev); printf ("*"); print_next (next, (cell*)(-1)); printf ("\n");)
      }
      REDGEN_TRACE(print_prev (prev); printf ("*"); print_next (next, *cur); printf ("\n\n");)

      // Go back to perform the next reduction.
      {
        int delta = redgen_backjump[red];
        REDGEN_DEBUG(printf ("DELTA = %d\n", delta);)
        if (delta > 0) {
          while ((next != NULL) && (delta > 0)) {
            cell *tmp = next;
            next = next->link;
            tmp->link = prev;
            prev = tmp;
            delta--;
          }
          REDGEN_DEBUG(printf ("POS DELTA "); print_prev (prev); printf ("*"); print_next (next, (cell*)(-1)); printf ("\n");)
        }
        if (delta < 0) {
          while ((prev != NULL) && (delta < 0)) {
            cell *tmp = prev;
            prev = prev->link;
            tmp->link = next;
            next = tmp;
            delta++;
          }
          REDGEN_DEBUG(printf ("NEG DELTA "); print_prev (prev); printf ("*"); print_next (next, (cell*)(-1)); printf ("\n");)
        }
        total_cmps += cmps; cmps = 0;
      }
    }

  }

  while (blocks != NULL) {
    block *tmp = blocks;
    blocks = blocks->next;
    free(tmp->cells);
    free(tmp);
  }

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
    REDGEN_TRACE(printf("\n%8d TOTAL COMPARES\n", tot_cmps);)
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
      REDGEN_TRACE(printf("\n%8d TOTAL COMPARES\n", tot_cmps);)
      fclose(yyin);
    }
    ENDCLOCK(PARSER)
    printf ("PARSER : %lf\n", clock_PARSER / TESTS);
    printf("\n%d TOTAL COMPARES\n\n", tot_cmps);
  }

  return 0;

}
