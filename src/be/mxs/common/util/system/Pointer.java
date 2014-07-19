package be.mxs.common.util.system;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;

public class Pointer {
	
	public static Vector getPointers(String key){
		Vector pointers = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("select OC_POINTER_VALUE from OC_POINTERS where OC_POINTER_KEY=? order by OC_POINTER_VALUE");
			ps.setString(1, key);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				pointers.add(rs.getString("OC_POINTER_VALUE"));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return pointers;
	}
	
	public static Vector getFullPointers(String key){
		Vector pointers = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("select OC_POINTER_VALUE,OC_POINTER_UPDATETIME from OC_POINTERS where OC_POINTER_KEY=? order by OC_POINTER_VALUE");
			ps.setString(1, key);
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				pointers.add(rs.getString("OC_POINTER_VALUE")+";"+new SimpleDateFormat("yyyyMMddHHmmSSsss").format(rs.getTimestamp("OC_POINTER_UPDATETIME")));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return pointers;
	}
	
	public static String getPointer(String key){
		String pointer = "";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("select OC_POINTER_VALUE from OC_POINTERS where OC_POINTER_KEY=?");
			ps.setString(1, key);
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				pointer=rs.getString("OC_POINTER_VALUE");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return pointer;
	}
	
	public static String getLastPointer(String key){
		String pointer = "";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("select OC_POINTER_VALUE from OC_POINTERS where OC_POINTER_KEY like ? order by OC_POINTER_UPDATETIME DESC");
			ps.setString(1, key+"%");
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				pointer=rs.getString("OC_POINTER_VALUE");
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return pointer;
	}
	
	public static Vector getPointers(String key,java.util.Date start, java.util.Date end){
		Vector pointers = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("select OC_POINTER_VALUE from OC_POINTERS where OC_POINTER_KEY=? and OC_POINTER_UPDATETIME between ? and ? order by OC_POINTER_VALUE");
			ps.setString(1, key);
			ps.setTimestamp(2, new java.sql.Timestamp(start.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				pointers.add(rs.getString("OC_POINTER_VALUE"));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return pointers;
	}
	
	public static Vector getLoosePointers(String key,java.util.Date start, java.util.Date end){
		Vector pointers = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("select OC_POINTER_VALUE from OC_POINTERS where OC_POINTER_KEY like ? and OC_POINTER_UPDATETIME between ? and ? order by OC_POINTER_VALUE");
			ps.setString(1, key+"%");
			ps.setTimestamp(2, new java.sql.Timestamp(start.getTime()));
			ps.setTimestamp(3, new java.sql.Timestamp(end.getTime()));
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				pointers.add(rs.getString("OC_POINTER_VALUE"));
			}
			rs.close();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		return pointers;
	}
	
	public static void deletePointers(String key){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("DELETE from OC_POINTERS where OC_POINTER_KEY=?");
			ps.setString(1, key);
			ps.execute();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public static void deleteLoosePointers(String key){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("DELETE from OC_POINTERS where OC_POINTER_KEY like ?");
			ps.setString(1, key+"%");
			ps.execute();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public static void storePointer(String key,String value){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("INSERT INTO OC_POINTERS(OC_POINTER_KEY,OC_POINTER_VALUE,OC_POINTER_UPDATETIME) values(?,?,?)");
			ps.setString(1, key);
			ps.setString(2, value);
			ps.setTimestamp(3, new java.sql.Timestamp(new java.util.Date().getTime()));
			ps.execute();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public static void storePointer(String key,String value,java.util.Date updatetime){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("INSERT INTO OC_POINTERS(OC_POINTER_KEY,OC_POINTER_VALUE,OC_POINTER_UPDATETIME) values(?,?,?)");
			ps.setString(1, key);
			ps.setString(2, value);
			ps.setTimestamp(3, new java.sql.Timestamp(updatetime.getTime()));
			ps.execute();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
	public static void storeUniquePointer(String key,String value,java.util.Date updatetime){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		try{
			ps=conn.prepareStatement("select * from OC_POINTERS where OC_POINTER_KEY=? and OC_POINTER_VALUE=?");
			ps.setString(1, key);
			ps.setString(2, value);
			ResultSet rs = ps.executeQuery();
			if(!rs.next()){
				rs.close();
				ps.close();
				ps=conn.prepareStatement("INSERT INTO OC_POINTERS(OC_POINTER_KEY,OC_POINTER_VALUE,OC_POINTER_UPDATETIME) values(?,?,?)");
				ps.setString(1, key);
				ps.setString(2, value);
				ps.setTimestamp(3, new java.sql.Timestamp(updatetime.getTime()));
				ps.execute();
				ps.close();
			}
			else {
				rs.close();
				ps.close();
			}
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
	
}
