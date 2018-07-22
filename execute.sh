#!bin/sh
echo "______________________________________________________"
echo ""
echo "INPUT PROGRAM:"
echo ""
cat prog.c
echo ""
echo "______________________________________________________"
echo ""
lex comments.l
gcc lex.yy.c -ll -w -o COMMENTS
./COMMENTS
echo ""
echo "AFTER REMOVAL OF COMMENTS:"
echo ""
cat out.c
lex lex.l
yacc -dy -v symtab1.y
gcc lex.yy.c y.tab.c -ll -ly -w -o SYMTABLE
./SYMTABLE
yacc -dy -v icg.y
gcc lex.yy.c y.tab.c -ll -ly -w -o ICG
./ICG
echo ""
yacc -dy -v opt.y
gcc lex.yy.c y.tab.c -ll -ly -w -o OPT
./OPT
yacc -dy -v ast.y
gcc lex.yy.c y.tab.c -ll -ly -w -o AST
echo "AST CREATED SUCCESSFULLY !!!"
echo ""
echo "______________________________________________________"
./AST > astout.txt
gedit astout.txt &
