package be.openclinic.medical;

import be.openclinic.adt.Encounter;
import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.util.Date;
import java.util.LinkedList;
import java.util.Vector;
import java.util.Iterator;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.net.URL;
import java.net.MalformedURLException;

import net.admin.User;
import org.dom4j.io.SAXReader;
import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Element;

/**
 * User: Frank
 * Date: 12-jan-2009
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

    //--- GETTERS AND SETTERS ---------------------------------------------------------------------
    public String getFlags(){
        return flags;
    }

    public void setFlags(String flags){
        this.flags = flags;
    }

    public String getCodeType(){
        return codeType;
    }

    public void setCodeType(String codeType){
        this.codeType = codeType;
    }

    public String getCode(){
        return code;
    }

    public void setCode(String code){
        this.code = code;
    }

    public Date getDate(){
        return date;
    }

    public void setDate(Date date){
        this.date = date;
    }

    public String getEncounterUID(){
        return this.encounterUID;
    }

    public void setEncounterUID(String encounterUID){
        this.encounterUID = encounterUID;
    }

    //--- ENCOUNTER -------------------------------------------------------------------------------
    public void setEncounter(Encounter encounter){
        this.encounter = encounter;
        setEncounterUID(encounter.getUid());
    }
    
    public Encounter getEncounter(){
        if(encounter==null || !encounter.getUid().equalsIgnoreCase(getEncounterUID())){
            encounter = Encounter.get(encounterUID);
        }
        
        return encounter;
    }

    //--- GET AUTHOR ------------------------------------------------------------------------------
    public User getAuthor(){
        if(this.author == null || !this.author.userid.equalsIgnoreCase(getAuthorUID())){
            User tmpUser = new User();
            if(this.authorUID != null &&this.authorUID.length() > 0){
                boolean bCheck = tmpUser.initialize(Integer.parseInt(this.authorUID));
                if(bCheck){
                    this.setAuthor(tmpUser);
                }
            }
            else{
                this.author = null;
            }
        }
        
        return author;
    }

    public void setAuthor(User author){
        this.author = author;
        setAuthorUID(author.userid);
    }

    //--- AUTHOR UID ------------------------------------------------------------------------------
    public String getAuthorUID(){
        return authorUID;
    }

    public void setAuthorUID(String authorUID){
        this.authorUID = authorUID;
    }

    //--- DELETE (1) ------------------------------------------------------------------------------
    public void delete(){
        PreparedStatement ps;
        String sDelete;
        String ids[];
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() >0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                    sDelete = "DELETE FROM OC_RFE "+
                              " WHERE OC_RFE_SERVERID = ?"+
                              "  AND OC_RFE_OBJECTID = ?";
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
        
        // close connection
        try{
			oc_conn.close();
		}
        catch (SQLException e){
			e.printStackTrace();
		}
    }

    //--- DELETE (2) ------------------------------------------------------------------------------
    public static void delete(int serverid,int objectid){
        PreparedStatement ps;
        String sDelete;
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            sDelete = "DELETE FROM OC_RFE"+
                      " WHERE OC_RFE_SERVERID = ?"+
                      "  AND OC_RFE_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sDelete);
            ps.setInt(1,serverid);
            ps.setInt(2,objectid);
            ps.executeUpdate();
            ps.close();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch (SQLException e){
			e.printStackTrace();
		}
    }

    //--- STORE -----------------------------------------------------------------------------------
    public void store(){
        PreparedStatement ps;
        ResultSet rs;
        String sSelect, sInsert, sDelete;

        int iVersion = 1;
        String ids[];
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()!=null && this.getUid().length() > 0){
                ids = this.getUid().split("\\.");
                if(ids.length == 2){
                    sSelect = "SELECT * FROM OC_RFE"+
                              " WHERE OC_RFE_SERVERID = ?"+
                              "  AND OC_RFE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        iVersion = rs.getInt("OC_RFE_VERSION")+1;
                    }

                    rs.close();
                    ps.close();

                    sInsert = "INSERT INTO OC_RFE_HISTORY"+
                              " SELECT OC_RFE_SERVERID,"+
                              "  OC_RFE_OBJECTID,"+
                              "  OC_RFE_ENCOUNTERUID,"+
                              "  OC_RFE_CODETYPE,"+
                              "  OC_RFE_CODE,"+
                              "  OC_RFE_DATE,"+
                              "  OC_RFE_FLAGS,"+
                              "  OC_RFE_VERSION,"+
                              "  OC_RFE_CREATETIME,"+
                              "  OC_RFE_UPDATETIME,"+
                              "  OC_RFE_UPDATEUID"+
                              " FROM OC_RFE"+
                              " WHERE OC_RFE_SERVERID = ?"+
                              " AND OC_RFE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sInsert);
                    ps.setInt(1,Integer.parseInt(ids[0]));
                    ps.setInt(2,Integer.parseInt(ids[1]));
                    ps.executeUpdate();
                    ps.close();

                }
            }
            else{
                ids = new String[]{
                		MedwanQuery.getInstance().getConfigString("serverId"),
                		MedwanQuery.getInstance().getOpenclinicCounter("OC_RFE")+""
                	  };
            }
            
            if(ids.length == 2){
                sDelete = "DELETE FROM OC_RFE"+
                          " WHERE OC_RFE_ENCOUNTERUID = ?"+
                          "  AND OC_RFE_CODETYPE = ?"+
                          "  AND OC_RFE_CODE = ?";

                ps = oc_conn.prepareStatement(sDelete);
                ps.setString(1,this.getEncounterUID());
                ps.setString(2,this.getCodeType());
                ps.setString(3,this.getCode());
                ps.executeUpdate();
                ps.close();

                sInsert = "INSERT INTO OC_RFE("+
                          " OC_RFE_SERVERID,"+
                          " OC_RFE_OBJECTID,"+
                          " OC_RFE_ENCOUNTERUID,"+
                          " OC_RFE_CODETYPE,"+
                          " OC_RFE_CODE,"+
                          " OC_RFE_DATE,"+
                          " OC_RFE_FLAGS,"+
                          " OC_RFE_VERSION,"+
                          " OC_RFE_CREATETIME,"+
                          " OC_RFE_UPDATETIME,"+
                          " OC_RFE_UPDATEUID)"+
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sInsert);
                ps.setInt(1,Integer.parseInt(ids[0]));
                ps.setInt(2,Integer.parseInt(ids[1]));
                if(this.getEncounter()!=null){
                    ps.setString(3,ScreenHelper.checkString(this.getEncounter().getUid()));
                }
                else{
                    ps.setString(3,"");
                }
                ps.setString(4,this.getCodeType());
                ps.setString(5,this.getCode());
                if(this.getDate()==null){
                    ps.setNull(6,Types.DATE);
                }
                else{
                    ps.setDate(6,new java.sql.Date(this.getDate().getTime()));
                }
                ps.setString(7,this.getFlags());
                ps.setInt(8,iVersion);
                ps.setTimestamp(9,new Timestamp(this.getCreateDateTime().getTime()));
                ps.setTimestamp(10,new Timestamp(this.getUpdateDateTime().getTime()));
                ps.setString(11,this.getUpdateUser());
                ps.executeUpdate();
                ps.close();
                
                this.setUid(ids[0]+"."+ids[1]);
            }
        }
        catch(Exception e){
            Debug.println("OpenClinic => ReasonForEncounter.java => store => "+e.getMessage());
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
    }

    //--- GET REASONS FOR ENCOUNTER BY ENCOUNTER UID ----------------------------------------------
    public static Vector getReasonsForEncounterByEncounterUid(String encounterUid){
        Vector reasonsForEncounter = new Vector();
        PreparedStatement ps;
        ResultSet rs;
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSelect = "SELECT * FROM OC_RFE"+
                             " WHERE OC_RFE_ENCOUNTERUID = ?"+
            		         "  ORDER BY OC_RFE_CODETYPE, OC_RFE_CODE";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,encounterUid);
            rs = ps.executeQuery();
            
            ReasonForEncounter reasonForEncounter; 
            while(rs.next()){
                reasonForEncounter = new ReasonForEncounter();
                reasonForEncounter.encounterUID = ScreenHelper.checkString(rs.getString("OC_RFE_ENCOUNTERUID"));
                reasonForEncounter.authorUID    = ScreenHelper.checkString(rs.getString("OC_RFE_UPDATEUID"));

                reasonForEncounter.setUid(ScreenHelper.checkString(rs.getString("OC_RFE_SERVERID"))+"."+ScreenHelper.checkString(rs.getString("OC_RFE_OBJECTID")));
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
        }
        catch(Exception e){
            Debug.println("OpenClinic => ReasonForEncounter.java => get => "+e.getMessage());
            e.printStackTrace();
        }
        
        // close connection
        try{
			oc_conn.close();
		}
        catch(SQLException e){
			e.printStackTrace();
		}
        
        return reasonsForEncounter;
    }

    //--- GET REASONS FOR ENCOUNTER AS HTML -------------------------------------------------------
    public static String getReasonsForEncounterAsHtml(Encounter encounter, String sWebLanguage, String deleteImg, String deleteFunction){
        if(encounter==null) return "";
        return getReasonsForEncounterAsHtml(encounter.getUid(),sWebLanguage,deleteImg,deleteFunction);
    }

    //--- GET REASONS FOR ENCOUNTER AS HTML -------------------------------------------------------
    public static String getReasonsForEncounterAsHtml(String encounterUid, String sWebLanguage, String deleteImg, String deleteFunction){
        String sHtml = "<table cellspacing='0' cellpadding='2' width='100%'>";
        
        Vector reasonsForEncounter = ReasonForEncounter.getReasonsForEncounterByEncounterUid(encounterUid);
        if(reasonsForEncounter.size()==0) return "";
        
        String sClass = "1";
        ReasonForEncounter reasonForEncounter;
        for(int n=0; n<reasonsForEncounter.size(); n++){
            reasonForEncounter = (ReasonForEncounter)reasonsForEncounter.elementAt(n);

            // alternate row-style
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";
            
            sHtml+= "<tr class='list"+sClass+"'>"+
                     "<td><img src='"+deleteImg+"' onmouseover='this.style.cursor=\"pointer\"' onmouseout='this.style.cursor=\"default\"' onclick='"+deleteFunction.replaceAll("\\$serverid",reasonForEncounter.getUid().split("\\.")[0]).replaceAll("\\$objectid",reasonForEncounter.getUid().split("\\.")[1])+"'/></td>"+
                     "<td>"+reasonForEncounter.getCodeType().toUpperCase()+"</td>"+
                     "<td><b>"+reasonForEncounter.getCode()+"</b></td>"+
                     "<td><b>"+MedwanQuery.getInstance().getCodeTran(reasonForEncounter.getCodeType()+"code"+reasonForEncounter.getCode(),sWebLanguage)+"</b></td>"+
                    "</tr>";
        }
        sHtml+= "</table>";
        
        return sHtml;
    }

    //--- GET REASONS FOR ENCOUNTER AS HTML -------------------------------------------------------
    public static String getReasonsForEncounterAsHtml(String encounterUid, String sWebLanguage){
        String sHtml = "<table cellpadding='0' cellspacing='1' style='border:1px solid #ddd'>";
        
        Vector reasonsForEncounter = ReasonForEncounter.getReasonsForEncounterByEncounterUid(encounterUid);
        if(reasonsForEncounter.size()==0) return "";

        String sClass = "1";
        ReasonForEncounter reasonForEncounter;
        for(int n=0; n<reasonsForEncounter.size(); n++){
            reasonForEncounter = (ReasonForEncounter)reasonsForEncounter.elementAt(n);

            // alternate row-style
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";
            
            sHtml+= "<tr class='list"+sClass+"'>"+
                     "<td>"+reasonForEncounter.getCodeType().toUpperCase()+"</td>"+
                     "<td><b>"+reasonForEncounter.getCode()+"</b></td>"+
                     "<td><b>"+MedwanQuery.getInstance().getCodeTran(reasonForEncounter.getCodeType()+"code"+reasonForEncounter.getCode(),sWebLanguage)+"</b></td>"+
                    "</tr>";
        }
        sHtml+= "</table>";
        
        return sHtml;
    }
    
    //--- GET REASONS FOR ENCOUNTER AS TEXT -------------------------------------------------------
    public static String getReasonsForEncounterAsText(String encounterUid, String sWebLanguage){
        Vector reasonsForEncounter = ReasonForEncounter.getReasonsForEncounterByEncounterUid(encounterUid);
        if(reasonsForEncounter.size()==0) return "";

        String sText = "";
        ReasonForEncounter reasonForEncounter;
        for(int n=0; n<reasonsForEncounter.size(); n++){
            reasonForEncounter = (ReasonForEncounter)reasonsForEncounter.elementAt(n);
            
            sText+= "("+reasonForEncounter.getCodeType().toUpperCase()+") "+reasonForEncounter.getCode()+" - "+
                    MedwanQuery.getInstance().getCodeTran(reasonForEncounter.getCodeType()+"code"+reasonForEncounter.getCode(),sWebLanguage)+"\n";                    
        }
        
        return sText;
    }
    
    //--- GET REASON FOR ENCOUNTER ----------------------------------------------------------------
    public static ReasonForEncounter get(String uid){
        ReasonForEncounter reasonForEncounter = new ReasonForEncounter();
        PreparedStatement ps;
        ResultSet rs;

        if(uid!=null && uid.length() > 0){
            String sUids[] = uid.split("\\.");
            
            if(sUids.length==2){
                Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
                try{
                    String sSelect = "SELECT * FROM OC_RFE"+
                                     " WHERE OC_RFE_SERVERID = ?"+
                                     "  AND OC_RFE_OBJECTID = ?";
                    ps = oc_conn.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sUids[0]));
                    ps.setInt(2,Integer.parseInt(sUids[1]));

                    rs = ps.executeQuery();

                    if(rs.next()){
                        reasonForEncounter.encounterUID = ScreenHelper.checkString(rs.getString("OC_RFE_ENCOUNTERUID"));
                        reasonForEncounter.authorUID    = ScreenHelper.checkString(rs.getString("OC_RFE_UPDATEUID"));

                        reasonForEncounter.setUid(ScreenHelper.checkString(rs.getString("OC_RFE_SERVERID"))+"."+ScreenHelper.checkString(rs.getString("OC_RFE_OBJECTID")));
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
                }
                catch(Exception e){
                    Debug.println("OpenClinic => ReasonForEncounter.java => get => "+e.getMessage());
                    e.printStackTrace();
                }
                
                // close connection
                try{
        			oc_conn.close();
        		}
                catch(SQLException e){
        			e.printStackTrace();
        		}
            }
        }
        
        return reasonForEncounter;
    }

    //--- GET FLAGS (1) ---------------------------------------------------------------------------
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
                if(flags.indexOf(f.attributeValue("flag"))<0 &&
                   f.attributeValue("codetype").equalsIgnoreCase(codeType) &&
                   f.attributeValue("start").compareTo(code)<1 &&
                   f.attributeValue("end").compareTo(code)>-1){
                    flags+= f.attributeValue("flag");
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        return flags;
    }

    //--- GET FLAGS (2) ---------------------------------------------------------------------------
    public static String getFlags(String codeType, String code, String flags){
        SAXReader reader = new SAXReader(false);
        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"/rfe.xml";
        try{
            Document document = reader.read(new URL(sDoc));
            Element root = document.getRootElement();
            Element e = root.element("flags");
            Iterator flagElements = e.elementIterator("flag");
            while(flagElements.hasNext()){
                Element f = (Element)flagElements.next();
                if(flags.indexOf(f.attributeValue("flag"))<0 &&
                   f.attributeValue("codetype").equalsIgnoreCase(codeType) &&
                   f.attributeValue("start").compareTo(code)<1 &&
                   f.attributeValue("end").compareTo(code)>-1){
                    flags+= f.attributeValue("flag");
                }
            }
        } 
        catch(Exception e){
            e.printStackTrace();
        }
        
        return flags;
    }
    
}