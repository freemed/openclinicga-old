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

    public int getPersonid() {
        return personid;
    }

    public void setPersonid(int personid) {
        this.personid = personid;
    }

    public byte[] getPicture() {
        return picture;
    }

    public void setPicture(byte[] picture) {
        this.picture = picture;
    }


    public Picture() {
        personid = 0;
        picture = null;
    }

    public Image getImage(){
        if(picture==null){
            return null;
        }
        Image image = null;
        try{
            image=Image.getInstance(picture);
        }
        catch(Exception e){
            e.printStackTrace();
        }
        return image;
    }

    public Picture(int personid) {
        this.personid = personid;
        try {
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        	PreparedStatement ps = oc_conn.prepareStatement("select * from OC_PERSON_PICTURES where personid=?");
            ps.setInt(1,personid);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                picture=rs.getBytes("picture");
            }
            rs.close();
            ps.close();
            oc_conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public boolean store(){
        try {
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            PreparedStatement ps = oc_conn.prepareStatement("delete from OC_PERSON_PICTURES where personid=?");
            ps.setInt(1,personid);
            ps.executeUpdate();
            ps.close();
            ps = oc_conn.prepareStatement("insert into OC_PERSON_PICTURES(personid,picture) values(?,?)");
            ps.setInt(1,personid);
            ps.setBytes(2,picture);
            ps.executeUpdate();
            ps.close();
            oc_conn.close();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public static boolean exists(int personid){
        boolean result=false;
        try {
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            PreparedStatement ps = oc_conn.prepareStatement("select personid from OC_PERSON_PICTURES where personid=?");
            ps.setInt(1,personid);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                result=true;
            }
            rs.close();
            ps.close();
            oc_conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    public boolean delete(){
        try {
            Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
            PreparedStatement ps = oc_conn.prepareStatement("delete from OC_PERSON_PICTURES where personid=?");
            ps.setInt(1,personid);
            ps.executeUpdate();
            ps.close();
            oc_conn.close();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
