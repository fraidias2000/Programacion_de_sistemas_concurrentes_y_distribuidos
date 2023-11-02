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
public class Taller {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        int i = 0;
        //Declaro los operarios y digo que el ultimo es el jefe
        Operario[] misOperarios = new Operario[5];
        for( i = 0; i <= 4 ; i++){
            misOperarios[i] = new Operario(false,i);
            misOperarios[i].start();
        }
        misOperarios[4] = new Operario (true,4);
        misOperarios[4].start();
        
       //LANZAMOS HILOS CLIENTES
       for( i = 0; i < 20; i++){
        Clientes misClientes = new Clientes(i+1);
        misClientes.start();
        }
        //LANZO HILO ADMINISTRADOR
        Administratio miAdministrativo = new Administratio ();
        miAdministrativo.start();
        
        
        
        
        
        
        
        
        
          
    }
    
}
