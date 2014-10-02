<%@page import="be.mxs.common.util.system.SessionMessage"%>
<%@page import="be.mxs.common.util.db.MedwanQuery,
                be.openclinic.system.Config,java.util.Hashtable,java.util.Enumeration" %>
<%@ page import="be.openclinic.sync.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
	if(request.getParameter("submit")!=null){
		if(checkString(request.getParameter("isslaveserver")).equalsIgnoreCase("1")){
			MedwanQuery.getInstance().setConfigString("enableSlaveServer", "1");
		}
		else{
			MedwanQuery.getInstance().setConfigString("enableSlaveServer", "0");
		}
		MedwanQuery.getInstance().setConfigString("slaveId", checkString(request.getParameter("slaveId")));
		MedwanQuery.getInstance().setConfigString("slaveName", checkString(request.getParameter("slaveName")));
		MedwanQuery.getInstance().setConfigString("slaveProject", checkString(request.getParameter("slaveProject")));
		if(checkString(request.getParameter("lastOpenClinicExport")).length()==0){
			MedwanQuery.getInstance().setConfigString("lastOpenClinicExport", new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new java.util.Date()));
		}
		else{
			MedwanQuery.getInstance().setConfigString("lastOpenClinicExport", request.getParameter("lastOpenClinicExport"));
		}
		if(checkString(request.getParameter("isslaveserver")).equalsIgnoreCase("1")){
			OpenclinicSlaveExporter openclinicSlaveExporter = new OpenclinicSlaveExporter(new SessionMessage());
			openclinicSlaveExporter.initializeCounters();
		}
		MedwanQuery.getInstance().setConfigString("slaveExportMaxRecordBlocks", checkString(request.getParameter("slaveExportMaxRecordBlocks")));
		MedwanQuery.getInstance().setConfigString("masterServerURL", checkString(request.getParameter("masterServerURL")));
	}
%>

<form name='transactionForm' method='post'>
  <%=writeTableHeader("web.manage","manageslaveserver",sWebLanguage,"doBack();")%>
  <table width="100%" class="menu" cellspacing="0" cellpadding="1">
  	<tr>
  		<td class='admin'><%=getTran("web","isslaveserver",sWebLanguage) %></td>
  		<td class='admin2'><input type='checkbox' name='isslaveserver' value='1' <%=MedwanQuery.getInstance().getConfigInt("enableSlaveServer",0)==1?"checked":"" %>/></td>
  	</tr>
  	<tr>
  		<td class='admin'><%=getTran("web","slaveId",sWebLanguage) %></td>
  		<td class='admin2'><input type='text' size='10' name='slaveId' value='<%=MedwanQuery.getInstance().getConfigString("slaveId","")%>'/></td>
  	</tr>
  	<tr>
  		<td class='admin'><%=getTran("web","slaveName",sWebLanguage) %></td>
  		<td class='admin2'><input type='text' size='80' name='slaveName' value='<%=MedwanQuery.getInstance().getConfigString("slaveName","")%>'/></td>
  	</tr>
  	<tr>
  		<td class='admin'><%=getTran("web","slaveProject",sWebLanguage) %></td>
  		<td class='admin2'><input type='text' size='80' name='slaveProject' value='<%=MedwanQuery.getInstance().getConfigString("slaveProject","")%>'/></td>
  	</tr>
  	<tr>
  		<td class='admin'><%=getTran("web","lastOpenClinicExport.empty.for.reset",sWebLanguage) %></td>
  		<td class='admin2'><input type='text' size='20' name='lastOpenClinicExport' value='<%=MedwanQuery.getInstance().getConfigString("lastOpenClinicExport","")%>'/></td>
  	</tr>
  	<tr>
  		<td class='admin'><%=getTran("web","initializeslavecounters",sWebLanguage) %></td>
  		<td class='admin2'><input type='checkbox' name='initializeslavecounters' value='1'/></td>
  	</tr>
  	<tr>
  		<td class='admin'><%=getTran("web","slaveExportMaxRecordBlocks",sWebLanguage) %></td>
  		<td class='admin2'><input type='text' size='80' name='slaveExportMaxRecordBlocks' value='<%=MedwanQuery.getInstance().getConfigInt("slaveExportMaxRecordBlocks",10000)%>'/></td>
  	</tr>
  	<tr>
  		<td class='admin'><%=getTran("web","masterServerURL",sWebLanguage) %></td>
  		<td class='admin2'><input type='text' size='80' name='masterServerURL' value='<%=MedwanQuery.getInstance().getConfigString("masterServerURL","http://localhost:10080/openclinic/util/webservice.jsp")%>'/></td>
  	</tr>
  </table>
  <input type='submit' name='submit' value='<%=getTranNoLink("web","save",sWebLanguage) %>'/>
</form>
