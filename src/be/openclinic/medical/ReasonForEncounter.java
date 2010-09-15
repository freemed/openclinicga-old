package be.openclinic.medical;

import be.openclinic.adt.Encounter;
import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.util.Date;
import java.util.Vector;
import java.util.Iterator;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.net.URL;
import java.net.MalformedURLException;

import net.admin.User;
import org.dom4j.io.SAXReader;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;

/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 12-jan-2009
 * Time: 16:02:34
 * To change this template use File | Settings | File Templates.
 */
public class ReasonForEncounter extends OC_Object {
    private Encounter encounter;
    private String encounterUID;
    private String codeType;
    private String code;
    private User author;
    private String authorUID;
    private Date date;
    private String flags;

    public String getFlags() {
        return flags;
    }

    public void setFlags(String flags) {
        this.flags = flags;
    }

    public String getCodeType() {
        return codeType;
    }

    public void setCodeType(String codeType) {
        this.codeType = codeType;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public void setEncounter(Encounter encounter) {
        this.encounter = encounter;
        setEncounterUID(encounter.getUid());
    }

    public String getEncounterUID(){
        return this.encounterUID;
    }

    public void setEncounterUID(String encounterUID){
        this.encounterUID = encounterUID;
    }

    public Encounter getEncounter(){
        if(encounter==null || !encounter.getUid().equalsIgnoreCase(getEncounterUID())){
            encounter = Encounter.get(encounterUID);
        }
        return encounter;
    }

    public User getAuthor() {
        if(this.author == null || !this.author.userid.equalsIgnoreCase(getAuthorUID())){
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
        setAuthorUID(author.userid);
    }

    public String getAuthorUID() {
        return authorUID;
    }

    public void setAuthorUID(String authorUID) {
        this.authorUID = authorUID;
    }

    public void delete(){
        PreparedStatement ps;
        String sDelete;
        String ids[];
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() >0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                    sDelete = " DELETE FROM OC_RFE " +
                              " WHERE OC_RFE_SERVERID = ? " +
                              " AND OC_RFE_OBJECTID = ? ";
                    ps = oc_conn.prepareStatement(sDelete);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();
                }
            }
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

    public static void delete(int serverid,int objectid){
        PreparedStatement ps;
        String sDelete;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sDelete = " DELETE FROM OC_RFE " +
                      " WHERE OC_RFE_SERVERID = ? " +
                      " AND OC_RFE_OBJECTID = ? ";
            ps = oc_conn.prepareStatement(sDelete);
            ps.setInt(1,serverid);
            ps.setInt(2,objectid);
            ps.executeUpdate();
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
                    sSelect = " SELECT * FROM OC_RFE " +
                              " WHERE OC_RFE_SERVERID = ? " +
                              " AND OC_RFE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        iVersion = rs.getInt("OC_RFE_VERSION") + 1;
                    }

                    rs.close();
                    ps.close();

                    sInsert = " INSERT INTO OC_RFE_HISTORY " +
                              " SELECT OC_RFE_SERVERID," +
                                     " OC_RFE_OBJECTID," +
                                     " OC_RFE_ENCOUNTERUID," +
                                     " OC_RFE_CODETYPE," +
                                     " OC_RFE_CODE," +
                                     " OC_RFE_DATE," +
                                     " OC_RFE_FLAGS,"+
                                     " OC_RFE_VERSION," +
                                     " OC_RFE_CREATETIME," +
                                     " OC_RFE_UPDATETIME," +
                                     " OC_RFE_UPDATEUID"  +
                              " FROM OC_RFE " +
                              " WHERE OC_RFE_SERVERID = ?" +
                              " AND OC_RFE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                }
            }else{
                ids = new String[] {MedwanQuery.getInstance().getConfigString("serverId"),MedwanQuery.getInstance().getOpenclinicCounter("OC_RFE")+""};
            }
            if(ids.length == 2){
                sDelete = " DELETE FROM OC_RFE " +
                          " WHERE OC_RFE_ENCOUNTERUID = ? " +
                          " AND OC_RFE_CODETYPE = ? "+
                          " AND OC_RFE_CODE = ? ";

                ps = oc_conn.prepareStatement(sDelete);
                ps.setString(1,this.getEncounterUID());
                ps.setString(2,this.getCodeType());
                ps.setString(3,this.getCode());
                ps.executeUpdate();
                ps.close();

                sInsert = " INSERT INTO OC_RFE(" +
                                 " OC_RFE_SERVERID," +
                                 " OC_RFE_OBJECTID," +
                                 " OC_RFE_ENCOUNTERUID," +
                                 " OC_RFE_CODETYPE," +
                                 " OC_RFE_CODE," +
                                 " OC_RFE_DATE," +
                                 " OC_RFE_FLAGS,"+
                                 " OC_RFE_VERSION," +
                                 " OC_RFE_CREATETIME," +
                                 " OC_RFE_UPDATETIME," +
                                 " OC_RFE_UPDATEUID)"  +
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                if(this.getEncounter() != null){
                    ps.setString(3, ScreenHelper.checkString(this.getEncounter().getUid()));
                }else{
                    ps.setString(3,"");
                }
                ps.setString(4,this.getCodeType());
                ps.setString(5,this.getCode());
                ps.setDate(6,new java.sql.Date(this.getDate().getTime()));
                ps.setString(7,this.getFlags());
                ps.setInt(8,iVersion);
                ps.setTimestamp(9,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(10,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(11,this.getUpdateUser());
                ps.executeUpdate();
                ps.close();
                this.setUid(ids[0] + "." + ids[1]);
            }
        }catch(Exception e){
            Debug.println("OpenClinic => ReasonForEncounter.java => store => "+e.getMessage());
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public static Vector getReasonsForEncounterByEncounterUid(String encounterUid){
        Vector reasonsForEncounter=new Vector();
        PreparedStatement ps;
        ResultSet rs;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = " SELECT * FROM OC_RFE " +
                             " WHERE OC_RFE_ENCOUNTERUID = ? order by OC_RFE_CODETYPE,OC_RFE_CODE";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,encounterUid);
            rs = ps.executeQuery();
            while(rs.next()){
                ReasonForEncounter reasonForEncounter = new ReasonForEncounter();
                reasonForEncounter.encounterUID = ScreenHelper.checkString(rs.getString("OC_RFE_ENCOUNTERUID"));
                reasonForEncounter.authorUID    = ScreenHelper.checkString(rs.getString("OC_RFE_UPDATEUID"));

                reasonForEncounter.setUid(ScreenHelper.checkString(rs.getString("OC_RFE_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_RFE_OBJECTID")));
                reasonForEncounter.setCreateDateTime(rs.getTimestamp("OC_RFE_CREATETIME"));
                reasonForEncounter.setUpdateDateTime(rs.getTimestamp("OC_RFE_UPDATETIME"));
                reasonForEncounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_RFE_UPDATEUID")));
                reasonForEncounter.setVersion(rs.getInt("OC_RFE_VERSION"));
                reasonForEncounter.setDate(rs.getTimestamp("OC_RFE_DATE"));
                reasonForEncounter.setCode(rs.getString("OC_RFE_CODE"));
                reasonForEncounter.setCodeType(rs.getString("OC_RFE_CODETYPE"));
                reasonForEncounter.setFlags(ScreenHelper.checkString(rs.getString("OC_RFE_FLAGS")));
                reasonsForEncounter.add(reasonForEncounter);
            }
            rs.close();
            ps.close();
        }catch(Exception e){
            Debug.println("OpenClinic => ReasonForEncounter.java => get => "+e.getMessage());
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return reasonsForEncounter;
    }

    public static String getReasonsForEncounterAsHtml(Encounter encounter,String sWebLanguage,String deleteImg,String deleteFunction){
        if(encounter==null) return "";
        return getReasonsForEncounterAsHtml(encounter.getUid(),sWebLanguage,deleteImg,deleteFunction);
    }

    public static String getReasonsForEncounterAsHtml(String encounterUid,String sWebLanguage,String deleteImg,String deleteFunction){
        String s="<table>";
        Vector reasonsForEncounter = ReasonForEncounter.getReasonsForEncounterByEncounterUid(encounterUid);
        if(reasonsForEncounter.size()==0) return "";
        for(int n=0;n<reasonsForEncounter.size();n++){
            ReasonForEncounter reasonForEncounter = (ReasonForEncounter)reasonsForEncounter.elementAt(n);
            s+="<tr><td><img src='"+deleteImg+"' onmouseover='this.style.cursor=\"pointer\"' onmouseout='this.style.cursor=\"default\"' onclick='"+deleteFunction.replaceAll("\\$serverid",reasonForEncounter.getUid().split("\\.")[0]).replaceAll("\\$objectid",reasonForEncounter.getUid().split("\\.")[1])+"'/>"+
                    "</td><td>"+reasonForEncounter.getCodeType().toUpperCase()+
                    "</td><td><b>"+reasonForEncounter.getCode()+
                    "</b></td><td><b>"+MedwanQuery.getInstance().getCodeTran(reasonForEncounter.getCodeType()+"code"+reasonForEncounter.getCode(),sWebLanguage)+
                    "</b></td></tr>";
        }
        s+="</table>";
        return s;
    }

    public static String getReasonsForEncounterAsHtml(String encounterUid,String sWebLanguage){
        String s="<table>";
        Vector reasonsForEncounter = ReasonForEncounter.getReasonsForEncounterByEncounterUid(encounterUid);
        if(reasonsForEncounter.size()==0) return "";
        for(int n=0;n<reasonsForEncounter.size();n++){
            ReasonForEncounter reasonForEncounter = (ReasonForEncounter)reasonsForEncounter.elementAt(n);
            s+="<tr><td>"+reasonForEncounter.getCodeType().toUpperCase()+
                    "</td><td><b>"+reasonForEncounter.getCode()+
                    "</b></td><td><b>"+MedwanQuery.getInstance().getCodeTran(reasonForEncounter.getCodeType()+"code"+reasonForEncounter.getCode(),sWebLanguage)+
                    "</b></td></tr>";
        }
        s+="</table>";
        return s;
    }

    public static ReasonForEncounter get(String uid){
        PreparedStatement ps;
        ResultSet rs;
        ReasonForEncounter reasonForEncounter = new ReasonForEncounter();

        if(uid != null && uid.length() > 0){
            String sUids[] = uid.split("\\.");
            if(sUids.length == 2){
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = " SELECT * FROM OC_RFE " +
                                     " WHERE OC_RFE_SERVERID = ? " +
                                     " AND OC_RFE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sUids[0]));
                    ps.setInt(2,Integer.parseInt(sUids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        reasonForEncounter.encounterUID = ScreenHelper.checkString(rs.getString("OC_RFE_ENCOUNTERUID"));
                        reasonForEncounter.authorUID    = ScreenHelper.checkString(rs.getString("OC_RFE_UPDATEUID"));

                        reasonForEncounter.setUid(ScreenHelper.checkString(rs.getString("OC_RFE_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_RFE_OBJECTID")));
                        reasonForEncounter.setCreateDateTime(rs.getTimestamp("OC_RFE_CREATETIME"));
                        reasonForEncounter.setUpdateDateTime(rs.getTimestamp("OC_RFE_UPDATETIME"));
                        reasonForEncounter.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_RFE_UPDATEUID")));
                        reasonForEncounter.setVersion(rs.getInt("OC_RFE_VERSION"));
                        reasonForEncounter.setDate(rs.getTimestamp("OC_RFE_DATE"));
                        reasonForEncounter.setCode(rs.getString("OC_RFE_CODE"));
                        reasonForEncounter.setCodeType(rs.getString("OC_RFE_CODETYPE"));
                        reasonForEncounter.setFlags(ScreenHelper.checkString(rs.getString("OC_RFE_FLAGS")));
                    }

                    rs.close();
                    ps.close();
                }catch(Exception e){
                    Debug.println("OpenClinic => ReasonForEncounter.java => get => "+e.getMessage());
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
        return reasonForEncounter;
    }

    public static String getFlags(String codeType, String code){
        String flags = "";
        SAXReader reader = new SAXReader(false);
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"/rfe.xml";
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

    public static String getFlags(String codeType, String code, String flags){
        SAXReader reader = new SAXReader(false);
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"/rfe.xml";
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
