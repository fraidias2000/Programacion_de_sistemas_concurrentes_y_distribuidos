/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaapplication1;

import static java.lang.Thread.sleep;

/**
 *
 * @author aculplay
 */
public class FlujoC extends Thread{
    public void run(){
        try{
            for(int i =0;i<=9;i++){
                System.out.println("Flujo C");
                sleep(500);
            }
        }
        catch (InterruptedException e){
            e.printStackTrace();
        }
    }
}
