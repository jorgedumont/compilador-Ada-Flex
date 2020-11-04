%{
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>    
#include <string.h>
#include "symtab.h"
#include "AST.h"

extern FILE *yyin;
extern FILE *yyout;

int globalError =0;
char *globalTipo;


//-----NUMEROS-----

add_SymNum ( char *sym_name, int sym_val, char *sym_type ) {  
symrec *s;
   s = getsymNum (sym_name,sym_val);
   if (s == 0){
        s = putsymNum (sym_name,sym_val, sym_type);
        printf( "%s no esta definida, es %d. (tipo=%s)\n", sym_name, sym_val, sym_type );
   }else {
          printf( "%s ya esta definida, es %d. (tipo=%s)\n", sym_name, sym_val, sym_type );
   }
}

Update_SymNum( char *sym_name, int sym_val ){ 
symrec *act;

  if ( getsymNum( sym_name, sym_val ) == 0 ) {
     printf( "%s no esta en la lista, es %d\n", sym_name, sym_val );
  }else{
     act = updatesymNum( sym_name, sym_val); 
     printf( "%s se actualiza a: %d\n", act->name, act->num );
  }
}

//-----TEXTOS-----

add_SymText ( char *sym_name, char *sym_text, char *sym_type ) {  
symrec *s;
   s = getsymText (sym_name,sym_text);
   if (s == 0){
        s = putsymText (sym_name,sym_text, sym_type);
        printf( "%s no esta definida, es %s. (tipo=%s) \n", sym_name, sym_text, sym_type );
   }else {
          printf( "%s ya esta definida, es %s. (tipo=%s) \n", sym_name, sym_text, sym_type );
   }
}

Update_SymText( char *sym_name, char *sym_text  ){ 
symrec *act;

  if ( getsymText( sym_name, sym_text ) == 0 ) {
     printf( "%s no esta en la lista, es %d\n", sym_name, sym_text );
  }else{
     act = updatesymText( sym_name, sym_text); 
     printf( "%s se actualiza a: %s\n", act->name, act->text );
  }
}




%}

%token MAS, MENOS, POR, DIV, PAR_I, PAR_D, IF, THEN, MAYOR_Q, MENOR_Q, ELSE, SALTOLINEA, PROCEDURE, IS, END, BEGINN, DOSPUNTOS, INTEGER, FLOAT, STRING, BOOLEAN, IDENTIFICADORSIMB, PIZQ_COM, DOSPUNTOS_IGUAL, PDECH_COM, PUTLINE, ENDIF, TRUE, FALSE, COMENTARIO, WHILE, LOOP, ENDLOOP, IGUAL, FOR, IN, RANGO, FUNCION, RETURN
%token <number> NUMENTERO
%type<snum> nombreF declaracion calc expr Fun
%token <numberf> NUMREAL
%token <string> IDENTIFICADOR


%union {
        int number;
        double numberf;
        char *string;
	struct {
     		char *tipo;
    		int valor;
    		double valord;
    		char *texto;
		struct ast *a;

  		} snum;

}





%start programa
%%

programa : cuerpo {fprintf(yyout, "TODO OK");}
;

cuerpo : inicio SALTOLINEA sentencias fin
;


inicio : PROCEDURE nombreI IS {fprintf(yyout, "Inicio -> procedure\n");}
;

fin : END nombreF {fprintf(yyout, "Final -> end\n");}
;

nombreI: IDENTIFICADOR {fprintf(yyout, "Nombre Inicio\n"); add_SymText ( "Nombre", $1, "string" )}
;


nombreF: IDENTIFICADOR {
	fprintf(yyout, "Nombre Final\n");

	if (strcmp($1, getvalsymText("Nombre")) == 0) {
		printf("CORRECTO - Coinciden los nombres");
	} else {
		printf("ERROR - No es igual el nombre del inicio y el del final");
	}
	
}
;

sentencias : declaraciones SALTOLINEA comienzo SALTOLINEA sentencia SALTOLINEA 
;


comienzo: BEGINN {fprintf(yyout, "Comienzo -> begin\n");}
;


declaraciones : declaraciones SALTOLINEA declaracion
	| declaracion 
;

declaracion : IDENTIFICADOR DOSPUNTOS tipo { 
	printf("Se declara la variable: %s \n", $1);
	$$.texto = $1; add_SymText ( $$.texto, $$.texto, globalTipo);
}
;


tipo: INTEGER {globalTipo= "entero"; fprintf(yyout, "Declaracion -> int\n");}
      |FLOAT { globalTipo= "float"; fprintf(yyout, "Declaracion -> float\n");}
      |STRING {globalTipo= "string"; fprintf(yyout, "Declaracion -> string\n");}
      |BOOLEAN {globalTipo= "boolean"; fprintf(yyout, "Declaracion -> boolean\n");}
;

sentencia : sentencia SALTOLINEA expr 
	| expr
;

expr: IDENTIFICADOR  DOSPUNTOS_IGUAL calc {
	$$.texto= $1;

	if (globalError ==0) { //No hay errores
		if (getvalsymText($$.texto) == 0 ) {
			printf("ERROR - No se ha declarado la variable: %s \n", $$.texto);

		} else {
			printf("CORRECTO - Se ha declarado la variable: %s \n", $$.texto);
	 		add_SymNum( $1, eval($3.a), globalTipo);
			Update_SymNum( $1, eval($3.a) ); 
			printf("RESULTADO - De %s: %4.4g\n", $1, eval($3.a));
		}
	} else { //HAY 
		globalError =0;
	}
		

      }
      |sentencia_if {fprintf(yyout, "Sentencia IF\n");}
      |PUTLINE PIZQ_COM IDENTIFICADOR PDECH_COM {fprintf(yyout, "Put_Line\n");}
      |IDENTIFICADOR DOSPUNTOS_IGUAL factor {fprintf(yyout, "Asignacion\n");}
      |COMENTARIO IDENTIFICADOR {fprintf(yyout, "Comentario\n");}
      |bucle_while {fprintf(yyout, "Bucle WHILE\n");}
      |bucle_for {fprintf(yyout, "Bucle FOR\n");}
      |funcion {fprintf(yyout, "FUNCION\n");}
;
/*ARBOL*/
calc:  calc MAS calc { 
		printf("Suma\n");
		if (globalError ==0) { //No hay errores
			if (($1.tipo == "entero") && ($3.tipo == "entero")) {
				$$.a = newast('+', $1.a,$3.a); 
				globalTipo = $1.tipo;
				//printf("Suma (tipo=%s)\n", $$.tipo);
			} 
			else if (($1.tipo == "real") && ($3.tipo == "real")){
				$$.a = newast('+', $1.a,$3.a); 
				globalTipo = $1.tipo;
				//printf("Suma (tipo=%s)\n", $$.tipo);
			} 
			else if (($1.tipo == "string")){
				$$.a = newast('+', $1.a,$3.a); 
				globalTipo = $3.tipo;
				//printf("Suma (tipo=%s)\n", $$.tipo);
			} 
			else if (($3.tipo == "string")){
				$$.a = newast('+', $1.a,$3.a); 
				globalTipo = $1.tipo;
				//printf("Suma (tipo=%s)\n", $$.tipo);

			}
		} else {
			printf("HAY ERRORES NO SE REALIZA LA SUMA\n");

		}


	}
	|  calc MENOS calc { 
		printf("Resta\n");
		if (globalError ==0) { //No hay errores
			if (($1.tipo == "entero") && ($3.tipo == "entero")) {
				$$.a = newast('-', $1.a,$3.a); 
				//printf("Resta (tipo=%s)\n", $$.tipo);
			} 
			else if (($1.tipo == "real") && ($3.tipo == "real")){
				$$.a = newast('-', $1.a,$3.a); 
				//printf("Resta (tipo=%s)\n", $$.tipo);
			} 
			else if (($1.tipo == "string")){
				$$.a = newast('-', $1.a,$3.a); 
				//printf("Resta (tipo=%s)\n", $$.tipo);
			} 
			else if (($3.tipo == "string")){
				$$.a = newast('-', $1.a,$3.a); 
				//printf("Resta (tipo=%s)\n", $$.tipo);
			}
		}  else {
			printf("HAY ERRORES NO SE REALIZA LA RESTA\n");

		}

	}
	|  calc POR calc { 
		printf("Multiplicacion\n");

		if (globalError ==0) { //No hay errores
			if (($1.tipo == "entero") && ($3.tipo == "entero")) {
				$$.a = newast('*', $1.a,$3.a); 
				//printf("Mult (tipo=%s)\n", $$.tipo);
			} 
			else if (($1.tipo == "real") && ($3.tipo == "real")){
				$$.a = newast('*', $1.a,$3.a); 
				//printf("Mult (tipo=%s)\n", $$.tipo);
			} 
			else if (($1.tipo == "string")){
				$$.a = newast('*', $1.a,$3.a); 
				//printf("Mult (tipo=%s)\n", $$.tipo);


			} 
			else if (($3.tipo == "string")){
				$$.a = newast('*', $1.a,$3.a); 
				//printf("Mult (tipo=%s)\n", $$.tipo);
			}
		} else {
			printf("HAY ERRORES NO SE REALIZA LA MULTIPLICACION\n");

		}

	}

	|   calc DIV calc {
		printf("Division\n");

		if ($3.valor == 0) { //No se puede dividir entre 0
			globalError =1;
		}

		if (globalError ==0) { //No hay errores
			if (($1.tipo == "entero") && ($3.tipo == "entero")) {
				$$.a = newast('/', $1.a,$3.a); 
				//printf("Div (tipo=%s)\n", $$.tipo);
			} 
			else if (($1.tipo == "real") && ($3.tipo == "real")){
				$$.a = newast('/', $1.a,$3.a); 
				//printf("Div (tipo=%s)\n", $$.tipo);
			} 
			else if (($1.tipo == "string")){
				$$.a = newast('/', $1.a,$3.a); 
				//printf("Div (tipo=%s)\n", $$.tipo);


			} 
			else if (($3.tipo == "string")){
				$$.a = newast('/', $1.a,$3.a); 
				//printf("Div (tipo=%s)\n", $$.tipo);

			}
		}else {
			printf("HAY ERRORES NO SE REALIZA LA DIVISION\n");
		}

	}
	| NUMENTERO { $$.a= newnum($1); $$.valor = $1; $$.tipo = "entero";  }
	| NUMREAL {$$.a= newnum($1); $$.valord = $1; $$.tipo = "real";}
	| IDENTIFICADOR {
		printf("variable\n");
		$$.tipo = "string";

		if (getvalsymText($1) == 0 ) {
			globalError = 1;
			printf("ERROR - Variable no existe: %s \n", $1);

		} else {
			globalError = 0;
			$$.valor = getvalsymNum($1);
			$$.a= newnum($$.valor);
			printf("CORRECTO - Variable si existe: %s \n", $1);		
		}
	}
;


funcion: FUNCION nombreFuncion PAR_I declaraciones PAR_D RETURN tipo IS SALTOLINEA BEGINN SALTOLINEA  sentencia SALTOLINEA Fun SALTOLINEA END
;

nombreFuncion: IDENTIFICADOR {
	if (getvalsymNum($1) == 0 ) {
		add_SymNum($1, 1 , "string");
		printf("CORRECTO - No existe ninguna función con ese nombre\n");		
	} else {
		printf("ERROR - Existe ya una funcion con ese nombre\n");		
	}
	fprintf(yyout, "Nombre funcion\n");
}  
;

Fun: RETURN IDENTIFICADOR {

	if (getvalsymText($2) == 0 ) {
		printf("ERROR - No se ha declarado la variable: %s \n", $2);
	} else {
		printf("Tiene al menos un return\n");
		if (strcmp(globalTipo, gettypesymText($2)) == 0) {
			printf("CORRECTO - Coincide el tipo de return\n");		
		} else {
			printf("ERROR - No coincide el tipo de return\n");		
		}

	}


} 
;



factor: NUMENTERO {fprintf(yyout, "  factor--> NUMENTERO(%d)\n", $1);}
	| NUMREAL {fprintf(yyout, "  factor--> NUMREAL(%f)\n"), $1;}
	|IDENTIFICADOR {fprintf(yyout, "  factor --> variable(%s)\n", $1);}
	|TRUE {fprintf(yyout, "  factor --> True\n");}
	|FALSE {fprintf(yyout, "  factor --> False\n");}
;


sentencia_if: IF condicion THEN SALTOLINEA sentencia SALTOLINEA ENDIF
	| IF condicion THEN SALTOLINEA sentencia SALTOLINEA ELSE SALTOLINEA sentencia SALTOLINEA ENDIF 


;

bucle_while: WHILE condicion LOOP SALTOLINEA sentencia SALTOLINEA ENDLOOP
;

bucle_for: FOR factor IN rangos LOOP SALTOLINEA sentencia SALTOLINEA ENDLOOP
;

rangos: factor RANGO factor {fprintf(yyout, "Variable\n");}
;

condicion: factor MAYOR_Q factor {fprintf(yyout, "Condicion\n");}
	| factor MENOR_Q factor {fprintf(yyout, "Condicion\n");}
	| factor IGUAL factor {fprintf(yyout, "Condicion\n");}
;


%%
int main(int argc, char *argv[]) {

if (argc == 1) {
	yyparse();
}
if (argc == 2) {
	yyout = fopen( "./salidaAda.txt", "wt" );

	yyin = fopen(argv[1], "rt");

	yyparse();
}

return 0;
}


yyerror()
{ 
} 
