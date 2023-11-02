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
public class Profesor extends Thread {
    static final int MAX_HOJAS = 10;
    public int id ;

    public Profesor(int id) {
        this.id = id;
    }
    public void run(){ 
        try {
            while(true){
                Semaforos.todosListos[this.id].acquire(); //Espera a que esten todos los alumnos en el aula
                Semaforos.mutexHojas.acquire();
                for(int i = 0; i <= 5 ; i++){ //Como sabemos que tiene que entregar si o si 5 hojas, hacemos un bucle for
                    Semaforos.Hojas --;
                    if (Semaforos.Hojas == 0){
                        System.out.println("El profesor " + id +" ha ido a por más hojas");
                        Thread.sleep(2000);
                        Semaforos.Hojas = MAX_HOJAS;
                    }else{
                        Semaforos.examen[this.id].release();//Le entrega una hoja a un alumno
                        System.out.println("El profesor ha entregado una hoja al alumno " + i + " (aula " + this.id + ")");
                    }
                }
                Semaforos.mutexHojas.release();
                Semaforos.todosFuera[this.id].acquire();//El profesor se queda esperando a que todos abandonen el aula
                 for (int i = 0; i <= 5; i++) {//Hacemos 5 signals a sillas para simular que el aula está vacía
                      Semaforos.Sillas[this.id].release();
                }
            }
        } catch (InterruptedException ex) {
            Logger.getLogger(Profesor.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}