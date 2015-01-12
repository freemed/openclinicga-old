<%@page import="be.openclinic.adt.Encounter,java.util.*,
                be.openclinic.adt.Bed"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sEncounterUID = checkString(request.getParameter("EncounterUID")),
           sServiceUID   = checkString(request.getParameter("ServiceUID"));    

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************ adt/ajaxActions/editEncounterDeleteService.jsp ***********");
    	Debug.println("sEncounterUID : "+sEncounterUID);
    	Debug.println("sServiceUID   : "+sServiceUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
        
    Encounter.deleteService(sEncounterUID,sServiceUID);
    
    // list remaining transfers
    Encounter tmpEncounter = Encounter.get(sEncounterUID);
    if(tmpEncounter!=null){
        Vector transferHistory = tmpEncounter.getTransferHistory();
        Encounter.EncounterService encounterService;
        java.util.Hashtable username;

        if(transferHistory.size() > 0){
        	%><table width="100%"><%
        	
	        for(int n=0; n<transferHistory.size(); n++){
	            encounterService = (Encounter.EncounterService)transferHistory.elementAt(n);
	            username = User.getUserName(encounterService.managerUID);
	            
		        %>
				    <tr>
				        <td width="25"><img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="deleteService('<%=encounterService.serviceUID%>')"></td>
				        <td width="200"><%=ScreenHelper.formatDate(encounterService.begin)+" - "+ScreenHelper.formatDate(encounterService.end)%></td>
				        <td><b><%=getTran("Service",encounterService.serviceUID,sWebLanguage)%></b></td>
				        <td><%=getTran("web","bed",sWebLanguage)+": "+checkString(Bed.get(encounterService.bedUID).getName())%></td>
				        <td><%=getTran("web","manager",sWebLanguage)+": "+(username!=null?username.get("firstname")+" "+username.get("lastname"):"")%></td>
				    </tr>
				<%
	        }
	        %></table><%
        }
        else{
        	%><i><%=getTran("web","noRecordsFound",sWebLanguage)%></i><%
        }
        
        // refresh maxTransferDate-variable
        java.util.Date maxTranferDate = tmpEncounter.getMaxTransferDate();
		if(maxTranferDate!=null){
			Debug.println("--> new maxTransferDate = "+ScreenHelper.formatDate(maxTranferDate));
			%><script>document.getElementById("maxTransferDate").value = "<%=ScreenHelper.formatDate(maxTranferDate)%>";</script><%
		}
		else{
			Debug.println("--> new maxTransferDate = empty");
			%><script>document.getElementById("maxTransferDate").value = "";</script><%
		}
    }
%>