package be.mxs.common.util.diagnostics;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.Connection;

/**
 * User: frank
 * Date: 7-okt-2005
 */
public class CleanHealthRecord extends Diagnostic{
    public CleanHealthRecord(){
        name = "CheckHealthRecordTable";
        id = "MXS.1";
        author = "frank.verbeke@mxs.be";
        description = "Checks if all HealthRecord rows have serverid = active server id. Corrects if not.";
        version = "1.1";
        date = "02/03/2006";
    }

    public Diagnosis check(){
        Diagnosis diagnosis = new Diagnosis();
        diagnosis.hasProblems=false;
        Connection connection = MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps;
        ResultSet rs;

        try {
            ps = connection.prepareStatement("SELECT COUNT(*) total, personId FROM Healthrecord GROUP BY personId ORDER BY total DESC");
            rs = ps.executeQuery();
            while (rs.next()){
                if (rs.getInt("total")>1){
                    diagnosis.values.add(new Integer(rs.getInt("personId")));
                    diagnosis.hasProblems=true;
                }
                else {
                    break;
                }
            }
            rs.close();
            ps.close();
            
            ps = connection.prepareStatement("SELECT COUNT(*) total FROM Healthrecord WHERE serverid <> ?");
            ps.setInt(1,MedwanQuery.getInstance().getConfigInt("serverId"));
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>0){
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();

            String sQuery = "SELECT COUNT(*) total FROM Healthrecord a "+
                            " WHERE personId < 0"+
                            "  AND NOT EXISTS(SELECT b.personid FROM AdminView b WHERE a.personId=b.personid)";
            ps = connection.prepareStatement(sQuery);
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>0){
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
        }
        catch (SQLException e) {
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
        PreparedStatement ps,ps2;
        ResultSet rs;

        try {
            for (int n=0; n<diagnosis.values.size(); n++){
                // We gaan eerst het blijvende dossier voor elke van deze dubbele personId's opzoeken
                int personId = ((Integer)diagnosis.values.elementAt(n)).intValue();
                ps = connection.prepareStatement("select healthRecordId from Healthrecord where personId=? and serverid=?");
                ps.setInt(1,personId);
                ps.setInt(2,MedwanQuery.getInstance().getConfigInt("serverId"));
                rs = ps.executeQuery();

                if (rs.next()){
                    int goodHealthRecordId = rs.getInt("healthRecordId");
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement("select healthRecordId from Healthrecord where personId=? and healthRecordId<>?");
                    ps.setInt(1,personId);
                    ps.setInt(2,goodHealthRecordId);
                    rs = ps.executeQuery();

                    while (rs.next()){
                        ps2 = connection.prepareStatement("update Transactions set healthRecordId=? where healthRecordId=?");
                        ps2.setInt(1,goodHealthRecordId);
                        ps2.setInt(2,rs.getInt("healthRecordId"));
                        ps2.executeUpdate();
                        ps2 = connection.prepareStatement("delete from Healthrecord where healthRecordId=?");
                        ps2.setInt(1,rs.getInt("healthRecordId"));
                        ps2.executeUpdate();
                        ps2.close();
                    }
                    rs.close();
                    ps.close();
                }else{
                    rs.close();
                    ps.close();
                }
            }

            ps = connection.prepareStatement("update Healthrecord set serverid=? where serverid<>?");
            ps.setInt(1,MedwanQuery.getInstance().getConfigInt("serverId"));
            ps.setInt(2,MedwanQuery.getInstance().getConfigInt("serverId"));
            ps.executeUpdate();
            ps.close();

            ps = connection.prepareStatement("Delete Healthrecord FROM Healthrecord a WHERE personId<0 and not exists(select b.personId from AdminView b where a.personId=b.personid)");
            ps.executeUpdate();
            ps.close();
        }
        catch (SQLException e) {
            correct = false;
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
}
