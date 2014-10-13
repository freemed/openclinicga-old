<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/commonFunctions.jsp"%>

<head>
    <%=sJSFORM%>
    <%=sCSSNORMAL%>
</head>

<body style="padding:3px;">
<form name='reportForm' action='<c:url value='/statistics/printHospitalReport.jsp'/>'>
	<input type='hidden' name='start' value='<%=request.getParameter("start")%>'/>
	<input type='hidden' name='end' value='<%=request.getParameter("end")%>'/>

    <%=writeTableHeader("Web","chin.global.hospital.report",sWebLanguage," closeWindow();")%>
	
	<table width="100%" class="list" cellpadding="0" cellspacing="1">
		<tr class="list1">
			<td><input type='checkbox' name='chapter1' id="cb1" class="hand"/><%=getLabel("hospital.statistics","base.activity.information",sWebLanguage,"cb1")%></td>
		</tr>
		<tr class="list">
			<td><input type='checkbox' name='chapter2' id="cb2" class="hand"/><%=getLabel("hospital.statistics","base.outcome.information",sWebLanguage,"cb2")%></td>
		</tr>
		<tr class="list1">
			<td><input type='checkbox' name='chapter3' id="cb3" class="hand"/><%=getLabel("hospital.statistics","pathology.profile",sWebLanguage,"cb3")%></td>
		</tr>
		<tr class="list">
			<td><input type='checkbox' name='chapter4' id="cb4" class="hand"/><%=getLabel("hospital.statistics","comorbidity.profile",sWebLanguage,"cb4")%></td>
		</tr>
		<tr class="list1">
			<td><input type='checkbox' name='chapter5' id="cb5" class="hand"/><%=getLabel("hospital.statistics","financial.profile",sWebLanguage,"cb5")%></td>
		</tr>
		<tr class="list">
			<td><input type='checkbox' name='chapter6' id="cb6" class="hand"/><%=getLabel("hospital.statistics","insurance.profile",sWebLanguage,"cb6")%></td>
		</tr>
		
		<%-- BUTTON --%>
		<tr height="30">
			<td class="admin2">
			    <input type='button' class='button' name='executeButton' onClick="doExecute();" value='<%=ScreenHelper.getTranNoLink("web","execute",sWebLanguage)%>'/>
			</td>
		</tr>
	</table>
	
	<%=ScreenHelper.alignButtonsStart()%>
	    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="closeWindow();">
	<%=ScreenHelper.alignButtonsStop()%>
</form>

<script>
  <%-- DO EXECUTE --%>
  function doExecute(){
	if(document.getElementById("cb1").checked ||
	   document.getElementById("cb2").checked ||
	   document.getElementById("cb3").checked ||
	   document.getElementById("cb4").checked ||
	   document.getElementById("cb5").checked ||
	   document.getElementById("cb6").checked){
	  reportForm.submit(); 
	}  
	else{
	  alertDialog("web","dataMissing");
	}
  }
  
  <%-- CLOSE WINDOW --%>
  function closeWindow(){
    window.opener = null;
    window.close();
  }
</script>
</body>