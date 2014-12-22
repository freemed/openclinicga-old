package be.openclinic.archiving;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.Iterator;
import java.util.Vector;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.ScreenHelper;
import be.openclinic.common.OC_Object;

public class ArchiveDocument extends OC_Object implements Comparable {

	/*
	// create table arch_documents (
	//  arch_document_objectid int,
    //  arch_document_serverid int,
    //  arch_document_udi varchar(50),
    //  arch_document_title varchar(255),
    //  arch_document_description text,
    //  arch_document_category varchar(50),
    //  arch_document_author varchar(50),
    //  arch_document_date datetime, 
    //  arch_document_destination varchar(255),
    //  arch_document_reference varchar(50),
    //  arch_document_personid int,
    //  arch_document_storagename varchar(255),
    //  arch_document_deletedate datetime,
    //  arch_document_tran_serverid int,
    //  arch_document_tran_transactionid int,
    //  arch_document_updatetime datetime,
    //  arch_document_updateid int
    // )
	*/
	
	public String udi;
	public String title;
	public String description;
	public String category;
	public String author;
	public java.util.Date date;
	public String destination;
	public String reference;
	public int personId;
	public int tranServerId; // link with transaction
	public int tranTranId;   // link with transaction
	public String storageName;
	public java.util.Date deleteDate;
	
	
	//--- CONSTRUCTOR -----------------------------------------------------------------------------
	public ArchiveDocument(){
		// empty
	}
	
	//--- SAVE ------------------------------------------------------------------------------------
	// return UDI (unique document id)
	public static ArchiveDocument save(boolean isNewTran, TransactionVO tran, UserVO activeUser){
		ArchiveDocument archDoc = new ArchiveDocument();
		String sUID = "", sUDI = "";

		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;

		if(isNewTran){
			//*** create record ***			
			String sSql = "INSERT INTO arch_documents (arch_document_serverid, arch_document_objectid, arch_document_udi,"+
			              "  arch_document_title, arch_document_description, arch_document_category, arch_document_author,"+
					      "  arch_document_date, arch_document_destination, arch_document_reference, arch_document_personid,"+
			              "  arch_document_tran_serverid, arch_document_tran_transactionid, arch_document_storagename,"+
					      "  arch_document_updatetime, arch_document_updateid)"+
			              " VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";			
			try{
				ps = conn.prepareStatement(sSql);
				int psIdx = 1;

				// IDs
				int serverId = Integer.parseInt(MedwanQuery.getInstance().getConfigString("serverId")),
				    objectId = MedwanQuery.getInstance().getOpenclinicCounter("ARCH_DOCUMENTS");
				ps.setInt(psIdx++,serverId);
				ps.setInt(psIdx++,objectId);
				sUID = serverId+"."+objectId;

				// get UDI
				sUDI = generateUDI(objectId);
				ps.setString(psIdx++,sUDI);
				
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_TITLE"));
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_DESCRIPTION"));
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_CATEGORY"));
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_AUTHOR"));
				
				// date
				String sDate = ScreenHelper.stdDateFormat.format(tran.getUpdateTime());
				if(sDate.length() > 0){
					sDate = ScreenHelper.convertToEUDate(sDate);
				    ps.setDate(psIdx++,new java.sql.Date(ScreenHelper.parseDate(sDate).getTime()));
				}
				else{
					ps.setNull(psIdx++,Types.NULL);
				}
				
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_DESTINATION"));
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_REFERENCE"));
				
				// personId
				String sPersonId = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_PERSONID");
				if(sPersonId.length() > 0){
				    ps.setInt(psIdx++,Integer.parseInt(sPersonId));
				}
				else{
					ps.setNull(psIdx++,Types.NULL);
				}

				// transactions' serverId and transactionId
				ps.setInt(psIdx++,tran.getServerId());
				ps.setInt(psIdx++,tran.getTransactionId().intValue());
				
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_STORAGENAME"));
				
				ps.setTimestamp(psIdx++,new java.sql.Timestamp(new java.util.Date().getTime())); // now
				ps.setInt(psIdx++,activeUser.userId.intValue());
				
				ps.executeUpdate();
			}
			catch(Exception e){
				e.printStackTrace();
			}
			finally{
				try{
					if(ps!=null) ps.close();
					if(conn!=null) conn.close();
				}
				catch(Exception e){
					e.printStackTrace();
				}
			}
		}
		else{
			//*** update record ***	
			sUID = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_UID");
			sUDI = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_UDI");
			
			// do not update UDI and link to transaction
			String sSql = "UPDATE arch_documents SET arch_document_title = ?, arch_document_description = ?, arch_document_category = ?,"+
			              "  arch_document_author = ?, arch_document_date = ?, arch_document_destination = ?, arch_document_reference = ?,"+
			              "  arch_document_personid = ?, arch_document_storagename = ?,"+
			              "  arch_document_updatetime = ?, arch_document_updateid = ?"+
			              " WHERE arch_document_serverid = ? AND arch_document_objectid = ?";			
			try{
				ps = conn.prepareStatement(sSql);
				int psIdx = 1;

				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_TITLE"));
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_DESCRIPTION"));
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_CATEGORY"));
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_AUTHOR"));
				
				// date
				String sDate = ScreenHelper.stdDateFormat.format(tran.getUpdateTime());
				if(sDate.length() > 0){
					sDate = ScreenHelper.convertToEUDate(sDate);
				    ps.setDate(psIdx++,new java.sql.Date(ScreenHelper.parseDate(sDate).getTime()));
				}
				else{
					ps.setNull(psIdx++,Types.NULL);
				}
				
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_DESTINATION"));
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_REFERENCE"));
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_PERSONID"));
				ps.setString(psIdx++,tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_STORAGENAME"));
				
				ps.setTimestamp(psIdx++,new java.sql.Timestamp(new java.util.Date().getTime())); // now
				ps.setInt(psIdx++,activeUser.userId.intValue());
				ps.setString(psIdx++,sUID.split("\\.")[0]);
				ps.setString(psIdx++,sUID.split("\\.")[1]);
				
				ps.executeUpdate();
			}
			catch(Exception e){
				e.printStackTrace();
			}
			finally{
				try{
					if(ps!=null) ps.close();
					if(conn!=null) conn.close();
				}
				catch(Exception e){
					e.printStackTrace();
				}
			}
		}

		//archDoc = get(sUDI); // to much load for the purpose..
		archDoc.udi = sUDI;
		archDoc.setUid(sUID);
		
		return archDoc;
	}
	
	//--- GET, TRHOUGH TRANSACTIONS ----------------------------------------------------------------
	public static ArchiveDocument getThroughTransactions(String sUDI, int personId) throws Exception {
		ArchiveDocument archDoc = null;

		Vector allArchDocs = MedwanQuery.getInstance().getTransactionsByType(personId,ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_ARCHIVE_DOCUMENT");
		Iterator docIter = allArchDocs.iterator();

		TransactionVO tran;
		while(docIter.hasNext()){
			tran = (TransactionVO)docIter.next();
			
			String sTmpUDI = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_UDI");
			if(sTmpUDI.equals(sUDI)){
				// convert tran to archDoc
	            archDoc = new ArchiveDocument();

	            String sServerId = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_SERVERID"),
	                   sObjectId = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_OBJECTID");
				archDoc.setUid(sServerId+"."+sObjectId);
				
	            archDoc.udi = sTmpUDI;	            
	            archDoc.title = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_TITLE");
	            archDoc.description = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_DESCRIPTION");
	            archDoc.category = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_CATEGORY");
	            archDoc.author = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_AUTHOR");
	            archDoc.date = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(tran.getUpdateTime()));	            
	            archDoc.destination = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_DESTINATION");
	            archDoc.reference = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_REFERENCE");
                archDoc.personId = Integer.parseInt(tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_PERSONID"));	            
	            archDoc.storageName = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_STORAGENAME");

	            // link with transaction
				archDoc.tranServerId = tran.getServerId();
				archDoc.tranTranId = tran.getTransactionId().intValue();
	            
	            break;
			}
		}
		
		return archDoc;		
	}

	//--- GET -------------------------------------------------------------------------------------
	public static ArchiveDocument get(String sUDI){
        return get(sUDI,false);		
	}
	
	public static ArchiveDocument get(String sUDI, boolean mustHaveStorageName){
		ArchiveDocument archDoc = null;

		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		ResultSet rs = null;
		
		String sSql = "SELECT * FROM arch_documents"+
		              " WHERE ARCH_DOCUMENT_UDI = ?";
		if(mustHaveStorageName){
	        sSql+= " AND "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(ARCH_DOCUMENT_STORAGENAME) > 0";
		}
		
		try{
			ps = conn.prepareStatement(sSql);
			ps.setString(1,sUDI);
			rs = ps.executeQuery();
			
			if(rs.next()){
				archDoc = new ArchiveDocument();
				archDoc.setUid(rs.getInt("ARCH_DOCUMENT_SERVERID")+"."+rs.getInt("ARCH_DOCUMENT_OBJECTID"));
				
				archDoc.udi = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_UDI"));
				archDoc.title = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_TITLE"));
				archDoc.description = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_DESCRIPTION"));
				archDoc.category = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_CATEGORY"));
				archDoc.author = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_AUTHOR"));
				archDoc.date = rs.getDate("ARCH_DOCUMENT_DATE");
				archDoc.destination = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_DESTINATION"));
				archDoc.reference = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_REFERENCE"));
				archDoc.personId = rs.getInt("ARCH_DOCUMENT_PERSONID");
				archDoc.storageName = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_STORAGENAME"));
				archDoc.deleteDate = rs.getDate("ARCH_DOCUMENT_DELETEDATE");

	            // link with transaction
				archDoc.tranServerId = rs.getInt("ARCH_DOCUMENT_TRAN_SERVERID");
				archDoc.tranTranId = rs.getInt("ARCH_DOCUMENT_TRAN_TRANSACTIONID");
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(rs!=null) rs.close();
				if(ps!=null) ps.close();
				if(conn!=null) conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		
		return archDoc;		
	}
	
	//--- GET BASIC -------------------------------------------------------------------------------
	// for environments without MedwanQuery
	public static ArchiveDocument getBasic(String sUDI, Connection conn){
        return getBasic(sUDI,false,conn);		
	}
	
	public static ArchiveDocument getBasic(String sUDI, boolean mustHaveStorageName, Connection conn){
		ArchiveDocument archDoc = null;
		
		PreparedStatement ps = null;
		ResultSet rs = null;
		
		String sSql = "SELECT * FROM arch_documents"+
		              " WHERE ARCH_DOCUMENT_UDI = ?";
		if(mustHaveStorageName){
	        sSql+= " AND len(ARCH_DOCUMENT_STORAGENAME) > 0";
		}
		
		try{
			ps = conn.prepareStatement(sSql);
			ps.setString(1,sUDI);
			rs = ps.executeQuery();
			
			if(rs.next()){
				archDoc = new ArchiveDocument();
				archDoc.setUid(rs.getInt("ARCH_DOCUMENT_SERVERID")+"."+rs.getInt("ARCH_DOCUMENT_OBJECTID"));
				
				archDoc.udi = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_UDI"));
				archDoc.title = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_TITLE"));
				archDoc.description = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_DESCRIPTION"));
				archDoc.category = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_CATEGORY"));
				archDoc.author = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_AUTHOR"));
				archDoc.date = rs.getDate("ARCH_DOCUMENT_DATE");
				archDoc.destination = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_DESTINATION"));
				archDoc.reference = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_REFERENCE"));
				archDoc.personId = rs.getInt("ARCH_DOCUMENT_PERSONID");
				archDoc.storageName = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_STORAGENAME"));
				archDoc.deleteDate = rs.getDate("ARCH_DOCUMENT_DELETEDATE");

	            // link with transaction
				archDoc.tranServerId = rs.getInt("ARCH_DOCUMENT_TRAN_SERVERID");
				archDoc.tranTranId = rs.getInt("ARCH_DOCUMENT_TRAN_TRANSACTIONID");
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(rs!=null) rs.close();
				if(ps!=null) ps.close();
				if(conn!=null) conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		
		return archDoc;		
	}
    	
	//--- FIND -------------------------------------------------------------------------------------
	public static Vector find(int personId, String sFindTitle, String sFindCategory, String sFindBegin, String sFindEnd){
	    return find(personId,sFindTitle,sFindCategory,sFindBegin,sFindEnd,false,false); // only not-deleted documents	
	}
	
	public static Vector find(int personId, String sFindTitle, String sFindCategory, String sFindBegin, String sFindEnd,
			                  boolean includeDeletedDocuments, boolean onlyScannedDocuments){
		Vector archDocs = new Vector();

		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		ResultSet rs = null;
		
		String sSql = "SELECT * FROM arch_documents"+
		              " WHERE ARCH_DOCUMENT_PERSONID = ?";

		if(onlyScannedDocuments){
		    sSql+= " AND arch_document_storagename IS NOT NULL AND arch_document_storagename <> ''";	
		}
		
		if(!includeDeletedDocuments){
		    sSql+= " AND ARCH_DOCUMENT_DELETEDATE IS NULL";
		
		           /*
				      "  AND EXISTS("+
		              "   SELECT 1 FROM transactions"+
				      "    WHERE serverid = d.ARCH_DOCUMENT_TRAN_SERVERID"+
		              "     AND transactionid = d.ARCH_DOCUMENT_TRAN_TRANSACTIONID"+
				      "  )";
		           */
		}
		
		if(sFindTitle.length() > 0){
			sSql+= " AND ARCH_DOCUMENT_TITLE LIKE ?";
		}
		if(sFindCategory.length() > 0){
			sSql+= " AND ARCH_DOCUMENT_CATEGORY = ?";
		}
		
		// dates
		if(sFindBegin.length() > 0 && sFindEnd.length() > 0){
			sSql+= " AND ARCH_DOCUMENT_DATE BETWEEN ? AND ?";
		}
		else if(sFindBegin.length() > 0){
			sSql+= " AND ARCH_DOCUMENT_DATE >= ?";
		}
		else if(sFindEnd.length() > 0){
			sSql+= " AND ARCH_DOCUMENT_DATE <= ?";
		}
		
		try{
			Debug.println(sSql);
			ps = conn.prepareStatement(sSql);
			int psIdx = 1;

			ps.setInt(psIdx++,personId);
			
			if(sFindTitle.length() > 0){
				ps.setString(psIdx++,"%"+sFindTitle+"%");
			}
			if(sFindCategory.length() > 0){
				ps.setString(psIdx++,sFindCategory);
			}
			
			// dates
			if(sFindBegin.length() > 0 && sFindEnd.length() > 0){
				ps.setDate(psIdx++,new java.sql.Date(ScreenHelper.parseDate(sFindBegin).getTime()));
				ps.setDate(psIdx++,new java.sql.Date(ScreenHelper.parseDate(sFindEnd).getTime()));
			}
			else if(sFindBegin.length() > 0){
				ps.setDate(psIdx++,new java.sql.Date(ScreenHelper.parseDate(sFindBegin).getTime()));
			}
			else if(sFindEnd.length() > 0){
				ps.setDate(psIdx++,new java.sql.Date(ScreenHelper.parseDate(sFindEnd).getTime()));
			}
			
			rs = ps.executeQuery();
			
			ArchiveDocument archDoc = null;
			while(rs.next()){
				archDoc = new ArchiveDocument();
				archDoc.setUid(rs.getInt("ARCH_DOCUMENT_SERVERID")+"."+rs.getInt("ARCH_DOCUMENT_OBJECTID"));

				archDoc.udi = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_UDI"));
				archDoc.title = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_TITLE"));
				archDoc.description = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_DESCRIPTION"));
				archDoc.category = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_CATEGORY"));
				archDoc.author = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_AUTHOR"));
				archDoc.date = rs.getDate("ARCH_DOCUMENT_DATE");
				archDoc.destination = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_DESTINATION"));
				archDoc.reference = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_REFERENCE"));
				archDoc.personId = rs.getInt("ARCH_DOCUMENT_PERSONID");
				archDoc.storageName = ScreenHelper.checkString(rs.getString("ARCH_DOCUMENT_STORAGENAME"));
				archDoc.deleteDate = rs.getDate("ARCH_DOCUMENT_DELETEDATE");

	            // link with transaction
				archDoc.tranServerId = rs.getInt("ARCH_DOCUMENT_TRAN_SERVERID");
				archDoc.tranTranId = rs.getInt("ARCH_DOCUMENT_TRAN_TRANSACTIONID");
				
				archDocs.add(archDoc);
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(rs!=null) rs.close();
				if(ps!=null) ps.close();
				if(conn!=null) conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		
		return archDocs;		
	}
	
	//--- GET MOST RECENT DOCUMENTS ---------------------------------------------------------------
	// search through transactions
	public static Vector getMostRecentDocuments(int maxRecords, int personId, boolean onlyScannedDocuments) throws Exception {
		Vector recentArchDocs = new Vector();
		Vector allArchDocs = MedwanQuery.getInstance().getTransactionsByType(personId,
				                                       ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_ARCHIVE_DOCUMENT");

		Iterator docIter = allArchDocs.iterator();
		ArchiveDocument archDoc;		
		TransactionVO tran;
		int docCount = 0;
		
		while(docIter.hasNext() && docCount < maxRecords){	
			tran = (TransactionVO)docIter.next();
			
			// convert tran to archDoc
	        archDoc = new ArchiveDocument();

            String sServerId = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_SERVERID"),
                   sObjectId = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_OBJECTID");
			archDoc.setUid(sServerId+"."+sObjectId);
	            
            archDoc.udi = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_UDI");
            archDoc.title = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_TITLE");
            archDoc.description = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_DESCRIPTION");
            archDoc.category = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_CATEGORY");
            archDoc.author = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_AUTHOR");
            archDoc.date = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(tran.getUpdateTime()));
            archDoc.destination = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_DESTINATION");
            archDoc.reference = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_REFERENCE");
            archDoc.personId = Integer.parseInt(tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_PERSONID"));
            archDoc.storageName = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_STORAGENAME");
			
            // link with transaction
			archDoc.tranServerId = tran.getServerId();
			archDoc.tranTranId = tran.getTransactionId().intValue();
			
			if((onlyScannedDocuments && archDoc.storageName.length() > 0) || !onlyScannedDocuments){
                recentArchDocs.add(archDoc);
			}
		}

		return recentArchDocs;		
	}
			
	//--- DELETE ----------------------------------------------------------------------------------
	// --> set deletedate, when deleting a transaction
	public static void delete(String sUID){		
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		
		String sSql = "UPDATE arch_documents SET ARCH_DOCUMENT_DELETEDATE = ?"+
		              " WHERE ARCH_DOCUMENT_SERVERID = ? AND ARCH_DOCUMENT_OBJECTID = ?";
		
		try{
			ps = conn.prepareStatement(sSql);
			ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime())); // now
			ps.setInt(2,Integer.parseInt(sUID.split("\\.")[0]));
			ps.setInt(3,Integer.parseInt(sUID.split("\\.")[1]));
			ps.executeUpdate();
			
			Debug.println("--> Archive-document marked as deleted : "+sUID+" (UID)");
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(ps!=null) ps.close();
				if(conn!=null) conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}	
	}
	
    //--- COMPARE TO ------------------------------------------------------------------------------
    public int compareTo(Object o) {
        int comp;
        
        if(o.getClass().isInstance(this)){
            comp = this.udi.compareTo(((ArchiveDocument)o).udi);
        } 
        else {
            throw new ClassCastException();
        }
        
        return comp;
    }
    
    //--- SET STORAGE NAME ------------------------------------------------------------------------
    // also update linked transaction
    public static void setStorageName(String sUDI, String sStorageName){
    	if(Debug.enabled){
	    	Debug.println("\n****************** setStorageName ********************");
	    	Debug.println("sUDI         : "+sUDI);
	    	Debug.println("sStorageName : "+sStorageName);
    	}
    	
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		ResultSet rs = null;
			
		try{
			//*** 1 - update archDoc ***
			String sSql = "UPDATE arch_documents SET ARCH_DOCUMENT_STORAGENAME = ?"+
		                  " WHERE ARCH_DOCUMENT_UDI = ?";	
			ps = conn.prepareStatement(sSql);
			ps.setString(1,sStorageName);
			ps.setString(2,sUDI);
			int recsUpdated = ps.executeUpdate();
			ps.close();
			conn.close();
			
			if(recsUpdated > 0){
				Debug.println("--> Storagename set for archive-document with UDI '"+sUDI+"' : "+sStorageName);
				
				//*** 2 - get link with transaction ***
				int serverId = -1, tranId = -1;
				sSql = "SELECT ARCH_DOCUMENT_TRAN_SERVERID, ARCH_DOCUMENT_TRAN_TRANSACTIONID"+
				       " FROM arch_documents"+
		               "  WHERE ARCH_DOCUMENT_UDI = ?";	
				ps = conn.prepareStatement(sSql);
				ps.setString(1,sUDI);
				rs = ps.executeQuery();
				if(rs.next()){
					serverId = rs.getInt(1);
					tranId   = rs.getInt(2);
				}
				rs.close();
				ps.close();
				conn.close();			
				
				//*** 3 - update linked transaction ***
				if(serverId > -1 && tranId > -1){
					sSql = "UPDATE items SET value = ?, version = version+1, versionserverid = ?"+
					       " WHERE serverid = ? AND transactionid = ?"+
						   "  AND type = ?";
					ps = conn.prepareStatement(sSql);
					ps.setString(1,sStorageName);
					ps.setInt(2,serverId); // versionserver
					ps.setInt(3,serverId);
					ps.setInt(4,tranId);
					ps.setString(5,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_STORAGENAME");
					int updatedRecs = ps.executeUpdate();
					ps.close();
					conn.close();
				
					if(updatedRecs==0){
						// insert item when not found during update
	                    sSql = "INSERT INTO Items(itemId,type,"+MedwanQuery.getInstance().getConfigString("valueColumn")+","+
	                    		MedwanQuery.getInstance().getConfigString("dateColumn")+","+
	                    		"transactionId,serverid,version,versionserverid,valuehash)"+
	                            " VALUES(?,?,?,?,?,?,?,?,?)";
	                    ps = conn.prepareStatement(sSql);
	                    ps.setInt(1,new Integer(MedwanQuery.getInstance().getOpenclinicCounter("ItemID")));
	                    ps.setString(2,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_STORAGENAME");
	                    ps.setString(3,sStorageName);
	                    ps.setDate(4,new java.sql.Date(new java.util.Date().getTime()));
	                    ps.setInt(5,tranId);
	                    ps.setInt(6,serverId);
	                    ps.setInt(7,1); // version
	                    ps.setInt(8,Integer.parseInt(MedwanQuery.getInstance().getConfigString("serverId"))); // versionserverid
	                    ps.setInt(9,(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_DOC_STORAGENAME"+sStorageName).hashCode());
	                    ps.execute();
	                    ps.close();	
	                    //remove transaction from cache
					}
					
					Debug.println("--> Storagename set in linked transaction '"+serverId+"."+tranId+"' to '"+sStorageName+"'");
				}
				else{			
					Debug.println("--> WARNING : Storagename NOT set in linked transaction, because no link found for archive-document with UDI '"+sUDI+"'");
				}
			}
			else{
				// recsUpdated == 0
				Debug.println("--> Storagename NOT SET, because no archive-document found with UDI '"+sUDI+"'.");
			}
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(rs!=null) rs.close();
				if(ps!=null) ps.close();
				if(conn!=null) conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
    }
    
    //--- GET STORAGE NAME ------------------------------------------------------------------------
    public static String getStorageName(String sUDI){
    	if(Debug.enabled){
	    	Debug.println("\n****************** getStorageName ********************");
	    	Debug.println("sUDI : "+sUDI);
    	}
    	
    	String sStorageName = "";
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps = null;
		ResultSet rs = null;
			
		try{
			String sSql = "SELECT ARCH_DOCUMENT_STORAGENAME"+
			              " FROM arch_documents"+
		                  "  WHERE ARCH_DOCUMENT_UDI = ?";	
			ps = conn.prepareStatement(sSql);
			ps.setString(1,sUDI);
			ps.executeQuery();
			rs = ps.executeQuery();
			if(rs.next()){
				sStorageName = ScreenHelper.checkString(rs.getString(1));
			}
			
			Debug.println("--> storagename : "+sStorageName);
		}
		catch(Exception e){
			e.printStackTrace();
		}
		finally{
			try{
				if(rs!=null) rs.close();
				if(ps!=null) ps.close();
				if(conn!=null) conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
		}
		
		return sStorageName;
    }
    
    //--- GENERATE UDI ----------------------------------------------------------------------------
    // checkDigits = 97 - (eerste 9 cijfers MOD 97)
    // 000000001/96
    // 000000002/95
    // 000000003/94 ...
    // --> 96 = 97 - (1/97)
    // --> 96 = 97 - 1
    //
    // '000123472/xx'
    //  --> xx = 97 - (123472%97)
    //  --> xx = 97 - 88
    //  --> xx = 09
    //   --> 000123472/09
    //
    // '000123480/01'
    //  --> 1 = 97 - (123480%97)
    //  --> 1 = 97 - 96
    //  --> 1 = 1
    public static String generateUDI(final int objectId){
    	String sUDI = Integer.toString(objectId);
    	
    	int xx = 97 - (objectId%97);
    	String sXX = Integer.toString(xx);
    	while(sXX.length()<2) sXX = "0"+sXX;
    	sUDI+= sXX;
    	
    	while(sUDI.length()<11) sUDI = "0"+sUDI;

        Debug.println("GENERATED UDI from OBJECTID "+objectId+" : "+sUDI);
    	
    	return sUDI;
    }
    
    //--- GET LINKED TRANSACTION ------------------------------------------------------------------
    public TransactionVO getLinkedTransaction(){    	
    	return MedwanQuery.getInstance().loadTransaction(this.tranServerId,this.tranTranId);
    }
    
}
