package be.openclinic.assets;

import be.openclinic.common.OC_Object;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;

import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import java.util.*;
import java.io.StringReader;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

import org.dom4j.Document;
import org.dom4j.Element;
import org.dom4j.io.SAXReader;


public class Supplier extends OC_Object {
    public int serverId;
    public int objectId;    

    public String code;
    public String name;
    public String address;
    public String city;
    public String zipcode;
    public String country;
    public String vatNumber;
    public String taxIDNumber;
    public String contactPerson;
    public String telephone;
    public String email;
    public String accountingCode;
    public String comment;
    
    
    //--- CONSTRUCTOR ---
    public Supplier(){
        serverId = -1;
        objectId = -1;

        code = "";
        name = "";
        address = "";
        city = "";
        zipcode = "";
        country = "";
        vatNumber = "";
        taxIDNumber = "";
        contactPerson = "";
        telephone = "";
        email = "";
        accountingCode = "";
        comment = "";
    }
        
    //--- STORE -----------------------------------------------------------------------------------
    public boolean store(String userUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSql;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
                
        try{            
            if(getUid().equals("-1")){            	  
                // insert new supplier
                sSql = "INSERT INTO OC_SUPPLIERS(OC_SUPPLIER_SERVERID,OC_SUPPLIER_OBJECTID,OC_SUPPLIER_CODE,OC_SUPPLIER_NAME,"+
                       "  OC_SUPPLIER_ADDRESS,OC_SUPPLIER_CITY,OC_SUPPLIER_ZIPCODE,OC_SUPPLIER_COUNTRY,OC_SUPPLIER_VAT,"+
                	   "  OC_SUPPLIER_TAXID,OC_SUPPLIER_CONTACT,OC_SUPPLIER_TELEPHONE,OC_SUPPLIER_EMAIL,OC_SUPPLIER_ACCOUNTINGCODE,"+
                       "  OC_SUPPLIER_COMMENT,OC_SUPPLIER_UPDATETIME,OC_SUPPLIER_UPDATEID)"+
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"; // 17 
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("OC_SUPPLIERS");
                this.setUid(serverId+"."+objectId);
                                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setString(psIdx++,code);
                ps.setString(psIdx++,name);
                ps.setString(psIdx++,address);
                ps.setString(psIdx++,city);
                ps.setString(psIdx++,zipcode);
                ps.setString(psIdx++,country);
                ps.setString(psIdx++,vatNumber);
                ps.setString(psIdx++,taxIDNumber);
                ps.setString(psIdx++,contactPerson);
                ps.setString(psIdx++,telephone);
                ps.setString(psIdx++,email);
                ps.setString(psIdx++,accountingCode);
                ps.setString(psIdx++,comment);
                
                // update-info
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE OC_SUPPLIERS SET"+
                       "  OC_SUPPLIER_CODE = ?, OC_SUPPLIER_NAME = ?, OC_SUPPLIER_ADDRESS = ?, OC_SUPPLIER_CITY = ?,"+
                	   "  OC_SUPPLIER_ZIPCODE = ?, OC_SUPPLIER_COUNTRY = ?, OC_SUPPLIER_VAT = ?, OC_SUPPLIER_TAXID = ?,"+
                       "  OC_SUPPLIER_CONTACT = ?, OC_SUPPLIER_TELEPHONE = ?, OC_SUPPLIER_EMAIL = ?, OC_SUPPLIER_ACCOUNTINGCODE = ?,"+
                	   "  OC_SUPPLIER_COMMENT = ?,"+
                       "  OC_SUPPLIER_UPDATETIME = ?, OC_SUPPLIER_UPDATEID = ?"+ // update-info
                       " WHERE (OC_SUPPLIER_SERVERID = ? AND OC_SUPPLIER_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setString(psIdx++,code);
                ps.setString(psIdx++,name);
                ps.setString(psIdx++,address);
                ps.setString(psIdx++,city);
                ps.setString(psIdx++,zipcode);
                ps.setString(psIdx++,country);
                ps.setString(psIdx++,vatNumber);
                ps.setString(psIdx++,taxIDNumber);
                ps.setString(psIdx++,contactPerson);
                ps.setString(psIdx++,telephone);
                ps.setString(psIdx++,email);
                ps.setString(psIdx++,accountingCode);
                ps.setString(psIdx++,comment);

                // update-info
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx++,userUid);
                
                // where
                ps.setInt(psIdx++,Integer.parseInt(getUid().substring(0,getUid().indexOf("."))));
                ps.setInt(psIdx,Integer.parseInt(getUid().substring(getUid().indexOf(".")+1)));
                
                ps.executeUpdate();
            }            
        }
        catch(Exception e){
        	errorOccurred = true;
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }
    
    //--- DELETE ----------------------------------------------------------------------------------
    public static boolean delete(String ssupplierUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM OC_SUPPLIERS"+
                          " WHERE (OC_SUPPLIER_SERVERID = ? AND OC_SUPPLIER_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(ssupplierUid.substring(0,ssupplierUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(ssupplierUid.substring(ssupplierUid.indexOf(".")+1)));
            
            ps.executeUpdate();
        }
        catch(Exception e){
        	errorOccurred = true;
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return errorOccurred;
    }
    
    //--- GET -------------------------------------------------------------------------------------
    public static Supplier get(Supplier supplier){
    	return get(supplier.getUid());
    }
       
    public static Supplier get(String ssupplierUid){
    	Supplier supplier = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM OC_SUPPLIERS"+
                          " WHERE (OC_SUPPLIER_SERVERID = ? AND OC_SUPPLIER_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(ssupplierUid.substring(0,ssupplierUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(ssupplierUid.substring(ssupplierUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                supplier = new Supplier();
                supplier.setUid(rs.getString("OC_SUPPLIER_SERVERID")+"."+rs.getString("OC_SUPPLIER_OBJECTID"));
                supplier.serverId = Integer.parseInt(rs.getString("OC_SUPPLIER_SERVERID"));
                supplier.objectId = Integer.parseInt(rs.getString("OC_SUPPLIER_OBJECTID"));

                supplier.code           = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_CODE"));
                supplier.name           = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_NAME"));
                supplier.address        = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_ADDRESS"));
                supplier.city           = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_CITY"));
                supplier.zipcode        = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_ZIPCODE"));
                supplier.country        = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_COUNTRY"));
                supplier.vatNumber      = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_VAT"));
                supplier.taxIDNumber    = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_TAXID"));
                supplier.contactPerson  = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_CONTACT"));
                supplier.telephone      = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_TELEPHONE"));
                supplier.email          = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_EMAIL"));
                supplier.accountingCode = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_ACCOUNTINGCODE"));
                supplier.comment        = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_COMMENT"));
                
                // update-info
                supplier.setUpdateDateTime(rs.getTimestamp("OC_SUPPLIER_UPDATETIME"));
                supplier.setUpdateUser(rs.getString("OC_SUPPLIER_UPDATEID"));
            }
        }
        catch(Exception e){
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return supplier;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<Supplier> getList(){
    	return getList(new Supplier());     	
    }
    
    public static List<Supplier> getList(Supplier findItem){
        List<Supplier> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
        	//*** compose query ***************************
            String sSql = "SELECT * FROM OC_SUPPLIERS WHERE 1=1"; // 'where' facilitates further composition of query

            // search-criteria 
            if(findItem.code.length() > 0){
                sSql+= " AND OC_SUPPLIER_CODE LIKE '%"+findItem.code+"%'";
            }
            if(ScreenHelper.checkString(findItem.name).length() > 0){
                sSql+= " AND OC_SUPPLIER_NAME LIKE '%"+findItem.name+"%'";
            }
            if(ScreenHelper.checkString(findItem.vatNumber).length() > 0){
                sSql+= " AND OC_SUPPLIER_VAT LIKE '%"+findItem.vatNumber+"%'";
            }
            
            sSql+= " ORDER BY OC_SUPPLIER_NAME ASC";
            
            ps = oc_conn.prepareStatement(sSql);
            
                        
            //*** execute query ***************************
            rs = ps.executeQuery();
            Supplier supplier;
            
            while(rs.next()){
            	supplier = new Supplier();   
            	supplier.setUid(rs.getString("OC_SUPPLIER_SERVERID")+"."+rs.getString("OC_SUPPLIER_OBJECTID"));
                supplier.serverId = Integer.parseInt(rs.getString("OC_SUPPLIER_SERVERID"));
                supplier.objectId = Integer.parseInt(rs.getString("OC_SUPPLIER_OBJECTID"));

                supplier.code           = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_CODE"));
                supplier.name           = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_NAME"));
                supplier.address        = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_ADDRESS"));
                supplier.city           = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_CITY"));
                supplier.zipcode        = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_ZIPCODE"));
                supplier.country        = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_COUNTRY"));
                supplier.vatNumber      = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_VAT"));
                supplier.taxIDNumber    = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_TAXID"));
                supplier.contactPerson  = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_CONTACT"));
                supplier.telephone      = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_TELEPHONE"));
                supplier.email          = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_EMAIL"));
                supplier.accountingCode = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_ACCOUNTINGCODE"));
                supplier.comment        = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_COMMENT"));
               
                // update-info
                supplier.setUpdateDateTime(rs.getTimestamp("OC_SUPPLIER_UPDATETIME"));
                supplier.setUpdateUser(rs.getString("OC_SUPPLIER_UPDATEID"));
                
                foundObjects.add(supplier);
            }
        }
        catch(Exception e){
        	if(Debug.enabled) e.printStackTrace();
            Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                Debug.printProjectErr(se,Thread.currentThread().getStackTrace());
            }
        }
        
        return foundObjects;
    }

}