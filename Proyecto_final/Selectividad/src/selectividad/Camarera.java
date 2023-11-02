/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package selectividad;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author aculplay
 */
public class Camarera extends Thread{
    static final int MAX_CAFES = 5;
    int numCafes = MAX_CAFES;
    
    public void run(){ 
    
        try {
            while(true){
                Semaforos.nuevoCliente.acquire();//Espera a que llegue un cliente
                numCafes--;
                if(numCafes > 0){
                    System.out.println("Se ha vendido un cafe");
                    Semaforos.atendidoCafeteria.release();
                }else{
                    System.out.println("Se han acabado los cafes, la camarera va a por más");
                    Thread.sleep(4000);
                    numCafes = MAX_CAFES;
                }
            }   
        }catch (InterruptedException ex) {
            Logger.getLogger(Camarera.class.getName()).log(Level.SEVERE, null, ex);
        }
    
    }
}
