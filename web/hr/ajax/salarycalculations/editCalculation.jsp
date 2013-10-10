<%@page import="java.util.*,
                be.openclinic.hr.SalaryCalculation,
                be.openclinic.hr.SalaryCalculationCode,
                be.mxs.common.util.system.HTMLEntities,
                java.util.Date"%>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("hr.salarycalculations","select",activeUser)%>

<%!
    //--- PARSE CODES -----------------------------------------------------------------------------
    private Vector parseCodes(String sSalCalUID, String sCodes){
    	Vector codes = new Vector();
    	
    	System.out.println("parseCodes : "+sCodes); /////////
    	String[] codesAsString = sCodes.split("\\$");
    	SalaryCalculationCode code;
    	String[] codeAsString;
    	
    	for(int i=0; i<codesAsString.length; i++){
    		codeAsString = codesAsString[i].split("\\|");
        	System.out.println(" codeAsString : "+codeAsString[1]); /////////
    		
    		code = new SalaryCalculationCode();
    		code.setUid("-1"); // codes are always deleted and re-inserted
    		code.calculationUid = sSalCalUID;
     		code.duration = Float.parseFloat(codeAsString[0]); 
        	System.out.println(" duration : "+code.duration); /////////
    	    code.code = codeAsString[1]; 
    	    //code.label = codeAsString[2];
    		
    		codes.add(code);
    	}

    	System.out.println("codes : "+codes.size()); /////////
    	return codes;    	
    }
%>

<%    
    String sAction = checkString(request.getParameter("Action"));

    String sSalCalUID = checkString(request.getParameter("SalCalUID")),
    	   sBegin     = checkString(request.getParameter("Begin")),
           sEnd       = checkString(request.getParameter("End")),
           sPersonId  = checkString(request.getParameter("PersonId")),
           sSource    = checkString(request.getParameter("Source")),
           sCodes     = checkString(request.getParameter("CalculationCodes"));
    
    /// DEBUG ///////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******* hr/ajax/salarycalculation/editCalculation.jsp *******");
        Debug.println("sAction    : "+sAction);
        Debug.println("sBegin     : "+sBegin);
        Debug.println("sEnd       : "+sEnd);
        Debug.println("sSalCalUID : "+sSalCalUID);
        Debug.println("sPersonId  : "+sPersonId);
        Debug.println("sSource    : "+sSource);
        Debug.println("sCodes     : "+sCodes+"\n");
    }
    /////////////////////////////////////////////////////////////////////////////////////
    
    boolean show = false;    
%>

<%
    SalaryCalculation calculation = new SalaryCalculation();
        
    //*** SAVE ********************************************************************************
    if(sAction.equalsIgnoreCase("save")){
        calculation = new SalaryCalculation();                
        calculation.setUid(sSalCalUID);
        calculation.personId = Integer.parseInt(sPersonId);
        calculation.source = sSource;
        calculation.begin = ScreenHelper.stdDateFormat.parse(sBegin);
        calculation.end = ScreenHelper.stdDateFormat.parse(sBegin);
        //calculation.end = ScreenHelper.stdDateFormat.parse(sEnd);
        sSalCalUID = calculation.store(activeUser.userid); // first store calculation to obtain UID
        calculation.source = "manual";
        
        // parse codes
        calculation.codes = parseCodes(sSalCalUID,sCodes);
        Debug.println("Saving "+calculation.codes.size()+" codes");
        
        calculation.store(activeUser.userid); // save again, the calculation now contains codes
    } 
    //*** DELETE ******************************************************************************
    else if(sAction.equalsIgnoreCase("delete")){
        SalaryCalculation.delete(sSalCalUID);            
    }
    //*** CREATE ******************************************************************************
    else if(sAction.equalsIgnoreCase("create")){
        calculation = new SalaryCalculation();
        sSalCalUID = "-1"; // new
        calculation.setUid(sSalCalUID);
        calculation.personId = Integer.parseInt(sPersonId);
        calculation.source = "manual";

        calculation.begin = ScreenHelper.stdDateFormat.parse(sBegin);
        calculation.end = calculation.begin;

        show = true;
    }
    //*** SHOW ********************************************************************************
    else if(sAction.equalsIgnoreCase("show")){
        calculation = SalaryCalculation.get(sSalCalUID);
                    
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

    	// FF fix : reserve space for TR which displays the username
        Hashtable updateUser = User.getUserName(calculation.getUpdateUser());
        String sHeight = "";
        if(updateUser!=null){
        	sHeight = "height='160'";
        }
        
        %>        
            <table class="list" border="0" width="484" <%=sHeight%> cellspacing="1">
                <input type="hidden" name="SalCalUID" value="<%=sSalCalUID%>">
                <input type="hidden" id="Source" name="Source" value="manual">
            
                <%-- 1 - calculation date --%>
                <tr>
                    <td width="100" class="admin"><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
                    <td class="admin2"><%=sCalculationBegin%></td>
                </tr>
                
                <%-- 2 - hidden dates --%>
                <input type="hidden" id="Begin" name="Begin" value="<%=sCalculationBegin%>">
                <input type="hidden" id="End" name="End" value="<%=sCalculationEnd%>">
                             
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
                                    <img src="<c:url value='_img/icon_questionmark.gif'/>" class="link" style="border:1px solid #aaa;background:#eee;" alt="<%=getTranNoLink("hr.salarycalculations","searchCodes",sWebLanguage)%>" onclick="searchCalculationCodes();">
                                    
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
                    </td>
                </tr>
                
                <%-- 4 - user --%>
                <%
                    if(updateUser!=null){
		                %>
			                <tr>
			                    <td class="admin"><%=HTMLEntities.htmlentities(getTran("web","user",sWebLanguage))%></td>
			                    <td class="admin2"><%=updateUser.get("lastname")+", "+updateUser.get("firstname")%></td>
			                </tr>
			            <%
                    }
                %>
                
                <%-- HIDDEN FIELDS --%>
                <input type="hidden" id="calculationCodes" name="calculationCodes" value="<%=sCCConcatValues%>">
                  
                <%-- BUTTONS --%>
                <tr>    
                    <td class="admin">&nbsp;</td>
                    <td class="admin2">                  
	                    <%
	                        if(activeUser.getAccessRight("hr.salarycalculations.add") || activeUser.getAccessRight("hr.salarycalculations.edit")){
	                            %><input class="button" type="button" name="buttonSave" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="saveCalculation('<%=sSalCalUID%>');">&nbsp;<%
	                        }
	                     
	                        if(!sAction.equalsIgnoreCase("create")){
		                        if(activeUser.getAccessRight("planning.delete")){
		                            %><input class="button" type="button" name="buttonDelete" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick="deleteCalculationThruUID('<%=sSalCalUID%>');">&nbsp;<%
		                        }
	                        }
	                    %>
	                     
	                    <input class="button" type="button" name="buttonClose" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="closeCalculation();">
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