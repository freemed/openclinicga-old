<%@page import="be.openclinic.pharmacy.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String sQuery=request.getParameter("query");
	String sDb=request.getParameter("db");
	String sBegin=request.getParameter("begin");
	String sEnd=request.getParameter("end");
%>
<table width='100%'>
	<tr>
		<td class='admin'><%=getTran("web","physician",sWebLanguage) %></td>
		<td class='admin2'>
                <input type="hidden" name="doctor" id='doctor' value="">
                <input class="text" type="text" name="doctorname" id="doctorname" readonly size="40" value="">
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTran("web","select",sWebLanguage)%>" onclick="searchManager('doctor','doctorname');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTran("web","clear",sWebLanguage)%>" onclick="document.getElementById('doctor').value='';document.getElementById('doctorname').value='';">
		</td>
	</tr>
	<tr>
		<td class='admin'><%=getTran("web","service",sWebLanguage) %></td>
		<td class='admin2'>
             <input type='hidden' name='service' id='service' value=''>
             <input class='text' type='text' name='servicename' id='servicename' readonly size='40' value=''>&nbsp;
             <img src='_img/icons/icon_search.gif' class='link' alt='<%=getTranNoLink("Web","select",sWebLanguage)%>' onclick='searchService();'>&nbsp;
             <img src='_img/icons/icon_delete.gif' class='link' alt='<%=getTranNoLink("Web","clear",sWebLanguage)%>' onclick='clearService();'>
		</td>
	</tr>
	<tr>
		<td colspan='2'><input type='button' name='find' value='<%=getTran("web","find",sWebLanguage) %>' onclick='findinvoices();'/></td>
	</tr>
</table>

<script>
	function findinvoices(){
		url="<c:url value='/util/csvStats.jsp?'/>query=<%=sQuery%>&db=<%=sDb%>&begin=<%=sBegin%>&end=<%=sEnd%>&doctor="+document.getElementById('doctor').value+"&service="+document.getElementById('service').value;
		window.open(url);
		window.close();
	}

	function clearService(){
		document.getElementById('service').value='';
		document.getElementById('servicename').value='';
	}
	
	function searchService(){
	  	url="_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode=service&VarText=servicename";
	  	openPopup(url);
	  	document.getElementsByName(serviceNameField)[0].focus();
	}

	function searchManager(managerUidField,managerNameField){
	  openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+managerUidField+"&ReturnName="+managerNameField+"&displayImmatNew=no");
	  document.getElementById('doctorname').focus();
	}

</script>
