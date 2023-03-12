NUM --> f ;
ID --> f ;
LPAR e RPAR --> f ;
f --> t ;
t MUL f --> t ;
t (ADD|RPAR|]) --> e 2 ;
e ADD t (ADD|RPAR|]) --> e 4 ;
