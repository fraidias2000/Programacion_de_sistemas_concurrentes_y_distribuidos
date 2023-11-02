with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
procedure Gestoria is
   MAX_EMPLEADOS_PAR:constant:=5;
   MAX_EMPLEADOS_EMP:constant:= 5;
   MAX_CLIENTES:constant :=10;
   TIEMPO_HABLAR_JEFE:constant:= 3.0;
   TIEMPO_DESCANSO:constant:= 2.0;
   TIEMPO_ATENDER:constant:= 1.0;

   task type ClienteParticular(id:Natural) is
      entry liberarParticular;
   end ClienteParticular;

   task type ClienteEmpresa(id:Natural)is
       entry liberarEmpresa;
   end ClienteEmpresa;

   task  dispensador is
      entry pedirEmpleado(categoria:Boolean);
   end dispensador;

   task type EmpleadoEmpresa is
      entry atenderClienteEmpresa;
   end EmpleadoEmpresa;

   task type EmpleadoParticular is
      entry atenderClienteParticular;
   end EmpleadoParticular;


 -------------------------------------------------------------------------------
   --Funcion para hacer numeros aleatorios
   function Generate_Number (MaxValue : Integer) return Integer is
   subtype Random_Type is Integer range 0 .. MaxValue;
   package Random_Pack is new Ada.Numerics.Discrete_Random (Random_Type);
   G : Random_Pack.Generator;
   begin
      Random_Pack.Reset (G);
      return Random_Pack.Random (G);
   end Generate_Number;
--------------------------------------------------------------------------------
   task body dispensador is
      ColaParticular: Natural :=0;
      ColaEmpresa: Natural := 0;
      cat:Boolean;
   begin
      loop
         select
            when ColaParticular< MAX_EMPLEADOS_PAR and ColaEmpresa < MAX_EMPLEADOS_EMP =>
               accept pedirEmpleado (categoria : in Boolean) do
                   cat:= categoria;

                if cat = true then
                       ColaParticular := ColaParticular + 1;
                   end if;

                   --Si el cliente es de empresa pero empresa esta lleno
                   if ColaEmpresa >= MAX_EMPLEADOS_EMP and ColaParticular < MAX_EMPLEADOS_PAR then
                      ColaParticular:= ColaParticular + 1;
                      cat:= true;
                   end if;

                   if cat = false then
                       ColaEmpresa:= ColaEmpresa + 1;
                   end if;
               end pedirEmpleado;
         or
            terminate;
         end select;
      end loop;
   end dispensador;
--------------------------------------------------------------------------------
   task Jefe is
      entry atenderEmpleado;
   end Jefe;

   task body Jefe is
   begin
      loop
         if atenderEmpleado'Count = 0 then --Si no llaman al jefe se pone con el movil
            Put_Line("El jefe está hablando por telefono");
         else
            accept atenderEmpleado  do
               Put_Line("El jefe esta hablando con un empleado empresa");
               delay TIEMPO_HABLAR_JEFE;
            end atenderEmpleado;

              or
                terminate;
         end if;
      end loop;
  end Jefe;
--------------------------------------------------------------------------------
   task body EmpleadoParticular is
      begin
      loop
         select
            accept atenderClienteParticular  do
               null;
            end atenderClienteParticular;
         or
            terminate;
         end select;
      end loop;
   end EmpleadoParticular;
--------------------------------------------------------------------------------
   task body EmpleadoEmpresa is
   begin
      loop
         select
            accept atenderClienteEmpresa  do
               null;
            end atenderClienteEmpresa;
         or
            terminate;
         end select;
      end loop;

      end EmpleadoEmpresa;
--------------------------------------------------------------------------------
task body ClienteParticular is
      NecesitaVolver:Natural;
      idCliente:Natural:=id;

   begin
      buzon.pedirParticular;
      buzon.atenderClienteParticular;
      delay TIEMPO_ATENDER;
      buzon.liberarParticular;
--COMPROBAR SI NECESITA VOLVER
      NecesitaVolver:= Generate_Number(2);
      if NecesitaVolver = 1 then
         buzon.pedirParticular;
         buzon.atenderClienteParticular;
      end if;
   end ClienteParticular;
--------------------------------------------------------------------------------
task body ClienteEmpresa is
   NecesitaVolver:Natural;
   begin
      buzon.pedirEmpresa;
      buzon.atenderClienteEmpresa;
      delay TIEMPO_ATENDER;
      --COMPROBAR SI NECESITA VOLVER
      NecesitaVolver:= Generate_Number(2);
      if NecesitaVolver = 1 then
         buzon.pedirEmpresa;
         buzon.atenderClienteEmpresa;
      end if;
end ClienteEmpresa;
--------------------------------------------------------------------------------
type ClienteAcess is access ClienteParticular;
type ClientesPAR is array (1..MAX_CLIENTES) of ClienteAcess;
begin
   for i in 1..MAX_CLIENTES loop
      ClientesPAR(i) := new ClienteParticular(i);
   end loop;
   end Gestoria;
