with Ada.Text_IO;
use Ada.Text_IO;
with Ada.Numerics;
with  Ada.Numerics.Discrete_Random;
procedure Main is
   task A;
   task B;
   task C;

   subtype segundos is integer range 1..5;
   package Azar is new Ada.Numerics.Discrete_Random(segundos);
   generaAzar: Azar.Generator;

   i: Integer := 0;

--------------------------------------------------------------------------------
   task body A is
   begin
      for i in 1..10 loop
         Put_Line("FLUJO A");
         delay Duration(Azar.Random(generaAzar));
         null;
      end loop;
   end;
--------------------------------------------------------------------------------
   task body B is
   begin
      for i in 1..15 loop
         Put_Line("FLUJO B");
         delay Duration(Azar.Random(generaAzar));
         null;
      end loop;
   end;
--------------------------------------------------------------------------------
   task body C is
   begin
      for i in 1..9 loop
         Put_Line("FLUJO C");
         delay Duration(Azar.Random(generaAzar));
         null;
      end loop;
   end;
--------------------------------------------------------------------------------
begin
   --  Insert code here.
   null;
end Main;
