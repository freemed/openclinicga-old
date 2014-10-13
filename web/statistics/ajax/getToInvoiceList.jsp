<%@page import="be.openclinic.finance.PatientInvoice,
                be.mxs.common.util.system.HTMLEntities,
                be.openclinic.finance.Debet,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindInvoiceType = checkString(request.getParameter("FindInvoiceType"));
  
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n****************** statistics/ajax/getToInvoiceLists.jsp ***************");
    	Debug.println("sFindInvoiceType : "+sFindInvoiceType+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
 
<table width='100%' cellspacing='0' class="sortable" id="searchresults">     
     <%        
        Vector debets = new Vector();
        if(sFindInvoiceType.equals("patient")){
        	debets = Debet.getPatientDebetsToInvoice();
        }
        else if(sFindInvoiceType.equals("insurar")){
        	debets = Debet.getInsurarDebetsToInvoice();
        }
        else if(sFindInvoiceType.equals("extrainsurar")){
        	debets = Debet.getExtraInsurarDebetsToInvoice();
        }
        
        int recsFound = debets.size();
        Iterator iter = debets.iterator();
        Debet debet;
        int i = 0;
        
        while(iter.hasNext()){
            debet = (Debet)iter.next();
                
            if(i==0){
            	// header
                %>
	                <tr class='gray'>
	                    <td width="100"><%=getTran("Web","prestations",sWebLanguage)%></td>
	                    <td width="100"><%=getTran("Web","period",sWebLanguage)%></td>
	                    <td width="80"><%=getTran("Web","amount",sWebLanguage)%></td>
	                    <td width="100"><%=getTran("Web","id",sWebLanguage)%></td>
	                    <td width="*"><%=getTran("Web","patient",sWebLanguage)%></td>
	                 </tr>
	             <%
            }
            
            %>
                <tr class='<%=(i%2==0?"list":"list1")%>'>
                 <td><%=debet.getComment()%></td>
                 <td><%=debet.getRefUid()%></td>
                 <td><%=debet.getAmount()%></td>
                 <td><a href='<c:url value="/"/>main.do?Page=curative/index.jsp&PersonID=<%=debet.getEncounterUid()%>'><%=debet.getEncounterUid()%></a></td>
                 <td><%=debet.getPatientName()%></td>
                </tr>
            <%
            
            i++;
        }
    %>
</table>

<%
    if(recsFound > 0){
        %><%=recsFound%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%><%
    }
    else{
        %><%=HTMLEntities.htmlentities(getTran("web","noRecordsfound",sWebLanguage))%><%
    }
%>