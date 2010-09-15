package be.openclinic.id;

import be.mxs.common.util.db.MedwanQuery;

import java.util.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class Barcode {
    private int personid;
    private int userid;
    private Timestamp updatetime;

    public Barcode() {
        personid = 0;
        userid = 0;
        updatetime = new Timestamp(new java.util.Date().getTime());
    }

    public int getPersonid() {
        return personid;
    }

    public void setPersonid(int personid) {
        this.personid = personid;
    }

    public int getUserid() {
        return userid;
    }

    public void setUserid(int userid) {
        this.userid = userid;
    }

    public Date getUpdatetime() {
        return updatetime;
    }

    public void setUpdatetime(Timestamp updatetime) {
        this.updatetime = updatetime;
    }

    public static boolean exists(int personid){
        boolean exists=false;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps= oc_conn.prepareStatement("SELECT 1 FROM OC_BARCODES WHERE personid=?");
            ps.setInt(1,personid);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                exists=true;
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
        return exists;
    }

    public Barcode(int ipersonid) {
        this.personid = ipersonid;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select * from OC_BARCODES where personid=?");
            ps.setInt(1,this.personid);
            ResultSet rs = ps.executeQuery();
            if(rs.next()){
                this.personid = rs.getInt("personid");
                this.userid = rs.getInt("updateuserid");
                this.updatetime = rs.getTimestamp("personid");
            }
            rs.close();
            ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
    }

    public boolean store(){
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("delete from OC_BARCODES where personid=?");
            ps.setInt(1,personid);
            ps.executeUpdate();
            ps.close();
            ps = oc_conn.prepareStatement("insert into OC_BARCODES(personid,updateuserid,updatetime) values(?,?,?)");
            ps.setInt(1,personid);
            ps.setInt(2,userid);
            ps.setTimestamp(3,updatetime);
            ps.executeUpdate();
            ps.close();
            oc_conn.close();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return false;
    }
}
