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
import java.net.ServerSocket;
import java.net.Socket;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author aculplay
 */
public class Servidor {
     public static void main(String[] args) { 
        Libro coleccion[] = new Libro[10];
        int iterador;
        String mensajeCliente;
        String otroMensaje;
        String DNI;
        String ISBN;
         try {
             ServerSocket miServidor  = new ServerSocket(5000);
             System.out.println("Servidor iniciado");
             Socket socketCliente = miServidor.accept();
             PrintWriter outServer = new PrintWriter(socketCliente.getOutputStream(), true); //Mandar mensajes servidor
             BufferedReader inServer = new BufferedReader(new InputStreamReader(socketCliente.getInputStream())); //Recibir mensajes servidor
             
             while(true){
                 iterador = 0;
                 mensajeCliente = inServer.readLine(); //Espero a que me mande cliente un mensaje (Nos mandará el ISBN de un libro)
                 while(coleccion[iterador].ISBN != null){//Busco en la coleccion de libros(No se si funciona bien)
                     if(coleccion[iterador].ISBN.equals(mensajeCliente)){ //Si el ISBN coincide con alguna posicion del vector
                         if(coleccion[iterador].disponible){//Si el libro que nos pide está disponible
                            outServer.println("DISPONIBLE");
                             break;
                         }else{
                             outServer.println("PRESTADO, si quieres ver quien lo tiene pon: CONSULTA ");
                             break;
                         }
                     }
                     iterador++;
                 }
                 outServer.println("NUEVO, si quieres añadirlo a la coleccion pon: ALTA");
                 
                 otroMensaje = inServer.readLine(); // Volvemos a esperar que el cliente nos mande un mensaje
                 
                 if(otroMensaje.equals("ALTA")){//El libro no existe y por tanto lo creamos
                     outServer.println("Dime su ISBN");
                     ISBN = inServer.readLine(); //Leemos el DNI que nos escribe el cliente
                     coleccion[iterador] = new Libro(ISBN,true,null);
                     outServer.println("OK");
                     
                 }else if(otroMensaje.equals("CONSULTA")){ // El libro esta ocupado y el cliente quiere ver quien lo tiene
                     outServer.println(coleccion[iterador].DNI);
                     
                 }else{ // Si no es ninguna de las anteriores es porque el libro esta disponible y el cliente quiere cogerlo
                     DNI = inServer.readLine();
                     coleccion[iterador].DNI = DNI;
                     coleccion[iterador].disponible = false;
                     outServer.println("OK");
                 }  
             }
         } catch (IOException ex) {
             Logger.getLogger(Servidor.class.getName()).log(Level.SEVERE, null, ex);
         }
        
             
    }
    
}
