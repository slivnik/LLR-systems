#include <stdio.h>
#include <stdlib.h>

int generate (int len)
{
  switch (len) {
    case 1:
      if (random () % 2 == 0)
        printf ("%d", random () % 10);
      else
        printf ("%c", 'a' + random () % 26);
      if (random () % 100 < 10) printf ("\n");
      break;
    default:
      if (random () % 2 == 0) {
        printf ("(");
        if (random () % 100 < 10) printf ("\n");
        generate (len - 2);
        printf (")");
        if (random () % 100 < 10) printf ("\n");
      }
      else {
        int len_l = (len == 3) ? 1 : 2 * (random () % (len / 2)) + 1;
        int len_r = len - len_l - 1;
        generate (len_l);
        if (random () % 2 == 0)
          printf ("+");
        else
          printf ("*");
        if (random () % 100 < 10) printf ("\n");
        generate (len_r);
      }
      break;
   }
}

int main (int argc, char *argv[])
{
  int len; sscanf (argv[1], "%d", &len);
  int rnd; sscanf (argv[2], "%d", &rnd);

  srandom (rnd);
  generate (len);
  return 0;
}