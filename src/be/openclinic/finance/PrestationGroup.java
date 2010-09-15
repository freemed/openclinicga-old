package be.openclinic.finance;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.util.Hashtable;
import java.util.Enumeration;
import java.util.Vector;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;



public class PrestationGroup extends OC_Object{
    private String description;
    private Hashtable prestations;

    public PrestationGroup(){
        super();
        prestations = new Hashtable();
    }
    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Hashtable getPrestations() {
        return prestations;
    }

    public void setPrestations(Hashtable prestations) {
        this.prestations = prestations;
    }

    public void addPrestation(Prestation prestation){
        if(this.prestations == null){
            this.prestations = new Hashtable();
        }
        this.prestations.put(prestation.getUid(),prestation);
    }

    public static PrestationGroup get(String uid){
        PrestationGroup prestations = new PrestationGroup();
        String ids[];
        if(uid != null && uid.length() > 0 ){
            ids = uid.split("\\.");
            if(ids.length == 2){
                PreparedStatement ps = null;
                ResultSet rs = null;
                String sSelect;
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    sSelect = "SELECT * FROM OC_PRESTATIONGRPS WHERE OC_PRESTATIONGRP_SERVERID = ? AND OC_PRESTATIONGRP_OBJECTID = ?";

                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    String sPrestationUID;
                    String[] sPrestationUIDS;
                    if(rs.next()){

                        prestations.setUid(uid);
                        prestations.setDescription(rs.getString("OC_PRESTATIONGRP_DESCRIPTION"));
                        prestations.setCreateDateTime(rs.getTimestamp("OC_PRESTATIONGRP_CREATETIME"));
                        prestations.setUpdateDateTime(rs.getTimestamp("OC_PRESTATIONGRP_UPDATETIME"));
                        prestations.setUpdateUser(rs.getString("OC_PRESTATIONGRP_UPDATEUID"));
                        prestations.setVersion(rs.getInt("OC_PRESTATIONGRP_VERSION"));

                        sPrestationUID = ScreenHelper.checkString(rs.getString("OC_PRESTATIONGRP_PRESTATIONUID"));

                        if(sPrestationUID.length() > 0){
                            sPrestationUIDS = sPrestationUID.split(";");
                            for(int i= 0 ; i < sPrestationUIDS.length ; i++){
                                prestations.addPrestation(Prestation.get(sPrestationUIDS[i]));
                            }
                        }
                    }
                    rs.close();
                    ps.close();
                }catch(Exception e){
                    e.printStackTrace();
                }finally{
                    try{
                        if(rs!=null)rs.close();
                        if(ps!=null)ps.close();
                        oc_conn.close();
                    }catch(Exception e){
                        e.printStackTrace();
                    }
                }
            }
        }
        return prestations;
    }

    public void store(){
        String ids[];
        PreparedStatement ps = null;
        ResultSet rs = null;
        int iVersion = 1;
        String sSelect , sDelete, sInsert;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid() != null && this.getUid().length() > 0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                    sSelect = "SELECT * FROM OC_PRESTATIONGRPS WHERE OC_PRESTATIONGRP_SERVERID = ? AND OC_PRESTATIONGRP_OBJECTID = ?";

                    ps = oc_conn.prepareStatement(sSelect);

                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        iVersion = rs.getInt("OC_PRESTATIONGRP_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sInsert = " INSERT INTO OC_PRESTATIONGRPS_HISTORY SELECT * FROM OC_PRESTATIONGRPS WHERE OC_PRESTATIONGRP_SERVERID = ? AND OC_PRESTATIONGRP_OBJECTID = ?";

                    ps = oc_conn.prepareStatement(sInsert);

                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    ps.executeUpdate();

                    ps.close();

                    sDelete = " DELETE FROM OC_PRESTATIONGRPS WHERE OC_PRESTATIONGRP_SERVERID = ? AND OC_PRESTATIONGRP_OBJECTID = ?";

                    ps = oc_conn.prepareStatement(sDelete);

                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    ps.executeUpdate();

                    ps.close();
                }
            }else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_PRESTATIONGROUPS")+""};
            }
            if(ids.length == 2){
                sInsert = " INSERT INTO OC_PRESTATIONGRPS (" +
                                                            "OC_PRESTATIONGRP_SERVERID, " +
                                                            "OC_PRESTATIONGRP_OBJECTID, " +
                                                            "OC_PRESTATIONGRP_DESCRIPTION, " +
                                                            "OC_PRESTATIONGRP_PRESTATIONUID, " +
                                                            "OC_PRESTATIONGRP_CREATETIME, " +
                                                            "OC_PRESTATIONGRP_UPDATETIME, " +
                                                            "OC_PRESTATIONGRP_UPDATEUID, " +
                                                            "OC_PRESTATIONGRP_VERSION" +
                                                          ") " +
                          " VALUES(?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);

                Enumeration e = this.getPrestations().elements();
                String sPrestationUIDs = "";
                while(e.hasMoreElements()){
                    Prestation prestation = (Prestation)e.nextElement();
                    sPrestationUIDs += prestation.getUid() + ";";
                }
                if(sPrestationUIDs.endsWith(";")){
                    sPrestationUIDs = sPrestationUIDs.substring(0,sPrestationUIDs.length()-1);
                }
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setString(3,this.getDescription());
                ps.setString(4,sPrestationUIDs);
                ps.setTimestamp(5,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(6,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(7,this.getUpdateUser());
                ps.setInt(8,iVersion);

                ps.executeUpdate();

                this.setUid(ids[0]+"."+ids[1]);

                ps.close();
            }
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public Prestation getPrestation(String uid){
        return (Prestation)this.getPrestations().get(uid);
    }

    public static Vector getPrestationGroups(String sPrestationGroupDescription){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT DISTINCT OC_PRESTATIONGRP_SERVERID,OC_PRESTATIONGRP_OBJECTID,OC_PRESTATIONGRP_DESCRIPTION FROM OC_PRESTATIONGRPS WHERE OC_PRESTATIONGRP_DESCRIPTION LIKE ?";

        Vector vPrestationGrps = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sPrestationGroupDescription + "%");

            rs = ps.executeQuery();

            PrestationGroup prestations;
            String sPrestationUID;
            String[] sPrestationUIDS;

            while(rs.next()){
                prestations = new PrestationGroup();

                prestations.setUid(ScreenHelper.checkString(rs.getString("OC_PRESTATIONGRP_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_PRESTATIONGRP_OBJECTID")));
                prestations.setDescription(rs.getString("OC_PRESTATIONGRP_DESCRIPTION"));

                if(prestations.getUid().length() > 0){
                    sPrestationUIDS = prestations.getUid().split(".");
                    for(int i= 0 ; i < sPrestationUIDS.length ; i++){
                        prestations.addPrestation(Prestation.get(sPrestationUIDS[i]));
                    }
                }
                vPrestationGrps.addElement(prestations);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
        return vPrestationGrps;
    }
}
