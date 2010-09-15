package net.admin;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


public class AdminFunction {
	public String code;
	public String type;
    public String category;

    //--- CONSTRUCTOR -----------------------------------------------------------------------------
    public AdminFunction() {
        code = "";
        type = "";
        category = "";
    }

    //--- SAVE TO DB ------------------------------------------------------------------------------
    public boolean saveToDB(String sWorkID, Connection connection){
        boolean bReturn = true;
        String sSelect = "";

        if(this.code.trim().length() > 0){
            try{
                String sType = "";
                if(this.type.length()>0){
                    sType = this.type.substring(0,1).toUpperCase();
                }
//          Helper.updateLabel("FunctionType", sType, this.type, "nl", connection);
                String lcaseFunctionType = MedwanQuery.getInstance().getConfigParam("lowerCompare","functiontype");
                sSelect = "SELECT workid FROM AdminFunctions WHERE workid = ? AND "+lcaseFunctionType+" = ? AND functionid = ? ";
                PreparedStatement ps = connection.prepareStatement(sSelect);
                ps.setInt(1,Integer.parseInt(sWorkID));
                ps.setString(2,sType.toLowerCase());
                ps.setString(3,this.code);
                ResultSet rs = ps.executeQuery();

                if (rs.next()) {
                    sSelect = "UPDATE AdminFunctions SET updatetime = ?, deletetime = null, "+
                              " functioncategory = ?,updateserverid="+MedwanQuery.getInstance().getConfigInt("serverId")+" WHERE workid = ? AND "+lcaseFunctionType+" = ? AND functionid = ?";
                    rs.close();
                    ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()));
                    ps.setString(2,this.category);
                    ps.setInt(3,Integer.parseInt(sWorkID));
                    ps.setString(4,sType.toLowerCase());
                    ps.setString(5,this.code);
                    ps.executeUpdate();
                    ps.close();
                }
                else {
                     sSelect = " INSERT INTO AdminFunctions(workid, functionid, functiontype, updatetime, functioncategory,updateserverid) "
                        +" VALUES (?,?,?,?,?,"+MedwanQuery.getInstance().getConfigInt("serverId")+")";
                     rs.close();
                     ps.close();
                    ps = connection.prepareStatement(sSelect);
                    ps.setInt(1,Integer.parseInt(sWorkID));
                    ps.setString(2,this.code);
                    ps.setString(3,sType);
                    ps.setTimestamp(4,new java.sql.Timestamp(new java.util.Date().getTime()));
                    ps.setString(5,this.category);
                    ps.executeUpdate();
                    ps.close();
                }
            }
            catch(SQLException e){
                ScreenHelper.writeMessage(getClass()+" (1) "+e.getMessage()+" "+sSelect);
                bReturn = false;
            }
        }

        return bReturn;
    }
}