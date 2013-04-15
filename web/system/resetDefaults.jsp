<%@page import="be.mxs.common.util.system.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String country=request.getParameter("country");
	String os=request.getParameter("os");
	String database=request.getParameter("database");
	if(country==null) country=MedwanQuery.getInstance().getConfigString("setup.country","");
	if(os==null) os=MedwanQuery.getInstance().getConfigString("setup.os","");
	if(database==null) database=MedwanQuery.getInstance().getConfigString("setup.database","");
	if(request.getParameter("update")!=null){
		UpdateSystem.updateSetup("country",country,request);
		UpdateSystem.updateSetup("os",os,request);
		UpdateSystem.updateSetup("database",database,request);
		if(request.getParameter("updatedb")!=null){
			UpdateSystem.updateDb();
		}
		if(request.getParameter("updatelabels")!=null){
			UpdateSystem.updateLabels(sAPPFULLDIR);
		}
		if(checkString(request.getParameter("project")).length()>0){
			UpdateSystem.updateProject(request.getParameter("project"));
		}
		MedwanQuery.getInstance().reloadConfigValues();
		MedwanQuery.getInstance().reloadLabels();
	}
%>

<form name='resetDefaults' method='post'>
	<table>
		<tr class='admin'><td colspan='2'><%=getTran("web","reset.defaults",sWebLanguage) %>&nbsp</td></tr>
		<tr>
			<td class='admin'><%=getTran("web","country",sWebLanguage) %></td>
			<td class='admin2'>
				<select name='country' id='country' class='text'>
					<option value=''></option>
					<option value='be' <%="be".equals(country)?"selected":""%>><%=getTran("country","be",sWebLanguage).toUpperCase() %></option>
					<option value='rw' <%="rw".equals(country)?"selected":""%>><%=getTran("country","rw",sWebLanguage).toUpperCase() %></option>
					<option value='bi' <%="bi".equals(country)?"selected":""%>><%=getTran("country","bi",sWebLanguage).toUpperCase() %></option>
					<option value='ml' <%="ml".equals(country)?"selected":""%>><%=getTran("country","ml",sWebLanguage).toUpperCase() %></option>
					<option value='cd' <%="cd".equals(country)?"selected":""%>><%=getTran("country","cd",sWebLanguage).toUpperCase() %></option>
					<option value='ci' <%="ci".equals(country)?"selected":""%>><%=getTran("country","ci",sWebLanguage).toUpperCase() %></option>
					<option value='cg' <%="cg".equals(country)?"selected":""%>><%=getTran("country","cg",sWebLanguage).toUpperCase() %></option>
					<option value='al' <%="al".equals(country)?"selected":""%>><%=getTran("country","al",sWebLanguage).toUpperCase() %></option>
					<option value='tz' <%="tz".equals(country)?"selected":""%>><%=getTran("country","tz",sWebLanguage).toUpperCase() %></option>
					<option value='br' <%="br".equals(country)?"selected":""%>><%=getTran("country","br",sWebLanguage).toUpperCase() %></option>
					<option value='ke' <%="ke".equals(country)?"selected":""%>><%=getTran("country","ke",sWebLanguage).toUpperCase() %></option>
					<option value='ug' <%="ug".equals(country)?"selected":""%>><%=getTran("country","ug",sWebLanguage).toUpperCase() %></option>
				</select>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","os",sWebLanguage) %>&nbsp</td>
			<td class='admin2'>
				<select name='os' class='text'>
					<option value=''></option>
					<option value='linux' <%="linux".equals(os)?"selected":""%>><%=getTran("web","mac",sWebLanguage).toUpperCase() %></option>
					<option value='linux' <%="linux".equals(os)?"selected":""%>><%=getTran("web","solaris",sWebLanguage).toUpperCase() %></option>
					<option value='linux' <%="linux".equals(os)?"selected":""%>><%=getTran("web","linux",sWebLanguage).toUpperCase() %></option>
					<option value='windows' <%="windows".equals(os)?"selected":""%>><%=getTran("web","windows",sWebLanguage).toUpperCase() %></option>
				</select>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","databaseserver",sWebLanguage) %>&nbsp</td>
			<td class='admin2'>
				<select name='database' class='text'>
					<option value=''></option>
					<option value='mysql' <%="mysql".equals(database)?"selected":""%>><%=getTran("web","mysql",sWebLanguage).toUpperCase() %></option>
					<option value='sqlserver' <%="sqlserver".equals(database)?"selected":""%>><%=getTran("web","sqlserver",sWebLanguage).toUpperCase() %></option>
				</select>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","project",sWebLanguage) %>&nbsp</td>
			<td class='admin2'>
				<input class='text' type='text' name='project' id='project' value='<%=MedwanQuery.getInstance().getConfigString("defaultProject","openclinic")%>'/>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","updatelabels",sWebLanguage) %>&nbsp</td>
			<td class='admin2'>
				<input class='text' type='checkbox' name='updatelabels' id='undatelabels'/>
			</td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","updatedatabase",sWebLanguage) %>&nbsp</td>
			<td class='admin2'>
				<input class='text' type='checkbox' name='updatedb' id='undatedb'/>
			</td>
		</tr>
	</table>
	<input class='button' type = 'submit' name='update' value='<%=getTran("web","update",sWebLanguage)%>'/>
</form>

<script language="JavaScript" type="text/javascript">
function sortlist(list) {
	var lb = document.getElementById(list);
	arrTexts = new Array();
	arrValues = new Array();
	
	for(i=0; i<lb.length; i++)  {
		  arrTexts[i] = lb.options[i].text+";"+lb.options[i].value;
	}
	
	arrTexts.sort();
	
	for(i=0; i<lb.length; i++)  {
	  lb.options[i].text = arrTexts[i].split(";")[0];
	  lb.options[i].value = arrTexts[i].split(";")[1];
	  if(lb.options[i].value=='<%=country%>'){
		  lb.options.selectedIndex=i;
	  }
	}
}

sortlist('country');
</script>