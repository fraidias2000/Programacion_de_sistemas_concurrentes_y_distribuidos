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
public class Semaforos {
    
        //variables compartidas
       static Semaphore mutexCuaderno = new Semaphore (1);
       static Semaphore mutex = new Semaphore (1);
       
        //cliente
       static Semaphore plazas = new Semaphore(5);
 
       //administrativo
       static Semaphore atenderAdministrador = new Semaphore (0);
       static Semaphore atendidoAdministrador = new Semaphore (0);
       
       //operarios
       static Semaphore jefeTrabajando = new Semaphore (0);
       static Semaphore[] pedirOperario = {new Semaphore (0),new Semaphore (0),new Semaphore (0),new Semaphore (0),new Semaphore (0)};
       static Semaphore[] atendidoOp = {new Semaphore (0),new Semaphore (0),new Semaphore (0),new Semaphore (0),new Semaphore (0)};
       
       
       
}
