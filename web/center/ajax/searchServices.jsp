<%@page import="be.openclinic.system.Center,
                java.util.*,
                be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindBegin = checkString(request.getParameter("FindBegin")),
           sFindEnd   = checkString(request.getParameter("FindEnd"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** center/ajax/searchServices.jsp *******************");
    	Debug.println("sFindBegin : "+sFindBegin);
    	Debug.println("sFindEnd   : "+sFindEnd+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<table width="100%" cellspacing="0" class="sortable" id="searchresults">
    <tr height="20" class="admin">
        <td width="20">&nbsp;</td>
        <td width="80"><%=getTran("web","version",sWebLanguage)%></td>
        <td width="100"><%=getTran("web","updatetime",sWebLanguage)%></td>
        <td width="100"><%=getTran("wicket","create_date",sWebLanguage)%></td>
        <td width="*"><%=getTran("web","user",sWebLanguage)%></td>
    </tr>
    
    <tbody class="hand">
    <%
        int i = 0;
        List centerList = (Center.getAll(sFindBegin,sFindEnd,true));
        centerList.addAll(Center.getAll(sFindBegin,sFindEnd,false));
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
		        <td><img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" onClick="deleteService('<%=center.getUid()%>','<%=center.getVersion()%>')" title="<%=getTranNoLink("web","delete",sWebLanguage)%>"></td>
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
    </tbody>
</table>

<span><%=centerList.size()%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%></span>

<script>sortables_init();</script>