<%@page import="java.io.*,
                java.util.*,
                be.mxs.common.util.io.WHONet.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%	
	String sAction = checkString(request.getParameter("Action"));
	
	String sExportDate  = checkString(request.getParameter("exportdate")),
		   sExportTime  = checkString(request.getParameter("exporttime")),
		   sDestination = checkString(request.getParameter("destination"));
	
	if(sExportDate.length()==0){
		sExportDate = MedwanQuery.getInstance().getConfigString("lastWHONetExport","19000101000000");
		
		java.util.Date tmpDate = ScreenHelper.parseDate(sExportDate,new SimpleDateFormat("yyyyMMddHHmmss"));
		sExportDate = ScreenHelper.formatDate(tmpDate);
		
		tmpDate = ScreenHelper.parseDate(sExportDate,new SimpleDateFormat("HHmmss"));
		sExportTime = new SimpleDateFormat("HH:mm:ss").format(tmpDate); 
	}
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n*********************** system/exportToWHONet.jsp *********************");
		Debug.println("sAction      : "+sAction);
		Debug.println("sExportDate  : "+sExportDate);
		Debug.println("sExportTime  : "+sExportTime);
		Debug.println("sDestination : "+sDestination+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	String message = "";
	java.util.Date exportdate;
	
	
	//*** EXPORT **********************************************************************************
	if(sAction.equals("export")){
		try{
			exportdate = ScreenHelper.parseDate(sExportDate+" "+sExportTime,ScreenHelper.fullDateFormatSS);
			 
			if(sDestination.equalsIgnoreCase("download")){
				out.println("<script>window.open('util/exportWHONetCsv.jsp?exportdate="+request.getParameter("exportdate")+"&exporttime="+request.getParameter("exporttime")+"&language="+sWebLanguage+"');</script>");
				out.flush();
			}
			else if(sDestination.equalsIgnoreCase("ftp")){
				message = WHONetUtils.ftpSendWHONetFile(exportdate,true,sWebLanguage);
				try{
					exportdate = new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastWHONetExport","19000101000000"));
				}
				catch(Exception e){
					// empty
				}
			}
			else if(sDestination.equalsIgnoreCase("smtp")){
				message = WHONetUtils.smtpSendWHONetFile(exportdate,true,sWebLanguage);
				try{
					exportdate = new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastWHONetExport","19000101000000"));
				}
				catch(Exception e){
					// empty
				}
			}
			else if(sDestination.equalsIgnoreCase("directory")){
				message = WHONetUtils.copyWHONetFile(exportdate,true,sWebLanguage);
				try{
					exportdate = new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastWHONetExport","19000101000000"));
				}
				catch(Exception e){
					// empty
				}
			}
		}
		catch(Exception e){
			e.printStackTrace();
			message = ScreenHelper.getTran("web","wrong.datetime.format",sWebLanguage)+"! ("+request.getParameter("exportdate")+" "+request.getParameter("exporttime")+")";
		}
	}
%>
<form name='transactionForm' method='post'>
    <input type="hidden" name="Action" value="">
    <%=writeTableHeader("web.manage","exporttowhonet",sWebLanguage," doBack();")%>

	<table class="list" width="100%" cellpadding="0" cellspacing="1">		
		<%-- DATES --%>
		<tr>
			<td class='admin' width="<%=sTDAdminWidth%>"><%=getTran("web","export.modifications.after",sWebLanguage)%></td>
			<td class='admin2'>
			    <%=ScreenHelper.writeDateField("exportdate","transactionForm",sExportDate,true,false,sWebLanguage,request.getRequestURI().replaceAll(request.getServletPath(),""))%>&nbsp;
		        <input class='text' type='text' width='10' size='10' name='exporttime' id='exporttime' value='<%=sExportTime%>'/></td>
		    </td>
		</tr>
		
		<%-- DESTINATION --%>
		<tr>
			<td class='admin'><%=getTran("web","destination",sWebLanguage)%>&nbsp;*&nbsp;</td>
			<td class='admin2'>
                <input type='radio' name='destination' id='destination1' value='download' <%=(sDestination.equals("download")?"checked":"")%>/><%=getLabel("web","download.file",sWebLanguage,"destination1")%><br>

				<%
				    // DESTINATION:FTP
					String ftpserver = MedwanQuery.getInstance().getConfigString("WHONetDestinationFtpServer","");
					if(ftpserver.split("@").length > 1){
						%><input type='radio' name='destination' id='destination2' value='ftp' <%=(sDestination.equals("ftp")?"checked":"")%>/><%=getLabel("web","send.to.ftpserver",sWebLanguage,"destination2")+" "+getTran("web","towards",sWebLanguage)+" ["+ftpserver.split("@")[1]+"]"%><br><%
					} 
	
				    // DESTINATION:SMTP
					String smtpserver = MedwanQuery.getInstance().getConfigString("WHONetDestinationSmtpServer","");
					if(smtpserver.split("@").length > 1){
						%><input type='radio' name='destination' id='destination3' value='smtp' <%=(sDestination.equals("smtp")?"checked":"")%>/><%=getLabel("web","send.to.smtpserver",sWebLanguage,"destination3")+" "+getTran("web","towards",sWebLanguage)+" ["+smtpserver+"]"%><br><%
					} 
		
				    // DESTINATION:DIRECTORY
					String directory = MedwanQuery.getInstance().getConfigString("WHONetDestinationDirectory","");
					if(directory.length() > 1){
						%><input type='radio' name='destination' id='destination4' value='directory' <%=(sDestination.equals("directory")?"checked":"")%>/><%=getLabel("web","send.to.directory",sWebLanguage,"destination4")+" "+getTran("web","towards",sWebLanguage)+" ["+directory+"]"%><br><%
					} 
				%>
			</td>
		</tr>
		
		<%-- BUTTONS --%>
		<tr>
		    <td class="admin">&nbsp;</td>
			<td class="admin2">
			    <input type='button' class='button' name='exportButton' onclick='doExport();' value='<%=getTranNoLink("web","export",sWebLanguage)%>'/>
			</td>
		</tr>
	</table>
	
	<font style="color:red;"><%=message%></font>
</form>

<script>
  <%-- DO EXPORT --%>
  function doExport(){
	if(document.getElementById("destination1").checked ||
       (document.getElementById("destination2")!=null && document.getElementById("destination2").checked) ||
       (document.getElementById("destination3")!=null && document.getElementById("destination3").checked) ||
       (document.getElementById("destination4")!=null && document.getElementById("destination4").checked)){
      transactionForm.Action.value = "export";
	  transactionForm.submit();
	}
	else{
      alertDialog("web.manage","dataMissing");
      document.getElementById("destination1").focus();
	}
  }
  
  <%-- DO BACK --%>
  function doBack(){
	window.location.href = "<c:url value='/main.do'/>?Page=labos/index.jsp";
  }
</script>