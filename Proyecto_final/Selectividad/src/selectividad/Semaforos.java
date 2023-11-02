/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package selectividad;
import java.util.concurrent.Semaphore;

/**
 *
 * @author aculplay
 */
public class Semaforos {
    
    //Examen
    static int Hojas = 10;
    static int aulaAsignada = 0;
    static int contadorAlumnos[] = {0,0,0,0,0};
    static Semaphore[] Sillas = {new Semaphore (5),new Semaphore (5),new Semaphore (5),new Semaphore (5),new Semaphore (5)};
    static Semaphore[] examen = {new Semaphore (0),new Semaphore (0),new Semaphore (0),new Semaphore (0),new Semaphore (0)};
    static Semaphore pedirAsignacionAula = new Semaphore(0);
    static Semaphore atendidoAdministrador = new Semaphore(0);
    static Semaphore todosListos[] = {new Semaphore (0),new Semaphore (0),new Semaphore (0),new Semaphore (0),new Semaphore (0)};
    static Semaphore mutexHojas = new Semaphore (1);
    static Semaphore mutexAula = new Semaphore (1);
    static Semaphore mutexEntradaAula = new Semaphore (1);
    static Semaphore mutexSalidaAula = new Semaphore (1);
    static Semaphore todosFuera[] = {new Semaphore (0),new Semaphore (0),new Semaphore (0),new Semaphore (0),new Semaphore (0)};
    
    //Cafeteria
    static Semaphore sillasCafeteria = new Semaphore(3);
    static Semaphore nuevoCliente = new Semaphore(0);
    static Semaphore atendidoCafeteria = new Semaphore(0);
     
     //Lloreria
    static int contadorLloreria = 0;
    static Semaphore sillasLloreria = new Semaphore(3);
    static Semaphore mutexLloreriaEntrada = new Semaphore(1);
    static Semaphore mutexLloreriaSalida = new Semaphore(1);
    static Semaphore preparadosParaLlorar = new Semaphore(0);
    static Semaphore atendidosLloreria = new Semaphore(0);
    static Semaphore esperandoGente = new Semaphore(0);
}
