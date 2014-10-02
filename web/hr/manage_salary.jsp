<%@page import="be.openclinic.hr.Salary,
               java.text.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../hr/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.salary.edit","edit",activeUser)%>

<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%=sJSSORTTABLE%>

<script src="<%=sCONTEXTPATH%>/hr/includes/commonFunctions.js"></script> 

<%
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** manage_salary.jsp ****************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////
%>            

<%=writeTableHeader("web","salary",sWebLanguage,"")%><br>

<div id="divSalaries" class="searchResults" style="width:100%;height:160px;"></div>

<form name="EditForm" id="EditForm" method="POST">
    <input type="hidden" id="EditSalaryUid" name="EditSalaryUid" value="-1">
                
    <table class="list" border="0" width="100%" cellspacing="1">        
        <%-- contract --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.hr","contract",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="contract" id="contract" value="">
                <input type="text" class="text" name="contractName" id="contractName" readonly size="20" value="">
                   
                <%-- buttons --%>
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("web","select",sWebLanguage)%>" onclick="searchContract('contract','contractName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="document.getElementById('contract').value='';document.getElementById('contractName').value='';">
            </td>
        </tr>
        
        <%-- begin date (*) --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","begin",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2" nowrap> 
                <%=writeDateField("beginDate","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
        
        <%-- end date --%>
        <tr>
            <td class="admin"><%=getTran("web.hr","end",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" nowrap> 
                <%=writeDateField("endDate","EditForm","",sWebLanguage)%>            
            </td>                        
        </tr>
                
        <%-- gross salary (*) --%>
        <%
            // depends on configured currency-mask
            int decimalLength = 2;
            String sPriceFormat = MedwanQuery.getInstance().getConfigParam("priceFormat","");
            if(sPriceFormat.length() > 0){
            	int dotIdx = sPriceFormat.indexOf(".");
            	if(dotIdx > -1){
	            	decimalLength = sPriceFormat.length()-dotIdx; // number of characters behind the dot
            	}
            	else{
            		decimalLength = 0;
            	}
            }
        %>
        <tr>
            <td class="admin"><%=getTran("web.hr","grossSalary",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="salary" name="salary" size="10" maxLength="14" onKeyUp="isNumber(this)" onBlur="if(isNumber(this))setDecimalLength(this,<%=decimalLength%>,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","")%>&nbsp;
            </td>
        </tr>
                    
        <%-- gross salary period (*) --%>  
        <tr>
            <td class="admin"><%=getTran("web.hr","grossSalaryPeriod",sWebLanguage)%>&nbsp;*&nbsp;</td> 
            <td class="admin2">                                                  
                <select class="text" id="salaryPeriod" name="salaryPeriod">
                    <option/>
                    <%=ScreenHelper.writeSelectUnsorted("hr.salary.period","period3",sWebLanguage)%>
                </select>&nbsp;  
            </td>
        </tr>
                      
        <%-- XML 1 - benefits (multi-add) -------------------------------------------------------%>   
        <tr>
            <td class="admin" nowrap><%=getTran("web.hr","benefits",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" id="benefits" name="benefits" value="">
                                     
                <table width="100%" class="sortable" id="tblBE" cellspacing="1" headerRowCount="2"> 
                    <%-- header --%>                        
                    <tr class="admin">
                        <%-- 0 - empty --%>
                        <td width="40" nowrap/>
                        <%-- 1 - beginDate --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","beginDate",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>
                        <%-- 2 - endDate --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","endDate",sWebLanguage)%>&nbsp;
                        </td>
                        <%-- 3 - period --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","period",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 4 - type --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","type",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 5 - amount --%>
                        <td width="80" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","amount",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 6 - empty --%>
                        <td width="300" nowrap>&nbsp;</td>      
                    </tr>
        
                    <%-- content by ajax and javascript --%>
                    
                    <%-- add-row --%>                          
                    <tr>
                        <%-- 0 - empty --%>
                        <td class="admin"/>
                        <%-- 1 - beBegin --%>
                        <td class="admin" nowrap> 
                            <%=writeDateField("beBegin","EditForm","",sWebLanguage)%>&nbsp; 
                        </td>
                        <%-- 2 - beEnd --%>
                        <td class="admin" nowrap>
                            <%=writeDateField("beEnd","EditForm","",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 3 - bePeriod --%>
                        <td class="admin">                                                        
                            <select class="text" id="bePeriod" name="bePeriod">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.salary.period","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>  
                        <%-- 4 - beType --%>
                        <td class="admin">                                                        
                            <select class="text" id="beType" name="beType">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.salary.benefit.type","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>   
                        <%-- 5 - amount --%>
                        <td class="admin"> 
                            <input type="text" class="text" id="beAmount" name="beAmount" size="10" maxLength="14" onKeyUp="isNumber(this)" onBlur="if(isNumber(this))setDecimalLength(this,<%=decimalLength%>,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","")%>&nbsp;
                        </td>
                        <%-- 6 - buttons --%>
                        <td class="admin" nowrap>
                            <input type="button" class="button" name="ButtonAddBE" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addBE();">
                            <input type="button" class="button" name="ButtonUpdateBE" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateBE();" disabled>&nbsp;
                        </td>    
                    </tr>
                </table>                    
            </td>
        </tr>        
                
        <%-- XML 2 - bonuses (multi-add) --------------------------------------------------------%>
        <tr>
            <td class="admin" nowrap><%=getTran("web.hr","bonuses",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" id="bonuses" name="bonuses" value="">
                                     
                <table width="100%" class="sortable" id="tblBO" cellspacing="1" headerRowCount="2"> 
                    <%-- header --%>                        
                    <tr class="admin">
                        <%-- 0 - empty --%>
                        <td width="40" nowrap/>
                        <%-- 1 - beginDate --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","beginDate",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>
                        <%-- 2 - endDate --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","endDate",sWebLanguage)%>&nbsp;
                        </td>
                        <%-- 3 - period --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","period",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 4 - type --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","type",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>   
                        <%-- 5 - percentage --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web","percentage",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 6 - amount --%>
                        <td width="80" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","amount",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 7 - empty --%>
                        <td width="200" nowrap>&nbsp;</td>    
                    </tr>
        
                    <%-- content by ajax and javascript --%>
                    
                    <%-- add-row --%>                          
                    <tr>
                        <%-- 0 - empty --%>
                        <td class="admin"/>
                        <%-- 1 - boBegin --%>
                        <td class="admin" nowrap> 
                            <%=writeDateField("boBegin","EditForm","",sWebLanguage)%>&nbsp; 
                        </td>
                        <%-- 2 - boEnd --%>
                        <td class="admin" nowrap>
                            <%=writeDateField("boEnd","EditForm","",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 3 - boPeriod --%>
                        <td class="admin">                                                        
                            <select class="text" id="boPeriod" name="boPeriod">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.salary.period","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>  
                        <%-- 4 - boType --%>
                        <td class="admin">                                                        
                            <select class="text" id="boType" name="boType" onChange="calculateBonus();">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.salary.bonus.type","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>   
                        <%-- 5 - boPercentage --%>
                        <td class="admin"> 
                            <input type="text" class="text" id="boPercentage" name="boPercentage" size="2" maxLength="5" onKeyUp="isNumber(this)" onBlur="if(isNumber(this)){setDecimalLength(this,2,true);calculateBonus();}" onBlur="if(isNumber(this))calculateBonusAmount(this.value);" value="">&nbsp;<%=getTran("web","percent",sWebLanguage).toLowerCase()%>
                        </td>
                        <%-- 6 - boAmount --%>
                        <td class="admin"> 
                            <input type="text" class="text" id="boAmount" name="boAmount" size="10" maxLength="14" onKeyUp="isNumber(this)" onBlur="if(isNumber(this))setDecimalLength(this,<%=decimalLength%>,true);" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","")%>&nbsp;
                        </td>
                        <%-- 6 - buttons --%>
                        <td class="admin" nowrap>
                            <input type="button" class="button" name="ButtonAddBO" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addBO();">
                            <input type="button" class="button" name="ButtonUpdateBO" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateBO();" disabled>&nbsp;
                        </td>    
                    </tr>
                </table>                    
            </td>
        </tr>        
        
        <%-- XML 3 - otherIncome (multi-add) ----------------------------------------------------%>     
        <tr>
            <td class="admin" nowrap><%=getTran("web.hr","otherIncome",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" id="otherIncome" name="otherIncome" value="">
                                     
                <table width="100%" class="sortable" id="tblOI" cellspacing="1" headerRowCount="2"> 
                    <%-- header --%>                        
                    <tr class="admin">
                        <%-- 0 - empty --%>
                        <td width="40" nowrap/>
                        <%-- 1 - beginDate --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","beginDate",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>
                        <%-- 2 - endDate --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","endDate",sWebLanguage)%>&nbsp;
                        </td>
                        <%-- 3 - period --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","period",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 4 - type --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","type",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 5 - amount --%>
                        <td width="80" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","amount",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 6 - empty --%>
                        <td width="300" nowrap>&nbsp;</td>   
                    </tr>
        
                    <%-- content by ajax and javascript --%>
                    
                    <%-- add-row --%>                          
                    <tr>
                        <%-- 0 - empty --%>
                        <td class="admin"/>
                        <%-- 1 - oiBegin --%>
                        <td class="admin" nowrap> 
                            <%=writeDateField("oiBegin","EditForm","",sWebLanguage)%>&nbsp; 
                        </td>
                        <%-- 2 - oiEnd --%>
                        <td class="admin" nowrap>
                            <%=writeDateField("oiEnd","EditForm","",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 3 - oiPeriod --%>
                        <td class="admin">                                                        
                            <select class="text" id="oiPeriod" name="oiPeriod">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.salary.period","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>  
                        <%-- 4 - oiType --%>
                        <td class="admin">                                                        
                            <select class="text" id="oiType" name="oiType" onChange="calculateOtherIncome();">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.salary.otherIncome.type","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>   
                        <%-- 5 - oiAmount --%>
                        <td class="admin"> 
                            <input type="text" class="text" id="oiAmount" name="oiAmount" size="10" maxLength="14" onKeyUp="isNumber(this)" onBlur="if(isNumber(this)){setDecimalLength(this,<%=decimalLength%>,true);calculateOtherIncome();}" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","")%>&nbsp;
                        </td>
                        <%-- 6 - buttons --%>
                        <td class="admin" nowrap>
                            <input type="button" class="button" name="ButtonAddOI" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addOI();">
                            <input type="button" class="button" name="ButtonUpdateOI" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateOI();" disabled>&nbsp;
                        </td>    
                    </tr>
                </table>                    
            </td>
        </tr>        
        
        <%-- XML 4 - deductions (multi-add) -----------------------------------------------------%>
        <tr>
            <td class="admin" nowrap><%=getTran("web.hr","deductions",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" id="deductions" name="deductions" value="">
                                     
                <table width="100%" class="sortable" id="tblDE" cellspacing="1" headerRowCount="2"> 
                    <%-- header --%>                        
                    <tr class="admin">
                        <%-- 0 - empty --%>
                        <td width="40" nowrap/>
                        <%-- 1 - beginDate --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","beginDate",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>
                        <%-- 2 - endDate --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","endDate",sWebLanguage)%>&nbsp;
                        </td>
                        <%-- 3 - period --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","period",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 4 - type --%>
                        <td width="70" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","type",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 5 - amount --%>
                        <td width="80" nowrap style="padding-left:0px;">
                            <%=getTran("web.hr","amount",sWebLanguage)%>&nbsp;*&nbsp;
                        </td>    
                        <%-- 6 - empty --%>
                        <td width="300" nowrap>&nbsp;</td>      
                    </tr>
        
                    <%-- content by ajax and javascript --%>
                    
                    <%-- add-row --%>                          
                    <tr>
                        <%-- 0 - empty --%>
                        <td class="admin"/>
                        <%-- 1 - deBegin --%>
                        <td class="admin" nowrap> 
                            <%=writeDateField("deBegin","EditForm","",sWebLanguage)%>&nbsp; 
                        </td>
                        <%-- 2 - deEnd --%>
                        <td class="admin" nowrap>
                            <%=writeDateField("deEnd","EditForm","",sWebLanguage)%>&nbsp;
                        </td>    
                        <%-- 3 - dePeriod --%>
                        <td class="admin">                                                        
                            <select class="text" id="dePeriod" name="dePeriod">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.salary.period","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>  
                        <%-- 4 - deType --%>
                        <td class="admin">                                                        
                            <select class="text" id="deType" name="deType" onChange="calculateDeduction();">
                                <option/>
                                <%=ScreenHelper.writeSelectUnsorted("hr.salary.deduction.type","",sWebLanguage)%>
                            </select>&nbsp;
                        </td>   
                        <%-- 5 - deAmount --%>
                        <td class="admin"> 
                            <input type="text" class="text" id="deAmount" name="deAmount" size="10" maxLength="14" onKeyUp="isNumber(this)" onBlur="if(isNumber(this)){setDecimalLength(this,<%=decimalLength%>,true);calculateDeduction();}" value="">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","")%>&nbsp;
                        </td>
                        <%-- 6 - buttons --%>
                        <td class="admin" nowrap>
                            <input type="button" class="button" name="ButtonAddDE" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addDE();">
                            <input type="button" class="button" name="ButtonUpdateDE" value="<%=getTranNoLink("web","edit",sWebLanguage)%>" onclick="updateDE();" disabled>&nbsp;
                        </td>    
                    </tr>
                </table>                    
            </td>
        </tr>                
        
        <%-- comment --%>                    
        <tr>
            <td class="admin"><%=getTran("web.hr","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="comment" id="comment" cols="80" rows="4" onKeyup="resizeTextarea(this,8);"></textarea>
            </td>
        </tr>
            
        <%-- BUTTONS --%>
        <tr>     
            <td class="admin"/>
            <td class="admin2" colspan="2">
                <input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveSalary();">&nbsp;
                <input class="button" type="button" name="buttonDelete" id="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteSalary();" style="visibility:hidden;">&nbsp;
                <input class="button" type="button" name="buttonNew" id="buttonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="newSalary();" style="visibility:hidden;">&nbsp;
            </td>
        </tr>
    </table>
    <i><%=getTran("web","colored_fields_are_obligate",sWebLanguage)%></i>
    
    <div id="divMessage" style="padding-top:10px;"></div>
</form>
    
<script>   
  <%-- CHECK INTERFERENCE --%>
  function checkInterference(){
	var interference = false;
	    
    var beginDate = null;
    if(document.getElementById("beginDate").value.length > 0){
      beginDate = makeDate(document.getElementById("beginDate").value);
    }

    var endDate = null;
    if(document.getElementById("endDate").value.length > 0){
      endDate = makeDate(document.getElementById("endDate").value);
    }
     
    for(var i=0; i<periodsWithSalary.length && interference==false; i++){
      var salaryUid = periodsWithSalary[i].split("_")[0];
	
      <%-- do not consider the period of the salary currently being edited --%>
      if(salaryUid!=EditForm.EditSalaryUid.value){        	
        var periodBegin = periodsWithSalary[i].split("_")[1],
     	    periodEnd   = periodsWithSalary[i].split("_")[2];
    
   	    <%-- begin- and end of period specified --%>
        if((periodBegin!=null && periodBegin.length > 0) && (periodEnd!=null && periodEnd.length > 0)){
          var periodBeginDate = makeDate(periodBegin),
              periodEndDate   = makeDate(periodEnd);

          if((beginDate==null || (beginDate!=null && (beginDate <= periodEndDate))) && (endDate==null || (endDate!=null && endDate > periodBeginDate))){
            alertDialog("web","periodsInterfere");
            document.getElementById("beginDate").focus();
            okToSubmit = false;                	
            interference = true;  
          }
        } 
        <%-- only begin of period specified --%>
        else if(periodBegin.length > 0){
          var periodBeginDate = makeDate(periodBegin);
          
          if(endDate==null || (endDate!=null && endDate >= periodBeginDate)){
            alertDialog("web","periodsInterfere");
            document.getElementById("beginDate").focus();
            okToSubmit = false;
            interference = true;                  	
          }
        }
        <%-- only end of period specified --%>
        else if(periodEnd.length > 0){
          var periodEndDate = makeDate(periodEnd);

          if(beginDate==null || (beginDate!=null && beginDate <= periodEndDate)){
            alertDialog("web","periodsInterfere");
            document.getElementById("beginDate").focus();
            okToSubmit = false;
            interference = true;                  	
          }
        }
      }
    }
    
    return interference;
  } 
  
  <%-- SAVE SALARY --%>
  function saveSalary(){
    var okToSubmit = true;
    
    if(document.getElementById("contract").value.length > 0 &&
       document.getElementById("beginDate").value.length > 0 &&
       document.getElementById("salary").value.length > 0 &&
       document.getElementById("salaryPeriod").selectedIndex > 0
      ){     
      <%-- beginDate can not be after endDate --%>
      if(document.getElementById("endDate").value.length > 0){
        var beginDate = makeDate(document.getElementById("beginDate").value),
            endDate   = makeDate(document.getElementById("endDate").value);
        
        if(beginDate > endDate){
          alertDialog("web","beginMustComeBeforeEnd");
          document.getElementById("beginDate").focus();
          okToSubmit = false;
        }  
      }

      <%-- periods can not interfere (max 1 salary at all times) --%>
      if(okToSubmit){
        okToSubmit = !checkInterference();  
      }
      
      if(okToSubmit){
        document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Saving";  
        var url = "<c:url value='/hr/ajax/salary/saveSalary.jsp'/>?ts="+new Date().getTime();

        document.getElementById("buttonSave").disabled = true;
        document.getElementById("buttonDelete").disabled = true;
        document.getElementById("buttonNew").disabled = true;
        
        new Ajax.Request(url,
          {
            method: "POST",
            postBody: "EditSalaryUid="+EditForm.EditSalaryUid.value+
                      "&PersonId=<%=activePatient.personid%>"+
                      "&begin="+document.getElementById("beginDate").value+
                      "&end="+document.getElementById("endDate").value+
                      "&contractUid="+document.getElementById("contract").value+
                      "&salary="+document.getElementById("salary").value+
                      "&salaryPeriod="+document.getElementById("salaryPeriod").value+
                      "&benefits="+removeTRIndexes(sBE)+ // xmls
                      "&bonuses="+removeTRIndexes(sBO)+
                      "&otherIncome="+removeTRIndexes(sOI)+
                      "&deductions="+removeTRIndexes(sDE)+
                      "&comment="+document.getElementById("comment").value,
            onSuccess: function(resp){
              var data = eval("("+resp.responseText+")");
              $("divMessage").innerHTML = data.message;

              if(document.getElementById("EditSalaryUid").value=="-1"){
                addSalaryPeriod(document.getElementById("EditSalaryUid").value);
              }
              else{
            	var sPeriod = document.getElementById("beginDate").value+"_"+document.getElementById("endDate").value;
                updateSalaryPeriod(document.getElementById("EditSalaryUid").value,sPeriod);
              }
              
              loadSalaries();
              newSalary();
              
              //EditForm.EditSalaryUid.value = data.newUid;
              document.getElementById("buttonSave").disabled = false;
              document.getElementById("buttonDelete").disabled = false;
              document.getElementById("buttonNew").disabled = false;
            },
            onFailure: function(resp){
              $("divMessage").innerHTML = "Error in 'hr/ajax/salary/saveSalary.jsp' : "+resp.responseText.trim();
            }
          }
        );
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
        
      <%-- focus empty field --%>
           if(document.getElementById("contract").value.length==0) document.getElementById("contractName").focus();
      else if(document.getElementById("beginDate").value.length==0) document.getElementById("beginDate").focus();
      else if(document.getElementById("salary").value.length==0) document.getElementById("salary").focus();
      else if(document.getElementById("salaryPeriod").selectedIndex==0) document.getElementById("salaryPeriod").focus();   
    }
  }
    
  <%-- LOAD SALARIES --%>
  function loadSalaries(){
    document.getElementById("divSalaries").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading";            
    var url = "<c:url value='/hr/ajax/salary/getSalaries.jsp'/>?ts="+new Date().getTime();
    new Ajax.Updater("divSalaries",url,
      { 
        method: "GET",
        evalScripts: true,
        parameters: "PatientId=<%=activePatient.personid%>",
        onSuccess: function(resp){
          $("divSalaries").innerHTML = resp.responseText;
          setTimeout("sortables_init()",500);
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/salary/getSalaries.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }
  
  var periodsWithSalary = new Array();

  <%-- ADD SALARY PERIOD --%>
  function addSalaryPeriod(salaryUid,sPeriod){
	var salaryFound = false;
	
    for(var i=0; i<periodsWithSalary.length && salaryFound==false; i++){
      if(periodsWithSalary[i].indexOf(salaryUid+"_")==0){
    	salaryFound = true;
      }
    }

    if(salaryFound==false){
      periodsWithSalary.push(salaryUid+"_"+sPeriod);
    }
  }

  <%-- REMOVE SALARY PERIOD --%>
  function removeSalaryPeriod(salaryUid){
	for(var i=0; periodsWithSalary.length; i++){
      if(periodsWithSalary[i].indexOf(salaryUid+"_")==0){
    	periodsWithSalary.splice(i,1);
      	break;
      }
	}
  }

  <%-- UPDATE SALARY PERIOD --%>
  function updateSalaryPeriod(salaryUid,sPeriod){
	for(var i=0; periodsWithSalary.length; i++){
	  if(periodsWithSalary[i].indexOf(salaryUid+"_")==0){
	  	periodsWithSalary.splice(i,1);
	  	periodsWithSalary.push(salaryUid+"_"+sPeriod);
	   	break;
	  }
    }
  }

  <%-- DISPLAY SALARY --%>
  function displaySalary(salaryUid){          
    var url = "<c:url value='/hr/ajax/salary/getSalary.jsp'/>?ts="+new Date().getTime();
    
    <%-- clear edit fields --%>
    newSalary();
    
    new Ajax.Request(url,
      {
        method: "GET",
        parameters: "SalaryUid="+salaryUid,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");

          $("EditSalaryUid").value = salaryUid;
          $("contract").value = data.contractUid;
          $("contractName").value = data.contractName.unhtmlEntities();
          $("beginDate").value = data.begin;
          $("endDate").value = data.end;
          $("salary").value = data.salary;
          $("salaryPeriod").value = data.salaryPeriod;
          $("comment").value = replaceAll(data.comment.unhtmlEntities(),"<br>","\n");
          
          <%-- multi-selects / xmls --%>
          $("benefits").value = data.benefits;
          $("bonuses").value = data.bonuses;
          $("otherIncome").value = data.otherIncome;
          $("deductions").value = data.deductions;
          
          displayBenefits();
          displayBonuses();
          displayOtherIncomes();
          displayDeductions();
          
          resizeAllTextareas(8);

          <%-- display hidden buttons --%>
          document.getElementById("buttonDelete").style.visibility = "visible";
          document.getElementById("buttonNew").style.visibility = "visible";
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/salary/getSalary.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }
  
  <%-- DELETE SALARY --%>
  function deleteSalary(){  
    var answer = yesnoDialog("web","areYouSureToDelete"); 
     if(answer==1){                 
      var url = "<c:url value='/hr/ajax/salary/deleteSalary.jsp'/>?ts="+new Date().getTime();

      document.getElementById("buttonSave").disabled = true;
      document.getElementById("buttonDelete").disabled = true;
      document.getElementById("buttonNew").disabled = true;
    
      new Ajax.Request(url,
        {
          method: "GET",
          parameters: "SalaryUid="+document.getElementById("EditSalaryUid").value,
          onSuccess: function(resp){
            var data = eval("("+resp.responseText+")");
            $("divMessage").innerHTML = data.message;

            removeSalaryPeriod(document.getElementById("EditSalaryUid").value);
            loadSalaries();
            newSalary();
            
            document.getElementById("buttonSave").disabled = false;
            document.getElementById("buttonDelete").disabled = false;
            document.getElementById("buttonNew").disabled = false;
          },
          onFailure: function(resp){
            $("divMessage").innerHTML = "Error in 'hr/ajax/salary/deleteSalary.jsp' : "+resp.responseText.trim();
          }  
        }
      );
    }
  }
    
  <%-- NEW SALARY --%>
  function newSalary(){  
    clearAllTables();
      
    <%-- hide irrelevant buttons --%>
    document.getElementById("buttonDelete").style.visibility = "hidden";
    document.getElementById("buttonNew").style.visibility = "hidden";

    $("EditSalaryUid").value = "-1";
    $("contract").value = "";
    $("contractName").value = "";
    $("beginDate").value = "";
    $("endDate").value = "";
    $("salary").value = "";
    $("salaryPeriod").selectedIndex = "type3"; // default : monthly
    $("comment").value = "";

    <%-- multi-selects --%>
    $("benefits").value = "";
    $("bonuses").value = "";
    $("otherIncome").value = "";
    $("deductions").value = "";
    
    $("contractName").focus();
    resizeAllTextareas(8);
  }
  
  <%-- clear all tables --%>
  function clearAllTables(){     
    clearBETable();
    clearBOTable();
    clearDETable();
    clearOITable();
  }
  
  <%-- CALCULATE BONUS AMOUNT --%>
  function calculateBonusAmount(percentage){      
    if(document.getElementById("salary").value.length > 0){
      percentage = percentage*1;
      var salary = document.getElementById("salary").value*1;

      document.getElementById("boAmount").value = (percentage * salary) / 100;
      
      if(isNumber(document.getElementById("boAmount"))){
        setDecimalLength(document.getElementById("boAmount"),2,false);
      }
    }
  }
  
  <%-- CALCULATE BONUS --%>
  function calculateBonus(){
    document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Calculating";
    
    var url = "<c:url value='/hr/ajax/salary/calculateBonus.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,
      {
        method: "POST",
        postBody: "SalaryUid="+EditForm.EditSalaryUid.value+
                  "&bonusType="+document.getElementById("boType").value+
                  "&bonusPercentage="+document.getElementById("boPercentage").value+
                  "&begin="+document.getElementById("beginDate").value+
                  "&end="+document.getElementById("endDate").value+
                  "&salary="+document.getElementById("salary").value+
                  "&salaryPeriod="+document.getElementById("salaryPeriod").value,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");          
          $("boAmount").value = data.value;            
          $("divMessage").innerHTML = data.message;
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/salary/calculateBonus.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }
  
  <%-- CALCULATE OTHER INCOME --%>
  function calculateOtherIncome(){
    document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Calculating";
    
    var url = "<c:url value='/hr/ajax/salary/calculateOtherIncome.jsp'/>?ts="+new Date().getTime();
    var parameters = "SalaryUid="+EditForm.EditSalaryUid.value+
                     "&otherIncomeType="+document.getElementById("oiType").value+
                     "&begin="+document.getElementById("beginDate").value+
                     "&end="+document.getElementById("endDate").value+
                     "&salary="+document.getElementById("salary").value+
                     "&salaryPeriod="+document.getElementById("salaryPeriod").value;    
    new Ajax.Request(url,
      {
        method: "POST",
        postBody: parameters,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");          
          $("oiAmount").value = data.value;            
          $("divMessage").innerHTML = data.message;
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/salary/calculateOtherIncome.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }
  
  <%-- CALCULATE DEDUCTION --%>
  function calculateDeduction(){
    document.getElementById("divMessage").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Calculating";
    
    var url = "<c:url value='/hr/ajax/salary/calculateDeduction.jsp'/>?ts="+new Date().getTime();
    new Ajax.Request(url,
      {
        method: "POST",
        postBody: "SalaryUid="+EditForm.EditSalaryUid.value+
                  "&deductionType="+document.getElementById("deType").value+
                  "&begin="+document.getElementById("beginDate").value+
                  "&end="+document.getElementById("endDate").value+
                  "&salary="+document.getElementById("salary").value+
                  "&salaryPeriod="+document.getElementById("salaryPeriod").value,
        onSuccess: function(resp){
          var data = eval("("+resp.responseText+")");          
          $("deAmount").value = data.value;            
          $("divMessage").innerHTML = data.message;
        },
        onFailure: function(resp){
          $("divMessage").innerHTML = "Error in 'hr/ajax/salary/calculateDeduction.jsp' : "+resp.responseText.trim();
        }
      }
    );
  }
    
  <%-- SEARCH CONTRACT --%>
  function searchContract(contractUidField,contractIdField){
    var url = "/_common/search/searchContract.jsp&ts=<%=getTs()%>"+
              "&PersonId=<%=activePatient.personid%>"+
              "&ReturnFieldContractUid="+contractUidField+
              "&ReturnFieldContractId="+contractIdField;
    openPopup(url);
    document.getElementById(contractIdField).focus();
  }

  <%-- JS 1 : BENEFIT FUNCTIONS -----------------------------------------------------------------%>
  var editBERowid = "", iBEIndex = 1, sBE = "";

  <%-- DISPLAY BENEFITS --%>
  function displayBenefits(){
    sBE = document.getElementById("benefits").value;
        
    if(sBE.indexOf("|") > -1){
      var sTmpBE = sBE;
      sBE = "";
      
      var sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpAmount;
 
      while(sTmpBE.indexOf("$") > -1){
        sTmpBegin = "";
        sTmpEnd = "";
        sTmpPeriod = "";
        sTmpType = "";
        sTmpAmount = "";

        if(sTmpBE.indexOf("|") > -1){
          sTmpBegin = sTmpBE.substring(0,sTmpBE.indexOf("|"));
          sTmpBE = sTmpBE.substring(sTmpBE.indexOf("|")+1);
        }
        
        if(sTmpBE.indexOf("|") > -1){
          sTmpEnd = sTmpBE.substring(0,sTmpBE.indexOf("|"));
          sTmpBE = sTmpBE.substring(sTmpBE.indexOf("|")+1);
        }
            
        if(sTmpBE.indexOf("|") > -1){
          sTmpPeriod = sTmpBE.substring(0,sTmpBE.indexOf("|"));
          sTmpBE = sTmpBE.substring(sTmpBE.indexOf("|")+1);
        }
            
        if(sTmpBE.indexOf("|") > -1){
          sTmpType = sTmpBE.substring(0,sTmpBE.indexOf("|"));
          sTmpBE = sTmpBE.substring(sTmpBE.indexOf("|")+1);
        }

        if(sTmpBE.indexOf("$") > -1){
          sTmpAmount = sTmpBE.substring(0,sTmpBE.indexOf("$"));
          sTmpBE = sTmpBE.substring(sTmpBE.indexOf("$")+1);
        }

        sBE+= "rowBE"+iBEIndex+"="+sTmpBegin+"|"+
                                   sTmpEnd+"|"+
                                   sTmpPeriod+"|"+
                                   sTmpType+"|"+
                                   sTmpAmount+"$";
        displayBenefit(iBEIndex++,sTmpBegin,sTmpEnd,sTmpPeriod,sTmpType,sTmpAmount);
      }
    }
  }
  
  <%-- DISPLAY BENEFIT --%>
  function displayBenefit(iBEIndex,sBegin,sEnd,sPeriod,sType,sAmount){
    var tblBE = document.getElementById("tblBE"); // FF
    var tr = tblBE.insertRow(tblBE.rows.length);
    tr.id = "rowBE"+iBEIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteBE(rowBE"+iBEIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editBE(rowBE"+iBEIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+sBegin;
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.innerHTML = "&nbsp;"+sEnd;
    tr.appendChild(td);
                             
    <%-- period --%>
    td = tr.insertCell(3);
         if(sPeriod=="period1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
    else if(sPeriod=="period2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
    else if(sPeriod=="period3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
    else if(sPeriod=="period4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
    else if(sPeriod=="period5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
    tr.appendChild(td);
    
    <%-- type --%>
    td = tr.insertCell(4);
         if(sType=="type1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.benefit.type","type1",sWebLanguage)%>";
    else if(sType=="type2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.benefit.type","type2",sWebLanguage)%>";
    else if(sType=="type3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.benefit.type","type3",sWebLanguage)%>";
    tr.appendChild(td);

    <%-- amount --%>
    td = tr.insertCell(5);
    td.innerHTML = "&nbsp;"+sAmount;
    tr.appendChild(td);
        
    <%-- empty cell --%>
    td = tr.insertCell(6);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iBEIndex);
  }
  
  <%-- ADD BENEFIT --%>
  function addBE(){
    if(areRequiredBEFieldsFilled()){
      var okToAdd = true;
      
      <%-- check dates --%>
      if(EditForm.beBegin.value.length > 0 && EditForm.beEnd.value.length > 0){
        var beginDate = makeDate(EditForm.beBegin.value),
            endDate   = makeDate(EditForm.beEnd.value);
        
        if(beginDate.getTime() > endDate.getTime()){
          okToAdd = false;
        }
      }
    
      if(okToAdd==true){
        iBEIndex++;

        <%-- update arrayString --%>
        sBE+="rowBE"+iBEIndex+"="+EditForm.beBegin.value+"|"+
                                  EditForm.beEnd.value+"|"+
                                  EditForm.bePeriod.value+"|"+
                                  EditForm.beType.value+"|"+
                                  EditForm.beAmount.value+"$";

        var tblBE = document.getElementById("tblBE"); // FF
        var tr = tblBE.insertRow(tblBE.rows.length);
        tr.id = "rowBE"+iBEIndex;

        var td = tr.insertCell(0);
        td.innerHTML = "<a href='javascript:deleteBE(rowBE"+iBEIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                       "</a> "+
                       "<a href='javascript:editBE(rowBE"+iBEIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                       "</a>";
        tr.appendChild(td);

        td = tr.insertCell(1);
        td.innerHTML = "&nbsp;"+EditForm.beBegin.value;
        tr.appendChild(td);

        td = tr.insertCell(2);
        td.innerHTML = "&nbsp;"+EditForm.beEnd.value;
        tr.appendChild(td);
                                 
        <%-- period --%>
        td = tr.insertCell(3);
             if(EditForm.bePeriod.selectedIndex==1) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
        else if(EditForm.bePeriod.selectedIndex==2) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
        else if(EditForm.bePeriod.selectedIndex==3) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
        else if(EditForm.bePeriod.selectedIndex==4) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
        else if(EditForm.bePeriod.selectedIndex==5) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
        tr.appendChild(td);
        
        <%-- type --%>
        td = tr.insertCell(4);
             if(EditForm.beType.selectedIndex==1) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.benefit.type","type1",sWebLanguage)%>";
        else if(EditForm.beType.selectedIndex==2) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.benefit.type","type2",sWebLanguage)%>";
        else if(EditForm.beType.selectedIndex==3) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.benefit.type","type3",sWebLanguage)%>";
        tr.appendChild(td);

        <%-- amount --%>
        td = tr.insertCell(5);
        td.innerHTML = "&nbsp;"+EditForm.beAmount.value;
        tr.appendChild(td);
      
        <%-- empty cell --%>
        td = tr.insertCell(6);
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        setRowStyle(tr,iBEIndex);
      
        <%-- reset --%>
        clearBEFields()
        EditForm.ButtonUpdateBE.disabled = true;
      }
      else{
        alertDialog("web","beginMustComeBeforeEnd");
        EditForm.beBegin.focus();
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
        
      <%-- focus empty field --%>
           if(EditForm.beBegin.value.length==0) EditForm.beBegin.focus();
      else if(EditForm.bePeriod.selectedIndex==0) EditForm.bePeriod.focus();
      else if(EditForm.beType.selectedIndex==0) EditForm.beType.focus();
    }
    
    return true;
  }

  <%-- UPDATE BENEFIT --%>
  function updateBE(){
    if(areRequiredBEFieldsFilled()){
      var okToAdd = true;

      <%-- check dates --%>
      if(EditForm.beBegin.value.length > 0 && EditForm.beEnd.value.length > 0){
        var beginDate = makeDate(EditForm.beBegin.value),
            endDate   = makeDate(EditForm.beEnd.value);
        
        if(beginDate.getTime() > endDate.getTime()){
          okToAdd = false;
        }
      }
    
      if(okToAdd==true){        
        <%-- update arrayString --%>
        var newRow = editBERowid.id+"="+EditForm.beBegin.value+"|"+
                                        EditForm.beEnd.value+"|"+
                                        EditForm.bePeriod.value+"|"+
                                        EditForm.beType.value+"|"+
                                        EditForm.beAmount.value;

        sBE = replaceRowInArrayString(sBE,newRow,editBERowid.id);

        <%-- update table object --%>
        var tblBE = document.getElementById("tblBE"); // FF
        var row = tblBE.rows[editBERowid.rowIndex];
        row.cells[0].innerHTML = "<a href='javascript:deleteBE("+editBERowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                                 "</a> "+
                                 "<a href='javascript:editBE("+editBERowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                                 "</a>";

        row.cells[1].innerHTML = "&nbsp;"+EditForm.beBegin.value;
        row.cells[2].innerHTML = "&nbsp;"+EditForm.beEnd.value;
                                 
        <%-- period --%>
             if(EditForm.bePeriod.selectedIndex==1) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
        else if(EditForm.bePeriod.selectedIndex==2) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
        else if(EditForm.bePeriod.selectedIndex==3) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
        else if(EditForm.bePeriod.selectedIndex==4) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
        else if(EditForm.bePeriod.selectedIndex==5) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
        
        <%-- type --%>
             if(EditForm.beType.selectedIndex==1) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.benefit.type","type1",sWebLanguage)%>";
        else if(EditForm.beType.selectedIndex==2) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.benefit.type","type2",sWebLanguage)%>";
        else if(EditForm.beType.selectedIndex==3) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.benefit.type","type3",sWebLanguage)%>";
                
        row.cells[5].innerHTML = "&nbsp;"+EditForm.beAmount.value;

        <%-- empty cell --%>
        row.cells[6].innerHTML = "&nbsp;";

        <%-- reset --%>
        clearBEFields();
        EditForm.ButtonUpdateBE.disabled = true;
      }
      else{
        alertDialog("web","beginMustComeBeforeEnd");
        EditForm.beBegin.focus();
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
    
      <%-- focus empty field --%>
           if(EditForm.beBegin.value.length==0) EditForm.beBegin.focus();
      else if(EditForm.bePeriod.selectedIndex==0) EditForm.bePeriod.focus();
      else if(EditForm.beType.selectedIndex==0) EditForm.beType.focus();
    }
  }
  
  <%-- ARE REQUIRED BE FIELDS FILLED --%>
  function areRequiredBEFieldsFilled(){
    return (EditForm.beBegin.value.length > 0 &&
            EditForm.bePeriod.selectedIndex > 0 &&
            EditForm.beType.selectedIndex > 0);
  }

  <%-- CLEAR BE FIELDS --%>
  function clearBEFields(){
    EditForm.beBegin.value = "";
    EditForm.beEnd.value = "";
    EditForm.bePeriod.selectedIndex = 0;
    EditForm.beType.selectedIndex = 0;        
    EditForm.beAmount.value = "";
  }

  <%-- CLEAR BENEFIT TABLE --%>
  function clearBETable(){
    var table = document.getElementById("tblBE");
    
    for(var i=table.rows.length; i>2; i--){
      table.deleteRow(i-1);
    }
  }
  
  <%-- DELETE BENEFIT --%>
  function deleteBE(rowid){
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){
      sBE = deleteRowFromArrayString(sBE,rowid.id);
      tblBE.deleteRow(rowid.rowIndex);
      clearBEFields();
    }
  }

  <%-- EDIT BENEFIT --%>
  function editBE(rowid){
    var row = getRowFromArrayString(sBE,rowid.id);

    EditForm.beBegin.value  = getCelFromRowString(row,0);
    EditForm.beEnd.value    = getCelFromRowString(row,1);
    EditForm.bePeriod.value = getCelFromRowString(row,2);
    
    <%-- type --%>
    var beType = getCelFromRowString(row,3);    
    for(var i=0; i<$("beType").options.length; i++){
      if($("beType").options[i].value==beType){
        $("beType").selectedIndex = i;
      }
    }
    
    EditForm.beAmount.value = getCelFromRowString(row,4);

    editBERowid = rowid;
    EditForm.ButtonUpdateBE.disabled = false;
  }

  <%-- JS 2 : BONUS FUNCTIONS -------------------------------------------------------------------%>
  var editBORowid = "", iBOIndex = 1, sBO = "";

  <%-- DISPLAY BONUSES --%>
  function displayBonuses(){
    sBO = document.getElementById("bonuses").value;
        
    if(sBO.indexOf("|") > -1){
      var sTmpBO = sBO;
      sBO = "";
      
      var sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpPercentage, sTmpAmount;
 
      while(sTmpBO.indexOf("$") > -1){
        sTmpBegin = "";
        sTmpEnd = "";
        sTmpPeriod = "";
        sTmpType = "";
        sTmpPercentage = "";
        sTmpAmount = "";

        if(sTmpBO.indexOf("|") > -1){
          sTmpBegin = sTmpBO.substring(0,sTmpBO.indexOf("|"));
          sTmpBO = sTmpBO.substring(sTmpBO.indexOf("|")+1);
        }
        
        if(sTmpBO.indexOf("|") > -1){
          sTmpEnd = sTmpBO.substring(0,sTmpBO.indexOf("|"));
          sTmpBO = sTmpBO.substring(sTmpBO.indexOf("|")+1);
        }
            
        if(sTmpBO.indexOf("|") > -1){
          sTmpPeriod = sTmpBO.substring(0,sTmpBO.indexOf("|"));
          sTmpBO = sTmpBO.substring(sTmpBO.indexOf("|")+1);
        }
            
        if(sTmpBO.indexOf("|") > -1){
          sTmpType = sTmpBO.substring(0,sTmpBO.indexOf("|"));
          sTmpBO = sTmpBO.substring(sTmpBO.indexOf("|")+1);
        }
            
        if(sTmpBO.indexOf("|") > -1){
          sTmpPercentage = sTmpBO.substring(0,sTmpBO.indexOf("|"));
          sTmpBO = sTmpBO.substring(sTmpBO.indexOf("|")+1);
        }

        if(sTmpBO.indexOf("$") > -1){
          sTmpAmount = sTmpBO.substring(0,sTmpBO.indexOf("$"));
          sTmpBO = sTmpBO.substring(sTmpBO.indexOf("$")+1);
        }

        sBO+= "rowBO"+iBOIndex+"="+sTmpBegin+"|"+
                                   sTmpEnd+"|"+
                                   sTmpPeriod+"|"+
                                   sTmpType+"|"+
                                   sTmpPercentage+"|"+
                                   sTmpAmount+"$";
        displayBonus(iBOIndex++,sTmpBegin,sTmpEnd,sTmpPeriod,sTmpType,sTmpPercentage,sTmpAmount);
      }
    }
  }
  
  <%-- DISPLAY BONUS --%>
  function displayBonus(iBOIndex,sBegin,sEnd,sPeriod,sType,sPercentage,sAmount){
    var tblBO = document.getElementById("tblBO"); // FF
    var tr = tblBO.insertRow(tblBO.rows.length);
    tr.id = "rowBO"+iBOIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteBO(rowBO"+iBOIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editBO(rowBO"+iBOIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+sBegin;
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.innerHTML = "&nbsp;"+sEnd;
    tr.appendChild(td);
                             
    <%-- period --%>
    td = tr.insertCell(3);
         if(sPeriod=="period1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
    else if(sPeriod=="period2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
    else if(sPeriod=="period3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
    else if(sPeriod=="period4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
    else if(sPeriod=="period5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
    tr.appendChild(td);
    
    <%-- type --%>
    td = tr.insertCell(4);
         if(sType=="type1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.bonus.type","type1",sWebLanguage)%>";
    else if(sType=="type2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.bonus.type","type2",sWebLanguage)%>";
    else if(sType=="type3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.bonus.type","type3",sWebLanguage)%>";
    tr.appendChild(td);

    <%-- percentage --%>
    td = tr.insertCell(5);
    td.innerHTML = "&nbsp;"+sPercentage;
    tr.appendChild(td);

    <%-- amount --%>
    td = tr.insertCell(6);
    td.innerHTML = "&nbsp;"+sAmount;
    tr.appendChild(td);
    
    <%-- empty cell --%>
    td = tr.insertCell(7);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iBOIndex);
  }
  
  <%-- ADD BONUS --%>
  function addBO(){
    if(areRequiredBOFieldsFilled()){
      var okToAdd = true;
      
      <%-- check dates --%>
      if(EditForm.boBegin.value.length > 0 && EditForm.boEnd.value.length > 0){
        var beginDate = makeDate(EditForm.boBegin.value),
            endDate   = makeDate(EditForm.boEnd.value);
        
        if(beginDate.getTime() > endDate.getTime()){
          okToAdd = false;
        }
      }
    
      if(okToAdd==true){
        iBOIndex++;

        <%-- update arrayString --%>
        sBO+="rowBO"+iBOIndex+"="+EditForm.boBegin.value+"|"+
                                  EditForm.boEnd.value+"|"+
                                  EditForm.boPeriod.value+"|"+
                                  EditForm.boType.value+"|"+
                                  EditForm.boPercentage.value+"|"+
                                  EditForm.boAmount.value+"$";

        var tblBO = document.getElementById("tblBO"); // FF
        var tr = tblBO.insertRow(tblBO.rows.length);
        tr.id = "rowBO"+iBOIndex;

        var td = tr.insertCell(0);
        td.innerHTML = "<a href='javascript:deleteBO(rowBO"+iBOIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                       "</a> "+
                       "<a href='javascript:editBO(rowBO"+iBOIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                       "</a>";
        tr.appendChild(td);

        td = tr.insertCell(1);
        td.innerHTML = "&nbsp;"+EditForm.boBegin.value;
        tr.appendChild(td);

        td = tr.insertCell(2);
        td.innerHTML = "&nbsp;"+EditForm.boEnd.value;
        tr.appendChild(td);
                                 
        <%-- period --%>
        td = tr.insertCell(3);
             if(EditForm.boPeriod.selectedIndex==1) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
        else if(EditForm.boPeriod.selectedIndex==2) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
        else if(EditForm.boPeriod.selectedIndex==3) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
        else if(EditForm.boPeriod.selectedIndex==4) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
        else if(EditForm.boPeriod.selectedIndex==5) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
        tr.appendChild(td);
        
        <%-- type --%>
        td = tr.insertCell(4);
             if(EditForm.boType.selectedIndex==1) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.bonus.type","type1",sWebLanguage)%>";
        else if(EditForm.boType.selectedIndex==2) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.bonus.type","type2",sWebLanguage)%>";
        else if(EditForm.boType.selectedIndex==3) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.bonus.type","type3",sWebLanguage)%>";
        tr.appendChild(td);

        <%-- percentage --%>
        td = tr.insertCell(5);
        td.innerHTML = "&nbsp;"+EditForm.boPercentage.value;
        tr.appendChild(td);
        
        <%-- amount --%>
        td = tr.insertCell(6);
        td.innerHTML = "&nbsp;"+EditForm.boAmount.value;
        tr.appendChild(td);
      
        <%-- empty cell --%>
        td = tr.insertCell(7);
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        setRowStyle(tr,iBOIndex);
      
        <%-- reset --%>
        clearBOFields()
        EditForm.ButtonUpdateBO.disabled = true;
      }
      else{
        alertDialog("web","beginMustComeBeforeEnd");
        EditForm.boBegin.focus();
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
        
      <%-- focus empty field --%>
           if(EditForm.boBegin.value.length==0) EditForm.boBegin.focus();
      else if(EditForm.boPeriod.selectedIndex==0) EditForm.boPeriod.focus();
      else if(EditForm.boType.selectedIndex==0) EditForm.boType.focus();
      else if(EditForm.boAmount.value.length==0) EditForm.boAmount.focus();
    }
    
    return true;
  }

  <%-- UPDATE BONUS --%>
  function updateBO(){
    if(areRequiredBOFieldsFilled()){
      var okToAdd = true;

      <%-- check dates --%>
      if(EditForm.boBegin.value.length > 0 && EditForm.boEnd.value.length > 0){
        var beginDate = makeDate(EditForm.boBegin.value),
            endDate   = makeDate(EditForm.boEnd.value);
        
        if(beginDate.getTime() > endDate.getTime()){
          okToAdd = false;
        }
      }
    
      if(okToAdd==true){        
        <%-- update arrayString --%>
        var newRow = editBORowid.id+"="+EditForm.boBegin.value+"|"+
                                        EditForm.boEnd.value+"|"+
                                        EditForm.boPeriod.value+"|"+
                                        EditForm.boType.value+"|"+
                                        EditForm.boPercentage.value+"|"+
                                        EditForm.boAmount.value;

        sBO = replaceRowInArrayString(sBO,newRow,editBORowid.id);

        <%-- update table object --%>
        var tblBO = document.getElementById("tblBO"); // FF
        var row = tblBO.rows[editBORowid.rowIndex];
        row.cells[0].innerHTML = "<a href='javascript:deleteBO("+editBORowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                                 "</a> "+
                                 "<a href='javascript:editBO("+editBORowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                                 "</a>";

        row.cells[1].innerHTML = "&nbsp;"+EditForm.boBegin.value;
        row.cells[2].innerHTML = "&nbsp;"+EditForm.boEnd.value;
                                 
        <%-- period --%>
             if(EditForm.boPeriod.selectedIndex==1) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
        else if(EditForm.boPeriod.selectedIndex==2) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
        else if(EditForm.boPeriod.selectedIndex==3) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
        else if(EditForm.boPeriod.selectedIndex==4) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
        else if(EditForm.boPeriod.selectedIndex==5) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
        
        <%-- type --%>
             if(EditForm.boType.selectedIndex==1) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.bonus.type","type1",sWebLanguage)%>";
        else if(EditForm.boType.selectedIndex==2) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.bonus.type","type2",sWebLanguage)%>";
        else if(EditForm.boType.selectedIndex==3) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.bonus.type","type3",sWebLanguage)%>";

        row.cells[5].innerHTML = "&nbsp;"+EditForm.boPercentage.value;
        row.cells[6].innerHTML = "&nbsp;"+EditForm.boAmount.value;

        <%-- empty cell --%>
        row.cells[7].innerHTML = "&nbsp;";

        <%-- reset --%>
        clearBOFields();
        EditForm.ButtonUpdateBO.disabled = true;
      }
      else{
        alertDialog("web","beginMustComeBeforeEnd");
        EditForm.boBegin.focus();
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
    
      <%-- focus empty field --%>
           if(EditForm.boBegin.value.length==0) EditForm.boBegin.focus();
      else if(EditForm.boPeriod.selectedIndex==0) EditForm.boPeriod.focus();
      else if(EditForm.boType.selectedIndex==0) EditForm.boType.focus();
      else if(EditForm.boAmount.value.length==0) EditForm.boAmount.focus();
    }
  }
  
  <%-- ARE REQUIRED BO FIELDS FILLED --%>
  function areRequiredBOFieldsFilled(){
    return (EditForm.boBegin.value.length > 0 &&
            EditForm.boPeriod.selectedIndex > 0 &&
            EditForm.boType.selectedIndex > 0 &&
            EditForm.boAmount.value.length > 0);
  }

  <%-- CLEAR BO FIELDS --%>
  function clearBOFields(){
    EditForm.boBegin.value = "";
    EditForm.boEnd.value = "";
    EditForm.boPeriod.selectedIndex = 0;
    EditForm.boType.selectedIndex = 0;
    EditForm.boPercentage.value = "";        
    EditForm.boAmount.value = "";
  }

  <%-- CLEAR BONUS TABLE --%>
  function clearBOTable(){
    var table = document.getElementById("tblBO");
    
    for(var i=table.rows.length; i>2; i--){
      table.deleteRow(i-1);
    }
  }
  
  <%-- DELETE BONUS --%>
  function deleteBO(rowid){
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){
      sBO = deleteRowFromArrayString(sBO,rowid.id);
      tblBO.deleteRow(rowid.rowIndex);
      clearBOFields();
    }
  }

  <%-- EDIT BONUS --%>
  function editBO(rowid){
    var row = getRowFromArrayString(sBO,rowid.id);

    EditForm.boBegin.value  = getCelFromRowString(row,0);
    EditForm.boEnd.value    = getCelFromRowString(row,1);
    EditForm.boPeriod.value = getCelFromRowString(row,2);
    
    <%-- type --%>
    var boType = getCelFromRowString(row,3);    
    for(var i=0; i<$("boType").options.length; i++){
      if($("boType").options[i].value==boType){
        $("boType").selectedIndex = i;
      }
    }

    EditForm.boPercentage.value = getCelFromRowString(row,4);
    EditForm.boAmount.value = getCelFromRowString(row,5);

    editBORowid = rowid;
    EditForm.ButtonUpdateBO.disabled = false;
  }

  <%-- JS 3 : OTHER INCOME FUNCTIONS ------------------------------------------------------------%>
  var editOIRowid = "", iOIIndex = 1, sOI = "";

  <%-- DISPLAY OTHER INCOMES --%>
  function displayOtherIncomes(){
    sOI = document.getElementById("otherIncome").value;
        
    if(sOI.indexOf("|") > -1){
      var sTmpOI = sOI;
      sOI = "";
      
      var sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpAmount;
 
      while(sTmpOI.indexOf("$") > -1){
        sTmpBegin = "";
        sTmpEnd = "";
        sTmpPeriod = "";
        sTmpType = "";
        sTmpAmount = "";

        if(sTmpOI.indexOf("|") > -1){
          sTmpBegin = sTmpOI.substring(0,sTmpOI.indexOf("|"));
          sTmpOI = sTmpOI.substring(sTmpOI.indexOf("|")+1);
        }
        
        if(sTmpOI.indexOf("|") > -1){
          sTmpEnd = sTmpOI.substring(0,sTmpOI.indexOf("|"));
          sTmpOI = sTmpOI.substring(sTmpOI.indexOf("|")+1);
        }
            
        if(sTmpOI.indexOf("|") > -1){
          sTmpPeriod = sTmpOI.substring(0,sTmpOI.indexOf("|"));
          sTmpOI = sTmpOI.substring(sTmpOI.indexOf("|")+1);
        }
            
        if(sTmpOI.indexOf("|") > -1){
          sTmpType = sTmpOI.substring(0,sTmpOI.indexOf("|"));
          sTmpOI = sTmpOI.substring(sTmpOI.indexOf("|")+1);
        }

        if(sTmpOI.indexOf("$") > -1){
          sTmpAmount = sTmpOI.substring(0,sTmpOI.indexOf("$"));
          sTmpOI = sTmpOI.substring(sTmpOI.indexOf("$")+1);
        }

        sOI+= "rowOI"+iOIIndex+"="+sTmpBegin+"|"+
                                   sTmpEnd+"|"+
                                   sTmpPeriod+"|"+
                                   sTmpType+"|"+
                                   sTmpAmount+"$";
        displayOtherIncome(iOIIndex++,sTmpBegin,sTmpEnd,sTmpPeriod,sTmpType,sTmpAmount);
      }
    }
  }
  
  <%-- DISPLAY OTHER INCOME --%>
  function displayOtherIncome(iOIIndex,sBegin,sEnd,sPeriod,sType,sAmount){
    var tblOI = document.getElementById("tblOI"); // FF
    var tr = tblOI.insertRow(tblOI.rows.length);
    tr.id = "rowOI"+iOIIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteOI(rowOI"+iOIIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editOI(rowOI"+iOIIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+sBegin;
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.innerHTML = "&nbsp;"+sEnd;
    tr.appendChild(td);
                             
    <%-- period --%>
    td = tr.insertCell(3);
         if(sPeriod=="period1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
    else if(sPeriod=="period2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
    else if(sPeriod=="period3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
    else if(sPeriod=="period4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
    else if(sPeriod=="period5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
    tr.appendChild(td);
    
    <%-- type --%>
    td = tr.insertCell(4);
         if(sType=="type1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type1",sWebLanguage)%>";
    else if(sType=="type2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type2",sWebLanguage)%>";
    else if(sType=="type3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type3",sWebLanguage)%>";
    tr.appendChild(td);

    <%-- amount --%>
    td = tr.insertCell(5);
    td.innerHTML = "&nbsp;"+sAmount;
    tr.appendChild(td);
        
    <%-- empty cell --%>
    td = tr.insertCell(6);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iOIIndex);
  }
  
  <%-- ADD OTHER INCOME --%>
  function addOI(){
    if(areRequiredOIFieldsFilled()){
      var okToAdd = true;
      
      <%-- check dates --%>
      if(EditForm.oiBegin.value.length > 0 && EditForm.oiEnd.value.length > 0){
        var beginDate = makeDate(EditForm.oiBegin.value),
            endDate   = makeDate(EditForm.oiEnd.value);
        
        if(beginDate.getTime() > endDate.getTime()){
          okToAdd = false;
        }
      }
    
      if(okToAdd==true){
        iOIIndex++;

        <%-- update arrayString --%>
        sOI+="rowOI"+iOIIndex+"="+EditForm.oiBegin.value+"|"+
                                  EditForm.oiEnd.value+"|"+
                                  EditForm.oiPeriod.value+"|"+
                                  EditForm.oiType.value+"|"+
                                  EditForm.oiAmount.value+"$";

	    var tblOI = document.getElementById("tblOI"); // FF
        var tr = tblOI.insertRow(tblOI.rows.length);
        tr.id = "rowOI"+iOIIndex;

        var td = tr.insertCell(0);
        td.innerHTML = "<a href='javascript:deleteOI(rowOI"+iOIIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                       "</a> "+
                       "<a href='javascript:editOI(rowOI"+iOIIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                       "</a>";
        tr.appendChild(td);

        td = tr.insertCell(1);
        td.innerHTML = "&nbsp;"+EditForm.oiBegin.value;
        tr.appendChild(td);

        td = tr.insertCell(2);
        td.innerHTML = "&nbsp;"+EditForm.oiEnd.value;
        tr.appendChild(td);
                                 
        <%-- period --%>
        td = tr.insertCell(3);
             if(EditForm.oiPeriod.selectedIndex==1) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
        else if(EditForm.oiPeriod.selectedIndex==2) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
        else if(EditForm.oiPeriod.selectedIndex==3) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
        else if(EditForm.oiPeriod.selectedIndex==4) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
        else if(EditForm.oiPeriod.selectedIndex==5) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
        tr.appendChild(td);
        
        <%-- type --%>
        td = tr.insertCell(4);
             if(EditForm.oiType.selectedIndex==1) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type1",sWebLanguage)%>";
        else if(EditForm.oiType.selectedIndex==2) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type2",sWebLanguage)%>";
        else if(EditForm.oiType.selectedIndex==3) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type3",sWebLanguage)%>";
        tr.appendChild(td);

        <%-- amount --%>
        td = tr.insertCell(5);
        td.innerHTML = "&nbsp;"+EditForm.oiAmount.value;
        tr.appendChild(td);
      
        <%-- empty cell --%>
        td = tr.insertCell(6);
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        setRowStyle(tr,iOIIndex);
      
        <%-- reset --%>
        clearOIFields()
        EditForm.ButtonUpdateOI.disabled = true;
      }
      else{
        alertDialog("web","beginMustComeBeforeEnd");
        EditForm.oiBegin.focus();
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
        
      <%-- focus empty field --%>
           if(EditForm.oiBegin.value.length==0) EditForm.oiBegin.focus();
      else if(EditForm.oiType.selectedIndex==0) EditForm.oiType.focus();
      else if(EditForm.oiAmount.value.length==0) EditForm.oiAmount.focus();
    }
    
    return true;
  }

  <%-- UPDATE OTHER INCOME --%>
  function updateOI(){
    if(areRequiredOIFieldsFilled()){
      var okToAdd = true;

      <%-- check dates --%>
      if(EditForm.oiBegin.value.length > 0 && EditForm.oiEnd.value.length > 0){
        var beginDate = makeDate(EditForm.oiBegin.value),
            endDate   = makeDate(EditForm.oiEnd.value);
        
        if(beginDate.getTime() > endDate.getTime()){
          okToAdd = false;
        }
      }
    
      if(okToAdd==true){        
        <%-- update arrayString --%>
        var newRow = editOIRowid.id+"="+EditForm.oiBegin.value+"|"+
                                        EditForm.oiEnd.value+"|"+
                                        EditForm.oiPeriod.value+"|"+
                                        EditForm.oiType.value+"|"+
                                        EditForm.oiAmount.value;

        sOI = replaceRowInArrayString(sOI,newRow,editOIRowid.id);

        <%-- update table object --%>
        var tblOI = document.getElementById("tblOI"); // FF
        var row = tblOI.rows[editOIRowid.rowIndex];
        row.cells[0].innerHTML = "<a href='javascript:deleteOI("+editOIRowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                                 "</a> "+
                                 "<a href='javascript:editOI("+editOIRowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                                 "</a>";

        row.cells[1].innerHTML = "&nbsp;"+EditForm.oiBegin.value;
        row.cells[2].innerHTML = "&nbsp;"+EditForm.oiEnd.value;
                                 
        <%-- period --%>
             if(EditForm.oiPeriod.selectedIndex==1) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
        else if(EditForm.oiPeriod.selectedIndex==2) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
        else if(EditForm.oiPeriod.selectedIndex==3) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
        else if(EditForm.oiPeriod.selectedIndex==4) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
        else if(EditForm.oiPeriod.selectedIndex==5) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
        
        <%-- type --%>
             if(EditForm.oiType.selectedIndex==1) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type1",sWebLanguage)%>";
        else if(EditForm.oiType.selectedIndex==2) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type2",sWebLanguage)%>";
        else if(EditForm.oiType.selectedIndex==3) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type3",sWebLanguage)%>";
                
        row.cells[5].innerHTML = "&nbsp;"+EditForm.oiAmount.value;

        <%-- empty cell --%>
        row.cells[6].innerHTML = "&nbsp;";

        <%-- reset --%>
        clearOIFields();
        EditForm.ButtonUpdateOI.disabled = true;
      }
      else{
        alertDialog("web","beginMustComeBeforeEnd");
        EditForm.oiBegin.focus();
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
    
      <%-- focus empty field --%>
           if(EditForm.oiBegin.value.length==0) EditForm.oiBegin.focus();
      else if(EditForm.oiType.selectedIndex==0) EditForm.oiType.focus();
      else if(EditForm.oiAmount.value.length==0) EditForm.oiAmount.focus();
    }
  }
  
  <%-- ARE REQUIRED OI FIELDS FILLED --%>
  function areRequiredOIFieldsFilled(){
    return (EditForm.oiBegin.value.length > 0 &&
            EditForm.oiType.selectedIndex > 0 &&
            EditForm.oiAmount.value.length > 0);
  }

  <%-- CLEAR OI FIELDS --%>
  function clearOIFields(){
    EditForm.oiBegin.value = "";
    EditForm.oiEnd.value = "";
    EditForm.oiPeriod.selectedIndex = 0;
    EditForm.oiType.selectedIndex = 0;        
    EditForm.oiAmount.value = "";
  }

  <%-- CLEAR OTHER INCOME TABLE --%>
  function clearOITable(){
    var table = document.getElementById("tblOI");
    
    for(var i=table.rows.length; i>2; i--){
      table.deleteRow(i-1);
    }
  }
  
  <%-- DELETE OTHER INCOME --%>
  function deleteOI(rowid){
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){
      sOI = deleteRowFromArrayString(sOI,rowid.id);
      tblOI.deleteRow(rowid.rowIndex);
      clearOIFields();
    }
  }

  <%-- EDIT OTHER INCOME --%>
  function editOI(rowid){
    var row = getRowFromArrayString(sOI,rowid.id);

    EditForm.oiBegin.value  = getCelFromRowString(row,0);
    EditForm.oiEnd.value    = getCelFromRowString(row,1);
    EditForm.oiPeriod.value = getCelFromRowString(row,2);
    
    <%-- type --%>
    var oiType = getCelFromRowString(row,3);    
    for(var i=0; i<$("oiType").options.length; i++){
      if($("oiType").options[i].value==oiType){
        $("oiType").selectedIndex = i;
      }
    }
    
    EditForm.oiAmount.value = getCelFromRowString(row,4);

    editOIRowid = rowid;
    EditForm.ButtonUpdateOI.disabled = false;
  }

  <%-- JS 4 : DEDUCTION FUNCTIONS ---------------------------------------------------------------%>
  var editDERowid = "", iDEIndex = 1, sDE = "";

  <%-- DISPLAY DEDUCTIONS --%>
  function displayDeductions(){
    sDE = document.getElementById("deductions").value;
        
    if(sDE.indexOf("|") > -1){
      var sTmpDE = sDE;
      sDE = "";
      
      var sTmpBegin, sTmpEnd, sTmpPeriod, sTmpType, sTmpAmount;
 
      while(sTmpDE.indexOf("$") > -1){
        sTmpBegin = "";
        sTmpEnd = "";
        sTmpPeriod = "";
        sTmpType = "";
        sTmpAmount = "";

        if(sTmpDE.indexOf("|") > -1){
          sTmpBegin = sTmpDE.substring(0,sTmpDE.indexOf("|"));
          sTmpDE = sTmpDE.substring(sTmpDE.indexOf("|")+1);
        }
        
        if(sTmpDE.indexOf("|") > -1){
          sTmpEnd = sTmpDE.substring(0,sTmpDE.indexOf("|"));
          sTmpDE = sTmpDE.substring(sTmpDE.indexOf("|")+1);
        }
            
        if(sTmpDE.indexOf("|") > -1){
          sTmpPeriod = sTmpDE.substring(0,sTmpDE.indexOf("|"));
          sTmpDE = sTmpDE.substring(sTmpDE.indexOf("|")+1);
        }
            
        if(sTmpDE.indexOf("|") > -1){
          sTmpType = sTmpDE.substring(0,sTmpDE.indexOf("|"));
          sTmpDE = sTmpDE.substring(sTmpDE.indexOf("|")+1);
        }

        if(sTmpDE.indexOf("$") > -1){
          sTmpAmount = sTmpDE.substring(0,sTmpDE.indexOf("$"));
          sTmpDE = sTmpDE.substring(sTmpDE.indexOf("$")+1);
        }

        sDE+= "rowDE"+iDEIndex+"="+sTmpBegin+"|"+
                                   sTmpEnd+"|"+
                                   sTmpPeriod+"|"+
                                   sTmpType+"|"+
                                   sTmpAmount+"$";
        displayDeduction(iDEIndex++,sTmpBegin,sTmpEnd,sTmpPeriod,sTmpType,sTmpAmount);
      }
    }
  }
  
  <%-- DISPLAY DEDUCTION --%>
  function displayDeduction(iDEIndex,sBegin,sEnd,sPeriod,sType,sAmount){
    var tblDE = document.getElementById("tblDE"); // FF
    var tr = tblDE.insertRow(tblDE.rows.length);
    tr.id = "rowDE"+iDEIndex;

    var td = tr.insertCell(0);
    td.innerHTML = "<a href='javascript:deleteDE(rowDE"+iDEIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0' style='vertical-align:-2px;'>"+
                   "</a> "+
                   "<a href='javascript:editDE(rowDE"+iDEIndex+")'>"+
                    "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0' style='vertical-align:-3px;'>"+
                   "</a>";
    tr.appendChild(td);

    td = tr.insertCell(1);
    td.innerHTML = "&nbsp;"+sBegin;
    tr.appendChild(td);

    td = tr.insertCell(2);
    td.innerHTML = "&nbsp;"+sEnd;
    tr.appendChild(td);
                             
    <%-- period --%>
    td = tr.insertCell(3);
         if(sBegin=="period1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
    else if(sBegin=="period2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
    else if(sBegin=="period3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
    else if(sBegin=="period4") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
    else if(sBegin=="period5") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
    tr.appendChild(td);
    
    <%-- type --%>
    td = tr.insertCell(4);
         if(sType=="type1") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.deduction.type","type1",sWebLanguage)%>";
    else if(sType=="type2") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.deduction.type","type2",sWebLanguage)%>";
    else if(sType=="type3") td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.deduction.type","type3",sWebLanguage)%>";
    tr.appendChild(td);

    <%-- amount --%>
    td = tr.insertCell(5);
    td.innerHTML = "&nbsp;"+sAmount;
    tr.appendChild(td);
        
    <%-- empty cell --%>
    td = tr.insertCell(6);
    td.innerHTML = "&nbsp;";
    tr.appendChild(td);
    
    setRowStyle(tr,iDEIndex);
  }
  
  <%-- ADD DEDUCTION --%>
  function addDE(){
    if(areRequiredDEFieldsFilled()){
      var okToAdd = true;
      
      <%-- check dates --%>
      if(EditForm.deBegin.value.length > 0 && EditForm.deEnd.value.length > 0){
        var beginDate = makeDate(EditForm.deBegin.value),
            endDate   = makeDate(EditForm.deEnd.value);
        
        if(beginDate.getTime() > endDate.getTime()){
          okToAdd = false;
        }
      }
    
      if(okToAdd==true){
        iDEIndex++;

        <%-- update arrayString --%>
        sDE+="rowDE"+iDEIndex+"="+EditForm.deBegin.value+"|"+
                                  EditForm.deEnd.value+"|"+
                                  EditForm.dePeriod.value+"|"+
                                  EditForm.deType.value+"|"+
                                  EditForm.deAmount.value+"$";

        var tblDE = document.getElementById("tblDE"); // FF
        var tr = tblDE.insertRow(tblDE.rows.length);
        tr.id = "rowDE"+iDEIndex;

        var td = tr.insertCell(0);
        td.innerHTML = "<a href='javascript:deleteDE(rowDE"+iDEIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                       "</a> "+
                       "<a href='javascript:editDE(rowDE"+iDEIndex+")'>"+
                        "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                       "</a>";
        tr.appendChild(td);

        td = tr.insertCell(1);
        td.innerHTML = "&nbsp;"+EditForm.deBegin.value;
        tr.appendChild(td);

        td = tr.insertCell(2);
        td.innerHTML = "&nbsp;"+EditForm.deEnd.value;
        tr.appendChild(td);
                                 
        <%-- period --%>
        td = tr.insertCell(3);
             if(EditForm.dePeriod.selectedIndex==1) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
        else if(EditForm.dePeriod.selectedIndex==2) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
        else if(EditForm.dePeriod.selectedIndex==3) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
        else if(EditForm.dePeriod.selectedIndex==4) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
        else if(EditForm.dePeriod.selectedIndex==5) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
        tr.appendChild(td);
        
        <%-- type --%>
        td = tr.insertCell(4);
             if(EditForm.deType.selectedIndex==1) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.deduction.type","type1",sWebLanguage)%>";
        else if(EditForm.deType.selectedIndex==2) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.deduction.type","type2",sWebLanguage)%>";
        else if(EditForm.deType.selectedIndex==3) td.innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.deduction.type","type3",sWebLanguage)%>";
        tr.appendChild(td);

        <%-- amount --%>
        td = tr.insertCell(5);
        td.innerHTML = "&nbsp;"+EditForm.deAmount.value;
        tr.appendChild(td);
      
        <%-- empty cell --%>
        td = tr.insertCell(6);
        td.innerHTML = "&nbsp;";
        tr.appendChild(td);

        setRowStyle(tr,iDEIndex);
      
        <%-- reset --%>
        clearDEFields()
        EditForm.ButtonUpdateDE.disabled = true;
      }
      else{
        alertDialog("web","beginMustComeBeforeEnd");
        EditForm.deBegin.focus();
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
        
      <%-- focus empty field --%>
           if(EditForm.deBegin.value.length==0) EditForm.deBegin.focus();
      else if(EditForm.deType.selectedIndex==0) EditForm.deType.focus();
      else if(EditForm.deAmount.value.length==0) EditForm.deAmount.focus();
    }
    
    return true;
  }

  <%-- UPDATE DEDUCTION --%>
  function updateDE(){
    if(areRequiredDEFieldsFilled()){
      var okToAdd = true;

      <%-- check dates --%>
      if(EditForm.deBegin.value.length > 0 && EditForm.deEnd.value.length > 0){
        var beginDate = makeDate(EditForm.deBegin.value),
            endDate   = makeDate(EditForm.deEnd.value);
        
        if(beginDate.getTime() > endDate.getTime()){
          okToAdd = false;
        }
      }
    
      if(okToAdd==true){        
        <%-- update arrayString --%>
        var newRow = editDERowid.id+"="+EditForm.deBegin.value+"|"+
                                        EditForm.deEnd.value+"|"+
                                        EditForm.dePeriod.value+"|"+
                                        EditForm.deType.value+"|"+
                                        EditForm.deAmount.value;

        sDE = replaceRowInArrayString(sDE,newRow,editDERowid.id);

        <%-- update table object --%>
        var tblDE = document.getElementById("tblDE"); // FF
        var row = tblDE.rows[editDERowid.rowIndex];
        row.cells[0].innerHTML = "<a href='javascript:deleteDE("+editDERowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif' alt='<%=getTranNoLink("web","delete",sWebLanguage)%>' border='0'>"+
                                 "</a> "+
                                 "<a href='javascript:editDE("+editDERowid.id+")'>"+
                                  "<img src='<%=sCONTEXTPATH%>/_img/icons/icon_edit.gif' alt='<%=getTranNoLink("web","edit",sWebLanguage)%>' border='0'>"+
                                 "</a>";

        row.cells[1].innerHTML = "&nbsp;"+EditForm.deBegin.value;
        row.cells[2].innerHTML = "&nbsp;"+EditForm.deEnd.value;
                                 
        <%-- period --%>
             if(EditForm.dePeriod.selectedIndex==1) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period1",sWebLanguage)%>";
        else if(EditForm.dePeriod.selectedIndex==2) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period2",sWebLanguage)%>";
        else if(EditForm.dePeriod.selectedIndex==3) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period3",sWebLanguage)%>";
        else if(EditForm.dePeriod.selectedIndex==4) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period4",sWebLanguage)%>";
        else if(EditForm.dePeriod.selectedIndex==5) row.cells[3].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.period","period5",sWebLanguage)%>";
        
        <%-- type --%>
             if(EditForm.deType.selectedIndex==1) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type1",sWebLanguage)%>";
        else if(EditForm.deType.selectedIndex==2) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type2",sWebLanguage)%>";
        else if(EditForm.deType.selectedIndex==3) row.cells[4].innerHTML = "&nbsp;<%=getTranNoLink("hr.salary.otherincome.type","type3",sWebLanguage)%>";
                
        row.cells[5].innerHTML = "&nbsp;"+EditForm.deAmount.value;

        <%-- empty cell --%>
        row.cells[6].innerHTML = "&nbsp;";

        <%-- reset --%>
        clearDEFields();
        EditForm.ButtonUpdateDE.disabled = true;
      }
      else{
        alertDialog("web","beginMustComeBeforeEnd");
        EditForm.deBegin.focus();
      }
    }
    else{
      alertDialog("web.manage","dataMissing");
    
      <%-- focus empty field --%>
           if(EditForm.deBegin.value.length==0) EditForm.deBegin.focus();
      else if(EditForm.deType.selectedIndex==0) EditForm.deType.focus();
      else if(EditForm.deAmount.value.length==0) EditForm.deAmount.focus();
    }
  }
  
  <%-- ARE REQUIRED DE FIELDS FILLED --%>
  function areRequiredDEFieldsFilled(){
    return (EditForm.deBegin.value.length > 0 &&
            EditForm.deType.selectedIndex > 0 &&
            EditForm.deAmount.value.length > 0);
  }

  <%-- CLEAR DE FIELDS --%>
  function clearDEFields(){
    EditForm.deBegin.value = "";
    EditForm.deEnd.value = "";
    EditForm.dePeriod.selectedIndex = 0;
    EditForm.deType.selectedIndex = 0;        
    EditForm.deAmount.value = "";
  }

  <%-- CLEAR DEDUCTION TABLE --%>
  function clearDETable(){
    var table = document.getElementById("tblDE");
    
    for(var i=table.rows.length; i>2; i--){
      table.deleteRow(i-1);
    }
  }
  
  <%-- DELETE DEDUCTION --%>
  function deleteDE(rowid){
    var answer = yesnoDialog("web","areYouSureToDelete");
    if(answer==1){
      sDE = deleteRowFromArrayString(sDE,rowid.id);
      tblDE.deleteRow(rowid.rowIndex);
      clearDEFields();
    }
  }

  <%-- EDIT DEDUCTION --%>
  function editDE(rowid){
    var row = getRowFromArrayString(sDE,rowid.id);

    EditForm.deBegin.value  = getCelFromRowString(row,0);
    EditForm.deEnd.value    = getCelFromRowString(row,1);
    EditForm.dePeriod.value = getCelFromRowString(row,2);
    
    <%-- type --%>
    var deType = getCelFromRowString(row,3);    
    for(var i=0; i<$("deType").options.length; i++){
      if($("deType").options[i].value==deType){
        $("deType").selectedIndex = i;
      }
    }
    
    EditForm.deAmount.value = getCelFromRowString(row,4);

    editDERowid = rowid;
    EditForm.ButtonUpdateDE.disabled = false;
  }
  
  <%-- disable all update buttons at load --%>
  EditForm.ButtonUpdateBE.disabled = true;
  EditForm.ButtonUpdateBO.disabled = true;
  EditForm.ButtonUpdateOI.disabled = true;
  EditForm.ButtonUpdateDE.disabled = true;
    
  loadSalaries();
  EditForm.contractName.focus();
  resizeAllTextareas(8);
</script>