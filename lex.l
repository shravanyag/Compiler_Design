%{
	#include "y.tab.h"
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	void yyerror(const char *);
%} 
%option yylineno

%%
"main"		return MAIN;
"int"		return INT;
"char"  	return CHAR;
"void"		return VOID;
"closure"	return CLOSURE;
"#"		return HASH;
"include"	return INCLUDE;
"<stdio.h>"	return LIBRARY;
"while"		return WHILE;
"for"		return FOR;
"if"		return IF;
"else"		return ELSE;
"continue"	return CONT;
"break"		return BRK;
"return"	return RTRN;
[0-9]+	{yylval.num=(double)atof(yytext);return NUM;}
[a-zA-Z][a-zA-Z0-9]* {yylval.str=strdup(yytext);return ID;}
"="		return EQUAL;
";"		return SEMICOLON;
":"		return COLON;
"{"  		return SO;
"}"  		return SC;
"(" 		return OB;
")"		return CB;
","		return COMMA;
"+="		return ADDRIGHT;
"++"		return ADDPREFIX;
"+"		return ADD;
"-="		return SUBRIGHT;
"--"		return SUBPREFIX;
"-"		return SUB;
"*="		return MULRIGHT;
"*"		return MUL;
"/="		return DIVRIGHT;
"/"		return DIV;
"<"		return LT;
">"		return GT;
">="		return GTE;
"<="		return LTE;
"!="		return NE;
"=="		return EQ;
"&&" 		return BINARYAND;
"||"        	return BINARYOR;
" "		;
\t 		;
\n		;
. 		return *yytext;

%%

int yywrap(void)
{
	return 1;
}

