<%@page import="be.openclinic.medical.*,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%!
	//--- WRITE ROW -------------------------------------------------------------------------------
	private String writeRow(String sID, String sType, String sCode, String sLabel, String sWebLanguage){
	    if(sLabel.startsWith("<")){
	        sLabel = "";
	    }
	
	    // translate labtype
	         if(sType.equals("1")) sType = getTran("Web.occup","labanalysis.type.blood",sWebLanguage);
	    else if(sType.equals("2")) sType = getTran("Web.occup","labanalysis.type.urine",sWebLanguage);
	    else if(sType.equals("3")) sType = getTran("Web.occup","labanalysis.type.other",sWebLanguage);
	    else if(sType.equals("4")) sType = getTran("Web.occup","labanalysis.type.stool",sWebLanguage);
	    else if(sType.equals("5")) sType = getTran("Web.occup","labanalysis.type.sputum",sWebLanguage);
	    else if(sType.equals("6")) sType = getTran("Web.occup","labanalysis.type.smear",sWebLanguage);
	    else if(sType.equals("7")) sType = getTran("Web.occup","labanalysis.type.liquid",sWebLanguage);
	
	    return "<tr>"+
	            "<td class='admin' width='60'><a href='javascript:selectLabAnalysis(\""+sID+"\",\""+sType+"\",\""+sCode+"\",\""+sLabel+"\")' title='"+getTranNoLink("web","select",sWebLanguage)+"'>"+sCode+"</a></td>"+
	            "<td class='admin2' width='70'>"+sType+"</td>"+
	            "<td class='admin2'>"+sLabel+"</td>"+
	           "</tr>";
	}

    //--- WRITE PROFILE ROW -----------------------------------------------------------------------
    private String writeProfileRow(String sId, String sCode, String sLabel, String sWebLanguage){
        if(sLabel.startsWith("<")){
            sLabel = "";
        }
        
        return "<tr>"+
                "<td class='admin' width='60'><a href='javascript:selectLabAnalysisGroup(\""+sId+"\",\""+sCode+"\",\""+sLabel+"\")' title='"+getTranNoLink("web","select",sWebLanguage)+"'>"+sCode+"</a></td>"+
                "<td class='admin2' width='250'><img width='16px' src='_img/multiple.gif'/> - "+sLabel+"</td>"+
               "</tr>";
    }
%>

<%
    String sVarID       = checkString(request.getParameter("VarID")),
           sVarType     = checkString(request.getParameter("VarType")),
           sVarCode     = checkString(request.getParameter("VarCode")),
	       sVarText     = checkString(request.getParameter("VarText")),
	       sVarTextHtml = checkString(request.getParameter("VarTextHtml"));

    String sSearchCode  = checkString(request.getParameter("FindCode")),
           sFindText    = checkString(request.getParameter("FindText"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
	    Debug.println("\n************* _common/search/searchLabAnalysisAndGroups.jsp ***********");
	    Debug.println("sVarID       : "+sVarID);
	    Debug.println("sVarType     : "+sVarType);
	    Debug.println("sVarCode     : "+sVarCode);
	    Debug.println("sVarText     : "+sVarText);
	    Debug.println("sVarTextHtml : "+sVarTextHtml);
	    Debug.println("sSearchCode  : "+sSearchCode);
	    Debug.println("sFindText    : "+sFindText+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    StringBuffer sOut = new StringBuffer();
    String sLabID, sLabType, sLabCode, sCodeOther = "", sLabel;
    String sMsg1 = "", sMsg2 = "";
    int iTotal = 0;

    //*** 1 - ANALYSES ********************************************************
    //--- search on LABCODE ---
    if(sSearchCode.length() > 0){
        sFindText = ""; // if searched on code, you can not search on name

        Vector hLabAnalysis = LabAnalysis.searchByLabCode(sSearchCode,"name",sWebLanguage);

        LabAnalysis objLabAnalysis;
        for(int n=0; n<hLabAnalysis.size(); n++){
            objLabAnalysis = (LabAnalysis)hLabAnalysis.elementAt(n);
            iTotal++;
            
            sLabID = Integer.toString(objLabAnalysis.getLabId());
            sLabType = objLabAnalysis.getLabtype();
            sLabCode = objLabAnalysis.getLabcode();
            sCodeOther = objLabAnalysis.getLabcodeother();
            sLabel = getTran("labanalysis",objLabAnalysis.getLabId()+"",sWebLanguage);

            sOut.append(writeRow(sLabID,sLabType,sLabCode,sLabel,sWebLanguage));
        }
    }
    //--- search on LABLABEL ---
    else if(sFindText.length() > 0){
        String lowerLabel = checkString(MedwanQuery.getInstance().getConfigParam("lowerCompare","OC_LABEL_VALUE"));

        if(lowerLabel.length() > 0){
            Hashtable hLabAnalysis = LabAnalysis.searchByLabLabel(sFindText,"name",sWebLanguage);
            Enumeration e = hLabAnalysis.keys();
            String sKey;

            LabAnalysis objLabAnalysis;
            while(e.hasMoreElements()){
                sKey = (String)e.nextElement();
                iTotal++;

                objLabAnalysis = (LabAnalysis) hLabAnalysis.get(sKey);
                sLabID = Integer.toString(objLabAnalysis.getLabId());
                sLabType = objLabAnalysis.getLabtype();
                sLabCode = objLabAnalysis.getLabcode();
                sCodeOther = objLabAnalysis.getLabcodeother();
                sLabel = sKey;

                sOut.append(writeRow(sLabID,sLabType,sLabCode,sLabel,sWebLanguage));
            }
        }
    }
    //--- DISPLAY NOTHING OR ALL ANALYSES ---
    else{
        if(MedwanQuery.getInstance().getConfigString("fillUpSearchScreens").equalsIgnoreCase("on")){
            Vector hLabAnalysis = LabAnalysis.searchByLabCode("%","name",sWebLanguage);

            LabAnalysis objLabAnalysis;
            for(int n=0; n<hLabAnalysis.size(); n++){
                objLabAnalysis = (LabAnalysis)hLabAnalysis.elementAt(n);
                iTotal++;
                
                sLabID = Integer.toString(objLabAnalysis.getLabId());
                sLabType = objLabAnalysis.getLabtype();
                sLabCode = objLabAnalysis.getLabcode();
                sCodeOther = objLabAnalysis.getLabcodeother();
                sLabel = getTran("labanalysis",objLabAnalysis.getLabId()+"",sWebLanguage);

                sOut.append(writeRow(sLabID,sLabType,sLabCode,sLabel,sWebLanguage));
            }
        }
    }
    
    if(iTotal > 0){
        sMsg1 = iTotal+" "+getTran("web","recordsFound",sWebLanguage);
    }
    else{
        sMsg1 = getTran("web","noRecordsFound",sWebLanguage);
    }
    
    //*** 2 - GROUPS **********************************************************
    StringBuffer sOut2 = new StringBuffer();
    Hashtable labprofiles = LabProfile.getProfiles(sWebLanguage);
    SortedMap lp = new TreeMap();
    lp.putAll(labprofiles);
    iTotal = 0;
    
    Iterator it = lp.keySet().iterator();
    while(it.hasNext()){
    	String key = (String)it.next();
    	LabProfile profile = (LabProfile)lp.get(key);
    	iTotal++;
    	
    	sOut2.append(writeProfileRow(profile.getProfileID()+"",profile.getProfilecode(),getTran("labprofiles",profile.getProfileID()+"",sWebLanguage),sWebLanguage));
    }
    
    if(iTotal > 0){
        sMsg2 = iTotal+" "+getTran("web","recordsFound",sWebLanguage);
    }
    else{
        sMsg2 = getTran("web","noRecordsFound",sWebLanguage);
    }
%>

<form name="searchForm" method="POST" onSubmit="doFind();">
  <%=writeTableHeader("web","searchLabAnalysis",sWebLanguage," window.close();")%>
  
  <table width="100%" cellspacing="0" cellpadding="0" class="menu">
    <%-- SEARCH INPUTS --%>
    <tr>
      <td class="admin2" height='25'>
        <%=getTran("web.manage","labanalysis.cols.code",sWebLanguage)%>&nbsp;<input class="text" type="text" name="FindCode" value="<%=sSearchCode%>" size="16">&nbsp;
        <%=getTran("web.manage","labanalysis.cols.name",sWebLanguage)%>&nbsp;<input class="text" type="text" name="FindText" value="<%=sFindText%>" size="32">

        <%-- BUTTONS --%>
        <input class="button" type="button" name="FindButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>" onClick="doFind();">
        <input class="button" type="button" name="ClearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="clearForm();">
      </td>
    </tr>
  </table>
  <br>

  <%-- SEARCH RESULTS --%>
  <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults1">
    <%-- HEADER --%>
    <tr class="admin">
      <td width="60"><%=getTran("web.manage","labanalysis.cols.code",sWebLanguage)%></a></td>
      <td width="70"><%=getTran("web.manage","labanalysis.cols.type",sWebLanguage)%></a></td>
      <td width="180"><%=getTran("web.manage","labanalysis.cols.name",sWebLanguage)%></a></td>
    </tr>
    <%=sOut%>
  </table>

  <%
      if(sMsg1.length() > 0){
          %><%=sMsg1%><br><%
      }
  %>
  <br>
  
  <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults2">
    <%-- HEADER --%>
  	<tr class="admin">
 	  <td width="60"><%=getTran("web","code",sWebLanguage)%></td>
      <td width="250"><%=getTran("web.manage","labanalysis.cols.labgroup",sWebLanguage)%></td>
    </tr>
    <%=sOut2%>
  </table>
  
  <%
      if(sMsg2.length() > 0){
          %><%=sMsg2%><br><%
      }
  %>
  <br>

  <%-- CLOSE BUTTON --%>
  <%=ScreenHelper.alignButtonsStart()%>
    <input type="button" name="buttonclose" class="button" value="<%=getTranNoLink("Web","Close",sWebLanguage)%>" onclick="window.close();">
  <%=ScreenHelper.alignButtonsStop()%>
  
  <input type="hidden" name="VarCode" value="<%=sVarCode%>">
  <input type="hidden" name="VarText" value="<%=sVarText%>">
</form>

<script>
  window.resizeTo(542,484);
  searchForm.FindCode.focus();

  function clearForm(){
    searchForm.FindCode.value = "";
    searchForm.FindText.value = "";
    
    searchForm.FindCode.focus();
  }

  function doFind(){
    ToggleFloatingLayer("FloatingLayer",1);
    searchForm.FindButton.disabled = true;
    searchForm.submit();
  }
  
  <%-- SELECT LABANALYSIS --%>
  function selectLabAnalysis(sID,sType,sCode,sText){
	<%
	    if(sVarID.length() > 0){
            %>if(window.opener.document.getElementsByName('<%=sVarID%>')[0]) window.opener.document.getElementsByName('<%=sVarID%>')[0].value = sID;<%
	    }
	    if(sVarType.length() > 0){
	    	%>if(window.opener.document.getElementsByName('<%=sVarType%>')[0]) window.opener.document.getElementsByName('<%=sVarType%>')[0].value = sType;<%    	
	    }
	    if(sVarCode.length() > 0){
	    	%>if(window.opener.document.getElementsByName('<%=sVarCode%>')[0]) window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sCode;<%    	
	    }
	    if(sVarText.length() > 0){ // value
	    	%>if(window.opener.document.getElementsByName('<%=sVarText%>')[0]) window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sText;<%    	
	    }
	    if(sVarText.length() > 0){ // title
	    	%>if(window.opener.document.getElementsByName('<%=sVarText%>')[0]) window.opener.document.getElementsByName('<%=sVarText%>')[0].title = sText;<%   	
	    }
	    if(sVarTextHtml.length() > 0){ // id !
            %>if(window.opener.document.getElementById('<%=sVarTextHtml%>')) window.opener.document.getElementById('<%=sVarTextHtml%>').innerHTML = sText;<%
	    }

        if(sCodeOther.equals("1")){
            %>
            	if(window.opener.document.getElementsByName('LabComment')[0]) window.opener.document.getElementsByName('LabComment')[0].readOnly = false;
             	if(window.opener.document.getElementsByName('LabComment')[0]) window.opener.document.getElementsByName('LabComment')[0].focus();
            	if(window.opener.document.getElementsByName('LabCodeOther')[0]) window.opener.document.getElementsByName('LabCodeOther')[0].value = "1";
            <%
        }
        else{
            %>if(window.opener.document.getElementsByName('LabComment')[0]) window.opener.document.getElementsByName('LabComment')[0].readOnly = true;<%
        }
    %>

    window.close();
  }
    
  <%-- SELECT LABANALYSIS GROUP --%>
  function selectLabAnalysisGroup(sID,sCode,sText){
    if(window.opener.document.getElementsByName('<%=sVarCode%>')[0]) window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = "^"+sCode;
    if(window.opener.document.getElementById('<%=sVarTextHtml%>')) window.opener.document.getElementById('<%=sVarTextHtml%>').innerHTML = "<img width='16px' src='_img/multiple.gif'/> - "+sText;

    window.close();
  }
</script>