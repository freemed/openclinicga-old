<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSDATE%>

<%
    String sAction = checkString(request.getParameter("Action"));

    // begin
    String sYearBegin = "01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());

    String sBegin = checkString(request.getParameter("begin"));
    if(sBegin.length()==0 && sAction.length()==0){
        sBegin = sYearBegin; // default
    }
    
    // end
    String sYearEnd;
    if(ScreenHelper.stdDateFormat.toPattern().equals("dd/MM/yyyy")){
        sYearEnd = "31/12/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    else{
        sYearEnd = "12/31/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }

    String sEnd = checkString(request.getParameter("end"));
    if(sEnd.length()==0 && sAction.length()==0){
	    sEnd = sYearEnd; // default
    }
    
    String codetype  = checkString(request.getParameter("codetype")),
           diagnosis = checkString(request.getParameter("diagnosis")),
           situation = checkString(request.getParameter("situation"));
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n****************** statistics/diagnosesPerSituation.jsp ****************");
    	Debug.println("sAction : "+sAction);
    	Debug.println("sBegin  : "+sBegin);
    	Debug.println("sEnd    : "+sEnd);
    	Debug.println("codetype  : "+codetype);
    	Debug.println("diagnosis : "+diagnosis);
    	Debug.println("situation : "+situation+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>
<form method="post" name="statForm">
    <%=writeTableHeader("Web","statistics.diagnosespersituation",sWebLanguage," doBack()")%>
    <input type="hidden" name="Action" value=""/>
    
    <table class="list" cellpadding="0" cellspacing="1" width="100%">
        <%-- PERIOD --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","period",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%=getTran("web","from",sWebLanguage)%>&nbsp;<%=writeDateField("begin","statForm",sBegin,sWebLanguage)%>&nbsp;
                <%=getTran("web","to",sWebLanguage)%>&nbsp;<%=writeDateField("end","statForm",sEnd,sWebLanguage)%>&nbsp;
            </td>
        </tr>
        
        <%-- DIAGNOSIS --%>
        <tr>
            <td class="admin"><%=getTran("web","diagnosis",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select name="codetype" id="codetype" class="text" onChange="statForm.diagnosis.focus();">
                    <option value=""/>
                    <option value="icpc" <%="icpc".equalsIgnoreCase(codetype)?" selected":""%>><%=getTranNoLink("web","icpc",sWebLanguage)%></option>
                    <option value="icd10" <%="icd10".equalsIgnoreCase(codetype)?" selected":""%>><%=getTranNoLink("web","icd10",sWebLanguage)%></option>
                    <option value="icpcgroups" <%="icpcgroups".equalsIgnoreCase(codetype)?" selected":""%>><%=getTranNoLink("web","icpcgroups",sWebLanguage)%></option>
                    <option value="icd10groups" <%="icd10groups".equalsIgnoreCase(codetype)?" selected":""%>><%=getTranNoLink("web","icd10groups",sWebLanguage)%></option>
                </select>
                <input type='text' class='text' name='diagnosis' id="diagnosis" size="20"/>
            </td>
        </tr>
        
        <%-- SITUATION --%>
        <tr>
            <td class="admin"><%=getTran("Web","situation",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="situation" id="situation">
                    <option value=""/>
                    <%=ScreenHelper.writeSelectUnsorted("encounter.situation","",sWebLanguage)%>
                </select>&nbsp;&nbsp;
                
                <%-- BUTTONS --%>
				<input type="button" class="button" name="findButton" value="<%=getTranNoLink("web","find",sWebLanguage)%>" onClick="doSearch();"/>&nbsp;
				<input type="button" class="button" name="clearButton" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
              	<input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
		    </td>
        </tr>
    </table>
</form>

<%
    //*** SEARCH **********************************************************************************
    if(sAction.equals("search")){    	
        // zoek debets van de betreffende periode en ventileer ze per dienst
        String sQuery = "select distinct personid, firstname, lastname, oc_encounter_serverid,"+
                        " oc_encounter_objectid, oc_encounter_begindate, oc_encounter_enddate"+
        	            "  from oc_diagnoses a, oc_encounters b, adminview c"+
                        "   where b.oc_encounter_patientuid = c.personid"+
        	            "    and a.oc_diagnosis_encounterobjectid = b.oc_encounter_objectid";

        if(situation.length() > 0){
            sQuery+= " and b.oc_encounter_situation = ?";
        }
        if(sBegin.length() > 0 && sEnd.length() > 0){
            sQuery+= " and a.oc_diagnosis_date between ? and ?";
        }
        else if(sBegin.length() > 0){
            sQuery+= " and a.oc_diagnosis_date >= ?";
        }
        else if(sEnd.length() > 0){
            sQuery+= " and a.oc_diagnosis_date <= ?";
        }
        if(situation.length() > 0){
            sQuery+= " and a.oc_diagnosis_codetype = ?";
        }
        if(situation.length() > 0){
            sQuery+= " and a.oc_diagnosis_code like ?";
        }
        
        sQuery+= " order by oc_encounter_begindate";
        Connection conn = MedwanQuery.getInstance().getLongOpenclinicConnection();
        PreparedStatement ps = conn.prepareStatement(sQuery);
        int psIdx = 1;
        
        if(situation.length() > 0) ps.setString(psIdx++,situation);
        if(sBegin.length() > 0 && sEnd.length() > 0){
        	ps.setDate(psIdx++,new java.sql.Date(ScreenHelper.parseDate(sBegin).getTime()));
            ps.setDate(psIdx++,new java.sql.Date(ScreenHelper.parseDate(sEnd).getTime()));
        }
        else if(sBegin.length() > 0){
        	ps.setDate(psIdx++,new java.sql.Date(ScreenHelper.parseDate(sBegin).getTime()));
        }
        else if(sEnd.length() > 0){
        	ps.setDate(psIdx++,new java.sql.Date(ScreenHelper.parseDate(sEnd).getTime()));
        }
        if(codetype.length() > 0) ps.setString(psIdx++,codetype);
        if(diagnosis.length() > 0) ps.setString(psIdx++,diagnosis+"%");
        
        ResultSet rs = ps.executeQuery();
        String sClass = "1";
        int recCount = 0;
        
		while(rs.next()){
			if(recCount==0){
		    	%>
		    	    <table width="100%" class="list" cellpadding="0" cellspacing="1">
		    	        <%-- header --%>
		    	        <tr class="gray">
		    	            <td width="80"><%=getTran("web","personId",sWebLanguage)%></td>
		    	            <td width="220"><%=getTran("web","person",sWebLanguage)%></td>
		    	            <td width="*"><%=getTran("web","period",sWebLanguage)%></td>
		    	        </tr>
		    	<%
			}
			
			java.util.Date enddate = rs.getDate("oc_encounter_enddate");
			String personid = rs.getString("personid");
			recCount++;
			
			// alternate row-style
			if(sClass.length()==0) sClass = "1";
			else                   sClass = "";
			
			out.print("<tr class='list"+sClass+"'>"+
			           "<td>"+personid+"</td>"+
					   "<td><a href='javascript:openDossier("+personid+")'>"+rs.getString("firstname").toUpperCase()+" "+rs.getString("lastname").toUpperCase()+"</a></td>"+
			           "<td>"+ScreenHelper.formatDate(rs.getDate("oc_encounter_begindate"))+" - "+(enddate==null?"?":ScreenHelper.formatDate(enddate))+"</td>"+
					  "</tr>");
		}
        rs.close();
        ps.close();
        conn.close();
  
	    if(recCount > 0){
	    	%>
	    	    </table>
	    	
	    	    <%=recCount%> <%=getTran("web","recordsFound",sWebLanguage)%>
	    
	            <%=ScreenHelper.alignButtonsStart()%>
	                <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doBack();">
	            <%=ScreenHelper.alignButtonsStop()%>
		    <%
	    }
	    else{
	    	%><%=getTran("web","noRecordsFound",sWebLanguage)%><%
	    }
    }
%>

<script>
  <%-- DO SEARCH --%>
  function doSearch(){
	statForm.Action.value = "search";
	statForm.findButton.disabled = true;
	statForm.clearButton.disabled = true;
	statForm.backButton.disabled = true;
	statForm.submit();
  }
  
  <%-- CLEAR SEARCHFIELDS --%>
  function clearSearchFields(){
	document.getElementById("begin").value = "<%=sYearBegin%>";
	document.getElementById("end").value = "<%=sYearEnd%>";
	document.getElementById("codetype").selectedIndex = 0;
    document.getElementById("diagnosis").value = "";
	document.getElementById("situation").selectedIndex = 0;
        
    document.getElementById("begin").focus();
  }

  <%-- OPEN DOSSIER --%>
  function openDossier(personid){
	var url = "<c:url value='main.jsp?Page=curative/index.jsp'/>&ts=<%=getTs()%>&PersonID="+personid;
    window.open(url,"Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=1020,height=700,menubar=no").moveTo((screen.width-1020)/2,(screen.height-700)/2);
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }
  
  document.getElementById("begin").focus();
</script>