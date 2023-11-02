/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

package taller;
import java.util.concurrent.Semaphore;

/**
 *
 * @author aculplay
 */
public class Clientes extends Thread {
    public int id;
    public static boolean[] operariosOcupados = {false,false,false,false,false};
    public  int Operario = 0;

    public Clientes(int id) {
        this.id = id;
    }
   
 
     @Override
     public void run(){
     
     try {
         //ADMINISTRADOR
        Semaforos.plazas.acquire(); //El cliente mira si tiene hueco en la sala
         System.out.println("El cliente "+ id + " ha entrado en la sala");
        Semaforos.atenderAdministrador.release(); //El cliente pide al administrador que le atienda
        Semaforos.atendidoAdministrador.acquire();
        Semaforos.plazas.release();
        
        //OPERARIO
        Semaforos.jefeTrabajando.acquire();
         
        Semaforos.mutex.acquire();
        while(operariosOcupados[Operario] == true){
            Operario++;
        }
            
            operariosOcupados[Operario] = true;//cogemos el operario 
            Semaforos.pedirOperario[Operario].release();
            sleep(300);
            Semaforos.mutex.release();
        
        Semaforos.atendidoOp[Operario].acquire();
        
         Semaforos.mutex.acquire();
         operariosOcupados[Operario] = false;
         Semaforos.mutex.release();
         
         Semaforos.jefeTrabajando.release();
         System.out.println("El cliente " + id + " ha abandonado el lugar.");
    }catch (InterruptedException e) {}

     
     }
}
