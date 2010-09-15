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
 * Date: 9-mrt-2007
 * Time: 9:44:20
 * To change this template use File | Settings | File Templates.
 */
public class ExportSpecification {
    String elementType;
    String exportCode;
    String elementContent;
    Timestamp updatetime;


    public String getElementType() {
        return elementType;
    }

    public void setElementType(String elementType) {
        this.elementType = elementType;
    }

    public String getExportCode() {
        return exportCode;
    }

    public void setExportCode(String exportCode) {
        this.exportCode = exportCode;
    }

    public String getElementContent() {
        return elementContent;
    }

    public void setElementContent(String elementContent) {
        this.elementContent = elementContent;
    }

    public Timestamp getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public static boolean exists(String elementType){
        PreparedStatement ps = null;
        ResultSet rs = null;

        boolean exportSpecificationFound = false;

        String sSelect = "SELECT 1 FROM exportSpecifications WHERE elementType = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,elementType);
            rs = ps.executeQuery();

            if(rs.next()){
                exportSpecificationFound = true;
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
        return exportSpecificationFound;
    }

    public void insert(){
        PreparedStatement ps = null;

        String sInsert = "INSERT INTO exportSpecifications VALUES(?,?,?,?)";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setString(1, this.getElementType());
            ps.setString(2, this.getExportCode());
            ps.setString(3, this.getElementContent());
            ps.setTimestamp(4, this.getUpdatetime());
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

    public void update(String elementType){
        PreparedStatement ps = null;

        String sInsert = " UPDATE exportSpecifications SET elementType = ?, " +
                                                         " exportCode = ?, " +
                                                         " elementContent = ?," +
                                                         " updatetime = ?" +
                         " WHERE elementType=?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sInsert);
            ps.setString(1, this.getElementType());
            ps.setString(2, this.getExportCode());
            ps.setString(3, this.getElementContent());
            ps.setTimestamp(4, this.getUpdatetime());
            ps.setString(5,elementType);
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

    public static String getExportCodeByElementType(String sElementType){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sCode = "";
        
        String sSelect = "SELECT exportCode FROM exportSpecifications WHERE elementType = ?";

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,sElementType);

            rs = ps.executeQuery();

            if(rs.next()){
                sCode = ScreenHelper.checkString(rs.getString("exportCode"));
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
        return sCode;
    }
}
