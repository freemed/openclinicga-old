<%@ page import="be.openclinic.medical.*,be.mxs.common.util.system.HTMLEntities" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>

<%
try{
	String sAction = checkString(request.getParameter("Action"));
    String sFindLabProcedureName = checkString(request.getParameter("FindLabProcedureName"));
    String sFunction = checkString(request.getParameter("doFunction"));
    String sReturnFieldUid = checkString(request.getParameter("ReturnFieldUid")),sReturnFieldDescr = checkString(request.getParameter("ReturnFieldDescr"));
%>

<div class="search">
    <%
        if (sAction.equals("search")) {
            Vector foundLabProcedures = LabProcedure.searchLabProcedures(sFindLabProcedureName);
            Iterator proceduresIter = foundLabProcedures.iterator();

            String sClass = "", sUid, sDescr,sReagent;
            String sSelectTran = getTranNoLink("web", "select", sWebLanguage);
            boolean recsFound = false;
            StringBuffer sHtml = new StringBuffer();
            LabProcedure procedure;
            String category = "";
            while (proceduresIter.hasNext()) {
                procedure = (LabProcedure) proceduresIter.next();
                if(procedure!=null){
	                recsFound = true;
	
	                // names
	                sUid = procedure.getUid();
	                sDescr = checkString(procedure.getName());
	                sReagent="";
	                for(int n=0;n<procedure.getReagents().size();n++){
	                	LabProcedureReagent reagent = (LabProcedureReagent)procedure.getReagents().elementAt(n);
	                	if(reagent.getReagent()!=null){
		                	if(sReagent.length()>0){
		                		sReagent+=", ";
		                	}
		                	sReagent+=reagent.getReagent().getName();
	                	}
	                }
	
	                // alternate row-style
	                if (sClass.equals("")) sClass = "1";
	                else sClass = "";
	                sHtml.append("<tr class='list" + sClass + "' title='" + sSelectTran + "' onclick=\"setLabProcedure('" + sUid + "','" + sDescr + "');\">")
	                        .append("<td width='60px'>" + procedure.getUid() + "</td>")
	                        .append("<td>" + sDescr + "</td>")
	                        .append("<td>" + sReagent + "</td>")
	                        .append("</tr>");
                }
            }

            if (recsFound) {
    %>
    <table id="searchresults" class="sortable" width="100%" cellpadding="1" cellspacing="0"
           style="border:1px solid #cccccc;">
        <%-- header --%>
        <tr class="admin">
            <td><%=HTMLEntities.htmlentities(getTran("web", "id", sWebLanguage))%>
            </td>
            <td><%=HTMLEntities.htmlentities(getTran("web", "name", sWebLanguage))%>
            </td>
            <td><%=HTMLEntities.htmlentities(getTran("web", "reagents", sWebLanguage))%>
            </td>
        </tr>

        <tbody class="hand">
            <%=HTMLEntities.htmlentities(sHtml.toString())%>
        </tbody>
    </table>
    <%
    } else {
        // display 'no results' message
    %><%=HTMLEntities.htmlentities(getTran("web", "norecordsfound", sWebLanguage))%><%
        }
    }
}
catch(Exception e){
	e.printStackTrace();
}
%>
</div>
