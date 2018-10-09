%{
	#include<stdio.h>
	#include<stdlib.h>
	#include<string.h>

	FILE *yyin;
	extern int yylineno;
	char vars[20][10];
	int vals[20];
	
	struct symtab
	{
		char identifier[20];
		char type[20];
		char attribute[20];
		int  val;
		char pars[100];
		char scope[20];
		int  spec;
		
	};
	struct symtab sym[20];
	struct funtab
	{
	
		char identifier[20];
		char type[20];
		char attribute[20];
		int  val;
		char pars[100];
		char scope[20];
		int spec;
	};
	struct funtab fun[20];
	char temp[20];
	char functemp[20];
	char tempname[20][20];
	char func[20];
	char closetype[20];
	char nonlocal[20];
	char temptype[20];
	char tempparams[100];
	char attr[20]="closure";
	char funcalled[20][20];
	int i=0,j=0,l,m;
	int count1=0;
	int called = 0;
	int ifnum = 0;
	double tempval;
	double extraval;
	int count = 0;
	int close = 0;
	void id_insert(int x);
	void display();
	void yyerror(const char*);
	int yylex();
%}

%union 
{
	char *str;
	double num;
};

%token INT MAIN OB CB SO SC CLOSURE COLON HASH INCLUDE LIBRARY
%token IF ELSE WHILE FOR CONT BRK RTRN SEMICOLON BINARYOR BINARYAND LT
%token GT LTE GTE NE EQ VOID CHAR COMMA EQUAL SUBPREFIX 
%token ADD SUB MUL DIV ADDRIGHT SUBRIGHT MULRIGHT DIVRIGHT ADDPREFIX
%token<str> ID
%token<num> NUM 
%type<num> E T F

%%
PreProcessorDirectives : {strcpy(func, "global");} HASH INCLUDE LIBRARY Global	
							{printf("\n______________________________________________________\n"); 
							printf("\nProgram SUCCESSFULLY Validated!!!\n\n"); display(); 
							printf("\n______________________________________________________\n\n");
							funtable();fundisplay();							
							}
						       
				;
Main : INT MAIN {strcpy(func, "main");} OB CB CompoundStmt Function '~' 
     ;
Identifier : ID {strcpy(temp,yylval.str);}
	   ;
CompoundStmt : SO Stmt SC 
	     ;
Global : FunctionDefinition Global	
       | ClosureFunctionDefinition Global
       | GlobeDeclaration Global		
       | Main				
       ;
GlobeDeclaration : Type VarList SEMICOLON	
	    	 | Type GlobeAssignExpr			
	         ;
GlobeAssignExpr : Identifier EQUAL E COMMA GlobeAssignExpr	
	   	| Identifier EQUAL E SEMICOLON	
	  	;
FunctionDefinition : FunctionName OB CB SEMICOLON 
		   | FunctionName OB ParamsType CB SEMICOLON
		   {	 if(sym[i].spec==0)
			 {id_insert(4);} 
			 else
			 {id_insert(5);}
			 strcpy(tempparams, "");
		   }
		   ;
FunctionName : Type Identifier {if(strcmp(func, "global") != 0 && close != 1)
			{strcpy(nonlocal, func); strcpy(func, temp);}
			else if(close==1)
			{strcpy(functemp,temp);} 
		}
		;
ParamsType : ParamsType COMMA Type	{strcat(tempparams, temptype); strcat(tempparams, " ");}
	   | Type			{strcat(tempparams, temptype); strcat(tempparams, " ");}
	   ;
ClosureFunctionDefinition : {sym[i].spec=1;} CLOSURE COLON FunctionDefinition 
			  ;
Stmt : Extra SEMICOLON Stmt
     | Declaration Stmt
     | AssignExpr Stmt
     | SelectionStmt Stmt
     | JumpStmt	Stmt
     | FunctionCall Stmt	
     | CompoundStmt Stmt
     | error SEMICOLON	{yyerrok; yyclearin; printf("missing ';'\n");}
     |
     ;
Function : FunctionName OB CB CompoundStmt Function {close=1;}
	 | FunctionName OB FunctionParams CB SO Stmt ClosureFunction Stmt SC Function {close=0;}
	 | FunctionName OB CB SO Stmt ClosureFunction Stmt SC Function {close=0;}
	 | FunctionName OB FunctionParams CB CompoundStmt Function{close=1;} 
	 |
	 ;
ClosureFunction : CLOSURE COLON FunctionName OB CB SO Stmt SC 
	        |  CLOSURE COLON FunctionName OB FunctionParams CB SO Stmt SC 
	        ;
FunctionParams : FunctionParams COMMA Type Identifier 	{id_insert(3);}
	       | Type Identifier			{id_insert(3);}
	       ;
Declaration : Type VarList SEMICOLON 
	    | Type AssignExpr	
	    ;
FunctionCall : Identifier EQUAL Identifier{strcpy(tempname[j++],yylval.str);called=1;} OB VarList CB SEMICOLON
	     | Identifier{strcpy(tempname[j++],yylval.str);called=1;} OB VarList CB SEMICOLON
	     ;
AssignExpr : Identifier EQUAL Extra COMMA {	 
					     	tempval = extraval; ifnum = 1;
						if(search_symbol_table(temp) == -1)
						{
							if(strcmp(temptype, "int")==0)
							{ id_insert(1); }
							else
							   printf("WARNING : line : %d : Invalid Type Error\n", yylineno);
						}
						else
						{
								id_insert(6);
						}
					  }AssignExpr
	   | Identifier EQUAL Extra SEMICOLON 	   {	 
						     	tempval = extraval; ifnum = 1;
							if(search_symbol_table(temp) == -1)
							{
								if(strcmp(temptype, "int")==0)
								{ id_insert(1); }
								else
								   printf("WARNING : line : %d : Invalid Type Error\n", yylineno);
							}
							else
							{
									id_insert(6);
							}
					 	   }
	   ;
SelectionStmt : IF OB cond CB CompoundStmt
	      | IF OB cond CB CompoundStmt ELSE CompoundStmt
	      ;
JumpStmt : CONT SEMICOLON	
	 | BRK SEMICOLON 	
	 | RTRN E SEMICOLON{called=0;}	
	 ;
cond : Expr		
     | Expr logOp Expr	
     ;
Expr : relExp 
     | logExp      
     ;
relExp : Extra relOp Extra	
       ;
logExp : Extra logOp Extra	
       ;
Extra : E {extraval = $1;}
      ;
logOp : BINARYOR	
      | BINARYAND	
      ;
relOp : LT	
      | GT	
      | LTE	
      | GTE	
      | NE	
      | EQ	
      ;
Type : INT 	{strcpy(temptype,"int");}
     | VOID	{strcpy(temptype,"void");}
     | CHAR 	{strcpy(temptype,"char");}
     ;
VarList : VarList COMMA Identifier { ifnum = 0;
			  if (strcmp(temptype,"char")==0)
			  {
				strcpy(temp,yylval.str);id_insert(0);
			  }
			  else if(strcmp(temptype,"int")==0)
			  {
				strcpy(temp,yylval.str);id_insert(1);			
			  }			
			  else if(strcmp(temptype,"void")==0)
			  {
				strcpy(temp,yylval.str);id_insert(2);			
			  }
			}
	| Identifier	{ ifnum = 0;
			  if (strcmp(temptype,"char")==0)
			  {
				strcpy(temp,yylval.str);id_insert(0);
			  }
			  else if(strcmp(temptype,"int")==0)
			  {
				strcpy(temp,yylval.str);id_insert(1);			
			  }			
			  else if(strcmp(temptype,"void")==0)
			  {
				strcpy(temp,yylval.str);id_insert(2);			
			  }
			}
	;
E : E ADD T	{$$ = $1 + $3;}		
  | E SUB T	{$$ = $1 - $3;}
  | T		
  ;
T : T MUL F	{$$ = $1 * $3;}		
  | T DIV F	{$$ = $1 / $3;}		
  | F			
  ;
F : ID 			{int x = search_symbol_table(yylval.str); $$ = sym[x].val;}		
  | NUM			{$$ = $1;}
  | OB E CB		{$$ = $2;}
  ;

%%

void yyerror(const char *msg)
{
	fprintf(stderr, "WARNING : line %d : %s\n", yylineno, msg);
}

void id_insert(int x)
{	
	if (x==0)
	{
		strcpy(sym[i].type,"char");
		strcpy(sym[i].identifier,temp);
		sym[i].val=0;
		sym[i].spec=0;
		strcpy(sym[i].attribute,"variable");
		i++;
		count++;				
	}
	else if(x==1)
	{
		if(close==2)
		{
			strcpy(sym[i].type,"int");
			strcpy(sym[i].identifier,temp);
			sym[i].spec=0;
			if(ifnum == 1)
				sym[i].val = tempval;
			strcpy(sym[i].attribute,"variable");
			i++;
			count++;
		}
		else
		{
			strcpy(sym[i].type,"int");
			strcpy(sym[i].identifier,temp);
			sym[i].spec=0;
			if(ifnum == 1)
				sym[i].val = tempval;
			strcpy(sym[i].scope, func);
			strcpy(sym[i].attribute,"variable");
			i++;
			count++;
		}
	}
	else if(x==2)
	{
		strcpy(sym[i].type,"void");
		strcpy(sym[i].identifier,temp);
		sym[i].spec=0;
		strcpy(sym[i].scope, func);
		strcpy(sym[i].attribute,"variable");
		i++;
		count++;
	}
	else if(x==3)
	{
		strcpy(sym[i].type,temptype);
		strcpy(sym[i].identifier,temp);
		sym[i].val=0;
		sym[i].spec=0;
		strcpy(sym[i].scope, func);
		strcpy(sym[i].attribute,"param");
		i++;
		count++;
	}

	else if(x==4)
	{
		strcpy(sym[i].type,temptype);
		strcpy(sym[i].identifier,temp);
		strcpy(sym[i].attribute,"function");
		strcpy(sym[i].pars, tempparams);
		sym[i].val=0;		
		i++;
		count++;
	}
	else if(x==5)
	{
		strcpy(sym[i].type,temptype);
		strcpy(sym[i].identifier,temp);
		strcpy(sym[i].attribute,"closure");
		strcpy(sym[i].pars, tempparams);
		strcpy(sym[i].scope, func);
		//sym[i].spec = 0;
		sym[i].val=0;
		i++;
		count++;
	}
	else if(x == 6)
	{
		int j = search_symbol_table(temp);
		if(ifnum == 1)
		sym[j].val = tempval;
	}
}

void display()
{
	printf("Symbol Table:\n");
	int j=0;
	for(j=0;j<count;j++)
	{
		if(strcmp(sym[j].attribute, "function") == 0 || strcmp(sym[j].attribute, "closure") == 0)
			printf("\n%s	%s	%s   \t	%s  \t	%s	%d",sym[j].type,sym[j].identifier,sym[j].attribute, sym[j].pars, sym[j].scope,sym[j].spec);
		else
			printf("\n%s	%s	%s   \t	%d  \t	%s	%d",sym[j].type,sym[j].identifier,sym[j].attribute, sym[j].val, sym[j].scope,sym[j].spec);		
	}
	printf("\n");
}
int funtable()
{  int closure = 0; 
	
	
	
	for(l=0;l < j;l++)
	{	
		for(m=0;m < count;m++)
		{	//printf("%s	%s\n",tempname[l],sym[m].scope);
			
			if(strcmp(sym[m].attribute, "function")  == 0 )
			{
				
			}
			else if( sym[m].spec==1 && closure == 0)
			{	
				strcpy(closetype,sym[m].identifier);
								
			}
	
			else if(strcmp(sym[m].scope, tempname[l]) == 0 && sym[m].spec != 1 )
			{	//printf("%s	\n",tempname[l]);
				strcpy(fun[count1].type,sym[m].type);
				strcpy(fun[count1].identifier,sym[m].identifier);
				fun[count1].val=sym[m].val;
				fun[count1].spec=sym[m].spec;
				strcpy(fun[count1].attribute,sym[m].attribute);
				strcpy(fun[count1].scope,sym[m].scope);	
				count1++;
			}
			
			else if(strcmp(closetype,sym[m].scope)==0 && closure == 0 )
			{
				
				strcpy(fun[count1].type,sym[m].type);
				strcpy(fun[count1].identifier,sym[m].identifier);
				fun[count1].val=sym[m].val;
				fun[count1].spec=sym[m].spec;
				strcpy(fun[count1].attribute,sym[m].attribute);
				strcpy(fun[count1].scope,tempname[l]);	
				count1++;
								
			}
		
		}
		closure = 1;
	}
}
void fundisplay()
{	
int k;
for(k=0;k<j;k++)
{
 	printf("\n%s table",tempname[k]);    
	for(l=0;l<count1;l++)
	{ 
		if(strcmp(fun[l].scope,tempname[k])==0)
		{
		printf("\n%s	%s	%s   \t	%d  \t	%s",fun[l].type,fun[l].identifier,fun[l].attribute,fun[l].val,fun[l].scope);
		}		
	}
}
printf("\n");
}

			
			

int search_symbol_table(char *var)
{
	for(int j = 0; j < 20; ++j)
	{
		if(strcmp(var, sym[j].identifier) == 0)
			return j;
	}
	return -1;
}

int main()
{
	yyin = fopen("out.c", "r");
	if(!yyparse())
		;
	else
		printf("Invalid");
	fclose(yyin);
	FILE *fptr;
	fptr = fopen("symbolTable.txt", "w");
	for(int j = 0; j < count; ++j)
		if(strcmp(sym[j].attribute, "variable") == 0)
		fprintf(fptr, "%s,%d\n", sym[j].identifier, sym[j].val);
	return 0;
}


