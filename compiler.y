%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int yylex(void);
void yyerror(const char *s);

typedef struct Symbol {
    char* name;
    int value;
    float fvalue;
    int* array;
    int arraySize;
    char cvalue;
} Symbol;

#define MAX_SYMBOLS 100
Symbol symbolTable[MAX_SYMBOLS];
int symbolCount = 0;

int findSymbolIndex(char* name);
void addSymbol(char* name, int value, int* array, int arraySize);
int getSymbolValue(char* name);
int getArrayValue(char* name, int index);
void setArrayValue(char* name, int index, int value);
%}

%union {
    char* str;
    int num;
    float fnum;
}

%token PURNO DOSOMIK CHARACTER BOOL
%token PRINT
%token JODI OTHOBA JONNE
%token <str> IDENTIFIER
%token <num> NUM
%token <fnum> FNUM
%token ASSIGN
%token PLUS MINUS TIMES DIVIDE MOD
%token EQ NEQ LT GT LTE GTE
%token LPAREN RPAREN LBRACE RBRACE COMMA PERIOD
%token LBRACKET RBRACKET
%token COMMENT

%left PLUS MINUS
%left TIMES DIVIDE MOD
%left EQ NEQ LT GT LTE GTE
%right ASSIGN

%type <num> expression

%%

program:
    statements
    ;

statements:
    statements statement
    | statement
    ;

statement:
      PURNO declarations PERIOD { printf("Declared purno variable(s).\n"); }
    | DOSOMIK declarations PERIOD { printf("Declared dosomik variable(s).\n"); }
    | CHARACTER declarations PERIOD { printf("Declared character variable(s).\n"); }

    | IDENTIFIER ASSIGN expression PERIOD { addSymbol($1, $3, NULL, 0); printf("Assigned %d to %s\n", $3, $1); }

    | IDENTIFIER LBRACKET expression RBRACKET ASSIGN expression PERIOD {
        setArrayValue($1, $3, $6);
        printf("Assigned %d to %s[%d]\n", $6, $1, $3);
    }

    | PRINT LPAREN IDENTIFIER RPAREN PERIOD { printf("Displaying value of %s: %d\n", $3, getSymbolValue($3)); }

    | PRINT LPAREN IDENTIFIER LBRACKET expression RBRACKET RPAREN PERIOD {
        printf("Displaying %s[%d] = %d\n", $3, $5, getArrayValue($3, $5));
    }

    | JODI LPAREN expression RPAREN LBRACE statements RBRACE {
        if ($3) printf("Jodi block executed.\n");
    }

    | JODI LPAREN expression RPAREN LBRACE statements RBRACE OTHOBA LBRACE statements RBRACE {
        if ($3)
            printf("Jodi block executed.\n");
        else
            printf("Othoba block executed.\n");
    }

    | JONNE LPAREN PURNO IDENTIFIER ASSIGN expression PERIOD expression PERIOD IDENTIFIER ASSIGN expression RPAREN LBRACE statements RBRACE {
        for (int i = $6; i < $8; i++) {
            addSymbol($4, i, NULL, 0);
            printf("Jonne loop iteration i=%d\n", i);
        }
    }

    | expression PERIOD { printf("Expression result: %d\n", $1); }
    ;

declarations:
      declaration
    | declarations COMMA declaration
    ;

declaration:
      IDENTIFIER { addSymbol($1, 0, NULL, 0); }
    | IDENTIFIER ASSIGN expression { addSymbol($1, $3, NULL, 0); }
    | IDENTIFIER LBRACKET NUM RBRACKET {
          int* arr = (int*)calloc($3, sizeof(int));
          addSymbol($1, 0, arr, $3);
          printf("Declared array: %s[%d]\n", $1, $3);
      }
    ;

expression:
      expression PLUS expression { $$ = $1 + $3; }
    | expression MINUS expression { $$ = $1 - $3; }
    | expression TIMES expression { $$ = $1 * $3; }
    | expression DIVIDE expression { $$ = $3 == 0 ? (yyerror("Division by zero"), 0) : $1 / $3; }
    | expression MOD expression { $$ = $1 % $3; }

    | expression EQ expression { $$ = ($1 == $3); }
    | expression NEQ expression { $$ = ($1 != $3); }
    | expression LT expression { $$ = ($1 < $3); }
    | expression LTE expression { $$ = ($1 <= $3); }
    | expression GT expression { $$ = ($1 > $3); }
    | expression GTE expression { $$ = ($1 >= $3); }

    | NUM { $$ = $1; }
    | FNUM { $$ = (int)$1; }
    | IDENTIFIER { $$ = getSymbolValue($1); }
    | IDENTIFIER LBRACKET expression RBRACKET { $$ = getArrayValue($1, $3); }

    | LPAREN expression RPAREN { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    printf("Error: %s\n", s);
}

int main() {
    printf("Enter your program:\n");
    yyparse();
    return 0;
}

int findSymbolIndex(char* name) {
    for (int i = 0; i < symbolCount; i++) {
        if (strcmp(symbolTable[i].name, name) == 0) {
            return i;
        }
    }
    return -1;
}

void addSymbol(char* name, int value, int* array, int arraySize) {
    int index = findSymbolIndex(name);
    if (index == -1) {
        if (symbolCount < MAX_SYMBOLS) {
            symbolTable[symbolCount].name = strdup(name);
            symbolTable[symbolCount].value = value;
            symbolTable[symbolCount].array = array;
            symbolTable[symbolCount].arraySize = arraySize;
            symbolCount++;
        } else {
            printf("Symbol table full!\n");
        }
    } else {
        symbolTable[index].value = value;
    }
}

int getSymbolValue(char* name) {
    int index = findSymbolIndex(name);
    if (index != -1) {
        return symbolTable[index].value;
    } else {
        printf("Error: Symbol %s not found!\n", name);
        return 0;
    }
}

int getArrayValue(char* name, int index) {
    int i = findSymbolIndex(name);
    if (i != -1 && symbolTable[i].array && index < symbolTable[i].arraySize) {
        return symbolTable[i].array[index];
    } else {
        printf("Error: Invalid array access %s[%d]\n", name, index);
        return 0;
    }
}

void setArrayValue(char* name, int index, int value) {
    int i = findSymbolIndex(name);
    if (i != -1 && symbolTable[i].array && index < symbolTable[i].arraySize) {
        symbolTable[i].array[index] = value;
    } else {
        printf("Error: Invalid array assignment %s[%d]\n", name, index);
    }
}
