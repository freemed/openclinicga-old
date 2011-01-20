package be.openclinic.datacenter;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.SortedMap;
import java.util.TreeMap;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

public class ExporterEncounter extends Exporter {

	public void export(){
		if(getParam().equalsIgnoreCase("encounter.1")){
			//Export a summary of bed occupancy
			StringBuffer sb = new StringBuffer("<services>");
			String serviceuid;
			SortedMap admissionServices = new TreeMap();
			Hashtable occupiedServices = new Hashtable();
			Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection(), oc_conn2;
			Date date = new Date();
			try {
				PreparedStatement ps = oc_conn.prepareStatement("select * from OC_EXPORTS where OC_EXPORT_ID='encounter.1' and OC_EXPORT_CREATEDATETIME>=?");
				ps.setTimestamp(1, new java.sql.Timestamp(getDeadline().getTime()));
				ResultSet rs = ps.executeQuery();
				if(!rs.next()){
					rs.close();
					ps.close();
					oc_conn.close();
					boolean bGo=true;
					while(bGo){
						oc_conn = MedwanQuery.getInstance().getAdminConnection();
						bGo=false;
						ps = oc_conn.prepareStatement("select serviceid from services where serviceparentid is not null and serviceparentid<>'' and not serviceparentid in (select serviceid from services)");
						rs = ps.executeQuery();
						while(rs.next()){
							bGo=true;
							oc_conn2 = MedwanQuery.getInstance().getAdminConnection();
							PreparedStatement ps2 = oc_conn2.prepareStatement("delete from Services where serviceid=?");
							ps2.setString(1, rs.getString("serviceid"));
							ps2.execute();
							ps2.close();
							oc_conn2.close();
						}
						rs.close();
						ps.close();
						oc_conn.close();
					}
					bGo=true;
					while(bGo){
						oc_conn = MedwanQuery.getInstance().getAdminConnection();
						bGo=false;
						ps = oc_conn.prepareStatement("select serviceid from services where totalbeds>0 and serviceparentid is not null and serviceparentid<>'' and not serviceparentid in (select serviceid from services where inactive=0)");
						rs = ps.executeQuery();
						while(rs.next()){
							bGo=true;
							oc_conn2 = MedwanQuery.getInstance().getAdminConnection();
							PreparedStatement ps2 = oc_conn2.prepareStatement("update Services set totalbeds=0 where serviceid=?");
							ps2.setString(1, rs.getString("serviceid"));
							ps2.execute();
							ps2.close();
							oc_conn2.close();
						}
						rs.close();
						ps.close();
						oc_conn.close();
					}
					bGo=true;
					while(bGo){
						oc_conn = MedwanQuery.getInstance().getAdminConnection();
						bGo=false;
						ps = oc_conn.prepareStatement("select serviceid from services where totalbeds>0 and inactive=1");
						rs = ps.executeQuery();
						while(rs.next()){
							bGo=true;
							oc_conn2 = MedwanQuery.getInstance().getAdminConnection();
							PreparedStatement ps2 = oc_conn2.prepareStatement("update Services set totalbeds=0 where serviceid=?");
							ps2.setString(1, rs.getString("serviceid"));
							ps2.execute();
							ps2.close();
							oc_conn2.close();
						}
						rs.close();
						ps.close();
						oc_conn.close();
					}
					
					oc_conn = MedwanQuery.getInstance().getAdminConnection();
					ps = oc_conn.prepareStatement("select * from services where totalbeds>0");
					rs = ps.executeQuery();
					while(rs.next()){
						admissionServices.put(rs.getString("serviceid"), new Integer(rs.getInt("totalbeds")));
					}
					rs.close();
					ps.close();
					oc_conn.close();
					oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
					ps=oc_conn.prepareStatement("select oc_encounter_serviceuid,count(*) total from oc_encounter_services a,oc_encounters b where a.oc_encounter_serverid=b.oc_encounter_serverid and a.oc_encounter_objectid=b.oc_encounter_objectid and oc_encounter_serviceenddate is null and oc_encounter_type='admission' group by oc_encounter_serviceuid");
					rs = ps.executeQuery();
					while(rs.next()){
						occupiedServices.put(rs.getString("oc_encounter_serviceuid"), new Integer(rs.getInt("total")));
					}
					Iterator iterator = admissionServices.keySet().iterator();
					while(iterator.hasNext()){
						String key = (String)iterator.next();
						String service = key+";"+ScreenHelper.getTran("service",key,"FR");
						sb.append("<service serviceid='"+service.replaceAll("'", "")+"' date='"+new SimpleDateFormat("yyyyMMddHHmmss").format(date)+"' totalbeds='"+admissionServices.get(key)+"' occupiedbeds='"+(occupiedServices.get(key)==null?0:occupiedServices.get(key))+"'/>");
					}
					sb.append("</services>");
					exportSingleValue(sb.toString(), "encounter.1");
				}
			} catch (SQLException e) {
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
