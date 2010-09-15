package be.openclinic.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Iterator;
import java.util.SortedSet;
import java.util.TreeSet;
import java.util.Vector;

import be.mxs.common.util.db.MedwanQuery;
import be.openclinic.adt.Encounter;

public class ProcessClusters {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		String encounterUid,sQuery,sOutcome,sCluster,sQuery2;
		int nMortality,nIcd10Gravity,nIcpcGravity,nYear;
		PreparedStatement ps, ps2;
		ResultSet rs,rs2;
		Vector diagnoses;
		SortedSet icd10set,icpcset,kpgsset;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
		try{
			sQuery="select * from OC_ENCOUNTERS where OC_ENCOUNTER_PROCESSED is null";
			ps = oc_conn.prepareStatement(sQuery);
			rs = ps.executeQuery();
			while (rs.next()){
				//Voor elk van deze encounters gaan we nu de bijhorende diagnoses opzoeken
				encounterUid=rs.getString("OC_ENCOUNTER_SERVERID")+"."+rs.getString("OC_ENCOUNTER_OBJECTID");
				System.out.println("Processing encounter "+encounterUid);
				if(rs.getString("OC_ENCOUNTER_OUTCOME").equalsIgnoreCase("dead")){
					nMortality=1;
				}
				else {
					nMortality=0;
				}
				nYear=0;
				try{
					nYear=Integer.parseInt(new SimpleDateFormat("yyyy").format(rs.getDate("OC_ENCOUNTER_BEGINDATE")));
				}
				catch(Exception r){
					r.printStackTrace();
				}
				diagnoses=new Vector();
				sQuery="select * from OC_DIAGNOSES where OC_DIAGNOSIS_ENCOUNTERUID=?";
				ps2=oc_conn.prepareStatement(sQuery);
				ps2.setString(1, encounterUid);
				rs2=ps2.executeQuery();
				while (rs2.next()){
					diagnoses.add(new Diagnosis(rs2.getString("OC_DIAGNOSIS_CODETYPE"),rs2.getString("OC_DIAGNOSIS_CODE"),rs2.getInt("OC_DIAGNOSIS_GRAVITY")));
				}
				rs2.close();
				ps2.close();
				//Nu hebben we de encounter en zijn bijhorende diagnoses, we zoeken op of deze combinatie reeds bestaat
				//We bouwen icd-10, icpc-2 en kpgs clusters op
				icd10set = new TreeSet();
				icpcset=new TreeSet();
				kpgsset=new TreeSet();
				nIcd10Gravity=0;
				nIcpcGravity=0;
				for (int n=0;n<diagnoses.size();n++){
					Diagnosis diagnosis = (Diagnosis)diagnoses.elementAt(n);
					if(diagnosis.sCodeType.equalsIgnoreCase("icd10")){
						icd10set.add(diagnosis.sCode);
						nIcd10Gravity+=diagnosis.nGravity;
					}
					else if(diagnosis.sCodeType.equalsIgnoreCase("icpc")){
						icpcset.add(diagnosis.sCode);
						nIcpcGravity+=diagnosis.nGravity;
					}
					//todo: kpgs clusters
				}
				//We verifiëren eerst het bestaan van de icd10 cluster
				sCluster="";
				Iterator i = icd10set.iterator();
				while (i.hasNext()){
					if(sCluster.length()>0){
						sCluster+="$";
					}
					sCluster+=i.next();
				}
				sQuery = "select * from OC_DIAG_CLUSTERS where OC_CLUSTER_DIAGTYPE='icd10' and OC_CLUSTER_DATA=? and OC_CLUSTER_YEAR=?";
				ps2=oc_conn.prepareStatement(sQuery);
				ps2.setString(1, sCluster);
				ps2.setInt(2,nYear);
				rs2=ps2.executeQuery();
				if(rs2.next()){
					rs2.close();
					ps2.close();
					sQuery="update OC_DIAG_CLUSTERS set OC_CLUSTER_MORTALITY=OC_CLUSTER_MORTALITY+?, OC_CLUSTER_GRAVITY=OC_CLUSTER_GRAVITY+?,OC_CLUSTER_COUNT=OC_CLUSTER_COUNT+1 "+
							" WHERE OC_CLUSTER_DIAGTYPE='icd10' and OC_CLUSTER_DATA=? and OC_CLUSTER_YEAR=?";
				}
				else {
					rs2.close();
					ps2.close();
					//In dit geval moeten we tevens all clusterverwijzingen toevoegen
					i = icd10set.iterator();
					while(i.hasNext()){
						sQuery="insert into OC_CLUSTER_DIAGS(OC_DIAG_TYPE,OC_DIAG_CODE,OC_DIAG_CLUSTERDATA,OC_DIAG_YEAR) values ('icd10',?,?,?)";
						ps2=oc_conn.prepareStatement(sQuery);
						ps2.setString(1,(String)i.next());
						ps2.setString(2,sCluster);
						ps2.setInt(3,nYear);
						ps2.execute();
						ps2.close();
					}
					sQuery="insert into OC_DIAG_CLUSTERS(OC_CLUSTER_DIAGTYPE,OC_CLUSTER_MORTALITY,OC_CLUSTER_GRAVITY,OC_CLUSTER_DATA,OC_CLUSTER_YEAR,OC_CLUSTER_COUNT) values ('icd10',?,?,?,?,1)";
				}
				ps2=oc_conn.prepareStatement(sQuery);
				ps2.setInt(1, nMortality);
				ps2.setInt(2, nIcd10Gravity);
				ps2.setString(3, sCluster);
				ps2.setInt(4,nYear);
				ps2.execute();
				ps2.close();
				//Nu verifiëren we het bestaan van de icpc cluster
				sCluster="";
				i = icpcset.iterator();
				while (i.hasNext()){
					if(sCluster.length()>0){
						sCluster+="$";
					}
					sCluster+=i.next();
				}
				sQuery = "select * from OC_DIAG_CLUSTERS where OC_CLUSTER_DIAGTYPE='icpc' and OC_CLUSTER_DATA=? and OC_CLUSTER_YEAR=?";
				ps2=oc_conn.prepareStatement(sQuery);
				ps2.setString(1, sCluster);
				ps2.setInt(2,nYear);
				rs2=ps2.executeQuery();
				if(rs2.next()){
					rs2.close();
					ps2.close();
					sQuery="update OC_DIAG_CLUSTERS set OC_CLUSTER_MORTALITY=OC_CLUSTER_MORTALITY+?, OC_CLUSTER_GRAVITY=OC_CLUSTER_GRAVITY+?,OC_CLUSTER_COUNT=OC_CLUSTER_COUNT+1 "+
							" WHERE OC_CLUSTER_DIAGTYPE='icpc' and OC_CLUSTER_DATA=? and OC_CLUSTER_YEAR=?";
				}
				else {
					rs2.close();
					ps2.close();
					//In dit geval moeten we tevens all clusterverwijzingen toevoegen
					i = icpcset.iterator();
					while(i.hasNext()){
						sQuery="insert into OC_CLUSTER_DIAGS(OC_DIAG_TYPE,OC_DIAG_CODE,OC_DIAG_CLUSTERDATA,OC_DIAG_YEAR) values ('icpc',?,?,?)";
						ps2=oc_conn.prepareStatement(sQuery);
						ps2.setString(1,(String)i.next());
						ps2.setString(2,sCluster);
						ps2.setInt(3,nYear);
						ps2.execute();
						ps2.close();
					}
					sQuery="insert into OC_DIAG_CLUSTERS(OC_CLUSTER_DIAGTYPE,OC_CLUSTER_MORTALITY,OC_CLUSTER_GRAVITY,OC_CLUSTER_DATA,OC_CLUSTER_YEAR,OC_CLUSTER_COUNT) values ('icpc',?,?,?,?,1)";
				}
				ps2=oc_conn.prepareStatement(sQuery);
				ps2.setInt(1, nMortality);
				ps2.setInt(2, nIcpcGravity);
				ps2.setString(3, sCluster);
				ps2.setInt(4,nYear);
				ps2.execute();
				ps2.close();
				sQuery="update OC_ENCOUNTERS set OC_ENCOUNTER_PROCESSED=1 where OC_ENCOUNTER_SERVERID=? and OC_ENCOUNTER_OBJECTID=?";
				ps2=oc_conn.prepareStatement(sQuery);
				ps2.setInt(1, Integer.parseInt(encounterUid.split("\\.")[0]));
				ps2.setInt(2, Integer.parseInt(encounterUid.split("\\.")[1]));
				ps2.execute();
				ps2.close();
			}
            rs.close();
            ps.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
		try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
	

}
