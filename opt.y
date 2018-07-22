%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>
	char vars[20][10];
	int vals[20];
	int intsym = 0;
	FILE *yyin;
	extern int yylineno;

	struct attr
	{
		char code[100000];
	};
	int label = 1;
	void generateLabel();
	
	int tp = 1;
	void generateTemp();
	
	int ifnum = 0;
	int ifalpha = 0;
	char buf[20];
	char tempT[20];
	char templabel[20];
	char temp[20];
	char namecall[20];
	char tempstr[100000];
	char temptype[20];
	char temptemp1[20];
	char temptemp2[20];
	char templog[20]; 
	char temprel[20];
	char tempparams[100];
	char tempFunc[50];
	
	char * createStr(char *);
	void yyerror(const char*);
	int yylex();
%}
%name parse
%union 
{
	char *str;
	int num;
	struct attr *node;
};

%token INT MAIN OB CB SO SC CLOSURE COLON HASH INCLUDE LIBRARY
%token IF ELSE WHILE FOR CONT BRK RTRN SEMICOLON BINARYOR BINARYAND LT
%token GT LTE GTE NE EQ VOID CHAR COMMA EQUAL SUBPREFIX 
%token ADD SUB MUL DIV ADDRIGHT SUBRIGHT MULRIGHT DIVRIGHT ADDPREFIX
%token<str> ID
%token<num> NUM 
%type<node> E T F VarList Expr Extra relExp logExp cond JumpStmt SelectionStmt AssignExpr
%type<node> FunctionCall Declaration ClosureFunction Function Stmt ClosureFunctionDefinition
%type<node> FunctionDefinition GlobeAssignExpr GlobeDeclaration Global CompoundStmt Main

%%
PreProcessorDirectives : HASH INCLUDE LIBRARY Global	
							{ strcpy(tempstr, "#include<stdio.h>") ; strcat(tempstr, "\n"); strcat(tempstr, $4->code);
							  
							 printf("\nOptimized ICG Successfully Created!!!\n\n"); 
							 printf("%s\n", tempstr);
							 printf("______________________________________________________\n\n"); 
							}
		       ;
Main : INT MAIN OB CB CompoundStmt Function '~' { generateLabel();
																strcpy(tempstr, templabel); 
																strcat(tempstr, $5->code); strcat(tempstr, "\n");
																strcat(tempstr, $6->code); $$ = createStr(tempstr);
																strcpy(tempstr, "");}
     ;
Identifier : ID {strcpy(temp,yylval.str);}
	   ;
CompoundStmt : SO Stmt SC {strcpy(tempstr, $2->code); $$ = createStr(tempstr);
									 strcpy(tempstr, "");}
	     ;
Global : FunctionDefinition Global		{strcpy(tempstr, $1->code); strcat(tempstr, "\n");
														strcat(tempstr, $2->code); $$ = createStr(tempstr);
													 strcpy(tempstr, "");}
       | ClosureFunctionDefinition Global	{strcpy(tempstr, $1->code); strcat(tempstr, "\n");
       													strcat(tempstr, $2->code); $$ = createStr(tempstr);
														 strcpy(tempstr, "");}
       | GlobeDeclaration Global		{strcpy(tempstr, $1->code); strcat(tempstr, "\n");
       										strcat(tempstr, $2->code); $$ = createStr(tempstr);
												 strcpy(tempstr, "");}
       | Main					{strcpy(tempstr,$1->code); $$ = createStr(tempstr);
									 strcpy(tempstr, "");}
       ;
GlobeDeclaration : Type VarList SEMICOLON	{strcat(tempstr, $2->code); 
														$$ = createStr(tempstr);
														strcpy(tempstr, "");}
	    	 | Type GlobeAssignExpr		{
	    	 									strcpy(tempstr, $2->code); $$ = createStr(tempstr);
												 strcpy(tempstr, "");}
	         ;
GlobeAssignExpr : Identifier EQUAL Extra COMMA GlobeAssignExpr	{ 
																					   	strcpy(tempstr, $3->code); strcat(tempstr, "\n");
																					   	strcat(tempstr, temp); strcat(tempstr, " = ");
																					   	strcat(tempstr, "t"); sprintf(buf, "%d", tp-1);
																					   	strcat(tempstr, buf); strcat(tempstr, "\n");
																					   	$$ = createStr(tempstr);
																							 strcpy(tempstr, "");
																		   	   }
	   	| Identifier EQUAL Extra SEMICOLON		{  
																   	strcpy(tempstr, $3->code); strcat(tempstr, "\n");
																   	strcat(tempstr, temp); strcat(tempstr, " = ");
																   	strcat(tempstr, "t"); sprintf(buf, "%d", tp-1);
																   	strcat(tempstr, buf);
																   	$$ = createStr(tempstr);
																		 strcpy(tempstr, "");
													   	   }
	  	;
FunctionDefinition : FunctionName OB CB SEMICOLON { strcpy(tempstr, tempFunc); strcat(tempstr, " ()"); $$ = createStr(tempstr);
																	 strcpy(tempstr, "");}
		   | FunctionName OB ParamsType CB SEMICOLON { strcpy(tempstr, tempFunc); strcat(tempstr, " (");
		   strcat(tempstr, tempparams); strcat(tempstr, ")"); strcpy(tempparams, ""); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
		   ;
FunctionName : Type Identifier {strcat(temptype, " "); strcat(temptype, temp); strcpy(tempFunc, temptype);}
		;
ParamsType : ParamsType COMMA Type	{strcat(tempparams, temptype); strcat(tempparams, " ");}
	   | Type			{strcat(tempparams, temptype); strcat(tempparams, " ");}
	   ;
ClosureFunctionDefinition : CLOSURE COLON FunctionDefinition {strcpy(tempstr, "closure : "); strcat(tempstr, $3->code); 
										$$ = createStr(tempstr);
										strcpy(tempstr, "");}
			  ;
Stmt : Extra SEMICOLON Stmt	{strcpy(tempstr, $1->code); strcat(tempstr, "\n"); strcat(tempstr, $3->code); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
     | Declaration Stmt		{strcpy(tempstr, $1->code); strcat(tempstr, "\n"); strcat(tempstr, $2->code); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
     | AssignExpr Stmt		{strcpy(tempstr, $1->code); strcat(tempstr, "\n"); strcat(tempstr, $2->code); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
     | SelectionStmt Stmt	{strcpy(tempstr, $1->code); strcat(tempstr, "\n"); strcat(tempstr, $2->code);$$ = createStr(tempstr);
																 strcpy(tempstr, "");}
     | JumpStmt	Stmt		{strcpy(tempstr, $1->code); strcat(tempstr, "\n"); strcat(tempstr, $2->code);$$ = createStr(tempstr);
																 strcpy(tempstr, "");}
     | FunctionCall Stmt	{strcpy(tempstr, $1->code); strcat(tempstr, "\n"); strcat(tempstr, $2->code);$$ = createStr(tempstr);
																 strcpy(tempstr, "");}
     | CompoundStmt Stmt	{strcpy(tempstr, $1->code); strcat(tempstr, "\n"); strcat(tempstr, $2->code);$$ = createStr(tempstr);
																 strcpy(tempstr, "");}
     | error SEMICOLON	{yyerrok; yyclearin; printf("missing ';'\n");}
     |	{strcpy(tempstr, ""); $$ = createStr(tempstr);}
     ;
Function : FunctionName OB CB CompoundStmt Function {	generateLabel();
																		strcpy(tempstr, templabel); strcat(tempstr, $4->code);
																		strcat(tempstr, "\n"); strcat(tempstr, $5->code);$$ = createStr(tempstr);
																		 strcpy(tempstr, "");
																	 }
	 | FunctionName OB FunctionParams CB SO Stmt ClosureFunction Stmt SC Function 
	   {	generateLabel();
	   	strcpy(tempstr, templabel);  strcat(tempstr, "\n"); strcat(tempstr, $6->code);
			strcat(tempstr, "\n"); 
			generateLabel();
			strcat(tempstr, templabel);
			strcat(tempstr, $7->code); strcat(tempstr, "\n");
			strcat(tempstr, $8->code); strcat(tempstr, "\n"); strcat(tempstr, $10->code);$$ = createStr(tempstr);
			 strcpy(tempstr, "");
		}
	 | FunctionName OB CB SO Stmt ClosureFunction Stmt SC Function 
	   {	generateLabel();
	   	strcpy(tempstr, templabel); strcat(tempstr, $5->code);
			strcat(tempstr, "\n"); 
			generateLabel();
			strcat(tempstr, templabel);
			strcat(tempstr, $6->code); strcat(tempstr, "\n");
			strcat(tempstr, $7->code); strcat(tempstr, "\n"); strcat(tempstr, $9->code);$$ = createStr(tempstr);
			strcpy(tempstr, "");
		}
	 | FunctionName OB FunctionParams CB CompoundStmt Function 
	   {	generateLabel();
	   	strcpy(tempstr, templabel);  strcat(tempstr, "\n"); strcat(tempstr, $5->code);
			strcat(tempstr, "\n");
			strcat(tempstr, $6->code);$$ = createStr(tempstr);
			strcpy(tempstr, "");
		}
	 |		{strcpy(tempstr, ""); $$ = createStr(tempstr);}
	 ;
ClosureFunction : CLOSURE COLON FunctionName OB CB SO Stmt SC 
		 {generateLabel();
		 strcpy(tempstr, templabel); strcat(tempstr, $7->code); $$ = createStr(tempstr);
			 strcpy(tempstr, "");}
	        | CLOSURE COLON FunctionName OB FunctionParams CB SO Stmt SC 
	        {generateLabel();
	        strcpy(tempstr, templabel);  strcat(tempstr, "\n"); strcat(tempstr, $8->code);
	        $$ = createStr(tempstr);
				 strcpy(tempstr, "");}
	        ;
FunctionParams : FunctionParams COMMA Type Identifier 	{strcat(tempparams, temptype); strcat(tempparams, " ");
							 strcat(tempparams, temp); strcat(tempparams, "\n"); }
	       | Type Identifier			{strcat(tempparams, temptype); strcat(tempparams, " ");
							 strcat(tempparams, temp); }
	       ;
Declaration : Type VarList SEMICOLON {strcat(tempstr, $2->code); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
	    | Type AssignExpr	     {strcat(tempstr, $2->code); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
	    ;
FunctionCall : Identifier EQUAL Call OB VarList CB SEMICOLON
		{strcpy(tempstr, "param "); strcat(tempstr,$5->code); strcat(tempstr, "\n"); 
		strcat(tempstr, "call("); strcat(tempstr, namecall); strcat(tempstr, ")");
		$$ = createStr(tempstr);  strcpy(tempstr, "");}
	     | Call OB VarList CB SEMICOLON
	        {strcpy(tempstr, "param "); strcat(tempstr , $3->code); strcat(tempstr, "\n"); 
	        strcat(tempstr, "call("); strcat(tempstr, namecall); strcat(tempstr, ")");
	        $$ = createStr(tempstr);  strcpy(tempstr, "");}
	     ;
Call : ID {strcpy(namecall, yylval.str);}	   
		;  
AssignExpr : Identifier EQUAL Extra COMMA AssignExpr	{  
																				if(ifnum == 1)
	   																{strcpy(tempstr, temp); strcat(tempstr, " = "); 
	   																 strcat(tempstr, $3->code);}
	   																 else
	   																 {
																   	strcpy(tempstr, $3->code); strcat(tempstr, "\n");
																   	strcat(tempstr, temp); strcat(tempstr, " = ");
																   	strcat(tempstr, "t"); sprintf(buf, "%d", tp-1);
																   	strcat(tempstr, buf); }
																   	$$ = createStr(tempstr);
																		 strcpy(tempstr, "");
																	   }
	   	| Identifier EQUAL Extra SEMICOLON		{  	if(ifnum == 1)
	   																{strcpy(tempstr, temp); strcat(tempstr, " = "); 
	   																 strcat(tempstr, $3->code);}
	   																 else
	   																 {
																   	strcpy(tempstr, $3->code); strcat(tempstr, "\n");
																   	strcat(tempstr, temp); strcat(tempstr, " = ");
																   	strcat(tempstr, "t"); sprintf(buf, "%d", tp-1);
																   	strcat(tempstr, buf); }
																   	$$ = createStr(tempstr);
																		 strcpy(tempstr, "");
													   	   }
	  	;
SelectionStmt : IF OB cond CB CompoundStmt	{strcpy(tempstr, "if "); strcat(tempstr, $3->code); 
																generateLabel(); strcpy(temptemp1, templabel);
															 strcat(tempstr, " goto "); strcat(tempstr, temptemp1); strcat(tempstr, "\n");
															 strcat(tempstr, temptemp1); strcat(tempstr, $5->code);
															 $$ = createStr(tempstr);
																 strcpy(tempstr, "");
															}
	      | IF OB cond CB CompoundStmt ELSE CompoundStmt
	      {strcpy(tempstr, "ifFalse "); strcat(tempstr, $3->code); 
	       generateLabel(); strcpy(temptemp1, templabel); 
			 strcat(tempstr, " goto "); strcat(tempstr, temptemp1); strcat(tempstr, "\n");
			 strcat(tempstr, $5->code); strcat(tempstr, "\n");
			 strcat(tempstr, temptemp1); strcat(tempstr, $7->code); $$ = createStr(tempstr);
																 strcpy(tempstr, "");
			}
	      ;
JumpStmt : CONT SEMICOLON	{strcpy(tempstr, "continue"); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
	 | BRK SEMICOLON 	{strcpy(tempstr, "break"); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
	 | RTRN Extra SEMICOLON	{  if(ifnum == 1)
	 									{
	 										strcpy(tempstr, "return ");
	 										strcat(tempstr, $2->code);
	 									}
	 									else
	 									{
									   	strcpy(tempstr, $2->code); strcat(tempstr, "\n");
									   	strcat(tempstr, "return ");
									   	strcat(tempstr, "t"); sprintf(buf, "%d", tp-1);
									   	strcat(tempstr, buf);  }
									   	$$ = createStr(tempstr);
																 strcpy(tempstr, "");
						   	   }
	 ;
cond : Expr	{strcpy(tempstr, $1->code); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}	
     | Expr logOp E	{  if(ifnum == 1)
     							{strcpy(tempstr, $1->code); strcat(tempstr, " ");
     							strcat(tempstr, templog); strcat(tempstr, " "); strcat(tempstr, $3->code);}
     							else
     							{
								   	strcpy(tempstr, $1->code); strcat(tempstr, "\n");
								   	strcat(temptemp1, "t"); sprintf(buf, "%d", tp-1);
								   	strcat(temptemp1, buf); 
								   	strcat(tempstr, $3->code); strcat(tempstr, "\n");
								   	strcat(temptemp2, "t"); sprintf(buf, "%d", tp-1);
								   	strcat(temptemp2, buf); 
								   	strcat(tempstr, temptemp1); strcat(tempstr, templog); strcat(tempstr, temptemp2);}
								   	$$ = createStr(tempstr);
																 strcpy(tempstr, "");
					   	   }
     ;
Expr : relExp {strcpy(tempstr, $1->code); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
     | logExp {strcpy(tempstr, $1->code); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
     ;
relExp : Extra relOp E {  if(ifnum == 1)
     							{strcpy(tempstr, $1->code); strcat(tempstr, " ");
     							strcat(tempstr, temprel); strcat(tempstr, " "); strcat(tempstr, $3->code);}
     							else
     							{
								   	strcpy(tempstr, $1->code); strcat(tempstr, "\n");
								   	strcat(temptemp1, "t"); sprintf(buf, "%d", tp-1);
								   	strcat(temptemp1, buf); 
								   	strcat(tempstr, $3->code); strcat(tempstr, "\n");
								   	strcat(temptemp2, "t"); sprintf(buf, "%d", tp-1);
								   	strcat(temptemp2, buf); 
								   	strcat(tempstr, temptemp1); strcat(tempstr, temprel); strcat(tempstr, temptemp2);}
								   	$$ = createStr(tempstr);
																 strcpy(tempstr, "");
					   	   }	
       ;
logExp : Extra logOp E  {  if(ifnum == 1)
     							{strcpy(tempstr, $1->code); strcat(tempstr, " ");
     							strcat(tempstr, templog); strcat(tempstr, " "); strcat(tempstr, $3->code);}
     							else
     							{
										strcpy(tempstr, $1->code); strcat(tempstr, "\n");
								   	strcat(temptemp1, "t"); sprintf(buf, "%d", tp-1);
								   	strcat(temptemp1, buf); 
								   	strcat(tempstr, $3->code); strcat(tempstr, "\n");
								   	strcat(temptemp2, "t"); sprintf(buf, "%d", tp-1);
								   	strcat(temptemp2, buf); 
								   	strcat(tempstr, temptemp1); strcat(tempstr, templog); strcat(tempstr, temptemp2);}
								   	$$ = createStr(tempstr);
																 strcpy(tempstr, "");
					   	   }
       ;
Extra : E {strcpy(tempstr, $1->code); $$ = createStr(tempstr);
																strcpy(tempstr, "");}
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
VarList : VarList COMMA Call { strcpy(tempstr, $1->code); strcat(tempstr,", "); printf("varlist - %s\n", $1->code);
													strcat(tempstr, namecall);
												$$ = createStr(tempstr);strcpy(tempstr, "");
												strcpy(tempstr, "");
												}
	| Identifier	{ strcat(tempstr, temp); $$ = createStr(tempstr);
																 strcpy(tempstr, "");}
	;
E : E ADD T	{	if(alldigits($1->code) && alldigits($3->code))
					{
						int sum = atoi($1->code) + atoi($3->code);
						sprintf(buf, "%d", sum); strcpy(tempstr, buf);
					}
					else
					{
						generateTemp(); ifnum = 0;
						strcpy(tempstr, tempT); strcat(tempstr, " = "); strcat(tempstr, $1->code); 
  						strcat(tempstr, " + "); strcat(tempstr, $3->code);
  					}
  					$$ = createStr(tempstr);
					strcpy(tempstr, "");}			
  | E SUB T	{	if(alldigits($1->code) && alldigits($3->code))
					{
						int sum = atoi($1->code) - atoi($3->code);
						sprintf(buf, "%d", sum); strcpy(tempstr, buf);
					}
					else
					{
						generateTemp(); ifnum = 0;
						strcpy(tempstr, tempT); strcat(tempstr, " = "); strcat(tempstr, $1->code); 
  						strcat(tempstr, " - "); strcat(tempstr, $3->code);
  					}
  					$$ = createStr(tempstr);
					strcpy(tempstr, "");}	
  | T			{strcpy(tempstr, $1->code);$$ = createStr(tempstr);
																 strcpy(tempstr, "");}
  ;
T : T MUL F	{	if(alldigits($1->code) && alldigits($3->code))
					{
						int sum = atoi($1->code) * atoi($3->code);
						sprintf(buf, "%d", sum); strcpy(tempstr, buf);
					}
					else
					{
						generateTemp(); ifnum = 0;
						strcpy(tempstr, tempT); strcat(tempstr, " = "); strcat(tempstr, $1->code); 
  						strcat(tempstr, " * "); strcat(tempstr, $3->code);
  					}
  					$$ = createStr(tempstr);
					strcpy(tempstr, "");}			
  | T DIV F	{	if(alldigits($1->code) && alldigits($3->code))
					{
						int sum = atoi($1->code) / atoi($3->code);
						sprintf(buf, "%d", sum); strcpy(tempstr, buf);
					}
					else
					{
						generateTemp(); ifnum = 0;
						strcpy(tempstr, tempT); strcat(tempstr, " = "); strcat(tempstr, $1->code); 
  						strcat(tempstr, " / "); strcat(tempstr, $3->code);
  					}
  					$$ = createStr(tempstr);
					strcpy(tempstr, "");}		
  | F			{	if(ifnum == 1){ifnum = 1; strcpy(tempstr, $1->code);}
  					else{ifnum = 0; generateTemp();
  					strcpy(tempstr, tempT); strcat(tempstr, " = "); strcat(tempstr, $1->code);}$$ = createStr(tempstr);
																 strcpy(tempstr, "");}
  ;
F : ID 			{ifnum = 1; int ind = search_symbol_table($1);
						if(ind == -1)
						{strcpy(tempstr, $1);}
						else
						{sprintf(buf, "%d", vals[ind]); strcpy(tempstr, buf);}
						$$ = createStr(tempstr);
						strcpy(tempstr, "");}		
  | NUM			{ifnum = 1; sprintf(buf, "%d", $1); strcpy(tempstr, buf);$$ = createStr(tempstr);
						strcpy(tempstr, "");}
  | OB E CB		{strcpy(tempstr, $2->code);$$ = createStr(tempstr);
						strcpy(tempstr, "");}
  ;

%%

void yyerror(const char *msg)
{
	fprintf(stderr, "WARNING : line %d : %s\n", yylineno, msg);
}

void generateLabel()
{
	strcpy(templabel, "L");
	char buffer[10];
	sprintf(buffer, "%d", label);
	strcat(templabel, buffer);
	strcat(templabel, ": ");
	label++;
}

void generateTemp()
{
	strcpy(tempT, "t");
	char buffer[10];
	sprintf(buffer, "%d", tp);
	strcat(tempT, buffer);
	strcat(tempT, " ");
	tp++;
}

char * createStr(char * l)
{
	struct attr *curr = (struct attr *)(malloc(sizeof(struct attr)));
	if(l != NULL)
		strcpy(curr -> code, l);
	else
		strcpy(curr -> code, "");
	return curr;
}

void tokenize(char *line)
{
	int i = 0;
	int k1 = 0; int k2 = 0;
	char tempvarsym[20];
	char tempvalsym[20];
	while(line[i] != ',')
	{
		tempvarsym[k1] = line[i];
		k1 += 1;
		i += 1;
	}
	tempvarsym[k1] = '\0';
	i += 1;
	while(line[i] != '\n')
	{
		tempvalsym[k2] = line[i];
		k2 += 1;
		i += 1;
	}
	tempvalsym[k2] = '\0';
	strcpy(vars[intsym], tempvarsym);
	vals[intsym] = atoi(tempvalsym);
	intsym++;
}

int search_symbol_table(char *var)
{
	for(int j = 0; j < intsym; ++j)
	{
		if(strcmp(var, vars[j]) == 0)
			return j;
	}
	return -1;
}

int alldigits(char *var)
{
	int i = 0;
	while(var[i] != NULL)
	{
		if(!(var[i] == '0' || var[i] == '1' || var[i] == '2' || var[i] == '3' || var[i] == '4' || var[i] == '5' || var[i] == '6' || var[i] == '7' || var[i] == '8' || var[i] == '9'))
		{
			return 0;
		}
		i += 1;
	}
	return 1;		
}

int main()
{
	FILE *fptr;
	fptr = fopen("symbolTable.txt", "r");
	char *line = NULL;
	size_t len = 0;
	ssize_t read;
	while((read = getline(&line, &len, fptr)) != EOF)
	{
		tokenize(line);
	}
	fclose(fptr);
	if(line){free(line);}
	yyin = fopen("out.c", "r");
	if(!yyparse())
		;
	else
		printf("Invalid");
	fclose(yyin);
	return 0;
}


