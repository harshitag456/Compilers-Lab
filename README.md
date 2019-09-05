# Compilers-Lab
A compiler for C like Language.

Flex is used for Lexical Analysis and Bison is used for syntax and semantic Analysis.

The language supports arithmetic, relational, logical operators( with short-circuiting), iterative and conditional statements(with nesting), functions, primitive data types.


# How to Run
These are the commands to be executed :-
-  1. bison -d bison.y 
-  2. flex flex.l
-  3. g++ -std=c++11 bison.tab.c lex.yy.c
-  4. ./a.out < input.cpp 

bison.tab.c and lex.yy.c files are automatically generated from the execution of first two commands.

input.cpp is the name of the file containing C language code which is to be compiled.


