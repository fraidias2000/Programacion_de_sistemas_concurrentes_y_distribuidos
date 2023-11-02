procedure Gasolinera is
   MAX_CLIENTES:constant:=10;
   MAX_GUANTES: constant :=5;
   MAX_SURTIDORES:constant:=4;
   TIEMPO_REPOSTAR:constant:=3.0;
   TIEMPO_REPONER:constant:=2.0;
   TIEMPO_PAGAR:constant:=1.5;

   task Guantes is
      entry cogerGuantes (ok:out boolean);
      entry reponerGuantes;
   end Guantes;

   task Surtidores is
      entry ocuparSurtidor;
      entry liberarSurtidor;
   end Surtidores;

   task type Cliente(id:Natural) is
       entry subirBarrera;
   end Cliente;

   task Encargado is
      entry pagar (id:Natural);
      entry necesitaReponer(id:Natural);
   end Encargado;
--------------------------------------------------------------------------------


task body Guantes is
   guantesDisponibles:Natural:= MAX_GUANTES;
   vacio: Boolean:=false;
begin
   loop
      select
         when not vacio =>
            accept cogerGuantes (ok:out Boolean) do
               if guantesDisponibles > 0 then
                  guantesDisponibles:= guantesDisponibles - 1;
                  ok:=true;
               else
                  ok:=false;
                  vacio :=true;
               end if;
            end cogerGuantes;
      or
         accept reponerGuantes do
            guantesDisponibles:= MAX_GUANTES-1;
            vacio:=false;
         end reponerGuantes;
      or
         terminate;
      end select;
   end loop;
end Guantes;
--------------------------------------------------------------------------------
task body Surtidores is
   surtidoresDisponibles:Natural:= MAX_SURTIDORES;
begin
   loop
      select
         when surtidoresDisponibles > 0 =>
            accept ocuparSurtidor do
               surtidoresDisponibles:= surtidoresDisponibles - 1;
            end ocuparSurtidor;
      or
         accept liberarSurtidor do
            surtidoresDisponibles:= surtidoresDisponibles + 1;
         end liberarSurtidor;
      or
         terminate;
      end select;
   end loop;
   end Surtidores;
--------------------------------------------------------------------------------
   task body Encargado is
      idCliente:Natural;
   begin
      loop
         select
            accept pagar (id:Natural) do
               idCliente := id;
            end pagar;
            delay TIEMPO_PAGAR;
            Cliente(idCliente).subirBarrera;
         or
              when pagar'Count = 0 => --count te dice las llamadas pendientes por aceptar
            accept necesitaReponer (id : in Natural) do
                  idCliente:=id;
       --FALTA PONER TEXTO CLIENTE COGIENDO GUANTES
                  delay TIEMPO_REPONER;
                  Guantes.reponerGuantes;
            end necesitaReponer;
         or
            terminate;
         end select;
      end loop;
   end Encargado;
   -----------------------------------------------------------------------------
   task body Cliente is
      ok:Boolean;
      idCliente:Natural:= id;
   begin
      Guantes.cogerGuantes(ok);
      if not ok then --Si no hay guantes
         Encargado.necesitaReponer(idCliente);--Pide al encargado guantes
      end if;
      Surtidores.ocuparSurtidor;
      delay TIEMPO_REPOSTAR;
      Surtidores.liberarSurtidor;
      Encargado.pagar(idCliente);

      accept subirBarrera  do
         null;
      end subirBarrera;
      end Cliente;



   type ClienteAcess is access Cliente;
  type Clientes is array (1..MAX_CLIENTES) of ClienteAcess;

begin
   for i in 1..MAX_CLIENTES loop
      Clientes(i) := new Cliente(i);
   end loop;
end Gasolinera;
