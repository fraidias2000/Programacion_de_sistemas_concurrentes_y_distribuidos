with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;

procedure Gasolinera is

	MAX_GUANTES: constant := 3;
	MAX_SURTIDORES: constant := 4;
	MAX_CLIENTES: constant := 20;

	-- Constantes de tiempo
	TIEMPO_REPOSTAR: constant := 3.0;
	TIEMPO_PAGAR: constant := 3.0;
	TIEMPO_REPONER: constant := 1.5;
	TIEMPO_DESCANSAR: constant := 4.0;

	-- Monitor de los guantes usados por los clientes
	protected Guantes is
		entry CogerGuantes;
		function NecesitaReponer return Boolean;
		procedure Reponer;
	private
		-- Numero de guantes disponibles
		guantDisp: Natural := MAX_GUANTES;
	end Guantes;

	protected body Guantes is

		entry CogerGuantes when guantDisp > 0 is
		begin
			guantDisp := guantDisp - 1;
		end CogerGuantes;

		function NecesitaReponer return Boolean is
		begin
			if guantDisp = 0 then
				return true;
			else
				return false;
			end if;
		end NecesitaReponer;

		procedure Reponer is
		begin
			guantDisp := MAX_GUANTES;
		end Reponer;

	end Guantes;
--------------------------------------------------------------------------------
	-- Monitor de los surtidores
	protected Surtidores is
		entry OcuparSurtidor;
		procedure LiberarSurtidor;
	private
		-- Numero de surtidores libres
		surtLibres: Natural := MAX_SURTIDORES;
	end Surtidores;

	protected body Surtidores is

		entry OcuparSurtidor when surtLibres > 0 is
		begin
			surtLibres := surtLibres - 1;
		end OcuparSurtidor;

		procedure LiberarSurtidor is
		begin
			surtLibres := surtLibres + 1;
		end LiberarSurtidor;

	end Surtidores;
-------------------------------------------------------------------------------------------------------------------
	-- Monitor de la caja
	protected Caja is
		procedure Entrar;
		entry PagarYSubirBarrera;
		function HayGente return Boolean;
		entry Cobrar;
	private
		-- Numero de personas que hay esperando en la caja
		esperando: Natural := 0;
		-- Indica si el encargado acaba de terminar de cobrar a un cliente
		pagado: Boolean := false;
	end Caja;

	protected body Caja is

		procedure Entrar is
		begin
			esperando := esperando + 1;
		end Entrar;

		entry PagarYSubirBarrera when pagado is
		begin
			pagado := false;
		end PagarYSubirBarrera;

		function HayGente return Boolean is
		begin
			if esperando > 0 then
				return true;
			else
				return false;
			end if;
		end HayGente;

		entry Cobrar when not pagado is
		begin
			pagado := true;
			esperando := esperando - 1;
		end Cobrar;

	end Caja;
-----------------------------------------------------------------------------------------------------------------------------
	-- Tarea del encargado
   	task Encargado;

	task body Encargado is
		-- Indica si hay que reponer los guantes
		repGuantes: Boolean := false;
		-- Indica si hay alguien en la caja esperando para pagar
		esperaCaja: Boolean := false;
	begin
		loop
			Put_Line("El encargado se va a descansar.");
			delay TIEMPO_DESCANSAR;
			loop
				esperaCaja := Caja.HayGente;
				exit when not esperaCaja; --Se sale del bucle si no hay gente en la caja
				Put_Line("El encargado esta cobrandole a un cliente.");
				delay TIEMPO_PAGAR;
				Put_Line("El encargado ha terminado de cobrarle a un cliente y va a subirle la barrera.");
				Caja.Cobrar;
			end loop;
			repGuantes := Guantes.NecesitaReponer; --Miramos si necesitamos reponer
			if repGuantes then
				Put_Line("El encargado va a reponer los guantes porque se han agotado.");
				delay TIEMPO_REPONER;
				Guantes.Reponer;
			end if;
		end loop;
	end Encargado;
------------------------------------------------------------------------------------------------------------------------------------
	-- Tarea de los clientes
	task type Cliente (id: Natural);

   	task body Cliente is
    begin
      	Put_Line("El cliente" & Integer'Image(id) & " ha llegado a la gasolinera y va a situarse en un surtidor libre.");
		Surtidores.OcuparSurtidor;
		Put_Line("El cliente" & Integer'Image(id) & " se ha colocado en un surtidor y va a coger un par de guantes.");
		Guantes.CogerGuantes;
		Put_Line("El cliente" & Integer'Image(id) & " ha cogido un par de guantes y va a repostar.");
		delay TIEMPO_REPOSTAR;
		Put_Line("El cliente" & Integer'Image(id) & " ha terminado de repostar.");
		Surtidores.LiberarSurtidor;
		Put_Line("El cliente" & Integer'Image(id) & " va a entrar a la caja.");
		Caja.Entrar;
		Put_Line("El cliente" & Integer'Image(id) & " va a hacer cola para pagar.");
		Caja.PagarYSubirBarrera;
		Put_Line("El cliente" & Integer'Image(id) & " ha abandonado la gasolinera.");
	end Cliente;

	-- Vector de clientes
	type ClienteAccess is access Cliente;
	Clientes: array (1..MAX_CLIENTES) of ClienteAccess;


begin

	for i in 1..MAX_CLIENTES loop
		Clientes(i) := new Cliente(i);
		if i mod 2 = 0 then
			delay 2.0;
		else
			delay 1.5;
		end if;
	end loop;

end Gasolinera;

