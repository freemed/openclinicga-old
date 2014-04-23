<%@include file="/mobile/_common/helper.jsp"%>
<meta name="viewport" content="width=device-width,initial-scale=1">
<%
    // prevent caching
	response.setHeader("Content-Type","text/html; charset=ISO-8859-1");
	response.setHeader("Expires","Sat, 6 May 1995 12:00:00 GMT");
	response.setHeader("Cache-Control","no-store,no-cache,must-revalidate");
	response.addHeader("Cache-Control","post-check=0,pre-check=0");
	response.setHeader("Pragma","no-cache");
%>

<html>
<head>
    <%=sCSS%>
    <%=sFAVICON%>
    <%=sJSPROTOTYPE%>
    <%=sSCRIPTS%>
    <title><%=sWEBTITLE%></title>
    <script>
      function initBarcode2(){
	    window.open("zxing://scan/?ret=<%="http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(),"")%>/mobile/searchPatient.jsp\?action=search%26patientpersonid={CODE}")
      }
	</script>
</head>

<body onkeydown="escBackSpace();">
<%
    // permanent buttons in header : menu / logout
    String sPage = request.getRequestURI();
    if(!sPage.endsWith("welcome.jsp") && !sPage.endsWith("login.jsp")){
    	%>    	
<table class="list" padding="0" cellspacing="0" width="<%=sTABLE_WIDTH%>">
	<tr>
 		<td colspan="2">
            <table class="list" padding="0" cellspacing="0" width="<%=sTABLE_WIDTH%>">
               <tr class="admintitle">
 		            <td width="50">&nbsp;</td>
 		            <td width="*"><%=sAPPNAME%></td>
 		            <td width="50" style="text-align:right"><img src="../_img/icon_logout.png" class="link" title="<%=getTranNoLink("web","logout",activeUser)%>" onClick="logOut();"></td>
 		        </tr>
 		    </table>
		</td>
	</tr>
	<tr>
		<%-- BARCODE --%>
		<td style="padding:5px;width:50px;padding-top:5px;">
			<img class="link" onclick="initBarcode2();" src="<%=sCONTEXTPATH%>/_img/androidbarcode.png" alt="<%=getTranNoLink("web","barcode",activeUser)%>">
		</td>

		<%-- BUTTONS --%>
		<td style="vertical-align:top;padding-top:5px;width:95%">
			<%	
				if(activePatient!=null){
					String sAction = checkString((String)request.getParameter("action"));
				
					if(activePatient!=null && !sPage.endsWith("searchPatient.jsp") && !sPage.endsWith("patientMenu.jsp")){
						%><input type="button" class="button" name="patientMenuButton" value="<%=activePatient.lastname+", "+activePatient.firstname%>" onClick="showPatientMenu();"%><div style="padding-top:3px;"/><%
					}
					else{
						if(!sAction.equals("newSearch")){
							%><input type="button" class="button" name="searchButton" value="<%=getTranNoLink("mobile","newSearch",activeUser)%>" onClick="doNewSearch();"%><div style="padding-top:3px;"/><%
	             		}
					}
				}
	            
				// link to full-size application	
				if(session.getAttribute("activePatient")!=null){
					String pid = ((AdminPerson)session.getAttribute("activePatient")).personid;
					%><a href='<%="http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(),"")%>/main.do?Page=curative/index.jsp&PersonID=<%=pid%>&ts=<%=new java.util.Date().getTime()+""%>'><%=getTran("web","desktop.interface",activeUser)%></a><%
				}
				else{
					%><a href='<%="http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(),"")%>/main.do?CheckService=true&CheckMedicalCenter=true&ts=<%=new java.util.Date().getTime()+""%>'><%=getTran("web","desktop.interface",activeUser)%></a><%
				}
			%>
        </td>
    </tr>
</table>   
<div style="padding-top:5px"></div> 	
    	<%
    }
%>