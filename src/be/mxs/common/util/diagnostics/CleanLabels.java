package be.mxs.common.util.diagnostics;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.*;

/**
 * User: frank
 * Date: 7-okt-2005
 */
public class CleanLabels extends Diagnostic {
    public CleanLabels(){
        name = "CheckLabelsTable";
        id = "MXS.5";
        author = "frank.verbeke@mxs.be";
        description = "Checks if there are single quotes in the Labels table. Corrects if there are.";
        version = "1.0";
        date = "10/01/2006";
    }

    public Diagnosis check(){
        Diagnosis diagnosis = new Diagnosis();
        Connection connection = MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps;
        ResultSet rs;

        try {
            String s="%'%";
            ps = connection.prepareStatement("select count(*) total from OC_LABELS where OC_LABEL_VALUE like ?");
            ps.setString(1,s);

            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    diagnosis.hasProblems = true;
                }
            }
            rs.close();
            ps.close();
            s="%\"%";
            ps = connection.prepareStatement("select count(*) total from OC_LABELS where OC_LABEL_VALUE like ?");
            ps.setString(1,s);
            rs = ps.executeQuery();
            if (rs.next()){
                if (rs.getInt("total")>1){
                    diagnosis.hasProblems = true;
                }
            }
            rs.close();
            ps.close();
            connection.close();
        }
        catch (SQLException e) {
            e.printStackTrace();
        }

        return diagnosis;
    }

    public boolean correct(Diagnosis diagnosis){
        boolean correct = true;
        Connection connection = MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps,ps2;
        try {
            String s="%'%";
            ps = connection.prepareStatement("select * from OC_LABELS where OC_LABEL_VALUE LIKE ?");
            ps.setString(1,s);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                ps2=connection.prepareStatement("update OC_LABELS set OC_LABEL_VALUE = ? where OC_LABEL_TYPE = ? and OC_LABEL_ID = ? AND OC_LABEL_LANGUAGE = ?");
                String value = rs.getString("OC_LABEL_VALUE");
                ps2.setString(1,value!=null?value.replaceAll("\\'","´"):"");
                ps2.setString(2,rs.getString("OC_LABEL_TYPE"));
                ps2.setString(3,rs.getString("OC_LABEL_ID"));
                ps2.setString(4,rs.getString("OC_LABEL_LANGUAGE"));
                ps2.execute();
                ps2.close();
            }
            rs.close();
            ps.close();
            s="%\"%";
            ps = connection.prepareStatement("select * from OC_LABELS where OC_LABEL_VALUE like ? ");
            ps.setString(1,s);
            rs = ps.executeQuery();
            while (rs.next()){
                ps2=connection.prepareStatement("update OC_LABELS set OC_LABEL_VALUE = ? where OC_LABEL_TYPE=? and OC_LABEL_ID = ? AND OC_LABEL_LANGUAGE = ?");
                String value=rs.getString("OC_LABEL_VALUE");
                ps2.setString(1,value!=null?value.replaceAll("\"","´"):"");
                ps2.setString(2,rs.getString("OC_LABEL_TYPE"));
                ps2.setString(3,rs.getString("OC_LABEL_ID"));
                ps2.setString(4,rs.getString("OC_LABEL_LANGUAGE"));
                ps2.execute();
                ps2.close();
            }
            rs.close();
            ps.close();
            connection.close();
        }
        catch (SQLException e) {
            e.printStackTrace();
            correct=false;
        }
        return correct;
    }
}