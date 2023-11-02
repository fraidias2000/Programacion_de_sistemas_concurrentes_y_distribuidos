procedure Main is
   MAX_MONOS_ESTE: constant : = 20;
   MAX_MONOS_OESTE: constant := 20;
   MAX_PASADOS : constant := 10;
   MAX_MONOS_PUENTE_PERMITIDOS : constant := 4;
   TIEMPO_CRUZAR :constant := 20;

   task Puente is
      entry pedirCruzarEste;
      entry pedirCruzarOeste;
      entry cruzarEste;
      entry cruzarOeste;
      entry salirPuenteEste;
      entry salirPuenteOeste;
   end Puente;

   task type MonoEste(id : Natural);
   task type MonoOeste (id : Natural);
   type direccion is (NINGUNA,ESTE,OESTE);

   type MonoEsteAccess is access MonoEste;
   MonosEste is array (1..MAX_MONOS_ESTE) of MonoEsteAccess;

   type MonosOesteAccess is access MonoOeste;
   MonosOeste is array (1..MAX_MONOS_OESTE) of MonosOesteAccess;
--------------------------------------------------------------------------------
         task body Puente is
            cruzar:direccion:= NINGUNA;
            esperandoEste : Natural := 0;
            esperandoOeste : Natural := 0;
            pasados : Natural:= 0;
            monosCruzando : Natural := 0;
         begin
            loop
               select
                   --Pide un mono del este cruzar
                  accept pedirCruzarEste do
                     esperandoEste := esperandoEste + 1;
                  end pedirCruzarEste;
               or
                  --Pide un mono del oeste cruzar
                  accept pedirCruzarOeste  do
                     esperandoOeste := esperandoOeste + 1;
                  end pedirCruzarOeste;
               or
                    --Cruza un mono del este
                  accept cruzarEste  when cruzar /= OESTE and
                    monosCruzando < MAX_MONOS_PUENTE_PERMITIDOS and
                    pasados < MAX_PASADOS =>
                    esperandoEste := esperandoEste - 1;
                    monosCruzando := monosCruzando + 1;
                    --Si es el primer mono en pasar
                    if cruzar = NINGUNA then
                      cruzar := ESTE;
                    end if;

                    --Si hay monos del oeste esperando solo pueden pasar 10 monos
                    if esperandoOeste > 0 then
                       pasados := pasados + 1;
                    end if;
                  end cruzarEste;
               or
                    --Cruza un mono del oeste
                    accept cruzarOeste  when cruzar /= ESTE and
                    monosCruzando < MAX_MONOS_PUENTE_PERMITIDOS and
                    pasados < MAX_PASADOS =>
                    esperandoOeste := esperandoOeste - 1;
                    monosCruzando := monosCruzando + 1;
                    --Si es el primer mono en pasar
                    if cruzar = NINGUNA then
                      cruzar := OESTE;
                    end if;

                    --Si hay monos del este esperando solo pueden pasar 10 monos
                    if esperandoEste > 0 then
                       pasados := pasados + 1;
                    end if;
                  end cruzarOeste;

               or
                   accept salirPuenteEste  do
                        monosCruzando := monosCruzando - 1;
                        --En caso de ser el último mono
                        if monosCruzando == 0 then
                            if esperandoOeste > 0 then
                                 cruzar := oeste;
                                 pasados := 0;
                            else
                                cruzar := NINGUNA;

                  end salirPuenteEste;
               or
                  accept salirPuenteOeste  do
                        monosCruzando := monosCruzando - 1;
                        --En caso de ser el último mono
                        if monosCruzando == 0 then
                            if esperandoEste > 0 then
                                 cruzar := este;
                                 pasados := 0;
                            else
                                cruzar := NINGUNA;
                  end salirPuenteOeste;
               or
                        terminate;
               end select;
           end loop;
        end Puente;
 -------------------------------------------------------------------------------
        task body MonoEste is
        begin
           Puente.pedirCruzarEste;
           Puente.cruzarEste;
           Puente.salirPuenteEste;
        end MonoEste;
--------------------------------------------------------------------------------
        task body MonoOeste is
        begin
           Puente.pedirCruzarOeste;
           Puente.cruzarOeste;
           Puente.salirPuenteOeste;
        end MonoOeste;
--------------------------------------------------------------------------------
begin

   --  Insert code here.
   null;
end Main;
