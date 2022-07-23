package com.example.carproject;

import android.os.StrictMode;
import android.util.Log;

import java.sql.Connection;
import java.sql.DriverManager;

public class connexionSql {
    public static Connection conn;
    String uname,pass,ip,port,database;

    public void setConnection (){

        database ="DataCar";
        uname="admin";
        pass="admin";
        port="1433";
        String ConnectionURL;

        try{
            StrictMode.ThreadPolicy policy= new StrictMode.ThreadPolicy.Builder().permitAll().build();
            StrictMode.setThreadPolicy(policy);
            ip = "192.168.1.35";

            ConnectionURL= "jdbc:jtds:sqlserver://"+ip+":"+port+"/"+database;
                   // "jdbc:jtds:sqlserver://" + ip +";instance=SQLEXPRESS;user=" + uname + ";password=" + pass + ";databaseName=" + database+";";
            Class.forName("net.sourceforge.jtds.jdbc.Driver").newInstance();
            conn = DriverManager.getConnection(ConnectionURL,uname,pass);
            Log.e("ASK","Connexion called");
        }
        catch(Exception e) {
            Log.e("Error","EXCEPTION "+ e.getMessage());

        }
    }
}
