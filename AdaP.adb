procedure Hello is
	Numero :Integer;
	Marcos :Integer;
	Paula :Integer;
	Letra :String;
	Decimal :Float;
	Flag :Boolean;
	Edad :Integer;
	Igual :Integer;


begin	
	Igual :=  3 + Vacio;
	Edad := 5.4 + 20.5 - 1.2;
	Edad := 20 + 20 / 2;
	Rosa := Edad * 10 - 5;
	Edad := 200 - Edad;
	Numero := 10;
	Edad := Numero * 5;
	Juan := 8 / 4;
	Paula := Edad + 5;
	Marcos := Paula;

	function Funcion1 (Edad :Integer) return Integer is
	begin
		Put_Line("Mayor");
		Rosa := 200 - 5;
		return Edad;
	end


	function Funcion2 (Edad :Integer) return Integer is
	begin
		Put_Line("Mayor");
		Rosa := 200 - 5;
		return Rosa;

	end

	function Funcion1 (Edad :Integer) return Integer is
	begin
		Put_Line("Mayor");
		Rosa := 200 - 5;
		return Paula;

	end

	function Funcion3 (Edad :Integer) return Integer is
	begin
		Put_Line("Mayor");
		Rosa := 200 - 5;
		return Igual;

	end

	Put_Line("Hola");
	while Numero > 10 loop
		--BucleWhile
	end loop;

	for Numero in 1..10 loop
		--BucleFor
	end loop;

	if Suma < 10 then
		Put_Line("Menor");
		Numero := 30 - 5;
	else
		--Hola
	    	Igual := Edad;
	end if;
	Put_Line("Adios");
end Hello