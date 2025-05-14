%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
extern FILE *yyin;
extern FILE *yyout;
int yylex(void);
void yyerror(char *);
char* newTemp();
char* newLabel();

int tempCount = 1;
int labelCount = 1;
%}

%union {
    char* str;
    struct {
        char* label2; /* For else block or end of if block */
    } labels;
}

%token LIGHTSOUT CHEQUERED PITSTOP BOOST BRAKE TURBO SLIPSTREAM TELEMETRY SECTOR THEN ELSE ENDSECTOR
%token EQ NE LT GT LE GE
%token <str> ID NUMBER
%type <str> expression term factor statement statements
%type <labels> condition

%left EQ NE LT GT LE GE
%left BOOST BRAKE
%left TURBO SLIPSTREAM

%%
program:
    LIGHTSOUT statements CHEQUERED { /* Program complete */ }
    ;

statements:
    statement
    | statements statement
    ;

statement:
    PITSTOP ID { /* Declare variable, no TAC needed */ }
    | ID '=' expression {
        fprintf(yyout, "%s = %s\n", $1, $3);
        free($3);
    }
    | TELEMETRY ID {
        fprintf(yyout, "PRINT %s\n", $2);
    }
    | TELEMETRY expression {
        fprintf(yyout, "PRINT %s\n", $2);
        free($2);
    }
    | SECTOR condition THEN statements ENDSECTOR {
        fprintf(yyout, "%s:\n", $2.label2); /* Emit label2 after statements */
        free($2.label2); /* Free label2 */
    }
    | SECTOR condition THEN statements {
        /* No goto needed; control flows naturally to after else */
        fprintf(yyout, "%s:\n", $2.label2); /* Emit label2 (start of else) */
    } ELSE statements ENDSECTOR {
        /* No end label needed; control flows naturally to next statements */
        free($<labels>2.label2); /* Free label2 */
    }
    ;

condition:
    factor EQ factor {
        char* temp = newTemp();
        fprintf(yyout, "%s = %s == %s\n", temp, $1, $3);
        free($1);
        free($3);
        char* label1 = newLabel();
        char* label2 = newLabel();
        fprintf(yyout, "if %s goto %s\n", temp, label1);
        fprintf(yyout, "goto %s\n", label2);
        fprintf(yyout, "%s:\n", label1);
        free(temp);
        $$.label2 = label2; /* Pass label2 for else block or end of if */
    }
    | factor NE factor {
        char* temp = newTemp();
        fprintf(yyout, "%s = %s != %s\n", temp, $1, $3);
        free($1);
        free($3);
        char* label1 = newLabel();
        char* label2 = newLabel();
        fprintf(yyout, "if %s goto %s\n", temp, label1);
        fprintf(yyout, "goto %s\n", label2);
        fprintf(yyout, "%s:\n", label1);
        free(temp);
        $$.label2 = label2;
    }
    | factor LT factor {
        char* temp = newTemp();
        fprintf(yyout, "%s = %s < %s\n", temp, $1, $3);
        free($1);
        free($3);
        char* label1 = newLabel();
        char* label2 = newLabel();
        fprintf(yyout, "if %s goto %s\n", temp, label1);
        fprintf(yyout, "goto %s\n", label2);
        fprintf(yyout, "%s:\n", label1);
        free(temp);
        $$.label2 = label2;
    }
    | factor GT factor {
        char* temp = newTemp();
        fprintf(yyout, "%s = %s > %s\n", temp, $1, $3);
        free($1);
        free($3);
        char* label1 = newLabel();
        char* label2 = newLabel();
        fprintf(yyout, "if %s goto %s\n", temp, label1);
        fprintf(yyout, "goto %s\n", label2);
        fprintf(yyout, "%s:\n", label1);
        free(temp);
        $$.label2 = label2;
    }
    | factor LE factor {
        char* temp = newTemp();
        fprintf(yyout, "%s = %s <= %s\n", temp, $1, $3);
        free($1);
        free($3);
        char* label1 = newLabel();
        char* label2 = newLabel();
        fprintf(yyout, "if %s goto %s\n", temp, label1);
        fprintf(yyout, "goto %s\n", label2);
        fprintf(yyout, "%s:\n", label1);
        free(temp);
        $$.label2 = label2;
    }
    | factor GE factor {
        char* temp = newTemp();
        fprintf(yyout, "%s = %s >= %s\n", temp, $1, $3);
        free($1);
        free($3);
        char* label1 = newLabel();
        char* label2 = newLabel();
        fprintf(yyout, "if %s goto %s\n", temp, label1);
        fprintf(yyout, "goto %s\n", label2);
        fprintf(yyout, "%s:\n", label1);
        free(temp);
        $$.label2 = label2;
    }
    ;

expression:
    expression BOOST term {
        char* temp = newTemp();
        fprintf(yyout, "%s = %s + %s\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    | expression BRAKE term {
        char* temp = newTemp();
        fprintf(yyout, "%s = %s - %s\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    | term {
        $$ = $1;
    }
    ;

term:
    term TURBO factor {
        char* temp = newTemp();
        fprintf(yyout, "%s = %s * %s\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    | term SLIPSTREAM factor {
        char* temp = newTemp();
        fprintf(yyout, "%s = %s / %s\n", temp, $1, $3);
        free($1);
        free($3);
        $$ = temp;
    }
    | factor {
        $$ = $1;
    }
    ;

factor:
    ID {
        $$ = $1;
    }
    | NUMBER {
        $$ = $1;
    }
    ;

%%

char* newTemp() {
    char buffer[10];
    sprintf(buffer, "t%d", tempCount++);
    return strdup(buffer);
}

char* newLabel() {
    char buffer[10];
    sprintf(buffer, "L%d", labelCount++);
    return strdup(buffer);
}

void yyerror(char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int main() {
    yyin = fopen("input.txt", "r");
    yyout = fopen("output.txt", "w");
    yyparse();
    fclose(yyin);
    fclose(yyout);
    return 0;
}