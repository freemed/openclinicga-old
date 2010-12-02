package be.openclinic.medical;

import be.openclinic.common.OC_Object;
import be.openclinic.adt.Encounter;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;
import net.admin.Service;
import net.admin.User;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Iterator;
import java.util.Vector;
import java.util.Hashtable;
import java.net.URL;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.sql.SQLException;

import org.apache.taglibs.standard.functions.Functions;
import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;

/**
 * Created by IntelliJ IDEA.
 * User: Frank Verbeke
 * Date: 10-sep-2006
 * Time: 21:32:46
 * To change this template use Options | File Templates.
 */
public class Diagnosis extends OC_Object{
    private Encounter encounter;
    private String codeType;
    private String code;
    private User author;
    private int certainty;
    private int gravity;
    private Date date;
    private Timestamp endDate;
    private StringBuffer lateralisation;
    private String referenceType;
    private String referenceUID;

    private String authorUID;
    private String encounterUID;
    private String POA;
    private String NC;
    private String serviceUid;
    private String flags;

    public boolean checkFlags(String flags){
        for(int n=0;n<flags.length();n++){
            if(getFlags().indexOf(flags.substring(n,n+1))<0){
                return false;
            }
        }
        return true;
    }

    public String getFlags() {
		return flags;
	}

	public void setFlags(String flags) {
		this.flags = flags;
	}

	public String getServiceUid() {
		return serviceUid;
	}

	public void setServiceUid(String serviceUid) {
		this.serviceUid = serviceUid;
	}

	public String getNC() {
        return NC;
    }

    public void setNC(String newCase) {
        this.NC = newCase;
    }

    public String getPOA() {
        return POA;
    }

    public void setPOA(String presentOnAdmission) {
        this.POA = presentOnAdmission;
    }

    public String getReferenceType() {
        return referenceType;
    }

    public void setReferenceType(String referenceType) {
        this.referenceType = referenceType;
    }

    public String getReferenceUID() {
        return referenceUID;
    }

    public void setReferenceUID(String referenceUID) {
        this.referenceUID = referenceUID;
    }


    public Timestamp getEndDate() {
        return endDate;
    }

    public void setEndDate(Timestamp endDate) {
        this.endDate = endDate;
    }

    public Encounter getEncounter() {
        if(this.encounter == null){
            if(this.encounterUID != null && this.encounterUID.length() > 0){
                this.setEncounter(Encounter.get(this.encounterUID));
            }else{
                this.encounter = null;
            }
        }
        return this.encounter;
    }

    public void setEncounter(Encounter encounter) {
        this.encounter = encounter;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public User getAuthor() {
        if(this.author == null){
            User tmpUser = new User();
            if(this.authorUID != null &&this.authorUID.length() > 0){
                boolean bCheck = tmpUser.initialize(Integer.parseInt(this.authorUID));
                if(bCheck){
                    this.setAuthor(tmpUser);
                }
            }else{
                this.author = null;
            }
        }
        return author;
    }

    public void setAuthor(User author) {
        this.author = author;
    }

    public int getCertainty() {
        return certainty;
    }

    public void setCertainty(int certainty) {
        this.certainty = certainty;
    }

    public int getGravity() {
        return gravity;
    }

    public void setGravity(int gravity) {
        this.gravity = gravity;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public String getAuthorUID(){
        return this.authorUID;
    }

    public void setAuthorUID(String authorUID){
        this.authorUID = authorUID;
    }

    public String getEncounterUID(){
        return this.encounterUID;
    }

    public void setEncounterUID(String encounterUID){
        this.encounterUID = encounterUID;
    }

    public StringBuffer getLateralisation() {
        return lateralisation;
    }

    public void setLateralisation(StringBuffer lateralisation) {
        this.lateralisation = lateralisation;
    }

    public String getCodeType() {
        return codeType;
    }

    public void setCodeType(String codeType) {
        this.codeType = codeType;
    }

    public static void deleteForEncounter(String encounterUid){
        PreparedStatement ps;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            ps=oc_conn.prepareStatement("delete from OC_DIAGNOSES where OC_DIAGNOSIS_ENCOUNTERUID=?");
            ps.setString(1,encounterUid);
            ps.execute();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public void store(){
        PreparedStatement ps;
        ResultSet rs;

        String sSelect,sInsert,sDelete;

        int iVersion = 1;
        String ids[];
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() >0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                    sSelect = " SELECT * FROM OC_DIAGNOSES " +
                              " WHERE OC_DIAGNOSIS_SERVERID = ? " +
                              " AND OC_DIAGNOSIS_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        iVersion = rs.getInt("OC_DIAGNOSIS_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sInsert = " INSERT INTO OC_DIAGNOSES_HISTORY " +
                              " SELECT OC_DIAGNOSIS_SERVERID," +
                                     " OC_DIAGNOSIS_OBJECTID," +
                                     " OC_DIAGNOSIS_DATE," +
                                     " OC_DIAGNOSIS_ENCOUNTEROBJECTID," +
                                     " OC_DIAGNOSIS_AUTHORUID," +
                                     " OC_DIAGNOSIS_CODE," +
                                     " OC_DIAGNOSIS_CERTAINTY," +
                                     " OC_DIAGNOSIS_GRAVITY," +
                                     " OC_DIAGNOSIS_CREATETIME," +
                                     " OC_DIAGNOSIS_UPDATETIME," +
                                     " OC_DIAGNOSIS_UPDATEUID,"  +
                                     " OC_DIAGNOSIS_VERSION," +
                                     " OC_DIAGNOSIS_LATERALISATION," +
                                     " OC_DIAGNOSIS_CODETYPE," +
                                     " OC_DIAGNOSIS_ENDDATE," +
                                     " OC_DIAGNOSIS_REFERENCETYPE," +
                                    " OC_DIAGNOSIS_REFERENCEUID," +
                                    " OC_DIAGNOSIS_POA," +
                                    " OC_DIAGNOSIS_NC," +
                                    " OC_DIAGNOSIS_SERVICEUID," +
                                    " OC_DIAGNOSIS_FLAGS" +
                              " FROM OC_DIAGNOSES " +
                              " WHERE OC_DIAGNOSIS_SERVERID = ?" +
                              " AND OC_DIAGNOSIS_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                    sDelete = " DELETE FROM OC_DIAGNOSES " +
                              " WHERE OC_DIAGNOSIS_SERVERID = ? " +
                              " AND OC_DIAGNOSIS_OBJECTID = ? ";

                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_DIAGNOSES")+""};
            }
            if(ids.length == 2){
                if(this.getEncounter() != null){
	            	sDelete = " DELETE FROM OC_DIAGNOSES " +
	                " WHERE OC_DIAGNOSIS_CODE = ? " +
	                " AND OC_DIAGNOSIS_ENCOUNTERUID = ? ";
	
				    ps = oc_conn.prepareStatement(sDelete);
				    ps.setString(1,this.getCode());
				    ps.setString(2,this.getEncounter().getUid());
				    ps.executeUpdate();
				    ps.close();
                }
                sInsert = " INSERT INTO OC_DIAGNOSES" +
                                      "(" +
                                      " OC_DIAGNOSIS_SERVERID," +
                                      " OC_DIAGNOSIS_OBJECTID," +
                                      " OC_DIAGNOSIS_DATE," +
                                      " OC_DIAGNOSIS_ENCOUNTERUID," +
                                      " OC_DIAGNOSIS_AUTHORUID," +
                                      " OC_DIAGNOSIS_CODE," +
                                      " OC_DIAGNOSIS_CERTAINTY," +
                                      " OC_DIAGNOSIS_GRAVITY," +
                                      " OC_DIAGNOSIS_CREATETIME," +
                                      " OC_DIAGNOSIS_UPDATETIME," +
                                      " OC_DIAGNOSIS_UPDATEUID,"  +
                                      " OC_DIAGNOSIS_VERSION," +
                                      " OC_DIAGNOSIS_LATERALISATION," +
                                      " OC_DIAGNOSIS_CODETYPE," +
                                      " OC_DIAGNOSIS_ENDDATE," +
                                      " OC_DIAGNOSIS_REFERENCETYPE," +
                                    " OC_DIAGNOSIS_REFERENCEUID," +
                                    " OC_DIAGNOSIS_POA," +
                                    " OC_DIAGNOSIS_ENCOUNTEROBJECTID," +
                                    " OC_DIAGNOSIS_NC," +
                                    " OC_DIAGNOSIS_SERVICEUID," +
                                    " OC_DIAGNOSIS_FLAGS" +
                                      ") " +
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                ps.setTimestamp(3,new Timestamp(this.getDate().getTime()));
                if(this.getEncounter() != null){
                    ps.setString(4,ScreenHelper.checkString(this.getEncounter().getUid()));
                }else{
                    ps.setString(4,"");
                }
                if(this.getAuthor() != null){
                    ps.setString(5,ScreenHelper.checkString(this.getAuthor().userid));
                }else{
                    ps.setString(5,ScreenHelper.checkString(this.getAuthorUID()));
                }
                ps.setString(6,this.getCode());
                ps.setInt(7,this.getCertainty());
                ps.setInt(8,this.getGravity());
                ps.setTimestamp(9,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(10,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(11,this.getUpdateUser());
                ps.setInt(12,iVersion);
                ps.setString(13,this.lateralisation.toString());
                ps.setString(14,this.getCodeType());
                ps.setTimestamp(15,this.getEndDate());
                ps.setString(16,this.getReferenceType());
                ps.setString(17,this.getReferenceUID());
                ps.setString(18,this.getPOA());
                if(this.getEncounter() != null && this.getEncounter().getUid().split("\\.").length==2){
                    ps.setInt(19,Integer.parseInt(ScreenHelper.checkString(this.getEncounter().getUid().split("\\.")[1])));
                }else{
                    ps.setInt(19,0);
                }
                ps.setString(20,this.getNC());
                ps.setString(21,this.getServiceUid());
                ps.setString(22,this.getFlags());

                ps.executeUpdate();
                ps.close();
                this.setUid(ids[0] + "." + ids[1]);
            }
        }catch(Exception e){
            Debug.println("OpenClinic => Diagnosis.java => store => "+e.getMessage());
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        MedwanQuery.getInstance().getObjectCache().putObject("diagnosis",this);
    }

    public static Diagnosis get(String uid){
        Diagnosis diagnosis = (Diagnosis)MedwanQuery.getInstance().getObjectCache().getObject("diagnosis",uid);
        if(diagnosis!=null){
            return diagnosis;
        }
        PreparedStatement ps;
        ResultSet rs;

        diagnosis = new Diagnosis();

        if(uid != null && uid.length() > 0){
            String sUids[] = uid.split("\\.");
            if(sUids.length == 2){
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = " SELECT * FROM OC_DIAGNOSES " +
                                     " WHERE OC_DIAGNOSIS_SERVERID = ? " +
                                     " AND OC_DIAGNOSIS_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sUids[0]));
                    ps.setInt(2,Integer.parseInt(sUids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        diagnosis.encounterUID = ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_ENCOUNTERUID"));
                        diagnosis.authorUID    = ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_AUTHORUID"));

                        diagnosis.setUid(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_OBJECTID")));
                        diagnosis.setCreateDateTime(rs.getTimestamp("OC_DIAGNOSIS_CREATETIME"));
                        diagnosis.setUpdateDateTime(rs.getTimestamp("OC_DIAGNOSIS_UPDATETIME"));
                        diagnosis.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_UPDATEUID")));
                        diagnosis.setVersion(rs.getInt("OC_DIAGNOSIS_VERSION"));
                        diagnosis.setDate(rs.getTimestamp("OC_DIAGNOSIS_DATE"));
                        diagnosis.setEndDate(rs.getTimestamp("OC_DIAGNOSIS_ENDDATE"));
                        diagnosis.setCode(rs.getString("OC_DIAGNOSIS_CODE"));
                        diagnosis.setCertainty(rs.getInt("OC_DIAGNOSIS_CERTAINTY"));
                        diagnosis.setGravity(rs.getInt("OC_DIAGNOSIS_GRAVITY"));
                        diagnosis.setLateralisation(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_LATERALISATION"))));
                        diagnosis.setCodeType(rs.getString("OC_DIAGNOSIS_CODETYPE"));
                        diagnosis.setReferenceType(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_REFERENCETYPE")));
                        diagnosis.setReferenceUID(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_REFERENCEUID")));
                        diagnosis.setPOA(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_POA")));
                        diagnosis.setNC(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_NC")));
                        diagnosis.setServiceUid(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_SERVICEUID")));
                        diagnosis.setFlags(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_FLAGS")));
                    }

                    rs.close();
                    ps.close();
                }catch(Exception e){
                    Debug.println("OpenClinic => Diagnosis.java => get => "+e.getMessage());
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
        MedwanQuery.getInstance().getObjectCache().putObject("diagnosis",diagnosis);
        return diagnosis;
    }

    public static Vector selectDiagnoses(String serverID, String objectID, String encounterUID, String authorUID, String fromGravity,String toGravity,
                                         String fromCertainty,String toCertainty, String code, String fromDate, String toDate, String codeType, String findSortColumn){
        return selectDiagnoses(serverID, objectID, encounterUID, authorUID, fromGravity,toGravity,fromCertainty,toCertainty, code, fromDate, toDate, codeType, findSortColumn,"","");
    }
    public static Vector selectDiagnoses(String serverID, String objectID, String encounterUID, String authorUID, String fromGravity,String toGravity,
            String fromCertainty,String toCertainty, String code, String fromDate, String toDate, String codeType, String findSortColumn,String findEncounterOutcome,String serviceID){
        return selectDiagnoses(serverID, objectID, encounterUID, authorUID, fromGravity,toGravity,fromCertainty,toCertainty, code, fromDate, toDate, codeType, findSortColumn,findEncounterOutcome,serviceID,"");
    }
    public static Vector selectDiagnoses(String serverID, String objectID, String encounterUID, String authorUID, String fromGravity,String toGravity,
            String fromCertainty,String toCertainty, String code, String fromDate, String toDate, String codeType, String findSortColumn,String findEncounterOutcome,String serviceID,String contactType){
        PreparedStatement ps;
        ResultSet rs = null;

        String sCondition = " a.OC_DIAGNOSIS_ENCOUNTERUID="+ MedwanQuery.getInstance().convert("varchar(10)","b.oc_encounter_serverid")+MedwanQuery.getInstance().concatSign()+"'.'"+MedwanQuery.getInstance().concatSign()+ MedwanQuery.getInstance().convert("varchar(10)","b.oc_encounter_objectid")+" and";
        String sSelect = " SELECT distinct OC_DIAGNOSIS_SERVERID,OC_DIAGNOSIS_OBJECTID,OC_DIAGNOSIS_CODE,OC_DIAGNOSIS_DATE," +
                "OC_DIAGNOSIS_ENDDATE,OC_DIAGNOSIS_CERTAINTY,OC_DIAGNOSIS_GRAVITY,"+ MedwanQuery.getInstance().convert("varchar(4000)","OC_DIAGNOSIS_LATERALISATION")+" as OC_DIAGNOSIS_LATERALISATION," +
                "OC_DIAGNOSIS_ENCOUNTERUID,OC_DIAGNOSIS_AUTHORUID,OC_DIAGNOSIS_CODETYPE,OC_DIAGNOSIS_POA,OC_DIAGNOSIS_NC,OC_DIAGNOSIS_SERVICEUID,OC_DIAGNOSIS_FLAGS  FROM OC_DIAGNOSES a,OC_ENCOUNTERS_view b";

        if(serverID.length() >0)      sCondition += " OC_DIAGNOSIS_SERVERID = ? AND";
        if(objectID.length() >0)      sCondition += " OC_DIAGNOSIS_OBJECTID = ? AND";
        if(encounterUID.length() > 0) sCondition += " OC_DIAGNOSIS_ENCOUNTERUID = ? AND";
        if(authorUID.length() > 0)    sCondition += " OC_DIAGNOSIS_AUTHORUID = ? AND";
        if(fromGravity.length() > 0)  sCondition += " OC_DIAGNOSIS_GRAVITY >= ? AND";
        if(toGravity.length() > 0)    sCondition += " OC_DIAGNOSIS_GRAVITY <= ? AND";
        if(fromCertainty.length() > 0)sCondition += " OC_DIAGNOSIS_CERTAINTY >= ? AND";
        if(toCertainty.length() > 0)  sCondition += " OC_DIAGNOSIS_CERTAINTY <= ? AND";
        if(code.length() > 0)         sCondition += " (" + MedwanQuery.getInstance().getConfigString("lowerCompare").replaceAll("<param>","OC_DIAGNOSIS_CODE") + " LIKE ? OR " +
                " EXISTS (SELECT * FROM OC_DIAGNOSIS_GROUPS WHERE OC_DIAGNOSIS_GROUPCODE like ? AND OC_DIAGNOSIS_CODETYPE=a.OC_DIAGNOSIS_CODETYPE AND OC_DIAGNOSIS_CODE>=OC_DIAGNOSIS_CODESTART AND OC_DIAGNOSIS_CODE<=OC_DIAGNOSIS_CODEEND)) AND";
        if(fromDate.length() > 0)     sCondition += " b.OC_ENCOUNTER_ENDDATE >= ? AND";
        if(toDate.length() > 0)       sCondition += " b.OC_ENCOUNTER_BEGINDATE < ? AND";
        if(codeType.length() > 0)     sCondition += " OC_DIAGNOSIS_CODETYPE = ? AND";
        if(contactType.length() > 0)     sCondition += " OC_ENCOUNTER_TYPE = ? AND";
        if(findEncounterOutcome!=null && findEncounterOutcome.length()>0)     sCondition += (findEncounterOutcome.equalsIgnoreCase("null")?" (b.OC_ENCOUNTER_OUTCOME IS NULL OR b.OC_ENCOUNTER_OUTCOME='') AND":" b.OC_ENCOUNTER_OUTCOME = ? AND");
        if(serviceID!=null && serviceID.length()>0){
        	String children = Service.getChildIdsAsString(serviceID);
        	sCondition += " b.OC_ENCOUNTER_SERVICEUID in ("+children+") AND";
        }

        if(sCondition.length() > 0){
            sSelect += " WHERE " + sCondition;
            sSelect = sSelect.substring(0,sSelect.length() - 3);
        }

        if(findSortColumn.length() == 0){
            findSortColumn = "OC_DIAGNOSIS_DATE";
        }

        sSelect += " ORDER BY " + findSortColumn;

        Vector vDiagnoses = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            int i = 1;
            ps = oc_conn.prepareStatement(sSelect);

            if(serverID.length() >0)        { ps.setInt(i++,Integer.parseInt(serverID));}
            if(objectID.length() >0)        { ps.setInt(i++,Integer.parseInt(objectID));}
            if(encounterUID.length() > 0)   { ps.setString(i++,encounterUID);}
            if(authorUID.length() > 0)      { ps.setString(i++,authorUID);}
            if(fromGravity.length() > 0)    { ps.setInt(i++,Integer.parseInt(fromGravity));}
            if(toGravity.length() > 0)      { ps.setInt(i++,Integer.parseInt(toGravity));}
            if(fromCertainty.length() > 0)  { ps.setInt(i++,Integer.parseInt(fromCertainty));}
            if(toCertainty.length() > 0)    { ps.setInt(i++,Integer.parseInt(toCertainty));}
            if(code.length() > 0)           { ps.setString(i++,code.toLowerCase()+"%");ps.setString(i++,code.toLowerCase()+"%");}
            if(fromDate.length() > 0)       { ps.setDate(i++,ScreenHelper.getSQLDate(fromDate));}
            if(toDate.length() > 0)         { ps.setDate(i++,ScreenHelper.getSQLDate(toDate));}
            if(codeType.length() > 0)       { ps.setString(i++,codeType);}
            if(contactType.length() > 0 )       { ps.setString(i++,contactType);}
            if(findEncounterOutcome!=null && findEncounterOutcome.length()>0 && !findEncounterOutcome.equalsIgnoreCase("null"))       { ps.setString(i++,findEncounterOutcome);}
            rs = ps.executeQuery();

            Diagnosis dTmp;

            while(rs.next()){
                dTmp = new Diagnosis();
                dTmp.setUid(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_OBJECTID")));
                dTmp.setCode(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CODE")));
                if(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_DATE")).length() > 0){
                    dTmp.setDate(rs.getDate("OC_DIAGNOSIS_DATE"));
                }
                if(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_ENDDATE")).length() > 0){
                    dTmp.setEndDate(rs.getTimestamp("OC_DIAGNOSIS_ENDDATE"));
                }
                if(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CERTAINTY")).length() > 0){
                    dTmp.setCertainty(Integer.parseInt(rs.getString("OC_DIAGNOSIS_CERTAINTY")));
                }
                if(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_GRAVITY")).length() > 0){
                    dTmp.setGravity(Integer.parseInt(rs.getString("OC_DIAGNOSIS_GRAVITY")));
                }
                dTmp.setLateralisation(new StringBuffer(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_LATERALISATION"))));
                dTmp.setEncounterUID(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_ENCOUNTERUID")));
                dTmp.setAuthorUID(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_AUTHORUID")));
                dTmp.setCodeType(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CODETYPE")));
                dTmp.setPOA(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_POA")));
                dTmp.setNC(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_NC")));
                dTmp.setServiceUid(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_SERVICEUID")));
                dTmp.setFlags(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_FLAGS")));
                MedwanQuery.getInstance().getObjectCache().putObject("diagnosis",dTmp);
                vDiagnoses.addElement(dTmp);
            }

            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

        return vDiagnoses;
    }

    public static String getCodeLabel(String code,String codeType,String language){
        String sLabel = "";

        String label = "labelen";
        if (language.equalsIgnoreCase("F") || language.equalsIgnoreCase("FR")) {
            label = "labelfr";
        }
        if (language.equalsIgnoreCase("N") || language.equalsIgnoreCase("NL")) {
            label = "labelnl";
        }

        PreparedStatement ps;
        ResultSet rs;
        String sSelect = "";
        if(codeType.equals("ICPC-2")){
            sSelect = "SELECT " + label + " from ICPC2View WHERE code = ?";
        }else if(codeType.equals("ICD-10")){
            sSelect = "SELECT " + label + " from ICD10View WHERE code = ?";
        }
        if(sSelect.length() > 0){
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            try{
                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,code);

                rs = ps.executeQuery();

                if(rs.next()){
                    sLabel = ScreenHelper.checkString(rs.getString(label));
                }

                rs.close();
                ps.close();
            }catch(Exception e){
                e.printStackTrace();
            }
            try {
				oc_conn.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
        }

        return sLabel;
    }

    public static void deleteDiagnosesByReferenceUID(String sReferenceUID,String sType){
        PreparedStatement ps = null;

        String sDelete = "DELETE FROM OC_DIAGNOSES WHERE OC_DIAGNOSIS_REFERENCETYPE = ? AND OC_DIAGNOSIS_REFERENCEUID = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setString(1,sType);
            ps.setString(2,sReferenceUID);
            ps.execute();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }finally{
            try{
                if(ps!=null)ps.close();
                oc_conn.close();
            }catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    public static Hashtable getDiagnosesByReferenceUID(String sReferenceUID,String sReferenceType){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Hashtable hDiagnoses = new Hashtable();
        Hashtable hDiagnosisInfo = new Hashtable();
        String sSelect = "SELECT * FROM OC_DIAGNOSES WHERE OC_DIAGNOSIS_REFERENCETYPE = ? AND OC_DIAGNOSIS_REFERENCEUID = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sReferenceType);
            ps.setString(2,sReferenceUID);

            rs = ps.executeQuery();

            while(rs.next()){
                hDiagnosisInfo = new Hashtable();
                hDiagnosisInfo.put("Gravity",ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_GRAVITY")));
                hDiagnosisInfo.put("Certainty",ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CERTAINTY")));
                hDiagnosisInfo.put("POA",ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_POA")));
                hDiagnosisInfo.put("NC",ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_NC")));
                hDiagnosisInfo.put("ServiceUid",ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_SERVICEUID")));
                hDiagnosisInfo.put("Flags",ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_FLAGS")));
                hDiagnoses.put(ScreenHelper.checkString(rs.getString("OC_DIAGNOSIS_CODE")),hDiagnosisInfo);
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
        return hDiagnoses;
    }

    public static void saveTransactionDiagnosis(String sCode,String sLateralisation,String sGravity,String sCertainty, String sPersonid,String sCodeType,String sType,Timestamp updateTime,String sTransactionUID, int userid,String POA){
        try{
            if(POA==null){
                POA="";
            }
            Diagnosis objDiagnosis = new Diagnosis();

            //objDiagnosis.setAuthor(user);
            objDiagnosis.setAuthorUID(Integer.toString(userid));
            objDiagnosis.setCertainty(Integer.parseInt(sCertainty));
            objDiagnosis.setGravity(Integer.parseInt(sGravity));
            objDiagnosis.setCode(sCode.substring(sCodeType.length(),sCode.length()));
            objDiagnosis.setCodeType(sType);
            objDiagnosis.setLateralisation(new StringBuffer(sLateralisation));
            objDiagnosis.setDate(ScreenHelper.getSQLTime());
            objDiagnosis.setCreateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateUser(Integer.toString(userid));
            objDiagnosis.setReferenceType("Transaction");
            objDiagnosis.setReferenceUID(sTransactionUID);
            Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(updateTime.getTime()),sPersonid);
            objDiagnosis.setEncounterUID(activeEnc.getUid());
            objDiagnosis.setPOA(POA);
            objDiagnosis.store();
            MedwanQuery.getInstance().getObjectCache().putObject("diagnosis",objDiagnosis);
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void saveTransactionDiagnosis(String sCode,String sLateralisation,String sGravity,String sCertainty, String sPersonid,String sCodeType,String sType,Timestamp updateTime,String sTransactionUID, int userid,String POA,String NC){
        try{
            if(POA==null){
                POA="";
            }
            if(NC==null){
                NC="";
            }
            Diagnosis objDiagnosis = new Diagnosis();

            //objDiagnosis.setAuthor(user);
            objDiagnosis.setAuthorUID(Integer.toString(userid));
            objDiagnosis.setCertainty(Integer.parseInt(sCertainty));
            objDiagnosis.setGravity(Integer.parseInt(sGravity));
            objDiagnosis.setCode(sCode.substring(sCodeType.length(),sCode.length()));
            objDiagnosis.setCodeType(sType);
            objDiagnosis.setLateralisation(new StringBuffer(sLateralisation));
            objDiagnosis.setDate(ScreenHelper.getSQLTime());
            objDiagnosis.setCreateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateUser(Integer.toString(userid));
            objDiagnosis.setReferenceType("Transaction");
            objDiagnosis.setReferenceUID(sTransactionUID);
            Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(updateTime.getTime()),sPersonid);
            objDiagnosis.setEncounterUID(activeEnc.getUid());
            objDiagnosis.setPOA(POA);
            objDiagnosis.setNC(NC);
            MedwanQuery.getInstance().getObjectCache().putObject("diagnosis",objDiagnosis);
            objDiagnosis.store();
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void saveTransactionDiagnosis(String sCode,String sLateralisation,String sGravity,String sCertainty, String sPersonid,String sCodeType,String sType,Timestamp updateTime,String sTransactionUID, int userid,Encounter encounter,String POA){
        try{
            if(POA==null){
                POA="";
            }
            Diagnosis objDiagnosis = new Diagnosis();

            //objDiagnosis.setAuthor(user);
            objDiagnosis.setAuthorUID(Integer.toString(userid));
            objDiagnosis.setCertainty(Integer.parseInt(sCertainty));
            objDiagnosis.setGravity(Integer.parseInt(sGravity));
            objDiagnosis.setCode(sCode.substring(sCodeType.length(),sCode.length()));
            objDiagnosis.setCodeType(sType);
            objDiagnosis.setLateralisation(new StringBuffer(sLateralisation));
            objDiagnosis.setDate(encounter.getBegin());
            objDiagnosis.setCreateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateUser(Integer.toString(userid));
            objDiagnosis.setReferenceType("Transaction");
            objDiagnosis.setReferenceUID(sTransactionUID);
            objDiagnosis.setEncounterUID(encounter.getUid());
            objDiagnosis.setPOA(POA);
            MedwanQuery.getInstance().getObjectCache().putObject("diagnosis",objDiagnosis);
            objDiagnosis.store();
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void saveTransactionDiagnosis(String sCode,String sLateralisation,String sGravity,String sCertainty, String sPersonid,String sCodeType,String sType,Timestamp updateTime,String sTransactionUID, int userid,Encounter encounter,String POA, String NC){
        try{
            if(POA==null){
                POA="";
            }
            if(NC==null){
                NC="";
            }
            Diagnosis objDiagnosis = new Diagnosis();

            //objDiagnosis.setAuthor(user);
            objDiagnosis.setAuthorUID(Integer.toString(userid));
            objDiagnosis.setCertainty(Integer.parseInt(sCertainty));
            objDiagnosis.setGravity(Integer.parseInt(sGravity));
            objDiagnosis.setCode(sCode.substring(sCodeType.length(),sCode.length()));
            objDiagnosis.setCodeType(sType);
            objDiagnosis.setLateralisation(new StringBuffer(sLateralisation));
            objDiagnosis.setDate(encounter.getBegin());
            objDiagnosis.setCreateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateUser(Integer.toString(userid));
            objDiagnosis.setReferenceType("Transaction");
            objDiagnosis.setReferenceUID(sTransactionUID);
            objDiagnosis.setEncounterUID(encounter.getUid());
            objDiagnosis.setPOA(POA);
            objDiagnosis.setNC(NC);
            MedwanQuery.getInstance().getObjectCache().putObject("diagnosis",objDiagnosis);
            objDiagnosis.store();
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void saveTransactionDiagnosisWithService(String sCode,String sLateralisation,String sGravity,String sCertainty, String sPersonid,String sCodeType,String sType,Timestamp updateTime,String sTransactionUID, int userid,Encounter encounter,String POA, String NC,String serviceUid){
        try{
            if(POA==null){
                POA="";
            }
            if(NC==null){
                NC="";
            }
            Diagnosis objDiagnosis = new Diagnosis();

            //objDiagnosis.setAuthor(user);
            objDiagnosis.setAuthorUID(Integer.toString(userid));
            objDiagnosis.setCertainty(Integer.parseInt(sCertainty));
            objDiagnosis.setGravity(Integer.parseInt(sGravity));
            objDiagnosis.setCode(sCode.substring(sCodeType.length(),sCode.length()));
            objDiagnosis.setCodeType(sType);
            objDiagnosis.setLateralisation(new StringBuffer(sLateralisation));
            objDiagnosis.setDate(encounter.getBegin());
            objDiagnosis.setCreateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateUser(Integer.toString(userid));
            objDiagnosis.setReferenceType("Transaction");
            objDiagnosis.setReferenceUID(sTransactionUID);
            objDiagnosis.setEncounterUID(encounter.getUid());
            objDiagnosis.setPOA(POA);
            objDiagnosis.setNC(NC);
            objDiagnosis.setServiceUid(serviceUid);
            MedwanQuery.getInstance().getObjectCache().putObject("diagnosis",objDiagnosis);
            objDiagnosis.store();
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    public static void saveTransactionDiagnosisWithServiceAndFlags(String sCode,String sLateralisation,String sGravity,String sCertainty, String sPersonid,String sCodeType,String sType,Timestamp updateTime,String sTransactionUID, int userid,Encounter encounter,String POA, String NC,String serviceUid,String flags){
        try{
            if(POA==null){
                POA="";
            }
            if(NC==null){
                NC="";
            }
            Diagnosis objDiagnosis = new Diagnosis();

            //objDiagnosis.setAuthor(user);
            objDiagnosis.setAuthorUID(Integer.toString(userid));
            objDiagnosis.setCertainty(Integer.parseInt(sCertainty));
            objDiagnosis.setGravity(Integer.parseInt(sGravity));
            objDiagnosis.setCode(sCode.substring(sCodeType.length(),sCode.length()));
            objDiagnosis.setCodeType(sType);
            objDiagnosis.setLateralisation(new StringBuffer(sLateralisation));
            objDiagnosis.setDate(encounter.getBegin());
            objDiagnosis.setCreateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateDateTime(ScreenHelper.getSQLTime());
            objDiagnosis.setUpdateUser(Integer.toString(userid));
            objDiagnosis.setReferenceType("Transaction");
            objDiagnosis.setReferenceUID(sTransactionUID);
            objDiagnosis.setEncounterUID(encounter.getUid());
            objDiagnosis.setPOA(POA);
            objDiagnosis.setNC(NC);
            objDiagnosis.setServiceUid(serviceUid);
            objDiagnosis.setFlags(flags);
            MedwanQuery.getInstance().getObjectCache().putObject("diagnosis",objDiagnosis);
            objDiagnosis.store();
        }catch(Exception e){
            e.printStackTrace();
        }
    }

    public boolean existsComorbidity(String code,String codetype){
        boolean bResult=false;
        String sSelect = "SELECT * FROM OC_DIAGNOSES a WHERE OC_DIAGNOSIS_ENCOUNTERUID = ? AND OC_DIAGNOSIS_CODETYPE=? AND (OC_DIAGNOSIS_CODE like ? OR EXISTS (SELECT * FROM OC_DIAGNOSIS_GROUPS WHERE OC_DIAGNOSIS_GROUPCODE like ? AND OC_DIAGNOSIS_CODETYPE=a.OC_DIAGNOSIS_CODETYPE AND OC_DIAGNOSIS_CODE>=OC_DIAGNOSIS_CODESTART AND OC_DIAGNOSIS_CODE<=OC_DIAGNOSIS_CODEEND))";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            PreparedStatement ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,getEncounterUID());
            ps.setString(2,codetype);
            ps.setString(3,code+"%");
            ps.setString(4,code+"%");
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                bResult=true;
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return bResult;
    }
    
    static public int getGravity(String codetype, String code, int defaultValue){
    	int i = defaultValue;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		PreparedStatement ps = oc_conn.prepareStatement("select weight from OC_BOD where codetype=? and code=?");
    		ps.setString(1, codetype);
    		ps.setString(2, code.substring(0,3));
    		ResultSet rs = ps.executeQuery();
    		if(rs.next()){
    			i=rs.getInt("weight");
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
    	return i;
    }
    
    static public Vector getPatientKPGSDiagnosesByICPC(String code,String codetype,String patientuid,String language){
    	Vector i = new Vector();
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	try{
    		String sQuery="select a.OC_DIAGNOSIS_CODETYPE,a.OC_DIAGNOSIS_CODE,a.OC_DIAGNOSIS_DATE from oc_diagnoses a,oc_diagnosis_groups b,oc_diagnosis_groups c,oc_encounters d"+
    						" where"+
    						" d.oc_encounter_patientuid=? and"+
    						" d.oc_encounter_objectid=replace(a.oc_diagnosis_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and"+
    						" b.oc_diagnosis_codetype=? and"+
    						" ? between b.oc_diagnosis_codestart and b.oc_diagnosis_codeend and"+
    						" c.oc_diagnosis_codetype=a.oc_diagnosis_codetype and"+
    						" a.oc_diagnosis_code between c.oc_diagnosis_codestart and c.oc_diagnosis_codeend and"+
    						" b.oc_diagnosis_groupcode=c.oc_diagnosis_groupcode" +
    						" order by a.OC_DIAGNOSIS_DATE desc";		
    		PreparedStatement ps = oc_conn.prepareStatement(sQuery);
    		ps.setString(1, patientuid);
    		ps.setString(2, codetype);
    		ps.setString(3, code);
    		ResultSet rs = ps.executeQuery();
    		while(rs.next()){
    			String sCode=rs.getString("OC_DIAGNOSIS_CODE");
    			String sCodeType=rs.getString("OC_DIAGNOSIS_CODEType");
    			i.add(new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("OC_DIAGNOSIS_DATE"))+" "+sCodeType.toUpperCase()+" "+sCode+": "+MedwanQuery.getInstance().getDiagnosisLabel(sCodeType, sCode, language));
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
    	return i;
     }
    
	public static String getFlags(String codeType, String code, String flags){
	    SAXReader reader = new SAXReader(false);
	    String sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"/diagnosis.xml";
	    try {
	        Document document = reader.read(new URL(sDoc));
	        Element root = document.getRootElement();
	        Element e = root.element("flags");
	        Iterator flagElements = e.elementIterator("flag");
	        while(flagElements.hasNext()){
	            Element f = (Element)flagElements.next();
	            if (flags.indexOf(f.attributeValue("flag"))<0 &&
	                    f.attributeValue("codetype").equalsIgnoreCase(codeType) &&
	                    f.attributeValue("start").compareTo(code)<1 &&
	                    f.attributeValue("end").compareTo(code)>-1){
	                flags+=f.attributeValue("flag");
	            }
	        }
	
	    } catch (Exception e) {
	        e.printStackTrace();  //To change body of catch statement use File | Settings | File Templates.
	    }
	    return flags;
	}
}
