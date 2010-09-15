package be.mxs.common.util.diagnostics;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Connection;
import java.sql.SQLException;

public class CleanCounters extends Diagnostic{
    public CleanCounters(){
        name = "CheckCounters";
        id = "MXS.1";
        author = "frank.verbeke@mxs.be";
        description = "Checks counters for Healthrecord,Transactions,Items";
        version = "1.0";
        date = "24/07/2006";
    }

    public Diagnosis check(){
        Diagnosis diagnosis = new Diagnosis();
        diagnosis.hasProblems=false;
        Connection connection = MedwanQuery.getInstance().getOpenclinicConnection();
        if (validateCounter(connection,"HealthRecordID","Healthrecord","healthRecordId","where serverid="+MedwanQuery.getInstance().getConfigInt("serverId"))){
            diagnosis.hasProblems=true;
        }
        if (validateCounter(connection,"TransactionID","Transactions","transactionId","where serverid="+MedwanQuery.getInstance().getConfigInt("serverId"))){
            diagnosis.hasProblems=true;
        }
        if (validateCounter(connection,"ItemID","Items","itemId","where serverid="+MedwanQuery.getInstance().getConfigInt("serverId"))){
            diagnosis.hasProblems=true;
        }
        connection = MedwanQuery.getInstance().getAdminConnection();
        if (validateCounter(connection,"PersonID","Admin","personid","")){
            diagnosis.hasProblems=true;
        }
        if (validateCounter(connection,"PrivateID","AdminPrivate","privateid","")){
            diagnosis.hasProblems=true;
        }
        try {
			connection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		try {
			connection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return diagnosis;
    }

    public boolean correct(Diagnosis diagnosis){
        boolean correct = true;
        Connection connection = MedwanQuery.getInstance().getOpenclinicConnection();
        correctCounter(connection,"HealthRecordID","Healthrecord","healthRecordId","where serverid="+MedwanQuery.getInstance().getConfigInt("serverId"));
        correctCounter(connection,"TransactionID","Transactions","transactionId","where serverid="+MedwanQuery.getInstance().getConfigInt("serverId"));
        correctCounter(connection,"ItemID","Items","itemId","where serverid="+MedwanQuery.getInstance().getConfigInt("serverId"));
        connection = MedwanQuery.getInstance().getAdminConnection();
        correctCounter(connection,"PersonID","Admin","personid","");
        correctCounter(connection,"PrivateID","AdminPrivate","privateid","");
        try {
			connection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        try {
			connection.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return correct;
    }

    private boolean validateCounter(Connection connection,String counterName,String tableName,String columnName,String extraCode){
        int counter=0,maxId=0;
        try {
            PreparedStatement ps = connection.prepareStatement("SELECT counter from Counters where name=?");
            ps.setString(1,counterName);
            ResultSet rs = ps.executeQuery();
            if (rs.next()){
                counter=rs.getInt("counter");
            }
            rs.close();
            ps.close();
            ps = connection.prepareStatement("SELECT max("+columnName+") maxid from "+tableName+" "+extraCode);
            rs = ps.executeQuery();
            if (rs.next()){
                maxId=rs.getInt("maxid");
            }
            rs.close();
            ps.close();
            if (maxId>=counter){
                return true;
            }
        }
        catch (Exception e){
            e.printStackTrace();
        }
        return false;
    }

    private void correctCounter(Connection connection,String counterName,String tableName,String columnName,String extraCode){
        int counter=0,maxId=0;
        try {
            PreparedStatement ps = connection.prepareStatement("SELECT counter from Counters where name=?");
            ps.setString(1,counterName);
            ResultSet rs = ps.executeQuery();
            if (rs.next()){
                counter=rs.getInt("counter");
            }
            rs.close();
            ps.close();
            ps = connection.prepareStatement("SELECT max("+columnName+") maxid from "+tableName+" "+extraCode);
            rs = ps.executeQuery();
            if (rs.next()){
                maxId=rs.getInt("maxid");
            }
            rs.close();
            ps.close();
            if (maxId>=counter){
                ps = connection.prepareStatement("update Counters set counter=? where name=?");
                ps.setInt(1,maxId+1);
                ps.setString(2,counterName);
                ps.execute();
                ps.close();
            }
        }
        catch (Exception e){
            e.printStackTrace();
        }

    }
}
