package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;

import org.dom4j.Document;
import org.dom4j.DocumentHelper;
import org.dom4j.Element;

import be.mxs.common.util.db.MedwanQuery;

public class ExportMessage extends DatacenterMessage{
	
	public void updateSentDateTime(Date sentDateTime){
		setSentDateTime(sentDateTime);
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_EXPORTS set OC_EXPORT_SENTDATETIME=? where OC_EXPORT_OBJECTID=?");
			ps.setTimestamp(1, new java.sql.Timestamp(sentDateTime.getTime()));
			ps.setInt(2, objectId);
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void updateAckDateTime(Date ackDateTime){
		setAckDateTime(ackDateTime);
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_EXPORTS set OC_EXPORT_ACKDATETIME=? where OC_EXPORT_OBJECTID=?");
			ps.setTimestamp(1, new java.sql.Timestamp(ackDateTime.getTime()));
			ps.setInt(2, objectId);
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public static void updateAckDateTime(int objectId,Date ackDateTime){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_EXPORTS set OC_EXPORT_ACKDATETIME=? where OC_EXPORT_OBJECTID=?");
			ps.setTimestamp(1, new java.sql.Timestamp(ackDateTime.getTime()));
			ps.setInt(2, objectId);
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void updateImportAckDateTime(Date ackDateTime){
		setImportAckDateTime(ackDateTime);
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_EXPORTS set OC_EXPORT_IMPORTACKDATETIME=? where OC_EXPORT_OBJECTID=?");
			ps.setTimestamp(1, new java.sql.Timestamp(ackDateTime.getTime()));
			ps.setInt(2, objectId);
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public static void updateImportAckDateTime(int objectId, Date ackDateTime){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_EXPORTS set OC_EXPORT_IMPORTACKDATETIME=? where OC_EXPORT_OBJECTID=?");
			ps.setTimestamp(1, new java.sql.Timestamp(ackDateTime.getTime()));
			ps.setInt(2, objectId);
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void updateImportDateTime(Date ackDateTime){
		setImportDateTime(ackDateTime);
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_EXPORTS set OC_EXPORT_IMPORTDATETIME=? where OC_EXPORT_OBJECTID=?");
			ps.setTimestamp(1, new java.sql.Timestamp(ackDateTime.getTime()));
			ps.setInt(2, objectId);
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public static void updateImportDateTime(int objectId, Date ackDateTime){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_EXPORTS set OC_EXPORT_IMPORTDATETIME=? where OC_EXPORT_OBJECTID=?");
			ps.setTimestamp(1, new java.sql.Timestamp(ackDateTime.getTime()));
			ps.setInt(2, objectId);
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public static void updateErrorCode(int objectId,int error){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		try{
			ps = conn.prepareStatement("update OC_EXPORTS set OC_EXPORT_ERRORCODE=? where OC_EXPORT_OBJECTID=?");
			ps.setInt(1, error);
			ps.setInt(2, objectId);
			ps.executeUpdate();
			ps.close();
		}
		catch(Exception e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		}
		finally {
			try {
				conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public String asXML(){
        String msg ="<data serverid='"+getServerId()
    	+"' objectid='"+getObjectId()
    	+"' parameterid='"+getMessageId()
    	+"' createdatetime='"+new SimpleDateFormat("yyyyMMddHHmmss").format(getCreateDateTime())
    	+"' sentdatetime='"+new SimpleDateFormat("yyyyMMddHHmmss").format(getSentDateTime())+"'>"
    	+getData()+"</data>";
        return msg;
	}
	
}
