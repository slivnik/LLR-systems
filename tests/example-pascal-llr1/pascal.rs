[ (PROGRAM) --> [ S program 2 ;

# ***** DEFINITIONS *****

# ... PROGRAM AND SUBPROGRAM DEFINITIONS ...

program (PROGRAM) --> tDOT compound_statement subprogram_part variable_part type_part constant_part label_part program_header 2 ;

program_header (PROGRAM) --> tSEMIC file_list tIDENTIFIER tPROGRAM 2 ;

file_list (LPARENT) --> tRPARENT files tLPARENT 2 ;
file_list (SEMIC) --> 2 ;

files (IDENTIFIER) --> files_rest tIDENTIFIER 2 ;
files_rest (COMMA) --> files_rest tIDENTIFIER tCOMMA 2 ;
files_rest (RPARENT) --> 2 ;

subprogram_part (PROCEDURE|FUNCTION) --> subprogram_part subprogram_definition 2 ;
subprogram_part (BEGIN) --> 2 ;

subprogram_definition (PROCEDURE|FUNCTION) --> subprogram_definition_rest subprogram_header 2 ;
subprogram_definition_rest (PROCEDURE|FUNCTION|VAR|LABEL|CONST|TYPE|BEGIN) --> tSEMIC compound_statement subprogram_part variable_part type_part constant_part label_part 2 ;
subprogram_definition_rest (EXTERNAL) --> tSEMIC tEXTERNAL 2 ;
subprogram_definition_rest (FORWARD) --> tSEMIC tFORWARD 2 ;

subprogram_header (PROCEDURE) --> tSEMIC parameter_list tIDENTIFIER tPROCEDURE 2 ;
subprogram_header (FUNCTION) --> tSEMIC type tCOLON parameter_list tIDENTIFIER tFUNCTION 2 ;

parameter_list (LPARENT) --> tRPARENT parameters tLPARENT 2 ;
parameter_list (SEMIC|COLON) --> 2 ;

parameters (IDENTIFIER|PROCEDURE|FUNCTION|VAR) --> parameters_rest parameter 2 ;
parameters_rest (SEMIC) --> parameters_rest parameter tSEMIC 2 ;
parameters_rest (RPARENT) --> 2 ;

parameter (IDENTIFIER) --> type tCOLON parameter_names 2 ;
parameter (VAR) --> type tCOLON parameter_names tVAR 2 ;
parameter (FUNCTION) --> type tCOLON parameter_names tFUNCTION 2 ;
parameter (PROCEDURE) --> parameter_names tPROCEDURE 2 ;

parameter_names (IDENTIFIER) --> parameter_names_rest tIDENTIFIER 2 ;
parameter_names_rest (COMMA) --> parameter_names_rest tIDENTIFIER tCOMMA 2 ;
parameter_names_rest (SEMIC|RPARENT|COLON) --> 2 ;

# ... LABEL DEFINITIONS ...

label_part (LABEL) --> tSEMIC label_definitions tLABEL 2 ;
label_part (PROCEDURE|FUNCTION|VAR|CONST|TYPE|BEGIN) --> 2 ;

label_definitions (INTEGERCONST) --> label_definitions_rest tINTEGERCONST 2 ;
label_definitions_rest (COMMA) --> label_definitions_rest tINTEGERCONST tCOMMA 2 ;
label_definitions_rest (SEMIC) --> 2 ;

# ... CONSTANT DEFINITIONS ...

constant_part (CONST) --> constant_definitions tCONST 2 ;
constant_part (PROCEDURE|FUNCTION|VAR|TYPE|BEGIN) --> 2 ;

constant_definitions (IDENTIFIER) --> constant_definitions_rest constant_definition 2 ;
constant_definitions_rest (IDENTIFIER) --> constant_definitions_rest constant_definition 2 ;
constant_definitions_rest (PROCEDURE|FUNCTION|VAR|TYPE|BEGIN) --> 2 ;

constant_definition (IDENTIFIER) --> tSEMIC constant tEQU tIDENTIFIER 2 ;

# ... TYPE DEFINITIONS ...

type_part (TYPE) --> type_definitions tTYPE 2 ;
type_part (PROCEDURE|FUNCTION|VAR|BEGIN) --> 2 ;

type_definitions (IDENTIFIER) --> type_definitions_rest type_definition 2 ;
type_definitions_rest (IDENTIFIER) --> type_definitions_rest type_definition 2 ;
type_definitions_rest (PROCEDURE|FUNCTION|VAR|BEGIN) --> 2 ;

type_definition (IDENTIFIER) --> tSEMIC type tEQU tIDENTIFIER 2 ;

# ... VARIABLE DEFINITIONS ...

variable_part (VAR) --> variable_definitions tVAR 2 ;
variable_part (PROCEDURE|FUNCTION|BEGIN) --> 2 ;

variable_definitions (IDENTIFIER) --> variable_definitions_rest variable_definition 2 ;
variable_definitions_rest (IDENTIFIER) --> variable_definitions_rest variable_definition 2 ;
variable_definitions_rest (PROCEDURE|FUNCTION|BEGIN) --> 2 ;

variable_definition (IDENTIFIER) --> tSEMIC type tCOLON variable_names 2 ;

variable_names (IDENTIFIER) --> variable_names_rest tIDENTIFIER 2 ;
variable_names_rest (COMMA) --> variable_names_rest tIDENTIFIER tCOMMA 2 ;
variable_names_rest (COLON) --> 2 ;

# ***** STATEMENTS *****

labeled_statements (IDENTIFIER|SEMIC|INTEGERCONST|BEGIN|IF|CASE|WHILE|REPEAT|FOR|WITH|GOTO|END|UNTIL) --> labeled_statements_rest labeled_statement 2 ;
labeled_statements_rest (SEMIC) --> labeled_statements_rest labeled_statement tSEMIC 2 ;
labeled_statements_rest (END|UNTIL) --> 2 ;

labeled_statement (INTEGERCONST) --> statement tCOLON tINTEGERCONST 2 ;
labeled_statement (IDENTIFIER|BEGIN|IF|CASE|WHILE|REPEAT|FOR|WITH|GOTO|SEMIC|END|ELSE|UNTIL) --> statement 2 ;

#??? statement -> assignment_statement .   # ??? <= lookahead: IDENTIFIER (ASSIGN|FIRST(variable_suffix))
statement (IDENTIFIER) (ASSIGN|DOT|LBRACKET|PTR) --> assignment_statement 2 3 ;
statement (IDENTIFIER) --> procedure_statement 2 ;
statement (BEGIN) --> compound_statement 2 ;
statement (IF) --> if_statement 2 ;
statement (CASE) --> case_statement 2 ;
statement (WHILE) --> while_statement 2 ;
statement (REPEAT) --> repeat_statement 2 ;
statement (FOR) --> for_statement 2 ;
statement (WITH) --> with_statement 2 ;
statement (GOTO) --> goto_statement 2 ;
statement (SEMIC|END|ELSE|UNTIL) --> 2 ;

assignment_statement (IDENTIFIER) --> expression tASSIGN variable 2 ;

procedure_statement (IDENTIFIER) --> procedure_parameters tIDENTIFIER 2 ;

procedure_parameters (LPARENT) --> tRPARENT arguments tLPARENT 2 ;
procedure_parameters (SEMIC|END|ELSE|UNTIL) --> 2 ;

compound_statement (BEGIN) --> tEND labeled_statements tBEGIN 2 ;

if_statement (IF) --> if_statement_rest labeled_statement tTHEN expression tIF 2 ;
#???   if_statement_rest -> ELSE labeled_statement . # ??? dangling else
if_statement_rest (ELSE) --> labeled_statement tELSE 2 ;
#???   if_statement_rest -> .                        # ??? dangling else
if_statement_rest (SEMIC|END|UNTIL) --> 2 ;

case_statement (CASE) --> tEND case_branches tOF expression tCASE 2 ;

case_branches (IDENTIFIER|SEMIC|INTEGERCONST|ADD|SUB|REALCONST|BOOLEANCONST|STRINGCONST|NIL|END) --> case_branches_rest case_branch 2 ;
case_branches_rest (SEMIC) --> case_branches_rest case_branch tSEMIC 2 ;
case_branches_rest (END) --> 2 ;

case_branch (IDENTIFIER|INTEGERCONST|ADD|SUB|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> labeled_statement tCOLON constants 2 ;
case_branch (SEMIC|END) --> 2 ;

while_statement (WHILE) --> labeled_statement tDO expression tWHILE 2 ;

repeat_statement (REPEAT) --> expression tUNTIL labeled_statements tREPEAT 2 ;

for_statement (FOR) --> labeled_statement tDO for_change expression for_direction expression tASSIGN tIDENTIFIER tFOR 2 ;

for_direction (TO) --> tTO 2 ;
for_direction (DOWNTO) --> tDOWNTO 2 ;

for_change (STEP) --> expression tSTEP 2 ;
for_change (DO) --> 2 ;

with_statement (WITH) --> labeled_statement tDO variables tWITH 2 ;

goto_statement (GOTO) --> tINTEGERCONST tGOTO 2 ;

variables (IDENTIFIER) --> variables_rest variable 2 ;
variables_rest (COMMA) --> variables_rest variable tCOMMA 2 ;
variables_rest (DO) --> 2 ;

variable (IDENTIFIER) --> variable_suffix tIDENTIFIER 2 ;

variable_suffix (LBRACKET) --> variable_suffix tRBRACKET expressions tLBRACKET 2 ;
variable_suffix (DOT) --> variable_suffix tIDENTIFIER tDOT 2 ;
variable_suffix (PTR) --> variable_suffix tPTR 2 ;
variable_suffix (COMMA|ASSIGN|DO) --> 2 ;

# ***** TYPES *****

type (IDENTIFIER|LPARENT|INTEGERCONST|CHAR|REAL|INTEGER|BOOLEAN|ADD|SUB|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> simple_type 2 ;
type (PTR) --> pointer_type 2 ;
type (PACKED|FILE|SET|ARRAY|RECORD) --> packed_type 2 ;

simple_type (CHAR|REAL|INTEGER|BOOLEAN) --> atomic_type 2 ;
simple_type (LPARENT) --> enumerated_type 2 ;
simple_type (IDENTIFIER|INTEGERCONST|ADD|SUB|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> interval_type 2 ;
#??? simple_type -> IDENTIFIER .   # ??? <= lookahead: IDENTIFIER !INTERVAL
simple_type (IDENTIFIER) (!INTERVAL) --> tIDENTIFIER 2 3 ;

atomic_type (CHAR) --> tCHAR 2 ;
atomic_type (REAL) --> tREAL 2 ;
atomic_type (INTEGER) --> tINTEGER 2 ;
atomic_type (BOOLEAN) --> tBOOLEAN 2 ;

enumerated_type (LPARENT) --> tRPARENT enumerated_names tLPARENT 2 ;

enumerated_names (IDENTIFIER) --> enumerated_names_rest tIDENTIFIER 2 ;
enumerated_names_rest (COMMA) --> enumerated_names_rest tIDENTIFIER tCOMMA 2 ;
enumerated_names_rest (RPARENT) --> 2 ;

interval_type (IDENTIFIER|INTEGERCONST|ADD|SUB|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> constant tINTERVAL constant 2 ;

pointer_type (PTR) --> type tPTR 2 ;

packed_type (PACKED) --> struct_type tPACKED 2 ;
packed_type (FILE|SET|ARRAY|RECORD) --> struct_type 2 ;

struct_type (ARRAY) --> array_type 2 ;
struct_type (RECORD) --> record_type 2 ;
struct_type (FILE) --> type tOF tFILE 2 ;
struct_type (SET) --> simple_type tOF tSET 2 ;

array_type (ARRAY) --> type tOF tRBRACKET simple_types tLBRACKET tARRAY 2 ;

simple_types (IDENTIFIER|LPARENT|INTEGERCONST|CHAR|REAL|INTEGER|BOOLEAN|ADD|SUB|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> simple_types_rest simple_type 2 ;
simple_types_rest (COMMA) --> simple_types_rest simple_type tCOMMA 2 ;
simple_types_rest (RBRACKET) --> 2 ;

record_type (RECORD) --> tEND field_definitions tRECORD 2 ;

field_definitions (RPARENT|END) --> 2 ;
field_definitions (CASE) --> record_case 2 ;
field_definitions (SEMIC) --> field_definitions tSEMIC 2 ;
field_definitions (IDENTIFIER) --> field_definitions_rest field_definition 2 ;
field_definitions_rest (RPARENT|END) --> 2 ;
field_definitions_rest (SEMIC) --> field_definitions tSEMIC 2 ;

field_definition (IDENTIFIER) --> type tCOLON field_names 2 ;

field_names (IDENTIFIER) --> field_names_rest tIDENTIFIER 2 ;
field_names_rest (COMMA) --> field_names_rest tIDENTIFIER tCOMMA 2 ;
field_names_rest (COLON) --> 2 ;

#??? record_case -> CASE IDENTIFIER COLON type OF record_case_branches .   # ??? <= lookeahed: CASE IDENTIFIER COLON
record_case (CASE) (IDENTIFIER) (COLON) --> record_case_branches tOF type tCOLON tIDENTIFIER tCASE 2 3 4 ;
record_case (CASE) --> record_case_branches tOF type tCASE 2 ;

record_case_branches (RPARENT|END) --> 2 ;
record_case_branches (SEMIC) --> record_case_branches tSEMIC 2 ;
record_case_branches (IDENTIFIER|INTEGERCONST|ADD|SUB|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> record_case_branches_rest record_case_branch 2 ;
record_case_branches_rest (RPARENT|END) --> 2 ;
record_case_branches_rest (SEMIC) --> record_case_branches tSEMIC 2 ;

record_case_branch (IDENTIFIER|INTEGERCONST|ADD|SUB|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> tRPARENT field_definitions tLPARENT tCOLON constants 2 ;

# ***** EXPRESSIONS *****

expressions (IDENTIFIER|LPARENT|INTEGERCONST|PTR|ADD|SUB|NOT|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> expressions_rest expression 2 ;
expressions_rest (COMMA) --> expressions_rest expression tCOMMA 2 ;
expressions_rest (RBRACKET) --> 2 ;

expression (IDENTIFIER|LPARENT|INTEGERCONST|PTR|ADD|SUB|NOT|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> relational_expression 2 ;

relational_expression (IDENTIFIER|LPARENT|INTEGERCONST|PTR|ADD|SUB|NOT|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> relation_expression_rest additive_expression 2 ;
relation_expression_rest (EQU) --> additive_expression tEQU 2 ;
relation_expression_rest (NEQ) --> additive_expression tNEQ 2 ;
relation_expression_rest (LTH) --> additive_expression tLTH 2 ;
relation_expression_rest (GTH) --> additive_expression tGTH 2 ;
relation_expression_rest (LEQ) --> additive_expression tLEQ 2 ;
relation_expression_rest (GEQ) --> additive_expression tGEQ 2 ;
relation_expression_rest (IN) --> additive_expression tIN 2 ;
relation_expression_rest (SEMIC|RPARENT|COMMA|COLON|END|THEN|ELSE|OF|DO|UNTIL|TO|DOWNTO|STEP|RBRACKET) --> 2 ;

additive_expression (IDENTIFIER|LPARENT|INTEGERCONST|PTR|ADD|SUB|NOT|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> additive_expression_rest multiplicative_expression 2 ;
additive_expression_rest (ADD) --> additive_expression_rest multiplicative_expression tADD 2 ;
additive_expression_rest (SUB) --> additive_expression_rest multiplicative_expression tSUB 2 ;
additive_expression_rest (OR) --> additive_expression_rest multiplicative_expression tOR 2 ;
additive_expression_rest (SEMIC|RPARENT|COMMA|COLON|EQU|END|THEN|ELSE|OF|DO|UNTIL|TO|DOWNTO|STEP|RBRACKET|NEQ|LTH|GTH|LEQ|GEQ|IN) --> 2 ;

multiplicative_expression (IDENTIFIER|LPARENT|INTEGERCONST|PTR|ADD|SUB|NOT|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> multiplicative_expression_rest prefix_expression 2 ;
multiplicative_expression_rest (MUL) --> multiplicative_expression_rest prefix_expression tMUL 2 ;
multiplicative_expression_rest (DIV) --> multiplicative_expression_rest prefix_expression tDIV 2 ;
multiplicative_expression_rest (IDIV) --> multiplicative_expression_rest prefix_expression tIDIV 2 ;
multiplicative_expression_rest (IMOD) --> multiplicative_expression_rest prefix_expression tIMOD 2 ;
multiplicative_expression_rest (AND) --> multiplicative_expression_rest prefix_expression tAND 2 ;
multiplicative_expression_rest (SEMIC|RPARENT|COMMA|COLON|EQU|END|THEN|ELSE|OF|DO|UNTIL|TO|DOWNTO|STEP|RBRACKET|NEQ|LTH|GTH|LEQ|GEQ|IN|ADD|SUB|OR) --> 2 ;

prefix_expression (IDENTIFIER|LPARENT|INTEGERCONST|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> suffix_expression 2 ;
prefix_expression (ADD) --> suffix_expression tADD 2 ;
prefix_expression (SUB) --> suffix_expression tSUB 2 ;
prefix_expression (NOT) --> suffix_expression tNOT 2 ;
prefix_expression (PTR) --> suffix_expression tPTR 2 ;

suffix_expression (IDENTIFIER|LPARENT|INTEGERCONST|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> suffix_expression_rest atomic_expression 2 ;
suffix_expression_rest (LBRACKET) --> suffix_expression_rest tRBRACKET expressions tLBRACKET 2 ;
suffix_expression_rest (DOT) --> suffix_expression_rest tIDENTIFIER tDOT 2 ;
suffix_expression_rest (PTR) --> suffix_expression_rest tPTR 2 ;
suffix_expression_rest (SEMIC|RPARENT|COMMA|COLON|EQU|END|THEN|ELSE|OF|DO|UNTIL|TO|DOWNTO|STEP|RBRACKET|NEQ|LTH|GTH|LEQ|GEQ|IN|ADD|SUB|OR|MUL|DIV|IDIV|IMOD|AND) --> 2 ;

atomic_expression (REALCONST) --> tREALCONST 2 ;
atomic_expression (INTEGERCONST) --> tINTEGERCONST 2 ;
atomic_expression (BOOLEANCONST) --> tBOOLEANCONST 2 ;
atomic_expression (STRINGCONST) --> tSTRINGCONST 2 ;
atomic_expression (NIL) --> tNIL 2 ;
atomic_expression (LPARENT) --> tRPARENT expression tLPARENT 2 ;
atomic_expression (IDENTIFIER) --> tIDENTIFIER 2 ;
#??? atomic_expression -> IDENTIFIER LPARENT arguments RPARENT .   # ??? <= lookahead: IDENTIFIER LPARENT
atomic_expression (IDENTIFIER) (LPARENT) --> tRPARENT arguments tLPARENT tIDENTIFIER 2 3 ;

arguments (IDENTIFIER|LPARENT|INTEGERCONST|PTR|ADD|SUB|NOT|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> arguments_rest argument 2 ;
arguments_rest (COMMA) --> arguments_rest argument tCOMMA 2 ;
arguments_rest (RPARENT) --> 2 ;

argument (IDENTIFIER|LPARENT|INTEGERCONST|PTR|ADD|SUB|NOT|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> argument_rest_1 expression 2 ;
argument_rest_1 (RPARENT|COMMA) --> 2 ;
argument_rest_1 (COLON) --> argument_rest_2 expression tCOLON 2 ;
argument_rest_2 (RPARENT|COMMA) --> 2 ;
argument_rest_2 (COLON) --> expression tCOLON 2 ;

constants (IDENTIFIER|INTEGERCONST|ADD|SUB|REALCONST|BOOLEANCONST|STRINGCONST|NIL) --> constants_rest constant 2 ;
constants_rest (COMMA) --> constants_rest constant tCOMMA 2 ;
constants_rest (COLON) --> 2 ;

constant (IDENTIFIER|INTEGERCONST|REALCONST) --> signeable_constant 2 ;
constant (ADD) --> signeable_constant tADD 2 ;
constant (SUB) --> signeable_constant tSUB 2 ;
constant (STRINGCONST) --> tSTRINGCONST 2 ;
constant (BOOLEANCONST) --> tBOOLEANCONST 2 ;
constant (NIL) --> tNIL 2 ;
signeable_constant (IDENTIFIER) --> tIDENTIFIER 2 ;
signeable_constant (REALCONST) --> tREALCONST 2 ;
signeable_constant (INTEGERCONST) --> tINTEGERCONST 2 ;

# ***** TERMINALS *****

tAND AND --> ;
tREPEAT REPEAT --> ;
tFILE FILE --> ;
tIF IF --> ;
tIDIV IDIV --> ;
tIMOD IMOD --> ;
tCONST CONST --> ;
tINTERVAL INTERVAL --> ;
tPROGRAM PROGRAM --> ;
tIN IN --> ;
tIDENTIFIER IDENTIFIER --> ;
tASSIGN ASSIGN --> ;
tLBRACKET LBRACKET --> ;
tSTEP STEP --> ;
tDIV DIV --> ;
tWITH WITH --> ;
tRBRACKET RBRACKET --> ;
tOF OF --> ;
tNEQ NEQ --> ;
tCASE CASE --> ;
tINTEGERCONST INTEGERCONST --> ;
tNIL NIL --> ;
tOR OR --> ;
tDOT DOT --> ;
tBEGIN BEGIN --> ;
tSET SET --> ;
tTHEN THEN --> ;
tMUL MUL --> ;
tINTEGER INTEGER --> ;
tCHAR CHAR --> ;
tGOTO GOTO --> ;
tDOWNTO DOWNTO --> ;
tCOLON COLON --> ;
tRPARENT RPARENT --> ;
tDO DO --> ;
tUNTIL UNTIL --> ;
tELSE ELSE --> ;
tSTRINGCONST STRINGCONST --> ;
tWHILE WHILE --> ;
tNOT NOT --> ;
tGTH GTH --> ;
tCOMMA COMMA --> ;
tPTR PTR --> ;
tEQU EQU --> ;
tLTH LTH --> ;
tFUNCTION FUNCTION --> ;
tSUB SUB --> ;
tFORWARD FORWARD --> ;
tREALCONST REALCONST --> ;
tBOOLEANCONST BOOLEANCONST --> ;
tGEQ GEQ --> ;
tLPARENT LPARENT --> ;
tADD ADD --> ;
tSEMIC SEMIC --> ;
tFOR FOR --> ;
tRECORD RECORD --> ;
tLEQ LEQ --> ;
tREAL REAL --> ;
tLABEL LABEL --> ;
tPROCEDURE PROCEDURE --> ;
tEXTERNAL EXTERNAL --> ;
tARRAY ARRAY --> ;
tTYPE TYPE --> ;
tEND END --> ;
tVAR VAR --> ;
tBOOLEAN BOOLEAN --> ;
tPACKED PACKED --> ;
tTO TO --> ;
