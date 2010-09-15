package be.openclinic.pharmacy;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;


import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class BatchOperation {
	
	private String type;
	private String thirdParty;
	private int quantity;
	private java.util.Date date;
	private String stockOperationUid;
	
	
	
	public String getStockOperationUid() {
		return stockOperationUid;
	}



	public void setStockOperationUid(String stockOperationUid) {
		this.stockOperationUid = stockOperationUid;
	}



	public String getType() {
		return type;
	}



	public void setType(String type) {
		this.type = type;
	}



	public String getThirdParty() {
		return thirdParty;
	}



	public void setThirdParty(String thirdParty) {
		this.thirdParty = thirdParty;
	}



	public int getQuantity() {
		return quantity;
	}



	public void setQuantity(int quantity) {
		this.quantity = quantity;
	}



	public java.util.Date getDate() {
		return date;
	}



	public void setDate(java.util.Date date) {
		this.date = date;
	}

	public ProductStockOperation getProductStockOperation(){
		return ProductStockOperation.get(stockOperationUid);
	}


	public BatchOperation(String type, String thirdParty, int quantity, java.util.Date date, String stockOperationUid) {
		super();
		this.type = type;
		this.thirdParty = thirdParty;
		this.quantity = quantity;
		this.date=date;
		this.stockOperationUid=stockOperationUid;
	}



	public static void storeOperation(String productStockOperationUid, String sourceBatchUid, String destinationBatchUid, int quantity, java.util.Date datetime){
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSelect = "insert into OC_BATCHOPERATIONS(OC_BATCHOPERATION_PRODUCTSTOCKOPERATIONUID,OC_BATCHOPERATION_SOURCEUID,OC_BATCHOPERATION_DESTINATIONUID,OC_BATCHOPERATION_QUANTITY,OC_BATCHOPERATION_UPDATETIME) values(?,?,?,?,?)";
            ps = oc_conn.prepareStatement(sSelect);
            ps.setString(1,productStockOperationUid);
            ps.setString(2,sourceBatchUid);
            ps.setString(3,destinationBatchUid);
            ps.setInt(4,quantity);
            ps.setTimestamp(5, new java.sql.Timestamp(datetime.getTime()));
            ps.execute();
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

}
