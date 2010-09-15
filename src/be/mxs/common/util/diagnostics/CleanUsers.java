package be.mxs.common.util.diagnostics;

import be.mxs.common.util.db.MedwanQuery;

import java.sql.*;

/**
 * Created by IntelliJ IDEA.
 * User: frank
 * Date: 7-okt-2005
 * Time: 13:05:14
 * To change this template use Options | File Templates.
 */
public class CleanUsers extends Diagnostic{
    public CleanUsers(){
        name="CheckUsersTable";
        id="MXS.2";
        author="frank.verbeke@mxs.be";
        description="Checks if there are no double User records. Corrects if there are.";
        version="1.0";
        date="12/10/2005";
    }

    public Diagnosis check(){
        Diagnosis diagnosis = new Diagnosis();
        Connection connection=MedwanQuery.getInstance().getAdminConnection();
        PreparedStatement ps;
        ResultSet rs;
        try {
            ps = connection.prepareStatement("select count(*) total,userid from Users group by userid order by total DESC");
            rs=ps.executeQuery();
            while (rs.next()){
                if (rs.getInt("total")>1){
                    diagnosis.values.add(new Integer(rs.getInt("userid")));
                    diagnosis.hasProblems=true;
                }
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
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
        boolean correct=true;
        Connection connection = MedwanQuery.getInstance().getAdminConnection();
        PreparedStatement ps;
        ResultSet rs;
        try {
            for (int n=0;n<diagnosis.values.size();n++){
                //We gaan eerst de blijvende gebruiker voor elke van deze dubbele userid's opzoeken
                int userid=((Integer)diagnosis.values.elementAt(n)).intValue();
                ps = connection.prepareStatement("select a.* from Users a,Admin b where a.personid=b.personid and userid=? order by a.updatetime DESC");
                ps.setInt(1,userid);
                rs=ps.executeQuery();
                if (rs.next()){
                    int goodPersonId = rs.getInt("personid");
                    int goodUserId=rs.getInt("userid");
                    Timestamp goodStart = rs.getTimestamp("start");
                    Timestamp goodStop = rs.getTimestamp("stop");
                    Timestamp goodUpdatetime = rs.getTimestamp("updatetime");
                    String goodProject=rs.getString("project");
                    byte[] goodPassword = rs.getBytes("encryptedpassword");
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement("delete from Users where userid=?");
                    ps.setInt(1,userid);
                    ps.execute();
                    ps = connection.prepareStatement("insert into Users(userid,personid,start,stop,updatetime,project,encryptedpassword) values(?,?,?,?,?,?,?)");
                    ps.setInt(1,goodUserId);
                    ps.setInt(2,goodPersonId);
                    ps.setTimestamp(3,goodStart);
                    ps.setTimestamp(4,goodStop);
                    ps.setTimestamp(5,goodUpdatetime);
                    ps.setString(6,goodProject);
                    ps.setBytes(7,goodPassword);
                    ps.execute();
                    ps.close();
                }
                else {
                    rs.close();
                    ps.close();
                }
            }
        } catch (SQLException e) {
            correct=false;
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
