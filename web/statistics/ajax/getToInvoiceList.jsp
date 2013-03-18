<%@ page import="be.openclinic.finance.PatientInvoice" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="be.openclinic.finance.Debet" %>
<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
     <table width='100%' cellspacing='0' class="sortable" id="searchresults">
        <%-- header --%>
        <tr height='20' class='gray'>
            <td><%=getTran("Web","prestations",sWebLanguage)%></td>
            <td><%=getTran("Web","amount",sWebLanguage)%></td>
            <td><%=getTran("Web","id",sWebLanguage)%></td>
            <td><%=getTran("Web","patient",sWebLanguage)%></td>
        </tr>
            <tbody>
    <%

        String sFindInvoiceType = checkString(request.getParameter("FindInvoiceType"));
        Vector v = new Vector();
        if(sFindInvoiceType.equals("patient")){
            v = Debet.getPatientDebetsToInvoice();
        }else if(sFindInvoiceType.equals("insurar")){
            v = Debet.getInsurarDebetsToInvoice();
        }else if(sFindInvoiceType.equals("extrainsurar")){
            v = Debet.getExtraInsurarDebetsToInvoice();
        }
         int recsFound = v.size();
         Debet debet;
            Iterator iter = v.iterator();
        int i = 0;
            while(iter.hasNext()){
                debet = (Debet)iter.next();
                %>
                <tr class='<%=(i%2==0)?"list":"list1"%>'><td ><%=debet.getComment()%></td><td ><%=debet.getAmount()%></td><td><a href='<c:url value="/"/>main.do?Page=curative/index.jsp&PersonID=<%=debet.getEncounterUid()%>'><%=debet.getEncounterUid()%></a></td><td><%=debet.getPatientName()%></td></tr>
                <%
            i++;
            }
    %>
         </tbody>
     </table>
<span><br /><%=recsFound%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%></span>