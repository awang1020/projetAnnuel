package com.example.carproject;

import androidx.appcompat.app.AppCompatActivity;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

import android.annotation.SuppressLint;
import android.os.Bundle;
import android.os.StrictMode;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemSelectedListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.Toast;

public class MainActivity extends AppCompatActivity {

    String ip, db, un, passwords;
    Connection connect;
    PreparedStatement stmt;
    ResultSet rs;
    Button button;
    Spinner spinnerhybride;
    Spinner spinnercarburant;
    Spinner spinnermotorisation;
    Spinner spinnermodele;
    Spinner spinnermarque;
    TextView textView;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        ip = "192.168.1.86";
        un = "admin";
        passwords = "admin";
        db = "DataCar";
        button = findViewById(R.id.button);
        textView=findViewById(R.id.valider);

        MethodeSpinnerMarque();
        MethodeSpinnerModele();
        MethodeSpinnerMotorisation();
        MethodeSpinnerCarburant();
        MethodeSpinnerHybride();

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {
                String sMarque = spinnermarque.getSelectedItem().toString();
                String sModele = spinnermodele.getSelectedItem().toString();
                String sMotorisation = spinnermotorisation.getSelectedItem().toString();
                String sCarburant = spinnercarburant.getSelectedItem().toString();
                String sHybride = spinnerhybride.getSelectedItem().toString();


                if (sMarque.equals("")) {
                    Toast.makeText(getApplicationContext(), "Veuillez renseigner la marque du véhicule !", Toast.LENGTH_SHORT).show();
                }
                if (sModele.equals("")) {
                    Toast.makeText(getApplicationContext(), "Veuillez renseigner le modèle du véhicule !", Toast.LENGTH_SHORT).show();
                }
                if (sMotorisation.equals("")) {
                    Toast.makeText(getApplicationContext(), "Veuillez renseigner la motorisation du véhicule !", Toast.LENGTH_SHORT).show();
                }
                if (sCarburant.equals("")) {
                    Toast.makeText(getApplicationContext(), "Veuillez renseigner l'énergie du véhicule !", Toast.LENGTH_SHORT).show();
                }
                if (sHybride.equals("")) {
                    Toast.makeText(getApplicationContext(), "Veuillez renseigner  du véhicule !", Toast.LENGTH_SHORT).show();
                }

                if (sMarque != "" && sModele != "" && sMotorisation != "" && sCarburant != "" && sHybride != ""){
                    //Toast.makeText(getApplicationContext(), sMarque, Toast.LENGTH_SHORT).show();
                    connect = CONN(un, passwords, db, ip);
                    String querybutton = "select lib_mrq, lib_mod_doss,hybride,dscom,typ_cbr,co2\n" +
                            "from Worksheet\n" +
                            "where lib_mrq ='"+sMarque+"' and lib_mod_doss='"+sModele+"' and hybride='"+sHybride+"' and dscom='"+sMotorisation+"' and typ_cbr='"+sCarburant+"'";
                    try {
                        connect = CONN(un, passwords, db, ip);
                        stmt = connect.prepareStatement(querybutton);
                        rs = stmt.executeQuery();

                        if (rs.next()) {
                            String co2 = rs.getString("co2");
                            textView.setText("Consommation du véhicule : "+co2+" g/km");
                        }
                        else {
                            textView.setText("Informations incohérentes !");
                        }

                    } catch (SQLException e) {
                        e.printStackTrace();
                    }

                }
            }
        });

    }



    private void MethodeSpinnerHybride() {

        spinnerhybride = (Spinner) findViewById(R.id.spinnerhybride);

        connect = CONN(un, passwords, db, ip);
        String queryhybride = "select distinct hybride from Worksheet";

        try {
            connect = CONN(un, passwords, db, ip);
            stmt = connect.prepareStatement(queryhybride);
            rs = stmt.executeQuery();
            ArrayList<String> data = new ArrayList<String>();
            while (rs.next()) {
                String id = rs.getString("hybride");
                data.add(id);

            }
            String[] array = data.toArray(new String[0]);
            ArrayAdapter NoCoreAdapter = new ArrayAdapter(this, android.R.layout.simple_list_item_1, data);
            spinnerhybride.setAdapter(NoCoreAdapter);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        spinnerhybride.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {

                String name = spinnerhybride.getSelectedItem().toString();
                //Toast.makeText(getApplicationContext(), name, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    private void MethodeSpinnerCarburant() {

        spinnercarburant = (Spinner) findViewById(R.id.spinnercarburant);

        connect = CONN(un, passwords, db, ip);
        String querycarburant = "select distinct typ_cbr from Worksheet \n" +
                "order by typ_cbr asc ";

        try {
            connect = CONN(un, passwords, db, ip);
            stmt = connect.prepareStatement(querycarburant);
            rs = stmt.executeQuery();
            ArrayList<String> data = new ArrayList<String>();
            while (rs.next()) {
                String id = rs.getString("typ_cbr");
                data.add(id);

            }
            String[] array = data.toArray(new String[0]);
            ArrayAdapter NoCoreAdapter = new ArrayAdapter(this, android.R.layout.simple_list_item_1, data);
            spinnercarburant.setAdapter(NoCoreAdapter);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        spinnercarburant.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {

                String name = spinnercarburant.getSelectedItem().toString();
                //Toast.makeText(getApplicationContext(), name, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    private void MethodeSpinnerMotorisation() {

        spinnermotorisation = (Spinner) findViewById(R.id.spinnermotorisation);

        connect = CONN(un, passwords, db, ip);
        String querymotorisation = "select distinct dscom from Worksheet \n" +
                "where dscom not like 'NULL'\n" +
                "order by dscom ";

        try {
            connect = CONN(un, passwords, db, ip);
            stmt = connect.prepareStatement(querymotorisation);
            rs = stmt.executeQuery();
            ArrayList<String> data = new ArrayList<String>();
            while (rs.next()) {
                String id = rs.getString("dscom");
                data.add(id);

            }
            String[] array = data.toArray(new String[0]);
            ArrayAdapter NoCoreAdapter = new ArrayAdapter(this, android.R.layout.simple_list_item_1, data);
            spinnermotorisation.setAdapter(NoCoreAdapter);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        spinnermotorisation.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {

                String name = spinnermotorisation.getSelectedItem().toString();
                //Toast.makeText(getApplicationContext(), name, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });
    }

    private void MethodeSpinnerModele() {

        spinnermodele = (Spinner) findViewById(R.id.spinnermodele);

        connect = CONN(un, passwords, db, ip);
        String querymodele = "select distinct lib_mod_doss from Worksheet \n" +
                "where lib_mod_doss not like 'NULL' \n" +
                "order by lib_mod_doss asc";

        try {
            connect = CONN(un, passwords, db, ip);
            stmt = connect.prepareStatement(querymodele);
            rs = stmt.executeQuery();
            ArrayList<String> data = new ArrayList<String>();
            while (rs.next()) {
                String id = rs.getString("lib_mod_doss");
                data.add(id);

            }
            String[] array = data.toArray(new String[0]);
            ArrayAdapter NoCoreAdapter = new ArrayAdapter(this, android.R.layout.simple_list_item_1, data);
            spinnermodele.setAdapter(NoCoreAdapter);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        spinnermodele.setOnItemSelectedListener(new OnItemSelectedListener() {

            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {

                String name = spinnermodele.getSelectedItem().toString();
                //Toast.makeText(getApplicationContext(), name, Toast.LENGTH_SHORT).show();
            }

            @Override
            public void onNothingSelected(AdapterView<?> parent) {

            }
        });

    }

    private void MethodeSpinnerMarque() {
        spinnermarque = (Spinner) findViewById(R.id.spinnermarque);

        connect = CONN(un, passwords, db, ip);
        String querymarque = "select distinct lib_mrq from Worksheet order by lib_mrq asc";

        try {
            connect = CONN(un, passwords, db, ip);
            stmt = connect.prepareStatement(querymarque);
            rs = stmt.executeQuery();
            ArrayList<String> data = new ArrayList<String>();
            while (rs.next()) {
                String id = rs.getString("lib_mrq");
                data.add(id);
            }
            String[] array = data.toArray(new String[0]);
            ArrayAdapter NoCoreAdapter = new ArrayAdapter(this, android.R.layout.simple_list_item_1, data);
            spinnermarque.setAdapter(NoCoreAdapter);

        } catch (SQLException e) {
            e.printStackTrace();
        }
        spinnermarque.setOnItemSelectedListener(new OnItemSelectedListener() {
            @Override
            public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
                String name = spinnermarque.getSelectedItem().toString();
                //Toast.makeText(getApplicationContext(), name, Toast.LENGTH_SHORT).show();
            }
            @Override
            public void onNothingSelected(AdapterView<?> parent) {
            }
        });
    }

    @SuppressLint("NewApi")
    private Connection CONN(String _user, String _pass, String _DB, String _server) {
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder()
                .permitAll().build();
        StrictMode.setThreadPolicy(policy);
        Connection conn = null;
        String ConnURL = null;
        try {

            Class.forName("net.sourceforge.jtds.jdbc.Driver");
            ConnURL = "jdbc:jtds:sqlserver://" + _server + ";"
                    + "databaseName=" + _DB + ";user=" + _user + ";password="
                    + _pass + ";";
            conn = DriverManager.getConnection(ConnURL);
        } catch (SQLException se) {
            Log.e("ERRO", se.getMessage());
        } catch (ClassNotFoundException e) {
            Log.e("ERRO", e.getMessage());
        } catch (Exception e) {
            Log.e("ERRO", e.getMessage());
        }
        return conn;

    }
}

