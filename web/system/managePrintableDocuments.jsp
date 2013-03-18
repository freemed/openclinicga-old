<%@page import="java.util.*"%>
<%@page import="java.io.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>  
<%@page import="be.openclinic.common.DocumentsFilter"%>

<%=checkPermission("printabledocuments","select",activeUser)%>

<%!
    //--- INNER CLASS Document --------------------------------------------------------------------
    public class Document{
        public String documentName;
        public String documentLabelId;
        public String documentModule;
        public boolean selected;

        // constructor
        public Document(String sDocumentName, String sDocumentLabelId, String sDocumentModule, boolean selected){
            this.documentName = sDocumentName;
            this.documentLabelId = sDocumentLabelId;
            this.documentModule = sDocumentModule;
            this.selected = selected;
        }
    }
    
    //--- SET CHECK BOX ---------------------------------------------------------------------------
    private String setCb(Document document, boolean checkIfChecked, String sWebLanguage) {
        // checked ?
        boolean isDocumentChecked;
        String sChecked = "";
        if(checkIfChecked){
            isDocumentChecked = isDocumentCheckedInDB(document.documentName);
            if(isDocumentChecked){
                sChecked = " checked";
            }
        }
        
        return "<input type='checkbox' name='" + document.documentName + "'" + sChecked + " id='cb_" + document.documentName + "'>&nbsp;" + getLabel("documents", document.documentLabelId, sWebLanguage, "cb_"+document.documentName) + "<br>";
    }

    //--- IS DICUMENT CHECKED IN DB ---------------------------------------------------------------
    private boolean isDocumentCheckedInDB(String sDocumentName){
        boolean checked = false;
        PreparedStatement ps = null;
        ResultSet rs = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT 1 FROM printableDocuments"+
                          " WHERE documentName = ?"+
                          "  AND selected = 1";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,sDocumentName);
            rs = ps.executeQuery();
            checked = rs.next();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(rs!=null) rs.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }        

        return checked;
    }

    //--- CHECK DOCUMENT IN DB ----------------------------------------------------------------
    private void checkDocumentInDB(String sDocumentName){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // update record : check document
            String sSql = "UPDATE printableDocuments SET selected = 1, updatetime = ?"+
                          " WHERE documentName = ?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime())); // now
            ps.setString(2,sDocumentName);
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- INSERT DOCUMENT IN DB ----------------------------------------------------------------
    private void insertDocumentInDB(Document document){
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            // insert document
            String sSql = "INSERT INTO printableDocuments(documentName,documentLabelId,documentModule,selected,updatetime)"+
                          " VALUES (?,?,?,?,?)";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,document.documentName);
            ps.setString(2,document.documentLabelId);
            ps.setString(3,document.documentModule);
            ps.setBoolean(4,false); // not checked
            ps.setTimestamp(5,new java.sql.Timestamp(new java.util.Date().getTime())); // now
            ps.executeUpdate();
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }
    }

    //--- GET DOCUMENT FROM DB --------------------------------------------------------------------
    private Document getDocumentFromDB(String sDocumentName){
        PreparedStatement ps = null;
        ResultSet rs = null;
        Document document = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM printableDocuments"+
                          " WHERE documentName = ?";
            ps = oc_conn.prepareStatement(sSql);
            ps.setString(1,sDocumentName);
            rs = ps.executeQuery();

            if(rs.next()){
                document = new Document(checkString(rs.getString("documentName")),
                                        checkString(rs.getString("documentLabelId")),
                                        checkString(rs.getString("documentModule")),
                                        rs.getBoolean("selected"));
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                if(rs!=null) rs.close();
                oc_conn.close();
            }
            catch(Exception e){
                e.printStackTrace();
            }
        }

        return document;
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        //*** first uncheck all previously checked documents in DB ***
        PreparedStatement ps = null;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "UPDATE printableDocuments SET selected = 0";
            ps = oc_conn.prepareStatement(sSql);
            ps.executeUpdate();
        }
        catch(Exception ex){
            ex.printStackTrace();
        }
        finally{
            try{
                if(ps!=null) ps.close();
                oc_conn.close();
            }
            catch(Exception sqle){
                sqle.printStackTrace();
            }
        }

        //*** run thru parameters and filter out the checkboxes
        String sParamName, sParamValue;

        Enumeration e = request.getParameterNames();
        while(e.hasMoreElements()){
            sParamName = (String)e.nextElement();

            sParamValue = checkString(request.getParameter(sParamName));
            if(sParamValue.equals("on")){
                checkDocumentInDB(sParamName);
            }
        }
    }
%>

<form name="transactionForm" method="post">
    <input type="hidden" name="Action">

    <%-- title --%>
    <%=writeTableHeader("web","printableDocuments",sWebLanguage," doBack();")%>
    
    <table width="100%" cellspacing="0" class="menu">
        <tr>
            <td>
            <%
                // display documents in configured directory, and check those which are marked as seleted in the database
                String sDocumentsFolder = MedwanQuery.getInstance().getConfigString("DocumentsFolder");

                int documentCount = 0;
                File documentsDir = new File(sDocumentsFolder+"/base/");
                if(documentsDir.exists() && documentsDir.isDirectory()){
                    FileFilter documentsFilter = new DocumentsFilter();
                    File[] documents = documentsDir.listFiles(documentsFilter);

                    Document document;
                    String sDocumentNameWithoutExt, sDocumentNameStripped, sDocLanguage;
                    
                    for(int i=0; i<documents.length; i++){
                        document = getDocumentFromDB(documents[i].getName());
                        sDocLanguage = documents[i].getName().substring(0,documents[i].getName().indexOf("_"));

                        if(document==null){
                            sDocumentNameWithoutExt = documents[i].getName().substring(0,documents[i].getName().lastIndexOf(".")); // strip extension
                            sDocumentNameStripped = sDocumentNameWithoutExt.substring(documents[i].getName().indexOf("_")+1); // strip language

                            document = new Document(documents[i].getName(),
                                                    sDocumentNameStripped,
                                                    sDocumentNameWithoutExt.replaceAll(sDocLanguage+"_","xx_"),
                                                    false);
                            insertDocumentInDB(document);

                            if(sDocLanguage.equalsIgnoreCase(sWebLanguage)){
                                out.print(setCb(document,false,sWebLanguage));
                                documentCount++;
                            }
                        }
                        else{
                            if(sDocLanguage.equalsIgnoreCase(sWebLanguage)){
                                out.print(setCb(document,true,sWebLanguage));
                                documentCount++;
                            }
                        }
                    }
                }
                else{
                    System.out.println("WARNING : configvalue 'DocumentsFolder' with value '"+sDocumentsFolder+"' is not an existing directory.");
                }

                if(documentCount==0){
                    %>&nbsp;<%=getTran("web","noDocumentsFound",sWebLanguage)%><%
                }
            %>
            </td>
        </tr>
    </table>

    <%-- number of documents found --%>
    <%
        if(documentCount > 0){
            %>
                <%-- UN/CHECK ALL --%>
                <a href="#" onclick="checkAll('documents',true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
                <a href="#" onclick="checkAll('documents',false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a><br>

                <%=documentCount%> <%=getTran("web","documentsFound",sWebLanguage)%><br>
            <%
        }
    %>

    <br>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%
            if(documentCount > 0){
                %><input type="button" class="button" name="saveButton" value="<%=getTran("web","save",sWebLanguage)%>" onclick="doSave();"><%
            }
        %>
        <input type="button" class="button" name="backButton" value="<%=getTran("Web","back",sWebLanguage)%>" OnClick="doBack();">
    <%=ScreenHelper.alignButtonsStop()%>
</form>

<script>
  <%-- CHECK ALL --%>
  function checkAll(tab,setchecked){
    var element; 
    for(var i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="checkbox"){
        element = transactionForm.elements[i];
        if(element.id.startsWith("cb_")){
          element.checked = setchecked;
        }
      }
    }
  }

  <%-- DO SAVE --%>
  function doSave(){
    transactionForm.Action.value = "save";
    transactionForm.submit();
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }
</script>