<%@page contentType="text/html;charset=UTF-8" language="java"%>

<%@page import="be.openclinic.system.Center"%>
<%@page import="java.util.*"%>
<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindBegin = checkString(request.getParameter("FindBegin")),
           sFindEnd   = checkString(request.getParameter("FindEnd"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************************** searchServices.jsp *************************");
    	Debug.println("sFindBegin : "+sFindBegin);
    	Debug.println("sFindEnd   : "+sFindEnd+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<table width='100%' onmouseover="this.style.cursor= 'pointer';" onmouseover="this.style.cursor= 'default';" cellspacing='1' class="sortable" id="searchresults">
    <tr height='20' class='admin'>
        <td width="25">&nbsp;</td>
        <td width="100"><%=getTran("web", "version", sWebLanguage)%></td>
        <td width="150"><%=getTran("web", "updatetime", sWebLanguage)%></td>
        <td width="150"><%=getTran("wicket", "create_date", sWebLanguage)%></td>
        <td><%=getTran("web", "user", sWebLanguage)%></td>
    </tr>
    
    <%
        int i = 0;
        List centerList = (Center.getAll(sFindBegin, sFindEnd, true));
        centerList.addAll(Center.getAll(sFindBegin, sFindEnd, false));
        Iterator centerIter = centerList.iterator();
        Center center;
        
        while(centerIter.hasNext()){
            center = (Center)centerIter.next();
            
            %><tr <%
            
            if(center.isActual()){
		        out.write("class='green'");
		    }
            else if(i%2==0){
		        out.write("class='list'");
		    }
            else{
		        out.write("class='list1'");
		    }
		    
		    %>>
		        <td><img src="<%=sCONTEXTPATH%>/_img/icon_delete.gif" onClick="deleteService('<%=center.getUid()%>')" title="<%=getTranNoLink("web","delete",sWebLanguage)%>"></td>
		        <td onclick="showService('<%=center.getVersion()%>')">&nbsp;<%=center.getVersion()%></td>
		        <td onclick="showService('<%=center.getVersion()%>')">&nbsp;<%=ScreenHelper.getSQLDate(center.getUpdateDateTime())%></td>
		        <td onclick="showService('<%=center.getVersion()%>')">&nbsp;<%=ScreenHelper.getSQLDate(center.getCreateDateTime())%></td>
		        <td onclick="showService('<%=center.getVersion()%>')">&nbsp;
			        <%
			            Hashtable hUser = User.getUserName(center.getUpdateUser());			
			            if(hUser!=null){
			                out.print(hUser.get("lastname")+" "+hUser.get("firstname"));
			            }
			    	%>
		        </td>
		    </tr>
		    <%
		    
		    i++;
	    }
    %>
</table>

<span><%=centerList.size()%> <%=HTMLEntities.htmlentities(getTran("web", "recordsfound", sWebLanguage))%></span>

<script>
  sortables_init();
</script>