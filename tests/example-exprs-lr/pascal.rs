[ (NUM|ID|LPAR) --> [ q0 2 ;
[ q0 q1 ] --> [ s ] ;

q0 ID --> q0 q4 ;
q0 NUM --> q0 q5 ;
q0 LPAR --> q0 q6 ;

q1 ADD --> q1 q7 ;

q2 MUL --> q2 q8 ;

q6 ID --> q6 q4 ;
q6 NUM --> q6 q5 ;
q6 LPAR --> q6 q6 ;

q7 ID --> q7 q4 ;
q7 NUM --> q7 q5 ;
q7 LPAR --> q7 q6 ;

q8 ID --> q8 q4 ;
q8 NUM --> q8 q5 ;
q8 LPAR --> q8 q6 ;

q9 ADD --> q9 q7 ;
q9 RPAR --> q9 q12 ;

q10 MUL --> q10 q8 ;

q0 q2 (ADD|RPAR|]) --> q0 q1 3 ;
q6 q2 (ADD|RPAR|]) --> q6 q9 3 ;

q0 q3 (ADD|MUL|RPAR|]) --> q0 q2 3 ;
q6 q3 (ADD|MUL|RPAR|]) --> q6 q2 3 ;
q7 q3 (ADD|MUL|RPAR|]) --> q7 q10 3 ;

q0 q4 (ADD|MUL|RPAR|]) --> q0 q3 3 ;
q6 q4 (ADD|MUL|RPAR|]) --> q6 q3 3 ;
q7 q4 (ADD|MUL|RPAR|]) --> q7 q3 3 ;
q8 q4 (ADD|MUL|RPAR|]) --> q8 q11 3 ;

q0 q5 (ADD|MUL|RPAR|]) --> q0 q3 3 ;
q6 q5 (ADD|MUL|RPAR|]) --> q6 q3 3 ;
q7 q5 (ADD|MUL|RPAR|]) --> q7 q3 3 ;
q8 q5 (ADD|MUL|RPAR|]) --> q8 q11 3 ;

q0 q1 q7 q10 (ADD|RPAR|]) --> q0 q1 5 ;
q6 q9 q7 q10 (ADD|RPAR|]) --> q6 q9 5 ;

q0 q2 q8 q11 (ADD|MUL|RPAR|]) --> q0 q2 5 ;
q6 q2 q8 q11 (ADD|MUL|RPAR|]) --> q6 q2 5 ;
q7 q10 q8 q11 (ADD|MUL|RPAR|]) --> q7 q10 5 ;

q0 q6 q9 q12 (ADD|MUL|RPAR|]) --> q0 q3 5 ;
q6 q6 q9 q12 (ADD|MUL|RPAR|]) --> q6 q3 5 ;
q7 q6 q9 q12 (ADD|MUL|RPAR|]) --> q7 q3 5 ;
q8 q6 q9 q12 (ADD|MUL|RPAR|]) --> q8 q11 5 ;
