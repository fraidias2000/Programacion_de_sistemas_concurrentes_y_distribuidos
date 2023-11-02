with Ada; use Ada;
with Ada.Numerics.Discrete_Random;
with Ada.Text_IO;
use Ada.Text_IO;
procedure Main is

   MAX_CLIENTES: constant := 15;
   MAX_MESAS: constant := 3;
   MAX_SILLAS: constant := 4;
   MAX_FICHAS:constant := 50;
   MAX_TRAGAPERRAS : constant := 5;
   MAX_REFRESCOS :constant := 2;
   MAX_PERSONAS : constant := 10;
   MAX_CLIENTES_CAFETERIA:constant := MAX_SILLAS-1;
   MAX_CLIENTES_ESPERA:constant:= MAX_SILLAS;

   TIEMPO_REPONER_FICHAS:constant:= 5.0;
   TIEMPO_REFRESCO: constant := 1.0;
   TIEMPO_TRAGAPERRAS : constant := 10.0;
   TIEMPO_LIMPIEZA_CAFETERIA:constant :=7.5;
   TIEMPO_REPONER_REFRESCOS : constant := 5.0;
   TIEMPO_CAMBIAR_FICHAS:constant := 4.5;
   TIEMPO_JUGAR_POKER: constant := 10.0;
--------------------------------------------------------------------------------
   task type Cliente(identificador: Integer) is
      entry volverPartidaPoker;
      entry puedeJugarPoker;
   end Cliente;

   task Recepcionista is
      entry pedirFichas (fichas: out Integer);
      entry cambiarFichas(id: in Integer);
   end Recepcionista;

   task  Encargado is
      entry comprobarYOcuparMesa(sillaHaSidoOcupada:in out Boolean;numeroCliente: in Integer; mesa : out Integer; ultimaSilla:out Boolean);
      entry reponerRefrescos(numeroRefrescos : out Integer);
      entry limpiarSala(cantidadPersonas : out Integer);
      entry jugarPartida(mesa:in Integer;fichas:in out Integer; idCliente:in Integer);
      entry irCafereria(mesa:in Integer; idCliente:in Integer);
      entry reservarMesa(idCliente : in Integer);
      entry llamarClientesEsperaPoker(cuenta:in Integer);
   end Encargado;

   task type Croupier(identificador: Integer) is
      entry ocuparSilla(sillaHaSidoOcupada:out Boolean;numeroCliente: in Integer; ultimo: out Boolean);
      entry jugarPartida(fichas:in out Integer; idCliente:in Integer);
      entry irCafeteria(idCliente: in Integer);
   end Croupier;

   task type Tragaperras is
      entry jugar(fichas:in out Integer; id :in Integer);
      entry liberar(id :in Integer);
   end Tragaperras;

   task Cafeteria is
      entry pedirRefresco(id:in Integer);
      entry entrarSala(id:in Integer);
      end Cafeteria;

   type CroupierAcces is access Croupier;

   type ClienteAcces is access Cliente;
   Clientes: array (1..MAX_CLIENTES) of ClienteAcces;

   miTragaperras: Tragaperras;
--------------------------------------------------------------------------------
--Funcion para hacer numeros aleatorios
  function Generate_Number (MaxValue : Integer) return Integer is
      subtype Random_Type is Integer range 1 .. MaxValue;
      package Random_Pack is new Ada.Numerics.Discrete_Random (Random_Type);
      G : Random_Pack.Generator;
  begin
      Random_Pack.Reset (G);
      return Random_Pack.Random (G);
   end Generate_Number;
--------------------------------------------------------------------------------
   task body Recepcionista is
      fichasDisponibles: Integer := MAX_FICHAS;
   begin
      loop
         select
            when fichasDisponibles > 0 => --Se bloquea mientras no haya fichas disponibles
            accept pedirFichas (fichas: out Integer) do
               if fichasDisponibles = 0 then
                  Put_Line("NO QUEDAN FICHAS, el recepcionista ha ido al almacén a por más");
                  delay TIEMPO_REPONER_FICHAS;
                  fichasDisponibles := MAX_FICHAS;
               end if;
               fichasDisponibles := fichasDisponibles - 10;
               fichas := 10;
               end pedirFichas;
         or
            accept cambiarFichas (id : in Integer) do
               Put_Line("El cliente "& Integer'Image(id) & "esta cambiando sus fichas");
               delay TIEMPO_CAMBIAR_FICHAS;
            end cambiarFichas;
         or
            terminate;
         end select;
      end loop;

   end Recepcionista;
--------------------------------------------------------------------------------
   task body Cafeteria is
      refrescosDisponibles : Integer := MAX_REFRESCOS;
      salaDisponible: Boolean := True;
      cantidadPersonas : Integer := 0;
      begin
      loop
         select
            when salaDisponible =>
               accept entrarSala (id : in Integer) do
                  cantidadPersonas :=cantidadPersonas +1;
                  if cantidadPersonas = MAX_PERSONAS then
                     salaDisponible := False;
                     Put_Line("LA CAFETERIA NECESITA SER LIMPIADA, la gente ha abandonado la sala");
                     Encargado.limpiarSala(cantidadPersonas);
                     salaDisponible := True;
                  end if;
                  Put_Line("El cliente "& Integer'Image(id) & " ha entrado en la cafeteria");
            end entrarSala;
         or
            when salaDisponible =>
            accept pedirRefresco(id:in Integer)do
               if refrescosDisponibles > 0 then
                  Put_Line("El cliente "& Integer'Image(id) & "(refrescos disponibles: " & Integer'Image(refrescosDisponibles) & " )");
                  refrescosDisponibles:= refrescosDisponibles -1;
               else
                  Encargado.reponerRefrescos(refrescosDisponibles);
                  Put_Line("REFRESCOS DISPONIBLES = " & Integer'Image(refrescosDisponibles));
                  refrescosDisponibles:= refrescosDisponibles -1;
               end if;
               Put_Line("El cliente "& Integer'Image(id) & " ha tomado un refresco");
            end pedirRefresco;
         or
            terminate;
         end select;
      end loop;
      end Cafeteria;
--------------------------------------------------------------------------------
   task body Encargado is
      mesas: array (1..MAX_MESAS) of CroupierAcces; --Vector de croupiers simbolizando las mesas que hay
      clientesEsperaPoker: array (1 .. MAX_CLIENTES_ESPERA) of Integer:= (others => 0); --Vector de gente a la espera de poder jugar una partida de poker
      iterador :Integer;
      reservaRealizada:Boolean;
     -- contador:Integer:=0;
   begin
      for i in 1..MAX_MESAS loop
         mesas(i) := new Croupier(i); --Se inicializan las mesas de los croupiers
      end loop;
      loop
         select
            accept comprobarYOcuparMesa(sillaHaSidoOcupada:in out Boolean;numeroCliente: in Integer; mesa : out Integer; ultimaSilla:out Boolean) do --sillaHaSidoOcupada devolverá true si se ha asignado una silla y numeroCliente es para decirle al croupier que cliente se ha sentado en su mesa
               Put_Line("El encargado está comprobando mesa para el cliente "& Integer'Image(numeroCliente));
               sillaHaSidoOcupada := false;
               iterador := 1;
               while not sillaHaSidoOcupada and iterador <= MAX_MESAS loop
                  mesas(iterador).ocuparSilla(sillaHaSidoOcupada,numeroCliente,ultimaSilla);--Comprueba las mesas
                  if sillaHaSidoOcupada then--Si es true es porque en esa mesa había una silla disponible
                     Put_Line("El cliente "& Integer'Image(numeroCliente) & " ha ocupado una silla de la mesa: "& Integer'Image(iterador));
                     mesa := iterador;
                  end if;
                  iterador := iterador + 1;
               end loop;
               end comprobarYOcuparMesa;
            or
               accept reponerRefrescos(numeroRefrescos : out Integer) do
                  Put_Line("El encargado ha repuesto los refrescos");
                  delay TIEMPO_REPONER_REFRESCOS;
                  numeroRefrescos := MAX_REFRESCOS;
               end reponerRefrescos;
         or
            accept limpiarSala(cantidadPersonas : out Integer)  do
               Put_Line("Encargado limpiando la sala");
               delay TIEMPO_LIMPIEZA_CAFETERIA;
               cantidadPersonas:= 0;
            end limpiarSala;
         or
            --El cliente avisa al croupier de que va a la cafeteria
            accept irCafereria (mesa : in Integer; idCliente : in Integer) do
               mesas(mesa).irCafeteria(idCliente);
            end irCafereria;
         or
            accept jugarPartida(mesa:in Integer;fichas:in out Integer; idCliente:in Integer) do
               mesas(mesa).jugarPartida(fichas,idCliente);
            end jugarPartida;
         or
            accept reservarMesa (idCliente : in Integer) do
               reservaRealizada:= false;
               iterador := 1;
               while not reservaRealizada and iterador <= MAX_CLIENTES_ESPERA loop
                  if clientesEsperaPoker(iterador) = 0 then
                     clientesEsperaPoker(iterador) := idCliente;
                     reservaRealizada:= true;
                  end if;
                  iterador := iterador + 1;
               end loop;
            end reservarMesa;
         or
            accept llamarClientesEsperaPoker (cuenta: in Integer)do
               iterador := 1;
               Put_Line("Los clientes entraran en orden de espera:");
               while clientesEsperaPoker(iterador) /= 0 and iterador <= MAX_CLIENTES_ESPERA loop
                  clientes(clientesEsperaPoker(iterador)).volverPartidaPoker;
                  iterador := iterador + 1;
               end loop;
            end llamarClientesEsperaPoker;
         or
            terminate;
         end select;
      end loop;
   end Encargado;
--------------------------------------------------------------------------------
   task body Croupier is
      id: Integer := identificador;
      contador:Integer:=0;
      meVoy: Integer:=-1;
      mesaLlena : Boolean := false;
      i:Integer:=  0;
      sillaOcupada: Boolean;
      clienteGanador : Integer :=0;
      ultimaSilla : Boolean;
      apuntado :Boolean := false;
      contador2 : Integer:= 0;
      clientesEnCafeteria: array (1 .. MAX_CLIENTES_CAFETERIA) of Integer:= (others => 0);
      sillas: array (1 .. MAX_SILLAS) of Integer:= (others => 0);-- simboliza las sillas (0 significa que está vacía)
   begin
      loop
         select
            accept ocuparSilla (sillaHaSidoOcupada:out Boolean;numeroCliente: in Integer; ultimo: out Boolean) do
               sillaOcupada := false; --Inicializamos la variable que depués se devolverá al proceso que la llamó
               Put_Line("Croupier " & Integer'Image(id) & " mirando su mesa...");
               ultimaSilla := false;
               i:= 1;
               while not sillaOcupada and i <= MAX_SILLAS and not mesaLlena loop
                     if sillas(i) = 0 then--silla disponible
                        sillas(i)  := numeroCliente; --El cliente ocupa la silla
                        sillaOcupada := true; -- Decimos que ha ocupado la silla(esta variable se devolverá al proceso que la invocó)
                        if i = MAX_SILLAS then --Es la ultima posicion del vector (si se ocupa la mesa estaría llena)
                           ultimaSilla:= true;
                           mesaLlena := true;
                           Put_Line("La mesa del croupier " & Integer'Image(id) & " se ha llenado");
                           for j in 1..MAX_CLIENTES_CAFETERIA loop --Llama a los clientes que se han ido
                              if clientesEnCafeteria(j) /= 0 then
                                 Put_Line("El Croupier "& Integer'Image(id) & " ha llamado al cliente "& Integer'Image(clientesEnCafeteria(j)));
                                 Clientes(clientesEnCafeteria(j)).volverPartidaPoker;
                              end if;
                           end loop;
                        end if;
                     end if;
                  i := i + 1;
               end loop;
               sillaHaSidoOcupada := sillaOcupada;
               ultimo := ultimaSilla;
            end ocuparSilla;
         or
              --Apunta quien se ha ido a la cafeteria
            accept irCafeteria (idCliente: in Integer) do
               i:= 1;
               apuntado := false;
               while not apuntado and i <= MAX_CLIENTES_CAFETERIA loop
                  if clientesEnCafeteria(i) = 0 then
                     clientesEnCafeteria(i):= idCliente;
                     apuntado := true;
                     Put_Line("Croupier apunta en la lista el cliente: " & Integer'Image(idCliente));
                  end if;
                  i := i+1;
               end loop;
            end irCafeteria;
         or
            accept jugarPartida (fichas:in out Integer; idCliente:in Integer)  do
               if contador = 0 then --Se decidirá quien ha ganado solo una vez
                  delay TIEMPO_JUGAR_POKER;
                  clienteGanador:= Generate_Number(4);
               end if;
               fichas := fichas - 10;
               contador:= contador + 1;
               --Crea un aleatorio entre 1 y 4
               if sillas(clienteGanador) = idCliente then --Elegimos un ganador
                     Put_Line("El cliente "& Integer'Image(idCliente) & " ha ganadado el bote en la mesa " & Integer'Image(id) );
                     fichas := fichas + 40;
               else
                 Put_Line("El cliente "& Integer'Image(idCliente) & " ha perdido su apuesta en la mesa " & Integer'Image(id) );
               end if;
               if contador=4 then
                  for i in 1..MAX_SILLAS loop
                     sillas(i):=0;
                  end loop;
                  mesaLlena:=False;
                  contador := 0; --Se reinicia el contador
                  Put_Line("Los clientes que esperaban vuelven para jugar y completar la mesa");
                  Encargado.llamarClientesEsperaPoker(contador2);
                  Put_Line("Esto no se ejecuta"& Integer'Image(meVoy));
               end if;
            end jugarPartida;
         or
            terminate;
         end select;
      end loop;
   end Croupier;
--------------------------------------------------------------------------------
     task body Cliente is
      fichas: Integer := 0;
      id: Integer := identificador;
      eleccion : Integer := 1;
      eleccion2 : Integer := 1;
      volverAJugar:Integer := 1;
      tomarRefresco : Integer := 1;
      ultimaSilla:Boolean := false;
      sillaOcupada : Boolean := False;
      mesaAsignada : Integer;
   begin
      Recepcionista.pedirFichas(fichas);
      Put_Line("El cliente " & Integer'Image(id) & " ha obtenido " & Integer'Image(fichas) & " fichas");
      while volverAJugar = 1 loop
         if fichas >= 0 then  --Sin fichas no puede jugar
            eleccion := Generate_Number(2);
            if eleccion = 1 then --Elige ir al poker
               Put_Line("El cliente " & Integer'Image(id) & " ha decidido ir al poker");
               Encargado.comprobarYOcuparMesa(sillaOcupada, id, mesaAsignada,ultimaSilla);
               if sillaOcupada = false then-- Si es false es porque no se ha ocupado una silla
                  Put_Line("TODAS LAS MESAS ESTÁN LLENAS");
                  Encargado.reservarMesa(id);
                  eleccion2 := Generate_Number(2);
                  if eleccion2 = 1 then --Elige ir a las maquinas
                     if fichas >= 10 then
                        miTragaperras.jugar(fichas,id);
                        miTragaperras.liberar(id);
                     else
                        Put_Line("El cliente "& Integer'Image(id) & " no tiene dinero para ir a la máquina tragaperras");
                        Recepcionista.pedirFichas(fichas);
                        miTragaperras.jugar(fichas,id);
                        miTragaperras.liberar(id);
                     end if;
                  else --Elige ir a la maquina de cafe
                     Cafeteria.entrarSala(id);
                     Cafeteria.pedirRefresco(id);
                  end if;
                  while not sillaOcupada loop --Se ejecuta hasta que obtiene una silla
                     accept puedeJugarPoker do --Se queda bloqueado esperando que un croupier libere una mesa
                        Encargado.comprobarYOcuparMesa(sillaOcupada, id,mesaAsignada,ultimaSilla);
                        if sillaOcupada then
                           Put_Line("Tras esperar, el cliente " & Integer'Image(id) & " ya puede jugar");
                           tomarRefresco := Generate_Number(2);
                           if tomarRefresco = 1 and not ultimaSilla then --El ultimo en sentarse no puede ir a tomar un refresco
                              Put_Line("El cliente "& Integer'Image(id) & " se ha ido a tomar un refresco");
                              Encargado.irCafereria(mesaAsignada,id);
                              delay TIEMPO_REFRESCO;
                              accept volverPartidaPoker do --Se queda bloqueado esperando a que le llame el croupier
                                 Put_Line("El cliente "& Integer'Image(id) & " vuelve a su mesa de poker para jugar");
                              end volverPartidaPoker;
                           else
                              Put_Line("El cliente "& Integer'Image(id) & " no ha ido a tomar un refresco (se queda en la mesa esperando)");
                           end if;
                        else
                           Encargado.reservarMesa(id);
                        end if;
                     end puedeJugarPoker;
                  end loop;
               else --Ocupa una silla
                    tomarRefresco := Generate_Number(2);
                  if tomarRefresco = 1 and not ultimaSilla then--El ultimo en sentarse no puede ir a tomar un refresco
                     Put_Line("El cliente "& Integer'Image(id) & " se ha ido a tomar un refresco");
                     Encargado.irCafereria(mesaAsignada,id);
                     Cafeteria.entrarSala(id);
                     Cafeteria.pedirRefresco(id);
                     accept volverPartidaPoker do --Se queda bloqueado esperando a que le llame el croupier
                        Put_Line("El cliente "& Integer'Image(id) & " vuelve a su mesa de poker para jugar");
                     end volverPartidaPoker;
                     Encargado.jugarPartida(mesaAsignada,fichas,id);--Habla con el encargado para jugar
                  else
                     Put_Line("El cliente "& Integer'Image(id) & " no ha ido a tomar un refresco (se queda en la mesa esperando)");
                     Encargado.jugarPartida(mesaAsignada,fichas,id);--Habla con el encargado para jugar
                  end if;
               end if;
            else-- Elige NOOO ir al poker
               Put_Line("El cliente " & Integer'Image(id) & " ha decidido NOOOO ir al poker");
               eleccion2 := Generate_Number(2);
               if eleccion2 = 1 then --Elige ir a las maquinas
                  if fichas >= 10 then
                     miTragaperras.jugar(fichas,id);
                     miTragaperras.liberar(id);
                  else
                     Put_Line("El cliente "& Integer'Image(id) & " no tiene dinero para ir a la máquina tragaperras");
                     Recepcionista.pedirFichas(fichas);
                     miTragaperras.jugar(fichas,id);
                     miTragaperras.liberar(id);
                  end if;
               else --Elige ir a la maquina de cafe
                  Cafeteria.entrarSala(id);
                  Cafeteria.pedirRefresco(id);
               end if;
            end if;
         else
            Put_Line("El cliente "& Integer'Image(id) &  " no tiene fichas suficientes para jugar");
            Recepcionista.pedirFichas(fichas);
         end if;
         volverAJugar := Generate_Number(2);
      end loop;
         Recepcionista.cambiarFichas(id);
         Put_Line("El cliente "& Integer'Image(id) & " se marcha con "& Integer'Image(fichas) & " EUROS");
      end Cliente;
--------------------------------------------------------------------------------
   task body Tragaperras is
      ganador: Integer :=0;
      TragaperrasDisponibles: Integer := MAX_TRAGAPERRAS;
   begin
      loop
         select
            when TragaperrasDisponibles > 0 =>
            accept jugar (fichas:in out Integer; id :in Integer) do
               TragaperrasDisponibles := TragaperrasDisponibles-1;
               Put_Line("El cliente " & Integer'Image(id) & "está jugando a la máquina tragaperras");
               Put_Line("TRAGAPERRAS DISPONIBLES: "& Integer'Image(TragaperrasDisponibles));
               delay TIEMPO_TRAGAPERRAS;
               ganador := Generate_Number(2);
               if ganador = 1 then
                  Put_Line("El cliente " & Integer'Image(id) & "ha ganado");
                  fichas := fichas + 5;
               else
                  Put_Line("El cliente " & Integer'Image(id) & "ha perdido");
                  fichas := fichas - 10;
               end if;
            end jugar;
         or
            accept liberar (id : in Integer) do
               Put_Line("El cliente " & Integer'Image(id) & " ha liberado la maquina Tragaperras");
               TragaperrasDisponibles := TragaperrasDisponibles + 1;
            end liberar;
         or
            terminate;
         end select;
      end loop;
   end Tragaperras;
--------------------------------------------------------------------------------
begin
    for i in 1..MAX_CLIENTES loop
         Clientes(i) := new Cliente(i); --Se inicializan los clientes
      end loop;
   null;
end Main;
