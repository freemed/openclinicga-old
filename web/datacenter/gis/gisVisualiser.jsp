<%@page import="uk.org.primrose.pool.core.*,
                be.mxs.common.util.db.MedwanQuery,
                be.mxs.common.util.system.Debug,
                be.mxs.common.util.system.ScreenHelper,
                java.util.*,
                java.io.*,
                java.sql.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSDATE%>

<%=sFAVICON%>
<%=sJSTOGGLE%>
<%=sJSFORM%>
<%=sJSPOPUPMENU%>
<%=sJSPROTOTYPE %>
<%=sJSAXMAKER %>
<%=sJSPROTOCHART %>
<%=sJSEXCANVAS %>
<%=sJSFUSIONCHARTS%>
<%=sJSAXMAKER %>
<%=sJSSCRPTACULOUS %>
<%=sJSMODALBOX%>
<%=sCSSDATACENTER%>
<%=sCSSMODALBOXDATACENTER%>
<%=sCSSDATACENTERIE%>

<%
    
    if(session.getAttribute("datacenteruser")!=null){
        out.write("<link href='"+sCONTEXTPATH+"/_common/_css/datacenter_"+session.getAttribute("datacenteruser")+".css' rel='stylesheet' type='text/css'>");
    }
%>

<script><%=getUserInterval(session,activeUser)%></script>

<%!
    //--- PARAMETER REQUIRES DIAGNOSIS ------------------------------------------------------------
    private boolean parameterRequiresDiagnosis(String sParameter){
        return sParameter.startsWith("vis.counter.7") || sParameter.startsWith("vis.counter.8.");
    }

    //--- HAS RELATIVE RESULT ---------------------------------------------------------------------
    private boolean hasRelativeResult(String sParameter){
        //return (parametersWithRelativeResult.get(sParameter)!=null);
        return (sParameter.equalsIgnoreCase("vis.counter.8.1") || sParameter.equalsIgnoreCase("vis.counter.9"));
    }    
  
	//--- STRING TO VECTOR ------------------------------------------------------------------------
	private Vector stringToVector(String sString, String sDelimeter){
	    return stringToVector(sString,sDelimeter,true);
    }

	private Vector stringToVector(String sString, String sDelimeter, boolean removeApostrophes){
	    Vector vector = new Vector();
	    
	    StringTokenizer tokenizer = new StringTokenizer(sString,sDelimeter);
	    String sValue;
	    while(tokenizer.hasMoreTokens()){
	    	sValue = (String)tokenizer.nextToken();
	    	if(removeApostrophes) sValue = sValue.replaceAll("","");
	        vector.add(sValue);        	
	    }	
	    
	    return vector;
	}

	//--- VECTOR TO STRING ------------------------------------------------------------------------
	private String vectorToString(Vector vector, String sDelimeter){
	    return vectorToString(vector,sDelimeter,true);
	}
	
	private String vectorToString(Vector vector, String sDelimeter, boolean addApostrophes){
		StringBuffer stringBuffer = new StringBuffer();
	    
	    for(int i=0; i<vector.size(); i++){
	    	if(addApostrophes) stringBuffer.append("'");
	        stringBuffer.append((String)vector.get(i));	        
	    	if(addApostrophes) stringBuffer.append("'");
	        
	        if(i<vector.size()){
	        	stringBuffer.append(sDelimeter);
	        }
	    }		    
	    
	    return stringBuffer.toString();
	}

    //--- GET SERVER GROUP IDS --------------------------------------------------------------------
    private Vector getServerGroupIds(){
	    Vector serverGroupIds = new Vector();
	    
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    	    
	    try{
	    	String sSql = "SELECT DISTINCT dc_servergroup_id"+
	                      " FROM dc_servergroups"+
	                      "  ORDER BY dc_servergroup_id";
			conn = MedwanQuery.getInstance().getOpenclinicConnection();
			ps = conn.prepareStatement(sSql);
			rs = ps.executeQuery();
			
			while(rs.next()){
				serverGroupIds.add(new Integer(rs.getInt("dc_servergroup_id")));
			}
	    }
	    catch(Exception e){
	    	e.printStackTrace();
	    }
	    finally{
	    	try{
	    		if(rs!=null) rs.close();
	    		if(ps!=null) ps.close();
	    		if(conn!=null) conn.close();
	    	}
	    	catch(Exception e){
	    		e.printStackTrace();
	    	}
	    }
	    
	    return serverGroupIds;
    }

    //--- GET DIAGNOSIS CODES AND LABELS ----------------------------------------------------------
    // code + label in 'en', 'fr' or 'nl'
    private Hashtable getDiagnosisCodesAndLabels(String sLabelLang){
    	Hashtable diagnoses = new Hashtable();
    		    
	    Connection conn = null;
	    PreparedStatement ps = null;
	    ResultSet rs = null;
	    	    
	    try{
	    	String sSql = "SELECT DISTINCT c.code, c.label"+sLabelLang+" AS label"+
	                      " FROM icd10 c, oc_diagnosis_groups g"+
	                      "  WHERE c.code = g.oc_diagnosis_groupcode";
			conn = MedwanQuery.getInstance().getOpenclinicConnection();
			ps = conn.prepareStatement(sSql);
			rs = ps.executeQuery();
			
			while(rs.next()){
				diagnoses.put(rs.getString("code"),rs.getString("label"));
			}
	    }
	    catch(Exception e){
	    	e.printStackTrace();
	    }
	    finally{
	    	try{
	    		if(rs!=null) rs.close();
	    		if(ps!=null) ps.close();
	    		if(conn!=null) conn.close();
	    	}
	    	catch(Exception e){
	    		e.printStackTrace();
	    	}
	    }
    	
    	return diagnoses;
    }
%>

<%
    String sAction = ScreenHelper.checkString(request.getParameter("Action"));

    // form-data
    String sDateFrom = ScreenHelper.checkString(request.getParameter("dateFrom")),
           sDateTo   = ScreenHelper.checkString(request.getParameter("dateTo"));

	String sServerGroupIds = ScreenHelper.checkString(request.getParameter("serverGroupIds")),
		   sParameter      = ScreenHelper.checkString(request.getParameter("parameter")),
		   sDiagnosisCode  = ScreenHelper.checkString(request.getParameter("diagnosisCode")),
		   sGraphType      = ScreenHelper.checkString(request.getParameter("graphType"));

    String jsonFileId = Long.toString(System.currentTimeMillis()); //request.getSession().getId();
    
	/// DEBUG /////////////////////////////////////////////////////////////////
	Debug.enabled = true; // todoooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo
	if(Debug.enabled){
		Debug.println("********* datacenter/gis/gisVisualiser.jsp **********");
		Debug.println("sAction         : "+sAction);
		Debug.println("sDateFrom       : "+sDateFrom);
		Debug.println("sDateTo         : "+sDateTo);
		Debug.println("sServerGroupIds : "+sServerGroupIds);
		Debug.println("sParameter      : "+sParameter);
		Debug.println("sDiagnosisCode  : "+sDiagnosisCode);
		Debug.println("sGraphType      : "+sGraphType);
		Debug.println("jsonFileId (no param) : "+jsonFileId+"\n");
	}
	///////////////////////////////////////////////////////////////////////////
	
	if(sDateTo.length()==0){
	    sDateTo = ScreenHelper.stdDateFormat.format(new java.util.Date());
	}
%>

<%-- ACTUAL PAGE --%>
<form name="gisForm" method="post" action="<c:url value='datacenterHome.jsp'/>?p=gis/gisVisualiser.jsp&ts=<%=getTs()%>">
    <%-- hidden fields --%>
    <input type="hidden" name="Action" value="popupGISData" />
    <input type="hidden" name="serverGroupIds" value="" />
  
    <%-- TITLE --%>
    <div class="landlist">
        <h3><%=getTran("datacenter","gisVisualiser",sWebLanguage)%></h3>
        
    	<div class="subcontent">
    <table class="content" width="100%" cellpadding="1" cellspacing="0" border="0">    
        <%-- DATES (from & to) --%>
        <tr>
            <td> 
	            <%=getTran("datacenter","dateFrom",sWebLanguage)%>&nbsp;  
                <span id="dateFromDiv" style="vertical-align:top;border:1px solid #fff;padding:1px;">
	                <%=writeDateField("dateFrom","gisForm",sDateFrom,sWebLanguage)%>
	            </span>                
            </td>
            <td> 
                <%=getTran("datacenter","dateTo",sWebLanguage)%>&nbsp;
                <span id="dateToDiv" style="vertical-align:top;border:1px solid #fff;padding:1px;"> 
	                <%=writeDateField("dateTo","gisForm",sDateTo,sWebLanguage)%>  
	            </span>          
            </td>
        </tr>
    
        <%-- AVAILABLE SERVER GROUPS --%>
        <tr>
            <td width="200" style="vertical-align:top;">
                <%=getTran("datacenter","serverGroups",sWebLanguage)%>&nbsp;<br>
                <select name="availableServerGroupIds" id="availableServerGroupIds">
                    <option value=""><%=MedwanQuery.getInstance().getLabel("datacenter","choose",sWebLanguage)%></option> 
                    <%
                        Vector serverGroupIds = getServerGroupIds();                    
                        String sGroupName;
                        int groupId;
                        
                        for(int i=0; i<serverGroupIds.size(); i++){
                        	groupId = ((Integer)serverGroupIds.get(i)).intValue();
                        	sGroupName = MedwanQuery.getInstance().getLabel("datacenterServerGroup",Integer.toString(groupId),sWebLanguage);
                        	
                            %><option value="<%=groupId%>"><%=sGroupName%></option><%	
                        }                    
                    %>
                </select>
                
                <%-- arrows --%>
                <input type="button" class="button" id="addButton" value=" > " onClick="addServerGroup();">
                <input type="button" class="button" id="addButtonAll" value=" >> " onClick="addAllServerGroups();"> 
            </td>
            
            <%-- CHOSEN SERVER GROUPS --%>
            <td width="*">
                <%=getTran("datacenter","serverGroupsToDisplay",sWebLanguage)%>&nbsp;<br>
                
                <%-- arrows --%>
                <span style="vertical-align:top;">
                    <input type="button" class="button" id="removeButton" value=" < " onClick="removeServerGroup();">
                    <input type="button" class="button" id="removeButtonAll" value=" << " onClick="removeAllServerGroups();">
                </span> 
                
                <span id="serverGroupsDiv" style="vertical-align:top;border:1px solid #fff;padding:1px;">
	                <select name="chosenServerGroupIds" id="chosenServerGroupIds" size="6" style="width:150px;">
	                    <%                               
	                        serverGroupIds = stringToVector(sServerGroupIds,";");
	                        String sGroupId;
	                    
	                        for(int i=0; i<serverGroupIds.size(); i++){
	                        	sGroupId = (String)serverGroupIds.get(i);
	                        	sGroupName = MedwanQuery.getInstance().getLabel("datacenterServerGroup",sGroupId,sWebLanguage);
	                        	
	                            %><option value="<%=sGroupId%>"><%=sGroupName%></option><%	
	                        }                    
	                    %>
	                </select>
                </span> 
            </td>
        </tr>
    
        <%-- PARAMETER (type of data to visualize) --%>   
        <tr>
            <td><%=getTran("datacenter","parameter",sWebLanguage)%>&nbsp;</td>            
            <td class="admin2">
                <span id="parameterDiv" style="border:1px solid #fff;padding:1px;">
	                <select name="parameter" onChange="toggleDates(this.options[this.selectedIndex].value);toggleDiagnoses(this.options[this.selectedIndex].value);">   
	                    <option value=""><%=MedwanQuery.getInstance().getLabel("datacenter","choose",sWebLanguage)%></option>               
	                    <%                               
	                        Vector parameters = new Vector();
	
	                        // todo : selected by FVE or query on labels ?
	                        parameters.add("vis.counter.0");     // core.1   
	                        parameters.add("vis.counter.0.0");   // core.1
	                        parameters.add("vis.counter.1");     // core.2
	                        parameters.add("vis.counter.2");     // core.4.1
	                        parameters.add("vis.counter.2.0");   // core.4.1
	                        parameters.add("vis.counter.3");     // core.4.2
	                        parameters.add("vis.counter.3.0");   // core.4.2
	                        parameters.add("vis.counter.4");     // core.5
	                        parameters.add("vis.counter.4.0");   // core.5
	                        parameters.add("vis.counter.5");     // core.11
	                        parameters.add("vis.counter.5.0");   // core.11
	                        parameters.add("vis.counter.6");     // core.17
	                        parameters.add("vis.counter.6.0");   // core.17
	                        
	                        parameters.add("vis.counter.7");     // dc_encounterdiagnosisvalues
	                        parameters.add("vis.counter.7.0");   // dc_encounterdiagnosisvalues; codetype=KPGS ; code=X ; type=admission OR visit
	                        parameters.add("vis.counter.7.0.0"); // dc_encounterdiagnosisvalues; codetype=KPGS ; code=X ; type=admission 
	                        parameters.add("vis.counter.7.1");   // dc_encounterdiagnosisvalues; codetype=KPGS ; code=X ; type=admission 
	                        parameters.add("vis.counter.7.1.0"); // dc_encounterdiagnosisvalues; codetype=KPGS ; code=X ; type=visit
	                        
	                        parameters.add("vis.counter.8");     // dc_mortalityvalues; aantal nieuwe overlijdens (t1-t0)
	                        parameters.add("vis.counter.8.0");   // dc_mortalityvalues ; codetype=KPGS ; code=X	
	                        parameters.add("vis.counter.8.1");   // dc_mortalityvalues ; codetype=KPGS ; code=X	(relative)
	                        
	                        parameters.add("vis.counter.9");     // dc_bedoccupancyvalues
	                        parameters.add("vis.counter.10");    // dc_financialvalues ; parameterid=financial.0
	                        parameters.add("vis.counter.10.0");  // dc_financialvalues ; parameterid=financial.1
	                        parameters.add("vis.counter.10.1");  // dc_financialvalues ; parameterid=financial.2
	                        parameters.add("vis.counter.10.2");  // dc_financialvalues ; parameterid=financial.3
	                    
	                        String sParamId, sParamName;
	                        for(int i=0; i<parameters.size(); i++){
	                        	sParamId = (String)parameters.get(i);
	                        	sParamName = MedwanQuery.getInstance().getLabel("vis.counter",sParamId,sWebLanguage);
	                        	
	                            %><option value="<%=sParamId%>" <%=(sParamId.equals(sParameter)?"selected":"")%>><%=sParamName%></option><%	
	                        }       
	                    %>
	                </select>
                </span> 
            </td>  
        </tr>  
        
        <%-- DIAGNOSIS CODES (mainly KPGS) --%>   
        <tr id="diagnoses" style="display:none;">
            <td><%=getTran("datacenter","diagnosis",sWebLanguage)%>&nbsp;</td>            
            <td class="admin2">
                <span id="diagnosisCodeDiv" style="border:1px solid #fff;padding:1px;">
	                <select name="diagnosisCode">  
	                    <option value=""><%=MedwanQuery.getInstance().getLabel("datacenter","choose",sWebLanguage)%></option>               
	                    <%            
	                        Hashtable diagnoses = getDiagnosisCodesAndLabels(sWebLanguage);
	                        
	                        Vector codes = new Vector(diagnoses.keySet());
	                        Collections.sort(codes);
	                    
	                        String sTmpDiagnosisCode, sTmpDiagnosisName;                                            
	                        for(int i=0; i<codes.size(); i++){
	                        	sTmpDiagnosisCode = (String)codes.get(i);
	                        	sTmpDiagnosisName = (String)diagnoses.get(sTmpDiagnosisCode);
	                        	
	                        	if(sTmpDiagnosisName.length() > 80){
	                        	    sTmpDiagnosisName = sTmpDiagnosisName.substring(0,80)+"..";
	                        	}
	                        	
	                            %><option value="<%=sTmpDiagnosisCode%>" <%=(sTmpDiagnosisCode.equals(sDiagnosisCode)?"selected":"")%>><%=sTmpDiagnosisCode+" - "+sTmpDiagnosisName%></option><%	
	                        }                    
	                    %>
	                </select>
	            </span>
            </td>   
        </tr>              
    
        <%-- GRAPH TYPE --%>
        <tr>
            <td><%=getTran("datacenter","graphType",sWebLanguage)%>&nbsp;</td>            
            <td class="admin2">
                <span id="graphTypeDiv" style="border:1px solid #fff;padding:1px;">
	                <select name="graphType">                 
	                    <option value=""><%=MedwanQuery.getInstance().getLabel("datacenter","choose",sWebLanguage)%></option>
	                    
	                    <option value="circles" <%=(sGraphType.equals("circles")?"selected":"")%>><%=MedwanQuery.getInstance().getLabel("datacenter","circles",sWebLanguage)%></option>
	                    <option value="clusterer" <%=(sGraphType.equals("clusterer")?"selected":"")%>><%=MedwanQuery.getInstance().getLabel("datacenter","clusterer",sWebLanguage)%></option>
	                    <option value="customMarker" <%=(sGraphType.equals("customMarker")?"selected":"")%>><%=MedwanQuery.getInstance().getLabel("datacenter","customMarker",sWebLanguage)%></option>
                        <option value="mapChart" <%=(sGraphType.equals("mapChart")?"selected":"")%>><%=MedwanQuery.getInstance().getLabel("datacenter","mapChart",sWebLanguage)%></option>
	                </select>
	            </span>
            </td>            
        </tr>
    </table>
    
    	</div>
    </div>
        
    <%-- spacer --%>
	<div style="padding-top:10px;"></div>
	
	<%-- BUTTONS --%>
	<div id="buttonsDiv" style="display:block;">
	    <input type="button" class="button" id="submitButton" style="width:150px" value="<%=MedwanQuery.getInstance().getLabel("datacenter","showMap",sWebLanguage)%>" onClick="doSubmit();">
	    <input type="button" class="button" id="clearButton" value="<%=MedwanQuery.getInstance().getLabel("web","clear",sWebLanguage)%>" onClick="doClear();">
	</div> 
	
    <%-- spacer --%>
	<div style="padding-top:10px;"></div>
	
	<%-- MESSAGE --%>
	<div id="msgDiv" style="height:20px;padding-left:1px;"><%-- javascript --%></div>	
</form>

<script>
  <%
	  if(parameterRequiresDiagnosis(sParameter)){
	      out.print("document.getElementById('diagnoses').style.display = 'block';");
      }
  %>
  gisForm.dateFrom.focus();

  var parametersRequiringDateFrom = {"vis.counter.0.0":1,"vis.counter.2.0":1,"vis.counter.3.0":1,"vis.counter.4.0":1,
		                             "vis.counter.5.0":1,"vis.counter.6.0":1,"vis.counter.7.0.0":1,"vis.counter.7.1.0":1,
		                             "vis.counter.8":1,"vis.counter.8.0":1,"vis.counter.8.1":1,"vis.counter.10":1,
		                             "vis.counter.10.0":1,"vis.counter.10.1":1,"vis.counter.10.2":1};

  var parametersWithRelativeResult = {"vis.counter.8.1":1,"vis.counter.9":1}; // percentage, all others are integer
  
  var parameterSelect = document.getElementById("parameter");
  toggleDates(parameterSelect.options[parameterSelect.selectedIndex].value);
  
  <%-- ADD SERVER GROUP --%>
  function addServerGroup(){
	var pool1 = document.getElementById("availableServerGroupIds"),
	  	pool2 = document.getElementById("chosenServerGroupIds");
	
	if(pool1.selectedIndex==0) return;
	var selectedOptionValue = pool1.options[pool1.selectedIndex].value;
	
	if(!allreadySelected(selectedOptionValue)){
	  pool2.options[pool2.options.length] = new Option(pool1.options[pool1.selectedIndex].text,pool1.options[pool1.selectedIndex].value);
      document.getElementById("serverGroupsDiv").style.border = "1px solid #fff";
	}
  }

  <%-- ADD ALL SERVER GROUPS --%>
  function addAllServerGroups(){
	var pool1 = document.getElementById("availableServerGroupIds"),
	  	pool2 = document.getElementById("chosenServerGroupIds");
	
	for(var i=1; i<pool1.options.length; i++){  
	  if(!allreadySelected(pool1.options[i].value)){    
	    pool2.options[pool2.options.length] = new Option(pool1.options[i].text,pool1.options[i].value);
	  }
	}
	
    document.getElementById("serverGroupsDiv").style.border = "1px solid #fff";
  }
  
  <%-- REMOVE SERVER GROUP --%>
  function removeServerGroup(){
	var pool2 = document.getElementById("chosenServerGroupIds");

	if(pool2.selectedIndex < 0) return;	
	pool2.remove(pool2.selectedIndex);
  }
  
  <%-- REMOVE ALL SERVER GROUPS --%>
  function removeAllServerGroups(){
	var pool2 = document.getElementById("chosenServerGroupIds");
	pool2.options.length = 0;
  }
  
  <%-- ALLREADY SELECTED --%>
  function allreadySelected(optionValue){
	var pool2 = document.getElementById("chosenServerGroupIds");
	var found = false;

	for(var i=0; i<pool2.options.length; i++){
	  if(pool2.options[i].value==optionValue){
		found = true;
	  }
	}
	
	return found;
  }
  
  <%-- TOGGLE DATES --%>
  function toggleDates(selectedParameter){	
	if(parameterRequiresDateFrom(selectedParameter)){
	  gisForm.dateFrom.disabled = false;
	  gisForm.dateFrom.style.background = "#ffffff";
	}
	else{
      gisForm.dateFrom.value = "";
	  gisForm.dateFrom.disabled = true;
	  gisForm.dateFrom.style.background = "#cccccc";
	}
  }

  <%-- PARAMETER REQUIRES DATE FROM --%>
  function parameterRequiresDateFrom(selectedParameter){	  
	return (parametersRequiringDateFrom[selectedParameter]!=null);   
  }

  <%-- TOGGLE DIAGNOSES --%>
  function toggleDiagnoses(selectedParameter){
	if(parameterRequiresDiagnosis(selectedParameter)){
	  document.getElementById("diagnoses").style.display = "block";
	  document.getElementById("diagnosisCode").focus();
	}
	else{		
	  document.getElementById("diagnoses").style.display = "none";
	}
	
    document.getElementById("diagnosisCode").selectedIndex = 0;
  }
  
  <%-- PARAMETER REQUIRES DIAGNOSIS --%>
  function parameterRequiresDiagnosis(sParameter){
	return (sParameter.startsWith("vis.counter.7") || sParameter.startsWith("vis.counter.8."));
  }
 
  <%-- OPEN GIS MAP --%>
  var gisWin = null;
  
  function openGISMap(parameter,mapType){
	if(gisWin) gisWin.close();  
	  
	if(mapType=="mapChart"){
	  var url = "<c:url value='/'/>datacenter/gis/googleMaps/"+mapType+"_<%=jsonFileId%>.html";
	  gisWin = window.open(url,"GISVisualiser","toolbar=no,status=no,scrollbars=yes,resizable=yes,width=690,height=510,menubar=no");
	}
	else{
	  var dataType = "";
	  if(hasRelativeResult(parameter)){
        dataType = "Percentage";
      }
		  
	  var url = "<c:url value='/'/>datacenter/gis/googleMaps/"+mapType+dataType+"_<%=jsonFileId%>.html";
	  gisWin = window.open(url,"GISVisualiser","toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=890,height=630,menubar=no"); // remove status bar
	}
	
	gisWin.focus();
  }
  
  <%-- HIDE BORDERS --%>
  function hideBorders(){
	document.getElementById("dateFromDiv").style.border = "1px solid #fff";
	document.getElementById("dateToDiv").style.border = "1px solid #fff";
	document.getElementById("serverGroupsDiv").style.border = "1px solid #fff";
	document.getElementById("parameterDiv").style.border = "1px solid #fff";
	document.getElementById("diagnosisCodeDiv").style.border = "1px solid #fff";
	document.getElementById("graphTypeDiv").style.border = "1px solid #fff";
  }
  
  <%-- DO SUBMIT --%>
  function doSubmit(){
	var okToSubmit = true;
	hideBorders();  
	
	document.getElementById("msgDiv").innerHTML = "";
    gisForm.serverGroupIds.value = concatChosenServerGroupIds();

    <%-- check dates first --%>
    if(gisForm.dateFrom.disabled==false && gisForm.dateTo.disabled==false){
      if((gisForm.dateFrom.value.length>0 && gisForm.dateTo.value.length>0) && after(gisForm.dateFrom.value,gisForm.dateTo.value)){
    	errorMsg("<%=MedwanQuery.getInstance().getLabel("web.occup","endMustComeAfterBegin",sWebLanguage)%>");   	 
        gisForm.dateTo.focus();
        okToSubmit = false;
      }
    }
    
    if(okToSubmit){
      <%-- check data completeness --%>
	  if((gisForm.dateFrom.disabled==true || (gisForm.dateFrom.disabled==false && gisForm.dateFrom.value.length > 0)) &&
	     (gisForm.dateTo.disabled==true || (gisForm.dateTo.disabled==false && gisForm.dateTo.value.length > 0)) && 
	     gisForm.serverGroupIds.value.length > 0 &&
	     gisForm.parameter.selectedIndex > 0 && 
	     (!parameterRequiresDiagnosis(gisForm.parameter.options[gisForm.parameter.selectedIndex].value) ||
	       parameterRequiresDiagnosis(gisForm.parameter.options[gisForm.parameter.selectedIndex].value) && gisForm.diagnosisCode.selectedIndex > 0) &&
	     gisForm.graphType.selectedIndex > 0
      ){       
		gisForm.submitButton.disabled = true;
        gisForm.clearButton.disabled = true;
        gisForm.submit();		
      }
	  else{		
	    if((gisForm.dateFrom.disabled==false && gisForm.dateFrom.value.length==0)){
	      gisForm.dateFrom.focus();
		  document.getElementById("dateFromDiv").style.border = "1px solid #cc0000";
	    }
	    else if((gisForm.dateTo.disabled==false && gisForm.dateTo.value.length==0)){
	      gisForm.dateTo.focus();
		  document.getElementById("dateToDiv").style.border = "1px solid #cc0000";
	    }
	    else if(gisForm.serverGroupIds.value.length==0){
	      document.getElementById("serverGroupsDiv").style.border = "1px solid #cc0000";
	    }
	    else if(gisForm.parameter.selectedIndex==0){
		  document.getElementById("parameterDiv").style.border = "1px solid #cc0000";
	    }
	    else if(parameterRequiresDiagnosis(gisForm.parameter.value) && gisForm.diagnosisCode.selectedIndex==0){
		  document.getElementById("diagnosisCodeDiv").style.border = "1px solid #cc0000";
		}
	    else if(gisForm.graphType.value.length==0){
		  document.getElementById("graphTypeDiv").style.border = "1px solid #cc0000";
		}

	    errorMsg("<%=MedwanQuery.getInstance().getLabel("web.manage","dataMissing",sWebLanguage)%>");
	    gisForm.serverGroupIds.value = "";
	  }
	}
  }
  
  <%-- DO CLEAR --%>
  function doClear(){
	hideBorders();
    errorMsg("");

	gisForm.dateFrom.disabled = false;
	gisForm.dateFrom.style.background = "#ffffff";
	gisForm.dateFrom.value = "";
    gisForm.dateFrom.focus();
	  
	gisForm.dateTo.disabled = false;
	gisForm.dateTo.style.background = "#ffffff";
	gisForm.dateTo.value = "";
	
	gisForm.parameter.selectedIndex = 0;
	gisForm.diagnosisCode.selectedIndex = 0;
	gisForm.graphType.selectedIndex = 0;
	
	removeAllServerGroups();
  }
  
  <%-- CONCAT CHOSEN SERVER GROUP IDS (;) --%>
  function concatChosenServerGroupIds(){
	var pool2 = document.getElementById("chosenServerGroupIds");
	var concatValue = "";
	
	for(var i=0; i<pool2.options.length; i++){
	  concatValue+= pool2.options[i].value+";";
	}  
	
	return concatValue;
  }
  
  <%-- OPEN POPUP --%>
  function openPopup(page,width,height,title){
    var url = "<c:url value='/popup.jsp'/>?Page="+page;
    
    if(width!=undefined) url+= "&PopupWidth="+width;
    if(height!=undefined) url+= "&PopupHeight="+height;
    if(title==undefined){
      if(page.indexOf("&") < 0){
        title = page.replace("/", "_");
        title = replaceAll(title, ".", "_");
      }
      else{
        title = replaceAll(page.substring(1,page.indexOf("&")),"/","_");
        title = replaceAll(title,".","_");
      }
    }
   
    var w = window.open(url,title,"toolbar=no,status=no,scrollbars=yes,resizable=no,width=1,height=1,menubar=no");
    w.moveBy(2000,2000);
  }

  <%-- ERROR MSG --%>
  function errorMsg(sMsg){
    document.getElementById("msgDiv").style.display = "block";
	document.getElementById("msgDiv").innerHTML = "<font color='red'>"+sMsg+"</font>";
  }
  
  <%-- NORMAL MSG --%>
  function normalMsg(sMsg){
    document.getElementById("msgDiv").style.display = "block";
	document.getElementById("msgDiv").innerHTML = sMsg;
  }

  <%-- REPLACE ALL --%>
  function replaceAll(s,s1,s2){
    while(s.indexOf(s1) > -1){
      s = s.replace(s1,s2);
    }
      
    return s;
  }
  
  <%-- HAS RELATIVE RESULT --%>
  function hasRelativeResult(sParameter){
    return (parametersWithRelativeResult[sParameter]!=null);    	  
  }  

  <%-- SHOW IN PROGRESS ICON --%>
  function showInProgressIcon(){
	document.getElementById("buttonsDiv").style.display = "none";
    document.getElementById("msgDiv").style.display = "block";
    document.getElementById("msgDiv").innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/ajax-loader.gif'>";
  }
  
  <%-- HIDE IN PROGRESS ICON --%>
  function hideInProgressIcon(){
	document.getElementById("buttonsDiv").style.display = "block";
    document.getElementById("msgDiv").style.display = "none";
    document.getElementById("msgDiv").innerHTML = "";
  }  
</script>

<%-- CALENDAR FRAMES --%>
<iframe width="174" height="189" name="gToday:normal1:agenda.js:gfPop1" id="gToday:normal1:agenda.js:gfPop1"
        src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
        style="visibility:visible; z-index:999; position:absolute; top:-200px; left:-200px;">
</iframe>
<iframe width="174" height="189" name="gToday:normal2:agenda.js:gfPop2" id="gToday:normal2:agenda.js:gfPop2"
        src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
        style="visibility:visible; z-index:999; position:absolute; top:-200px; left:-200px;">
</iframe>
<iframe width="174" height="189" name="gToday:normal3:agenda.js:gfPop3" id="gToday:normal3:agenda.js:gfPop3"
        src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
        style="visibility:visible; z-index:999; position:absolute; top:-200px; left:-200px;">
</iframe>

<%	
	//--- POPUP GIS DATA --------------------------------------------------------------------------
	if(sAction.equals("popupGISData")){
		%><script>window.clearInterval(userinterval);</script><%
	    %><script>showInProgressIcon();</script><%
	    status(out,"Compiling map-data..");
		
		// generate JSON file containing data about services in selected serviceGroups		
		String sUrl = "/datacenter/gis/createJSON.jsp"+
	                  "?dateFrom="+sDateFrom+
			          "&dateTo="+sDateTo+
			          "&serverGroupIds="+sServerGroupIds+
			          "&parameter="+sParameter+
			          "&diagnosisCode="+sDiagnosisCode+	
			          "&graphType="+sGraphType+
			          "&jsonFileId="+jsonFileId;		
		ScreenHelper.setIncludePage(sUrl,pageContext);
		
		// open file containing the appropriate javascript code to visualise the data in the generated JSON		
		//String sContextPath = MedwanQuery.getInstance().getConfigString("contextpath");
		String sContextPath = sAPPFULLDIR; // todooooooooooooooooooooo
	    String sFileDir = sContextPath+"/datacenter/gis/googleMaps";
		String sFileName;

    	// circles|clusterer|customMarker|mapChart|heatMap|heatMapWeighted
		if(sGraphType.equals("mapChart")){
			sFileName = "/mapChart_"+jsonFileId+".html";
		}
		else{
			sFileName = "/data/gisData_"+jsonFileId+".json"; 	

			String sDataType = "";
			if(hasRelativeResult(sParameter)){
		        sDataType = "Percentage";
		    }
			
			// generate specific html page (from static page)
			sUrl = "/datacenter/gis/createHTML.jsp"+
		           "?htmlPage="+sGraphType+sDataType+".html"+
			       "&jsonFileId="+jsonFileId;
			ScreenHelper.setIncludePage(sUrl,pageContext);	
		}
		
	    File fileContainingData = new File(sFileDir+sFileName);
	    boolean fileFound = fileContainingData.exists();
	    	    
	    // here because 'defer' does not always work
		if(fileFound){
		    out.print("<script defer>openGISMap('"+sParameter+"','"+sGraphType+"');</script>");
		}
		else{
			out.print("<script defer>errorMsg('"+MedwanQuery.getInstance().getLabel("datacenter","noDataFound",sWebLanguage)+"');</script>");
		}
	
	    %><script>hideInProgressIcon();</script><%
	    status(out,"Done");
	}
%>
