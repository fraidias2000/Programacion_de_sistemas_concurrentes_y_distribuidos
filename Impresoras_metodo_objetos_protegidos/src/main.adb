procedure Main is

  NUM_A:constant:= 20;
  NUM_B:constant:= 20;

  TIEMPO_IMPRIMIR_A constant:= 30;
  TIEMPO_IMPRIMIR_B constant:= 25;
  subtype tipoTrabajo is integer range 0..2;
  package trabajoAleatorio is new Ada.Numerics.Discrete.Random(tipoTrabajo);
  GeneradorTrabajo.trabajoAleatorioGenerartor;

  protected Impresora is
    entry preparaA;
    entry preparaB;
    entry preparaCualquiera(tipo: out integer); // devuelve el tipo de impresora que es

    procedure liberaA;
    procedure liberaB;

    private
      disponiblesA: Integer:= NUM_A;
      disponiblesB: Integer:= NUM_B; // aqui no hay condiciones entonces, la sincronizacion la hago con "entry"
  end Impresora;

  protected body Impresora is
    entry preparaA when disponiblesA > 0 is
     begin
       disponiblesB:= disponiblesA - 1;
     end preparaA;

    entry preparaB when disponiblesB > 0 is
     begin
       disponiblesB:= disponiblesB - 1;
     end preparaB;

    entry preparaCualquiera(tipo: out Integer) when disponiblesA or disponiblesB is
     begin
      if disponiblesA > 0 then
       tipo := 1;
       disponiblesA:= disponiblesA - 1;
      else
       tipo:= 2;
       disponiblesB := disponiblesB - 1;
      end if;
    end preparaCualquiera;

    procedure liberaA is
     begin
      disponiblesA := disponiblesA + 1;
     end liberaA;

    procedure liberaB is
     begin
      disponiblesB := disponiblesB + 1;
    end liberaB;

end Impresora;

function ServicioImpresion;
  function obtenerTipo return Integer is
   begin
   return trabajoAleatorioRandom(GeneradorTrabajo);
  end obtenerTipo;


 task type Trabajo;
 task body Trabajo is
 tipo: Integer:=0;
 begin
  tipo:=obtenerTipo;
  case tipo is
   when 1 =>
    delay TIEMPO_IMPRIMIR_A;
    Impresora.liberaA;
   when 2 =>
    Impresora.liberaB;
    delay TIEMPO_IMPRIMIR_B;
    Impresora.liberaB;
   when others =>
    Impresora.preparaCualquiera(tipo);
    if tipo = 1 then
     delay TIEMPO_IMPRIMIR_A;
     Impresora.liberaA;
    else
     delay TIEMPO_IMPRIMIR_B;
     Impresora.liberaB;
    end if;
   end case;
 end trabajo;

 numTrabajos: Integer:= 10;
 type trabajoAcces is access Trabajo;
   null;
 Trabajos: array (0..numTrabajos) of trabajoAcces;

 begin
  for i in 1..numTrabajos loop
   Trabajos(i):= new Trabajo;
  end loop;
end Main;
