with Ada.Text_IO;
use Ada.Text_IO;
procedure Main is

   MAX_SALIDA: constant := 50;
   MAX_ENTRADA:constant  := 50;
   TIEMPO_ESCRITURA:constant := 30;
   TIEMPO_ATENDER_CLIENTES:constant := 30;

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
   --Monitor monton de hojas
   protected Monton_hojas is
      entry cogerMontonEntrada;
      entry ponerMontonEntrada;
      entry ponerMontonSalida;
      entry quitarMontonSalida;
   private
     hojasMontonEntrada:Natural := 0;
      hojasMontonSalida:Natural := 0;
      numeroAleatorio: Natural := 0;
   end Monton_hojas;

   protected body Monton_hojas is
      --Coger una hoja del monton de entrada
      entry cogerMontonEntrada when hojasMontonEntrada > 0 is
          begin
             hojasMontonEntrada := hojasMontonEntrada - 1;
          end cogerMontonEntrada;

      --Poner todas las hojas del monton de entrada (solo el encargado)
      entry ponerMontonEntrada when hojasMontonEntrada = 0 is
          begin
             hojasMontonEntrada := MAX_ENTRADA;
          end ponerMontonEntrada;

      --Poner una hoja en el monton de salida
      entry ponerMontonSalida when hojasMontonSalida < MAX_SALIDA is
          begin
              hojasMontonSalida := hojasMontonSalida + 1;
          end ponerMontonSalida;

      --Quitar todas las hojas del monton de salida(solo el encargado)
      entry quitarMontonSalida when hojasMontonSalida = MAX_SALIDA is
          begin
         hojasMontonSalida := 0;
         numeroAleatorio := Generate_Number(MAX_SALIDA);
         Put_Line("Las hojas erroneas son: " + numeroAleatorio);

          end quitarMontonSalida;

   end Monton_hojas;
--------------------------------------------------------------------------------
   --Monitor oficina
   protected Oficina is
      entry abrirOficina;
      entry cerrarOficina;
      entry llegadaClientes;
      entry salidaClientes;
   private
      trabajar:Boolean:= false;
      turno:Integer := 0;
      end Oficina;
      protected body Oficina is

      --El encargado abre la oficina.
      entry abrirOficina  is
            begin
               trabajar := true;
            end abrirOficina;

         --¿Semaforo entrada clientes?
         entry llegadaClientes return Integer is
            begin
               turno := turno + 1;
               return turno;
            end llegadaClientes;

         --¿Semaforo salida clientes?
         entry salidaClientes is
            begin
                turno:= turno - 1;
            end salidaClientes;

         --El encargado cierra la oficina.
         entry cerrarOficina is
            begin
               trabajar:= false;
            end cerrarOficina;
--------------------------------------------------------------------------------

   task encargado;
   task body encargado is
      contadorHoraCierre : Integer := 0;
      begin
            while true loop

               --Mientras haya clientes el encargado los atiende.
               while Oficina.llegadaClientes > 0 loop
                  Put_Line("Atendiendo clientes");
                  delay TIEMPO_ATENDER_CLIENTES;
                     Oficina.salidaClientes;
               end loop;

               --comprueba montones de hojas
              if Monton_hojas.hojasMontonEntrada = 0 then
                  Monton_hojas.ponerMontonEntrada;
              else if Monton_hojas.hojasMontonSalida = MAX_SALIDA then
                     Monton_hojas.quitarMontonSalida;
              end if;
              contadorHoraCierre := contadorHoraCierre + 1;

               if contadorHoraCierre = 50 then --Cierre de la oficina
                  Oficina.cerrarOficina;
               end if;
          end loop;
--------------------------------------------------------------------------------
   task type Cliente is
   task Cliente body is
        begin
            Oficina.llegadaClientes;
            Oficina.salidaClientes;
        end Cliente;
--------------------------------------------------------------------------------
   task type Empleado is
   task Empleado body is
        begin
             if Oficina.trabajar = true then
                   Monton_hojas.cogerMontonEntrada;
                   Put_Line("Escribiendo hoja");
                   delay TIEMPO_ESCRITURA;
                   Monton_hojas.ponerMontonSalida;
             end if;
        end Empleado;
 -------------------------------------------------------------------------------

begin
   --  Insert code here.
   null;
end Main;
