package be.openclinic.pharmacy;

import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;
import be.openclinic.medical.Prescription;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.common.util.system.Debug;

import java.util.Date;
import java.util.Vector;
import java.sql.*;
import java.text.SimpleDateFormat;

/**
 * User: Frank Verbeke, Stijn Smets
 * Date: 10-sep-2006
 */
public class ProductStockOperation extends OC_Object{
    private String description;
    private ObjectReference sourceDestination; // (patient|medic|service)
    private Date date;
    private ProductStock productStock;
    private int unitsChanged;
    private String prescriptionUid;
    private String batchUid;
    private String batchNumber;
    private Date batchEnd;
    private String batchComment;
    private String receiveComment;
    private int unitsReceived;
    private String operationUID;

    public String getReceiveComment() {
		return receiveComment;
	}

	public void setReceiveComment(String receiveComment) {
		this.receiveComment = receiveComment;
	}

	public int getUnitsReceived() {
		return unitsReceived;
	}

	public void setUnitsReceived(int unitsReceived) {
		this.unitsReceived = unitsReceived;
	}

	public String getOperationUID() {
		return operationUID;
	}

	public void setOperationUID(String uID) {
		operationUID = uID;
	}

	public String getBatchNumber() {
		return batchNumber;
	}

	public void setBatchNumber(String batchNumber) {
		this.batchNumber = batchNumber;
	}

	public Date getBatchEnd() {
		return batchEnd;
	}

	public void setBatchEnd(Date batchEnd) {
		this.batchEnd = batchEnd;
	}

	public String getBatchComment() {
		return batchComment;
	}

	public void setBatchComment(String batchComment) {
		this.batchComment = batchComment;
	}

	// non-db data
    private String productStockUid;


    public String getBatchUid() {
		return batchUid;
	}

	public void setBatchUid(String batchUid) {
		this.batchUid = batchUid;
	}

	public String getPrescriptionUid() {
        return prescriptionUid;
    }

    public void setPrescriptionUid(String prescriptionUid) {
        this.prescriptionUid = prescriptionUid;
    }

    public Prescription getPrescription(){
        Prescription prescription = null;
        if(getPrescriptionUid()!=null && getPrescriptionUid().length()>0){
            prescription=Prescription.get(getPrescriptionUid());
        }
        return prescription;
    }

    //--- DESCRIPTION -----------------------------------------------------------------------------
    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    //--- SOURCE DESTINATION ----------------------------------------------------------------------
    public ObjectReference getSourceDestination() {
        return sourceDestination;
    }

    public void setSourceDestination(ObjectReference sourceDestination) {
        this.sourceDestination = sourceDestination;
    }

    //--- DATE ------------------------------------------------------------------------------------
    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    //--- PRODUCT STOCK ---------------------------------------------------------------------------
    public ProductStock getProductStock() {
        if(productStockUid!=null && productStockUid.length() > 0){
            if(productStock==null){
                this.setProductStock(ProductStock.get(productStockUid));
            }
        }

        return productStock;
    }

    public void setProductStock(ProductStock productStock) {
        this.productStock = productStock;
    }

    //--- UNITS CHANGED ---------------------------------------------------------------------------
    public int getUnitsChanged() {
        return unitsChanged;
    }

    public void setUnitsChanged(int unitsChanged) {
        this.unitsChanged = unitsChanged;
    }

    //--- NON-DB DATA : PRODUCT STOCK UID ---------------------------------------------------------
    public void setProductStockUid(String uid){
        this.productStockUid = uid;
    }

    public String getProductStockUid(){
        return this.productStockUid;
    }

    //--- GET -------------------------------------------------------------------------------------
    public static ProductStockOperation get(String operationUid){
        ProductStockOperation operation = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT * FROM OC_PRODUCTSTOCKOPERATIONS"+
                             " WHERE OC_OPERATION_SERVERID = ? AND OC_OPERATION_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(operationUid.substring(0,operationUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(operationUid.substring(operationUid.indexOf(".")+1)));
            rs = ps.executeQuery();

            // get data from DB
            if(rs.next()){
                operation = new ProductStockOperation();
                operation.setUid(operationUid);

                operation.setDescription(rs.getString("OC_OPERATION_DESCRIPTION"));
                operation.setDate(rs.getDate("OC_OPERATION_DATE"));
                operation.setUnitsChanged(rs.getInt("OC_OPERATION_UNITSCHANGED"));
                operation.setProductStockUid(rs.getString("OC_OPERATION_PRODUCTSTOCKUID"));
                operation.setPrescriptionUid(rs.getString("OC_OPERATION_PRESCRIPTIONUID"));

                // sourceDestination (Patient|Med|Service)
                ObjectReference sourceDestination = new ObjectReference();
                sourceDestination.setObjectType(rs.getString("OC_OPERATION_SRCDESTTYPE"));
                sourceDestination.setObjectUid(rs.getString("OC_OPERATION_SRCDESTUID"));
                operation.setSourceDestination(sourceDestination);

                // OBJECT variables
                operation.setCreateDateTime(rs.getTimestamp("OC_OPERATION_CREATETIME"));
                operation.setUpdateDateTime(rs.getTimestamp("OC_OPERATION_UPDATETIME"));
                operation.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_OPERATION_UPDATEUID")));
                operation.setVersion(rs.getInt("OC_OPERATION_VERSION"));
                operation.setBatchUid(rs.getString("OC_OPERATION_BATCHUID"));
                operation.setOperationUID(rs.getString("OC_OPERATION_UID"));
                operation.setReceiveComment(rs.getString("OC_OPERATION_RECEIVECOMMENT"));
                operation.setUnitsReceived(rs.getInt("OC_OPERATION_UNITSRECEIVED"));
            }
            else{
                throw new Exception("ERROR : PRODUCTSTOCKOPERATION "+operationUid+" NOT FOUND");
            }
        }
        catch(Exception e){
            if(e.getMessage().endsWith("NOT FOUND")){
                Debug.println(e.getMessage());
            }
            else{
                e.printStackTrace();
            }
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return operation;
    }
    
    public static Vector getWaitingDeliveries(String serviceStockUid,String productUid){
    	Vector result = new Vector();
    	return result;
    }

    //--- STORE -----------------------------------------------------------------------------------
    public String store(){
        //First we will check if this operation is acceptable
        ProductStock productStock = this.getProductStock();
        if(productStock==null){
            return "productstockoperation.undefined.productstock";
        }
        else if(this.getDescription().indexOf("delivery") > -1){
            if(productStock.getLevel()<this.getUnitsChanged()){
                return "productstockoperation.insufficient.stock";
            }
        }
        else if(this.getDescription().indexOf("receipt") > -1){
            if(this.getSourceDestination().getObjectType().equalsIgnoreCase("servicestock")){
                if(this.getSourceDestination().getObjectUid()!=null && this.getSourceDestination().getObjectUid().length()>0){
                    ServiceStock serviceStock = ServiceStock.get(this.getSourceDestination().getObjectUid());
                    if(serviceStock == null){
                        return "productstockoperation.undefined.sourceservicestock";
                    }
                    ProductStock productStockNew=serviceStock.getProductStock(this.getProductStock().getProductUid());
                    if(productStockNew == null){
                        return "productstockoperation.undefined.sourceproductstock";
                    }
                    else if(productStockNew.getLevel()<this.getUnitsChanged()){
                        return "productstockoperation.insufficient.sourceproductstock";
                    }
                }
            }
        }
        else if(this.getDescription().indexOf("correction")==-1){
            return "productstockoperation.undefined.operation";
        }
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid().equals("-1")){
                //***** INSERT *****
                if(Debug.enabled) Debug.println("@@@ PRODUCTSTOCK-OPERATION insert @@@");

                sSelect = "INSERT INTO OC_PRODUCTSTOCKOPERATIONS (OC_OPERATION_SERVERID, OC_OPERATION_OBJECTID,"+
                          "  OC_OPERATION_DESCRIPTION, OC_OPERATION_SRCDESTTYPE, OC_OPERATION_SRCDESTUID,"+
                          "  OC_OPERATION_DATE, OC_OPERATION_PRODUCTSTOCKUID, OC_OPERATION_UNITSCHANGED,"+
                          "  OC_OPERATION_CREATETIME, OC_OPERATION_UPDATETIME, OC_OPERATION_UPDATEUID, OC_OPERATION_PRESCRIPTIONUID,OC_OPERATION_VERSION,OC_OPERATION_BATCHUID,OC_OPERATION_UID,OC_OPERATION_RECEIVECOMMENT,OC_OPERATION_UNITSRECEIVED)"+
                          " VALUES(?,?,?,?,?,?,?,?,?,?,?,?,1,?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);

                // set new uid
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId");
                int operationCounter = MedwanQuery.getInstance().getOpenclinicCounter("OC_PRODUCTSTOCKOPERATIONS");
                ps.setInt(1,serverId);
                ps.setInt(2,operationCounter);
                this.setUid(serverId+"."+operationCounter);

                ps.setString(3,this.getDescription());
                ps.setString(4,this.getSourceDestination().getObjectType());
                ps.setString(5,this.getSourceDestination().getObjectUid());

                // date
                if(this.date!=null) ps.setTimestamp(6,new java.sql.Timestamp(this.date.getTime()));
                else                ps.setNull(6,Types.TIMESTAMP);

                ps.setString(7,this.getProductStockUid());
                ps.setInt(8,this.getUnitsChanged());

                // OBJECT variables
                ps.setTimestamp(9,new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setTimestamp(10,new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setString(11,this.getUpdateUser());
                ps.setString(12,this.getPrescriptionUid());
                ps.setString(13,this.getBatchUid());
                //if the UID is not known at creation time, then create a new one based on serverid and objectid
                ps.setString(14, this.getOperationUID()==null || this.getOperationUID().length()==0?serverId+"."+operationCounter:this.getOperationUID());
                ps.setString(15, this.getReceiveComment());
                ps.setInt(16, this.getUnitsReceived());

                ps.executeUpdate();
            }
            else{
                //***** UPDATE *****
            	//Remark: OC_OPERATION_UID is never updated!!
                if(Debug.enabled) Debug.println("@@@ PRODUCTSTOCK-OPERATION update @@@");

                sSelect = "UPDATE OC_PRODUCTSTOCKOPERATIONS SET OC_OPERATION_DESCRIPTION=?, OC_OPERATION_SRCDESTTYPE=?,"+
                          "  OC_OPERATION_SRCDESTUID=?, OC_OPERATION_DATE=?, OC_OPERATION_PRODUCTSTOCKUID=?, OC_OPERATION_UNITSCHANGED=?,"+
                          "  OC_OPERATION_UPDATETIME=?, OC_OPERATION_UPDATEUID=?, OC_OPERATION_PRESCRIPTIONUID=?,OC_OPERATION_VERSION=(OC_OPERATION_VERSION+1),OC_OPERATION_BATCHUID=?," +
                          "  OC_OPERATION_RECEIVECOMMENT=?,OC_OPERATION_UNITSRECEIVED=?"+
                          " WHERE OC_OPERATION_SERVERID=? AND OC_OPERATION_OBJECTID=?";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.getDescription());
                ps.setString(2,this.getSourceDestination().getObjectType());
                ps.setString(3,this.getSourceDestination().getObjectUid());

                // date begin
                if(this.date!=null) ps.setTimestamp(4,new java.sql.Timestamp(this.date.getTime()));
                else                ps.setNull(4,Types.TIMESTAMP);

                ps.setString(5,this.getProductStockUid());
                ps.setInt(6,this.getUnitsChanged());

                // OBJECT variables
                ps.setTimestamp(7,new java.sql.Timestamp(new java.util.Date().getTime())); // now
                ps.setString(8,this.getUpdateUser());
                ps.setString(9,this.getPrescriptionUid());
                ps.setString(10,this.getBatchUid());
                ps.setString(11, this.getReceiveComment());
                ps.setInt(12, this.getUnitsReceived());

                ps.setInt(13,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
                ps.setInt(14,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));

                ps.executeUpdate();
            }

            //*** update this productStock-level ***
            int currentProductStockLevel = productStock.getLevel();
            if(Debug.enabled) Debug.println("@@@ current ProductStockLevel = "+currentProductStockLevel);

            String sourceBatchUid="?";
            String destinationBatchUid="?";
            if(this.getDescription().indexOf("delivery") > -1 || this.getDescription().indexOf("correctionout")>-1){
            	//remove the units from this productstock
                productStock.setLevel(currentProductStockLevel-this.getUnitsChanged()); // minus
                //Remove the batch units from this batch
                if(getBatchUid()!=null && getBatchUid().length()>0){
                	Batch.updateBatchLevel(batchUid, -this.getUnitsChanged());
                	sourceBatchUid=batchUid;
                }
                else if(getBatchNumber()!=null && getBatchNumber().length()>0){
                	//Remark: delivery from a nonexistant batch should never occur!!!!
                	Batch batch = new Batch();
                	batch.setUid("-1");
                	batch.setUpdateUser(getUpdateUser());
                	batch.setBatchNumber(getBatchNumber());
                	batch.setComment(getBatchComment());
                	batch.setEnd(getBatchEnd());
                	batch.setLevel(-this.getUnitsChanged());
                	batch.store();
                	setBatchUid(batch.getUid());
                	setBatchNumber("");
                	setBatchEnd(null);
                	setBatchComment("");
                	sourceBatchUid=batchUid;
                }
            }
            else if(this.getDescription().indexOf("receipt") > -1 || this.getDescription().indexOf("correctionin")>-1){
            	//add the units to this productstock
            	productStock.setLevel(currentProductStockLevel+this.getUnitsChanged()); // plus
                //Add the batch units to this batch if it exists
                if(getBatchUid()!=null && getBatchUid().length()>0){
                	destinationBatchUid=Batch.copyBatch(getBatchUid(), productStock.getUid());
                	Batch.updateBatchLevel(destinationBatchUid,this.getUnitsChanged());
                }
            }

            if(Debug.enabled) Debug.println("@@@ updated ProductStockLevel = "+productStock.getLevel());
            if(productStock.getSupplierUid()==null){
                productStock.setSupplierUid("");
            }
            productStock.store();

            /*
            //*** update the source/destination productStock-level
            
            if(this.getSourceDestination().getObjectType().equalsIgnoreCase("servicestock")){
        		if(this.getDescription().indexOf("delivery") > -1){
                    //find the destination servicestock
        			ServiceStock destinationServiceStock = ServiceStock.get(this.getSourceDestination().getObjectUid());
                    if(destinationServiceStock!=null){
                        //find the destination productstock
                    	ProductStock productStockNew=destinationServiceStock.getProductStock(this.getProductStock().getProductUid());
                        //If the productstock does not yet exist at the destination, create it
                        if(productStockNew==null){
                            productStockNew=new ProductStock();
                            productStockNew.setUid("-1");
                            productStockNew.setUpdateDateTime(new Date());
                            productStockNew.setUpdateUser(productStock.getUpdateUser());
                            productStockNew.setVersion(1);
                            productStockNew.setBegin(new Date());
                            productStockNew.setCreateDateTime(new Date());
                            productStockNew.setDefaultImportance(productStock.getDefaultImportance());
                            productStockNew.setLevel(0);
                            productStockNew.setProductUid(productStock.getProductUid());
                            productStockNew.setServiceStockUid(destinationServiceStock.getUid());
                            productStockNew.setSupplierUid("");
                        }
                        //Add the units to the other productstock
                        productStockNew.setLevel(productStockNew.getLevel()+this.getUnitsChanged()); 
                        productStockNew.store();
                        //Add the batch units to the other product stock if it exists
                        if(getBatchUid()!=null && getBatchUid().length()>0){
                        	destinationBatchUid=Batch.copyBatch(getBatchUid(), productStockNew.getUid());
                        	Batch.updateBatchLevel(destinationBatchUid,this.getUnitsChanged());
                        }
                    }
                }
                else if(this.getDescription().indexOf("receipt") > -1){
                	//find the source servicestock
                	ServiceStock sourceServiceStock = ServiceStock.get(this.getSourceDestination().getObjectUid());
                    if(sourceServiceStock!=null){
                    	//find the source productstock
                    	ProductStock sourceProductStock = sourceServiceStock.getProductStock(getProductStock().getProductUid());
                    	if(sourceProductStock!=null){
                    		//remove the units from the other productstock
                    		sourceProductStock.setLevel(sourceProductStock.getLevel()-this.getUnitsChanged());
                    		if(getBatchUid()!=null && getBatchUid().length()>0){
                    			//Remove the units from the other batch
                    			sourceBatchUid=getBatchUid();
                    			Batch.updateBatchLevel(getBatchUid(),-this.getUnitsChanged());
                    		}
                    	}
                	}
                }
            }
            */
            if(!sourceBatchUid.equalsIgnoreCase("?") || !destinationBatchUid.equalsIgnoreCase("?")){
            	BatchOperation.storeOperation(this.getUid(), sourceBatchUid, destinationBatchUid, this.getUnitsChanged(),new java.util.Date());
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
        return null;
    }

    //--- DELETE ----------------------------------------------------------------------------------
    public static void delete(String operationUid){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "DELETE FROM OC_PRODUCTSTOCKOPERATIONS"+
                             " WHERE OC_OPERATION_SERVERID = ? AND OC_OPERATION_OBJECTID = ?";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setInt(1,Integer.parseInt(operationUid.substring(0,operationUid.indexOf("."))));
            ps.setInt(2,Integer.parseInt(operationUid.substring(operationUid.indexOf(".")+1)));
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }
    }

    //--- GET DELIVERED PACKAGES ------------------------------------------------------------------
    public static int getDeliveredPackages(java.util.Date since, String productStockUid){
        int deliveredPackages = 0;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // compose query
            String sSelect = "SELECT OC_OPERATION_UNITSCHANGED FROM OC_PRODUCTSTOCKOPERATIONS"+
                             " WHERE OC_OPERATION_DESCRIPTION LIKE 'medicationdelivery.%'"+
                             "  AND OC_OPERATION_SRCDESTTYPE = 'type2patient'"+
                             "  AND OC_OPERATION_DATE >= ?"+
                             "  AND OC_OPERATION_PRODUCTSTOCKUID = ?";

            // set questionmark values
            ps = oc_conn.prepareStatement(sSelect);
            ps.setDate(1,new java.sql.Date(since.getTime()));
            ps.setString(2,productStockUid);

            // execute
            rs = ps.executeQuery();
            while(rs.next()){
                deliveredPackages+= rs.getInt("OC_OPERATION_UNITSCHANGED");
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return deliveredPackages;
    }

    //--- GET DELIVERIES --------------------------------------------------------------------------
    public static Vector getDeliveries(String sourceDestionationUid, java.util.Date dateFrom, java.util.Date dateUntil,
                                       String sSortCol, String sSortDir){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector foundRecords = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_OPERATION_SERVERID,OC_OPERATION_OBJECTID"+
                             "  FROM OC_PRODUCTSTOCKOPERATIONS"+
                             " WHERE OC_OPERATION_DESCRIPTION LIKE 'medicationdelivery.%'";

            if(sourceDestionationUid.length() > 0){
                sSelect+= " AND OC_OPERATION_SRCDESTUID = ?";
            }

            // dates
            if(dateFrom!=null)  sSelect+= " AND OC_OPERATION_DATE >= ?";
            if(dateUntil!=null) sSelect+= " AND OC_OPERATION_DATE < ?";

            // order by selected col or default col
            sSelect+= " ORDER BY "+sSortCol+" "+sSortDir;

            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark-values
            int questionMarkIdx = 1;
            if(sourceDestionationUid.length() > 0) ps.setString(questionMarkIdx++,sourceDestionationUid);
            if(dateFrom!=null)                     ps.setDate(questionMarkIdx++,new java.sql.Date(dateFrom.getTime()));
            if(dateUntil!=null)                    ps.setDate(questionMarkIdx++,new java.sql.Date(dateUntil.getTime()));

            // execute
            rs = ps.executeQuery();
            while(rs.next()){
                foundRecords.add(get(rs.getString("OC_OPERATION_SERVERID")+"."+rs.getString("OC_OPERATION_OBJECTID")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return foundRecords;
    }

    public static Vector getDeliveries(String productStockUid, String sourceDestionationUid, java.util.Date dateFrom, java.util.Date dateUntil,
                                       String sSortCol, String sSortDir){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector foundRecords = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_OPERATION_SERVERID,OC_OPERATION_OBJECTID"+
                             "  FROM OC_PRODUCTSTOCKOPERATIONS"+
                             " WHERE OC_OPERATION_DESCRIPTION LIKE 'medicationdelivery.%'" +
                    " and OC_OPERATION_PRODUCTSTOCKUID='"+productStockUid+"'";

            if(sourceDestionationUid.length() > 0){
                sSelect+= " AND OC_OPERATION_SRCDESTUID = ?";
            }

            // dates
            if(dateFrom!=null)  sSelect+= " AND OC_OPERATION_DATE >= ?";
            if(dateUntil!=null) sSelect+= " AND OC_OPERATION_DATE < ?";

            // order by selected col or default col
            sSelect+= " ORDER BY "+sSortCol+" "+sSortDir;

            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark-values
            int questionMarkIdx = 1;
            if(sourceDestionationUid.length() > 0) ps.setString(questionMarkIdx++,sourceDestionationUid);
            if(dateFrom!=null)                     ps.setDate(questionMarkIdx++,new java.sql.Date(dateFrom.getTime()));
            if(dateUntil!=null)                    ps.setDate(questionMarkIdx++,new java.sql.Date(dateUntil.getTime()));

            // execute
            rs = ps.executeQuery();
            while(rs.next()){
                foundRecords.add(get(rs.getString("OC_OPERATION_SERVERID")+"."+rs.getString("OC_OPERATION_OBJECTID")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return foundRecords;
    }

    //--- GET RECEIPTS ----------------------------------------------------------------------------
    public static Vector getReceipts(String sourceDestionationUid, java.util.Date dateFrom, java.util.Date dateUntil,
                                     String sSortCol, String sSortDir){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector foundRecords = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_OPERATION_SERVERID,OC_OPERATION_OBJECTID"+
                             " FROM OC_PRODUCTSTOCKOPERATIONS"+
                             " WHERE OC_OPERATION_DESCRIPTION LIKE 'medicationreceipt.%'";

            if(sourceDestionationUid.length() > 0){
                sSelect+= " AND OC_OPERATION_SRCDESTUID = ?";
            }

            // dates
            if(dateFrom!=null)  sSelect+= " AND OC_OPERATION_DATE >= ?";
            if(dateUntil!=null) sSelect+= " AND OC_OPERATION_DATE < ?";

            // order by selected col or default col
            sSelect+= " ORDER BY "+sSortCol+" "+sSortDir;

            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark-values
            int questionMarkIdx = 1;
            if(sourceDestionationUid.length() > 0) ps.setString(questionMarkIdx++,sourceDestionationUid);
            if(dateFrom!=null)                     ps.setDate(questionMarkIdx++,new java.sql.Date(dateFrom.getTime()));
            if(dateUntil!=null)                    ps.setDate(questionMarkIdx++,new java.sql.Date(dateUntil.getTime()));

            // execute
            rs = ps.executeQuery();
            while(rs.next()){
                foundRecords.add(get(rs.getString("OC_OPERATION_SERVERID")+"."+rs.getString("OC_OPERATION_OBJECTID")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return foundRecords;
    }

    public static Vector getReceipts(String productStockUid,String sourceDestionationUid, java.util.Date dateFrom, java.util.Date dateUntil,
                                     String sSortCol, String sSortDir){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Vector foundRecords = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "SELECT OC_OPERATION_SERVERID,OC_OPERATION_OBJECTID"+
                             " FROM OC_PRODUCTSTOCKOPERATIONS"+
                             " WHERE OC_OPERATION_DESCRIPTION LIKE 'medicationreceipt.%' and" +
                    " OC_OPERATION_PRODUCTSTOCKUID='"+productStockUid+"'";

            if(sourceDestionationUid.length() > 0){
                sSelect+= " AND OC_OPERATION_SRCDESTUID = ?";
            }

            // dates
            if(dateFrom!=null)  sSelect+= " AND OC_OPERATION_DATE >= ?";
            if(dateUntil!=null) sSelect+= " AND OC_OPERATION_DATE < ?";

            // order by selected col or default col
            sSelect+= " ORDER BY "+sSortCol+" "+sSortDir;

            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark-values
            int questionMarkIdx = 1;
            if(sourceDestionationUid.length() > 0) ps.setString(questionMarkIdx++,sourceDestionationUid);
            if(dateFrom!=null)                     ps.setDate(questionMarkIdx++,new java.sql.Date(dateFrom.getTime()));
            if(dateUntil!=null)                    ps.setDate(questionMarkIdx++,new java.sql.Date(dateUntil.getTime()));

            // execute
            rs = ps.executeQuery();
            while(rs.next()){
                foundRecords.add(get(rs.getString("OC_OPERATION_SERVERID")+"."+rs.getString("OC_OPERATION_OBJECTID")));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(rs!=null) rs.close();
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(SQLException se){
                se.printStackTrace();
            }
        }

        return foundRecords;
    }

    public static Vector searchProductStockOperations(String sFindOperationDescr,String sFindSrcDestType,String sFindOperationDate,
                                                      String sFindProductStockUid,String sFindUnitsChanged,String sSortCol){
        PreparedStatement ps = null;
        ResultSet rs = null;

        String sSelect = "SELECT * FROM OC_PRODUCTSTOCKOPERATIONS ";

        if(sFindOperationDescr.length()>0 || sFindSrcDestType.length()>0 || sFindOperationDate.length()>0 ||
           sFindProductStockUid.length()>0 || sFindUnitsChanged.length()>0){
            sSelect+= "WHERE ";

            if(sFindOperationDescr.length() > 0)  sSelect+= "OC_OPERATION_DESCRIPTION LIKE ? AND ";
            if(sFindSrcDestType.length() > 0)     sSelect+= "OC_OPERATION_SRCDESTTYPE = ? AND ";
            if(sFindOperationDate.length() > 0)   sSelect+= "OC_OPERATION_DATE >= ? AND OC_OPERATION_DATE < ? AND ";
            if(sFindProductStockUid.length() > 0) sSelect+= "OC_OPERATION_PRODUCTSTOCKUID = ? AND ";
            if(sFindUnitsChanged.length() > 0)    sSelect+= "OC_OPERATION_UNITSCHANGED = ? AND ";

            // remove last AND if any
            if(sSelect.indexOf("AND ")>0){
                sSelect = sSelect.substring(0,sSelect.lastIndexOf("AND "));
            }
        }

        // order by selected col or default col
        sSelect+= "ORDER BY "+sSortCol+" DESC";

        Vector vProdStockOperations = new Vector();

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            ps = oc_conn.prepareStatement(sSelect);

            // set questionmark values
            int questionMarkIdx = 1;
            if(sFindOperationDescr.length() > 0)  ps.setString(questionMarkIdx++,sFindOperationDescr+"%");
            if(sFindSrcDestType.length() > 0)     ps.setString(questionMarkIdx++,sFindSrcDestType);
            if(sFindOperationDate.length() > 0)  {
                ps.setDate(questionMarkIdx++,ScreenHelper.getSQLDate(sFindOperationDate));
                ps.setDate(questionMarkIdx++,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sFindOperationDate).getTime()+24*60*60000));
            }
            if(sFindProductStockUid.length() > 0) ps.setString(questionMarkIdx++,sFindProductStockUid);
            if(sFindUnitsChanged.length() > 0)    ps.setString(questionMarkIdx++,sFindUnitsChanged);

            rs = ps.executeQuery();

            ProductStockOperation operation;

            while(rs.next()){
                operation = new ProductStockOperation();
                operation.setUid(ScreenHelper.checkString(rs.getString("OC_OPERATION_SERVERID")) + "." + ScreenHelper.checkString(rs.getString("OC_OPERATION_OBJECTID")));

                operation.setDescription(rs.getString("OC_OPERATION_DESCRIPTION"));
                operation.setDate(rs.getDate("OC_OPERATION_DATE"));
                operation.setUnitsChanged(rs.getInt("OC_OPERATION_UNITSCHANGED"));
                operation.setProductStockUid(rs.getString("OC_OPERATION_PRODUCTSTOCKUID"));

                // sourceDestination (Patient|Med|Service)
                ObjectReference sourceDestination = new ObjectReference();
                sourceDestination.setObjectType(rs.getString("OC_OPERATION_SRCDESTTYPE"));
                sourceDestination.setObjectUid(rs.getString("OC_OPERATION_SRCDESTUID"));
                operation.setSourceDestination(sourceDestination);

                // OBJECT variables
                operation.setCreateDateTime(rs.getTimestamp("OC_OPERATION_CREATETIME"));
                operation.setUpdateDateTime(rs.getTimestamp("OC_OPERATION_UPDATETIME"));
                operation.setUpdateUser(ScreenHelper.checkString(rs.getString("OC_OPERATION_UPDATEUID")));
                operation.setVersion(rs.getInt("OC_OPERATION_VERSION"));
                operation.setBatchUid(rs.getString("OC_OPERATION_BATCHUID"));
                
                vProdStockOperations.addElement(operation);
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
        return vProdStockOperations;
    }
}
