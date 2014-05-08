package be.openclinic.pharmacy;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.util.Vector;

import net.admin.Service;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;
import be.openclinic.common.ObjectReference;

public class OperationDocument extends OC_Object {
	private String type="";
	private String sourceuid="";
	private String destinationuid="";
	private java.util.Date date;
	private String comment="";
	private String reference="";
	
	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}
	public String getSourceuid() {
		return sourceuid;
	}
	public void setSourceuid(String sourceuid) {
		this.sourceuid = sourceuid;
	}
	public Object getSource(){
    	if(MedwanQuery.getInstance().getConfigString("stockOperationDocumentServiceSources","").indexOf('*'+getType()+'*')>-1){
    		return Service.getService(sourceuid);
    	}
    	else {
    		return ServiceStock.get(sourceuid);
    	}
	}
	public String getSourceName(String language){
    	String s = "";
    	if(sourceuid!=null){
			if(MedwanQuery.getInstance().getConfigString("stockOperationDocumentServiceSources","").indexOf('*'+getType()+'*')>-1){
	    		Service service = Service.getService(sourceuid);
	    		if(service!=null){
	    			s=ScreenHelper.checkString(service.getLabel(language));
	    		}
	    	}
	    	else {
	    		ServiceStock serviceStock= ServiceStock.get(sourceuid);
	    		if(serviceStock!=null){
	    			s= ScreenHelper.checkString(serviceStock.getName());
	    		}
	    	}
    	}
		return s;
	}
	public String getDestinationuid() {
		return destinationuid;
	}
	public void setDestinationuid(String destinationuid) {
		this.destinationuid = destinationuid;
	}
	public ServiceStock getDestination(){
		return ServiceStock.get(destinationuid);
	}
	public java.util.Date getDate() {
		return date;
	}
	public void setDate(java.util.Date date) {
		this.date = date;
	}
	public String getComment() {
		return comment;
	}
	public void setComment(String comment) {
		this.comment = comment;
	}
	public String getReference() {
		return reference;
	}
	public void setReference(String reference) {
		this.reference = reference;
	}
	
    public static OperationDocument get(String documentUid){
    	OperationDocument document = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        if(documentUid!=null && documentUid.split("\\.").length>1){
	        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	        try{
	            String sSelect = "SELECT * FROM OC_PRODUCTSTOCKOPERATIONDOCUMENTS"+
	                             " WHERE OC_DOCUMENT_SERVERID = ? AND OC_DOCUMENT_OBJECTID = ?";
	            ps = oc_conn.prepareStatement(sSelect);
	            ps.setInt(1,Integer.parseInt(documentUid.substring(0,documentUid.indexOf("."))));
	            ps.setInt(2,Integer.parseInt(documentUid.substring(documentUid.indexOf(".")+1)));
	            rs = ps.executeQuery();
	
	            // get data from DB
	            if(rs.next()){
	            	document=new OperationDocument();
	            	document.setUid(documentUid);
	            	document.setType(rs.getString("OC_DOCUMENT_TYPE"));
	            	document.setSourceuid(rs.getString("OC_DOCUMENT_SOURCEUID"));
	            	document.setDestinationuid(rs.getString("OC_DOCUMENT_DESTINATIONUID"));
	            	document.setDate(rs.getTimestamp("OC_DOCUMENT_DATE"));
	            	document.setComment(rs.getString("OC_DOCUMENT_COMMENT"));
	            	document.setReference(rs.getString("OC_DOCUMENT_REFERENCE"));
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
        }
        return document;
    }
    
    public Vector getProductStockOperations(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
    	Vector operations = new Vector();
    	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
    	try {
    		sSelect="select * from OC_PRODUCTSTOCKOPERATIONS where OC_OPERATION_DOCUMENTUID=? order by OC_OPERATION_DATE,OC_OPERATION_OBJECTID";
    		ps = conn.prepareStatement(sSelect);
    		ps.setString(1, this.getUid());
    		rs=ps.executeQuery();
    		ProductStockOperation operation = null;
    		while(rs.next()){
    			operation = new ProductStockOperation();
                operation.setUid(rs.getString("OC_OPERATION_SERVERID")+"."+rs.getString("OC_OPERATION_OBJECTID"));
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
                operation.setReceiveProductStockUid(rs.getString("OC_OPERATION_RECEIVEPRODUCTSTOCKUID"));
                operation.setDocumentUID(rs.getString("OC_OPERATION_DOCUMENTUID"));
                operations.add(operation);
    		}
	    }
	    catch(Exception e){
	        e.printStackTrace();
	    }
	    finally{
	        try{
	            if(rs!=null) rs.close();
	            if(ps!=null) ps.close();
	            conn.close();
	        }
	        catch(SQLException se){
	            se.printStackTrace();
	        }
	    }
    	return operations;
    }
    
    public static Vector find(String type,String source, String destination, String mindate, String maxdate, String reference, String order){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;
    	Vector documents = new Vector();
    	String sWhere="";
    	if(type!=null && type.length()>0){
    		sWhere+=" AND OC_DOCUMENT_TYPE=?";
    	}
    	if(source!=null && source.length()>0){
    		sWhere+=" AND OC_DOCUMENT_SOURCEUID=?";
    	}
    	if(destination!=null && destination.length()>0){
    		sWhere+=" AND OC_DOCUMENT_DESTINATIONUID=?";
    	}
    	if(mindate!=null && mindate.length()>0){
    		sWhere+=" AND OC_DOCUMENT_DATE>=?";
    	}
    	if(maxdate!=null && maxdate.length()>0){
    		sWhere+=" AND OC_DOCUMENT_DATE<=?";
    	}
    	if(reference!=null && reference.length()>0){
    		sWhere+=" AND OC_DOCUMENT_REFERENCE=?";
    	}
    	if(sWhere.length()>0){
    		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
    		try {
    			if(order==null || order.length()==0){
    				order= "OC_DOCUMENT_DATE";
    			}
    			sSelect="SELECT * from OC_PRODUCTSTOCKOPERATIONDOCUMENTS where 1=1"+sWhere+" ORDER by "+order;
    			ps=conn.prepareStatement(sSelect);
    			int i=1;
    	    	if(type!=null && type.length()>0){
    	    		ps.setString(i++, type);
    	    	}
    	    	if(source!=null && source.length()>0){
    	    		ps.setString(i++, source);
    	    	}
    	    	if(destination!=null && destination.length()>0){
    	    		ps.setString(i++, destination);
    	    	}
    	    	if(mindate!=null && mindate.length()>0){
    	    		ps.setDate(i++, new java.sql.Date(ScreenHelper.parseDate(mindate).getTime()));
    	    	}
    	    	if(maxdate!=null && maxdate.length()>0){
    	    		ps.setDate(i++, new java.sql.Date(ScreenHelper.parseDate(maxdate).getTime()));
    	    	}
    	    	if(reference!=null && reference.length()>0){
    	    		ps.setString(i++, reference);
    	    	}
    	    	rs=ps.executeQuery();
    	    	while(rs.next()){
    	    		OperationDocument document = new OperationDocument();
                	document.setUid(rs.getString("OC_DOCUMENT_SERVERID")+"."+rs.getString("OC_DOCUMENT_OBJECTID"));
                	document.setType(rs.getString("OC_DOCUMENT_TYPE"));
                	document.setSourceuid(rs.getString("OC_DOCUMENT_SOURCEUID"));
                	document.setDestinationuid(rs.getString("OC_DOCUMENT_DESTINATIONUID"));
                	document.setDate(rs.getTimestamp("OC_DOCUMENT_DATE"));
                	document.setComment(rs.getString("OC_DOCUMENT_COMMENT"));
                	document.setReference(rs.getString("OC_DOCUMENT_REFERENCE"));
                	documents.add(document);
    	    	}
            }
            catch(Exception e){
                e.printStackTrace();
            }
            finally{
                try{
                    if(rs!=null) rs.close();
                    if(ps!=null) ps.close();
                    conn.close();
                }
                catch(SQLException se){
                    se.printStackTrace();
                }
            }
      	}
    	return documents;
    }
    
    public void store(){
        PreparedStatement ps = null;
        ResultSet rs = null;
        String sSelect;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            if(this.getUid()==null || this.getUid().indexOf(".")<0 || this.getUid().equals("-1")){
                //***** INSERT *****

                sSelect = "INSERT INTO OC_PRODUCTSTOCKOPERATIONDOCUMENTS (OC_DOCUMENT_SERVERID, OC_DOCUMENT_OBJECTID,"+
                          "  OC_DOCUMENT_TYPE, OC_DOCUMENT_SOURCEUID, OC_DOCUMENT_DESTINATIONUID,"+
                          "  OC_DOCUMENT_DATE, OC_DOCUMENT_COMMENT, OC_DOCUMENT_REFERENCE)"+
                          " VALUES(?,?,?,?,?,?,?,?)";

                ps = oc_conn.prepareStatement(sSelect);

                // set new uid
                int serverId = MedwanQuery.getInstance().getConfigInt("serverId");
                int operationCounter = MedwanQuery.getInstance().getOpenclinicCounter("OC_PRODUCTSTOCKOPERATIONDOCUMENTS");
                ps.setInt(1,serverId);
                ps.setInt(2,operationCounter);
                this.setUid(serverId+"."+operationCounter);

                ps.setString(3,this.getType());
                ps.setString(4,this.getSourceuid());
                ps.setString(5,this.getDestinationuid());

                // date
                if(this.date!=null) ps.setTimestamp(6,new java.sql.Timestamp(this.date.getTime()));
                else                ps.setNull(6,Types.TIMESTAMP);

                ps.setString(7,this.getComment());
                ps.setString(8,this.getReference());
                ps.executeUpdate();
            }
            else{
                //***** UPDATE *****
                sSelect = "UPDATE OC_PRODUCTSTOCKOPERATIONDOCUMENTS SET OC_DOCUMENT_TYPE=?, OC_DOCUMENT_SOURCEUID=?,"+
                          "  OC_DOCUMENT_DESTINATIONUID=?, OC_DOCUMENT_DATE=?, OC_DOCUMENT_COMMENT=?, OC_DOCUMENT_REFERENCE=?"+
                          " WHERE OC_DOCUMENT_SERVERID=? AND OC_DOCUMENT_OBJECTID=?";

                ps = oc_conn.prepareStatement(sSelect);
                ps.setString(1,this.getType());
                ps.setString(2,this.getSourceuid());
                ps.setString(3,this.getDestinationuid());

                // date begin
                if(this.date!=null) ps.setTimestamp(4,new java.sql.Timestamp(this.date.getTime()));
                else                ps.setNull(4,Types.TIMESTAMP);

                ps.setString(5,this.getComment());
                ps.setString(6,this.getReference());

                ps.setInt(7,Integer.parseInt(this.getUid().substring(0,this.getUid().indexOf("."))));
                ps.setInt(8,Integer.parseInt(this.getUid().substring(this.getUid().indexOf(".")+1)));

                ps.executeUpdate();
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
    }

}
