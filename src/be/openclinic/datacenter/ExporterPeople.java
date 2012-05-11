package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import org.apache.commons.codec.binary.Base64;

import net.admin.AdminPerson;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Picture;

public class ExporterPeople extends Exporter {

	public void export(){
		if(!mustExport(getParam())){
			return;
		}
		if(getParam().equalsIgnoreCase("people.patients")){
			StringBuffer sb = new StringBuffer("<patients>");
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("update OC_EXPORTREQUESTS set OC_EXPORTREQUEST_PROCESSED=0 where OC_EXPORTREQUEST_TYPE='patient' and (OC_EXPORTREQUEST_PROCESSED is null or OC_EXPORTREQUEST_PROCESSED<2)");
				ps.execute();
				ps.close();
				boolean bHasPatients=false;
				ps = oc_conn.prepareStatement("select * from OC_EXPORTREQUESTS where OC_EXPORTREQUEST_TYPE='patient' and (OC_EXPORTREQUEST_PROCESSED is null or OC_EXPORTREQUEST_PROCESSED<2)");
				ResultSet rs = ps.executeQuery();
				while (rs.next()){
					bHasPatients=true;
					int personid=rs.getInt("OC_EXPORTREQUEST_ID");
					AdminPerson patient = AdminPerson.getAdminPerson(personid+"");
					//Here we will export relevant patient data
					sb.append("<patient id='"+personid+"'>");
					sb.append("<firstname>"+patient.firstname+"</firstname>");
					sb.append("<lastname>"+patient.lastname+"</lastname>");
					sb.append("<dateofbirth>"+patient.dateOfBirth+"</dateofbirth>");
					sb.append("<gender>"+patient.gender+"</gender>");
					sb.append("<archivefile>"+patient.getID("archiveFileCode")+"</archivefile>");
					if(Picture.exists(Integer.parseInt(patient.personid))){
						Picture picture = new Picture(Integer.parseInt(patient.personid));
						if(picture!=null){
							sb.append("<picture><![CDATA["+javax.mail.internet.MimeUtility.encodeText(new String(picture.getPicture(),"iso-8859-1"),"iso-8859-1",null)+"]]></picture>");
						}
					}
					sb.append("</patient>");
					
					PreparedStatement ps2 = oc_conn.prepareStatement("update OC_EXPORTREQUESTS set OC_EXPORTREQUEST_PROCESSED=1 where OC_EXPORTREQUEST_TYPE='patient' and OC_EXPORTREQUEST_ID=?");
					ps2.setString(1, personid+"");
					ps2.execute();
					ps2.close();
				}
				rs.close();
				ps.close();
				sb.append("</patients>");
				if(bHasPatients){
					if(exportSingleValue(sb.toString(),"people.patients")){
						ps = oc_conn.prepareStatement("UPDATE OC_EXPORTREQUESTS set OC_EXPORTREQUEST_PROCESSED=2, OC_EXPORTREQUEST_UPDATETIME=? where OC_EXPORTREQUEST_PROCESSED=1 and OC_EXPORTREQUEST_TYPE='patient'");
						ps.setTimestamp(1, new java.sql.Timestamp(new java.util.Date().getTime()));
						ps.execute();
						ps.close();
					}
				}
			} catch (Exception e) {
				e.printStackTrace();
			}
			finally {
				try {
					oc_conn.close();
				} catch (SQLException e) {
					e.printStackTrace();
				}
			}
		}
	}
}
