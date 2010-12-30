package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

import javax.mail.MessagingException;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

public class Importer {

	public static void execute(){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		String parameterid,parametertype;
		try{
			ps = conn.prepareStatement("select * from OC_IMPORTS where OC_IMPORT_IMPORTDATETIME is null");
			ResultSet rs = ps.executeQuery();
			while(rs.next()){
				parameterid=rs.getString("OC_IMPORT_ID");
				parametertype=ScreenHelper.checkString((String)MedwanQuery.getInstance().getDatacenterparametertypes().get(parameterid));
				if(parametertype.equalsIgnoreCase("simplevalue")){
					ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
					importMessage.setImportDateTime(new java.util.Date());
					if(storeSimpleValue(importMessage)){
						importMessage.updateImportDateTime(importMessage.getImportDateTime());
					}
					else if(importMessage.getError()>0){
						importMessage.sendError();
					}
				}
			}
			rs.close();
			ps.close();
	        String msgid=new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
			ps = conn.prepareStatement("select * from OC_IMPORTS where OC_IMPORT_IMPORTDATETIME is not null and OC_IMPORT_IMPORTACKDATETIME is null");
			rs = ps.executeQuery();
			Vector ackMessages = new Vector();
			while(rs.next()){
				ImportMessage importMessage = ImportMessage.get(rs.getInt("OC_IMPORT_UID"));
				ackMessages.add(importMessage);
			}
			ImportMessage.sendImportAck(ackMessages);
			rs.close();
		}
		catch(SQLException e){
			try {
				if(ps!=null){
					ps.close();
				}
			} catch (SQLException e2) {
				// TODO Auto-generated catch block
				e2.printStackTrace();
			}
			e.printStackTrace();
		} catch (MessagingException e) {
			// TODO Auto-generated catch block
        	Debug.println(e.getMessage());
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
	
	public static boolean storeSimpleValue(ImportMessage importMessage){
		boolean bSuccess=false;
		importMessage.setError(-1);
		Connection conn = MedwanQuery.getInstance().getStatsConnection();
		PreparedStatement ps=null;
		try{
			ps=conn.prepareStatement("SELECT * from DC_SIMPLEVALUES where DC_SIMPLEVALUE_SERVERID=? and DC_SIMPLEVALUE_OBJECTID=?");
			ps.setInt(1,importMessage.getServerId());
			ps.setInt(2, importMessage.getObjectId());
			ResultSet rs = ps.executeQuery();
			if(rs.next()){
				rs.close();
				importMessage.updateErrorCode(1);
			}
			else {
				rs.close();
				ps.close();
				ps=conn.prepareStatement("INSERT INTO DC_SIMPLEVALUES(DC_SIMPLEVALUE_SERVERID,DC_SIMPLEVALUE_OBJECTID,DC_SIMPLEVALUE_PARAMETERID," +
						"DC_SIMPLEVALUE_CREATEDATETIME,DC_SIMPLEVALUE_SENTDATETIME," +
						"DC_SIMPLEVALUE_RECEIVEDATETIME,DC_SIMPLEVALUE_IMPORTDATETIME,DC_SIMPLEVALUE_DATA) " +
						"values (?,?,?,?,?,?,?,?)");
				ps.setInt(1,importMessage.getServerId());
				ps.setInt(2, importMessage.getObjectId());
				ps.setString(3, importMessage.getMessageId());
				ps.setTimestamp(4,importMessage.getCreateDateTime()==null?null:new java.sql.Timestamp(importMessage.getCreateDateTime().getTime()));
				ps.setTimestamp(5,importMessage.getSentDateTime()==null?null:new java.sql.Timestamp(importMessage.getSentDateTime().getTime()));
				ps.setTimestamp(6,importMessage.getReceiveDateTime()==null?null:new java.sql.Timestamp(importMessage.getReceiveDateTime().getTime()));
				ps.setTimestamp(7,importMessage.getImportDateTime()==null?null:new java.sql.Timestamp(importMessage.getImportDateTime().getTime()));
				ps.setString(8, importMessage.getData());
				ps.executeUpdate();
				importMessage.updateErrorCode(0);
				bSuccess=true;
			}
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
		return bSuccess;
	}
}
