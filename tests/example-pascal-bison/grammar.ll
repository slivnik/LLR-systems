source -> program .

# *** DECLARATIONS ***

program -> program_header label_part const_part type_part var_part subprg_part compound_stmt DOT .

program_header -> PROGRAM IDENTIFIER files SEMIC .

files -> .
files -> LPARENT file_names RPARENT .

file_names -> IDENTIFIER file_names_1 .

file_names_1 -> COMMA IDENTIFIER file_names_1 .
file_names_1 -> .

label_part -> .
label_part -> LABEL label_decls SEMIC .

label_decls -> label_decl label_decls_1 .

label_decls_1 -> COMMA label_decl label_decls_1 .
label_decls_1 -> .

label_decl -> INTEGERCONST .

const_part -> .
const_part -> CONST const_decls .

const_decls -> const_decl const_decls_1 .

const_decls_1 -> const_decl const_decls_1 .
const_decls_1 -> .

const_decl -> IDENTIFIER EQU constant SEMIC .

type_part -> .
type_part -> TYPE type_decls .

type_decls -> type_decl type_decls_1 .

type_decls_1 -> type_decl type_decls_1 .
type_decls_1 -> .

type_decl -> IDENTIFIER EQU type SEMIC .

var_part -> .
var_part -> VAR var_decls .

var_decls -> var_decl var_decls_1 .

var_decls_1 -> var_decl var_decls_1 .
var_decls_1 -> .

var_decl -> var_names COLON type SEMIC .

var_names -> IDENTIFIER var_names_1 .

var_names_1 -> COMMA IDENTIFIER var_names_1 .
var_names_1 -> .

subprg_part -> .
subprg_part -> subprg_decls .

subprg_decls -> subprg_decl subprg_decls_1 .

subprg_decls_1 -> subprg_decl subprg_decls_1 .
subprg_decls_1 -> .

subprg_decl -> procedure_header subprg_decl_1 .

subprg_decl_1 -> label_part const_part type_part var_part subprg_part compound_stmt SEMIC .
subprg_decl_1 -> EXTERNAL SEMIC .
subprg_decl_1 -> FORWARD SEMIC .

subprg_decl -> function_header subprg_decl_2 .

subprg_decl_2 -> label_part const_part type_part var_part subprg_part compound_stmt SEMIC .
subprg_decl_2 -> EXTERNAL SEMIC .
subprg_decl_2 -> FORWARD SEMIC .

procedure_header -> PROCEDURE IDENTIFIER par_part SEMIC .

function_header -> FUNCTION IDENTIFIER par_part COLON type SEMIC .

par_part -> .
par_part -> LPARENT par_decls RPARENT .

par_decls -> par_decl par_decls_1 .

par_decls_1 -> SEMIC par_decl par_decls_1 .
par_decls_1 -> .

par_decl -> pars COLON type .
par_decl -> VAR pars COLON type .
par_decl -> PROCEDURE IDENTIFIER par_part .
par_decl -> FUNCTION IDENTIFIER par_part COLON type .

pars -> IDENTIFIER pars_1 .

pars_1 -> COMMA IDENTIFIER pars_1 .
pars_1 -> .

# *** STATEMENTS ***

labeled_stmts -> labeled_stmt labeled_stmts_1 .

labeled_stmts_1 -> SEMIC labeled_stmt labeled_stmts_1 .
labeled_stmts_1 -> .

labeled_stmt -> .
labeled_stmt -> stmt .
labeled_stmt -> INTEGERCONST COLON labeled_stmt_1 .

labeled_stmt_1 -> .
labeled_stmt_1 -> stmt .

stmt -> assign_proc_stmt .
stmt -> case_stmt .
stmt -> compound_stmt .
stmt -> for_stmt .
stmt -> goto_stmt .
stmt -> if_stmt .
stmt -> repeat_stmt .
stmt -> while_stmt .
stmt -> with_stmt .

assign_proc_stmt -> IDENTIFIER assign_proc_stmt_1 .

assign_proc_stmt_1 -> .
assign_proc_stmt_1 -> LPARENT args RPARENT .
assign_proc_stmt_1 -> var ASSIGN expr .

case_stmt -> CASE expr OF case_branches END .

case_branches -> case_branch case_branches_1 .

case_branches_1 -> SEMIC case_branch case_branches_1 .
case_branches_1 -> .

case_branch -> .
case_branch -> exprs COLON labeled_stmt .

compound_stmt -> BEGIN labeled_stmts END .

for_stmt -> FOR IDENTIFIER ASSIGN expr for_stmt_1 .

for_stmt_1 -> TO expr for_stmt_2 DO labeled_stmt .
for_stmt_1 -> DOWNTO expr for_stmt_2 DO labeled_stmt .
for_stmt_2 -> .
for_stmt_2 -> STEP expr .

goto_stmt -> GOTO INTEGERCONST .

if_stmt -> IF expr THEN labeled_stmt ELSE labeled_stmt .

repeat_stmt -> REPEAT labeled_stmts UNTIL expr .

while_stmt -> WHILE expr DO labeled_stmt .

with_stmt -> WITH vars DO labeled_stmt .

vars -> IDENTIFIER var vars_1 .

vars_1 -> COMMA IDENTIFIER var vars_1 .
vars_1 -> .

var -> LBRACKET exprs RBRACKET var .
var -> DOT IDENTIFIER var .
var -> PTR var .
var -> .

# *** EXPRESSIONS ***

exprs -> expr exprs_1 .

exprs_1 -> COMMA expr exprs_1 .
exprs_1 -> .

expr -> rel_expr .

rel_expr -> add_expr rel_expr_1 .

rel_expr_1 -> .
rel_expr_1 -> EQU add_expr .
rel_expr_1 -> NEQ add_expr .
rel_expr_1 -> LTH add_expr .
rel_expr_1 -> GTH add_expr .
rel_expr_1 -> LEQ add_expr .
rel_expr_1 -> GEQ add_expr .
rel_expr_1 -> IN add_expr .

add_expr -> mul_expr add_expr_1 .

add_expr_1 -> ADD mul_expr add_expr_1 .
add_expr_1 -> SUB mul_expr add_expr_1 .
add_expr_1 -> OR mul_expr add_expr_1 .
add_expr_1 -> .

mul_expr -> pfx_expr mul_expr_1 .

mul_expr_1 -> MUL pfx_expr mul_expr_1 .
mul_expr_1 -> DIV pfx_expr mul_expr_1 .
mul_expr_1 -> IDIV pfx_expr mul_expr_1 .
mul_expr_1 -> IMOD pfx_expr mul_expr_1 .
mul_expr_1 -> AND pfx_expr mul_expr_1 .
mul_expr_1 -> .

pfx_expr -> sfx_expr .
pfx_expr -> ADD sfx_expr .
pfx_expr -> SUB sfx_expr .
pfx_expr -> NOT sfx_expr .
pfx_expr -> PTR sfx_expr .

sfx_expr -> atom_expr sfx_expr_1 .

sfx_expr_1 -> LBRACKET exprs RBRACKET sfx_expr_1 .
sfx_expr_1 -> DOT IDENTIFIER sfx_expr_1 .
sfx_expr_1 -> PTR sfx_expr_1 .
sfx_expr_1 -> .

atom_expr -> STRINGCONST .
atom_expr -> REALCONST .
atom_expr -> INTEGERCONST .
atom_expr -> BOOLEANCONST .
atom_expr -> NIL .
atom_expr -> LPARENT expr RPARENT .
atom_expr -> IDENTIFIER atom_expr_1 .

atom_expr_1 -> .
atom_expr_1 -> LPARENT args RPARENT .

args -> arg args_1 .

args_1 -> COMMA arg args_1 .
args_1 -> .

arg -> expr arg_1 .

arg_1 -> .
arg_1 -> COLON INTEGERCONST arg_2 .

arg_2 -> .
arg_2 -> COLON INTEGERCONST .

constants -> constant constants_1 .
constants -> IDENTIFIER constants_1 .

constants_1 -> COMMA constant constants_1 .
constants_1 -> COMMA IDENTIFIER constants_1 .
constants_1 -> .

constant -> unsigned_constant .
constant -> ADD constant_1 .
constant -> SUB constant_1 .

constant_1 -> IDENTIFIER .
constant_1 -> unsigned_constant .

unsigned_constant -> STRINGCONST .
unsigned_constant -> REALCONST .
unsigned_constant -> INTEGERCONST .
unsigned_constant -> BOOLEANCONST .

# *** TYPES ***

type -> simple_type .
type -> pointer_type .
type -> struct_type .

simple_type -> atom_type .
simple_type -> scalar_type .
simple_type -> named_subrange_type .

atom_type -> CHAR .
atom_type -> REAL .
atom_type -> INTEGER .
atom_type -> BOOLEAN .

scalar_type -> LPARENT enums RPARENT .

enums -> IDENTIFIER enums_1 .

enums_1 -> COMMA IDENTIFIER enums_1 .
enums_1 -> .

named_subrange_type -> IDENTIFIER named_subrange_type_1 .
named_subrange_type -> constant INTERVAL named_subrange_type_2 .

named_subrange_type_1 -> .
named_subrange_type_1 -> INTERVAL named_subrange_type_2 .
named_subrange_type_2 -> INTEGER .
named_subrange_type_2 -> constant .

pointer_type -> PTR type .

struct_type -> array_type .
struct_type -> file_type .
struct_type -> set_type .
struct_type -> record_type .
struct_type -> PACKED struct_type_1 .

struct_type_1 -> array_type .
struct_type_1 -> file_type .
struct_type_1 -> set_type .
struct_type_1 -> record_type .

array_type -> ARRAY LBRACKET simple_types RBRACKET OF type .

simple_types -> simple_type simple_types_1 .

simple_types_1 -> COMMA simple_type simple_types_1 .
simple_types_1 -> .

file_type -> FILE OF type .

set_type -> SET OF type .

record_type -> RECORD rec_fields END .

rec_fields -> .
rec_fields -> CASE rec_fields_1 .
rec_fields -> rec_comp rec_fields_2 .

rec_fields_1 -> type OF rec_case_branches .
rec_fields_1 -> IDENTIFIER COLON type OF rec_case_branches .
rec_fields_2 -> .
rec_fields_2 -> SEMIC rec_fields .

rec_comp -> SEMIC .
rec_comp -> comps COLON type .

comps -> IDENTIFIER comps_1 .

comps_1 -> COMMA IDENTIFIER comps_1 .
comps_1 -> .

rec_case_branches -> .
rec_case_branches -> rec_case_branch rec_case_branches_1 .

rec_case_branches_1 -> .
rec_case_branches_1 -> SEMIC rec_case_branches .

rec_case_branch -> SEMIC .
rec_case_branch -> constants COLON LPARENT rec_fields RPARENT .
