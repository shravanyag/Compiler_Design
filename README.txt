TOPIC : Implementing Closure in functions (inner functions) and if conditional statement
Team 2 (E2) Memebers:	(VI Semester E Section)
01FB15ECS266	Sanjuktha Geeravani B P
01FB15ECS282	Shravanya G
01FB15ECS287	Shruthi K
01FB15ECS294	Sindhu

How to run our files:
Open a terminal in any Linux platform and type:
bash execute.sh
The bash file will perform Lexical Analysis and Parsing to generate the following in the same order:
Removal of comments - display on terminal
Symbol Table - display on terminal
ICG - display on terminal
Optimized ICG - display on terminal
AST - output into a file named astout.txt

Project :
The language the compiler is designed for is C. The properties we have implemented includes the basic structure of C 
which includes initializing variables, creating main and other functions, preprocessor directives limited to including 
<stdio.h> and so on. Our specific area of interest was IF CONDITIONAL STATAEMENTS and CLOSURE PROPERTY OF FUNCTIONS.
Closure as it is, is not a property of C language. Closure is implemented by allowing the grammar to
handle inner functions and using non local variables.

Implementation:
Simple Lex(comments.l and lex.l) and Yacc programs were written for the same. The types of error that have been handled is : 
Type error, Semicolon missing error(symtab.y). The ICG generated is the 3 address code format (icg.y).
The optimizations performed are : copy propagation and constant propagation (opt.y). Also all if-else statements were
optimized to ifFalse statements to reduce the number of goto statements (an additional optimization provided).
The AST is built by treating each non-terminal as a node in the tree (ast.y). The tree built is printed in the 
level order traversal for easier understanding.


