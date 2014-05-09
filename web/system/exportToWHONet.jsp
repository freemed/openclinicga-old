<%@page import="java.io.*,java.util.*,be.mxs.common.util.io.WHONet.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String message = "";
	java.util.Date exportdate= new SimpleDateFormat("yyyyMMddHHmmss").parse("19000101000000");
	try{
		exportdate= new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastWHONetExport","19000101000000"));
	}
	catch(Exception e){
		
	}
	if(request.getParameter("submit")!=null){
		if(request.getParameter("destination")==null){
			out.println("<script>alert('"+getTranNoLink("web","destination.missing",sWebLanguage)+"');</script>");
			out.flush();
		}
		else {
			try{
				exportdate = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").parse(request.getParameter("exportdate")+" "+request.getParameter("exporttime"));
				if(request.getParameter("destination").equalsIgnoreCase("download")){
					out.println("<script>window.open('util/exportWHONetCsv.jsp?exportdate="+request.getParameter("exportdate")+"&exporttime="+request.getParameter("exporttime")+"&language="+sWebLanguage+"');</script>");
					out.flush();
				}
				else if(request.getParameter("destination").equalsIgnoreCase("ftp")){
					message=WHONetUtils.ftpSendWHONetFile(exportdate, true, sWebLanguage);
					try{
						exportdate= new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastWHONetExport","19000101000000"));
					}
					catch(Exception e){
						
					}
				}
				else if(request.getParameter("destination").equalsIgnoreCase("smtp")){
					message=WHONetUtils.smtpSendWHONetFile(exportdate, true, sWebLanguage);
					try{
						exportdate= new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastWHONetExport","19000101000000"));
					}
					catch(Exception e){
						
					}
				}
				else if(request.getParameter("destination").equalsIgnoreCase("directory")){
					message=WHONetUtils.copyWHONetFile(exportdate, true, sWebLanguage);
					try{
						exportdate= new SimpleDateFormat("yyyyMMddHHmmss").parse(MedwanQuery.getInstance().getConfigString("lastWHONetExport","19000101000000"));
					}
					catch(Exception e){
						
					}
				}
			}
			catch(Exception e){
				e.printStackTrace();
				message=ScreenHelper.getTran("web","wrong.datetime.format",sWebLanguage)+"! ("+request.getParameter("exportdate")+" "+request.getParameter("exporttime")+")";
			}
		}
	}
%>
<form name='transactionForm' method='post'>
	<table>
		<tr class='admin'>
			<td colspan='3'><%=getTran("web.manage","exporttowhonet",sWebLanguage) %></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","export.modifications.after",sWebLanguage) %></td>
			<td class='admin2'><%=ScreenHelper.writeDateField("exportdate", "transactionForm", new SimpleDateFormat("dd/MM/yyyy").format(exportdate), true, false, sWebLanguage, request.getRequestURI().replaceAll(request.getServletPath(),"")) %></td>
			<td class='admin2'><input class='text' type='text' width='10' size='10' name='exporttime' id='exporttime' value='<%=new SimpleDateFormat("HH:mm:ss").format(exportdate) %>'/></td>
		</tr>
		<tr>
			<td class='admin'><%=getTran("web","download.file",sWebLanguage) %></td>
			<td class='admin2' colspan='2'><input type='radio' name='destination' id='destination' value='download'/></td>
		</tr>
		<%
			String ftpserver=MedwanQuery.getInstance().getConfigString("WHONetDestinationFtpServer","");
			if(ftpserver.split("@").length>1){ %>
			<tr>
				<td class='admin'><%=getTran("web","send.to.ftpserver",sWebLanguage)+" "+getTran("web","towards",sWebLanguage)+" ["+ftpserver.split("@")[1]+"]"%> </td>
				<td class='admin2' colspan='2'><input type='radio' name='destination' id='destination' value='ftp'/></td>
			</tr>
		<%
			} 
		%>
		<%
			String smtpserver=MedwanQuery.getInstance().getConfigString("WHONetDestinationSmtpServer","");
			if(smtpserver.split("@").length>1){ %>
			<tr>
				<td class='admin'><%=getTran("web","send.to.smtpserver",sWebLanguage)+" "+getTran("web","towards",sWebLanguage)+" ["+smtpserver+"]"%> </td>
				<td class='admin2' colspan='2'><input type='radio' name='destination' id='destination' value='smtp'/></td>
			</tr>
		<%
			} 
		%>
		<%
			String directory=MedwanQuery.getInstance().getConfigString("WHONetDestinationDirectory","");
			if(directory.length()>1){ %>
			<tr>
				<td class='admin'><%=getTran("web","send.to.directory",sWebLanguage)+" "+getTran("web","towards",sWebLanguage)+" ["+directory+"]"%> </td>
				<td class='admin2' colspan='2'><input type='radio' name='destination' id='destination' value='directory'/></td>
			</tr>
		<%
			} 
		%>
		<tr>
			<td colspan='3' class='admin2'><input type='submit' class='button' name='submit' value='<%=getTran("web","export",sWebLanguage) %>'/></td>
		</tr>
	</table>
	<p>
		<font style="font-size: 14px; color: red;"><%=message %></font>
	</p>
</form>