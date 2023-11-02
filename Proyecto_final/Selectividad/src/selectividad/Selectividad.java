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
public class Selectividad {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        // TODO code application logic here
        Profesor Profesores[] = new Profesor[5];
        
        Administrador Administrador = new Administrador();
        Administrador.start();//Inicializamos el administrador
        
        Camarera miCamarera = new Camarera();
        miCamarera.start(); //Inicializamos la camarera
        
        Lloreria miLloreria = new Lloreria();
        miLloreria.start(); //Inicializamos la lloreria
        
        for(int i = 0; i <= 4 ; i++){ //Inicializamos los profesores
            Profesores[i] = new Profesor(i);
            Profesores[i].start();
        }
        for (int i = 0; i <= 40; i++) {//Inicializamos los alumnos
            Alumno Alumnos = new Alumno(i);
            Alumnos.start();
        }
    }
    
}
