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


public class Asset extends OC_Object {
    public int serverId;
    public int objectId;    

    public String code;
    public String parentUid;
    public String description; // OC_LABELS.OC_LABEL_ID
    public String serialnumber;
    public double quantity;
    public String assetType;
    public String supplierUid;
    public java.util.Date purchaseDate;
    public double purchasePrice;
    public String receiptBy;
    public String purchaseDocuments;
    public String writeOffMethod;
    public String annuity;
    public String characteristics;
    public String accountingCode;
    public String gains; // xml : date, value
    public String losses; // xml : date, value
    public String residualValueHistory; // calculated, not in DB
    
    //*** loan ***
    public java.util.Date loanDate;
    public double loanAmount;
    public String loanInterestRate;
    public String loanReimbursementPlan; // date,capital,interest,totalAmount
    public double loanReimbursementAmount; // calculated, not in DB
    public String loanComment;
    public String loanDocuments;
    
    public java.util.Date saleDate;
    public double saleValue;
    public String saleClient;
    
    // search-criteria
    public java.util.Date purchasePeriodBegin, purchasePeriodEnd;
    
    
    //--- CONSTRUCTOR ---
    public Asset(){
        serverId = -1;
        objectId = -1;

        code = "";
        parentUid = "";
        description = "";
        serialnumber = "";
        quantity = 1; // default
        assetType = "";
        supplierUid = "";
        purchaseDate = null;
        purchasePrice = -1;
        receiptBy = "";
        purchaseDocuments = "";
        writeOffMethod = "";
        annuity = "";
        characteristics = "";
        accountingCode = "";
        gains = "";
        losses = "";
        residualValueHistory = "";
        
        //*** loan ***
        loanDate = null;
        loanAmount = -1;
        loanInterestRate = ""; // text !
        loanReimbursementPlan = "";
        loanReimbursementAmount = -1;
        loanComment = "";
        loanDocuments = "";
        
        saleDate = null;
        saleValue = -1;
        saleClient = "";       
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
                // insert new asset
                sSql = "INSERT INTO oc_assets(OC_ASSET_SERVERID,OC_ASSET_OBJECTID,OC_ASSET_CODE,"+
                	   " OC_ASSET_PARENTUID,OC_ASSET_DESCRIPTION,OC_ASSET_SERIAL,OC_ASSET_QUANTITY,OC_ASSET_TYPE,"+
                	   " OC_ASSET_SUPPLIERUID,OC_ASSET_PURCHASEDATE,OC_ASSET_PURCHASEPRICE,OC_ASSET_PURCHASERECEIPTBY,"+
                	   " OC_ASSET_PURCHASEDOCS,OC_ASSET_WRITEOFFMETHOD,OC_ASSET_ANNUITY,OC_ASSET_CHARACTERISTICS,"+
                	   " OC_ASSET_ACCOUNTINGCODE,OC_ASSET_GAINS,OC_ASSET_LOSSES,OC_ASSET_LOANDATE,OC_ASSET_LOANAMOUNT,"+
                	   " OC_ASSET_LOANINTERESTRATE,OC_ASSET_LOANREIMBURSEMENTPLAN,OC_ASSET_LOANCOMMENT,OC_ASSET_LOANDOCS,"+
                	   " OC_ASSET_SALEDATE,OC_ASSET_SALEVALUE,OC_ASSET_SALECLIENT,OC_ASSET_UPDATETIME,OC_ASSET_UPDATEID)"+
                       " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)"; // 30
                ps = oc_conn.prepareStatement(sSql);
                
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId"),
                    objectId = MedwanQuery.getInstance().getOpenclinicCounter("OC_ASSETS");
                this.setUid(serverId+"."+objectId);
                                
                int psIdx = 1;
                ps.setInt(psIdx++,serverId);
                ps.setInt(psIdx++,objectId);
                ps.setString(psIdx++,code);
                ps.setString(psIdx++,parentUid);
                ps.setString(psIdx++,description);
                ps.setString(psIdx++,serialnumber);
                ps.setDouble(psIdx++,quantity);
                ps.setString(psIdx++,assetType);
                ps.setString(psIdx++,supplierUid);

                // purchaseDate date might be unspecified
                if(purchaseDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(purchaseDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setDouble(psIdx++,purchasePrice);
                ps.setString(psIdx++,receiptBy);
                ps.setString(psIdx++,purchaseDocuments);
                ps.setString(psIdx++,writeOffMethod);
                ps.setString(psIdx++,annuity);
                ps.setString(psIdx++,characteristics);
                ps.setString(psIdx++,accountingCode);
                ps.setString(psIdx++,gains);
                ps.setString(psIdx++,losses);
                
                //*** loan ***
                // loanDate date might be unspecified
                if(loanDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(loanDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setDouble(psIdx++,loanAmount);
                ps.setString(psIdx++,loanInterestRate);
                ps.setString(psIdx++,loanReimbursementPlan);
                //ps.setDouble(psIdx++,loanReimbursementAmount); // calculated
                ps.setString(psIdx++,loanComment);
                ps.setString(psIdx++,loanDocuments);
                                
                // saleDate date might be unspecified
                if(saleDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(saleDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setDouble(psIdx++,saleValue);
                ps.setString(psIdx++,saleClient);
                     
                // update-info
                ps.setTimestamp(psIdx++,new Timestamp(new java.util.Date().getTime())); // now
                ps.setString(psIdx,userUid);
                
                ps.executeUpdate();
            } 
            else{
                // update existing record
                sSql = "UPDATE oc_assets SET"+
                       "  OC_ASSET_CODE = ?, OC_ASSET_PARENTUID = ?, OC_ASSET_DESCRIPTION = ?, OC_ASSET_SERIAL = ?,"+
                	   "  OC_ASSET_QUANTITY = ?, OC_ASSET_TYPE = ?, OC_ASSET_SUPPLIERUID = ?, OC_ASSET_PURCHASEDATE = ?,"+
                       "  OC_ASSET_PURCHASEPRICE = ?, OC_ASSET_PURCHASERECEIPTBY = ?, OC_ASSET_PURCHASEDOCS = ?,"+
                	   "  OC_ASSET_WRITEOFFMETHOD = ?, OC_ASSET_ANNUITY = ?, OC_ASSET_CHARACTERISTICS = ?,"+
                       "  OC_ASSET_ACCOUNTINGCODE = ?, OC_ASSET_GAINS = ?, OC_ASSET_LOSSES = ?, OC_ASSET_LOANDATE = ?,"+
                       "  OC_ASSET_LOANAMOUNT = ?, OC_ASSET_LOANINTERESTRATE = ?, OC_ASSET_LOANREIMBURSEMENTPLAN = ?,"+
                	   "  OC_ASSET_LOANCOMMENT = ?, OC_ASSET_LOANDOCS = ?, OC_ASSET_SALEDATE = ?, OC_ASSET_SALEVALUE = ?,"+
                       "  OC_ASSET_SALECLIENT = ?, OC_ASSET_UPDATETIME = ?, OC_ASSET_UPDATEID = ?"+ // update-info
                       " WHERE (OC_ASSET_SERVERID = ? AND OC_ASSET_OBJECTID = ?)"; // identification
                ps = oc_conn.prepareStatement(sSql);

                int psIdx = 1;
                ps.setString(psIdx++,code);
                ps.setString(psIdx++,parentUid);
                ps.setString(psIdx++,description);
                ps.setString(psIdx++,serialnumber);
                ps.setDouble(psIdx++,quantity);
                ps.setString(psIdx++,assetType);
                ps.setString(psIdx++,supplierUid);

                // purchaseDate date might be unspecified
                if(purchaseDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(purchaseDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setDouble(psIdx++,purchasePrice);
                ps.setString(psIdx++,receiptBy);
                ps.setString(psIdx++,purchaseDocuments);
                ps.setString(psIdx++,writeOffMethod);
                ps.setString(psIdx++,annuity);
                ps.setString(psIdx++,characteristics);
                ps.setString(psIdx++,accountingCode);
                ps.setString(psIdx++,gains);
                ps.setString(psIdx++,losses);

                //*** loan ***
                // loanDate date might be unspecified
                if(loanDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(loanDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }
                
                ps.setDouble(psIdx++,loanAmount);
                ps.setString(psIdx++,loanInterestRate);
                ps.setString(psIdx++,loanReimbursementPlan);
                //ps.setDouble(psIdx++,loanReimbursementAmount); // calculated
                ps.setString(psIdx++,loanComment);
                ps.setString(psIdx++,loanDocuments);

                // saleDate date might be unspecified
                if(saleDate!=null){
                    ps.setDate(psIdx++,new java.sql.Date(saleDate.getTime()));
                }
                else{
                    ps.setDate(psIdx++,null);
                }

                ps.setDouble(psIdx++,saleValue);
                ps.setString(psIdx++,saleClient);

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
    public static boolean delete(String sAssetUid){
    	boolean errorOccurred = false;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "DELETE FROM oc_assets"+
                          " WHERE (OC_ASSET_SERVERID = ? AND OC_ASSET_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sAssetUid.substring(0,sAssetUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sAssetUid.substring(sAssetUid.indexOf(".")+1)));
            
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
    public static Asset get(Asset asset){
    	return get(asset.getUid());
    }
       
    public static Asset get(String sAssetUid){
    	Asset asset = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT * FROM oc_assets"+
                          " WHERE (OC_ASSET_SERVERID = ? AND OC_ASSET_OBJECTID = ?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sAssetUid.substring(0,sAssetUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sAssetUid.substring(sAssetUid.indexOf(".")+1)));

            // execute
            rs = ps.executeQuery();
            if(rs.next()){
                asset = new Asset();
                asset.setUid(rs.getString("OC_ASSET_SERVERID")+"."+rs.getString("OC_ASSET_OBJECTID"));
                asset.serverId = Integer.parseInt(rs.getString("OC_ASSET_SERVERID"));
                asset.objectId = Integer.parseInt(rs.getString("OC_ASSET_OBJECTID"));

                asset.code              = ScreenHelper.checkString(rs.getString("OC_ASSET_CODE"));
                asset.parentUid         = ScreenHelper.checkString(rs.getString("OC_ASSET_PARENTUID"));
                asset.description       = ScreenHelper.checkString(rs.getString("OC_ASSET_DESCRIPTION"));
                asset.serialnumber      = ScreenHelper.checkString(rs.getString("OC_ASSET_SERIAL"));
                asset.quantity          = rs.getDouble("OC_ASSET_QUANTITY");
                asset.assetType         = ScreenHelper.checkString(rs.getString("OC_ASSET_TYPE"));
                asset.supplierUid       = ScreenHelper.checkString(rs.getString("OC_ASSET_SUPPLIERUID"));
                asset.purchaseDate      = rs.getDate("OC_ASSET_PURCHASEDATE");
                asset.purchasePrice     = rs.getDouble("OC_ASSET_PURCHASEPRICE");                
                asset.receiptBy         = ScreenHelper.checkString(rs.getString("OC_ASSET_PURCHASERECEIPTBY"));
                asset.purchaseDocuments = ScreenHelper.checkString(rs.getString("OC_ASSET_PURCHASEDOCS"));
                asset.writeOffMethod    = ScreenHelper.checkString(rs.getString("OC_ASSET_WRITEOFFMETHOD"));
                asset.annuity           = ScreenHelper.checkString(rs.getString("OC_ASSET_ANNUITY"));
                asset.characteristics   = ScreenHelper.checkString(rs.getString("OC_ASSET_CHARACTERISTICS"));
                asset.accountingCode    = ScreenHelper.checkString(rs.getString("OC_ASSET_ACCOUNTINGCODE"));
                asset.gains             = ScreenHelper.checkString(rs.getString("OC_ASSET_GAINS"));
                asset.losses            = ScreenHelper.checkString(rs.getString("OC_ASSET_LOSSES"));
                //asset.residualValueHistory = calculateResidualValueHistory();
                
                //*** loan ***
                asset.loanDate              = rs.getDate("OC_ASSET_LOANDATE");
                asset.loanAmount            = rs.getDouble("OC_ASSET_LOANAMOUNT");
                asset.loanInterestRate      = rs.getString("OC_ASSET_LOANINTERESTRATE");
                asset.loanReimbursementPlan = ScreenHelper.checkString(rs.getString("OC_ASSET_LOANREIMBURSEMENTPLAN"));
                //asset.loanReimbursementAmount = calculateReimbursementAmount();
                asset.loanComment           = ScreenHelper.checkString(rs.getString("OC_ASSET_LOANCOMMENT"));
                asset.loanDocuments         = ScreenHelper.checkString(rs.getString("OC_ASSET_LOANDOCS"));
                
                asset.saleDate   = rs.getDate("OC_ASSET_SALEDATE");
                asset.saleValue  = rs.getDouble("OC_ASSET_SALEVALUE");
                asset.saleClient = ScreenHelper.checkString(rs.getString("OC_ASSET_SALECLIENT")); 
                
                // update-info
                asset.setUpdateDateTime(rs.getTimestamp("OC_ASSET_UPDATETIME"));
                asset.setUpdateUser(rs.getString("OC_ASSET_UPDATEID"));
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
        
        return asset;
    }
        
    //--- GET LIST --------------------------------------------------------------------------------
    public static List<Asset> getList(){
    	return getList(new Asset());     	
    }
    
    public static List<Asset> getList(Asset findItem){
        List<Asset> foundObjects = new LinkedList();
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        SimpleDateFormat sqlDateFormat = new SimpleDateFormat("yyyyMMdd");
        
        try{
        	//*** compose query ***************************
            String sSql = "SELECT * FROM oc_assets WHERE 1=1"; // 'where' facilitates further composition of query

            // search-criteria 
            if(findItem.code.length() > 0){
                sSql+= " AND OC_ASSET_CODE LIKE '%"+findItem.code+"%'";
            }
            if(ScreenHelper.checkString(findItem.description).length() > 0){
                sSql+= " AND OC_ASSET_DESCRIPTION LIKE '%"+findItem.description+"%'";
            }
            if(ScreenHelper.checkString(findItem.serialnumber).length() > 0){
                sSql+= " AND OC_ASSET_SERIAL LIKE '%"+findItem.serialnumber+"%'";
            }
            if(ScreenHelper.checkString(findItem.assetType).length() > 0){
                sSql+= " AND OC_ASSET_TYPE = '"+findItem.assetType+"'";
            }
            if(ScreenHelper.checkString(findItem.supplierUid).length() > 0){
                sSql+= " AND OC_ASSET_SUPPLIERUID = '"+findItem.supplierUid+"'";
            }

            // purchase date
            if(findItem.purchasePeriodBegin!=null && findItem.purchasePeriodEnd!=null){
                sSql+= " AND ("+
                       "  OC_ASSET_PURCHASEDATE BETWEEN '"+sqlDateFormat.format(findItem.purchasePeriodBegin)+"' AND"+
                       "                                '"+sqlDateFormat.format(findItem.purchasePeriodEnd)+"'"+
                       " )";
            }
            else if(findItem.purchasePeriodBegin!=null){
                sSql+= " AND (OC_ASSET_PURCHASEDATE >= '"+sqlDateFormat.format(findItem.purchasePeriodBegin)+"')";
            }
            else if(findItem.purchasePeriodEnd!=null){
                sSql+= " AND (OC_ASSET_PURCHASEDATE < '"+sqlDateFormat.format(findItem.purchasePeriodEnd)+"')";
            }
            
            Debug.println("\n"+sSql+"\n");
            sSql+= " ORDER BY OC_ASSET_CODE ASC";
            
            ps = oc_conn.prepareStatement(sSql);
            
                        
            //*** execute query ***************************
            rs = ps.executeQuery();
            Asset asset;
            
            while(rs.next()){
            	asset = new Asset();
                asset.setUid(rs.getString("OC_ASSET_SERVERID")+"."+rs.getString("OC_ASSET_OBJECTID"));
                asset.serverId = Integer.parseInt(rs.getString("OC_ASSET_SERVERID"));
                asset.objectId = Integer.parseInt(rs.getString("OC_ASSET_OBJECTID"));

                asset.code              = ScreenHelper.checkString(rs.getString("OC_ASSET_CODE"));
                asset.parentUid         = ScreenHelper.checkString(rs.getString("OC_ASSET_PARENTUID"));
                asset.description       = ScreenHelper.checkString(rs.getString("OC_ASSET_DESCRIPTION"));
                asset.serialnumber      = ScreenHelper.checkString(rs.getString("OC_ASSET_SERIAL"));
                asset.quantity          = rs.getDouble("OC_ASSET_QUANTITY");
                asset.assetType         = ScreenHelper.checkString(rs.getString("OC_ASSET_TYPE"));
                asset.supplierUid       = ScreenHelper.checkString(rs.getString("OC_ASSET_SUPPLIERUID"));
                asset.purchaseDate      = rs.getDate("OC_ASSET_PURCHASEDATE");
                asset.purchasePrice     = rs.getDouble("OC_ASSET_PURCHASEPRICE");                
                asset.receiptBy         = ScreenHelper.checkString(rs.getString("OC_ASSET_PURCHASERECEIPTBY"));
                asset.purchaseDocuments = ScreenHelper.checkString(rs.getString("OC_ASSET_PURCHASEDOCS"));
                asset.writeOffMethod    = ScreenHelper.checkString(rs.getString("OC_ASSET_WRITEOFFMETHOD"));
                asset.annuity           = ScreenHelper.checkString(rs.getString("OC_ASSET_ANNUITY"));
                asset.characteristics   = ScreenHelper.checkString(rs.getString("OC_ASSET_CHARACTERISTICS"));
                asset.accountingCode    = ScreenHelper.checkString(rs.getString("OC_ASSET_ACCOUNTINGCODE"));
                asset.gains             = ScreenHelper.checkString(rs.getString("OC_ASSET_GAINS"));
                asset.losses            = ScreenHelper.checkString(rs.getString("OC_ASSET_LOSSES"));
                //asset.residualValueHistory = calculateResidualValueHistory();
                
                //*** loan ***
                asset.loanDate              = rs.getDate("OC_ASSET_LOANDATE");
                asset.loanAmount            = rs.getDouble("OC_ASSET_LOANAMOUNT");
                asset.loanInterestRate      = rs.getString("OC_ASSET_LOANINTERESTRATE");
                asset.loanReimbursementPlan = ScreenHelper.checkString(rs.getString("OC_ASSET_LOANREIMBURSEMENTPLAN"));
                //asset.loanReimbursementAmount = calculateReimbursementAmount();
                asset.loanComment           = ScreenHelper.checkString(rs.getString("OC_ASSET_LOANCOMMENT"));
                asset.loanDocuments         = ScreenHelper.checkString(rs.getString("OC_ASSET_LOANDOCS"));
                
                asset.saleDate   = rs.getDate("OC_ASSET_SALEDATE");
                asset.saleValue  = rs.getDouble("OC_ASSET_SALEVALUE");
                asset.saleClient = ScreenHelper.checkString(rs.getString("OC_ASSET_SALECLIENT")); 
                
                // update-info
                asset.setUpdateDateTime(rs.getTimestamp("OC_ASSET_UPDATETIME"));
                asset.setUpdateUser(rs.getString("OC_ASSET_UPDATEID"));
                
                foundObjects.add(asset);
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
    
    //--- CALCULATE RESIDUAL VALUE HISTORY --------------------------------------------------------
    // todo : OPTIMIZE ALGORITHM !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    public String calculateResidualValueHistory(){
    	String sHistory = "";
    	
    	if(this.purchaseDate!=null && this.purchasePrice > 0 && this.loanAmount > 0){
    		sHistory = "<table cellpadding='1' cellspacing='0' border='0'>";
    				    
	    	// 1st day of every fiscal year until value=0
	    	double value = this.purchasePrice;
	    	int startYear = Integer.parseInt(new SimpleDateFormat("yyyy").format(this.purchaseDate));
	    	DecimalFormat deci = new DecimalFormat("0.00");
	    	
	    	while(value >= this.loanAmount){
	            value-= this.loanAmount;
	            startYear++;

	    		sHistory+= "<tr>"+
	    		            "<td>"+startYear+" : </td>"+
	    		            "<td style='text-align:right;'>"+ScreenHelper.padLeft(deci.format(value)," ",8)+"</td>"+
	    		           "</tr>";
	    	}
	    	
    		sHistory+= "</table>";
    	}
    	
    	return sHistory;
    }
    
    //--- CALCULATE REIMBURSEMENT AMOUNT ----------------------------------------------------------
    // todo : OPTIMIZE ALGORITHM !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    public double calculateReimbursementAmount(){
        double amount = -1;
        
        if(this.loanReimbursementPlan.length() > 0){
        	amount = 0;
        	
	        // sum the total amount of each part of the reimbursement plan
	        Vector plans = parseLoanReimbursementPlans(this.loanReimbursementPlan);
 
	        String sCapital, sInterest;
	        Element planElem;
	        double planTotal;
	        
	        for(int i=0; i<plans.size(); i++){
	        	planElem = (Element)plans.get(i);
	
	        	sCapital  = ScreenHelper.checkString(planElem.elementText("Capital"));
	        	sInterest = ScreenHelper.checkString(planElem.elementText("Interest"));
	        	
	        	planTotal = (Double.parseDouble(sCapital) * Double.parseDouble(sInterest)) / 100;
	        	
	        	amount+= planTotal;
	        }
        }
        
        return amount;
    }
    
    //--- PARSE LOAN REIMBURSEMENT PLANS ----------------------------------------------------------
    /*
        <ReimbursementPlans>
            <Plan>
                <Date>01/05/2013</Date>
                <Capital>20000</Capital>
                <Interest>3.25</Interest>
            </Plan>
        </ReimbursementPlans>
    */    
    private Vector parseLoanReimbursementPlans(String sLoanReimbursementPlans){
    	Vector plans = new Vector();

        if(sLoanReimbursementPlans.length() > 0){
            try{
                // parse plans from xml           
                SAXReader reader = new SAXReader(false);
                Document document = reader.read(new StringReader(sLoanReimbursementPlans));
                Element plansElem = document.getRootElement();
         
                if(plansElem!=null){  
                    Iterator plansIter = plansElem.elementIterator("Plan");
        
                    String sTmpDate, sTmpCapital, sTmpInterest;
                    Element planElem;
                    String[] plan;
                    
                    while(plansIter.hasNext()){
                    	planElem = (Element)plansIter.next();
                                                
                    	//sTmpDate     = ScreenHelper.checkString(planElem.elementText("Date"));
                    	//sTmpCapital  = ScreenHelper.checkString(planElem.elementText("Capital"));
                    	//sTmpInterest = ScreenHelper.checkString(planElem.elementText("Interest"));
                        
                    	//plan = new String[]{sTmpDate,sTmpCapital,sTmpInterest};
                        //plans.add(plan);
                    	
                    	plans.add(planElem);
                    }
                }
            }
            catch(Exception e){
                if(Debug.enabled) e.printStackTrace();
                Debug.printProjectErr(e,Thread.currentThread().getStackTrace());
            }
        }
                
        return plans;
    }

    //--- GET SUPPLIER NAME -----------------------------------------------------------------------
    public String getSupplierName(String sSupplierUid){
	    String sSupplierName = ""; 
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT OC_SUPPLIER_NAME"+
                          " FROM oc_suppliers"+
        	              "  WHERE (OC_SUPPLIER_SERVERID = ? AND OC_SUPPLIER_OBJECTID = ?)";            
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sSupplierUid.substring(0,sSupplierUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sSupplierUid.substring(sSupplierUid.indexOf(".")+1)));
            
            rs = ps.executeQuery();            
            if(rs.next()){
            	sSupplierName = ScreenHelper.checkString(rs.getString("OC_SUPPLIER_NAME"));
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
	    
	    return sSupplierName;
    }
    
    //--- GET PARENT CODE -------------------------------------------------------------------------
    public String getParentCode(String sAssetUid){
    	String sParentCode = ""; 
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        
        try{
            String sSql = "SELECT OC_ASSET_CODE"+
                          " FROM oc_assets"+
        	              "  WHERE (OC_ASSET_SERVERID = ? AND OC_ASSET_OBJECTID = ?)";            
            ps = oc_conn.prepareStatement(sSql);
            ps.setInt(1,Integer.parseInt(sAssetUid.substring(0,sAssetUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(sAssetUid.substring(sAssetUid.indexOf(".")+1)));
            
            rs = ps.executeQuery();            
            if(rs.next()){
            	sParentCode = ScreenHelper.checkString(rs.getString("OC_ASSET_CODE"));
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
	    
    	return sParentCode;
    }
    
}
