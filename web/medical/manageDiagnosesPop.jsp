<%@page import="be.openclinic.medical.Diagnosis,
                java.util.Vector,
                be.openclinic.adt.Encounter"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("diagnoses.populationdiagnoses","edit",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- WRITE SELECT FROM CONFIG ----------------------------------------------------------------
    public static String writeSelectFromConfig(String config, String selected, String name,String language){
        String sConfigValue = MedwanQuery.getInstance().getConfigString(config,"");
        String sValues[] = sConfigValue.split("\\;");

        String sOutput = "<select class='text' name='"+name+"'><option value=''>"+ScreenHelper.getTranDb("web","choose",language)+"</option>";

        for(int i=0; i<sValues.length; i++){
            sOutput+= "<option value='"+sValues[i]+"' ";
            if(sValues[i].equals(selected)){
                sOutput+= " selected";
            }
            sOutput+= ">"+sValues[i]+"</option>";
        }
        
        sOutput+= "</select>";
        
        return sOutput;
    }
%>

<%
    String sDefaultSortDir = "ASC";
    String sSortDir = checkString(request.getParameter("SortDir"));
    if(sSortDir.length()==0) sSortDir = sDefaultSortDir;

    String sAction = checkString(request.getParameter("Action"));

    String sPatientID = checkString(request.getParameter("PatientID"));

    String sFindDiagnosisFromDate   = checkString(request.getParameter("FindDiagnosisFromDate")),
           sFindDiagnosisToDate     = checkString(request.getParameter("FindDiagnosisToDate")),
           sFindDiagnosisCode       = checkString(request.getParameter("FindDiagnosisCode"))+"%",
           sFindDiagnosisCodeType   = checkString(request.getParameter("FindDiagnosisCodeType")),
           sFindDiagnosisCodeLabel  = checkString(request.getParameter("FindDiagnosisCodeLabel")),
           sFindDiagnosisFromCertainty = checkString(request.getParameter("FindDiagnosisFromCertainty")),
           sFindDiagnosisToCertainty   = checkString(request.getParameter("FindDiagnosisToCertainty")),
           sFindDiagnosisFromGravity   = checkString(request.getParameter("FindDiagnosisFromGravity")),
           sFindDiagnosisToGravity  = checkString(request.getParameter("FindDiagnosisToGravity")),
           sFindEncounterOutcome    = request.getParameter("FindEncounterOutcome"),
           sFindContactType         = checkString(request.getParameter("contacttype")),
           sFindDiagnosisCodeExtra  = checkString(request.getParameter("FindDiagnosisCodeExtra")),
           sFindDiagnosisAuthor     = checkString(request.getParameter("FindDiagnosisAuthor")),
           sFindDiagnosisAuthorName = checkString(request.getParameter("FindDiagnosisAuthorName")),
           sFindServiceID           = checkString(request.getParameter("ServiceID"));

    String sEditDiagnosisUID        = checkString(request.getParameter("EditDiagnosisUID")),
           sEditDiagnosisDate       = checkString(request.getParameter("EditDiagnosisDate")),
           sEditDiagnosisEndDate    = checkString(request.getParameter("EditDiagnosisEndDate")),
           sEditDiagnosisCode       = checkString(request.getParameter("EditDiagnosisCode")),
           sEditDiagnosisCodeType   = checkString(request.getParameter("EditDiagnosisCodeType")),
           sEditDiagnosisCodeLabel  = checkString(request.getParameter("EditDiagnosisCodeLabel")),
           sEditDiagnosisCertainty  = checkString(request.getParameter("EditDiagnosisCertainty")),
           sEditDiagnosisGravity    = checkString(request.getParameter("EditDiagnosisGravity")),
           sEditDiagnosisEncounter  = checkString(request.getParameter("EditDiagnosisEncounter")),
           sEditDiagnosisEncounterName = checkString(request.getParameter("EditDiagnosisEncounterName")),
           sEditDiagnosisAuthor     = checkString(request.getParameter("EditDiagnosisAuthor")),
           sEditDiagnosisAuthorName = checkString(request.getParameter("EditDiagnosisAuthorName")),
           sEditDiagnosisLateralisation = checkString(request.getParameter("EditDiagnosisLateralisation"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** medical/manageDiagnosisPop.jsp ******************");
        Debug.println("sFindDiagnosisFromDate    : "+sFindDiagnosisFromDate);
        Debug.println("sFindDiagnosisToDate      : "+sFindDiagnosisToDate);
        Debug.println("sFindDiagnosisCode        : "+sFindDiagnosisCode);
        Debug.println("sFindDiagnosisCodeType    : "+sFindDiagnosisCodeType);
        Debug.println("sFindDiagnosisCodeLabel   : "+sFindDiagnosisCodeLabel);
        Debug.println("sFindDiagnosisFromCertainty : "+sFindDiagnosisFromCertainty);
        Debug.println("sFindDiagnosisToCertainty : "+sFindDiagnosisToCertainty);
        Debug.println("sFindDiagnosisFromGravity : "+sFindDiagnosisFromGravity);
        Debug.println("sFindDiagnosisToGravity   : "+sFindDiagnosisToGravity);
        Debug.println("sFindEncounterOutcome     : "+sFindEncounterOutcome);
        Debug.println("sFindContactType          : "+sFindContactType);
        Debug.println("sFindDiagnosisCodeExtra   : "+sFindDiagnosisCodeExtra);
        Debug.println("sFindDiagnosisAuthor      : "+sFindDiagnosisAuthor);
        Debug.println("sFindDiagnosisAuthorName  : "+sFindDiagnosisAuthorName);
        Debug.println("sFindServiceID            : "+sFindServiceID+"\n");
        
        Debug.println("sEditDiagnosisUID            : "+sEditDiagnosisUID);
        Debug.println("sEditDiagnosisDate           : "+sEditDiagnosisDate);
        Debug.println("sEditDiagnosisEndDate        : "+sEditDiagnosisEndDate);
        Debug.println("sEditDiagnosisCode           : "+sEditDiagnosisCode);
        Debug.println("sEditDiagnosisCodeType       : "+sEditDiagnosisCodeType);
        Debug.println("sEditDiagnosisCodeLabel      : "+sEditDiagnosisCodeLabel);
        Debug.println("sEditDiagnosisCertainty      : "+sEditDiagnosisCertainty);
        Debug.println("sEditDiagnosisGravity        : "+sEditDiagnosisGravity);
        Debug.println("sEditDiagnosisEncounter      : "+sEditDiagnosisEncounter);
        Debug.println("sEditDiagnosisEncounterName  : "+sEditDiagnosisEncounterName);
        Debug.println("sEditDiagnosisAuthor         : "+sEditDiagnosisAuthor);
        Debug.println("sEditDiagnosisAuthorName     : "+sEditDiagnosisAuthorName);
        Debug.println("sEditDiagnosisLateralisation : "+sEditDiagnosisLateralisation+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    
   	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
    if(sAction.equals("SAVE")){
        Diagnosis tmpDiagnosis = new Diagnosis();
        if(sEditDiagnosisUID.length() > 0){
            tmpDiagnosis = Diagnosis.get(sEditDiagnosisUID);
        } else{
            tmpDiagnosis.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
            tmpDiagnosis.setReferenceType("");
            tmpDiagnosis.setReferenceUID("");
        }
        if(sEditDiagnosisDate.length() > 0){
            tmpDiagnosis.setDate(ScreenHelper.getSQLDate(sEditDiagnosisDate));
        }
        if(sEditDiagnosisEndDate.length() > 0){
            tmpDiagnosis.setEndDate(new Timestamp(ScreenHelper.getSQLDate(sEditDiagnosisEndDate).getTime()));
        }
        tmpDiagnosis.setCode(sEditDiagnosisCode);
        tmpDiagnosis.setCodeType(sEditDiagnosisCodeType);
        if(sEditDiagnosisCertainty.length() > 0){
            tmpDiagnosis.setCertainty(Integer.parseInt(sEditDiagnosisCertainty));
        }
        if(sEditDiagnosisGravity.length() > 0){
            tmpDiagnosis.setGravity(Integer.parseInt(sEditDiagnosisGravity));
        }

        if(sEditDiagnosisEncounter.length() > 0){
            Encounter tmpEncounter = Encounter.get(sEditDiagnosisEncounter);
            tmpDiagnosis.setEncounter(tmpEncounter);
        }
        else{
            tmpDiagnosis.setEncounter(new Encounter());
        }
        
        tmpDiagnosis.setLateralisation(new StringBuffer(sEditDiagnosisLateralisation));
        if(sEditDiagnosisAuthor.length() > 0){
            User tmpUser = new User();
            tmpUser.initialize(Integer.parseInt(sEditDiagnosisAuthor));
            tmpDiagnosis.setAuthor(tmpUser);
        }
        else{
            tmpDiagnosis.setAuthor(new User());
        }

        tmpDiagnosis.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        tmpDiagnosis.setUpdateUser(activeUser.userid);
        tmpDiagnosis.store();
        sEditDiagnosisUID = tmpDiagnosis.getUid();
    }

    if(sEditDiagnosisUID.length() > 0){
        Diagnosis tmpDiagnosis = Diagnosis.get(sEditDiagnosisUID);

        sEditDiagnosisDate = checkString(ScreenHelper.stdDateFormat.format(tmpDiagnosis.getDate()));
        if(tmpDiagnosis.getEndDate()!=null){
            sEditDiagnosisEndDate = checkString(ScreenHelper.stdDateFormat.format(tmpDiagnosis.getEndDate()));
        } 
        else{
            sEditDiagnosisEndDate = "";
        }
        sEditDiagnosisCode = tmpDiagnosis.getCode();
        sEditDiagnosisCodeType = tmpDiagnosis.getCodeType();
        sEditDiagnosisCodeLabel = tmpDiagnosis.getCode()+": "+MedwanQuery.getInstance().getCodeTran(sEditDiagnosisCodeType+"code"+sEditDiagnosisCode, sWebLanguage);
        sEditDiagnosisCertainty = Integer.toString(tmpDiagnosis.getCertainty());
        sEditDiagnosisGravity = Integer.toString(tmpDiagnosis.getGravity());
        sEditDiagnosisAuthor = tmpDiagnosis.getAuthor().userid;
        sEditDiagnosisAuthorName = ScreenHelper.getFullUserName(tmpDiagnosis.getAuthor().userid, ad_conn);
        sEditDiagnosisEncounter = tmpDiagnosis.getEncounter().getUid();
        sEditDiagnosisEncounterName = tmpDiagnosis.getEncounter().getEncounterDisplayName(sWebLanguage);
        sEditDiagnosisLateralisation = tmpDiagnosis.getLateralisation().toString();
    }


    if(sEditDiagnosisDate.length()==0){
        sEditDiagnosisDate = checkString(ScreenHelper.stdDateFormat.format(ScreenHelper.getSQLDate(getDate())));
    }

    if(sEditDiagnosisEncounter.length()==0){
        if(sPatientID.length() > 0){
            Encounter encounter = Encounter.getActiveEncounter(sPatientID);
            if(encounter != null){
                sEditDiagnosisEncounter = encounter.getUid();
                sEditDiagnosisEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
            }
        }
    }
    if(sEditDiagnosisAuthor.length()==0){
        sEditDiagnosisAuthor = activeUser.userid;
        sEditDiagnosisAuthorName = ScreenHelper.getFullUserName(activeUser.userid, ad_conn);
    }
%>

<%-- FIND BLOCK --%>
<%
    if(sAction.equals("SEARCH") || sAction.equals("")){
%>
<form name="FindDiagnosisForm" id="FindDiagnosisForm" method="POST" action="<c:url value='/main.do'/>?Page=medical/manageDiagnosesPop.jsp&ts=<%=getTs()%>">
    <input type="hidden" name="Action" value="">
    <input type="hidden" name="FindSortColumn" value="">
        
    <%=writeTableHeader("Web","manageDiagnosesPop",sWebLanguage," doBack();")%>
    
    <table class='list' width="100%" cellspacing="1" onKeyDown='if(event.keyCode==13){doFind();return false;}else{return true;}'>
        <%-- date --%>
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("medical.diagnosis","period",sWebLanguage)%></td>
            <td class="admin2">
                <%=getTran("web","from",sWebLanguage)%>&nbsp;
                <%
                    String sFromDate = "";
                    if(sFindDiagnosisFromDate.length() > 0){
                        sFromDate = ScreenHelper.stdDateFormat.format(ScreenHelper.getSQLDate(sFindDiagnosisFromDate));
                    }
                    out.print(writeDateField("FindDiagnosisFromDate","FindDiagnosisForm",sFromDate,sWebLanguage));
                %>&nbsp;
                <%=getTran("web","to",sWebLanguage)%>&nbsp;
                <%
                    String sToDate = "";
                    if(sFindDiagnosisToDate.length() > 0){
                        sToDate = ScreenHelper.stdDateFormat.format(ScreenHelper.getSQLDate(sFindDiagnosisToDate));
                    }
                    out.print(writeDateField("FindDiagnosisToDate","FindDiagnosisForm",sToDate,sWebLanguage));
                %>&nbsp;
            </td>
        </tr>
        
        <%-- code --%>
        <tr>
            <td class="admin2"><%=getTran("medical.diagnosis","diagnosiscode",sWebLanguage)%></td>
            <td class="admin2">
                <input class="text" type="text" name="FindDiagnosisCodeLabel" id="FindDiagnosisCodeLabel" value="<%=sFindDiagnosisCodeLabel%>" size="<%=sTextWidth%>">
                
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchICPC('FindDiagnosisCode','FindDiagnosisCodeLabel','FindDiagnosisCodeType');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="FindDiagnosisForm.FindDiagnosisCode.value='';FindDiagnosisForm.FindDiagnosisCodeLabel.value='';FindDiagnosisForm.FindDiagnosisCodeType.value='';">
            </td>
            
            <input type="hidden" name="FindDiagnosisCode" id="FindDiagnosisCode" value="<%=sFindDiagnosisCode%>">
            <input type="hidden" name="FindDiagnosisCodeType" id="FindDiagnosisCodeType" value="<%=sFindDiagnosisCodeType%>">
        </tr>
        
        <%-- certainty --%>
        <tr>
            <td class="admin2"><%=getTran("medical.diagnosis","certainty",sWebLanguage)%></td>
            <td class="admin2">
                <%=getTran("web","from",sWebLanguage)%>&nbsp;
                <%=writeSelectFromConfig("adt.diagnosis.certainty",sFindDiagnosisFromCertainty,"FindDiagnosisFromCertainty",sWebLanguage)%>
                <%=getTran("web","to",sWebLanguage)%>&nbsp;
                <%=writeSelectFromConfig("adt.diagnosis.certainty",sFindDiagnosisToCertainty,"FindDiagnosisToCertainty",sWebLanguage)%>
            </td>
        </tr>
        
        <%-- gravity --%>
        <tr>
            <td class="admin2"><%=getTran("medical.diagnosis","gravity",sWebLanguage)%></td>
            <td class="admin2">
                <%=getTran("web","from",sWebLanguage)%>&nbsp;
                <%=writeSelectFromConfig("adt.diagnosis.gravity",sFindDiagnosisFromGravity,"FindDiagnosisFromGravity",sWebLanguage)%>
                <%=getTran("web","to",sWebLanguage)%>&nbsp;
                <%=writeSelectFromConfig("adt.diagnosis.gravity",sFindDiagnosisToGravity,"FindDiagnosisToGravity",sWebLanguage)%>
            </td>
        </tr>

        <%-- encounter
        <tr>
            <td class="admin2"><=getTran("web","encounter",sWebLanguage)></td>
            <td class="admin2">
                <input type="hidden" name="FindDiagnosisEncounter" value="<%--%=sFindDiagnosisEncounter%>">
                <input class="text" type="text" name="FindDiagnosisEncounterName" readonly size="<%--%=sTextWidth%>" value="<%--%=sFindDiagnosisEncounterName%>">
             
                <img src="<%--c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%--%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('FindDiagnosisEncounter','FindDiagnosisEncounterName');">
                <img src="<%--c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%--%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="FindDiagnosisForm.FindDiagnosisEncounter.value='';FindDiagnosisForm.FindDiagnosisEncounterName.value='';">
            </td>
        </tr>
        --%>
        
        <%-- author --%>
        <tr>
            <td class="admin2"><%=getTran("medical.diagnosis","author",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="FindDiagnosisAuthor" value="<%=sFindDiagnosisAuthor%>">
                <input class="text" type="text" name="FindDiagnosisAuthorName" readonly size="<%=sTextWidth%>" value="<%=sFindDiagnosisAuthorName%>">
              
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchAuthor('FindDiagnosisAuthor','FindDiagnosisAuthorName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="FindDiagnosisForm.FindDiagnosisAuthor.value='';FindDiagnosisForm.FindDiagnosisAuthorName.value='';">
            </td>
        </tr>
        
        <%-- outcome --%>
        <tr>
            <td class="admin2"><%=getTran("Web","outcome",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="FindEncounterOutcome" style="vertical-align:-2px;">
                    <option value="">
                    <%=ScreenHelper.writeSelectUnsorted("encounter.outcome",checkString(sFindEncounterOutcome),sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin2"/>
            <td class="admin2">
                <input class="button" type="button" name="FindButton" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="doFind();">&nbsp;
                <input class="button" type="button" name="ClearButton" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
                <input class="button" type="button" name="BackButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">&nbsp;
            </td>
        </tr>
    </table>
</form>

<script>FindDiagnosisForm.FindDiagnosisFromDate.focus();</script>
<%-- END FIND BLOCK --%>
<%
    }
%>

<%-- RESULTS BLOCK --%>
<%
    if(sAction.equals("SEARCH")){
	    StringBuffer sbResuslts = new StringBuffer();
	    Vector vDiagnoses = new Vector();
	
	    int iCountResults = 0;
	    if(sFindDiagnosisToDate.length()==0){
	        sFindDiagnosisToDate = ScreenHelper.stdDateFormat.format(new java.util.Date());
	    }
	    if(sFindDiagnosisFromDate.length()==0){
	        sFindDiagnosisFromDate = "01/01/1900";
	    }

	    try{
	        String sSearchCode = "";
	        if(sFindDiagnosisCode.length() > 0){
	            sSearchCode = sFindDiagnosisCode;
	        }
	        else{
	            sSearchCode = sFindDiagnosisCodeLabel;
	            sFindDiagnosisCodeType = "";
	        }
	
	        vDiagnoses = Diagnosis.selectDiagnoses("","","",sFindDiagnosisAuthor,sFindDiagnosisFromGravity,sFindDiagnosisToGravity,
	        		                               sFindDiagnosisFromCertainty,sFindDiagnosisToCertainty,sSearchCode,
	        		                               sFindDiagnosisFromDate,sFindDiagnosisToDate,sFindDiagnosisCodeType,
	        		                               "",sFindEncounterOutcome,sFindServiceID,sFindContactType);
	
	        String sClass = "", sEncounterUID = "", sEncounterName = "", sPatientName = "", sAuthorUID = "", sAuthorName = "",
	               sCode = "", sCodeType = "", sCodeLabel = "", sEncounterDuration = "", sTotalDuration = "", sEndDate = "";
	        Iterator iter = vDiagnoses.iterator();
	        Diagnosis dTmp;

	        while(iter.hasNext()){
	            dTmp = (Diagnosis)iter.next();
	            sCodeType = checkString(checkString(dTmp.getCodeType()));
	            if(sFindDiagnosisCodeExtra.length()>0 && !dTmp.existsComorbidity(sFindDiagnosisCodeExtra,sCodeType)){
	                continue;
	            }
	
	            iCountResults++;
	            
	            // alternate row-style
	            if(sClass.equals("")) sClass = "1";
	            else                  sClass = "";
	
	            sCode = checkString(checkString(dTmp.getCode()));
	            if(sCode.length() > 0){
	                sCodeLabel = MedwanQuery.getInstance().getCodeTran(sCodeType+"code"+sCode,sWebLanguage);
	            }
	            else{
	                sCodeLabel = "";
	            }

	            sEncounterUID = checkString(dTmp.getEncounterUID());
	            if(checkString(sEncounterUID).length() > 0){
	                Encounter eTmp = Encounter.get(sEncounterUID);
	                
	                sEncounterName = eTmp.getEncounterDisplayName(sWebLanguage);
	                sEncounterDuration = (eTmp.getDurationInDays(ScreenHelper.parseDate(sFindDiagnosisFromDate),ScreenHelper.parseDate(sFindDiagnosisToDate))+1)+"";
	                sPatientName = ScreenHelper.getFullPersonName(eTmp.getPatientUID(),ad_conn);
	            } 
	            else{
	                sEncounterName = "";
	                sEncounterDuration = "";
	            }
            
	            sAuthorUID = checkString(dTmp.getAuthorUID());
	            if(sAuthorUID.length() > 0){
	                sAuthorName = ScreenHelper.getFullUserName(sAuthorUID,ad_conn);
	            }
	            else{
	                sAuthorName = "";
	            }
            
	            if(dTmp.getEncounter().getEnd()!=null){
	                sEndDate = checkString(ScreenHelper.stdDateFormat.format(dTmp.getEncounter().getEnd()));
	                sTotalDuration = Math.ceil((dTmp.getEncounter().getEnd().getTime()+1000-dTmp.getDate().getTime())/(1000.0*60*60*24))+"";
	            }
	            else{
	                sEndDate = "";
	            }
	
	            sbResuslts.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.style.cursor='hand';\" onmouseout=\"this.style.cursor='default';\" onclick=\"doSelect('"+dTmp.getUid()+"','"+dTmp.getEncounter().getPatientUID()+"');\">"+
				                   "<td nowrap><b>"+sPatientName+"</b></td>"+
				                   "<td>"+checkString(ScreenHelper.stdDateFormat.format(dTmp.getDate()))+"</td>"+
				                   "<td>"+sEndDate+"</td>"+
				                   "<td>"+sCode+": "+sCodeLabel+"</td>"+
				                   "<td><i> ("+sAuthorName+")</i></td>"+
				                   "<td>"+dTmp.getCertainty()+"/"+dTmp.getGravity()+"</td>"+
				                   "<td nowrap>"+sEncounterDuration+" <i>("+sTotalDuration+ ")</i></td>"+
				                  "</tr>");
	        }
	    }
	    catch(Exception e){
	        e.printStackTrace();
	    }
	
	    String sortTran = getTran("web","clicktosort",sWebLanguage);
%>
<table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
    <tr class="admin">
        <td><%=getTranNoLink("web","patient",sWebLanguage)%></td>
        <td><a href="#" class="underlined" title="<%=sortTran%>"><<%=sSortDir%>><%=getTranNoLink("web","date",sWebLanguage)%></<%=sSortDir%>></a></td>
        <td><a href="#" class="underlined"><%=getTranNoLink("web","enddate",sWebLanguage)%></a></td>
        <td><a href="#" class="underlined"><%=getTranNoLink("medical.diagnosis","diagnosiscode",sWebLanguage)%></a></td>
        <td><a href="#" class="underlined"><%=getTranNoLink("medical.diagnosis","author",sWebLanguage)%></a></td>
        <td><a href="#" class="underlined"><%=getTranNoLink("medical.diagnosis","certainty",sWebLanguage)%></a> / <a href="#" class="underlined"><%=getTranNoLink("medical.diagnosis","gravity",sWebLanguage)%></a></td>
        <td><a href="#" class="underlined"><%=getTranNoLink("medical.diagnosis","days",sWebLanguage)%></a></td>
    </tr>
    <%=sbResuslts%>
</table>
<%
	    if(sbResuslts.length()==0){
	        out.print(getTran("web","norecordsfound",sWebLanguage));
	    }
	    else{
	        out.print(iCountResults+" "+getTran("web","recordsfound",sWebLanguage));
	    }
	%>
	<%-- END RESULTS BLOCK --%>
<%
    }
%>

<%
    if(sAction.equals("NEW") || sAction.equals("SELECT") || sAction.equals("SAVE")){
%>
<%-- EDIT BLOCK --%>
<form name="EditDiagnosisForm" id="EditDiagnosisForm" method="POST" action="<c:url value='/main.do'/>?Page=medical/manageDiagnosesPop.jsp&ts=<%=getTs()%>">
    <input type="hidden" name="Action" value="">
    <input type="hidden" name="EditDiagnosisUID" value="<%=sEditDiagnosisUID%>">
    
    <%=writeTableHeader("Web","manageDiagnosesPop",sWebLanguage," doSearchBack();")%>
    
    <table class="list" width="100%" cellspacing="1">
        <%-- date --%>
        <tr>
            <td class="admin" width='<%=sTDAdminWidth%>'><%=getTran("web","date",sWebLanguage)%> *</td>
            <td class="admin2">
                <%=writeDateField("EditDiagnosisDate","EditDiagnosisForm",sEditDiagnosisDate,sWebLanguage)%>
            </td>
        </tr>
        
        <%-- enddate --%>
        <tr>
            <td class="admin" width='<%=sTDAdminWidth%>'><%=getTran("web","enddate",sWebLanguage)%> *</td>
            <td class="admin2">
                <%=writeDateField("EditDiagnosisEndDate","EditDiagnosisForm",sEditDiagnosisEndDate,sWebLanguage)%>
            </td>
        </tr>
        
        <%-- code --%>
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","diagnosiscode",sWebLanguage)%> *</td>
            <td class="admin2">
                <input class="text" type="text" name="EditDiagnosisCodeLabel" value="<%=sEditDiagnosisCodeLabel%>" readonly size="<%=sTextWidth%>">
             
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchICPC('EditDiagnosisForm.EditDiagnosisCode','EditDiagnosisForm.EditDiagnosisCodeLabel','EditDiagnosisForm.EditDiagnosisCodeType');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditDiagnosisForm.EditDiagnosisCode.value='';EditDiagnosisForm.EditDiagnosisCodeLabel.value='';EditDiagnosisForm.EditDiagnosisCodeType.value='';">
            </td>
            
            <input type="hidden" name="EditDiagnosisCode" value="<%=sEditDiagnosisCode%>">
            <input type="hidden" name="EditDiagnosisCodeType" value="<%=sEditDiagnosisCodeType%>">
        </tr>
        
        <%-- certainty --%>
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","certainty",sWebLanguage)%> *</td>
            <td class="admin2">
                <%
                    out.print(writeSelectFromConfig("adt.diagnosis.certainty",sEditDiagnosisCertainty,"EditDiagnosisCertainty",sWebLanguage));
                %>
            </td>
        </tr>
        
        <%-- gravity --%>
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","gravity",sWebLanguage)%> *</td>
            <td class="admin2">
                <%=writeSelectFromConfig("adt.diagnosis.gravity",sEditDiagnosisGravity,"EditDiagnosisGravity",sWebLanguage)%>
            </td>
        </tr>
        
        <%-- encounter --%>
        <tr>
            <td class="admin"><%=getTran("web","encounter",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="hidden" name="EditDiagnosisEncounter" value="<%=sEditDiagnosisEncounter%>">
                <input class="text" type="text" name="EditDiagnosisEncounterName" readonly size="<%=sTextWidth%>" value="<%=sEditDiagnosisEncounterName%>">
                
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('EditDiagnosisEncounter','EditDiagnosisEncounterName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditDiagnosisForm.EditDiagnosisEncounter.value='';EditDiagnosisForm.EditDiagnosisEncounterName.value='';">
            </td>
        </tr>
        
        <%-- author --%>
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","author",sWebLanguage)%> *</td>
            <td class="admin2">
                <input type="hidden" name="EditDiagnosisAuthor" value="<%=sEditDiagnosisAuthor%>">
                <input class="text" type="text" name="EditDiagnosisAuthorName" readonly size="<%=sTextWidth%>" value="<%=sEditDiagnosisAuthorName%>">
                
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchAuthor('EditDiagnosisAuthor','EditDiagnosisAuthorName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditDiagnosisForm.EditDiagnosisAuthor.value='';EditDiagnosisForm.EditDiagnosisAuthorName.value='';">
            </td>
        </tr>
        
        <%-- lateralisation --%>
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","lateralisation",sWebLanguage)%> *</td>
            <td class="admin2">
                <%=writeTextarea("EditDiagnosisLateralisation","","","",sEditDiagnosisLateralisation)%>
            </td>
        </tr>
        
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class="button" type="button" name="EditSaveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;
            <input class="button" type="button" name="BackButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doSearchBack();">&nbsp;
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>

    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
</form>

<script>EditDiagnosisForm.EditDiagnosisDate.focus();</script>
<%-- END EDIT BLOCK --%>
<%
    }
	ad_conn.close();

%>
<script>           
  function doFind(){
    if(FindDiagnosisForm.FindDiagnosisFromDate.value==""
       && FindDiagnosisForm.FindDiagnosisToDate.value==""
       && FindDiagnosisForm.FindDiagnosisCode.value==""
       && FindDiagnosisForm.FindDiagnosisCodeType.value==""
       && FindDiagnosisForm.FindDiagnosisCodeLabel.value==""
       && FindDiagnosisForm.FindDiagnosisFromCertainty.value==""
       && FindDiagnosisForm.FindDiagnosisToCertainty.value==""
       && FindDiagnosisForm.FindDiagnosisFromGravity.value==""
       && FindDiagnosisForm.FindDiagnosisToGravity.value==""
       && FindDiagnosisForm.FindDiagnosisAuthor.value==""
       && FindDiagnosisForm.FindDiagnosisAuthorName.value==""){
      alertDialog("web.manage","datamissing");
    }
    else{
      FindDiagnosisForm.FindButton.disabled = true;
      FindDiagnosisForm.Action.value = "SEARCH";
      FindDiagnosisForm.submit();
    }
  }

  function doNew(){
    FindDiagnosisForm.NewButton.disabled = true;
    FindDiagnosisForm.Action.value = "NEW";
    FindDiagnosisForm.submit();
  }

  function doSearch(col){
    FindDiagnosisForm.FindSortColumn.value = col;
    FindDiagnosisForm.Action.value = "SEARCH";
    FindDiagnosisForm.submit();
  }

  function doBack(){
    <%
       if(activePatient != null){
           %>window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";<%
       }
       else{
           %>window.location.href = "<c:url value='/main.do'/>?Page=medical/index.jsp&ts=<%=getTs()%>";<%
       }
   %>
  }

  function doSearchBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=medical/manageDiagnosesPop.jsp&ts=<%=getTs()%>";
  }

  function isNumber(val){
    if(isNaN(val)) return false;
    else           return true;
  }

  function doSave(){
    if(EditDiagnosisForm.EditDiagnosisDate.value==""){
      alertDialog("medical","no_date");
    }
    else if(EditDiagnosisForm.EditDiagnosisCode.value==""){
      alertDialog("medical","no_code");
    }
    else if(EditDiagnosisForm.EditDiagnosisCertainty.value==""){
      alertDialog("medical","no_certainty");
    }
    else if(!isNumber(EditDiagnosisForm.EditDiagnosisCertainty.value)){
      alertDialog("medical","cert_no_valid_input");
    }
    else if(EditDiagnosisForm.EditDiagnosisGravity.value==""){
      alertDialog("medical","no_gravity");
    }
    else if(!isNumber(EditDiagnosisForm.EditDiagnosisGravity.value)){
      alertDialog("medical","grav_no_valid_input");
    }
    else if(EditDiagnosisForm.EditDiagnosisEncounter.value==""){
      alertDialog("medical","no_encounter");
    }
    else if(EditDiagnosisForm.EditDiagnosisAuthor.value==""){
      alertDialog("medical","no_author");
    }
    else{
      EditDiagnosisForm.EditSaveButton.disabled = true;
      EditDiagnosisForm.Action.value = "SAVE";
      EditDiagnosisForm.submit();
    }
  }

  function searchEncounter(encounterUidField,encounterNameField){
    <%
        if(sPatientID.length() > 0){
            %>openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode="+encounterUidField+"&VarText="+encounterNameField+"&FindEncounterPatient=<%=sPatientID%>");<%
        }
        else{
            %>alertDialog("web","nopatientselected");<%
        }
    %>
  }

  function searchAuthor(authorUidField,authorNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+authorUidField+"&ReturnName="+authorNameField+"&displayImmatNew=no");
  }

  function doSelect(diagnosis,patientID){
    <%
        if(request.getParameter("selectrecord")==null){
            %>window.location = "<c:url value='/main.do'/>?Page=medical/manageDiagnosesPop.jsp&Action=SELECT&EditDiagnosisUID="+diagnosis+"&PatientID="+patientID+"&ts=<%=getTs()%>";<%
        }
        else{
            %>window.location = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=ScreenHelper.getTs()%>&PersonID="+patientID;<%
        }
    %>
  }

  function searchICPC(code,codelabel,codetype){
    openPopup("/_common/search/searchICPC.jsp&ts=<%=getTs()%>&returnField="+code+"&returnField2="+codelabel+"&returnField3="+codetype+"&ListChoice=TRUE");
  }

  function clearSearchFields(){
    FindDiagnosisForm.FindDiagnosisFromDate.value = "";
    FindDiagnosisForm.FindDiagnosisToDate.value = "";
    FindDiagnosisForm.FindDiagnosisCode.value = "";
    FindDiagnosisForm.FindDiagnosisCodeType.value = "";
    FindDiagnosisForm.FindDiagnosisCodeLabel.value = "";
    FindDiagnosisForm.FindDiagnosisFromCertainty.value = ""
    FindDiagnosisForm.FindDiagnosisToCertainty.value = ""
    FindDiagnosisForm.FindDiagnosisFromGravity.value = ""
    FindDiagnosisForm.FindDiagnosisToGravity.value = ""
    FindDiagnosisForm.FindDiagnosisAuthor.value = "";
    FindDiagnosisForm.FindDiagnosisAuthorName.value = "";
    FindDiagnosisForm.FindEncounterOutcome.value = "";
  }
</script>