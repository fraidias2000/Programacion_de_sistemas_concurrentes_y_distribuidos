/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package maquinacafe;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 *
 * @author fraid
 */
public class Lector extends Thread{
    
    public void run(){
        try {
            Semaforos.ocuparSilla.acquire();
            System.out.println("Un lector ha ocupado una silla");
            sleep(200);
            System.out.println("Un lector ha pedido un cafe");
            Semaforos.hacerCafe.release();
            Semaforos.cafeHecho.acquire();
            
            Semaforos.ocuparSilla.release();
            System.out.println("Un lector ha abandonado el aula");
            
        } catch (InterruptedException ex) {
            Logger.getLogger(Lector.class.getName()).log(Level.SEVERE, null, ex);
        }
    
    }
    
}
