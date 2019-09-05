%{
#include <bits/stdc++.h>
#include "symbol.h"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
using namespace std;
int linecount = 0;
int cnt =0;

vector<funcNameTable> functionTable;
int activeFunc = 0;
int level;


vector<symTab>symbolTable;
vector<int>freet(8,0);
vector<string>quadruple;
int nextquad=0;

void yyerror(char *s)
{
    fprintf(stderr,"Invalid Syntax\n");
    exit(1);
}
int yywrap(){return 1;}
%}
%{
    int yylex();
%}



%union{
    char idName[100];
    struct Node *n;
    int val;
    float data;
}

%{
    int insert_symtab(char *id_name);
    void patch_type2(int type, vector<int>v);
    int getfreet();
    void freeit(int i);

    int search_func(string name);
    int enter_func(int type , string name);
    int search_param(string name);
    void enter_param(string name,int type);
    int search_var(string name,int flag);
    int enter_var(string name,int flag,vector<int> dim);
    void patch_type1(int type , vector<int> list);
    int get_var_type(string name);
    int get_param_type(string name);
    int get_ele_type(string name);
    int get_dim(string name);
    int get_level(string name);
    /*void call_func(struct node n,char *a1);
    void cross_product(char *a1,char *a2);
    void project(struct node n,char *a1);
    void equi_join(char *a1,struct node n,char *a2);
    char *concatenate(char *a1,char *a2,char temp1[1000]);*/
%}

/*%type <arr> ID
%type <n> NUM
%type <n> A
%type <n> STRING
%type <n> C
%type <n> B
%type <n> cond2
%type <n> cond1
%type <n> cond
%type <n> opt
%type <n> attr_list*/
%type<data>DECIMAL;
%type <n> T;
%type <n> L;
%type <idName> ID;
%type <n> E;
%type <n> E2;
%type <n> E22;
%type <n> M_E0;
%type <n> M_E1;
%type <n> F;
%type <n> F3;
%type <n> T2;
%type <n> E_MAIN;
%type <n> OPT;
%type <n> LHS;
%type <n> WHILEXEP;
%type <n> M_WHILE;
%type <n> M_STMT;
%type <n> M_FOR1;
%type <n> M_FOR2;
%type <n> STMT_LIST;
%type <n> STMT;
%type <n> FOREXP;
%type <n> IFEXP;
%type <n> ASG;
%type <val> NUM;
%type <n> M;
%type <n> N;
%type <n> FUNC_DECL;
%type <n> CALL_PARAM;

%type <n> constant_expr;
%type <n> cases;
%type <n> default;
%type <n> case;
%type <n> case_end;
%type <n> case_exp;

%type <n> RESULT;
%type <n> List;
%type <n> DIMList;
%type <n> ID_ARR;

%token MUL
%token PROJECT
%token CARTESIAN_PRODUCT
%token EQUI_JOIN
%token AND
%token OR
%token NOT
%token LP
%token RP
%token LE
%token GE
%token LT
%token GT
%token EQ
%token SEMI
%token NUM
%token QUO
%token ID
%token DOT
%token STRING
%token COMMA
%token STAR
%token MINUS
%token PLUS
%token DIV
%token INT
%token FLOAT
%token WHILE
%token LC
%token RC
%token FOR
%token EE
%token DECIMAL
%token DIVIDE

%token IF
%token ELSE
%token RETURN
%token LB
%token RB

%token SWITCH
%token BREAK
%token COLON
%token CASE
%token DEFAULT

%%


START : STMT_LIST
{
    for(int i=0;i<$1->nextlist.size();i++)
    {
   	 //quadruple[$1->nextlist[i]] += to_string(nextquad);
   	 quadruple[$1->nextlist[i]] += to_string(nextquad-1);
    }
};

STMT : FUNC_DECL
{
    /*for(int i=0;i<$1->nextlist.size();i++)
    {
   	 quadruple[$1->nextlist[i]] += to_string(nextquad);
    }*/
    $$ = new Node;
    $$->nextlist = $1->nextlist;
    level = 0;
    activeFunc = 0;
};

STMT : RETURN F SEMI
{
    
    $$ = new Node;
    string str = quadruple[quadruple.size()-1];
    //cout<<"fvb"<<str<<"fjds";
    string temp="";
    string reg="";
    for(int i=str.size()-1;i>=0;i--)
    {
   	 if(str[i]==' ')
   		 break;
   	 temp = str[i]+temp;
    }
    for(int i=0;i<str.size();i++)
    {
   	 if(str[i]==' ')
   		 break;
   	 reg = reg + str[i];
    }
    /*temp = "return " + temp;
    quadruple.push_back(temp);
    nextquad++;*/
    char arr[100];
    int parSize = functionTable[activeFunc].parList.size()+1;
    sprintf(arr,"#%d = %s",parSize,reg.c_str());
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;
    char arr22[100];
    
    sprintf(arr22,"goto 1%s_end",functionTable[activeFunc].name.c_str());
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr22;
    nextquad++;
};
FUNC_DECL : FUNC_HEAD LC STMT_LIST RC
{
    quadruple.push_back("func end");
    nextquad++;
    $$ = new Node;
    $$->nextlist = $3->nextlist;
};
FUNC_HEAD : RES_ID LP DECL_PLIST RP
{
    level = 2;
};
RES_ID : T ID
{
    int found = search_func($2);
    if(found)
   	 printf("Line %d : Function %s() already declared\n",lineno,$2);
    else
    {
   	 int index = enter_func($1->type,$2);
   	 activeFunc = index;
   	 //cout<<activeFunc<<" ";
   	 level = 1;
   	 char temp[100];
   	 sprintf(temp , "func begin %s",$2);
   	 quadruple.push_back(temp);
   	 nextquad++;
    }    
};
/*RESULT : INT
{
    $$ = new Node;
    $$->type = 0;
};
RESULT : FLOAT
{
    $$ = new Node;
    $$->type = 1;
};*/

DECL_PLIST : DECL_PL  ;
DECL_PLIST : ;
DECL_PL : DECL_PL COMMA DECL_PARAM ;
DECL_PL : DECL_PARAM;
DECL_PARAM : T ID
{
    int found = search_param($2);
    if(found)
   	 printf("Line %d : Parameter %s already Declared\n",lineno,$2);
    else{
   	 enter_param($2,$1->type);
    }    
};
STMT_LIST : STMT_LIST M_STMT STMT
{
    $$ = new Node;

    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());

    for(int i=0;i<$1->nextlist.size();i++)
    {
   	 char temp[100];
   	 //cout<<$2->quad<<endl;
   	 sprintf(temp,"%d",$2->quad);
    //    printf("==%s===",temp);
   	 quadruple[$1->nextlist[i]] += temp;
    }
    
};
STMT_LIST :  STMT
{
    $$ = new Node;
    $$->nextlist.insert($$->nextlist.end(),$1->nextlist.begin(),$1->nextlist.end());
//    cout<<$$->nextlist.size()<<endl;
};
M_STMT :
{
    $$ = new Node;
    $$->quad = nextquad;
};
STMT : ASG SEMI  
{
    vector<string>list = $1->idlist;
    vector<int> eletypelist = $1->eletypelist;
    int dimSize  = $1->dim.size();
    for(int i=0;i<list.size();i++)
    {
   	 int found = search_var(list[i],1);
   	 if(!found)
   	 {
   		 found = search_param(list[i]);
   		 if(!found)
   			 printf("Line %d : Variable %s Not declared\n",lineno,list[i].c_str());
   		 else
   		 {
   			 int eletype = get_ele_type(list[i]);
   			 if(eletype!=eletypelist[i])
   				 printf("Line %d : %s Element Type Mismatch",lineno,list[i].c_str());
   		 }
   	 }
   	 else
   	 {
   		 int eletype = get_ele_type(list[i]);
   		 if(eletype!=eletypelist[i])
   			 printf("Line %d : %s Element Type Mismatch",lineno,list[i].c_str());
   		 int d = get_dim(list[i]);
   		 if(d!=dimSize)
   			 printf("Line %d : %s Dimension Mismmatch\n",lineno,list[i].c_str() );
   	 }

    }
    /*if($1->sem_type!=-1)
   	 printf("Line %d : Type Mismatch\n",lineno);*/
};
STMT : D SEMI;

STMT : FOREXP LC STMT_LIST RC
{
    $$ = new Node;
    quadruple.resize(nextquad+1);
    char arr[500];
    sprintf(arr,"goto %d",$1->end);
    quadruple[nextquad] = arr;
    nextquad++;    
    /*  backpatch */
    for(int i=0;i<$3->nextlist.size();i++)
    {
   	 char temp[100];
   	 sprintf(temp,"%d",$1->end);
   	 quadruple[$3->nextlist[i]] += temp;
    }

    /* S.next = falselist*/
    $$->nextlist.insert($$->nextlist.end(),$1->falselist.begin(),$1->falselist.end());
    int i=0;
    for(i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 if(functionTable[activeFunc].varList[i].level==level)
   	 {
   		 functionTable[activeFunc].varList.erase(functionTable[activeFunc].varList.begin()+i);
   		 i=0;
   	 }
    }
    level--;
};
FOREXP : FOR LP F1 SEMI M_FOR1 E_MAIN SEMI M_FOR2 F3 RP
{
//    printf("ok\n");
    $$ = new Node;
    quadruple.resize(nextquad+1);
    char arr2[500];
    sprintf(arr2,"goto ");
    $9->nextlist.push_back(nextquad);
    quadruple[nextquad] = arr2;
    nextquad++;
    $$->falselist.push_back(nextquad);
    quadruple.resize(nextquad+1);
    char we = 't';
    if ($6->type==1)
   	 we='f';

    char arr[500];
    sprintf(arr,"if %c%d <=0 goto ",we,$6->reg);
    quadruple[nextquad] = arr;

    for(int i=0;i<$8->nextlist.size();i++)
    {
   	 char temp[100];
   	 sprintf(temp,"%d",nextquad);
   	 quadruple[$8->nextlist[i]] += temp;
    }
    for(int i=0;i<$6->nextlist.size();i++)
    {
   	 char temp[100];
   	 sprintf(temp,"%d",nextquad);
   	 quadruple[$6->nextlist[i]] += temp;
    }

    nextquad++;

    $$->begin = $5->quad;
    $$->end = $8->quad;

    for(int i=0;i<$9->nextlist.size();i++)
    {
   	 char temp[100];
   	 sprintf(temp,"%d",$$->begin);
   	 quadruple[$9->nextlist[i]] += temp;
    }

    level++;
    freeit($6->reg);

};

M_FOR1 :
{
    $$ = new Node;
    $$->quad = nextquad;
};

M_FOR2 :
{
    $$ = new Node;
    quadruple.resize(nextquad+1);
    char arr[500];
    sprintf(arr,"goto ");
    quadruple[nextquad] = arr;
    $$->nextlist.push_back(nextquad);
    nextquad++;
    $$->quad = nextquad;
};

F1 : ASG ;
F3 : ASG {$$ = new Node;};
STMT : WHILEXEP LC STMT_LIST RC
{
    //printf("ok");
    $$ = new Node;
    quadruple.resize(nextquad+1);
    char arr[500];
    sprintf(arr,"goto %d",$1->begin);
    quadruple[nextquad] = arr;
    nextquad++;    
    /*  backpatch */
    for(int i=0;i<$3->nextlist.size();i++)
    {
   	 char temp[100];
   	 sprintf(temp,"%d",$1->begin);
   	 quadruple[$3->nextlist[i]] += temp;
    }

    /* S.next = falselist*/
    $$->nextlist.insert($$->nextlist.end(),$1->falselist.begin(),$1->falselist.end());

    int i=0;
    for(i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 if(functionTable[activeFunc].varList[i].level==level)
   	 {
   		 functionTable[activeFunc].varList.erase(functionTable[activeFunc].varList.begin()+i);
   		 i=0;
   	 }
    }
    level--;
//    cout<<$$->nextlist.size()<<endl;
    
};
/*Decl : DList  ;
DList : D  | DList SEMI D ; */
D : T L {
    //patch_type1($1->type,$2->namelist);
    //patch_type2($1->type,$2->namelist);
    //cout<<"hello";
    vector<string> list = $2->idlist;
    vector<int> eleList  = $2->eletypelist;
    for(int i=0;i<list.size();i++)
    {
   	 int found = search_var(list[i],0);
   	 if(found)
   	 {
   		 printf("Line %d : Variable %s already declared at same level\n",lineno,list[i].c_str());
   	 }
   	 else if(level==2)
   	 {
   		 int found = search_param(list[i]);
   		 if(found)
   			 printf("Line %d : Redeclaration of Parameter %s as Variable\n",lineno,list[i].c_str());
   		 else
   		 {
   			 int index = enter_var(list[i],eleList[i],$2->dim);
   			 functionTable[activeFunc].varList[index].type = $1->type;
   		 }
   	 }
   	 else
   	 {

   		 int index = enter_var(list[i],eleList[i],$2->dim);
   		 functionTable[activeFunc].varList[index].type = $1->type;
   	 }
   	 if(level<0)
   	 {
   		 ;
   	 //    sprintf(arr,"#%d = t%d\n",abs(level),$3->reg);
   	 }
   	 else
   		 {
   			 //cout<<"h"<<$2->nextlist2.size();
   			 //cout<<i<<" "<<$2->nextlist2[i]<<"\n";
   		 if(i < $2->nextlist2.size() && $2->nextlist2[i]!=-1)
   		 {
   			 

   			 //cout<<i<<" "<<$2->nextlist2[i]<<"\n";
   			 char arr[500];
   			 string temp="";
   			 int f=0;
   			 string res = quadruple[$2->nextlist2[i]];
   			 for(int i=0;i < res.size();i++)
   			 {
   				 if(f==1 || res[i]=='=')
   				 {
   					 temp += res[i];
   					 f=1;
   				 }
   			 }
   			 sprintf(arr,"%s_%d %s",list[i].c_str(),level,temp.c_str());
   			 quadruple[$2->nextlist2[i]] = arr;
   			 //cout<<quadruple[$2->nextlist2[i]]<<" ";
   		 }
   			 
   		 }
    }
    vector<pair<string,int> > comp = $1->comp;
    for(int i=0;i<comp.size();i++)
    {
   	 if(get_var_type(comp[i].first)!=comp[i].second)
   		 printf("Line %d : Type Mismatch\n",lineno);
    }

    /*if($2->sem_type!=-1 && $1->type!=$2->sem_type)
    {
   	 printf("ggLine %d : Type Mismatch\n",lineno);
    }*/

};
T : INT  {$$ = new Node;  $$->type = 0;};
T : FLOAT {$$ = new Node;  $$->type = 1;};
///////////////////////////////////////////////////////////////////////////////////////////
L : ASG {
    
    //int i = insert_symtab($1->id);
    //cout<<level<<" ";
    $$ = new Node;
    /*int found = search_var($1->id,0);
    if(found)
   	 printf("Variable %s already declared at same level\n",$1);
    else if(level==2)
    {
   	 found = search_param($1->id);
   	 if(found)
   		 printf("Redeclaration of Parameter %s as Variable\n",$1->id);
   	 else
   		 {int index = enter_var($1->id); $$->namelist.push_back(index);}
    }
    else
   	 {int index = enter_var($1->id);$$->namelist.push_back(index);}
*/
	  $$->idlist = $1->idlist;
	  $$->eletypelist = $1->eletypelist;
	  $$->dim = $1->dim;
	  $$->comp = $1->comp;
	  $$->nextlist2 = $1->nextlist2;

	  //$$->sem_type = $1->sem_type;
	 //$$->namelist.push_back(i);
};
L : L COMMA ASG {
    //int i = insert_symtab($3->id);
    /*$$ = new Node;
    $$->namelist.insert($$->namelist.end(),$1->namelist.begin(),$1->namelist.end());
    $$->namelist.push_back(i);*/

    /*int found = search_var($3->id,0);
    if(found)
    {
   	 printf("Variable %s already declared at same level\n",$1);
   	 $$->namelist = $1->namelist;
    }
    else if(level==2)
    {
   	 found = search_param($3->id);
   	 if(found)
   		 {
   			 printf("Redeclaration of Parameter %s as Variable\n",$3->id);
   			 $$->namelist = $1->namelist;
   		 }
   	 else
   	 {
   		 int index = enter_var($3->id);
   		 $$->namelist = $1->namelist;
   		 $$->namelist.push_back(index);
   	 }

    }
    else
    {
   	 int index = enter_var($3->id);
   	 $$->namelist = $1->namelist;
   	 $$->namelist.push_back(index);
    }*/
    $$ = new Node;
    $$->idlist = $1->idlist;
    $$->idlist.insert($$->idlist.end(),$3->idlist.begin(),$3->idlist.end());
    $$->eletypelist = $1->eletypelist;
    $$->eletypelist.insert($$->eletypelist.end(),$3->eletypelist.begin(),$3->eletypelist.end());

    $$->dim = $1->dim;
    $$->dim.insert($$->dim.end(),$3->dim.begin(),$3->dim.end());

    $$->comp = $1->comp;
    $$->comp.insert($$->comp.end(),$3->comp.begin(),$3->comp.end());
    
    $$->nextlist2 = $1->nextlist2;
    $$->nextlist2.insert($$->nextlist2.end(),$3->nextlist2.begin(),$3->nextlist2.end());
    //$$->sem_type = -1;
};

ID_ARR : ID
{
    $$ = new Node;
    $$->id = $1;
    $$->idlist.push_back($1);
    $$->eletypelist.push_back(0);
    $$->dim.push_back(-2);
    $$->type2 = 4;
};

ID_ARR : ID DIMList
{
    $$ = new Node;
    $$->id = $1;
    $$->idlist.push_back($1);
    $$->eletypelist.push_back(1);
    $$->type2 =5;
    $$->dim = $2->dim;
    $$->iddim = $2->iddim;
};

DIMList  : LB ID RB
{
    $$= new Node;
    $$->dim.push_back(-1);
    $$->iddim.push_back($2);
};
DIMList : LB ID RB DIMList
{
    $$= new Node;
    $$->dim.push_back(-1);
    $$->iddim.push_back($2);
    $$->dim.insert($$->dim.end(),$4->dim.begin(),$4->dim.end());
    $$->iddim.insert($$->iddim.end(),$4->iddim.begin(),$4->iddim.end());
};


DIMList  : LB NUM RB
{
    $$= new Node;
    $$->dim.push_back($2);
    $$->iddim.push_back("");
};
DIMList : LB NUM RB DIMList
{
    $$= new Node;
    $$->dim.push_back($2);
    $$->iddim.push_back("");
    $$->dim.insert($$->dim.end(),$4->dim.begin(),$4->dim.end());
    $$->iddim.insert($$->iddim.end(),$4->iddim.begin(),$4->iddim.end());
};


L : ID_ARR     {
    $$ = new Node;
    /*int i = insert_symtab($1);
    
     $$->namelist.push_back(i);*/
    /*int found = search_var($1,1);
    if(found)
   	 printf("Variable %s already declared at same level\n",$1);
    else if(level==2)
    {
   	 found = search_param($1);
   	 if(found)
   		 printf("Redeclaration of Parameter %s as Variable\n",$1);
   	 else
   		 {int index = enter_var($1); $$->namelist.push_back(index);}
    }
    else
   	 {int index = enter_var($1);$$->namelist.push_back(index);}

*/
    $$->idlist=$1->idlist;
    $$->eletypelist = $1->eletypelist;
    $$->dim = $1->dim;
    //$$->sem_type = -1;

};
L : L COMMA ID_ARR {
     $$ = new Node;
    /*int i = insert_symtab($3);
    
     $$->namelist.insert($$->namelist.end(),$1->namelist.begin(),$1->namelist.end());
    $$->namelist.push_back(i);*/
    /*int found = search_var($3,0);
    if(found)
    {
   	 printf("Variable %s already declared at same level\n",$3);
   	 $$->namelist = $1->namelist;
    }
    else if(level==2)
    {
   	 found = search_param($3);
   	 if(found)
   		 {
   			 printf("Redeclaration of Parameter %s as Variable\n",$3);
   			 $$->namelist = $1->namelist;
   		 }
   	 else
   	 {
   		 int index = enter_var($3);
   		 $$->namelist = $1->namelist;
   		 $$->namelist.push_back(index);
   	 }

    }
    else
    {
   	 int index = enter_var($3);
   	 $$->namelist = $1->namelist;
   	 $$->namelist.push_back(index);
    }*/
    $$->idlist = $1->idlist;
    $$->idlist.insert($$->idlist.end(),$3->idlist.begin(),$3->idlist.end());

    $$->eletypelist = $1->eletypelist;
    $$->eletypelist.insert($$->eletypelist.end(),$3->eletypelist.begin(),$3->eletypelist.end());
    
    $$->dim = $1->dim;
    $$->dim.insert($$->dim.end(),$3->dim.begin(),$3->dim.end());
    $$->comp = $1->comp;

    $$->nextlist2 = $1->nextlist2;
    $$->nextlist2.push_back(-1);

    //$$->sem_type = -1;

};


ASG : LHS EQ E_MAIN
{ /* depending on type */
    $$ = new Node;
    $$->id = $1->id;
//    int t = get_type_param($1->id);
    char we='t';
    if($3->type==1)
    {
   	 we='f';
    }

    int found = search_var($1->id,1);
    if(!found)
   	 found = search_param($1->id);
    //cout<<$1->id<<" "<<found<<" "<<$1->type<<"\n";

    if(found && get_var_type($1->id)!=$3->type)
   	 printf("Line %d : Type Mismatch\n",lineno );
    //cout<<$1->type<<" "<<$3->type<<"\n";
    
   	 //printf("Line %d : Type Mismatch\n",lineno );
    
    
   	 
    if($1->type2 == 4)
    {
   	 char arr[500];
   	 if($3->flag==0)
   		 {
   			 int l = get_level($1->id);

   			 if(l<0)
   			 {
   				 sprintf(arr,"#%d = %c%d\n",abs(l),we,$3->reg);
   			 //    cout<<
   			 }
   			 else
   				 sprintf(arr,"%s_%d = %c%d\n",$1->id.c_str(),l,we,$3->reg);
   		 }
   	 else
   	 {
   		 /*quadruple[quadruple.size()-2] += $1->id;
   		 quadruple[quadruple.size()-2] += "_" + to_string(level);*/
   		 string call_func_name = "";
   		 int f=0;
   		 //cout<<quadruple[quadruple.size()-1]<<" ";
   		 for(int i=0;i<quadruple[quadruple.size()-1].size();i++)
   		 {
   			 if(f==1)
   				 call_func_name += quadruple[quadruple.size()-1][i];
   			 if(quadruple[quadruple.size()-1][i]==' ')
   				 f=1;


   		 }
   		 int t;
   		 for(int i=0;i<functionTable.size();i++)
   		 {
   			 if(functionTable[i].name==call_func_name)
   			 {
   				 t = functionTable[i].resultType;
   				 break;
   			 }
   		 }
   		 char we;
   		 if(t==0)
   			 we='t';
   		 else
   			 we='f';
   		 int r = getfreet();
   		 freet[r] = 1;
   		 quadruple[quadruple.size()-2] += we + to_string(r);
   		 
   		 //cout<<"\n\n\n"<<call_func_name<<"\n\n\n";

   		 sprintf(arr,"%c%d = v0",we,r);
   		 quadruple.resize(nextquad+1);
   		 quadruple[nextquad] = arr;
   		 nextquad++;
   		 int l = get_level($1->id);
   		 if(l<0)
   		 {
   			 //cout<<"afvdsb<<" ""
   			 sprintf(arr,"#%d = %c%d",abs(l),we,r);
   		 }
   		 else
   			 {

   				 //cout<<"afvdsb<<" "";

   				 sprintf(arr,"%s_%d = %c%d",$1->id.c_str(),l,we,r);

   			 }
   		 for(int i=0;i<$3->regNum.size();i++)
   			 freeit($3->regNum[i]);
   		 freeit(r);
   	 }
   	 //sprintf(arr,"%s = t%d\n",$1->id.c_str(),$3->reg);
   	 $$->nextlist2.push_back(nextquad);
   	 
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
    }
    else
    {
   	 char arr[500];
   	 int a1 = getfreet();
   	 freet[a1]=1;
   	 

   	 

   	 vector<symTab> temp = functionTable[activeFunc].varList;
   	 vector<int> dim;
   	 int type;
   	 for(int i=0;i<temp.size();i++)
   	 {
   		 if(temp[i].name==$1->id)
   			 {
   				 dim = temp[i].dim;
   				 type = temp[i].type;
   			 }
   	 }
   	 int memory = 1;
   	 for(int i=0;i<dim.size();i++)
   	 {
   		 memory = memory * dim[i];
   	 }

   	 sprintf(arr,"t%d = addr(%s) %d\n",a1,$1->id.c_str(),memory);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;

   	 int ans=0;
   	 int final=0;
   	 if(type==0)
   	 {
   		 ans = 4;
   	 }
   	 else
   	 {
   		 ans = 8;
   	 }
   	 int w= getfreet();
   	 freet[w]=1;
   	 int cnt=0;
   	 char temp3[500];
   	 sprintf(temp3,"t%d = 0\n",w);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = temp3;
   	 nextquad++;

   	 for(int i=0;i<$1->dim.size();i++)
   	 {
   		 if($1->dim[i]!=-1)
   		 {
   			 int o=1;
   			 for(int j=i+1;j<$1->dim.size();j++)
   			 {
   				 o=o*dim[j];
   			 }
   			 o=o*$1->dim[i]*ans;
   			 final = final + o;
   		 }
   		 else
   		 {
   			 int q=1;
   			 for(int j=i+1;j<$1->dim.size();j++)
   			 {
   				 q = q*dim[j];
   			 }
   			 q= q*ans;
   			 int r = getfreet();
   			 freet[r]=1;

   			 int e = getfreet();
   			 freet[e]=1;
   			 char temp4[500];
   			 int l = get_level($1->id);
   			 sprintf(temp4,"t%d = %s_%d\n",e,$1->iddim[i].c_str(),l);
   			 quadruple.resize(nextquad+1);
   			 quadruple[nextquad] = temp4;
   			 nextquad++;


   			 char temp[500];
   			 sprintf(temp,"t%d = %d*t%d\n",r,q,e);
   			 quadruple.resize(nextquad+1);
   			 quadruple[nextquad] = temp;
   			 nextquad++;
   			 char temp2[500];
   			 sprintf(temp2,"t%d = t%d+t%d\n",w,w,r);
   			 quadruple.resize(nextquad+1);
   			 quadruple[nextquad] = temp2;
   			 nextquad++;
   			 freeit(r);
   			 freeit(e);
   			 cnt++;
   		 }
   	 }
   	 
   	 char temp2[500];
   	 sprintf(temp2,"t%d = t%d+%d\n",w,w,final);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = temp2;
   	 nextquad++;

   	 char arr2[500];
   	 int a2 = getfreet();
   	 freet[a2]=1;

   	 sprintf(arr2,"t%d = t%d\n",a2,w);
   	 quadruple.resize(nextquad+1);
   	 
   	 quadruple[nextquad] = arr2;
   	 nextquad++;
   	 freeit(w);

   	 char arr3[500];
   	 sprintf(arr3,"t%d[t%d] = %c%d\n",a1,a2,we,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr3;
   	 nextquad++;
   	 freeit(a1);
   	 freeit(a2);
    }

    /*char arr[500];
    if($$->flag==0)
   	 sprintf(arr,"%s = t%d\n",$1->id.c_str(),$3->reg);
    else
    {
   	 quadruple[quadruple.size()-2] += $1->id;
   	 sprintf(arr,"%s = result",$1->id.c_str());
    }
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;*/
    freeit($3->reg);
    /*if($1->type!=$3->type)
    {
   	 printf("Type Mismatch\n");
    }*/

    $$->idlist = $1->idlist;
    $$->eletypelist = $1->eletypelist;
    $$->dim = $1->dim;
    $$->comp.push_back(make_pair($1->id , $3->type));

};
///////////////////////////////////////////////////
E_MAIN : ID LP CALL_PARAM RP
{

    $$ = new Node;
    int index = -1;
    for(int i=0;i<functionTable.size();i++)
    {
   	 if(functionTable[i].name==$1)
   	 {
   		 index = i;
   	 }
    }
    if(index==-1)
    {
   	 printf("Line %d : Function %s Not declared\n",lineno,$1);
    }
    else
    {
   	 $$->type = functionTable[index].resultType;

   	 vector<int> param = $3->nextlist;
   	 vector<symTab> parList = functionTable[index].parList;
   	 if(parList.size()!=param.size())
   	 {
   		 printf("Line %d : Wrong Number of passed arguments for function %s \n",lineno,$1);
   	 }
   	 else
   	 {
   		 for(int i=0;i<param.size();i++)
   		 {
   			 if(parList[i].type!=param[i])
   			 {
   				 printf("Line %d : Argument Type Mismatch\n",lineno);
   				 break;
   			 }
   		 }
   		 /*vector<string> list = $3->list;
   		 char arr[500];
   		 for(int i=0;i<list.size();i++)
   		 {
   			 
   			 for(int j=0;j<list[i].size();j++)
   			 {
   				 if(isalpha(list[i][j]))
   					 {
   						 int l = get_level(list[i]);
   						 char we='t';
   						 int y=get_var_type(list[i]);
   						 if(y==-1)
   						 {
   							 y=get_param_type(list[i]);
   						 }
   						 if(y==1)
   						 {
   							 we='f';
   						 }
   						 if(l<0)
   						 {

   							 int r = getfreet();
   							 freet[r] = 1;
   							 $$->regNum.push_back(r);
   							 sprintf(arr,"%c%d = #%d",we,r,abs(l));
   							 quadruple.resize(nextquad+1);
   							 quadruple[nextquad] = arr;
   							 nextquad++;
   							 sprintf(arr,"refparam %c%d",we,r);
   						 }
   						 else
   							 {
   								 int r = getfreet();
   								 freet[r] = 1;
   								 $$->regNum.push_back(r);
   								 sprintf(arr,"%c%d = %s_%d",we,r,list[i].c_str(),l);
   								 quadruple.resize(nextquad+1);
   								 quadruple[nextquad] = arr;
   								 nextquad++;
   								 sprintf(arr,"refparam %c%d",we,r);
   							 }
   						 quadruple.resize(nextquad+1);
   						 quadruple[nextquad] = arr;
   						 nextquad++;
   						 break;
   					 }
   				 else
   				 {
   							 char we='t';
   							 int f=0;
   							 for(int j=0;j<list[i].size();j++)
   								 if(list[i][j]=='.')
   									 f=1;
   							 if(f==1)
   								 we='f';
   							 int r = getfreet();
   							 freet[r] = 1;
   							 $$->regNum.push_back(r);
   							 sprintf(arr,"%c%d = %s",we,r,list[i].c_str());
   							 quadruple.resize(nextquad+1);
   							 quadruple[nextquad] = arr;
   							 nextquad++;
   							 sprintf(arr,"refparam %c%d",we,r);
   							 quadruple.resize(nextquad+1);
   							 quadruple[nextquad] = arr;
   							 nextquad++;
   							 break;
   				 }
   			 }
   		 }*/
   		 char arr[500];
   		 //cout<<$3->regFunc.size()<<"vfsvd\n";
   		 for(int i=0;i<$3->regFunc.size();i++)
   		 {
   			 /*int r = getfreet();
   			 freet[r] = 1;*/
   			 $$->regNum.push_back($3->regFunc[i]);
   			 /*sprintf(arr,"%c%d = %s_%d",we,r,list[i].c_str(),l);
   			 quadruple.resize(nextquad+1);
   			 quadruple[nextquad] = arr;
   			 nextquad++;*/
   			 char we='t';
   			 int f=0;
   			 if($3->nextlist[i]==1)
   				 f=1;
   			 if(f==1)
   				 we='f';
   			 sprintf(arr,"refparam %c%d",we,$3->regFunc[i]);
   			 quadruple.resize(nextquad+1);
   			 quadruple[nextquad] = arr;
   			 nextquad++;
   			 break;
   		 }
   		 sprintf(arr,"refparam ");
   		 quadruple.resize(nextquad+1);
   		 quadruple[nextquad] = arr;
   		 nextquad++;
   		 sprintf(arr , "call %s",$1);
   		 quadruple.resize(nextquad+1);
   		 quadruple[nextquad] = arr;
   		 nextquad++;

   	 }
    }

    $$->flag = 1;
    
};
CALL_PARAM : CALL_PARAM COMMA E_MAIN
{

    $$ = new Node;
    $$->nextlist = $1->nextlist;
    $$->nextlist.push_back($3->type);
    
    /*$$->list = $1->list;
    $$->list.insert($$->list.end(),$3->list.begin(),$3->list.end());*/

    $$->regFunc = $1->regFunc;
    $$->regFunc.push_back($3->reg);
};
CALL_PARAM : E_MAIN
{

    $$ = new Node;
    $$->nextlist.push_back($1->type);
    //$$->list = $1->list;

    $$->regFunc.push_back($1->reg);
};
CALL_PARAM :
{

    $$ = new Node;
};

LHS : ID_ARR
{


    $$ = new Node;
    $$->id = $1->id;
    $$->type2 = $1->type2;
    $$->dim = $1->dim;
    $$->iddim = $1->iddim;
    //$$->idlist = $1->idlist;

    /*
    int found = search_var($1,1);
    if(!found)
   	 found = search_param($1);
    if(!found)
    {
   	 printf("Variable %s not declared\n",$1);
    }
    $$->type  = get_var_type($1);
    if($$->type==-1)
   	 $$->type = get_param_type($1);*/
    //$$->idlist.push_back($1);
    $$->idlist.insert($$->idlist.end(),$1->idlist.begin(),$1->idlist.end());
    $$->eletypelist.insert($$->eletypelist.end(),$1->eletypelist.begin(),$1->eletypelist.end());
    $$->type = $1->type;

};
E_MAIN : E22
{
//    cout<<3<<endl;
    $$ = new Node;  
    $$->reg = $1->reg;
    /*char arr[500];
    sprintf(arr,"t%d = t%d\n",$$->reg,$1->reg);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;*/
    $$->nextlist.insert($$->nextlist.end(),$1->nextlist.begin(),$1->nextlist.end());
    /*freet[$$->reg]=1;
    freeit($1->reg);*/
//    cout<<$$->nextlist.size()<<endl;

    $$->type = $1->type;
//    cout<<"---------"<<$$->type<<endl;
    $$->flag=0;
};
E_MAIN : E_MAIN OR M_E1 E22
{
    $$ = new Node;  
    $$->reg = getfreet();

    if($1->type==0 && $3->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d || t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = f%d || f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=0;
    }
    char we='t';
    if($$->type == 0)
    {
   	 we='t';
    }
    else
   	 we='f';
    $$->nextlist.insert($$->nextlist.end(),$4->nextlist.begin(),$4->nextlist.end());
    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
//    cout<<$3->nextlist.size()<<endl;
    for(int i=0;i<$3->nextlist.size();i++)
    {
   	 char temp[100];
   	 sprintf(temp,"if %c%d==1 goto %d",we,$1->reg,nextquad-1);
   	 quadruple[$3->nextlist[i]] = temp;
    }

    freet[$$->reg]=1;
    freeit($1->reg);
    freeit($4->reg);
    if($1->type!=$4->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
    //$$->type = $1->type;
    $$->flag=0;
};
E_MAIN : E_MAIN AND M_E0 E22
{
    //cout<<22<<endl;
    $$ = new Node;  
    $$->reg = getfreet();
    if($1->type==0 && $3->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d && t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = f%d && f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=0;
    }
    char we;
    if($$->type == 0)
    {
   	 we='t';
    }
    else
   	 we='f';
    $$->nextlist.insert($$->nextlist.end(),$4->nextlist.begin(),$4->nextlist.end());
    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
//    cout<<$3->nextlist.size()<<endl;
    for(int i=0;i<$3->nextlist.size();i++)
    {
   	 char temp[100];
   	 sprintf(temp,"if %c%d==0 goto %d",we,$1->reg,nextquad-1);
   	 quadruple[$3->nextlist[i]] = temp;
    }
//    cout<<$$->nextlist.size()<<endl;
    freet[$$->reg]=1;
    freeit($1->reg);
    freeit($4->reg);
    //cout<<$$->nextlist.size()<<endl;
    if($1->type!=$4->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
//    $$->type = $1->type;
    $$->flag=0;
};

M_E1 :
{
    $$ = new Node;
    char temp[500];
    sprintf(temp,"if t==1 goto ");
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = temp;
    $$->nextlist.push_back(nextquad);
    nextquad++;
    $$->quad = nextquad;
};

M_E0 :
{
    //cout<<4<<endl;
    $$ = new Node;
    char temp[500];
    sprintf(temp,"if t==0 goto ");
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = temp;
    $$->nextlist.push_back(nextquad);
    nextquad++;
    $$->quad = nextquad;
};

E22 : E2
{
    $$ = new Node;  
    $$->reg = $1->reg;
    /*char arr[500];
    sprintf(arr,"t%d = t%d\n",$$->reg,$1->reg);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;*/
    $$->nextlist.insert($$->nextlist.end(),$1->nextlist.begin(),$1->nextlist.end());
    /*freet[$$->reg]=1;
    freeit($1->reg);*/

    $$->type = $1->type;
};

E22 : E22 LT E2
{
    $$ = new Node;  
    $$->reg = getfreet();
    if($1->type==0 && $3->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d < t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = f%d < f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=0;
    }
    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
    freet[$$->reg]=1;
    freeit($1->reg);
    freeit($3->reg);
    if($1->type!=$3->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
//    $$->type = $1->type;
};

E22 : E22 GT E2
{
    $$ = new Node;  
    $$->reg = getfreet();
    if($1->type==0 && $3->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d > t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = f%d > f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=0;
    }
    freet[$$->reg]=1;
    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
    freeit($1->reg);
    freeit($3->reg);
    if($1->type!=$3->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
//    $$->type = $1->type;
};
E22 : E22 LE E2
{
    $$ = new Node;  
    $$->reg = getfreet();
    if($1->type==0 && $3->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d <= t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = f%d <= f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=0;
    }
    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
    freet[$$->reg]=1;
    freeit($1->reg);
    freeit($3->reg);
    if($1->type!=$3->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
//    $$->type = $1->type;
};
E22 : E22 GE E2
{
    $$ = new Node;  
    $$->reg = getfreet();

    if($1->type==0 && $3->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d >= t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = f%d >= f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=0;
    }
    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
    freet[$$->reg]=1;
    freeit($1->reg);
    freeit($3->reg);
    if($1->type!=$3->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
    //$$->type = $1->type;
};
E22 : E22 EE E2
{
    $$ = new Node;  
    $$->reg = getfreet();

    if($1->type==0 && $3->type==0)
    {
    //    cout<<"----------------------u787687";
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d = t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
    //    cout<<"----------------------p787687";
   	 char arr[500];
   	 sprintf(arr,"t%d = f%d = f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=0;
    }

    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
    freet[$$->reg]=1;
    freeit($1->reg);
    freeit($3->reg);
    if($1->type!=$3->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
//    $$->type = $1->type;
};

E2 : E
{
    $$ = new Node;  
    $$->reg = $1->reg;
    /*char arr[500];
    sprintf(arr,"t%d = t%d\n",$$->reg,$1->reg);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;*/
    $$->nextlist.insert($$->nextlist.end(),$1->nextlist.begin(),$1->nextlist.end());
    /*freet[$$->reg]=1;
    freeit($1->reg);*/

    $$->type = $1->type;
};
E2 : NOT E
{
    $$ = new Node;
//    printf("ok\n");
    $$->reg = getfreet();
//    $$->type = $2->type;
    if($2->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = NOT t%d\n",$$->reg,$2->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"f%d = NOT f%d\n",$$->reg,$2->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
    }
    
    $$->nextlist.insert($$->nextlist.end(),$2->nextlist.begin(),$2->nextlist.end());
    freet[$$->reg]=1;
    freeit($2->reg);

    $$->type = $2->type;
};
//E : NOT E ;
E     :     T2
{
    $$ = new Node;  
    $$->reg = $1->reg;
    $$->type = $1->type;
    /*char arr[500];
    sprintf(arr,"t%d = t%d\n",$$->reg,$1->reg);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;*/
    $$->nextlist.insert($$->nextlist.end(),$1->nextlist.begin(),$1->nextlist.end());
    /*freet[$$->reg]=1;
    freeit($1->reg);*/
    $$->type = $1->type;
};
E     :    E PLUS T2
{
    $$ = new Node;  
    $$->reg = getfreet();

    if($1->type==0 && $3->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d + t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"f%d = f%d + f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=1;
    }

    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
    freet[$$->reg]=1;
    freeit($1->reg);
    freeit($3->reg);

    if($1->type!=$3->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
    $$->type = $1->type;
};

E     :    E MINUS T2
{
    $$ = new Node;  
    $$->reg = getfreet();

    if($1->type==0 && $3->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d - t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"f%d = f%d - f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=1;
    }

    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
    freet[$$->reg]=1;
    freeit($1->reg);
    freeit($3->reg);

    if($1->type!=$3->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
    $$->type = $1->type;
};


T2     :     F
{
//    printf("ok\n");
    $$ = new Node;  
    $$->reg = $1->reg;
    $$->type = $1->type;
    /*char arr[500];
    sprintf(arr,"t%d = t%d\n",$$->reg,$1->reg);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;*/
    $$->nextlist.insert($$->nextlist.end(),$1->nextlist.begin(),$1->nextlist.end());
    /*freet[$$->reg]=1;
    freeit($1->reg);*/

    $$->type = $1->type;
};
T2     :     T2 STAR F
{
    $$ = new Node;  
    $$->reg = getfreet();

    if($1->type==0 && $3->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d * t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"f%d = f%d * f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=1;
    }
    
    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
    freet[$$->reg]=1;
    freeit($1->reg);
    freeit($3->reg);

    if($1->type!=$3->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
    $$->type = $1->type;
};

T2     :     T2 DIVIDE F
{
    $$ = new Node;  
    $$->reg = getfreet();

    if($1->type==0 && $3->type==0)
    {
   	 char arr[500];
   	 sprintf(arr,"t%d = t%d / t%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type = 0;
    }
    else
    {
   	 char arr[500];
   	 sprintf(arr,"f%d = f%d / f%d\n",$$->reg,$1->reg,$3->reg);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;
   	 $$->type=1;
    }
    
    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
    freet[$$->reg]=1;
    freeit($1->reg);
    freeit($3->reg);

    if($1->type!=$3->type)
    {
   	 printf("Line %d : Type Mismatch\n",lineno);
    }
    $$->type = $1->type;
};

/*T2 : PLUS PLUS F
{
    $$ = new Node;  
    $$->reg = getfreet();
    char arr[500];
    sprintf(arr,"t%d = t%d + 1\n",$$->reg,$3->reg);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;
    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());
    freet[$$->reg]=1;
    freeit($3->reg);

    
    $$->type = $3->type;
};*/
/*T2 :  F PLUS PLUS
{
    $$ = new Node;  
    $$->reg = getfreet();
    char arr[500];
    sprintf(arr,"t%d = t%d + 1\n",$$->reg,$1->reg);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;
    $$->nextlist.insert($$->nextlist.end(),$1->nextlist.begin(),$1->nextlist.end());
    freet[$$->reg]=1;
    freeit($1->reg);

    $$->type = $1->type;
};*/

F     :     ID
{
    $$ = new Node;  
    $$->reg = getfreet();
    char arr[500];
    int type = get_var_type($1);
    if(type == -1)
    {
   	 type = get_param_type($1);
    }

    char q;
//    cout<<$1<<" ---- "<<type<<endl;
    if(type==0)
   	 q='t';
    else
   	 q='f';
    //cout<<"-----"<<type<<endl;
    int l = get_level($1);
    if(l < 0)
    {
   	 //cout<<"yuff";
   	 sprintf(arr,"%c%d = #%d\n",q,$$->reg,abs(l));
    }
    else
   	 sprintf(arr,"%c%d = %s_%d\n",q,$$->reg,$1,l);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;
    freet[$$->reg]=1;

    int found = search_var($1,1);
    if(!found)
    {
   	 found = search_param($1);
   	 if(!found)
   		 printf("Line %d : Variable %s not declared\n",lineno, $1);
    }
    $$->type  = get_var_type($1);
    $$->type = type;
    sprintf(arr,"%s",$1);
    $$->list.push_back(arr);
};


F     :     ID DIMList
{
    $$ = new Node;  
    $$->reg = getfreet();
    freet[$$->reg]=1;
    int a1 = getfreet();
    freet[a1]=1;
    int a2 = getfreet();
    freet[a2]=1;
    int memory =1;

    

    vector<symTab> temp = functionTable[activeFunc].varList;
   	 vector<int> dim;
   	 int type;
   	 for(int i=0;i<temp.size();i++)
   	 {
   		 if(temp[i].name==$1)
   			 {
   				 dim = temp[i].dim;
   				 type = temp[i].type;
   			 }
   	 }
   	 for(int i=0;i<dim.size();i++)
   	 {
   		 memory = memory * dim[i];
   	 }
   	 char arr[500];
   	 sprintf(arr,"t%d = addr(%s) %d\n",a1,$1,memory);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = arr;
   	 nextquad++;


   	 int ans=0;
   	 int final=0;
   	 if(type==0)
   	 {
   		 ans = 4;
   	 }
   	 else
   	 {
   		 ans = 8;
   	 }
   	 int w= getfreet();
   	 freet[w]=1;
   	 int cnt=0;
   	 char temp3[500];
   	 sprintf(temp3,"t%d = 0\n",w);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = temp3;
   	 nextquad++;

   	 for(int i=0;i<$2->dim.size();i++)
   	 {
   		 if($2->dim[i]!=-1)
   		 {
   			 int o=1;
   			 for(int j=i+1;j<$2->dim.size();j++)
   			 {
   				 o=o*dim[j];
   			 }
   			 o=o*$2->dim[i]*ans;
   			 final = final + o;
   		 }
   		 else
   		 {
   			 int q=1;
   			 for(int j=i+1;j<$2->dim.size();j++)
   			 {
   				 q = q*dim[j];
   			 }
   			 q= q*ans;
   			 int r = getfreet();
   			 freet[r]=1;
   			 int e = getfreet();
   			 freet[e]=1;
   			 char temp4[500];
   			 int l = get_level($1);
   			 sprintf(temp4,"t%d = %s_%d\n",e,$2->iddim[i].c_str(),l);
   			 quadruple.resize(nextquad+1);
   			 quadruple[nextquad] = temp4;
   			 nextquad++;


   			 char temp3[500];
   			 sprintf(temp3,"t%d = %d*t%d\n",r,q,e);
   			 quadruple.resize(nextquad+1);
   			 quadruple[nextquad] = temp3;
   			 nextquad++;
   			 char temp2[500];
   			 sprintf(temp2,"t%d = t%d+t%d\n",w,w,r);
   			 quadruple.resize(nextquad+1);
   			 quadruple[nextquad] = temp2;
   			 nextquad++;
   			 freeit(r);
   			 freeit(e);
   			 cnt++;
   		 }
   	 }
   	 
   	 char temp2[500];
   	 sprintf(temp2,"t%d = t%d+%d\n",w,w,final);
   	 quadruple.resize(nextquad+1);
   	 quadruple[nextquad] = temp2;
   	 nextquad++;

   	 char arr4[500];
    //    int a2 = getfreet();
    //    freet[a2]=1;

   	 sprintf(arr4,"t%d = t%d\n",a2,w);
   	 quadruple.resize(nextquad+1);
   	 
   	 quadruple[nextquad] = arr4;
   	 nextquad++;
   	 freeit(w);



    /*char arr1[500];
    sprintf(arr1,"t%d = \n",a2);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr1;
    nextquad++;*/

    char arr2[500];
    sprintf(arr2,"t%d = t%d[t%d]\n",$$->reg,a1,a2);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr2;
    nextquad++;
    freeit(a1);
    freeit(a2);
    

    int found = search_var($1,1);
    if(!found)
    {
   	 found = search_param($1);
   	 if(!found)
   		 printf("Line %d : Variable %s not declared\n",lineno, $1);
    }
    $$->type  = get_var_type($1);

};

F : DECIMAL
{
    $$ = new Node;  
    $$->reg = getfreet();
    char arr[500];
    sprintf(arr,"f%d = %f\n",$$->reg,$1);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;
    freet[$$->reg]=1;

    $$->type  = 1;
    $$->list.push_back(to_string($1));
};


F   :   NUM
{
    $$ = new Node;  
    $$->reg = getfreet();
    char arr[500];
    sprintf(arr,"t%d = %d\n",$$->reg,$1);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;
    freet[$$->reg]=1;

    $$->type  = 0;
    $$->list.push_back(to_string($1));
};
F     :     LP E_MAIN RP
{
    $$ = new Node;  
    $$->reg = $2->reg;
    $$->type = $2->type;
    /*char arr[100];
    sprintf(arr,"t%d = t%d\n",$$->reg,$2->reg);
    quadruple.resize(nextquad+1);
    quadruple[nextquad] = arr;
    nextquad++;*/
    $$->nextlist.insert($$->nextlist.end(),$2->nextlist.begin(),$2->nextlist.end());
    /*freet[$$->reg]=1;
    freeit($2->reg);*/

};

WHILEXEP : WHILE M_WHILE E_MAIN
{
    //cout<<$3->nextlist.size()<<endl;
    //cout<<123<<endl;
    //printf("ok");
    $$ = new Node;
    $$->falselist.push_back(nextquad);
    quadruple.resize(nextquad+1);

    char we = 't';
    if ($3->type==1)
   	 we='f';
    char arr[500];
    sprintf(arr,"if %c%d <=0 goto ",we,$3->reg);
    quadruple[nextquad] = arr;
//    cout<<$3->nextlist.size()<<endl;
    /*for(int i=0;i<$3->nextlist.size();i++)
    {
   	 cout<<1<<endl;
   	 char temp[100];
   	 sprintf(temp,"%d",nextquad);
   	 quadruple[$3->nextlist[i]] += temp;
    }*/
    freeit($3->reg);
    nextquad++;
    $$->begin = $2->quad;

    level++;
};

M_WHILE :
{
    $$ = new Node;
    $$->quad = nextquad;
};


STMT : IFEXP LC STMT_LIST RC N ELSE LC M STMT_LIST RC
{
    $$ = new Node;
    for(int i=0;i<$1->falselist.size();i++)
    {
   	 quadruple[$1->falselist[i]].append(to_string($8->quad));
    }
    $$->nextlist.insert($$->nextlist.end() , $3->nextlist.begin(),$3->nextlist.end());
    $$->nextlist.insert($$->nextlist.end() ,$5->nextlist.begin(),$5->nextlist.end());
    $$->nextlist.insert($$->nextlist.end() , $9->nextlist.begin(),$9->nextlist.end());

    int i=0;
    for(i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 if(functionTable[activeFunc].varList[i].level==level)
   	 {
   		 functionTable[activeFunc].varList.erase(functionTable[activeFunc].varList.begin()+i);
   		 i=0;
   	 }
    }
    /*for(int i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 cout<<functionTable[activeFunc].varList[i].name<<" "<<functionTable[activeFunc].varList[i].level<<"\n";
    }*/
    level--;
};

STMT : IFEXP LC STMT_LIST RC
{
    //cout<<"11";
    $$ = new Node;
    $$->nextlist.insert($$->nextlist.end(),$1->falselist.begin(),$1->falselist.end());
    $$->nextlist.insert($$->nextlist.end(),$3->nextlist.begin(),$3->nextlist.end());

    int i=0;
    for(i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 if(functionTable[activeFunc].varList[i].level==level)
   	 {
   		 functionTable[activeFunc].varList.erase(functionTable[activeFunc].varList.begin()+i);
   		 i=0;
   	 }
    }
    ///cout<<"fbsbjs";
    for(int i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 cout<<functionTable[activeFunc].varList[i].name<<" "<<functionTable[activeFunc].varList[i].level<<"\n";
    }
    level--;
};

IFEXP : IF E_MAIN
{
    //cout<<"11";
    $$ = new Node;
    char we = 't';
    //cout<<"-----"<<$2->type<<"-----------------------"<<endl;
    if ($2->type==1)
   	 we='f';

    //cout<<nextquad;
    $$->falselist.push_back(nextquad);
    char temp[100];
    sprintf(temp,"if %c%d <= 0 goto ",we,$2->reg);
    quadruple.push_back(temp);
    nextquad++;
    level++;
    freeit($2->reg);
};
N :
{
    $$ = new Node;
    $$->nextlist.push_back(nextquad);
    quadruple.push_back("goto ");
    nextquad++;
    int i;
    for(i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 if(functionTable[activeFunc].varList[i].level==level)
   	 {
   		 functionTable[activeFunc].varList.erase(functionTable[activeFunc].varList.begin()+i);
   		 i=0;
   	 }
    }
};
M :
{
    $$ = new Node;
    $$->quad = nextquad;    
};
STMT : LC M_LEVEL STMT_LIST RC
{
    $$ = new Node;
    $$->nextlist = $3->nextlist;

    int i=0;
    for(i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 if(functionTable[activeFunc].varList[i].level==level)
   	 {
   		 functionTable[activeFunc].varList.erase(functionTable[activeFunc].varList.begin()+i);
   		 i=0;
   	 }
    }
    level--;
};
M_LEVEL :
{
    level++;
};

STMT : SWITCH LP E_MAIN RP M_SWITCH LC cases RC
{
    $$ = new Node;
    $$->nextlist.insert($$->nextlist.end(),$7->nextlist.begin(),$7->nextlist.end());

    int i=0;
    for(i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 if(functionTable[activeFunc].varList[i].level==level)
   	 {
   		 functionTable[activeFunc].varList.erase(functionTable[activeFunc].varList.begin()+i);
   		 i=0;
   	 }
    }
    for(int i=0;i<$7->namelist.size();i++)
    {

   	 //cout<<$7->namelist.size();
   	 string str = quadruple[$7->namelist[i]];
   	 string temp="";
   	 for(int i=0;i<str.size();i++)
   	 {
   		 if(str[i]=='E')
   			 temp+="t"+to_string($3->reg);
   		 else
   			 temp+=str[i];
   	 }
   	 quadruple[$7->namelist[i]] = temp;
    }
    freeit($3->reg);
    level--;
};
M_SWITCH :
{
    level++;
};

cases : case cases
{
    $$ = new Node;
    $$->nextlist.insert($$->nextlist.end(),$1->nextlist.begin(),$1->nextlist.end());
    $$->nextlist.insert($$->nextlist.end(),$2->nextlist.begin(),$2->nextlist.end());
    $$->namelist = $1->namelist;
    $$->namelist.insert($$->namelist.end(),$2->namelist.begin(),$2->namelist.end());
};

cases : case
{
    $$ = new Node;
    $$->nextlist.insert($$->nextlist.end(),$1->nextlist.begin(),$1->nextlist.end());
    $$->namelist = $1->namelist;
};
cases : default
{
    $$ = new Node;
    $$->nextlist = $1->nextlist;
};
case : case_exp COLON LC STMT_LIST case_end RC
{
    $$ = new Node;
    quadruple[$1->end].append(to_string(nextquad));
    $$->nextlist.insert($$->nextlist.end(),$4->nextlist.begin(),$4->nextlist.end());
    $$->nextlist.insert($$->nextlist.end(),$5->nextlist.begin(),$5->nextlist.end());

    int i=0;
    for(i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 if(functionTable[activeFunc].varList[i].level==level)
   	 {
   		 functionTable[activeFunc].varList.erase(functionTable[activeFunc].varList.begin()+i);
   		 i=0;
   	 }
    }
    $$->namelist = $1->namelist;
    level--;
};
case_exp : CASE constant_expr
{
    $$ = new Node;
    char temp[100];
    int r = getfreet();
    freet[r] = 1;
    sprintf(temp,"t%d = %d",r,$2->value);
    quadruple.push_back(temp);
    nextquad++;

    $$->end = nextquad;
    
    sprintf(temp,"if E != t%d goto ",r);
    quadruple.push_back(temp);
    $$->namelist.push_back(nextquad);
    nextquad++;    

    freeit(r);
    level++;
};
default : DEFAULT COLON M_SWITCH LC STMT_LIST RC  
{
    $$ = new Node;

    int i=0;
    for(i=0;i<functionTable[activeFunc].varList.size();i++)
    {
   	 if(functionTable[activeFunc].varList[i].level==level)
   	 {
   		 functionTable[activeFunc].varList.erase(functionTable[activeFunc].varList.begin()+i);
   		 i=0;
   	 }
    }
    $$->nextlist.insert($$->nextlist.end(),$5->nextlist.begin(),$5->nextlist.end());
    level--;
};
case_end : BREAK SEMI
{
    $$ = new Node;
    $$->nextlist.push_back(nextquad);
    quadruple.push_back("goto ");
    nextquad++;
};
case_end :
{
    $$ = new Node;
};
constant_expr : NUM
{
    $$ = new Node;
    $$->value = $1;    
};




%%
int search_func(string name)
{
    for(int i=0;i<functionTable.size();i++)
    {
   	 if(functionTable[i].name==name)
   		 return 1;
    }
    return 0;
}
int enter_func(int type , string name)
{
    funcNameTable *f = new funcNameTable;
    f->name = name;
    f->resultType = type;
    functionTable.push_back(*f);
    return functionTable.size()-1;
}
int search_param(string name)
{
    vector<symTab> temp = functionTable[activeFunc].parList;
    for(int i=0;i<temp.size();i++)
    {
   	 if(temp[i].name==name)
   	 {
   		 return 1;
   	 }
    }
    return 0;
}
void enter_param(string name,int type)
{
    symTab *t = new symTab;
    t->name = name;
    t->type = type;
    t->tag = 0;
    t->level = 1;
    functionTable[activeFunc].parList.push_back(*t);
}

int search_var(string name,int flag)
{
    vector<symTab> temp = functionTable[activeFunc].varList;
    for(int i=0;i<temp.size();i++)
    {
   	 //cout<<temp[i].name<<" "<<temp[i].level<<"\n";
   	 if(flag==0)
   	 {
   		 if(temp[i].name==name && temp[i].level==level)
   		 {
   			 return 1;
   		 }
   	 }
   	 else
   	 {
   		 if(temp[i].name==name && temp[i].level<=level)
   		 {
   			 return 1;
   		 }
   	 }
    }
    if(flag==1)
    {
   	 temp = functionTable[0].varList;
   	 for(int i=0;i<temp.size();i++)
   	 {
   		 if(temp[i].name==name && temp[i].level<=level)
   		 {
   			 return 1;
   		 }
   	 }
    }
    
    return 0;
}
int enter_var(string name,int flag,vector<int> dim)
{
    symTab *t = new symTab;
    t->name = name;
    t->tag = 1;
    t->level = level;
    t->eletype = flag;
    t->dim = dim;
    functionTable[activeFunc].varList.push_back(*t);
    return functionTable[activeFunc].varList.size()-1;
}
void patch_type1(int type , vector<int> list)
{
    for(int i=0;i<list.size();i++)
    {
   	 functionTable[activeFunc].varList[list[i]].type = type;
    }
}
int get_var_type(string name)
{
    vector<symTab> temp = functionTable[activeFunc].varList;
    int pos=-1,l=-1;
    for(int i=0;i<temp.size();i++)
    {
   	 if(temp[i].name==name && temp[i].level<=level)
   	 {
   		 l = max(l,temp[i].level);
   		 pos=i;
   	 }
    }
    if(pos!=-1)
   	 return temp[l].type;
    temp = functionTable[0].varList;
    
    for(int i=0;i<temp.size();i++)
    {
   	 if(temp[i].name==name && temp[i].level<=level)
   	 {
   		 return temp[i].type;
   	 }
    }
    return -1;
}

int get_param_type(string name)
{
    vector<symTab> temp = functionTable[activeFunc].parList;
    for(int i=0;i<temp.size();i++)
    {
   	 if(temp[i].name==name)
   	 {
   		 return temp[i].type;
   	 }
    }
    return -1;
}

int get_ele_type(string name)
{
    vector<symTab> temp = functionTable[activeFunc].varList;
    for(int i=0;i<temp.size();i++)
    {
   	 if(temp[i].name==name && temp[i].level<=level)
   	 {
   		 return temp[i].eletype;
   	 }
    }
    temp = functionTable[activeFunc].parList;
    for(int i=0;i<temp.size();i++)
    {
   	 if(temp[i].name==name )
   	 {
   		 return temp[i].eletype;
   	 }
    }
    temp = functionTable[0].varList;
    for(int i=0;i<temp.size();i++)
   	 {
   		 if(temp[i].name==name && temp[i].level<=level)
   		 {
   			 return temp[i].eletype;
   		 }
   	 }
    return -1;
}

int get_dim(string name)
{
    vector<symTab> temp = functionTable[activeFunc].varList;
    for(int i=0;i<temp.size();i++)
    {
   	 if(temp[i].name==name)
   	 {
   		 return temp[i].dim.size();
   	 }
    }
    return -1;
}

int get_level(string name)
{
    vector<symTab> temp = functionTable[activeFunc].varList;
    int max_level=-1;
    for(int i=0;i<temp.size();i++)
    {
   	 if(temp[i].name==name)
   	 {
   		 max_level = max(temp[i].level,max_level);
   	 }
    }
    if(max_level==-1)
    {
   	 vector<symTab> temp = functionTable[activeFunc].parList;
   	 for(int i=0;i<temp.size();i++)
   	 {
   		 if(temp[i].name==name)
   		 {
   			 max_level = -1*(i+1);
   		 }
   	 }
    }    
    return max_level;
}

int getfreet()
{
    for(int i=0;i<freet.size();i++)
    {
   	 if(freet[i]==0)
   	 {
   		 return i;
   	 }
    }
    return -1;
}

void freeit(int i)
{
    freet[i]=0;
}

int insert_symtab(string id_name)
{
    int size = symbolTable.size();
    symTab temp;
    temp.name = id_name;
    temp.eletype = 0;
    temp.type = -1;
    symbolTable.push_back(temp);
    return size;
}

void patch_type2(int type, vector<int>v)
{
    for(int i=0;i<v.size();i++)
    {
   	 symbolTable[v[i]].type = type;
    }
    return ;
}


int main(int argc, char **argv)
{

    funcNameTable *f = new funcNameTable;
    f->name = "global";
    f->resultType = 0;
    functionTable.push_back(*f);
    yyparse();
    for(int i=0;i<quadruple.size();i++)
    {
   	 cout<<i<<": "<<quadruple[i]<<endl;
    }
    int label=1;
    vector<string>final;
    final.resize(quadruple.size()+1);
    map<int,int>m;
    for(int i=0;i<quadruple.size();i++)
    {
   	 string str;
   	 str  = quadruple[i];
   	 bool o=0;
   	 for(int j=0;j<str.size();j++)
   	 {
   		 if(str[j]=='\n')
   		 {
   			 quadruple[i].insert(j,";");
   			 o=1;
   		 }
   		 if(j+3<str.size() && str[j]=='g' && str[j+1]=='o' && str[j+2]=='t' && str[j+3]=='o')
   		 {
   			 j=j+5;
   			 string u = "L";
   			 string z = str.substr(j);    
   		 //    cout<<z<<" ";
   			 int temp = stoi(z);
   		 //    cout<<temp<<endl;
   			 char arr[100];
   			 quadruple[i].insert(j,u);
   			 if(j+6<str.size() && isalpha(str[j+6]))
   			 {
   				 
   			 }
   			 else if(m.find(temp)==m.end())
   			 {
   				 m[temp]=1;
   				 sprintf(arr,"L%d: ;\n",temp);
   				 final[temp] += arr;
   			 }
   			 
   	 //   	 cout<<temp<<endl;
   		 }
   	 }
   	 if(o==0)
   	 {
   		 quadruple[i]+=';';
   		 quadruple[i]+='\n';
   	 }
    }
    for(int i=0;i<quadruple.size();i++)
    {
   	 final[i]+=quadruple[i];
   	 cout<<final[i];
    }

    FILE *fp;
    fp = fopen("function.txt","w");
    for(int i=1;i<functionTable.size();i++)
    {
   	 //cout<<functionTable[i].name<<" "<<functionTable[i].parList.size()<<"\n";
   	 fprintf(fp, "%s %d %d\n",functionTable[i].name.c_str(),functionTable[i].parList.size(),100);
    }

    printf("Valid Syntax\n");
} 
