package javaapplication1;

import static java.lang.Thread.sleep;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author aculplay
 */
public class FlujoB extends Thread{
    public void run(){
        try{
            for(int i =0;i<=15;i++){
                System.out.println("Flujo B");
                sleep(500);
            }
        }
        catch (InterruptedException e){
            e.printStackTrace();
        }
    }
}
