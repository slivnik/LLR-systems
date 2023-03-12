#ifndef TIMING_H
#define TIMING_H

#include <time.h>
#define BEGCLOCK(name)                                                           \
  double clock_##name;                                                           \
  {                                                                              \
    clock_t begclock##name = clock ();
#define ENDCLOCK(name)                                                           \
    clock_t endclock##name = clock ();                                           \
    clock_##name = ((double)(endclock##name - begclock##name)) / CLOCKS_PER_SEC; \
    fprintf (stdout, "CLOCK(%s): %lf\n", #name, clock_##name);                   \
  }

#include <sys/time.h>
#define BEGTIME(name) {                                                \
  struct timeval begtime##name;gettimeofday(&begtime##name, NULL);
#define ENDTIME(name)                                                  \
  struct timeval endtime##name;gettimeofday(&endtime##name, NULL);     \
  fprintf (stdout, "TIME(%s): %lf\n", #name,                           \
    ((endtime##name.tv_sec * 1.0e6 + endtime##name.tv_usec) -          \
    (begtime##name.tv_sec * 1.0e6 + begtime##name.tv_usec)) / 1.0e6);}

#endif
