%{
    #include <stdlib.h>
    #include <string.h>
    #include <bits/stdc++.h>
    
    #include "bison.tab.h"
    using namespace std;
    extern int lineno;
    



%}    
%option noyywrap
%%
"["   						 return LB;
"]"   						 return RB;    
"&&"   					  return AND    ;    
"||"   					  return OR;
"!"   					 return NOT;
int[' '\t]+ 					 return INT;
float[' '\t]+   				 return  FLOAT ;
\(    					  return LP;
\)   					  return RP;
"<="   					  return LE;
">="   					  return GE;
"=="   					 return EE;    
"<"    					  return LT;
">"    					  return GT;
"="    					  return EQ;
"*"   						  return STAR;
"+"   						  return PLUS;
"/"   						  return DIVIDE;    
"-"   						  return MINUS;
";"   					  return SEMI;
","   					  return COMMA;
"while"   				  return WHILE;
"for"   					 return FOR;
"{"   				 return LC;
"}"   						 return RC;   	 
"if"    					 return IF;
"else"    				 return ELSE;
"return"    				 return RETURN;
"switch"   				 return SWITCH;
"break"    				 return BREAK;
"case"   					 return CASE;
":"   						 return COLON;
"default"    				 return DEFAULT;
[a-zA-Z][a-zA-Z0-9_]*   	strcpy(yylval.idName, yytext);   return ID	;
" "   		 
"-"[0-9]+   					  yylval.val = atoi(yytext); return NUM;
[0-9]+   					 yylval.val = atoi(yytext); return NUM;   	 
[0-9]+"."[0-9]+   			 yylval.data = atof(yytext);    return DECIMAL;    
"-"[0-9]+"."[0-9]+   			 yylval.data = atof(yytext);    return DECIMAL;    
\n    							 lineno++;
%%
