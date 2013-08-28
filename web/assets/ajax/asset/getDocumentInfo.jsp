<%@page import="be.openclinic.assets.Asset,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page import="java.io.*,
                org.dom4j.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
       
<%!
    //### INNER CLASS Document ####################################################################
    static class Document {
        public static String name;
        public static String filename;
        public static java.util.Date date;
        public static String author;
        
        //--- GET ---------------------------------------------------------------------------------
        public static Document get(){
            Document docu = null; 
                        
            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! TODO !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            docu = new Document();
            docu.name = "Testverslag";
            docu.filename = "test.pdf";
            docu.date = new java.util.Date();
            docu.author = "Stijn@mxs";
            //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
            
            /*
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
                    docu = new Document();
                    docu.setUid(rs.getString("OC_DOCUMENT_SERVERID")+"."+rs.getString("OC_DOCUMENT_OBJECTID"));
                    docu.serverId = Integer.parseInt(rs.getString("OC_DOCUMENT_SERVERID"));
                    docu.objectId = Integer.parseInt(rs.getString("OC_DOCUMENT_OBJECTID"));

                    docu.name     = checkString(rs.getString("OC_DOCUMENT_NAME"));
                    docu.filename = checkString(rs.getString("OC_DOCUMENT_FILENAME"));
                    docu.date     = checkString(rs.getString("OC_DOCUMENT_DATE"));
                    docu.author   = checkString(rs.getString("OC_DOCUMENT_AUTHOR"));
                    
                    // update-info
                    docu.setUpdateDateTime(rs.getTimestamp("OC_DOCUMENT_UPDATETIME"));
                    docu.setUpdateUser(rs.getString("OC_DOCUMENT_UPDATEID"));
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
            */

            return docu;
        }
    }
    //#############################################################################################
%>

<%
    String sDocumentId = checkString(request.getParameter("DocumentId"));

    String sDocumentBase = MedwanQuery.getInstance().getConfigParam("documentBase","");
    sDocumentBase = sDocumentBase.replaceAll("\\\\","/");

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*************** getDocumentInfo.jsp ***************");
        Debug.println("sDocumentBase : "+sDocumentBase);
        Debug.println("sDocumentId   : "+sDocumentId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////
   
    Document docu = Document.get();
    if(docu!=null){
        if(Debug.enabled){
            Debug.println("docu.name     : "+docu.name);
            Debug.println("docu.filename : "+docu.filename);
            Debug.println("docu.date     : "+ScreenHelper.stdDateFormat.format(docu.date));
            Debug.println("docu.author   : "+docu.author+"\n");
        }
        
        // check wether the referred document exists as a file
        File docuFile = new File(sDocumentBase+"/"+docu.filename);
        boolean documentExistsAsFile = (docuFile.exists() && !docuFile.isDirectory());
        
        if(documentExistsAsFile){
            // 1 : all is right
            %>
{
  "message":"ok",
  "documentName":"<%=HTMLEntities.htmlentities(docu.name)%>",
  "documentFilename":"<%=HTMLEntities.htmlentities(docu.filename)%>",
  "documentDate":"<%=HTMLEntities.htmlentities(ScreenHelper.stdDateFormat.format(docu.date))%>",
  "documentAuthor":"<%=HTMLEntities.htmlentities(docu.author)%>"
}
            <%
        }
        else{
            // 2 : not found as file
            String sMessage = "<font color='red'>"+getTranNoLink("web","fileNotFound",sWebLanguage)+" : "+sDocumentBase+"/"+docu.filename+"</font>";
            
            %>
{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "documentName":"<%=HTMLEntities.htmlentities(docu.name)%>",
  "documentFilename":"<%=HTMLEntities.htmlentities(docu.filename)%>",
  "documentDate":"<%=HTMLEntities.htmlentities(ScreenHelper.stdDateFormat.format(docu.date))%>",
  "documentAuthor":"<%=HTMLEntities.htmlentities(docu.author)%>"
}
            <%
        }
    }
    else{
        // 3 : not found in database
        String sMessage = "<font color='red'>"+getTranNoLink("web","documentNotFound",sWebLanguage)+"</font>";
        
        %>
{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "documentName":"",
  "documentFilename":"",
  "documentDate":"",
  "documentAuthor":""
}
        <%
    }
%>    