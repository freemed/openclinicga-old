<%@page import="be.openclinic.medical.*,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sAction = checkString(request.getParameter("Action"));

    String sFindReagentName = checkString(request.getParameter("FindReagentName"));
    String sFunction = checkString(request.getParameter("doFunction"));
    
    String sReturnFieldUid   = checkString(request.getParameter("ReturnFieldUid")),
           sReturnFieldDescr = checkString(request.getParameter("ReturnFieldDescr"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n****************** searchByAjax/searchReagentShow.jsp ******************");
    	Debug.println("sAction           : "+sAction);
    	Debug.println("sFindReagentName  : "+sFindReagentName);
    	Debug.println("sFunction         : "+sFunction);
    	Debug.println("sReturnFieldUid   : "+sReturnFieldUid);
    	Debug.println("sReturnFieldDescr : "+sReturnFieldDescr+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<div class="search">
    <%
        if(sAction.equals("search")){
            Vector foundReagents = Reagent.searchReagents(sFindReagentName);
            Iterator reagentsIter = foundReagents.iterator();

            String sClass = "", sUid, sDescr,sUnit;
            String sSelectTran = getTranNoLink("web","select",sWebLanguage);
            StringBuffer sHtml = new StringBuffer();
            String category = "";
            int recCount = 0;
            Reagent reagent;
            
            while(reagentsIter.hasNext()){
                reagent = (Reagent)reagentsIter.next();
                if(reagent!=null){
                	recCount++;
	
	                // names
	                sUid = reagent.getUid();
	                sDescr = checkString(reagent.getName());
	                sUnit = checkString(reagent.getUnit());
	
	                // alternate row-style
	                if(sClass.equals("")) sClass = "1";
	                else                  sClass = "";
	                
	                sHtml.append("<tr class='list"+sClass+"' title='"+sSelectTran+"' onclick=\"setReagent('"+sUid+"','"+sDescr+"','"+sUnit+"');\">")
	                      .append("<td width='60px'>"+reagent.getUid()+"</td>")
	                      .append("<td>"+sDescr+"</td>")
	                      .append("<td>"+sUnit+"</td>")
	                     .append("</tr>");
                }
            }

            if(recCount > 0){
			    %>
			    <table id="searchresults" class="sortable" width="100%" cellpadding="1" cellspacing="0" style="border:1px solid #ccc;">
			        <%-- header --%>
			        <tr class="admin">
			            <td><%=HTMLEntities.htmlentities(getTran("web","id",sWebLanguage))%></td>
			            <td><%=HTMLEntities.htmlentities(getTran("web","name",sWebLanguage))%></td>
			            <td><%=HTMLEntities.htmlentities(getTran("web","unit",sWebLanguage))%></td>
			        </tr>
			
			        <tbody class="hand">
			            <%=HTMLEntities.htmlentities(sHtml.toString())%>
			        </tbody>
			    </table>
			    
			    <%=recCount%> <%=HTMLEntities.htmlentities(getTran("web","recordsFound",sWebLanguage))%>
			    <%
    		}
            else{
		        // display 'no results' message
    			%><%=HTMLEntities.htmlentities(getTran("web","norecordsfound",sWebLanguage))%><%
        	}
    	}
   %>
</div>