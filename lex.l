%{
#include "yacc.tab.h"
#include <string.h>
%}

%%
"lightsout"     { return LIGHTSOUT; }
"chequered"     { return CHEQUERED; }
"pitstop"       { return PITSTOP; }
"boost"         { return BOOST; }
"brake"         { return BRAKE; }
"turbo"         { return TURBO; }
"slipstream"    { return SLIPSTREAM; }
"telemetry"     { return TELEMETRY; }
"sector"        { return SECTOR; }
"then"          { return THEN; }
"else"          { return ELSE; }  /* Add ELSE token */
"endsector"     { return ENDSECTOR; }
[a-zA-Z][a-zA-Z0-9]* { yylval.str = strdup(yytext); return ID; }
[0-9]+          { yylval.str = strdup(yytext); return NUMBER; }
"="             { return '='; }
"=="            { return EQ; }
"!="            { return NE; }
"<"             { return LT; }
">"             { return GT; }
"<="            { return LE; }
">="            { return GE; }
[ \t\n]+        { /* Ignore whitespace */ }
.               { printf("Unknown character: %s\n", yytext); return yytext[0]; }
%%

int yywrap() {
    return 1;
}