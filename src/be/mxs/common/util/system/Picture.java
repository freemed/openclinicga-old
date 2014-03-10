package be.mxs.common.util.system;

import be.mxs.common.util.db.MedwanQuery;
import com.itextpdf.text.Image;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class Picture {
    private int personid;
    private byte[] picture;


    //--- CONSTRUCTOR (1) -------------------------------------------------------------------------
    public Picture(){
        personid = 0;
        picture = null;
    }

    //--- CONSTRUCTOR (2) ---------------------------------------------------------------------------
    public Picture(int personid){
        this.personid = personid;
    	
    	Connection oc_conn = null;
    	PreparedStatement ps = null;
    	ResultSet rs = null;
        
        try{
            oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        	ps = oc_conn.prepareStatement("select picture from OC_PERSON_PICTURES where personid = ?");
            ps.setInt(1,personid);
            rs = ps.executeQuery();
            
            if(rs.next()){
                picture = rs.getBytes("picture");
            }
        }
        catch(SQLException e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                if(oc_conn!=null) oc_conn.close();
            }
            catch(Exception e){
            	e.printStackTrace();
            }
        }
    }

    //--- PERSONID --------------------------------------------------------------------------------
    public int getPersonid(){
        return personid;
    }

    public void setPersonid(int personid){
        this.personid = personid;
    }

    //--- PICTURE ---------------------------------------------------------------------------------
    public byte[] getPicture(){
        return picture;
    }

    public void setPicture(byte[] picture){
        this.picture = picture;
    }
    
    //--- GET IMAGE -------------------------------------------------------------------------------
    public Image getImage(){
        if(picture==null) return null;
        
        Image image = null;
        try{
            image = Image.getInstance(picture);
        }
        catch(Exception e){
            e.printStackTrace();
        }
        
        return image;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public boolean store(){
    	boolean stored = false;
    	
    	Connection oc_conn = null;
    	PreparedStatement ps = null;
    	ResultSet rs = null;
    	
        try{
        	// "replace"
            oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
            ps = oc_conn.prepareStatement("delete from OC_PERSON_PICTURES where personid = ?");
            ps.setInt(1,personid);
            ps.executeUpdate();
            ps.close();
            
            ps = oc_conn.prepareStatement("insert into OC_PERSON_PICTURES(personid,picture) values(?,?)");
            ps.setInt(1,personid);
            ps.setBytes(2,picture);
            ps.executeUpdate();
            
            stored = true;
        }
        catch(SQLException e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(oc_conn!=null) oc_conn.close();
            }
            catch(Exception e){
            	e.printStackTrace();
            }
        }
        
        return stored;
    }

    //--- EXISTS ----------------------------------------------------------------------------------
    public static boolean exists(int personid){
    	boolean exists = false;

    	Connection oc_conn = null;
    	PreparedStatement ps = null;
    	ResultSet rs = null;
    	
        try{
            oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
            ps = oc_conn.prepareStatement("select 1 from OC_PERSON_PICTURES where personid = ?");
            ps.setInt(1,personid);
            rs = ps.executeQuery();
            
            if(rs.next()) exists = true;
        }
        catch(SQLException e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                if(oc_conn!=null) oc_conn.close();
            }
            catch(Exception e){
            	e.printStackTrace();
            }
        }
        
        return exists;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public boolean delete(){
    	boolean deleted = false;

    	Connection oc_conn = null;
    	PreparedStatement ps = null;
    	
        try{
        	oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
            ps = oc_conn.prepareStatement("delete from OC_PERSON_PICTURES where personid = ?");
            ps.setInt(1,personid);
            ps.executeUpdate();
            
            deleted = true;
        }
        catch(SQLException e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(oc_conn!=null) oc_conn.close();
            }
            catch(Exception e){
            	e.printStackTrace();
            }
        }
        
        return deleted;
    }
    
}
