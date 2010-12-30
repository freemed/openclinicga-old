package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;

import java.sql.PreparedStatement;

import be.mxs.common.util.db.MedwanQuery;

public class DatacenterHelper {
	public static String getLastSimpleValue(int serverid,String parameterid){
		String value="?";
		Connection conn=MedwanQuery.getInstance().getStatsConnection();
		try{
			PreparedStatement ps = conn.prepareStatement("select max(DC_SIMPLEVALUE_CREATEDATETIME) lastcreate from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_PARAMETERID=?");
			ps.setInt(1, serverid);
			ps.setString(2, parameterid);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				java.sql.Timestamp lastcreate= rs.getTimestamp("lastcreate");
				rs.close();
				ps.close();
				ps = conn.prepareStatement("select DC_SIMPLEVALUE_DATA from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_PARAMETERID=? and DC_SIMPLEVALUE_CREATEDATETIME=?");
				ps.setInt(1, serverid);
				ps.setString(2, parameterid);
				ps.setTimestamp(3, lastcreate);
				rs = ps.executeQuery();
				if(rs.next()){
					value=rs.getString("DC_SIMPLEVALUE_DATA");
				}
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
		return value;
	}
}
