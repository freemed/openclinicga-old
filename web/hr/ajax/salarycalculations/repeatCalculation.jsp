<%@page import="java.util.*,
                be.openclinic.hr.SalaryCalculation,
                be.openclinic.hr.SalaryCalculationCode,
                be.mxs.common.util.system.HTMLEntities,
                java.util.Date"%>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("hr.salarycalculations","select",activeUser)%>

<%!
    /*
	//--- ADD DAYS --------------------------------------------------------------------------------
	private java.util.Date addDays(java.util.Date date, int days){
	    Calendar calendar = Calendar.getInstance();
	    
	    calendar.setTime(date);
	    calendar.set(Calendar.HOUR_OF_DAY,0);
	    calendar.set(Calendar.MINUTE,0);
	    calendar.set(Calendar.SECOND,0);
	    calendar.set(Calendar.MILLISECOND,0);
	    
	    calendar.add(Calendar.DAY_OF_YEAR,days);
	    
	    return calendar.getTime();
	}

	//--- DAY DIFF --------------------------------------------------------------------------------
	private int dayDiff(java.util.Date date1, java.util.Date date2){
	    int dayDiff = 0;
	    
	    // oldest date first
	    java.util.Date firstDate, secondDate;
	    if(date1.getTime() > date2.getTime()){
	        firstDate = date2;
	        secondDate = date1;
	    }
	    else{
	        firstDate = date1;
	        secondDate = date2;
	    }
	    
	    // count difference
	    while(secondDate.getTime() > firstDate.getTime()){
	        secondDate = addDays(secondDate,-1);
	        dayDiff++;
	    }
	    
	    return dayDiff;
	}
	*/

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

    String sBegin           = checkString(request.getParameter("Begin")),
           sEnd             = checkString(request.getParameter("End")),
           sType            = checkString(request.getParameter("Type")),
           sIncludeWeekends = checkString(request.getParameter("IncludeWeekends")),
           sPersonId        = checkString(request.getParameter("PersonId")),
           sCodes           = checkString(request.getParameter("CalculationCodes"));
    
    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******* hr/ajax/salarycalculation/repeatCalculation.jsp ******");
        Debug.println("sAction    : "+sAction);
        Debug.println("sType      : "+sType);
        Debug.println("sPersonId  : "+sPersonId);
        Debug.println("sCodes     : "+sCodes+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
    
    boolean show = false;    
%>

<%
    SalaryCalculation calculation = new SalaryCalculation();
        
    //*** SAVE ********************************************************************************
    if(sAction.equalsIgnoreCase("save")){
        java.util.Date startDate = ScreenHelper.stdDateFormat.parse(sBegin),
                       endDate   = ScreenHelper.stdDateFormat.parse(sEnd);

        Calendar periodBegin = Calendar.getInstance();
        periodBegin.setTime(startDate);
        
        Calendar periodEnd = Calendar.getInstance();
        periodEnd.setTime(endDate);

        java.util.Date currDate; 
        while(periodBegin.getTime().getTime() <= periodEnd.getTime().getTime()){
            currDate = periodBegin.getTime();
            
            calculation = SalaryCalculation.getCalculationOnDate(currDate);
            if(calculation==null){
	            Calendar cal = Calendar.getInstance();
	            cal.setTime(currDate);
	                            
		        // create calculation
		        calculation = new SalaryCalculation();                
		        calculation.setUid("-1"); // always new
		        calculation.personId = Integer.parseInt(sPersonId);
		        calculation.source = "manual"; // >< 'script'
		        calculation.type = sType;
		        
		        // dates
		        calculation.begin = currDate;			                    
		        calculation.end = currDate; // same !
	            
		        String sSalCalUID = calculation.store(activeUser.userid); // first store calculation to obtain UID
		        Debug.println("@@@ SAVED : sSalCalUID = "+sSalCalUID);
		        
		        // parse codes
		        calculation.codes = parseCodes(sSalCalUID,sCodes);
		        Debug.println("Saving "+calculation.codes.size()+" codes");
		        
		        calculation.store(activeUser.userid); // save again, the calculation now contains codes
            }
            else{
            	Debug.println("@@@ EXISTS : sSalCalUID = "+calculation.getUid());
            }
            
            periodBegin.add(Calendar.DATE,1); // proceed one day	
        }
    } 
    //*** CREATE ******************************************************************************
    else if(sAction.equalsIgnoreCase("create")){
        calculation = new SalaryCalculation();
        calculation.setUid("-1"); // new
        calculation.personId = Integer.parseInt(sPersonId);
        calculation.source = "manual"; // >< 'script'
        calculation.type = "workschedule"; // default

        calculation.begin = ScreenHelper.stdDateFormat.parse(sBegin);
        calculation.end = calculation.begin;

        show = true;
    }
    
    if(show){        
    	String sCCConcatValues = "";
    	
    	// dates
    	String sCalculationBegin = "", sCalculationEnd = "";
    	if(calculation.begin!=null){
    		sCalculationBegin = ScreenHelper.stdDateFormat.format(calculation.begin);
    	}
    	if(calculation.end!=null){
    		sCalculationEnd = ScreenHelper.stdDateFormat.format(calculation.end);
    	}
    	
        %>        
            <table class="list" border="0" width="534" cellspacing="1">
                <input type="hidden" name="SalCalUID" value="-1">
                <input type="hidden" id="Source" name="Source" value="manual">
            
                <%-- 0 - calculation type (workschedule,leave) --%>
                <%
                    String sSelectedType = "workschedule";
                    if(sType.length() > 0){
                    	sSelectedType = sType;
                    }
                %>
                <tr>
                    <td width="100" class="admin"><%=HTMLEntities.htmlentities(getTran("web","type",sWebLanguage))%>&nbsp;*&nbsp;</td>
                    <td class="admin2">
		                <select class="text" id="Type" name="Type">
		                    <%=ScreenHelper.writeSelect("hr.salarycalculation.type",sSelectedType,sWebLanguage)%>
		                </select>
                    </td>
                </tr>
                
                <%-- 1 - calculation begin date (*) --%>
                <tr>
                    <td class="admin"><%=HTMLEntities.htmlentities(getTran("hr.salarycalculations","beginDate",sWebLanguage))%>&nbsp;*&nbsp;</td>
                    <td class="admin2">
                        <input type="text" id="Begin" name="Begin" value="<%=sCalculationBegin%>" class="text" size="10" maxLength="10" onBlur="if(!checkDate(this)){this.focus();alertDialog('web.occup','date.error');}">
                        <span id="beginDateSelector"></span>
                        
                        <%-- date selector (only past) --%>
                        <script>document.getElementById("beginDateSelector").innerHTML = getMyDate("Begin","<c:url value='/_img/icon_agenda.gif'/>","<%=getTran("web","putToday",sWebLanguage)%>",true,false);</script>
                    </td>
                </tr>
                
                <%-- 2 - calculation end date --%>
                <tr>
                    <td class="admin"><%=HTMLEntities.htmlentities(getTran("hr.salarycalculations","endDate",sWebLanguage))%>&nbsp;*&nbsp;</td>
                    <td class="admin2">
                        <input type="text" id="End" name="End" value="<%=sCalculationEnd%>" class="text" size="10" maxLength="10" onBlur="if(!checkDate(this)){this.focus();alertDialog('web.occup','date.error');}">
                        <span id="endDateSelector"></span>
                        
                        <%-- date selector (only past) --%>
                        <script>document.getElementById("endDateSelector").innerHTML = getMyDate("End","<c:url value='/_img/icon_agenda.gif'/>","<%=getTran("web","putToday",sWebLanguage)%>",true,false);</script>
                    </td>
                </tr>
                
                <%-- 3 - include weekends --%>
                <tr>
                    <td class="admin">&nbsp;</td>
                    <td class="admin2">
                        <input type="checkbox" name="IncludeWeekends" id="IncludeWeekendsCB" value="true"><%=getLabel("hr.salarycalculations","includeWeekends",sWebLanguage,"IncludeWeekendsCB")%>
                    </td>
                </tr>
                             
                <%-- 4 - calculation codes --%>
                <tr>
                    <td class="admin"><%=HTMLEntities.htmlentities(getTran("hr.salarycalculations","codes",sWebLanguage))%>&nbsp;*&nbsp;</td>
                    <td class="admin2">
                        <table id="tblCC" cellpadding="0" cellspacing="0" width="98%" class="sortable" headerRowCount="2" style="border:1px solid #ccc;">
                            <%-- a - header --%>
                            <tr class="admin">
                                <td width="36">&nbsp;</td>
                                <td width="100" style="padding-left:1px;"><%=getTran("web","duration",sWebLanguage)%></td>
                                <td width="380" style="padding-left:1px;"><%=getTran("web","code",sWebLanguage)%></td>
                            </tr>
                            
                            <%-- b - add row --%>
                            <tr>
                                <%-- empty --%>
                                <td class="admin">&nbsp;</td>
                                                                
                                <%-- duration (hours) --%>
                                <td class="admin" nowrap>
                                    <input type="text" class="text" id="addDuration" name="addDuration" size="3" maxLength="4" onKeyUp="removeTrailingZeros(this);if(!isInteger(this))this.value='';"></input>&nbsp;<%=getTran("web","hours",sWebLanguage)%>
                                </td>
                                
                                <%-- code (and label) --%>
                                <td class="admin">
                                    <input type="text" class="text" id="codeAndLabel" name="codeAndLabel" size="30" readonly></input>
                                    
                                    <%-- code icon --%> 
                                    <img src="<c:url value='_img/icon_questionmark.gif'/>" class="link" style="border:1px solid #aaa;background:#eee;" alt="<%=getTranNoLink("hr.salarycalculations","searchCodes",sWebLanguage)%>" onclick="searchCalculationCodes();">
                                    
                                    <%-- add/edit buttons --%>
                                    <%
                                        if(activeUser.getAccessRight("hr.salarycalculations.add")){
                                            %><input class="button" type="button" name="buttonAdd" value="<%=getTranNoLink("web","add",sWebLanguage)%>" onclick="addCC();">&nbsp;<%
                                            %><input class="button" type="button" name="buttonUpdate" value="<%=getTranNoLink("web","update",sWebLanguage)%>" onclick="updateCC();" disabled>&nbsp;<%
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
                    </td>
                </tr>
                                
                <%-- HIDDEN FIELDS --%>
                <input type="hidden" id="calculationCodes" name="calculationCodes" value="<%=sCCConcatValues%>">
                  
                <%-- BUTTONS --%>
                <tr>    
                    <td class="admin">&nbsp;</td>
                    <td class="admin2">                  
	                    <%
	                        if(activeUser.getAccessRight("hr.salarycalculations.add") || activeUser.getAccessRight("hr.salarycalculations.edit")){
	                            %><input class="button" type="button" name="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveRepeatCalculation();">&nbsp;<%
	                        }
	                    %>
	                     
	                    <input class="button" type="button" name="buttonClose" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="closeCalculationForm();">
                    </td>
                </tr>
            </table>
            
            <script>
              setTimeout("sortables_init()",500);
              displayCalculationCodes();
            </script>
        <%
    } 
%>          