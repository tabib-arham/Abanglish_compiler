%{
#include "compiler.tab.h"
#include <string.h>
%}

%%

"purno"     { return PURNO; }
"dosomik"   { return DOSOMIK; }
"character" { return CHARACTER; }
"bool"      { return BOOL; }

"print"     { return PRINT; }
"jodi"      { return JODI; }
"othoba"    { return OTHOBA; }
"jonne"     { return JONNE; }

"true"      { yylval.num = 1; return NUM; }
"false"     { yylval.num = 0; return NUM; }

"="         { return ASSIGN; }
"=="        { return EQ; }
"!="        { return NEQ; }
"<"         { return LT; }
"<="        { return LTE; }
">"         { return GT; }
">="        { return GTE; }

"+"         { return PLUS; }
"-"         { return MINUS; }
"*"         { return TIMES; }
"/"         { return DIVIDE; }
"%"         { return MOD; }

","         { return COMMA; }
"("         { return LPAREN; }
")"         { return RPAREN; }
"{"         { return LBRACE; }
"}"         { return RBRACE; }
"."         { return PERIOD; }
"["         { return LBRACKET; }
"]"         { return RBRACKET; }

"^"([^\\^])*"^"     { /* Ignore comment */ }

[0-9]+\.[0-9]+      { yylval.fnum = atof(yytext); return FNUM; }
[0-9]+              { yylval.num = atoi(yytext); return NUM; }

\'[a-zA-Z0-9]\'      { yylval.num = yytext[1]; return NUM; }

[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }

[ \t\n]+            { /* Ignore whitespace */ }
.                   { return yytext[0]; }

%%

int yywrap(void) {
    return 1;
}
