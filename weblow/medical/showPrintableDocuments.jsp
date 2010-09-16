<%@page import="java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("showPrintableDocuments","select",activeUser)%>

<%!
    //--- INNER CLASS Document --------------------------------------------------------------------
    public class Document{
        public String documentName;
        public String documentModule;
        public String documentLabelId;
        public boolean selected;

        // constructor
        public Document(String sDocumentName, String sDocumentModule, String sDocumentLabelId, boolean selected){
            this.documentName = sDocumentName;
            this.documentModule = sDocumentModule;
            this.documentLabelId = sDocumentLabelId;
            this.selected = selected;
        }
    }
%>

<%=writeTableHeader("Web","printableDocuments",sWebLanguage," doBack();")%>

<table width="100%" class="list" cellspacing="0" cellpadding="0">
    <%
        //*** LIST DOCUMENTS from db ****************************************************
        Hashtable documents = new Hashtable();
        String sClass = "", sDocumentName, sDocumentLabelId;
        Document document;
        PreparedStatement ps = null;
        ResultSet rs = null;
        int documentCount = 0;

        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        try{
            String sSql = "SELECT * FROM printableDocuments"+
                          " WHERE selected = 1";
            ps = oc_conn.prepareStatement(sSql);
            rs = ps.executeQuery();

            while(rs.next()){
                sDocumentName    = checkString(rs.getString("documentName"));
                sDocumentLabelId = checkString(rs.getString("documentLabelId"));

                document = new Document(sDocumentName,
                                        sDocumentLabelId,
                                        checkString(rs.getString("documentModule")),
                                        rs.getBoolean("selected"));

                documents.put(getTranNoLink("documents",sDocumentLabelId,sWebLanguage),document);
                documentCount++;
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

        // sort on document label
        Vector sortedNames = new Vector(documents.keySet());
        Collections.sort(sortedNames);
        String sDocumentLabel;

        Iterator documentIter = sortedNames.iterator();
        while(documentIter.hasNext()) {
            sDocumentLabel = (String)documentIter.next();
            document = (Document)documents.get(sDocumentLabel);

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else                   sClass = "";

           %>
                <tr class="list<%=sClass%>" onmouseover="this.className='list_select';" onmouseout="this.className='list<%=sClass%>';">
                    <td>
                        <a target="refdocument" href="<c:url value='/medical/loadPDF.jsp?'/>file=base/<%=document.documentName%>&ts=<%=getTs()%>&module=xx_<%=document.documentModule%>"><%=sDocumentLabel%></a>
                    </td>
                </tr>
           <%
        }

        // no documents found
        if(documentCount==0){
            %><tr><td>&nbsp;<%=getTran("web","noDocumentsFound",sWebLanguage)%></td></tr><%
        }
    %>
</table>

<%-- number of documents found --%>
<%
    if(documentCount > 0){
        %><%=documentCount%> <%=getTran("web","documentsFound",sWebLanguage)%><%
    }
%>

<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="backButton" value="<%=getTran("Web","back",sWebLanguage)%>" OnClick="doBack();">
<%=ScreenHelper.alignButtonsStop()%>

<script>
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
  }
</script>