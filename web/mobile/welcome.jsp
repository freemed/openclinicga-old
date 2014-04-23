<%@include file="/mobile/_common/head.jsp"%>

<table class="list" padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
    <tr class="admintitle"><td><%=sAPPNAME%></td></tr>
    <tr>
        <td colspan="3" style="text-align:center;padding:10px">
			<%-- BARCODE --%>
			<img class="link" onclick="initBarcode2();" src="<%=sCONTEXTPATH%>/_img/androidbarcode.png" alt="<%=getTran("web","barcode",activeUser)%>">
        </td>
    </tr>
    <tr>
        <td colspan="3" style="text-align:center">
			<b><%=getTran("mobile","welcome",activeUser)%> <%=activeUser.person.firstname+" "+activeUser.person.lastname%></b>
		</td>
    </tr>
    <tr>
        <td colspan="3" style="text-align:center">
			<%
			    // last access time
				Connection conn = MedwanQuery.getInstance().getAdminConnection();
				PreparedStatement ps = conn.prepareStatement("select max(accesstime) as maxtime from AccessLogs where userid=?");
				ps.setString(1,activeUser.userid);
				ResultSet rs = ps.executeQuery();
				if(rs.next()){
					out.println("<font color='#999999'>"+getTran("mobile","lastlogin",activeUser)+": "+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(rs.getTimestamp("maxtime"))+"</font>");
				}
				rs.close();
				ps.close();
				conn.close();	
				
                // log current access
                AccessLog objAL = new AccessLog();
                objAL.setUserid(Integer.parseInt(activeUser.userid));
                objAL.setAccesstime(getSQLTime());
                AccessLog.logAccess(objAL);
			%>
        </td>
    </tr>
    
    <%-- BUTTONS --%>
    <tr>
        <td colspan="3">
			<div style="text-align:center;padding:10px">
			    <input type="button" class="button" name="searchButton" value="<%=getTran("mobile","searchPatient",activeUser)%>" onClick="doNewSearch();"%><div style="padding-top:5px;"/>
			    <input type="button" class="button" name="exitButton" value="<%=getTran("web","logOut",activeUser)%>" onClick="logOut();"%>
		    </div>
        </td>
    </tr>
</table>

<%
    // link to full-size application	
	if(session.getAttribute("activePatient")!=null){
		String pid = ((AdminPerson)session.getAttribute("activePatient")).personid;
	    %><a href='<%="http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(),"")%>/main.do?Page=curative/index.jsp&PersonID=<%=pid%>&ts=<%=new java.util.Date().getTime()+""%>'><%=getTran("web","desktop.interface",activeUser)%></a><%
	}
	else{
	    %><a href='<%="http://"+request.getServerName()+request.getRequestURI().replaceAll(request.getServletPath(),"")%>/main.do?CheckService=true&CheckMedicalCenter=true&ts=<%=new java.util.Date().getTime()+""%>'><%=getTran("web","desktop.interface",activeUser)%></a><%
	}
%>
<%@include file="/mobile/_common/footer.jsp"%>