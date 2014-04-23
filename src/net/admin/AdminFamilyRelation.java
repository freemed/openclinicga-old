package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class AdminFamilyRelation {
    public String relationId;
    public String sourceId;
    public String destinationId;
    public String relationType;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public AdminFamilyRelation(){
        relationId    = "";
        sourceId      = "";
        destinationId = "";
        relationType  = "";
    }

    //--- DELETE ALL RELATIONS FOR PERSON ---------------------------------------------------------
    public static void deleteAllRelationsForPerson(String sourceId){
        String sSelect;
        PreparedStatement ps = null;

    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
       try{
            sSelect = "DELETE FROM AdminFamilyRelation WHERE sourceid = ?";
            ps = ad_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(sourceId));
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null)ps.close();
                ad_conn.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }
    }

    //--- SAVE TO DB ------------------------------------------------------------------------------
    public void saveToDB(Connection connection){
        String sSelect;
        boolean relationExists = false;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try{
            //*** CHECK EXISTENCE ***
            sSelect = "SELECT relationid FROM AdminFamilyRelation"+
                      " WHERE sourceid = ? AND destinationid = ? AND relationtype = ?";
            ps = connection.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(this.sourceId));
            ps.setInt(2,Integer.parseInt(this.destinationId));
            ps.setString(3,this.relationType);
            rs = ps.executeQuery();
            if(rs.next()){
                this.relationId = rs.getInt("relationid")+"";
                relationExists = true;
            }
            if(rs!=null)rs.close();
            if(ps!=null)ps.close();

            if(relationExists){
                //*** UPDATE ***
                sSelect = "UPDATE AdminFamilyRelation SET sourceid = ?, destinationid = ?, relationtype = ?,"+
                          "  updatetime = ?, updateserverid = ?"+
                          " WHERE relationid = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.sourceId));
                ps.setInt(2,Integer.parseInt(this.destinationId));
                ps.setString(3,this.relationType);
                ps.setTimestamp(4,new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setInt(5,MedwanQuery.getInstance().getConfigInt("serverId"));
                ps.setInt(6,Integer.parseInt(this.relationId));
                ps.executeUpdate();
            }
            else{
                //*** INSERT ***
                this.relationId = MedwanQuery.getInstance().getOpenclinicCounter("FamilyRelationID")+"";

                sSelect = "INSERT INTO AdminFamilyRelation (relationid, sourceid, destinationid,"+
                          "  relationtype, updatetime ,updateserverid)"+
                          " VALUES (?,?,?,?,?,?)";
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.relationId));
                ps.setInt(2,Integer.parseInt(this.sourceId));
                ps.setInt(3,Integer.parseInt(this.destinationId));
                ps.setString(4,this.relationType);
                ps.setTimestamp(5,new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setInt(6,MedwanQuery.getInstance().getConfigInt("serverId"));
                ps.executeUpdate();  
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null)rs.close();
                if(ps!=null)ps.close();
            }
            catch(SQLException sqle){
                sqle.printStackTrace();
            }
        }
    }

    //--- INITIALIZE ------------------------------------------------------------------------------
    public void initialize(Connection connection){
        String sSelect;
        PreparedStatement ps = null;
        ResultSet rs = null;

        if(this.relationId!=null && this.relationId.trim().length()>0){
            try{
                sSelect = "SELECT * FROM AdminFamilyRelation WHERE relationid = ?";
                ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(this.relationId));
                rs = ps.executeQuery();

                if(rs.next()){
                    this.relationId    = ScreenHelper.checkString(rs.getInt("relationid")+"");
                    this.sourceId      = ScreenHelper.checkString(rs.getInt("sourceid")+"");
                    this.destinationId = ScreenHelper.checkString(rs.getInt("destinationid")+"");
                    this.relationType  = ScreenHelper.checkString(rs.getString("relationtype"));
                }
            }
            catch(Exception e){
                e.printStackTrace();
            }
            finally{
                try{
                    if(rs!=null)rs.close();
                    if(ps!=null)ps.close();
                }
                catch(SQLException sqle){
                    sqle.printStackTrace();
                }
            }
        }
    }
    
}