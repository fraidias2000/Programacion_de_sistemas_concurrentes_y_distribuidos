/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package sockets;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.Scanner;
import java.util.logging.Level;
import java.util.logging.Logger;


/**
 *
 * @author aculplay
 */
public class Cliente {
     public static void main(String[] args) {
         String accion = "";
         String recibido = "";
          Scanner teclado = new Scanner(System.in);
         try {
             Socket miSocket =  new Socket("localHost",5000);
             PrintWriter out = new PrintWriter(miSocket.getOutputStream(), true); //Mandar mensajes servidor
             BufferedReader in = new BufferedReader(new InputStreamReader(miSocket.getInputStream())); //Recibir mensajes servidor
                
            while(!accion.equals("FIN") && recibido.equals("ERROR")){ //Mientras que el cliente no ponga "FIN" se mantiene la conexión entre cliente-servidor
                System.out.println("Escribe el ISBN del libro que quieres obtener informacion");
                accion = teclado.nextLine();
                out.println(accion); // Le pedimos un libro
            
                recibido = in.readLine(); // Nos responde (mientras estamos bloqueados aqui esperando)
                System.out.println(recibido); //Escribimos en pantalla lo que nos ha respondido el servidor
             
                accion = teclado.nextLine();
                out.println(accion);//En base a lo que nos dice el servidor, decidimos que hacer o poner "FIN"
            
                recibido = in.readLine();//El servidor nos responde (mientras estamos bloqueados aqui esperando)
                System.out.println(recibido);
             
                if(accion.equals("ALTA")){//Si antes hemos puesto ALTA, tendremos que poner el ISBN 
                    accion = teclado.nextLine(); 
                    out.println(accion); //Le decimos el ISBN del libro para que lo añada a la colección o poner "FIN"
                    
                    recibido = in.readLine(); // Nos responde (nos pondrá OK si todo ha ido bien)
                    System.out.println(recibido);
                    
                }else if (recibido.equals("DISPONIBLE")){//Si el servidor nos ha puesto que está disponible
                    System.out.println("Pon el DNI para coger el libro");
                    accion = teclado.nextLine();
                    out.println(accion); // Ponemos un DNI para reservarlo o poner "FIN"
                    
                    recibido = in.readLine(); // Nos responde (nos pondrá OK si todo ha ido bien)
                    System.out.println(recibido);
                    
                }else { // Si no es ninguna de las anteriores es porque el libro esta ocupado
                    accion = teclado.nextLine();
                    out.println(accion);// Ponemos si queremos consultar el libro o poner "FIN"
                    
                    recibido = in.readLine(); // Nos responde (nos pondrá OK si todo ha ido bien)
                    System.out.println(recibido);
                }
            }
             System.out.println("Conexión finalizada");
         }catch (IOException ex) {
             Logger.getLogger(Cliente.class.getName()).log(Level.SEVERE, null, ex);
         }
    }
    
}
