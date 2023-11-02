/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package taller;

import java.util.concurrent.Semaphore;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author aculplay
 */
public class Operario extends Thread{
   
   public boolean disponible;
   public boolean jefe;
   public int id;
   public static boolean auxiliar = true;
   public static int hojas;
   public final int MAX_HOJAS = 20;
   public int tiempo_aleatorio ;
    public int numeroCliente = 0;
   
  

    public Operario( boolean jefe, int id) {
        this.jefe = jefe;
        this.id = id;
    }
    
  public void run(){
      hojas = MAX_HOJAS;
      tiempo_aleatorio = (int) (Math.random());
      while(true){
        try {
          /*Semaforos.trabajar.acquire();
            System.out.println("Los operarios ya pueden trabajar");
          */
            
            
             sleep(tiempo_aleatorio);
          
            if(jefe && auxiliar){
                System.out.println("El jefe ya ha llegado");
                for(int i =0 ; i < 5; i++){
                    Semaforos.jefeTrabajando.release();
                }
                auxiliar = false;
            }
            Semaforos.pedirOperario[this.id].acquire(); //espera hasta que haya un cliente
            numeroCliente++;
             
            sleep(tiempo_aleatorio);
            System.out.println("El cliente "+ numeroCliente + " ha entrado en operario " + (id + 1) );
            System.out.println("Revisando vehiculo del cliente " + numeroCliente + " por el operario " + (id + 1));
            
            
            Semaforos.mutexCuaderno.acquire(); //hace un wait a mutex para tratar una variable compartida
            hojas--;
             if(hojas == 0){
                System.out.println("El operario "+ (id + 1) + " ha ido al almacen a por una libreta");
                sleep(tiempo_aleatorio);
                hojas = MAX_HOJAS;
            }else{
            System.out.println("El operario " + (id + 1) + " esta escribiendo en la hoja (quedan " + hojas + " hojas)");
            sleep(tiempo_aleatorio);
            
             }
            Semaforos.mutexCuaderno.release(); 
            Semaforos.atendidoOp[this.id].release();
            
        } catch (InterruptedException ex) {
            Logger.getLogger(Operario.class.getName()).log(Level.SEVERE, null, ex);
        }
  }
  }
}
