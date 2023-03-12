[ (NUM|ID|LPAR) --> [ e 2 ;

e (NUM|ID|LPAR) --> e2 t 2 ;
e2 (ADD) --> e2 t tADD 2 ;
e2 (RPAR|]) --> 2 ;
t (NUM|ID|LPAR) --> t2 f 2 ;
t2 (MUL) --> t2 f tMUL 2 ;
t2 (ADD|RPAR|]) --> 2 ;
f (NUM) --> tNUM 2 ;
f (ID) --> tID 2 ;
f (LPAR) --> tRPAR e tLPAR 2 ;

[ ] --> [ s ] ;

tID ID --> ;
tNUM NUM --> ;
tLPAR LPAR --> ;
tRPAR RPAR --> ;
tADD ADD --> ;
tMUL MUL --> ;