<%@page import="java.util.*,
                be.openclinic.hr.SalaryCalculationCode"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="../../hr/includes/commonFunctions.jsp"%>
<%=checkPermission("hr.manageDefaultSalaryCodes","select",activeUser)%>

<%=sJSSTRINGFUNCTIONS%>
<%=sJSDATE%>
<%=sJSSORTTABLE%>

<%!
    //--- PARSE CODES -----------------------------------------------------------------------------
    private Vector parseCodes(String sSalCalUID, String sCodes){
    	Vector codes = new Vector();
    	
    	String[] codesAsString = sCodes.split("\\$");
    	SalaryCalculationCode code;
    	String[] codeAsString;
    	
    	for(int i=0; i<codesAsString.length; i++){
    		codeAsString = codesAsString[i].split("\\|");
    		
    		code = new SalaryCalculationCode();
    		code.setUid("-1"); // codes are always deleted and re-inserted
    		code.calculationUid = sSalCalUID;
     		code.duration = Float.parseFloat(codeAsString[0].replace(",",".")); 
    	    code.code = codeAsString[1]; 
    	    //code.label = codeAsString[2];
    		
    		codes.add(code);
    	}

    	return codes;    	
    }
%>

<%    
    String sAction = checkString(request.getParameter("Action"));
    
    String sCodes = checkString(request.getParameter("CalculationCodes"));
    
    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n********* hr/management/manageDefaultSalaryCodes.jsp ********");
        Debug.println("sAction : "+sAction);
        Debug.println("sCodes : "+sCodes+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
    
    String sMsg = "";
    
    //*** SAVE CODES ******************************************************************************
    if(sAction.equalsIgnoreCase("saveCodes")){
    	/*
        // parse codes
        calculation.codes = parseCodes(sSalCalUID,sCodes);
        Debug.println("Saving "+calculation.codes.size()+" codes");
        
        calculation.store(activeUser.userid); // save again, the calculation now contains codes
        */
    } 
    //*** DELETE **********************************************************************************
    else if(sAction.equalsIgnoreCase("delete")){
        //SalaryCalculation.delete(sSalCalUID);            
    }
    
    
	String sCCConcatValues = "";
%>

<script src="<%=sCONTEXTPATH%>/hr/includes/commonFunctions.js"></script> 

<form name="EditForm" method="post" action="<c:url value='/main.do'/>?Page=hr/management/manageDefaultSalaryCodes.jsp&ts=<%=getTs()%>" onkeydown="if(enterEvent(event,13)){saveCodes();return false;}">
    <input type="hidden" name="Action" value="<">
                
    <%=writeTableHeader("web","salaryCalculations",sWebLanguage)%>

    <table width="100%" class="list" cellspacing="0" cellpadding="0" style="border:none;">

        <%-- 3 - calculation codes --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("hr.salarycalculations","codes",sWebLanguage))%></td>
            <td class="admin2">
                <table id="tblCC" cellpadding="0" cellspacing="0" width="98%" class="sortable" headerRowCount="2" style="border:1px solid #ccc;">
                    <%-- a - header --%>
                    <tr class="admin">
                        <td width="20">&nbsp;</td>
                        <td width="100" style="padding-left:1px;"><%=getTran("web","duration",sWebLanguage)%></td>
                        <td width="380" style="padding-left:1px;"><%=getTran("web","code",sWebLanguage)%></td>
                    </tr>
                    
                    <%-- b - add row --%>
                    <tr>
                        <%-- empty --%>
                        <td class="admin">&nbsp;</td>
                                                        
                        <%-- duration (hours) --%>
                        <td class="admin" nowrap>
                            <input type="text" class="text" id="addDuration" name="addDuration" size="3" maxLength="3" onKeyUp="removeTrailingZeros(this);if(!isInteger(this))this.value='';"></input>&nbsp;<%=getTran("web","hours",sWebLanguage)%>
                        </td>
                        
                        <%-- code (and label) --%>
                        <td class="admin">
                            <input type="text" class="text" id="codeAndLabel" name="codeAndLabel" size="30" readonly></input>
                            
                            <%-- code icon --%> 
                            <img src="<c:url value='_img/icons/icon_questionmark.gif'/>" class="link" style="border:1px solid #aaa;background:#eee;" alt="<%=getTranNoLink("hr.salarycalculations","searchCodes",sWebLanguage)%>" onclick="searchCalculationCodes();">
                            
                            <%-- add button --%>
                            <%
                                if(activeUser.getAccessRight("hr.salarycalculations.add")){
                                    %><input class="button" type="button" name="buttonAdd" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addCC();">&nbsp;<%
                                }
                            %>
                        </td>
                        
                        <%-- hidden code --%>
                        <input type="hidden" class="text" id="addCode" name="addCode"></input>
                    </tr>
                    
                    <%-- c - list codes --%>
                    <%
                         Vector savedCodes = calculation.codes;
                         String sCC = "";
                         int iCCIndex = 0;
                          
                         if(savedCodes.size() > 0){
                             Hashtable hSort = new Hashtable();
                             SalaryCalculationCode savedCode;
                             
                             // sorted on salary.beginDate
                             for(int i=0; i<savedCodes.size(); i++){
                            	 savedCode = (SalaryCalculationCode)savedCodes.get(i);
                            	 
                            	 sCCConcatValues+= savedCode.duration+"|"+savedCode.code+"|"+getTranNoLink("salaryCalculationCode",savedCode.code,sWebLanguage)+"$";
                             }
                         }                   
                    %>                          
                </table>
                
                <%-- HIDDEN FIELDS --%>
                <input type="hidden" id="calculationCodes" name="calculationCodes" value="<%=sCCConcatValues%>">
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
        
    <%
        // display message, if any
        if(sMsg.length() > 0){
        	%><br><%=sMsg%><br><%
        }
    %>     
</form>
    
<script>  
  <%-- SAVE CODES --%>
  function saveCodes(){
    var okToSubmit = true;

    /*
    if(document.getElementById("addDuration").value.length > 0 && document.getElementById("addCode").value.length > 0){
      if(yesnoDialog("web","firstAddData")==1){
        okToSubmit = addCC();
      }
    }
    */
    
    if(okToSubmit){
      EditForm.buttonSave.disabled = true;
      EditForm.buttonBack.disabled = true;
      EditForm.Action.value = "saveCodes";
      
      var url = "<c:url value='/hr/ajax/salarycalculations/repeatCalculation.jsp'/>?ts="+new Date().getTime();
      var params = "Action=save"+
                   "&PersonId="+document.getElementById("PersonId").value+
                   "&Begin="+document.getElementById("Begin").value+
                   "&End="+document.getElementById("End").value+
                   "&CalculationCodes="+removeTRIndexes(sCC);

      new Ajax.Request(url,{
        evalScripts: true,
        parameters: params,
        onComplete: displayClientMsgDataIsSaved()
      });
    }
  }
</script>
