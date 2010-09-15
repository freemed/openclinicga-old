package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Created by IntelliJ IDEA.
 * User: mxs-rudy
 * Date: 19-mrt-2007
 * Time: 18:03:19
 * To change this template use File | Settings | File Templates.
 */
public class Document {
    private int id;
    private String type;
    private String format;
    private String name;
    private String filename;
    private int userid;
    private String folder;
    private Timestamp updatetime;
    private int personid;


    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getFormat() {
        return format;
    }

    public void setFormat(String format) {
        this.format = format;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public int getUserid() {
        return userid;
    }

    public void setUserid(int userid) {
        this.userid = userid;
    }

    public String getFolder() {
        return folder;
    }

    public void setFolder(String folder) {
        this.folder = folder;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public int getPersonid() {
        return personid;
    }

    public void setPersonid(int personid) {
        this.personid = personid;
    }

    public static Document getDocumentByID(String sID){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "select * from Documents where id=?";

        Document document = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sID));

            rs = ps.executeQuery();

            if(rs.next()){
                document = new Document();
                document.setId(Integer.parseInt(sID));
                document.setType(ScreenHelper.checkString(rs.getString("type")));
                document.setFormat(ScreenHelper.checkString(rs.getString("format")));
                document.setName(ScreenHelper.checkString(rs.getString("name")));
                document.setFilename(ScreenHelper.checkString(rs.getString("filename")));
                document.setUserid(rs.getInt("userid"));
                document.setFolder(ScreenHelper.checkString(rs.getString("folder")));
                document.setUpdatetime(rs.getTimestamp("updatetime"));
                document.setPersonid(rs.getInt("personid"));
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
        return document;
    }
}
