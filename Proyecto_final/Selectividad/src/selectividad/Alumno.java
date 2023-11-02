/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package selectividad;
import java.util.concurrent.Semaphore;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 *
 * @author aculplay
 */
public class Alumno extends Thread {
    
    int miAsignacion = 0;
    int contadorLloros = 0;
    int auxiliar = 0;
    private int id;
    
    
    public Alumno(int id) {
        this.id = id;
    }
     public void run(){
        try  {
            Semaforos.pedirAsignacionAula.release();//Pide al administrador poder entrar al aula
            Semaforos.atendidoAdministrador.acquire();//Espera a que le atienda y le diga que aula le toca
            miAsignacion = Semaforos.aulaAsignada; //Creamos una variable local para poder seguir asignando aulas
            Semaforos.mutexAula.release();//Quitamos el mutex para que otro Alumno pueda pedir que le asignen un aula
            if(miAsignacion == 6){//Si el administrador nos asigna un 6 es porque intentamos colarnos
                System.out.println("El alumno " + id + " ha sido expulsado");
                return;
            }
            Semaforos.Sillas[miAsignacion].acquire(); //Coje una silla del aula que le han asignado
            Semaforos.mutexEntradaAula.acquire();//Ponemos mutex para que no entren 2 personas y se cuente solo una
            Semaforos.contadorAlumnos[miAsignacion]++;//Aumenta la cantidad de alumnos de esa aula para que cuando este llena alguien avise al profesor
            Semaforos.mutexEntradaAula.release();
           if(Semaforos.contadorAlumnos[miAsignacion] == 5){
               System.out.println("En el aula " + miAsignacion + " ya estan todos y van a hacer el examen"); 
               Semaforos.todosListos[miAsignacion].release();//Le decimos que en el aula estan todos los alumnos
              }else{
                Semaforos.examen[miAsignacion].acquire();//Esperamos a que nos den el examen
           }
           
           
            Thread.sleep(5000);//Tiempo que tarda en hacer un examen
            
            Semaforos.mutexSalidaAula.acquire();
            Semaforos.contadorAlumnos[miAsignacion]--;
            Semaforos.mutexSalidaAula.release();
             if(Semaforos.contadorAlumnos[miAsignacion] == 0){
                 System.out.println("Aula " + miAsignacion + " vacia");
                 Semaforos.todosFuera[miAsignacion].release();//Le decimos que el aula esta vacia   
            }
            
             
          //  -------------------------------------------------------------------- Hasta aqui el examen
            int numero = (int)(Math.random()*10 -4);
            if(numero > 0){ //Si el numero es negativo es porque el alumno ha decido ir a la cafeteria
                System.out.println("El alumno " + id + " ha decidido irse a la cafeteria");
                Semaforos.sillasCafeteria.acquire();//Coge una silla de la cafeteria
                Semaforos.nuevoCliente.release();//Pide a la camarera que le atiendan
                Semaforos.atendidoCafeteria.acquire();//Esperamos a que nos haya atendido
                Thread.sleep(4000);//Hacemos como que el alumno esta tomandose un café
                System.out.println("Alumno " + id + " ha sido atendido en la cefeteria y se va");
                Semaforos.sillasCafeteria.release();
            
            //--------------------------------------------------------------------- Hasta aqui la cafeteria    
            }else{//El alumno ha decidido irse a llorar
                System.out.println("El alumno " + id +" ha ido a la lloreria");
                Semaforos.sillasLloreria.acquire();//Coge una silla de la lloreria
               
                Semaforos.mutexLloreriaEntrada.acquire();
                Semaforos.contadorLloreria++;       
                Semaforos.mutexLloreriaEntrada.release();
                if(Semaforos.contadorLloreria == 3){
                    Semaforos.preparadosParaLlorar.release();
                    
                }else{
                    Semaforos.esperandoGente.acquire();//Si no está llena el aula, los alumnos esperan a que se llene
                }
                System.out.println("El alumno " + id + " está llorando");
                Thread.sleep(6000); //Tiempo que están llorando los alumnos
                
                Semaforos.sillasLloreria.release();
                Semaforos.mutexLloreriaSalida.acquire();
                Semaforos.contadorLloreria--;
                Semaforos.mutexLloreriaSalida.release();
                System.out.println("El alumno " + id + " se ha ido");
            }
     }catch (InterruptedException ex) {
        Logger.getLogger(Administrador.class.getName()).log(Level.SEVERE, null, ex);
     }
     
     }
}
