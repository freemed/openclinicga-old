package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;

public abstract class Sender {
	Vector messages;
	Date deadline;
	
	public Vector getMessages() {
		return messages;
	}

	public void setMessages(Vector messages) {
		this.messages = messages;
	}

	public Date getDeadline() {
		return deadline;
	}

	public void setDeadline(Date deadline) {
		this.deadline = deadline;
	}

	public void loadMessages(){
		int maxMessages = MedwanQuery.getInstance().getConfigInt("datacenterMaxMessagesSent",100), counter=0;
		messages = new Vector();
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=null;
		ResultSet rs=null;
		try{
			ps = conn.prepareStatement("select * from OC_EXPORTS where OC_EXPORT_SENTDATETIME is NULL order by OC_EXPORT_CREATEDATETIME");
			rs=ps.executeQuery();
			while(rs.next() && counter<maxMessages){
				counter++;
				ExportMessage exportMessage = new ExportMessage();
				exportMessage.setObjectId(rs.getInt("OC_EXPORT_OBJECTID"));
				exportMessage.setMessageId(rs.getString("OC_EXPORT_ID"));
				exportMessage.setCreateDateTime(rs.getTimestamp("OC_EXPORT_CREATEDATETIME"));
				exportMessage.setData(rs.getString("OC_EXPORT_DATA"));
				messages.add(exportMessage);
			}
			rs.close();
			ps.close();
		}
		catch(Exception e){
			try {
				if(rs!=null){
					rs.close();
				}
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
	
	public abstract void send();
}
