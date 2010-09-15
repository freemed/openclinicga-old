package org.hnrw.report;

import be.mxs.common.util.db.MedwanQuery;

import java.util.Date;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;



/**
 * Created by IntelliJ IDEA.
 * User: Frank
 * Date: 12-jan-2009
 * Time: 12:38:05
 * To change this template use File | Settings | File Templates.
 */
public class Report {
    Date begin;
    Date end;
    Report_Identification report_identification;

    public int countItems(Date begin,Date end,String transactionType,String itemType,String itemValue){
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select count(distinct transactionId) as total from Transactions a,Items b where a.serverid=b.serverid and" +
                    "a.transactionId=b.transactionId and" +
                    "a.transactionType=? and " +
                    "a.updateTime>=? and " +
                    "a.updateTime<? and " +
                    "b.type=? and" +
                    "b.value=?");
            ps.setString(1,transactionType);
            ps.setDate(2,new java.sql.Date(begin.getTime()));
            ps.setDate(3,new java.sql.Date(end.getTime()));
            ps.setString(4,itemType);
            ps.setString(5,itemValue);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return total;
    }

    public int countItems(Date begin,Date end,String transactionType,String itemType){
        int total = 0;
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try {
            PreparedStatement ps = oc_conn.prepareStatement("select count(distinct transactionId) as total from Transactions a,Items b where a.serverid=b.serverid and" +
                    "a.transactionId=b.transactionId and" +
                    "a.transactionType=? and " +
                    "a.updateTime>=? and " +
                    "a.updateTime<? and " +
                    "b.type=?");
            ps.setString(1,transactionType);
            ps.setDate(2,new java.sql.Date(begin.getTime()));
            ps.setDate(3,new java.sql.Date(end.getTime()));
            ps.setString(4,itemType);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                total = rs.getInt("total");
            }
            rs.close();
            ps.close();
        }
        catch (Exception e) {
            e.printStackTrace();
        }
        try {
			oc_conn.close();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
        return total;
    }
}
