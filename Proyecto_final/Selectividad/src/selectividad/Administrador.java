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
public class Administrador extends Thread {
    int asignacion;
    public void run(){ 
        try {
            while(true){
                Semaforos.pedirAsignacionAula.acquire(); //Espera a que llege un alumno y le pida entrar
                System.out.println("Comprobando el DNI de un alumno");
                Thread.sleep(1500);
                int numero = (int)(Math.random()*3+1);
                Semaforos.mutexAula.acquire();
                if(numero == 1){ // Si el numero aleatorio es positivo suponemos que el Alumno intentaba colarse
                    Semaforos.aulaAsignada = 6;
                    System.out.println("Un alumno ha intenado colarse");
                }else{
                    numero = (int)(Math.random()*5);
                    asignacion = 0;
                    switch(numero){
                        case 0:
                            System.out.println("El alumno se va a evaluar de ingles (aula 0)");
                            asignacion = 0;
                            break;
                        case 1:
                             System.out.println("El alumno se va a evaluar de matematicas (aula 1)");
                             asignacion = 1;
                            break;
                        case 2:
                             System.out.println("El alumno se va a evaluar de historia (aula 2)");
                             asignacion = 2;
                            break;
                        case 3:
                             System.out.println("El alumno se va a evaluar de fisica (aula 3)");
                             asignacion = 3;
                            break;
                        case 4:
                            System.out.println("El alumno se va a evaluar de lengua (aula 4)");
                            asignacion = 4;
                            break;
                    
                    }
                    Semaforos.aulaAsignada = asignacion;//Le pasamos el aula que no está llena
                    System.out.println("Se le ha asignado el aula: " + asignacion);
                }
                Semaforos.atendidoAdministrador.release();
            }
        }catch (InterruptedException ex) {
            Logger.getLogger(Administrador.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
