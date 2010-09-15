package be.openclinic.system;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Vector;
import java.util.Hashtable;

/**
 * Created by IntelliJ IDEA.
 * User: mxs_david
 * Date: 11-jan-2007
 * Time: 13:19:19
 * To change this template use Options | File Templates.
 */
public class Macro {

    private String id;
    private String category;
    private String nl;
    private String fr;
    Timestamp updatetime;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getNl() {
        return nl;
    }

    public void setNl(String nl) {
        this.nl = nl;
    }

    public String getFr() {
        return fr;
    }

    public void setFr(String fr) {
        this.fr = fr;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }


    public static void addMacro(Macro objMacro){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO Macros (id, category, nl, fr) VALUES (?,?,?,?)";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setString(1,objMacro.getId());
            ps.setString(2,objMacro.getCategory());
            ps.setString(3,objMacro.getNl());
            ps.setString(4,objMacro.getFr());
            ps.executeUpdate();
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

    public static void saveMacro(Macro objMacro, String sOldId){
        PreparedStatement ps = null;

        String sUpdate = "UPDATE Macros SET id = ?, category = ?, nl = ?, fr = ? WHERE id = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sUpdate);
            ps.setString(1,objMacro.getId());
            ps.setString(2,objMacro.getCategory());
            ps.setString(3,objMacro.getNl());
            ps.setString(4,objMacro.getFr());
            ps.setString(5,sOldId);
            ps.executeUpdate();
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

    public static void deleteMacro(String sId){
        PreparedStatement ps = null;

        String sDelete = "DELETE FROM Macros WHERE id = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sDelete);
            ps.setString(1,sId);
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

    public static Vector getDistinctCategoryFromMacros(){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vCategories = new Vector();
        String sCategory;

        String sSelect = "SELECT DISTINCT category FROM Macros ORDER BY category ASC";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            rs = ps.executeQuery();

            while(rs.next()){
                sCategory = ScreenHelper.checkString(rs.getString("category"));
                vCategories.addElement(sCategory);
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
        return vCategories;
    }

    public static Vector getId_NameFromMacros(String sLanguage,String sSelectedCategory){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector vMacros = new Vector();
        Hashtable hMacroInfo;

        String sSelect = "SELECT id,"+sLanguage+" AS name FROM Macros";

        if(sSelectedCategory.length() > 0){
            sSelect+= " WHERE category = ?";
        }
        else{
            sSelect+= " ORDER BY id";
        }
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            if(sSelectedCategory.length() > 0){
                ps.setString(1,sSelectedCategory);
            }
            rs = ps.executeQuery();
            while(rs.next()){
                hMacroInfo = new Hashtable();
                hMacroInfo.put("id",ScreenHelper.checkString(rs.getString("id")));
                hMacroInfo.put("name",ScreenHelper.checkString(rs.getString("name")));

                vMacros.addElement(hMacroInfo);
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
        return vMacros;
    }

    public static Macro getMacro(String sId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Macro objMacro = new Macro();

        String sSelect = "SELECT * FROM Macros WHERE id = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sId);

            rs = ps.executeQuery();

            if(rs.next()){
                objMacro.setId(ScreenHelper.checkString(rs.getString("id")));
                objMacro.setCategory(ScreenHelper.checkString(rs.getString("category")));
                objMacro.setNl(ScreenHelper.checkString(rs.getString("nl")));
                objMacro.setFr(ScreenHelper.checkString("fr"));
                objMacro.setUpdatetime(rs.getTimestamp("updatetime"));
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
        return objMacro;
    }

    public static Vector selectMacrosByCatagoryAndId(String sCategory,String sId){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Vector vMacros = new Vector();
        Macro objMacro;
        String sSelect = "SELECT * FROM Macros WHERE category LIKE ? AND id LIKE ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sCategory+"%");
            ps.setString(2,sId+"%");
            rs = ps.executeQuery();
            while(rs.next()){
                objMacro = new Macro();

                objMacro.setId(ScreenHelper.checkString(rs.getString("id")));
                objMacro.setCategory(ScreenHelper.checkString(rs.getString("category")));
                objMacro.setNl(ScreenHelper.checkString(rs.getString("nl")));
                objMacro.setFr(ScreenHelper.checkString(rs.getString("fr")));
                objMacro.setUpdatetime(rs.getTimestamp("updatetime"));

                vMacros.addElement(objMacro);
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
        return vMacros;
    }

}
