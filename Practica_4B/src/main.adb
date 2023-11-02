with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
procedure Main is
   MAX_EMPLEADOS_EMP:constant:= 5;
   MAX_EMPLEADOS_PAR:constant:= 5;
   MAX_EMPLEADOS:constant := 5;
   MAX_CLIENTE:constant:= 1;
   TIEMPO_ATENDER_EMP:constant:=3.0;
   TIEMPO_ATENDER_PAR:constant:=2.0;
   TIEMPO_HABLAR_JEFE:constant:= 2.0;
   TIEMPO_JEFE_MOVIL:constant:= 5.0;
--------------------------------------------------------------------------------
   task type clienteParticular(id:Natural);
   task type clienteEmpresa(id:Natural);
--------------------------------------------------------------------------------
   task Jefe is
      entry atenderEmpleado;
   end Jefe;
--------------------------------------------------------------------------------
   task type empleadoEmpresa is
      entry atender_E (id:Natural);
   end empleadoEmpresa;
--------------------------------------------------------------------------------
   task  type empleadoParticular is
      entry atender_P (id:Natural);
   end empleadoParticular;
--------------------------------------------------------------------------------
   task dispensador is
      entry pedirTurno_EMP(asig:out Natural;disponible:out Natural);
      entry pedirTurno_PAR(disponible:out Natural);
      entry liberarEmpresa;
      entry liberarParticular;
   end dispensador;
   -----------------------------------------------------------------------------
   --ARRAYS DE EMPLEADOS
   type Empleado_ParticularAccess is access empleadoParticular;
   Particulares: array (1..MAX_EMPLEADOS_PAR) of Empleado_ParticularAccess;
   type Empleado_EmpresaAccess is access empleadoEmpresa;
   Empresas: array (1..MAX_EMPLEADOS_EMP) of Empleado_EmpresaAccess;
--------------------------------------------------------------------------------
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
   task body Jefe is
   begin
      loop
            select
               accept atenderEmpleado  do
                   Put_Line("El jefe esta hablando con un empleado");
                   delay TIEMPO_HABLAR_JEFE;
               end atenderEmpleado;
            else
                 Put_Line("El jefe está hablando por telefono");
                 delay TIEMPO_JEFE_MOVIL;

            end select;
      end loop;
  end Jefe;
--------------------------------------------------------------------------------
   task body empleadoEmpresa is
      identificador:Natural;
      necesita_ver_jefe:Natural;
      Ocupado:Boolean:= false;
   begin
      loop
         select
            accept atender_E(id:Natural) do
                Ocupado:= true;
               identificador:= id;
               Put_Line("Atendiendo al cliente (Empresa) " & Integer'Image(identificador));
               delay TIEMPO_ATENDER_EMP;

               --COMPROBAR SI NECESITA HABLAR CON EL JEFE
               necesita_ver_jefe:= Generate_Number(2);
               if necesita_ver_jefe = 1 then
                  Jefe.atenderEmpleado;
               end if;
               Ocupado:= false;
            end atender_E;
         or
            terminate;
         end select;
      end loop;
   end empleadoEmpresa;
--------------------------------------------------------------------------------
   task body empleadoParticular is
   identificador:Natural;
   necesita_ver_jefe:Natural;
   Ocupado:Boolean:=false;
   begin
      loop
        select
         accept atender_P(id:Natural)  do
               Ocupado:= true;
               identificador:= id;
               Put_Line("Atendiendo al cliente (Particular) " & Integer'Image(identificador));
               delay TIEMPO_ATENDER_PAR;
               --COMPROBAR SI NECESITA HABLAR CON EL JEFE
                necesita_ver_jefe:= Generate_Number(2);
               if necesita_ver_jefe = 1 then
                  Jefe.atenderEmpleado;
                  Put_Line("Empleado Particular ha dejado de hablar con el jefe");
            end if;
            Ocupado:=false;
            end atender_P;
        or
            terminate;

        end select;
      end loop;
   end empleadoParticular;
 -------------------------------------------------------------------------------
   task body clienteEmpresa is
      asignacion:Natural;
      identificador:Natural:= id;
      NecesitaVolver_EMP:Natural:= 1;
      iterador:Natural:= 0;
   begin
      dispensador.pedirTurno_EMP(asignacion,iterador);
      --LE DICEN QUE NO HAY HUECO EN EMPRESA PERO SI EN PARTICULAR
      if asignacion = 1 then
            Particulares(iterador).atender_P(identificador);
            dispensador.liberarParticular;
         else
            Empresas(iterador).atender_E(identificador);
            dispensador.liberarEmpresa;
         end if;

      --COMPROBAR SI NECESITA VOLVER
         NecesitaVolver_EMP:= Generate_Number(2);
         if NecesitaVolver_EMP = 1 then
            Put_Line("CLIENTE EMPRESA NECESITA VOLVER");
            dispensador.pedirTurno_EMP(asignacion,iterador);
            if asignacion = 1 then
               Particulares(iterador).atender_P(identificador);
               dispensador.liberarParticular;
            else
               Empresas(iterador).atender_E(identificador);
               dispensador.liberarEmpresa;
            end if;
         end if;
   end clienteEmpresa;
--------------------------------------------------------------------------------
   task body clienteParticular is
      identificador:Natural:= id;
      NecesitaVolver_PAR:Natural:= 1;
      iterador:Natural:=0;
   begin
         dispensador.pedirTurno_PAR(iterador);
         Particulares(iterador).atender_P(identificador);
         dispensador.liberarParticular;

         --COMPROBAR SI NECESITA VOLVER
         NecesitaVolver_PAR:= Generate_Number(2);
         if NecesitaVolver_PAR = 1 then
             Put_Line("CLIENTE PARTICULAR NECESITA VOLVER");
             dispensador.pedirTurno_PAR(iterador);
             Particulares(iterador).atender_P(identificador);
             dispensador.liberarParticular;
         end if;
   end clienteParticular;
--------------------------------------------------------------------------------
   task body dispensador is
     EmpresaOcupado:Natural:= 0;
     ParticularOcupado:Natural:=0;
      iterador:Natural := 0;
      --ARRAYS DE BOOLEANOS
      type EMPRESA is array(1..MAX_EMPLEADOS) of Boolean;
      type PARTICULAR is array(1..MAX_EMPLEADOS)of Boolean;
      EMP_OCUPADOS:EMPRESA:=(others => False);
      PAR_OCUPADOS:PARTICULAR:=(others => False);
   begin
     loop
       select
         when EmpresaOcupado <= MAX_EMPLEADOS_EMP or ParticularOcupado <= MAX_EMPLEADOS_PAR =>
         accept pedirTurno_EMP (asig:out Natural;disponible:out Natural)do

               if EmpresaOcupado >= MAX_EMPLEADOS_EMP and ParticularOcupado < MAX_EMPLEADOS_PAR then
                 ParticularOcupado:= ParticularOcupado + 1;
                 Put_Line("AL CLIENTE EMPRESA AHORA LE ATIENDE EMPLEADO PARTICULAR");
                 asig:= 1;
                 --SABER QUE PARTICULAR ESTÁ DISPONIBLE
                 while PAR_OCUPADOS(iterador) = true loop
                     iterador:= iterador + 1;
                  end loop;
                  PAR_OCUPADOS(iterador):= true;
                 disponible:= iterador;
            else
                EmpresaOcupado:= EmpresaOcupado + 1;
                asig:= 0;
                --SABER QUE EMPRESA ESTÁ DISPONIBLE
                while EMP_OCUPADOS(iterador)= true loop
                   iterador:= iterador + 1;
                  end loop;
                  Empresas(iterador):= false;
                disponible:= iterador;
            end if;
       end pedirTurno_EMP;
       or
           when ParticularOcupado< MAX_EMPLEADOS_PAR =>
            accept pedirTurno_PAR (disponible:out Natural) do
               ParticularOcupado:= ParticularOcupado + 1;
               --SABER QUE PARTICULAR ESTÁ DISPONIBLE
               while PAR_OCUPADOS(iterador) = true loop
                  iterador:= iterador + 1;
               end loop;
               disponible:= iterador;
               end pedirTurno_PAR;
       or
             accept liberarEmpresa do
                 Put_Line("El cliente empresa se ha ido");
                 EmpresaOcupado:= EmpresaOcupado - 1;
             end liberarEmpresa;
       or
             accept liberarParticular do
                 Put_Line("El cliente particular se ha ido");
                 ParticularOcupado:= ParticularOcupado - 1;
             end liberarParticular;
       or
             terminate;
       end select;
     end loop;
   end dispensador;
--------------------------------------------------------------------------------
type clienteParticularAccess is access clienteParticular;
type clienteEmpresaAccess is access clienteEmpresa;
clientesParticular:array (1..MAX_CLIENTE) of clienteParticularAccess;
clientesEmpresa:array (1..MAX_CLIENTE) of clienteEmpresaAccess;

begin
   for i in 1..MAX_CLIENTE loop
      clientesParticular(i):= new clienteParticular(i);
      clientesEmpresa(i):= new clienteEmpresa(i);
   end loop;

   for i in 1.. MAX_EMPLEADOS loop
      Particulares(i) := new empleadoParticular;
      Empresas(i) := new empleadoEmpresa;
   end loop;
end Main;
