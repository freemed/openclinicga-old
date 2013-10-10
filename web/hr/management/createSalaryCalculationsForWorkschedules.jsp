<%@page import="be.openclinic.hr.SalaryCalculationManager"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../hr/includes/commonFunctions.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));
 
    String sPeriodBegin = checkString(request.getParameter("PeriodBegin")),
           sPeriodEnd   = checkString(request.getParameter("PeriodEnd"));
	 
    if(sPeriodBegin.length()==0 || sPeriodEnd.length()==0){
	    // currMonth : begin and end
	    Calendar now = Calendar.getInstance();        
	    int month = now.get(Calendar.MONTH)+1;
	    String sMonth = Integer.toString(month);
	    if(month < 10){
	        sMonth = "0"+sMonth;
	    }
	    	    
	    if(sPeriodBegin.length()==0){
            String sCurrMonthBegin = "01/"+sMonth+"/"+now.get(Calendar.YEAR);
	        sPeriodBegin = sCurrMonthBegin;
	    }
	    
	    if(sPeriodEnd.length()==0){
            String sCurrMonthEnd = now.getActualMaximum(Calendar.DAY_OF_MONTH)+"/"+sMonth+"/"+now.get(Calendar.YEAR);
	        sPeriodEnd = sCurrMonthEnd;
	    }
    }
    
	/// DEBUG ////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n**** hr/management/createSalaryCalculationsForWorkschedules.jsp ****");
	    Debug.println("sAction      : "+sAction);
	    Debug.println("sPeriodBegin : "+sPeriodBegin);
	    Debug.println("sPeriodEnd   : "+sPeriodEnd+"\n");
	}
	//////////////////////////////////////////////////////////////////////////////////////////

	String sMsg = "";
	
	
	//*** CREATE **********************************************************************************
	if(sAction.equals("create")){
		java.util.Date periodBegin = null, periodEnd = null;
		
		if(sPeriodBegin.length() > 0){
			periodBegin = ScreenHelper.stdDateFormat.parse(sPeriodBegin);
		}
		if(sPeriodEnd.length() > 0){
			periodEnd = ScreenHelper.stdDateFormat.parse(sPeriodEnd);
		}
		
		int calculationsCreated = SalaryCalculationManager.createSalaryCalculations(periodBegin,periodEnd,activeUser);
		
		sMsg = "Created <b>"+calculationsCreated+"</b> calculations<br><br>"+
		       "<i>When only few calculations were created, they might exist already.</i><br>"+
		       "<i>If no period specified, the period is the current month.</i>";
	}
%>
  
<form name="EditForm" method="post" action="<c:url value='/main.do'/>?Page=hr/management/createSalaryCalculationsForWorkschedules.jsp&ts=<%=getTs()%>" onkeydown="if(enterEvent(event,13)){createCalculations();return false;}">
    <%=writeTableHeader("web.manage","createSalaryCalculationsForWorkschedules",sWebLanguage,"")%>
    <input type="hidden" name="Action" value="">

    <table border="0" width="100%" cellspacing="1">      
        <%-- beginDate --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.hr","beginDate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <%=writeDateField("beginDate","EditForm",sPeriodBegin,sWebLanguage)%>          
            </td>                        
        </tr>
        
        <%-- endDate --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","endDate",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <%=writeDateField("endDate","EditForm",sPeriodEnd,sWebLanguage)%>          
            </td>                        
        </tr> 
        
        <%-- employees --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","employees",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                      
            </td>                        
        </tr>            
                                      
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2">
                <input type="button" class="button" name="buttonCreate" value="<%=getTranNoLink("web.manage","createCalculations",sWebLanguage)%>" onclick="createCalculations();">
                <input type="button" class="button" name="buttonBack" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
    <br>
        
    <%
        // display message, if any
        if(sMsg.length() > 0){
        	%><%=sMsg%><br><br><%
        }
    %>    
        
    <%-- link to hr/manage_workschedules --%>
    <img src='<c:url value="/_img/pijl.gif"/>'>
    <a href="<c:url value='/main.do'/>?Page=hr/manage_workschedule.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("web","workschedule",sWebLanguage)%></a>&nbsp;    
    <br>
    
    <%-- link to hr/manageDefaultSalaryCodes --%>
    <img src='<c:url value="/_img/pijl.gif"/>'>
    <a href="<c:url value='/main.do'/>?Page=hr/manageDefaultSalaryCodes.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("web.manage","manageDefaultWorkschedules",sWebLanguage)%></a>&nbsp;    
</form>
    
<script>  
  <%-- CREATE CALCULATIONS --%>
  function createCalculations(){
    var answer = yesnoDialog("web","areYouSure");
	if(answer==1){
      var okToSubmit = true;

      /*
      if(okToSubmit){
        if(document.getElementById("weekScheduleType").value.length==0){
          okToSubmit = false;
          document.getElementById("weekScheduleType").focus();
          alertDialog("web.manage","dataMissing");
        }
      }
      */
    
      if(okToSubmit){
        EditForm.buttonCreate.disabled = true;
        EditForm.buttonBack.disabled = true;
        EditForm.Action.value = "create";
        
        EditForm.submit();
      }
    }    
  }
  
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.do?Page=system/menu.jsp";
  }
</script>
