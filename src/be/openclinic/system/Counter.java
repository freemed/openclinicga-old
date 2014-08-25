package be.openclinic.system;


import java.sql.PreparedStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

public class Counter {
    private String name;
    private int counter;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getCounter() {
        return counter;
    }

    public void setCounter(int counter) {
        this.counter = counter;
    }

    /*
    // --------> USE MWQ.setOpenclinicCounter(), which is synchronised <--------------
    public static void saveCounter(Counter objCounter, String sDB){
        PreparedStatement ps = null;
        Connection conn;


        String sUpdate = "";

        conn = MedwanQuery.getInstance().getConfigConnection();
        try{
            if (sDB.toLowerCase().startsWith("admin")) {
                sUpdate = "UPDATE Counters SET counter = ? WHERE name = ?";
            }
            else if (sDB.toLowerCase().startsWith("control")) {
                sUpdate = "UPDATE Counters SET counter = ? WHERE name = ?";
            }
            else if (sDB.toLowerCase().startsWith("occup")) {
                sUpdate = "UPDATE counters SET counter = ? WHERE name = ?";
            }
            else if (sDB.toLowerCase().startsWith("result")) {
                sUpdate = "UPDATE Counters SET counter = ? WHERE counterid = ?";
            }
            else if (sDB.toLowerCase().startsWith("monitor")) {
                sUpdate = "UPDATE Counters SET counter = ? WHERE name = ?";
            }

            ps = conn.prepareStatement(sUpdate);
            ps.setInt(1,objCounter.getCounter());
            ps.setString(2,objCounter.getName());

            ps.executeUpdate();

            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }
    */

    public static Vector selectCounters(String sDB){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Connection conn;

        Vector vCounters = new Vector();

        String sSelect = "";

        conn = MedwanQuery.getInstance().getConfigConnection();
        try{
            if (sDB.toLowerCase().startsWith("admin")) {
                sSelect = "SELECT * FROM Counters ORDER BY name";
            }
            else if (sDB.toLowerCase().startsWith("control")) {
                sSelect = "SELECT * FROM Counters ORDER BY name";
            }
            else if (sDB.toLowerCase().startsWith("occup")) {
                sSelect = "SELECT * FROM counters ORDER BY name";
            }
            else if (sDB.toLowerCase().startsWith("result")) {
                sSelect = "SELECT counterid AS name, counter FROM Counters ORDER BY name";
            }
            else if (sDB.toLowerCase().startsWith("monitor")) {
                sSelect = "SELECT * FROM Counters ORDER BY name";
            }

            if(sSelect.length() > 0){
                ps = conn.prepareStatement(sSelect);
                rs = ps.executeQuery();

                Counter objCounter;

                while(rs.next()){
                    objCounter = new Counter();
                    objCounter.setCounter(rs.getInt("counter"));
                    objCounter.setName(ScreenHelper.checkString(rs.getString("name")));

                    vCounters.addElement(objCounter);
                }

                rs.close();
                ps.close();
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }

        return vCounters;
    }
}
