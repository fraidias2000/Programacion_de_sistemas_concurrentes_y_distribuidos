/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package maquinacafe;

import java.util.concurrent.Semaphore;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author fraid
 */
public class Semaforos {
    static Semaphore ocuparSilla = new Semaphore (5);
    static Semaphore hacerCafe = new Semaphore (0);
    static Semaphore cafeHecho = new Semaphore (0);
    
}
