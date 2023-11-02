package javaapplication1;

/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author aculplay
 */
class FlujoA extends Thread {
    @Override
    public void run(){
        try{
           for(int i =0;i<=10;i++){
                System.out.println("Flujo A");
                sleep(500);
            }
        }
        catch (InterruptedException e){
            e.printStackTrace();
        }
    }
}

    
