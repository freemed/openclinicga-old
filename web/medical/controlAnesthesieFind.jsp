<%@page import="be.openclinic.medical.AnesthesieControl,
                java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("controlanesthesie","select",activeUser)%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindBegin = checkString(request.getParameter("FindBegin")),
           sFindEnd   = checkString(request.getParameter("FindEnd")),
           sFindOK    = checkString(request.getParameter("FindOK"));

	int pageIdx = 0;
	String sPageIdx = checkString(request.getParameter("PageIdx"));
	if(sPageIdx.length() > 0){
		pageIdx = Integer.parseInt(sPageIdx);
	}

    String sMsg = checkString(request.getParameter("Msg"));
    
    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************* medical/controlAnesthesieFind.jsp *************");
    	Debug.println("sAction    : "+sAction);
    	Debug.println("sFindBegin : "+sFindBegin);
    	Debug.println("sFindEnd   : "+sFindEnd);
    	Debug.println("sPageIdx   : "+sPageIdx);
    	Debug.println("sFindOK    : "+sFindOK);
    	Debug.println("sMsg       : "+sMsg+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
%>

<form name="searchForm" method="post">
    <input type="hidden" name="Action" value="">
    <input type="hidden" name="PageIdx" value="<%=pageIdx%>">
    
    <%=writeTableHeader("web","controlanesthesie",sWebLanguage)%>
    
    <table width="100%" class="list" cellspacing="1" onkeydown="if(enterEvent(event,13)){doFind();}">
        <%-- BEGIN --%>
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("web","Begin",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateFieldWithDelete("FindBegin","searchForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        
        <%-- END --%>
        <tr>
            <td class="admin2"><%=getTran("web","End",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateFieldWithDelete("FindEnd","searchForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        
        <%-- CHECKUP OK ? --%>
        <tr>
            <td class="admin2">&nbsp;</td>
            <td class="admin2"><input type="checkbox" name="FindOK" id="cb_FindOK" class="hand" <%=(sFindOK.equals("on")?"checked":"")%>><%=getLabel("web","checkupMustBeOK",sWebLanguage,"cb_FindOK")%></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin2">&nbsp;</td>
            <td class="admin2">
	            <input type="button" class="button" name="ButtonFind" value="<%=getTranNoLink("web","Find",sWebLanguage)%>" onclick="doFind();">
	            <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("web","Clear",sWebLanguage)%>" onclick="clearFields();">
	            <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("web","New",sWebLanguage)%>" onclick="doNew();">
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
        int foundRecords = AnesthesieControl.countAnesthesieControls(sFindBegin,sFindEnd,sFindOK.equals("on"));
        if(foundRecords > 0){
            Vector vACs = AnesthesieControl.searchAnesthesieControls(sFindBegin,sFindEnd,sFindOK.equals("on"),pageIdx);  
            %>		            	
                <%=sJSSORTTABLE%>
       
		        <table cellspacing="0" width="100%" class="sortable" id="searchresults">
		            <%-- header --%>
		            <tr class="admin">
		                <td width="100"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
		                <td width="200"><%=getTran("openclinic.chuk","control_performed_by",sWebLanguage)%></td>
		                <td width="*"><%=getTran("openclinic.chuk","ok",sWebLanguage)%></td>
		            </tr>
		           
		            <tbody class="hand">
         	<%

            String sClass = "1", sDate, sControlName, sControlID;	
            int shownRecords = 0;
            
	        Iterator acIter = vACs.iterator();
	        AnesthesieControl ac;
	        while(acIter.hasNext()){
	        	shownRecords++;
	
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
                        <td>&nbsp;<%=sDate%></td>
                        <td>&nbsp;<%=sControlName%></td>
                        <td>&nbsp;<%=(ac.isFullyOK()?"OK":"")%></td>
                    </tr>
                <%
            }
	        
	        %>
		            </tbody>
		        </table>
	        
	            <%=foundRecords%> <%=getTran("web","recordsFound",sWebLanguage)%><%
	                if(foundRecords > shownRecords){
	                    %>, <%=shownRecords%> <%=getTran("web","recordsShown",sWebLanguage)%><%
                    }
                %>
                	        
		        <%=writePagingControls(foundRecords,pageIdx)%>
		        
	            <script>
	              function showAnesthesie(sID){
	                window.location.href= "<c:url value='/main.do'/>?Page=medical/controlAnesthesieEdit.jsp"+
	                                      "&EditUID="+sID+"&View=true"+
	                                      "&FindBegin=<%=sFindBegin%>"+
	                                      "&FindEnd=<%=sFindEnd%>"+
	                                      "&FindOK=<%=sFindOK%>"+
	                                      "&PageIdx=<%=sPageIdx%>"+
	                                      "&ts=<%=getTs()%>";
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

  <%-- SHOW PAGE --%>
  function showPage(pageIdx){
    searchForm.PageIdx.value = pageIdx;  
	searchForm.Action.value = "find"; 
	searchForm.submit(); 
  }
  
  <%-- DO FIND --%>
  function doFind(){
	searchForm.Action.value = "find"; 
    searchForm.PageIdx.value = "0";
	searchForm.submit();  
  }
  
  <%-- CLEAR FIELDS --%>
  function clearFields(){
    searchForm.FindBegin.value = "";
    searchForm.FindEnd.value = "";
    searchForm.FindOK.checked = false;
    searchForm.PageIdx.value = "0";
    
    searchForm.FindBegin.focus();
  }

  <%-- DO NEW --%>
  function doNew(){
    window.location.href = "<c:url value='/main.do'/>?Page=medical/controlAnesthesieEdit.jsp&ts=<%=getTs()%>";
  }
</script>