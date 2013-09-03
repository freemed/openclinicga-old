<%@ page import="be.openclinic.medical.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("lab.procedures","edit",activeUser)%>

<%
	String sAction = checkString(request.getParameter("Action"));
	String msg = "";

	String sFindLabProcedureName=checkString(request.getParameter("FindLabProcedureName"));
	
	String sEditLabProcedureUid=checkString(request.getParameter("EditLabProcedureUid"));
	String sEditLabProcedureName=checkString(request.getParameter("EditLabProcedureName"));
	String sEditMinBatchSize=checkString(request.getParameter("EditMinBatchSize"));
	try{
		sEditMinBatchSize=""+Integer.parseInt(sEditMinBatchSize);
	}
	catch(Exception e){sEditMinBatchSize="1";};
	String sEditMaxBatchSize=checkString(request.getParameter("EditMaxBatchSize"));
	try{
		sEditMaxBatchSize=""+Integer.parseInt(sEditMaxBatchSize);
	}
	catch(Exception e){sEditMaxBatchSize="1";};
	String sEditMaxDelayInDays=checkString(request.getParameter("EditMaxDelayInDays"));
	try{
		sEditMaxDelayInDays=""+Integer.parseInt(sEditMaxDelayInDays);
	}
	catch(Exception e){sEditMaxDelayInDays="1";};
	
	String sEditReagents=checkString(request.getParameter("EditReagents"));
	
    if(sAction.equals("save")){
    	LabProcedure procedure;
    	if(sEditLabProcedureUid.length()>0 && sEditLabProcedureUid.split("\\.").length==2){	
    		procedure=LabProcedure.get(sEditLabProcedureUid);
    	}
    	else {
            procedure = new LabProcedure();
            procedure.setUpdateUser(activeUser.userid);
    	}
    	//Store procedure
    	procedure.setMaxBatchSize(Integer.parseInt(sEditMaxBatchSize));
    	procedure.setMinBatchSize(Integer.parseInt(sEditMinBatchSize));
    	procedure.setMaxDelayInDays(Integer.parseInt(sEditMaxDelayInDays));
    	procedure.setName(sEditLabProcedureName);
    	procedure.setUpdateUser(activeUser.userid);
    	Vector procedurereagents = new Vector();
    	//Add reagents
    	String[] reagents = sEditReagents.split("\\$");
    	for(int n=0;n<reagents.length;n++){
    		if(reagents[n].split("\\|").length>=2){
    			LabProcedureReagent reagent = new LabProcedureReagent();
    			reagent.setReagentuid(reagents[n].split("\\|")[0]);
    			reagent.setQuantity(Double.parseDouble(reagents[n].split("\\|")[1]));
        		if(reagents[n].split("\\|").length>=5){
	    			reagent.setConsumptionType(reagents[n].split("\\|")[4]);
        		}
    			procedurereagents.add(reagent);
    		}
    	}
    	procedure.setReagents(procedurereagents);
    	procedure.store();
    	sEditLabProcedureUid=procedure.getUid();
        msg = getTran("web","dataIsSaved",sWebLanguage);
        sAction = "search";
    }
    if(sAction.equals("delete")){
        LabProcedure.delete(sEditLabProcedureUid);
        msg = getTran("web","dataIsDeleted",sWebLanguage);
    }
    
%>

<form id="transactionForm" name="transactionForm" onsubmit="return false;" method="post" >
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditLabProcedureUid" id="EditLabProcedureUid" value="<%=sEditLabProcedureUid%>"/>
    <%=writeTableHeader("Web.manage","ManageLabProcedures",sWebLanguage,"")%>

    <%-- SEARCH FIELDS --%>
    <table width="100%" class="menu" cellspacing="0">
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web","name",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindLabProcedureName" size="20" maxlength="50" value="<%=sFindLabProcedureName%>">
            </td>
        </tr>
        <tr>
           <td/>
           <td>
               <input type="button" class="button" name="searchButton" value="<%=getTranNoLink("Web","Search",sWebLanguage)%>" onClick="transactionForm.Action.value='search';searchProcedure();">&nbsp;
               <input type="button" class="button" name="newButton" value="<%=getTranNoLink("Web","New",sWebLanguage)%>" onClick="newProcedure();">&nbsp;
               <input type="button" class="button" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="document.getElementById('FindLabProcedureName').value='';">&nbsp;
           </td>
        </tr>
        <%-- SEARCH RESULTS TABLE --%>
        <tr>
            <td valign="top" colspan="2" class="white" width="100%">
                <div id="divFindRecords" style="height: 100px">
                </div>
            </td>
        </tr>
    </table>
	<%
    LabProcedure procedure = new LabProcedure();
	if(sAction.equals("search") || sAction.equals("new")){
	    // load specified prestation
	    if(sAction.equals("search")){
	    	procedure = LabProcedure.get(sEditLabProcedureUid);
	    }
	}
%>    
    <%-- EDIT FIELDS ----------------------------------------------------------------%>
    <table width="100%" cellspacing="1" cellpadding="0" class="list">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">ID</td>
            <td class="admin2"><label id='idlabel'><%=checkString(procedure.getUid())%></label></td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","name",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" name="EditLabProcedureName" id="EditLabProcedureName" size="80" maxlength="255" value="<%=checkString(procedure.getName())%>">
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","minbatchsize",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" name="EditMinBatchSize" id="EditMinBatchSize" size="10" maxlength="10" value="<%=procedure.getMinBatchSize()%>">
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","maxbatchsize",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" name="EditMaxBatchSize" id="EditMaxBatchSize" size="10" maxlength="10" value="<%=procedure.getMaxBatchSize()%>">
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","maxdelayindays",sWebLanguage)%></td>
            <td class="admin2">
                <input type="text" class="text" name="EditMaxDelayInDays" id="EditMaxDelayInDays" size="10" maxlength="10" value="<%=procedure.getMaxDelayInDays()%>">
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","reagents",sWebLanguage)%>&nbsp;*&nbsp;</td>
            <td class="admin2">
            	<%
            		String sReagentsString="";
            		for(int n=0;n<procedure.getReagents().size();n++){
            			LabProcedureReagent reagent = (LabProcedureReagent)procedure.getReagents().elementAt(n);
            			if(sReagentsString.length()>0){
            				sReagentsString+="$";
            			}
            			sReagentsString+=reagent.getReagentuid()+"|"+reagent.getQuantity()+"|"+reagent.getReagent().getName()+"|"+reagent.getReagent().getUnit()+"|"+checkString(reagent.getConsumptionType());
            		}
            	%>
            	<input type="hidden" name="EditReagents" id="EditReagents" value="<%=sReagentsString%>"/>
		        <%=getTran("web","reagent",sWebLanguage) %>: <input class="greytext" type="text" disabled name="EditReagentUid" id="EditReagentUid" size="10" readonly value="" >
		        <input class="greytext" readonly disabled type="text" name="EditReagentName" id="EditReagentName" value="" size="50"/>
		        <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchReagent('EditReagentUid','EditReagentName','EditReagentUnit');">
		        <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt='Vider' onclick="document.getElementById('EditReagentUid').value='';document.getElementById('EditReagentName').value='';"> 
				<%=getTran("web","quantity",sWebLanguage) %>: <input type="text" class="text" size="10" name="EditQuantity" id="EditQuantity"/>   
            	<input type="text" class="greytext" size="10" readonly disabled name="EditReagentUnit" id="EditReagentUnit" value=""/>
            	<select class="text" name="EditConsumptionType" id="EditConsumptionType">
            		<%=ScreenHelper.writeSelect("labprocedure.consumptiontype", "", sWebLanguage) %>
            	</select>
				<input type="button" class="button" name="AddReagent" value="<%=getTran("web","add",sWebLanguage) %>" onclick="addReagent();"/>         	
            	<table width="100%"  cellspacing="1">
            		<tr class='admin'>
            			<td width="10%">ID</td>
            			<td width="60%"><%=getTran("web","reagent",sWebLanguage) %></td>
            			<td width="30%"><%=getTran("web","quantity",sWebLanguage) %></td>
            		</tr>
            	</table>
            	<table width="100%" class="sortable" name="EditReagentsTable" id="EditReagentsTable" cellspacing="1" headerRowCount="2"> 
            	</table>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <button class="button" name="saveButton" onclick="saveLabProcedure();"><%=getTranNoLink("accesskey","save",sWebLanguage)%></button>&nbsp;
                <%
                    // no delete button for new lab procedure
                    if(sEditLabProcedureUid.length()>0 && !sEditLabProcedureUid.equals("-1")){
                        %><input class="button" type="button" name="deleteButton" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="deleteLabProcedure('<%=procedure.getUid()%>');">&nbsp;<%
                    }
                %>
            </td>
        </tr>
    </table>
</form>

<script>
<%-- SEARCH PROCEDURE --%>
	function searchProcedure(){
	    transactionForm.Action.value = "search";
	    ajaxChangeSearchResults('_common/search/searchByAjax/searchLabProcedureShow.jsp', transactionForm);
	}
	
	function addReagent(){
		if(document.getElementById("EditReagentUid").value.length>0 && document.getElementById("EditQuantity").value.length>0){
			var reagents=document.getElementById("EditReagents").value.split("$");
			document.getElementById("EditReagents").value="";
			for(var n=0;n<reagents.length;n++){
				if(reagents[n].indexOf(document.getElementById("EditReagentUid").value+"|")<0){
					if(document.getElementById("EditReagents").value.length>0){
						document.getElementById("EditReagents").value=document.getElementById("EditReagents").value+"$";
					}
					document.getElementById("EditReagents").value=document.getElementById("EditReagents").value+reagents[n];
				}
			}
			if(document.getElementById("EditReagents").value.length>0){
				document.getElementById("EditReagents").value=document.getElementById("EditReagents").value+"$";
			}
			document.getElementById("EditReagents").value=document.getElementById("EditReagents").value+document.getElementById("EditReagentUid").value+"|"+document.getElementById("EditQuantity").value+"|"+document.getElementById("EditReagentName").value+"|"+document.getElementById("EditReagentUnit").value+"|"+document.getElementById("EditConsumptionType").value;
		}	
		//Now redraw the table
		fillReagentsTable();
        $('EditReagentUid').value="";
        $('EditReagentName').value="";
        $('EditQuantity').value="";
        $('EditReagentUnit').value="";
	}
	
	function fillReagentsTable(){
		if(document.getElementById("EditReagents").value.length>0){
			var html="";
			var reagents=document.getElementById("EditReagents").value.split("$");
			for(var n=0;n<reagents.length;n++){
				html=html+"<tr><td width='10%'><img src='<c:url value="_img/icon_delete.gif"/>' onclick='removeReagent(\""+reagents[n].split("|")[0]+"\")'/>"+reagents[n].split("|")[0]+"</td><td width='60%'>"+reagents[n].split("|")[2]+"</td><td width='30%'>"+reagents[n].split("|")[1];
				if(reagents[n].split("|").length>=4){
					html=html+" "+reagents[n].split("|")[3];					
				}
				if(reagents[n].split("|").length>=5){
					if(reagents[n].split("|")[4]=='batch'){
						html=html+" <%=getTranNoLink("labprocedure.consumptiontype","batch",sWebLanguage)%>";					
					}
					else if(reagents[n].split("|")[4]=='sample'){
						html=html+" <%=getTranNoLink("labprocedure.consumptiontype","sample",sWebLanguage)%>";					
					}
				}
				html=html+"</td></tr>";
			}
			document.getElementById("EditReagentsTable").innerHTML=html;
		}
	}
	
	function removeReagent(uid){
		var reagents=document.getElementById("EditReagents").value.split("$");
		document.getElementById("EditReagents").value="";
		for(var n=0;n<reagents.length;n++){
			if(reagents[n].indexOf(uid+"|")<0){
				if(document.getElementById("EditReagents").value.length>0){
					document.getElementById("EditReagents").value=document.getElementById("EditReagents").value+"$";
				}
				document.getElementById("EditReagents").value=document.getElementById("EditReagents").value+reagents[n];
			}
		}
		//Now redraw the table
		fillReagentsTable();
	}
	
    function ajaxChangeSearchResults(urlForm, SearchForm, moreParams) {
        document.getElementById('divFindRecords').innerHTML = "<div style='text-align:center'><img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading</div>";
        var url = urlForm;
        var params = Form.serialize(SearchForm) + moreParams;
        var myAjax = new Ajax.Updater(
                "divFindRecords", url,
        {
            evalScripts:true,
            method: 'post',
            parameters: params,
            onload: function() {

            },
            onSuccess: function(resp) {


            },
            onFailure:function() {
                $('divFindRecords').innerHTML = "Problem with ajax request !!";

            }

        });

    }

	<%-- SEARCH REAGENT --%>
	function searchReagent(reagentUidField,reagentNameField,reagentUnitField){
	    var url = "/_common/search/searchReagents.jsp&ts=<%=getTs()%>"+
		          "&ReturnFieldUid="+reagentUidField+
		          "&ReturnFieldUnit="+reagentUnitField+
	              "&ReturnFieldDescr="+reagentNameField;
	    openPopup(url);
	    document.getElementById(reagentNameField).focus();
	}
	
	function saveLabProcedure(){
	   	if(transactionForm.EditLabProcedureName.value.length > 0 &&
	       	transactionForm.EditMinBatchSize.value.length > 0 &&
	       	transactionForm.EditMaxBatchSize.value.length > 0 &&
	       	transactionForm.EditReagents.value.length > 0){
		   	if(transactionForm.EditLabProcedureUid.value.length==0){
			    transactionForm.EditLabProcedureUid.value = "-1";
			}
		    var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	     	transactionForm.saveButton.style.visibility = "hidden";
	     	transactionForm.Action.value = "save";
         	document.transactionForm.submit();
	   	}
	   	else{
	     	if(transactionForm.EditLabProcedureName.value.length==0){
	       		transactionForm.EditLabProcedureName.focus();
	     	}
	     	else if(transactionForm.EditMinBatchSize.value.length==0){
	       		transactionForm.EditMinBatchSize.focus();
	     	}
	     	else if(transactionForm.EditMaxBatchSize.value.length==0){
	       		transactionForm.EditMaxBatchSize.focus();
	     	}
	
	     	var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.manage&labelID=dataMissing";
	    	var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
	     	(window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm('<%=getTranNoLink("web.manage","dataMissing",sWebLanguage)%>');
	   	}
	}
	
	function deleteLabProcedure(sLabProcedureUid){
	   	var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
	   	var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
	   	var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm('<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>');
	
	   	if(answer==1){
	     	transactionForm.EditLabProcedureUid.value = sLabProcedureUid;
	     	transactionForm.Action.value = "delete";
	     	transactionForm.submit();
	   	}
	}
	
	function setLabProcedure(uid,descr){
        var params = 'FindLabProcedureUid=' + uid;
        var today = new Date();
        var url= '<c:url value="/labos/getLabProcedure.jsp"/>?ts='+today;
		new Ajax.Request(url,{
				method: "GET",
                parameters: params,
                onSuccess: function(resp){
                    var label = eval('('+resp.responseText+')');
                    $('EditLabProcedureUid').value=uid;
                    $('idlabel').innerHTML=uid;
                    $('EditLabProcedureName').value=label.Name;
                    $('EditMinBatchSize').value=label.MinBatchSize;
                    $('EditMaxBatchSize').value=label.MaxBatchSize;
                    $('EditMaxDelayInDays').value=label.MaxDelayInDays;
                    $('EditReagents').value=label.Reagents;
                    $('EditReagentsTable').innerHTML=label.ReagentsTable;
                    $('EditReagentUid').value="";
                    $('EditReagentName').value="";
                    $('EditQuantity').value="";
                    $('EditReagentUnit').value="";
                },
				onFailure: function(){
					alert("error");
                }
			}
		);
	}
	
	function newProcedure(){
        $('idlabel').innerHTML="";
        $('EditLabProcedureUid').value="";
        $('EditLabProcedureName').value="";
        $('EditLabProcedureName').focus();
        $('EditMinBatchSize').value="";
        $('EditMaxBatchSize').value="";
        $('EditMaxDelayInDays').value="";
        $('EditReagents').value="";
        $('EditReagentsTable').innerHTML="";
        $('EditReagentUid').value="";
        $('EditReagentName').value="";
        $('EditQuantity').value="";
        $('EditReagentUnit').value="";
	}

	window.setTimeout('document.getElementById("FindLabProcedureName").focus();',500);
	searchProcedure();
	fillReagentsTable();

</script>


