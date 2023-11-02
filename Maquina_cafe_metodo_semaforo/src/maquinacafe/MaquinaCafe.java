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
public class MaquinaCafe extends Thread{
    public void run(){
        try {
            Semaforos.hacerCafe.acquire();
        
        System.out.println("La maquina está haciendo un café");
        Semaforos.cafeHecho.release();
        } catch (InterruptedException ex) {
            Logger.getLogger(MaquinaCafe.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
