<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.archiving.ArchiveDocument,
                java.util.*,
                java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
       
<%
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

    String sDocumentId = checkString(request.getParameter("DocumentId"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n****************** assets/ajax/asset/openDocument.jsp ******************");
        Debug.println("sDocumentId : "+sDocumentId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    ArchiveDocument docu = ArchiveDocument.get(sDocumentId);
    if(docu!=null){
        if(Debug.enabled){
            Debug.println("docu.author       : "+docu.author);
            Debug.println("docu.category     : "+docu.category);
            Debug.println("docu.description  : "+docu.description);
            Debug.println("docu.destination  : "+docu.destination);
            Debug.println("docu.personId     : "+docu.personId);
            Debug.println("docu.reference    : "+docu.reference);
            Debug.println("docu.storageName  : "+docu.storageName);
            Debug.println("docu.title        : "+docu.title);
            Debug.println("docu.tranServerId : "+docu.tranServerId);
            Debug.println("docu.tranTranId   : "+docu.tranTranId);
            Debug.println("docu.udi          : "+docu.udi);
            
            if(docu.date!=null){
                Debug.println("docu.date         : "+ScreenHelper.stdDateFormat.format(docu.date));
            }
            
            if(docu.deleteDate!=null){
                Debug.println("docu.deleteDate   : "+ScreenHelper.stdDateFormat.format(docu.deleteDate)+"\n");
            }
        }

    	// show link to open document, when server is configured
    	String sPath = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_basePath")+"/"+
    	               MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirTo");
        Debug.println("--> Full path : "+sPath+(sPath.endsWith("/")?"":"/")+(docu.storageName.startsWith("/")?docu.storageName.substring(1):docu.storageName));
    	
        String sURL = MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_url")+"/"+
	                  MedwanQuery.getInstance().getConfigString("scanDirectoryMonitor_dirTo");    	
        Debug.println("--> Full URL  : "+sURL+(sURL.endsWith("/")?"":"/")+(docu.storageName.startsWith("/")?docu.storageName.substring(1):docu.storageName));
        
        File file = new File(sPath+"/"+docu.storageName);
        if(file.exists()){
            StringBuffer sbContentDispValue = new StringBuffer();
            sbContentDispValue.append("inline; filename=").append(file.getName());

            // prepare response
            response.setHeader("Cache-Control","max-age=30");
            String sFileExt = file.getName().substring(file.getName().lastIndexOf(".")+1);
            response.setContentType("application/"+sFileExt);
            response.setHeader("Content-disposition",sbContentDispValue.toString());
            response.setContentLength((int)file.length());

            // write PDF to servlet
            FileInputStream fis = new FileInputStream(file);
            ServletOutputStream sos = response.getOutputStream();             
            byte[] outputByte = new byte[4096];
            while(fis.read(outputByte,0,4096)!=-1){
            	sos.write(outputByte,0,4096);
            }
            fis.close();
            sos.flush();
            sos.close();
        }
        else{
        	Debug.println("Document with udi '"+sDocumentId+"' not found as file.");
        }
    }
    else{
    	Debug.println("Document with udi '"+sDocumentId+"' not found in database.");
    }
%>