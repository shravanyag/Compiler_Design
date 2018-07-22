%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	FILE *yyin;
	extern int yylineno;
	struct treeNode
	{
		char name[20];
		struct treeNode* left;
		struct treeNode* right;
		char str1[100];
		char str2[100];
	};
	struct treeNode *createNode(char *, struct treeNode *, struct treeNode *, char *, char *);
	struct treeNode *head;
	struct treeNode *tempNode1;
	struct treeNode *tempNode2;
	
	char temptype[50];
	char temp[50];
	char buffer[50];
	char tempFunc[50];
	char tempparams[100];
	char extraval[20];
	char templog[20];
	char temprel[20];
	
	int closure = 0;
	int tempval;
	void display();
	int height(struct treeNode *);
	void printLevel(struct treeNode *, int);
	void yyerror(const char*);
	int yylex();
%}
%name parse
%union 
{
	char *str;
	int num;
	struct treeNode *node;
};

%token INT MAIN OB CB SO SC CLOSURE COLON HASH INCLUDE LIBRARY
%token IF ELSE WHILE FOR CONT BRK RTRN SEMICOLON BINARYOR BINARYAND LT
%token GT LTE GTE NE EQ VOID CHAR COMMA EQUAL SUBPREFIX 
%token ADD SUB MUL DIV ADDRIGHT SUBRIGHT MULRIGHT DIVRIGHT ADDPREFIX
%token<str> ID
%token<num> NUM 
%type<num> E T F
%type<node> Main CompoundStmt Global GlobeDeclaration GlobeAssignExpr FunctionDefinition ClosureFunctionDefinition
%type<node> Stmt Function ClosureFunction Declaration FunctionCall AssignExpr SelectionStmt JumpStmt cond Expr
%type<node> relExp logExp VarList

%%
PreProcessorDirectives : HASH INCLUDE LIBRARY Global	
							{ head = createNode("Start", NULL, $4, "#include<stdio.h>", NULL);
							 printf("\n______________________________________________________\n"); 
							 printf("\nAST Successfully Created!!!\n\n"); 
							 display(); 
							 printf("\n______________________________________________________\n\n");}
		       ;
Main : INT MAIN OB CB CompoundStmt Function '~' {$$ = createNode("Main", $5, $6, NULL, NULL); }
     ;
Identifier : ID {strcpy(temp,yylval.str);}
	   ;
CompoundStmt : SO Stmt SC {$$ = $2;}
	     ;
Global : FunctionDefinition Global		{$$ = createNode("Global Sequence", $1, $2, NULL, NULL);}
       | ClosureFunctionDefinition Global	{$$ = createNode("Global Sequence", $1, $2, NULL, NULL);}
       | GlobeDeclaration Global		{$$ = createNode("Global Sequence", $1, $2, NULL, NULL);}
       | Main					{$$ = $1;}
       ;
GlobeDeclaration : Type VarList SEMICOLON	{$$ = createNode("Declaration", NULL, $2, temptype, NULL); }
	    	 | Type GlobeAssignExpr		{$$ = createNode("Declaration", NULL, $2, temptype, NULL); }
	         ;
GlobeAssignExpr : Identifier EQUAL Extra COMMA GlobeAssignExpr	{ tempNode1 = createNode("=", NULL, NULL, temp, extraval);
								  $$ = createNode(",", tempNode1, $5, NULL, NULL);
								  }
	   	| Identifier EQUAL Extra SEMICOLON		{ $$ = createNode("=", NULL, NULL, temp, extraval);}
	  	;
FunctionDefinition : FunctionName OB CB SEMICOLON 
		   {	 if(closure)
		   	 	$$ = createNode("Closure Definition", NULL, NULL, tempFunc, "no params");
		   	 else
		   	 {	$$ = createNode("Function Definition", NULL, NULL, tempFunc, "no params");
			 strcpy(tempparams, "");
			 strcpy(tempFunc, "");
			 closure = 0;
		   	 }
		   }
		   | FunctionName OB ParamsType CB SEMICOLON
		   {	 if(closure)
		   	 	$$ = createNode("Closure Definition", NULL, NULL, tempFunc, tempparams);
		   	 else
		   	 	$$ = createNode("Function Definition", NULL, NULL, tempFunc, tempparams);
			 strcpy(tempparams, "");
			 strcpy(tempFunc, "");
			 closure = 0;
		   }
		   ;
FunctionName : Type Identifier {strcat(temptype, " "); strcat(temptype, temp); strcpy(tempFunc, temptype);}
		;
ParamsType : ParamsType COMMA Type	{strcat(tempparams, temptype); strcat(tempparams, " ");}
	   | Type			{strcat(tempparams, temptype); strcat(tempparams, " ");}
	   ;
ClosureFunctionDefinition : CLOSURE COLON FunctionDefinition {$$ = $3;}
			  ;
Stmt : Extra SEMICOLON Stmt	{$$ = createNode("Sequence", NULL, $3, extraval, NULL); }
     | Declaration Stmt		{$$ = createNode("Sequence", $1, $2, NULL, NULL); }
     | AssignExpr Stmt		{$$ = createNode("Sequence", $1, $2, NULL, NULL); }
     | SelectionStmt Stmt	{$$ = createNode("Sequence", $1, $2, NULL, NULL); }
     | JumpStmt	Stmt		{$$ = createNode("Sequence", $1, $2, NULL, NULL); }
     | FunctionCall Stmt	{$$ = createNode("Sequence", $1, $2, NULL, NULL); }
     | CompoundStmt Stmt	{$$ = createNode("Sequence", $1, $2, NULL, NULL); }
     | error SEMICOLON	{yyerrok; yyclearin; printf("missing ';'\n"); $$ = createNode("error", NULL, NULL, "semicolon missing", NULL);}
     |	{printf("");}
     ;
Function : FunctionName OB CB CompoundStmt Function {	tempNode1 = createNode(tempFunc, NULL, $4, "no params", NULL);
							$$ = createNode("Functions", tempNode1, $5, NULL, NULL);
							strcpy(tempFunc,"");	}
	 | FunctionName OB FunctionParams CB SO Stmt ClosureFunction Stmt SC Function 
	   {	tempNode2 = createNode("Function Sequence", $6, $8, NULL, NULL);
	   	tempNode1 = createNode(tempFunc, NULL, tempNode2, tempparams, NULL);
	   	strcpy(tempparams, "");
	   	strcpy(tempFunc,"");
	   	tempNode2 = createNode("Closure Sequence", $7, $10, NULL, NULL);
		$$ = createNode("Functions", NULL, tempNode1, tempNode2, NULL);		}
	 | FunctionName OB CB SO Stmt ClosureFunction Stmt SC Function 
	   {	tempNode2 = createNode("Function Sequence", $5, $7, NULL, NULL);
	   	tempNode1 = createNode(tempFunc, NULL, tempNode2, "no params", NULL);
	   	strcpy(tempparams, "");
	   	strcpy(tempFunc,"");
	   	tempNode2 = createNode("Closure Sequence", $6, $9, NULL, NULL);
		$$ = createNode("Functions", NULL, tempNode1, tempNode2, NULL);		}
	 | FunctionName OB FunctionParams CB CompoundStmt Function 
	 {	tempNode1 = createNode(tempFunc, NULL, $5, tempparams, NULL);
		$$ = createNode("Functions", tempNode1, $6, NULL, NULL);
		strcpy(tempFunc,"");
		strcpy(tempparams,"");	}
	 |		{printf("");}
	 ;
ClosureFunction : CLOSURE COLON FunctionName OB CB SO Stmt SC 
		 {	strcat(tempFunc, " closure");
		 	$$ = createNode(tempFunc, NULL, $7, "no params", NULL);
		 	strcpy(tempFunc, "");		
		 }
	        | CLOSURE COLON FunctionName OB FunctionParams CB SO Stmt SC 
	        {	strcat(tempFunc, " closure");
	        	$$ = createNode(tempFunc, NULL, $8, tempparams, NULL);
	        	strcpy(tempFunc, "");
	        	strcpy(tempparams, "");  
	        }
	        ;
FunctionParams : FunctionParams COMMA Type Identifier 	{strcat(tempparams, temptype); strcat(tempparams, " ");
							 strcat(tempparams, temp); strcat(tempparams, ",");}
	       | Type Identifier			{strcat(tempparams, temptype); strcat(tempparams, " ");
							 strcat(tempparams, temp);}
	       ;
Declaration : Type VarList SEMICOLON {$$ = createNode("Declaration", NULL, $2, temptype, NULL); }
	    | Type AssignExpr	     {$$ = createNode("Declaration", NULL, $2, temptype, NULL); }
	    ;
FunctionCall : Identifier EQUAL Identifier OB VarList CB SEMICOLON
		{$$ = createNode("call", NULL, $5, temp, NULL); }
	     | Identifier OB VarList CB SEMICOLON
	        {$$ = createNode("call", NULL, $3, temp, NULL); }
	     ;
AssignExpr : Identifier EQUAL Extra COMMA AssignExpr	{ tempNode1 = createNode("=", NULL, NULL, temp, extraval);
								  $$ = createNode(",", tempNode1, $5, NULL, NULL);
								  }
	   | Identifier EQUAL Extra SEMICOLON		{ $$ = createNode("=", NULL, NULL, temp, extraval); }
	  	;
SelectionStmt : IF OB cond CB CompoundStmt	{$$ = createNode("if", $3, $5, NULL, NULL); }
	      | IF OB cond CB CompoundStmt ELSE CompoundStmt	{
	      		tempNode1 = createNode("if", $3, $5, NULL, NULL);
	      		tempNode2 = createNode("else", $7, NULL, NULL, NULL);
	      		$$ = createNode("selection", tempNode1, tempNode2, NULL, NULL); }
	      ;
JumpStmt : CONT SEMICOLON	{$$ = createNode("continue", NULL, NULL, NULL, NULL); }
	 | BRK SEMICOLON 	{$$ = createNode("break", NULL, NULL, NULL, NULL); }
	 | RTRN Extra SEMICOLON	{$$ = createNode("return", NULL, NULL, extraval, NULL); }
	 ;
cond : Expr	{$$ = createNode("cond", NULL, NULL, extraval, NULL); }	
     | Expr logOp Expr	{$$ = createNode(templog, $1, $3, NULL, NULL); }
     ;
Expr : relExp {$$ = $1;}
     | logExp {$$ = $1;}
     ;
relExp : Extra relOp E {sprintf(buffer, "%d", $3); $$ = createNode(temprel, NULL, NULL, extraval, buffer); }	
       ;
logExp : Extra logOp E  {sprintf(buffer, "%d", $3); $$ = createNode(templog, NULL, NULL, extraval, buffer); }
       ;
Extra : E {sprintf(buffer, "%d", $1); strcpy(extraval, buffer);}
      ;
logOp : BINARYOR	{strcpy(templog, "||");}
      | BINARYAND	{strcpy(templog, "&&");}
      ;
relOp : LT	{strcpy(temprel, "<");}
      | GT	{strcpy(temprel, ">");}
      | LTE	{strcpy(temprel, "<=");}
      | GTE	{strcpy(temprel, ">=");}
      | NE	{strcpy(temprel, "!=");}
      | EQ	{strcpy(temprel, "==");}
      ;
Type : INT 	{strcpy(temptype,"int");}
     | VOID	{strcpy(temptype,"void");}
     | CHAR 	{strcpy(temptype,"char");}
     ;
VarList : VarList COMMA Identifier {$$ = createNode("varlist", $1, NULL, ",", temp); }
	| Identifier	{ $$ = createNode("varlist", NULL, NULL, temp, NULL); }
	;
E : E ADD T	{$$ = $1 + $3;}		
  | E SUB T	{$$ = $1 - $3;}
  | T		
  ;
T : T MUL F	{$$ = $1 * $3;}		
  | T DIV F	{$$ = $1 / $3;}		
  | F			
  ;
F : ID 			{$$ = -1;}		
  | NUM			{$$ = $1;}
  | OB E CB		{$$ = $2;}
  ;

%%

void yyerror(const char *msg)
{
	fprintf(stderr, "WARNING : line %d : %s\n", yylineno, msg);
}

struct treeNode *createNode(char *n, struct treeNode *l, struct treeNode *r, char *s1, char *s2)
{
	struct treeNode *temp = (struct treeNode *)(malloc(sizeof(struct treeNode)));
	strcpy(temp -> name, n);
	temp -> left = l;
	temp -> right = r;
	if(s1 == NULL)
		strcpy(temp -> str1, "");
	else
		strcpy(temp -> str1, s1);
	if(s2 == NULL)
		strcpy(temp -> str2, "");
	else
		strcpy(temp -> str2, s2);
	return temp;
}

void display()
{
	struct treeNode *curr = head;
	int ht = height(curr);
	int i;
	for(i = 1; i <= ht; ++i)
	{
		for(int space = 15 - i + 1; space > 0; space--)
			printf("\t");
		printf("level : %d [", i);
		printLevel(curr, i);
		printf("]");
		printf("\n\n");
	}
}

int height(struct treeNode *curr)
{
	if(curr == NULL)
		return 0;
	else
	{
		int l = height(curr -> left);
		int r = height(curr -> right);
		if(l > r)
			return (l + 1);
		else
			return(r + 1);
	}
}

void printLevel(struct treeNode *curr, int level)
{
	if(curr == NULL)
		return;
	if(level == 1)
		printf("[ %s | %s | %s ]\t", curr -> name, curr -> str1, curr -> str2);
	else if(level > 1)
	{
		printLevel(curr -> left, level - 1);
		printLevel(curr -> right, level - 1);
		
	}
}

int main()
{
	head = (struct treeNode *)(malloc(sizeof(struct treeNode)));
	tempNode1 = (struct treeNode *)(malloc(sizeof(struct treeNode)));
	tempNode2 = (struct treeNode *)(malloc(sizeof(struct treeNode)));
	yyin = fopen("out.c", "r");
	if(!yyparse())
		;
	else
		printf("Invalid");
	fclose(yyin);
	return 0;
}


