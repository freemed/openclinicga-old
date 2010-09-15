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
public class CleanAdminPrivate extends Diagnostic{
    public CleanAdminPrivate(){
        name="CheckAdminPrivateTable";
        id="MXS.4";
        author="frank.verbeke@mxs.be";
        description="Checks if there are no double AdminPrivate records. Corrects if there are.";
        version="1.0";
        date="17/10/2005";
    }

    public Diagnosis check(){
        final Diagnosis diagnosis = new Diagnosis();
        final Connection connection=MedwanQuery.getInstance().getAdminConnection();
        PreparedStatement ps;
        ResultSet rs;
        try {
            ps = connection.prepareStatement("select count(*) total,personid from AdminPrivate where stop is null group by personid having count(*)>1 order by total DESC");
            rs=ps.executeQuery();
            while (rs.next()){
                diagnosis.values.add(new Integer(rs.getInt("personid")));
                diagnosis.hasProblems=true;
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use Options | File Templates.
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
        final Connection connection = MedwanQuery.getInstance().getAdminConnection();
        PreparedStatement ps;
        ResultSet rs;
        try {
            for (int n=0;n<diagnosis.values.size();n++){
                //We gaan eerst de blijvende record voor elke van deze dubbele personid's opzoeken
                final int personid=((Integer)diagnosis.values.elementAt(n)).intValue();
                ps = connection.prepareStatement("select * from AdminPrivate where personid=? and stop is null order by updatetime DESC");
                ps.setInt(1,personid);
                rs=ps.executeQuery();
                if (rs.next()){
                    final int goodPrivateId = rs.getInt("privateid");
                    final int goodPersonid=rs.getInt("personid");
                    final Timestamp goodStart = rs.getTimestamp("start");
                    final Timestamp goodStop = rs.getTimestamp("stop");
                    final String goodAddress = rs.getString("address");
                    final String goodCity = rs.getString("city");
                    final String goodZipcode = rs.getString("zipcode");
                    final String goodCountry = rs.getString("country");
                    final String goodTelephone = rs.getString("telephone");
                    final String goodFax = rs.getString("fax");
                    final String goodMobile = rs.getString("mobile");
                    final String goodEmail = rs.getString("email");
                    final String goodComment = rs.getString("comment");
                    final Timestamp goodUpdatetime = rs.getTimestamp("updatetime");
                    final String goodType = rs.getString("type");
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement("delete from AdminPrivate where personid=? and stop is null");
                    ps.setInt(1,goodPersonid);
                    ps.execute();
                    ps.close();
                    ps = connection.prepareStatement("insert into AdminPrivate(privateid,personid,start,stop,address,city,zipcode,country,telephone,fax,mobile,email,comment,updatetime,type) values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)");
                    ps.setInt(1,goodPrivateId);
                    ps.setInt(2,goodPersonid);
                    ps.setTimestamp(3,goodStart);
                    ps.setTimestamp(4,goodStop);
                    ps.setString(5,goodAddress);
                    ps.setString(6,goodCity);
                    ps.setString(7,goodZipcode);
                    ps.setString(8,goodCountry);
                    ps.setString(9,goodTelephone);
                    ps.setString(10,goodFax);
                    ps.setString(11,goodMobile);
                    ps.setString(12,goodEmail);
                    ps.setString(13,goodComment);
                    ps.setTimestamp(14,goodUpdatetime);
                    ps.setString(15,goodType);
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
            e.printStackTrace();  //To change body of catch statement use Options | File Templates.
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
