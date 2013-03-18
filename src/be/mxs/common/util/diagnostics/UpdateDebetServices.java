package be.mxs.common.util.diagnostics;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.finance.Debet;

public class UpdateDebetServices {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		int batchsize=1000;
		String sDatabaseType="";
		try{
			Connection conn =  DriverManager.getConnection(args[0]);
			sDatabaseType=conn.getMetaData().getDatabaseProductName();
			conn.close();
		}
		catch (Exception e){
			e.printStackTrace();
		}
		String sQuery="select top "+batchsize+" * from OC_DEBETS where OC_DEBET_SERVICEUID is null";
		if(sDatabaseType.contains("MySQL")){
			sQuery="select * from OC_DEBETS where OC_DEBET_SERVICEUID is null limit "+batchsize;
		}
		int totalupdated=0;
		while (true){
			int counter=0;
			try{
				Connection conn =  DriverManager.getConnection(args[0]);
				PreparedStatement ps = conn.prepareStatement(sQuery);
				ResultSet rs = ps.executeQuery();
				while (rs.next() && counter<batchsize){
					counter++;
					boolean bDone=false;
					String serviceuid="";
					String prestationuid = rs.getString("OC_DEBET_PRESTATIONUID");
					if(prestationuid!=null && prestationuid.split("\\.").length>1){
						PreparedStatement ps2 = conn.prepareStatement("select * from OC_PRESTATIONS where OC_PRESTATION_OBJECTID=?");
						ps2.setInt(1, Integer.parseInt(prestationuid.split("\\.")[1]));
						ResultSet rs2 = ps2.executeQuery();
						if(rs2.next()){
							serviceuid = ScreenHelper.checkString(rs2.getString("OC_PRESTATION_SERVICEUID"));
							if(serviceuid.length()>0){
								bDone=true;
							}
						}
						rs2.close();
						ps2.close();
					}
					if(!bDone){
						String encounteruid = rs.getString("OC_DEBET_ENCOUNTERUID");
						if(encounteruid!=null && encounteruid.split("\\.").length>1){
							PreparedStatement ps2 = conn.prepareStatement("select * from OC_ENCOUNTERS_VIEW where OC_ENCOUNTER_OBJECTID=? and OC_ENCOUNTER_SERVICEUID is not null");
							ps2.setInt(1, Integer.parseInt(encounteruid.split("\\.")[1]));
							ResultSet rs2 = ps2.executeQuery();
							if(rs2.next()){
								serviceuid = ScreenHelper.checkString(rs2.getString("OC_ENCOUNTER_SERVICEUID"));
							}
							rs2.close();
							ps2.close();
						}
					}
					PreparedStatement ps2=conn.prepareStatement("UPDATE OC_DEBETS set OC_DEBET_SERVICEUID=? where OC_DEBET_OBJECTID=?");
					ps2.setString(1, serviceuid);
					ps2.setInt(2, rs.getInt("OC_DEBET_OBJECTID"));
					ps2.executeUpdate();
					ps2.close();
					Thread.sleep(50);
				}
				rs.close();
				ps.close();
				conn.close();
				totalupdated+=counter;
				System.out.println("Total number of Debets updated: "+totalupdated);
			}
			catch (Exception e){
				e.printStackTrace();
			}
			if(counter < batchsize){
				break;
			}
		}

	}

}
