<%@page import="be.openclinic.medical.Diagnosis,
                be.openclinic.adt.Encounter,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("diagnoses.patientdiagnoses","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- WRITE SELECT FROM CONFIG ----------------------------------------------------------------
    public static String writeSelectFromConfig(String config, String selected, String name,String language){
        String sConfigValue = MedwanQuery.getInstance().getConfigString(config,"");
        String sValues[] = sConfigValue.split("\\;");

        String sOutput = "<select class='text' name='"+name+"'>"+
                          "<option value=''>"+ScreenHelper.getTranDb("web","choose",language)+"</option>";

        for(int i=0; i<sValues.length; i++){
            sOutput+= "<option value='"+sValues[i]+"'";
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
    String sMsg = "";

    if(activePatient!=null && activePatient.personid.length()>0){
        try{
            String sDefaultSortDir = "ASC";
            String sSortDir = checkString(request.getParameter("SortDir"));
            if(sSortDir.length()==0) sSortDir = sDefaultSortDir;

            String sAction = checkString(request.getParameter("Action"));
            if(sAction.equals("")) sAction = "SEARCH"; // default
                       
	        String sFindDiagnosisFromDate    = checkString(request.getParameter("FindDiagnosisFromDate")),
	               sFindDiagnosisToDate      = checkString(request.getParameter("FindDiagnosisToDate")),
	               sFindDiagnosisCode        = checkString(request.getParameter("FindDiagnosisCode")),
	               sFindDiagnosisCodeType    = checkString(request.getParameter("FindDiagnosisCodeType")),
	               sFindDiagnosisCodeLabel   = checkString(request.getParameter("FindDiagnosisCodeLabel")),
	               sFindDiagnosisFromCertainty = checkString(request.getParameter("FindDiagnosisFromCertainty")),
	               sFindDiagnosisToCertainty = checkString(request.getParameter("FindDiagnosisToCertainty")),
	               sFindDiagnosisFromGravity = checkString(request.getParameter("FindDiagnosisFromGravity")),
	               sFindDiagnosisToGravity   = checkString(request.getParameter("FindDiagnosisToGravity")),
	               sFindDiagnosisEncounter   = checkString(request.getParameter("FindDiagnosisEncounter")),
	               sFindDiagnosisEncounterName = checkString(request.getParameter("FindDiagnosisEncounterName")),
	               sFindDiagnosisAuthor      = checkString(request.getParameter("FindDiagnosisAuthor")),
	               sFindDiagnosisAuthorName  = checkString(request.getParameter("FindDiagnosisAuthorName"));

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
	        

        /// DEBUG /////////////////////////////////////////////////////////////////////////////////
        if(Debug.enabled){
            Debug.println("\n**************** medical/manageDiagnosesPatient.jsp ***************");            
            Debug.println("sFindDiagnosisFromDate    : "+sFindDiagnosisFromDate);
            Debug.println("sFindDiagnosisToDate      : "+sFindDiagnosisToDate);
            Debug.println("sFindDiagnosisCode        : "+sFindDiagnosisCode);
            Debug.println("sFindDiagnosisCodeType    : "+sFindDiagnosisCodeType);
            Debug.println("sFindDiagnosisCodeLabel   : "+sFindDiagnosisCodeLabel);
            Debug.println("sFindDiagnosisFromCertainty : "+sFindDiagnosisFromCertainty);
            Debug.println("sFindDiagnosisToCertainty : "+sFindDiagnosisToCertainty);
            Debug.println("sFindDiagnosisFromGravity : "+sFindDiagnosisFromGravity);
            Debug.println("sFindDiagnosisToGravity   : "+sFindDiagnosisToGravity);
            Debug.println("sFindDiagnosisEncounter   : "+sFindDiagnosisEncounter);
            Debug.println("sFindDiagnosisEncounterName : "+sFindDiagnosisEncounterName);
            Debug.println("sFindDiagnosisAuthor      : "+sFindDiagnosisAuthor);
            Debug.println("sFindDiagnosisAuthorName  : "+sFindDiagnosisAuthorName+"\n");
            
            Debug.println("sEditDiagnosisUID        : "+sEditDiagnosisUID);
            Debug.println("sEditDiagnosisDate       : "+sEditDiagnosisDate);
            Debug.println("sEditDiagnosisEndDate    : "+sEditDiagnosisEndDate);
            Debug.println("sEditDiagnosisCode       : "+sEditDiagnosisCode);
            Debug.println("sEditDiagnosisCodeType   : "+sEditDiagnosisCodeType);
            Debug.println("sEditDiagnosisCodeLabel  : "+sEditDiagnosisCodeLabel);
            Debug.println("sEditDiagnosisCertainty  : "+sEditDiagnosisCertainty);
            Debug.println("sEditDiagnosisGravity    : "+sEditDiagnosisGravity);
            Debug.println("sEditDiagnosisEncounter  : "+sEditDiagnosisEncounter);
            Debug.println("sEditDiagnosisEncounterName : "+sEditDiagnosisEncounterName);
            Debug.println("sEditDiagnosisAuthor     : "+sEditDiagnosisAuthor);
            Debug.println("sEditDiagnosisAuthorName : "+sEditDiagnosisAuthorName);
            Debug.println("sEditDiagnosisLateralisation : "+sEditDiagnosisLateralisation+"\n");
        }

        //*** SAVE ********************************************************************************
        if(sAction.equals("SAVE")){
            Diagnosis tmpDiagnosis = new Diagnosis();
            if(sEditDiagnosisUID.length() > 0){
                tmpDiagnosis = Diagnosis.get(sEditDiagnosisUID);
            }
            else{
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
            sMsg = getTran("web","dataIsSaved",sWebLanguage);
        }
        
        //*** LOAD ********************************************************************************
       	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();

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
            Encounter encounter = Encounter.getActiveEncounter(activePatient.personid);
            if(encounter!=null){
                sEditDiagnosisEncounter = encounter.getUid();
                sEditDiagnosisEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
            }
        }

        if(sEditDiagnosisAuthor.length()==0){
            sEditDiagnosisAuthor = activeUser.userid;
            sEditDiagnosisAuthorName = ScreenHelper.getFullUserName(activeUser.userid, ad_conn);
        }
        
        ad_conn.close();
%>

<%-- FIND BLOCK --%>
<%
    if(sAction.equals("SEARCH") || sAction.equals("")){
%>
<form name="FindDiagnosisForm" id="FindDiagnosisForm" method="POST" action="<c:url value='/main.do'/>?Page=medical/manageDiagnosesPatient.jsp&ts=<%=getTs()%>">
    <input type="hidden" name="Action" value="">
    <input type="hidden" name="FindSortColumn" value="">
        
    <%=writeTableHeader("Web","manageDiagnosesPatient",sWebLanguage," doBack();")%>
    
    <table class='list' width="100%" cellspacing="1" onKeyDown='if(enterEvent(event,13)){doFind();return false;}else{return true;}'>
        <%-- date --%>
        <tr>
            <td class="admin2" width='<%=sTDAdminWidth%>'>
                <%=getTran("medical.diagnosis","period",sWebLanguage)%>
            </td>
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

        <%-- encounter --%>
        <tr>
            <td class="admin2"><%=getTran("web","encounter",sWebLanguage)%></td>
            <td class="admin2">
                <input type="hidden" name="FindDiagnosisEncounter" value="<%=sFindDiagnosisEncounter%>">
                <input class="text" type="text" name="FindDiagnosisEncounterName" readonly size="<%=sTextWidth%>" value="<%=sFindDiagnosisEncounterName%>">
               
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('FindDiagnosisEncounter','FindDiagnosisEncounterName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="FindDiagnosisForm.FindDiagnosisEncounter.value='';FindDiagnosisForm.FindDiagnosisEncounterName.value='';">
            </td>
        </tr>
        
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
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin2"/>
            <td class="admin2">
                <input class="button" type="button" name="FindButton" value="<%=getTranNoLink("web","search",sWebLanguage)%>" onclick="doFind();">&nbsp;
                <input class="button" type="button" name="EmptyButton" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
                <input class="button" type="button" name="NewButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">&nbsp;
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
	    Vector vEncounters = new Vector();
	    int iCountResults = 0;
	
	    try {
	        String sSearchCode = "";
	        if(sFindDiagnosisCode.length() > 0){
	            sSearchCode = sFindDiagnosisCode;
	        }
	        else{
	            sSearchCode = sFindDiagnosisCodeLabel;
	            sFindDiagnosisCodeType = "";
	        }
	        
	        if(sFindDiagnosisEncounter.length()==0){
	            vEncounters = Encounter.selectEncountersUnique("","","","","","","","",activePatient.personid,"");
	        }
	        else{
	            vEncounters.add(Encounter.get(sFindDiagnosisEncounter));
	        }
	        
	        String sClass = "1";	
	        String sEncounterUID = "", sEncounterName = "", sAuthorUID = "", sAuthorName = "",
	        	   sCode = "", sCodeType = "", sCodeLabel = "";
	        Iterator iter = vEncounters.iterator();
	        Iterator iter2;
	
	        Diagnosis dTmp;
	        Encounter tempEncounter;
	        Hashtable encountersdone = new Hashtable();
	        while(iter.hasNext()){
	            tempEncounter = (Encounter)iter.next();
	            
	            if(encountersdone.get(tempEncounter.getUid())==null){
	                encountersdone.put(tempEncounter.getUid(),"1");
	                
	                vDiagnoses = Diagnosis.selectDiagnoses("","",tempEncounter.getUid(),sFindDiagnosisAuthor,sFindDiagnosisFromGravity,
	                		                               sFindDiagnosisToGravity,sFindDiagnosisFromCertainty,sFindDiagnosisToCertainty,
	                                                       sSearchCode,sFindDiagnosisFromDate,sFindDiagnosisToDate,sFindDiagnosisCodeType,"");
	                iter2 = vDiagnoses.iterator();
	                while(iter2.hasNext()){
	                    dTmp = (Diagnosis)iter2.next();
	                    iCountResults++;
	                    
	                    // alternate row-style
	                    if(sClass.equals("")) sClass = "1";
	                    else                  sClass = "";
	
	                    sCode = checkString(checkString(dTmp.getCode()));
	                    sCodeType = checkString(checkString(dTmp.getCodeType()));
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
	                    }
	                    else{
	                        sEncounterName = "";
	                    }
	
	                    sAuthorUID = checkString(dTmp.getAuthorUID());
	                    if(sAuthorUID.length() > 0){
	                       	ad_conn = MedwanQuery.getInstance().getAdminConnection();
	                        sAuthorName = ScreenHelper.getFullUserName(sAuthorUID,ad_conn);
	                        ad_conn.close();
	                    }
	                    else{
	                        sAuthorName = "";
	                    }
	
	                    String sEnddate = "";
	                    if(dTmp.getEndDate()!=null){
	                        sEnddate = checkString(ScreenHelper.stdDateFormat.format(dTmp.getEndDate()));
	                    }
	                    
	                    sbResuslts.append("<tr class=\"list"+sClass+"\" onmouseover=\"this.style.cursor='hand';\" onmouseout=\"this.style.cursor='default';\" onclick=\"doSelect('"+dTmp.getUid()+"');\">")
	                               .append("<td>"+checkString(ScreenHelper.stdDateFormat.format(dTmp.getDate()))+"</td>")
	                               .append("<td>"+sEnddate+"</td>")
	                               .append("<td>"+sCodeType.toUpperCase()+"</td>")
	                               .append("<td>"+sCode+": "+sCodeLabel+"</td>")
	                               .append("<td>"+dTmp.getCertainty()+"</td>")
	                               .append("<td>"+dTmp.getGravity()+"</td>")
	                               .append("<td>"+sEncounterName+"</td>")
	                               .append("<td>"+sAuthorName+"</td>")
	                              .append("</tr>");
	                }
	            }
	        }
        }
	    catch(Exception e){
            e.printStackTrace();
        }

%>
    <table width='100%' cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
        <tr class="admin">
            <td><%=getTranNoLink("web","date",sWebLanguage)%></td>
            <td><%=getTranNoLink("web","enddate",sWebLanguage)%></td>
            <td><%=getTranNoLink("web","codetype",sWebLanguage)%></td>
            <td><%=getTranNoLink("medical.diagnosis","diagnosiscode",sWebLanguage)%></td>
            <td><%=getTranNoLink("medical.diagnosis","certainty",sWebLanguage)%></td>
            <td><%=getTranNoLink("medical.diagnosis","gravity",sWebLanguage)%></td>
            <td><%=getTranNoLink("web","encounter",sWebLanguage)%></td>
            <td><%=getTranNoLink("medical.diagnosis","author",sWebLanguage)%></td>
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
<%
    }
%>

<%
    if(sAction.equals("NEW") || sAction.equals("SELECT") || sAction.equals("SAVE")){
%>
<%-- EDIT BLOCK --%>
<form name="EditDiagnosisForm" id="EditDiagnosisForm" method="POST" action="<c:url value='/main.do'/>?Page=medical/manageDiagnosesPatient.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("Web","manageDiagnosesPatient",sWebLanguage," doSearchBack();")%>
    
    <input type="hidden" name="EditDiagnosisUID" value="<%=sEditDiagnosisUID%>">
    <input type="hidden" name="Action" value="">
    
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
                <input class="text" type="text" name="EditDiagnosisCodeLabel" id="EditDiagnosisCodeLabel" value="<%=sEditDiagnosisCodeLabel%>" readonly size="<%=sTextWidth%>">
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchICPC('EditDiagnosisCode','EditDiagnosisCodeLabel','EditDiagnosisCodeType');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditDiagnosisForm.EditDiagnosisCode.value='';EditDiagnosisForm.EditDiagnosisCodeLabel.value='';EditDiagnosisForm.EditDiagnosisCodeType.value='';">
            </td>
            
            <input type="hidden" name="EditDiagnosisCode" id="EditDiagnosisCode" value="<%=sEditDiagnosisCode%>">
            <input type="hidden" name="EditDiagnosisCodeType" id="EditDiagnosisCodeType" value="<%=sEditDiagnosisCodeType%>">
        </tr>
        
        <%-- certainty --%>
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","certainty",sWebLanguage)%> *</td>
            <td class="admin2">
                <%=writeSelectFromConfig("adt.diagnosis.certainty",sEditDiagnosisCertainty,"EditDiagnosisCertainty",sWebLanguage)%>
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
            <td class="admin"><%=getTran("medical.diagnosis","lateralisation",sWebLanguage)%></td>
            <td class="admin2">
                <%=writeTextarea("EditDiagnosisLateralisation","","","",sEditDiagnosisLateralisation)%>
            </td>
        </tr>
        
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class="button" type="button" name="SaveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;
            <input class="button" type="button" name="BackButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doSearchBack();">&nbsp;
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
        
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
    
	<%
	    if(sMsg.length() > 0){
	        %><br><br><%=sMsg%><%
	    }
	%>
</form>

<script>EditDiagnosisForm.EditDiagnosisDate.focus();</script>
<%-- END EDIT BLOCK --%>
<%
    }
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
       && FindDiagnosisForm.FindDiagnosisEncounter.value==""
       && FindDiagnosisForm.FindDiagnosisEncounterName.value==""
       && FindDiagnosisForm.FindDiagnosisAuthor.value==""
       && FindDiagnosisForm.FindDiagnosisAuthorName.value==""){
                alertDialog("web.manage","dataMissing");
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

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
  }

  function doSearchBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=medical/manageDiagnosesPatient.jsp&ts=<%=getTs()%>";
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
      EditDiagnosisForm.SaveButton.disabled = true;
      EditDiagnosisForm.BackButton.disabled = true;
      EditDiagnosisForm.Action.value = "SAVE";
      EditDiagnosisForm.submit();
    }
  }

  function searchEncounter(encounterUidField,encounterNameField){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode="+encounterUidField+"&VarText="+encounterNameField+"&FindEncounterPatient=<%=activePatient.personid%>");
  }

  function searchAuthor(authorUidField,authorNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+authorUidField+"&ReturnName="+authorNameField+"&displayImmatNew=no");
  }

  function doSelect(diagnosis){
    window.location = "<c:url value='/main.do'/>?Page=medical/manageDiagnosesPatient.jsp&Action=SELECT&EditDiagnosisUID="+diagnosis+"&ts=<%=getTs()%>";
  }

  function searchICPC(code,codelabel,codetype){
    openPopup("/_common/search/searchICPC.jsp&ts=<%=getTs()%>&returnField="+code+"&returnField2="+codelabel+"&returnField3="+codetype+"&ListChoice=TRUE");
  }

  function clearSearchFields(){
    FindDiagnosisForm.FindDiagnosisFromDate.value = "";
    FindDiagnosisForm.FindDiagnosisToDate.value = "";
    FindDiagnosisForm.FindDiagnosisCode.value = "";
    FindDiagnosisForm.FindDiagnosisCodeLabel.value = "";
    FindDiagnosisForm.FindDiagnosisCodeType.value = "";
    FindDiagnosisForm.FindDiagnosisFromCertainty.value = "";
    FindDiagnosisForm.FindDiagnosisToCertainty.value = "";
    FindDiagnosisForm.FindDiagnosisFromGravity.value = "";
    FindDiagnosisForm.FindDiagnosisToGravity.value = "";
    FindDiagnosisForm.FindDiagnosisEncounter.value = "";
    FindDiagnosisForm.FindDiagnosisEncounterName.value = "";
    FindDiagnosisForm.FindDiagnosisAuthor.value = "";
    FindDiagnosisForm.FindDiagnosisAuthorName.value = "";
  }
</script>
<%
	    }
	    catch(Exception e){
	        e.printStackTrace();
	    }
    }
    else{
%>
    <%=writeTableHeader("Web","manageDiagnosesPatient",sWebLanguage," doBack();")%>
    <table class='list' width="100%" cellspacing="1" onKeyDown='if(enterEvent(event,13)){doFind();return false;}else{return true;}'>
        <tr>
            <td colspan="2"><%=getTranNoLink("web","nopatientselected",sWebLanguage)%></td>
        </tr>
    </table>
    
    <script>
      function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=medical/index.jsp&ts=<%=getTs()%>";
      }
      
      function doClose(){
        var URL = unescape(window.opener.location);
        window.opener.location.href = URL;
        window.close();
      }
    </script>
<%
    }
%>