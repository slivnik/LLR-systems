### PROGRAM:

program_header label_declarations (CONST|TYPE|VAR|PROCEDURE|FUNCTION|BEGIN) --> program_upto_labels(1,2) 3;
program_header (CONST|TYPE|VAR|PROCEDURE|FUNCTION|BEGIN) --> program_upto_labels(1) 2 ;

program_upto_labels const_declarations (TYPE|VAR|PROCEDURE|FUNCTION|BEGIN) --> program_upto_consts(1,2) 3 ;
program_upto_labels (TYPE|VAR|PROCEDURE|FUNCTION|BEGIN) --> program_upto_consts(1) 2 ;

program_upto_consts type_declarations (VAR|PROCEDURE|FUNCTION|BEGIN) --> program_upto_types(1,2) 3 ;
program_upto_consts (VAR|PROCEDURE|FUNCTION|BEGIN) --> program_upto_types(1) 2 ;

program_upto_types var_declarations (PROCEDURE|FUNCTION|BEGIN) --> program_upto_vars(1,2) 3 ;
program_upto_types (PROCEDURE|FUNCTION|BEGIN) --> program_upto_vars(1) 2 ;

program_upto_vars subprogram --> 1 subprgs(2) ;
program_upto_vars subprgs subprogram --> 1 subprgs(2,3) ;
program_upto_vars subprgs BEGIN --> program_upto_subprograms(1,2) 3 ;
program_upto_vars BEGIN --> program_upto_subprograms(1) 2 ;

program_upto_subprograms block_stmt DOT --> program(1,2,3) ;

### PROGRAM HEADER:

PROGRAM IDENTIFIER SEMIC --> program_header(1,2,3) ;
PROGRAM IDENTIFIER LPARENT RPARENT SEMIC --> program_header(1,2,3,4) ;
PROGRAM IDENTIFIER LPARENT file_names RPARENT SEMIC --> program_header(1,2,3,4,5,6) ;

PROGRAM IDENTIFIER LPARENT IDENTIFIER --> 1 2 3 file_names(4);
file_names COMMA IDENTIFIER --> file_names(1,2,3) ;

### LABEL DECLARATIONS:

LABEL label_names SEMIC --> label_declarations(1,2,3) ;

LABEL INTEGERCONST --> 1 label_names(2) ;
label_names COMMA INTEGERCONST --> label_names(1,2,3) ;

### CONST DECLARATIONS:

(CONST|const_declarations) IDENTIFIER EQU (STRINGCONST|REALCONST|INTEGERCONST|BOOLEANCONST|IDENTIFIER) --> 1 2 3 constant(4) ;
(CONST|const_declarations) IDENTIFIER EQU (ADD|SUB) (STRINGCONST|REALCONST|INTEGERCONST|BOOLEANCONST|IDENTIFIER) SEMIC --> 1 2 3 constant(4,5) ;

(CONST|const_declarations) IDENTIFIER EQU constant SEMIC --> 1 const_declaration(2,3,4,5) ;

CONST const_declaration --> const_declarations(1,2) ;
const_declarations const_declaration --> const_declarations(1,2) ;

### TYPE DECLARATIONS:

(TYPE IDENTIFIER EQU|type_declarations IDENTIFIER EQU|
 ARRAY LBRACKET|ARRAY LBRACKET simple_types COMMA|ARRAY LBRACKET simple_types RBRACKET OF|
 FILE OF|SET OF|record_field_names COLON|var_names COLON)
 IDENTIFIER --> 1 named_type(2) ;
(TYPE IDENTIFIER EQU|type_declarations IDENTIFIER EQU|
 ARRAY LBRACKET|ARRAY LBRACKET simple_types COMMA|ARRAY LBRACKET simple_types RBRACKET OF|
 FILE OF|SET OF|record_field_names COLON|var_names COLON)
 (STRINGCONST|REALCONST|INTEGERCONST|BOOLEANCONST|IDENTIFIER) INTERVAL --> 1 constant(2) 3 ;
(TYPE IDENTIFIER EQU|type_declarations IDENTIFIER EQU|
 ARRAY LBRACKET|ARRAY LBRACKET simple_types COMMA|ARRAY LBRACKET simple_types RBRACKET OF|
 FILE OF|SET OF|record_field_names COLON|var_names COLON)
 (ADD|SUB) (STRINGCONST|REALCONST|INTEGERCONST|BOOLEANCONST|IDENTIFIER) INTERVAL --> 1 constant(2,3) 4;
(TYPE IDENTIFIER EQU|type_declarations IDENTIFIER EQU|
 ARRAY LBRACKET|ARRAY LBRACKET simple_types COMMA|ARRAY LBRACKET simple_types RBRACKET OF|
 FILE OF|SET OF|record_field_names COLON|var_names COLON)
 PTR IDENTIFIER --> 1 pointer_type(2,3) ;
(TYPE IDENTIFIER EQU|type_declarations IDENTIFIER EQU|
 ARRAY LBRACKET|ARRAY LBRACKET simple_types COMMA|ARRAY LBRACKET simple_types RBRACKET OF|
 FILE OF|SET OF|record_field_names COLON|var_names COLON)
 LPARENT IDENTIFIER --> 1 2 enum_names(3) ;

(TYPE|type_declarations) IDENTIFIER EQU type SEMIC --> 1 type_declaration(2,3,4,5) ;
TYPE type_declaration --> type_declarations(1,2) ;
type_declarations type_declaration --> type_declarations(1,2) ;

(CHAR|REAL|INTEGER|BOOLEAN) --> atom_type(1) ;

enum_names COMMA IDENTIFIER --> enum_names(1,2,3) ;
LPARENT enum_names RPARENT --> enum_type(1,2,3) ;

INTERVAL (STRINGCONST|REALCONST|INTEGERCONST|BOOLEANCONST|IDENTIFIER) --> 1 constant(2) ;
INTERVAL (ADD|SUB) (STRINGCONST|REALCONST|INTEGERCONST|BOOLEANCONST|IDENTIFIER) --> 1 constant(2,3) ;
constant INTERVAL constant --> subrange_type(1,2,3) ;

(atom_type|named_type|enum_type|subrange_type) --> simple_type(1) ;

ARRAY LBRACKET simple_type --> 1 2 simple_types(3) ;
simple_types COMMA simple_type --> simple_types(1,2,3) ;
ARRAY LBRACKET simple_types RBRACKET OF type --> array_type(1,2,3,4,5,6) ;

FILE OF type --> file_type(1,2,3) ;

SET OF simple_type --> set_type(1,2,3) ;

RECORD SEMIC --> RECORD(1,2) ;

RECORD END --> record_type(1,2) ;
RECORD record_field_declarations END --> record_type(1,2,3) ;
RECORD record_field_declarations SEMIC END --> record_type(1,2,3,4) ;
RECORD record_field_declarations SEMIC record_case END --> record_type(1,2,3,4,5) ;
RECORD record_field_declarations SEMIC record_case SEMIC END --> record_type(1,2,3,4,5,6) ;
RECORD record_case END --> record_type(1,2,3) ;
RECORD record_case SEMIC END --> record_type(1,2,3,4) ;

(RECORD|record_constants COLON LPARENT) record_field_declaration --> 1 record_field_declarations(2) ;
record_field_declarations SEMIC SEMIC --> 1 SEMIC(2,3) ;
record_field_declarations SEMIC record_field_declaration --> record_field_declarations(1,2,3) ;

record_field_names COLON type --> record_field_declaration(1,2,3) ;

(RECORD|record_field_declarations SEMIC|record_constants COLON LPARENT) IDENTIFIER --> 1 record_field_names(2) ;
record_field_names COMMA IDENTIFIER --> record_field_names(1,2,3) ;

record_case_header (RPARENT|END|SEMIC RPARENT|SEMIC END) --> record_case(1) 2 ; 
record_case_header record_case_branches (RPARENT|END|SEMIC RPARENT|SEMIC END) --> record_case(1,2) 3 ; 

(RECORD|record_field_declarations SEMIC) CASE IDENTIFIER OF --> 1 2 named_type(3) 4;
(RECORD|record_field_declarations SEMIC) CASE IDENTIFIER COLON IDENTIFIER OF --> 1 2 3 4 named_type(5) 6;
(RECORD|record_field_declarations SEMIC) CASE (atom_type|named_type) OF --> 1 record_case_header(2,3,4) ;
(RECORD|record_field_declarations SEMIC) CASE IDENTIFIER COLON (atom_type|named_type) OF --> 1 record_case_header(2,3,4,5,6) ;

record_case_header SEMIC --> record_case_header(1,2) ;

record_constants COLON LPARENT RPARENT --> record_case_branch(1,2,3,4) ;
record_constants COLON LPARENT record_field_declarations RPARENT --> record_case_branch(1,2,3,4,5) ;
record_constants COLON LPARENT record_field_declarations SEMIC RPARENT --> record_case_branch(1,2,3,4,5,6) ;
record_constants COLON LPARENT record_field_declarations SEMIC record_case RPARENT --> record_case_branch(1,2,3,4,5,6,7) ;
record_constants COLON LPARENT record_field_declarations SEMIC record_case SEMIC RPARENT --> record_case_branch(1,2,3,4,5,6,7,8) ;
record_constants COLON LPARENT record_case RPARENT --> record_case_branch(1,2,3,4,5) ;
record_constants COLON LPARENT record_case SEMIC RPARENT --> record_case_branch(1,2,3,4,5,6) ;

record_case_header record_case_branch --> 1 record_case_branches(2) ;
record_case_branches SEMIC SEMIC --> 1 SEMIC(2,3) ;
record_case_branches SEMIC record_case_branch --> record_case_branches(1,2,3) ;

(record_case_header|record_case_branches SEMIC|record_constants COMMA) (STRINGCONST|REALCONST|INTEGERCONST|BOOLEANCONST|IDENTIFIER) --> 1 record_constant(2) ;
(record_case_header|record_case_branches SEMIC|record_constants COMMA) (ADD|SUB) (STRINGCONST|REALCONST|INTEGERCONST|BOOLEANCONST|IDENTIFIER) --> 1 record_constant(2,3) ;

(record_case_header|record_case_branches SEMIC) record_constant --> 1 record_constants(2) ;
record_constants COMMA record_constant --> record_constants(1,2,3) ;

(array_type|file_type|set_type|record_type) --> struct_type(1) ;

PACKED struct_type --> packed_type(1,2) ;

(simple_type|pointer_type|struct_type|packed_type) --> type(1) ;

### VAR DECLARATIONS:

(VAR|var_declarations) IDENTIFIER --> 1 var_names(2) ;
var_names COMMA IDENTIFIER --> var_names(1,2,3) ;

var_names COLON type SEMIC --> var_declaration(1,2,3,4) ;
VAR var_declaration --> var_declarations(1,2) ;
var_declarations var_declaration --> var_declarations(1,2) ;

### SUBPROGRAM DECLARATIONS:

(procedure_header|function_header) --> subprogram_header(1) ;

PROCEDURE IDENTIFIER SEMIC --> procedure_header(1,2,3) ;
PROCEDURE IDENTIFIER LPARENT par_declarations RPARENT SEMIC --> procedure_header(1,2,3,4,5,6) ;

FUNCTION IDENTIFIER COLON IDENTIFIER --> 1 2 3 named_type(4) ;
FUNCTION IDENTIFIER LPARENT par_declarations RPARENT COLON IDENTIFIER --> 1 2 3 4 5 6 named_type(7) ;
FUNCTION IDENTIFIER COLON (atom_type|named_type) SEMIC --> function_header(1,2,3,4,5) ;
FUNCTION IDENTIFIER LPARENT par_declarations RPARENT COLON (atom_type|named_type) SEMIC --> function_header(1,2,3,4,5,6,7,8) ;

(FUNCTION|PROCEDURE) IDENTIFIER LPARENT IDENTIFIER --> 1 2 3 par_names(4) ;
(FUNCTION|PROCEDURE) IDENTIFIER LPARENT (VAR|FUNCTION|PROCEDURE) IDENTIFIER --> 1 2 3 4 par_names(5) ;
(par_declarations SEMIC) IDENTIFIER --> 1 par_names(2) ;
(par_declarations SEMIC VAR|par_declarations SEMIC FUNCTION|par_declarations SEMIC PROCEDURE) IDENTIFIER --> 1 par_names(2) ;
par_names COMMA IDENTIFIER --> par_names(1,2,3) ;

par_names COLON IDENTIFIER --> 1 2 named_type(3) ;
par_names COLON (atom_type|named_type) (SEMIC|RPARENT) --> val_par_declaration(1,2,3) 4 ;
VAR par_names COLON (atom_type|named_type) (SEMIC|RPARENT) --> ref_par_declaration(1,2,3,4) 5 ;
FUNCTION par_names COLON (atom_type|named_type) (SEMIC|RPARENT) --> func_par_declaration(1,2,3,4) 5 ;
PROCEDURE par_names (SEMIC|RPARENT) --> proc_par_declaration(1,2) 3 ;

(val_par_declaration|ref_par_declaration|func_par_declaration|proc_par_declaration) --> par_declaration(1) ;

LPARENT par_declaration --> 1 par_declarations(2) ;
par_declarations SEMIC par_declaration --> par_declarations(1,2,3) ;
subprogram_header (EXTERNAL|FORWARD) SEMIC --> subprogram(1,2,3) ;
#subprogram_header block_stmt --> subprogram_declaration(1,2) ;

subprogram_declaration subprogram_declaration --> subprogram_declarations(1,2) ;
subprogram_declarations subprogram_declaration --> subprogram_declarations(1,2) ;

subprogram_header label_declarations (CONST|TYPE|VAR|PROCEDURE|FUNCTION|BEGIN) --> subprogram_upto_labels(1,2) 3;
subprogram_header (CONST|TYPE|VAR|PROCEDURE|FUNCTION|BEGIN) --> subprogram_upto_labels(1) 2 ;

subprogram_upto_labels const_declarations (TYPE|VAR|PROCEDURE|FUNCTION|BEGIN) --> subprogram_upto_consts(1,2) 3 ;
subprogram_upto_labels (TYPE|VAR|PROCEDURE|FUNCTION|BEGIN) --> subprogram_upto_consts(1) 2 ;

subprogram_upto_consts type_declarations (VAR|PROCEDURE|FUNCTION|BEGIN) --> subprogram_upto_types(1,2) 3 ;
subprogram_upto_consts (VAR|PROCEDURE|FUNCTION|BEGIN) --> subprogram_upto_types(1) 2 ;

subprogram_upto_types var_declarations (PROCEDURE|FUNCTION|BEGIN) --> subprogram_upto_vars(1,2) 3 ;
subprogram_upto_types (PROCEDURE|FUNCTION|BEGIN) --> subprogram_upto_vars(1) 2 ;

subprogram_upto_vars subprogram --> 1 subprgs(2) ;
subprogram_upto_vars subprgs subprogram --> 1 subprgs(2,3) ;
subprogram_upto_vars subprgs BEGIN --> subprogram_upto_subprograms(1,2) 3 ;
subprogram_upto_vars BEGIN --> subprogram_upto_subprograms(1) 2 ;

subprogram_upto_subprograms block_stmt SEMIC --> subprogram(1,2,3) ;

### STATEMENTS:

BEGIN SEMIC --> BEGIN(1,2) ;
REPEAT SEMIC --> REPEAT(1,2) ;
(BEGIN|REPEAT) stmt --> 1 stmts(2) ;
stmts SEMIC SEMIC --> 1 SEMIC(2,3) ;
stmts SEMIC stmt --> stmts(1,2,3) ;

(BEGIN|if_then|if_else|case_constants COLON|DO|REPEAT|stmts SEMIC) INTEGERCONST COLON --> 1 stmt_label(2) ;

(labeled_stmt|assign_stmt|proc_stmt|block_stmt|if_stmt|case_stmt|while_stmt|repeat_stmt|for_stmt|with_stmt|goto_stmt) --> stmt(1) ;
stmt_label (END|ELSE|UNTIL|SEMIC) --> stmt(1) 2 ;

stmt_label stmt --> labeled_stmt(1,2) ;

(BEGIN|if_then|if_else|case_constants COLON|DO|REPEAT|stmt_label|stmts SEMIC) IDENTIFIER (PTR|DOT|LBRACKET|ASSIGN) --> 1 var_name(2) 3 ;
(BEGIN|if_then|if_else|case_constants COLON|DO|REPEAT|stmt_label|stmts SEMIC) IDENTIFIER LPARENT --> 1 proc_name(2) pstfix_lparent(3) ;
(BEGIN|if_then|if_else|case_constants COLON|DO|REPEAT|stmt_label|stmts SEMIC) IDENTIFIER --> 1 proc_stmt(2) ;

var_name --> var(1) ;
var_name PTR --> var_name(1,2) ;
var_name DOT IDENTIFIER --> var_name(1,2,3) ;
var_name LBRACKET --> var_core(1) pstfix_lbracket(2) ;
var_core pstfix_lbracket exprs RBRACKET --> var_name(1,2,3,4) ;
var ASSIGN expr --> assign_stmt(1,2,3) ;

proc_name pstfix_lparent args RPARENT --> proc_stmt(1,2,3,4) ;

BEGIN END --> block_stmt(1,2) ;
BEGIN stmts END --> block_stmt(1,2,3) ;
BEGIN stmts SEMIC END --> block_stmt(1,2,3,4) ;

IF expr THEN --> if_then(1,2,3) ;
if_then stmt --> if_stmt(1,2) ;
if_then (END|ELSE|UNTIL|SEMIC) --> if_else(1,2) ;
if_then stmt ELSE --> if_else(1,2,3) ;
if_else stmt --> if_stmt(1,2) ;
if_else (END|ELSE|UNTIL|SEMIC) --> if_stmt(1) 2 ;

(BEGIN|if_then|if_else|case_constants COLON|DO|REPEAT|stmt_label|stmts SEMIC) CASE expr OF --> 1 case_header(2,3,4) ;

(case_header|case_branches SEMIC|case_constants COMMA) (STRINGCONST|REALCONST|INTEGERCONST|BOOLEANCONST|IDENTIFIER) --> 1 case_constant(2) ;
(case_header|case_branches SEMIC|case_constants COMMA) (ADD|SUB) (STRINGCONST|REALCONST|INTEGERCONST|BOOLEANCONST|IDENTIFIER) --> 1 case_constant(2,3) ;

(case_header|case_branches SEMIC) case_constant --> 1 case_constants(2) ;
case_constants COMMA case_constant --> case_constants(1,2,3) ;

case_constants COLON stmt --> case_branch(1,2,3) ;
case_constants COLON (SEMIC|END) --> case_branch(1,2) 3 ;
case_header case_branch --> 1 case_branches(2) ;
case_branches SEMIC SEMIC --> 1 SEMIC(2,3) ;
case_branches SEMIC case_branch --> case_branches(1,2,3) ;

case_header case_branches END --> case_stmt(1,2,3) ;
case_header case_branches SEMIC END --> case_stmt(1,2,3,4) ;

WHILE expr DO stmt --> while_stmt(1,2,3,4) ;

REPEAT stmts UNTIL expr --> repeat_stmt(1,2,3,4) ;
REPEAT stmts SEMIC UNTIL expr --> repeat_stmt(1,2,3,4,5) ;

FOR IDENTIFIER ASSIGN expr (TO|DOWNTO) expr DO stmt --> for_stmt(1,2,3,4,5,6,7,8) ;
FOR IDENTIFIER ASSIGN expr (TO|DOWNTO) expr STEP expr DO stmt --> for_stmt(1,2,3,4,5,6,7,8,9,10) ;

WITH vars DO stmt --> with_stmt(1,2,3,4) ;
(WITH|vars COMMA) IDENTIFIER --> 1 var_name(2) ;
WITH var --> 1 vars(2) ;
vars COMMA var --> vars(1,2,3) ;

GOTO INTEGERCONST --> goto_stmt(1,2) ;

### EXPRESSIONS:

(ASSIGN|IF|CASE|WHILE|UNTIL|TO|DOWNTO|STEP|expr_lparent|pstfix_lbracket|pstfix_lparent|pstfix_op|prefix_op|mul_op|add_op|rel_op|exprs COMMA|args COMMA) (BOOLEANCONST|STRINGCONST|REALCONST|INTEGERCONST|IDENTIFIER) --> 1 atom_expr(2) ;
(ASSIGN|IF|CASE|WHILE|UNTIL|TO|DOWNTO|STEP|expr_lparent|pstfix_lbracket|pstfix_lparent|pstfix_op|prefix_op|mul_op|add_op|rel_op|exprs COMMA|args COMMA) LPARENT --> 1 expr_lparent(2) ;
(ASSIGN|IF|CASE|WHILE|UNTIL|TO|DOWNTO|STEP|expr_lparent|pstfix_lbracket|pstfix_lparent|pstfix_op|prefix_op|mul_op|add_op|rel_op|exprs COMMA|args COMMA) (ADD|SUB|NOT|PTR) --> 1 prefix_op(2) ;

atom_expr --> pstfix_expr(1) ;
pstfix_expr (PTR|DOT|LBRACKET|LPARENT) --> pstfix_core(1) 2;
pstfix_core PTR --> pstfix_expr(1,2) ;
pstfix_core DOT IDENTIFIER --> pstfix_expr(1,2,3) ;
pstfix_core LBRACKET --> 1 pstfix_lbracket(2) ;
pstfix_core pstfix_lbracket exprs RBRACKET --> pstfix_expr(1,2,3,4) ;
pstfix_core LPARENT --> 1 pstfix_lparent(2) ;
pstfix_core pstfix_lparent args RPARENT --> pstfix_expr(1,2,3,4) ;

pstfix_lbracket expr --> 1 exprs(2) ;
exprs COMMA expr --> exprs(1,2,3) ;

(pstfix_lparent|args COMMA) expr --> 1 arg(2) ;
(pstfix_lparent|args COMMA) expr COLON INTEGERCONST --> 1 arg(2,3,4) ;
(pstfix_lparent|args COMMA) expr COLON INTEGERCONST COLON INTEGERCONST --> 1 arg(2,3,4,5,6) ;
pstfix_lparent arg --> 1 args(2) ;
args COMMA arg --> args(1,2,3) ;

pstfix_expr --> prefix_expr(1) ;
prefix_op pstfix_expr --> prefix_expr(1,2) ;
prefix_op pstfix_expr (PTR|DOT|LBRACKET|LPARENT) --> 1 pstfix_core(2) 3 ;

prefix_expr --> mul_expr(1) ;
mul_expr (MUL|DIV|IDIV|IMOD|AND) --> mul_core(1) mul_op(2) ;
mul_core mul_op mul_expr --> mul_expr(1,2,3) ;

mul_expr --> add_expr(1) ;
add_expr (ADD|SUB|OR) --> add_core(1) add_op(2) ;
add_core add_op add_expr --> add_expr(1,2,3) ;

add_expr --> rel_core_a(1) ;
rel_core_a (EQU|NEQ|LTH|GTH|LEQ|GEQ|IN) --> rel_core_b (1) rel_op(2) ;
rel_core_a --> rel_expr(1) ;
rel_core_b rel_op rel_core_a --> rel_expr(1,2,3) ;

rel_expr --> expr(1) ;

expr_lparent expr RPARENT --> atom_expr(1,2,3) ;
