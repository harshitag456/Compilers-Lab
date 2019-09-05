/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_BISON_TAB_H_INCLUDED
# define YY_YY_BISON_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    MUL = 258,
    PROJECT = 259,
    CARTESIAN_PRODUCT = 260,
    EQUI_JOIN = 261,
    AND = 262,
    OR = 263,
    NOT = 264,
    LP = 265,
    RP = 266,
    LE = 267,
    GE = 268,
    LT = 269,
    GT = 270,
    EQ = 271,
    SEMI = 272,
    NUM = 273,
    QUO = 274,
    ID = 275,
    DOT = 276,
    STRING = 277,
    COMMA = 278,
    STAR = 279,
    MINUS = 280,
    PLUS = 281,
    DIV = 282,
    INT = 283,
    FLOAT = 284,
    WHILE = 285,
    LC = 286,
    RC = 287,
    FOR = 288,
    EE = 289,
    DECIMAL = 290,
    DIVIDE = 291,
    IF = 292,
    ELSE = 293,
    RETURN = 294,
    LB = 295,
    RB = 296,
    SWITCH = 297,
    BREAK = 298,
    COLON = 299,
    CASE = 300,
    DEFAULT = 301
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED

union YYSTYPE
{
#line 34 "bison.y" /* yacc.c:1909  */

    char idName[100];
    struct Node *n;
    int val;
    float data;

#line 108 "bison.tab.h" /* yacc.c:1909  */
};

typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_BISON_TAB_H_INCLUDED  */
