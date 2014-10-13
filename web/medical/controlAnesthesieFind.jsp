<%@page import="be.openclinic.medical.AnesthesieControl,
                java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("controlanesthesie","select",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindBegin = checkString(request.getParameter("FindBegin")),
           sFindEnd   = checkString(request.getParameter("FindEnd"));

    String sMsg = checkString(request.getParameter("Msg"));
    
    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************* medical/controlAnesthesieFind.jsp *************");
    	Debug.println("sAction    : "+sAction);
    	Debug.println("sFindBegin : "+sFindBegin);
    	Debug.println("sFindEnd   : "+sFindEnd);
    	Debug.println("sMsg       : "+sMsg+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
%>

<form name="searchForm" method="post">
    <input type="hidden" name="Action" value="">
    
    <%=writeTableHeader("web","controlanesthesie",sWebLanguage,"main.do?Page=medical/controlAnesthesieEdit.jsp")%>
    
    <table width="100%" class="list" cellspacing="1" onkeydown="if(enterEvent(event,13)){searchForm.submit();}">
        <%-- BEGIN --%>
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("web","Begin",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindBegin","searchForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        
        <%-- END --%>
        <tr>
            <td class="admin2"><%=getTran("web","End",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindEnd","searchForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
	            <input type="button" class="button" name="ButtonFind" value="<%=getTranNoLink("web","Find",sWebLanguage)%>" onclick="doFind();">&nbsp;
	            <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("web","Clear",sWebLanguage)%>" onclick="clearFields();">&nbsp;
	            <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("web","New",sWebLanguage)%>" onclick="doNew();">&nbsp;
		    </td>
		</tr>        
    </table>

	<%
	    if(sMsg.length() > 0){
	    	if(sMsg.equalsIgnoreCase("saved")){
	    		sMsg = getTran("web","dataIsSaved",sWebLanguage);
	    	}
	    	%><%=sMsg%><br><br><%
	    }
	%>
</form>

    
<%
    //--- FIND ------------------------------------------------------------------------------------
    if(sAction.equals("find")){
        String sClass = "", sDate, sControlName, sControlID;	
        int iCounter = 0;

        Vector vACs = AnesthesieControl.searchAnesthesieControls(sFindBegin,sFindEnd);        
        if(vACs.size() > 0){
            %>		            	
                <%=sJSSORTTABLE%>
       
		        <table cellspacing="0" width="100%" class="sortable" id="searchresults">
		            <%-- DATE --%>
		            <tr class="admin">
		                <td width="100"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
		                <td><%=getTran("openclinic.chuk","control_performed_by",sWebLanguage)%></td>
		            </tr>
		           
		            <tbody onmouseover="this.style.cursor='hand'" onmouseout="this.style.cursor='default'">
         	<%
        	
	        Iterator acIter = vACs.iterator();
	        AnesthesieControl ac;
	        while(acIter.hasNext()){
	            iCounter++;
	
	            ac = (AnesthesieControl)acIter.next();
	            sDate = ScreenHelper.getSQLDate(ac.getDate());
	            sControlID = ac.getControlPerformedById();
	
	            if(sControlID.length() > 0){
	               	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
	                sControlName = ScreenHelper.getFullUserName(sControlID,ad_conn);
	                ad_conn.close();
	            }
	            else{
	                sControlName = "";
	            }
             
	            // alternate row-style
	            if(sClass.equals("")) sClass = "1";
	            else                  sClass = "";
    		
    		    %>
                    <tr class="list<%=sClass%>" onclick="showAnesthesie('<%=ac.getUid()%>');">
                        <td>&nbsp;<%=sDate%></td><td>&nbsp;<%=sControlName%></td>
                    </tr>
                <%
            }
	        
	        %>
		            </tbody>
		        </table>
	        
	            <%=iCounter%> <%=getTran("web","recordsFound",sWebLanguage)%>
	        
	            <script>
	              function showAnesthesie(sID){
	                window.location.href= "<c:url value='/main.do'/>?Page=medical/controlAnesthesieEdit.jsp"+
	                                      "&EditUID="+sID+"&View=true&ts=<%=getTs()%>";
	              }
	            </script>
            <%
        }
		else{
            %><%=getTran("web","noRecordsFound",sWebLanguage)%><%
		}	    
    }
%>
    
<script>
  searchForm.FindBegin.focus();

  <%-- DO FIND --%>
  function doFind(){
	searchForm.Action.value = "find"; 
	searchForm.submit();  
  }
  
  <%-- CLEAR FIELDS --%>
  function clearFields(){
    searchForm.FindBegin.value = "";
    searchForm.FindEnd.value = "";
    searchForm.FindBegin.focus();
  }

  <%-- DO NEW --%>
  function doNew(){
    window.location.href = "<c:url value='/main.do'/>?Page=medical/controlAnesthesieEdit.jsp&ts=<%=getTs()%>";
  }
</script>