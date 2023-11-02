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
public class Lloreria extends Thread {
      public void run(){ 
            while(true){
                try {
                    Semaforos.preparadosParaLlorar.acquire();//Espera a que se llene el aula para poder llorar
                        for (int i = 0; i <= 3; i++) {
                            Semaforos.esperandoGente.release();
                        }
                } catch (InterruptedException ex) {
                    Logger.getLogger(Lloreria.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
      
      }
    
}
