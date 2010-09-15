package be.openclinic.statistics;

import be.mxs.common.util.db.MedwanQuery;

import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;




public class DistrictStats {

    public static class ServiceDistrictStat{
        public String service;
        public Vector districtstats=new Vector();

        public ServiceDistrictStat(String service){
            this.service=service;
        }

    }

    public static class DistrictStat {
        public String district;
        public int total;

        public DistrictStat(String district, int total){
            this.district=district;
            this.total=total;
        }
    }

    public static Vector getAdmissionServiceDistrictStats(){

        Vector services=new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql="select count(*) as total,c.oc_encounter_serviceuid as service, case when b.district is null then '' else b.district end as district" +
                    " from oc_encounters a,privateview b,oc_encounter_services c" +
                    " where" +
                    " a.oc_encounter_objectid=c.oc_encounter_objectid and" +
                    " a.oc_encounter_serverid=c.oc_encounter_serverid and" +
                    " a.oc_encounter_enddate is null and" +
                    " a.oc_encounter_patientuid=b.personid" +
                    " group by c.oc_encounter_serviceuid, case when b.district is null then '' else b.district end" +
                    " order by c.oc_encounter_serviceuid,count(*) desc";
            PreparedStatement ps = oc_conn.prepareStatement(sSql);
            ResultSet rs = ps.executeQuery();
            String activeService=null;
            ServiceDistrictStat serviceDistrictStat = null;
            while (rs.next()){
                String service = rs.getString("service");
                String district = rs.getString("district");
                int total = rs.getInt("total");
                if (activeService==null || !activeService.equalsIgnoreCase(service)) {
                    activeService=service;
                    serviceDistrictStat = new ServiceDistrictStat(service);
                    services.add(serviceDistrictStat);
                }
                serviceDistrictStat.districtstats.add(new DistrictStat(district,total));
            }
            rs.close();
            ps.close();
        }
        catch (Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return services;
    }

    public static Vector getAdmissionDistrictStats(){
        Vector districts = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql="select count(*) as total,case when b.district is null then '' else b.district end as district" +
                    " from oc_encounters a,privateview b,oc_encounter_services c" +
                    " where" +
                    " a.oc_encounter_objectid=c.oc_encounter_objectid and" +
                    " a.oc_encounter_serverid=c.oc_encounter_serverid and" +
                    " a.oc_encounter_enddate is null and" +
                    " a.oc_encounter_patientuid=b.personid" +
                    " group by case when b.district is null then '' else b.district end" +
                    " order by count(*) desc";
            PreparedStatement ps = oc_conn.prepareStatement(sSql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                String district = rs.getString("district");
                int total = rs.getInt("total");
                districts.add(new DistrictStat(district,total));
            }
            rs.close();
            ps.close();
        }
        catch (Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return districts;
    }

    public static Vector getPassiveDistrictStats(){
        Vector districts = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql="select count(*) as total, case when b.district is null then '' else b.district end as district" +
                    " from adminview d,privateview b" +
                    " where" +
                    " d.personid*=b.personid and" +
                    " not exists (select * from oc_encounters a,oc_encounter_services c where" +
                    " a.oc_encounter_objectid=c.oc_encounter_objectid and" +
                    " a.oc_encounter_serverid=c.oc_encounter_serverid and" +
                    " a.oc_encounter_enddate is null and" +
                    " a.oc_encounter_patientuid=b.personid)" +
                    " group by case when b.district is null then '' else b.district end" +
                    " order by count(*) desc";
            PreparedStatement ps = oc_conn.prepareStatement(sSql);
            ResultSet rs = ps.executeQuery();
            while (rs.next()){
                String district = rs.getString("district");
                int total = rs.getInt("total");
                districts.add(new DistrictStat(district,total));
            }
            rs.close();
            ps.close();
        }
        catch (Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return districts;
    }
}
