<%@page import="be.openclinic.hr.SalaryCalculationManager"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../../hr/includes/commonFunctions.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));
    boolean ajaxMode = (checkString(request.getParameter("AjaxMode")).equalsIgnoreCase("true"));

    String sPeriodBegin = checkString(request.getParameter("beginDate")),
           sPeriodEnd   = checkString(request.getParameter("endDate")),
           sPersonId    = checkString(request.getParameter("personId"));
     
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
        Debug.println("ajaxMode     : "+ajaxMode);
        Debug.println("sPersonId    : "+sPersonId);
        Debug.println("sPeriodBegin : "+sPeriodBegin);
        Debug.println("sPeriodEnd   : "+sPeriodEnd+"\n");
    }
    //////////////////////////////////////////////////////////////////////////////////////////

    String sMsg = "";
    
    
    //*** CREATE **********************************************************************************
    if(sAction.equals("create")){
        java.util.Date periodBegin = null, periodEnd = null;
        
        if(sPeriodBegin.length() > 0){
            periodBegin = ScreenHelper.parseDate(sPeriodBegin);
        }
        if(sPeriodEnd.length() > 0){
            periodEnd = ScreenHelper.parseDate(sPeriodEnd);
        }
        
        int[] counters;
        if(sPersonId.length() > 0){
            // one specific dossier
        	counters = SalaryCalculationManager.createSalaryCalculationsForWorkschedulesForPerson(Integer.parseInt(sPersonId),periodBegin,periodEnd,activeUser);
        }
        else{
        	// all dossiers 
            counters = SalaryCalculationManager.createSalaryCalculationsForWorkschedules(periodBegin,periodEnd,activeUser);        
        }
        
        int calculationsCreated = counters[0],
            calculationsExisted = counters[1];
        
        sMsg = "Created <b>"+calculationsCreated+"</b> calculations;<br>"+
               "<b>"+calculationsExisted+"</b> calculations already existed.<br><br>"+
               "<i>When only few calculations were created, they might exist already.</i><br>"+
               "<i>If no period specified, the period is the current month.</i>";
    }
    
    if(ajaxMode==true){
    	// return message
    	%><%=sMsg%><%
    }
    else{
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
            <td class="admin" style="vertical-align:top;"><%=getTran("web.hr","employees",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap>
                <%
                    Vector employeeNames = new Vector(SalaryCalculationManager.getEmployeePersonIds().values()); 

                    String sEmployeeName;
	                for(int i=0; i<employeeNames.size(); i++){
	                	sEmployeeName = (String)employeeNames.get(i);
	                    
	                	%><%=sEmployeeName%><br><%
	                }        
                %>
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
    
    <i><font color="red">Workschedules have no priority over leaves.</font></i><br><br>
        
    <%-- link to hr/manage_workschedules --%>
    <% 
        if(activePatient!=null && activePatient.personid.length() > 0){
            %>
                <img src="<c:url value='/_img/themes/default/pijl.gif'/>">
                <a href="<c:url value='/main.do'/>?Page=hr/manage_workschedule.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("web","workschedulesForActivePatient",sWebLanguage)%></a><br>
            <%
        }
    %>     
    
    <%-- link to createSalaryCalculationsForLeaves --%>
    <img src="<c:url value='/_img/themes/default/pijl.gif'/>">
    <a href="<c:url value='/main.do'/>?Page=hr/management/createSalaryCalculationsForLeaves.jsp?ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("web.manage","createSalaryCalculationsForLeaves",sWebLanguage)%></a>&nbsp;
</form>  
    
<script>  
  <%-- CREATE CALCULATIONS --%>
  function createCalculations(){
    if(yesnoDialog("web","areYouSure")){
      var okToSubmit = true;

      if(okToSubmit){  
        <%-- begin can not be after end --%>
        if(document.getElementById("beginDate").value.length > 0 && document.getElementById("endDate").value.length > 0){
          var beginDate = makeDate(document.getElementById("beginDate").value),
              endDate   = makeDate(document.getElementById("endDate").value);
      
          if(beginDate.getTime() > endDate.getTime()){
            okToSubmit = false;
            alertDialog("web","beginMustComeBeforeEnd");
            document.getElementById("beginDate").focus();
          }
        }  
      }   
      
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
        <%
    }
%>
