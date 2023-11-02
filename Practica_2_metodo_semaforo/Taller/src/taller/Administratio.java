/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package taller;

import java.util.logging.Level;
import java.util.logging.Logger;
/**
 *
 * @author aculplay
 */
public class Administratio extends Thread{
    public int tiempo_aleatorio ;
    public int numeroCliente = 0;
 
     public void run(){
         while(true){
             try {
                 tiempo_aleatorio = (int) (Math.random());
                 Semaforos.atenderAdministrador.acquire();//Espera hasta que haya un cliente
                 numeroCliente++;
                 System.out.println("El administrativo va a atender al cliente " + numeroCliente);
                 System.out.println("Tramitando papeles ITV...");
                 Semaforos.atendidoAdministrador.release();//Hace un signal a cliente
                 sleep(tiempo_aleatorio);
             } catch (InterruptedException ex) {
                 Logger.getLogger(Administratio.class.getName()).log(Level.SEVERE, null, ex);
             }
         }
     }
    
}
