with Ada.Text_IO, Ada.Integer_Text_IO;
use Ada.Text_IO, Ada.Integer_Text_IO;
procedure Main is
   TIEMPO_IMPRESO:constant:= 3.0;
   TIEMPO_PAGAR:constant := 4.0;

protected mostrador is
      entry cogerBoli;
      procedure dejarBoli;
private
    bolisDisp: Natural:= 3;
   end mostrador;
protected body mostrador is
begin
      entry cogerBoli when bolisDisp > 0 is
         bolisDisp:= bolisDisp - 1;
      end cogerBoli;

      procedure dejarBoli is
         bolisDisp:= bolisDisp + 1;
      end dejarBoli;
end mostrador;
--------------------------------------------------------------------------------
protected ventanilla is
      function asignarVentanilla return Natural;
      entry pagar1;
      entry pagar2;
      entry irBuzon;
   private
      esperandoVentanilla1, esperandoVentanilla2, asignacion: Natural:= 0;
      pagado1, pagado2: Boolean := false;
end ventanilla;

protected body ventanilla is
begin
      function asignarVentanilla return natural is
         if esperandoVentanilla2 > esperandoVentanilla1 then
            asignacion := 1;
            esperandoVentanilla1:= esperandoVentanilla1 + 1;
         else
            asignacion := 2;
            esperandoVentanilla2:= esperandoVentanilla2 + 1;
         end if;
         return asignacion;
      end asignarVentanilla;

      entry pagar1 when not pagado is
         pagado1:= true;
         esperandoVentanilla1:= esperandoVentanilla1 - 1;
      end pagar;

       entry pagar2 when not pagado is
         pagado2:= true;
         esperandoVentanilla2:= esperandoVentanilla2 - 1;
       end pagar;

      entry irBuzon when pagado1 or pagado2 is
         if pagado1 then
            pagado1:= false;
            Put_Line("El cliente de la ventanilla 1 va al buzon");
         else
            pagado2:= false;
            Put_Line("El cliente de la ventanilla 2 va al buzon");
      end irBuzon;
end ventanilla;
--------------------------------------------------------------------------------

   task type Cliente (id: Natural);
      task body Cliente is
         asignacion :Natural:= 0;
   begin
      mostrador.cogerBoli;
      Put_Line("El cliente" & Integer'Image(id) & " va a hacer rellenar el impreso");
      delay TIEMPO_IMPRESO;
         mostrador.dejarBoli;
         asignacion := ventanilla.asignarVentanilla;
         if asignacion = 1 then
            ventanilla.pagar1;
            delay TIEMPO_PAGAR;
            Put_Line("El cliente" & Integer'Image(id) & " ha pagado en la ventanilla 1");
         else
            ventanilla.pagar2;
            delay TIEMPO_PAGAR;
            Put_Line("El cliente" & Integer'Image(id) & " ha pagado en la ventanilla 2");
         end if;
         ventanilla.irBuzon;
   end Cliente;

begin
   --  Insert code here.
   null;
end Main;
