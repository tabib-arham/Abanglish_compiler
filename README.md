
# Abanglish Compiler

A simple yet powerful compiler for the Abanglish language, built using *Lex* and *Bison*. This project is a demonstration of how a hybrid language (English + Bangla) can be parsed using classic compiler construction tools.

## 🚀 Features

- Lexical analysis using *Flex*
- Syntax parsing using *Bison*
- Support for a basic grammar of Abanglish
- Error handling for invalid tokens and grammar mismatches
- Modular and extendable source code

## 🔧 Technologies Used

- Lex (Flex)
- Bison (Yacc-compatible parser generator)
- GCC (for compiling C code)


To run the compiler sample code in cmd
flex src/abanglish.l
bison -d src/abanglish.y
gcc lex.yy.c abanglish.tab.c src/main.c -o abanglish
