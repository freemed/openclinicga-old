<%@include file="/mobile/_common/helper.jsp"%>

<%
    User activeUser = null;
    AdminPerson activePatient = null;

	String sUriPage = request.getRequestURI();
	if(!sUriPage.endsWith("loggedOut.jsp") && !sUriPage.endsWith("sessionExpired.jsp") && !sUriPage.endsWith("login.jsp")){
		if(session==null || session.isNew()){
			//System.out.println("@@@@@@@@ session null : "+(session==null)); ///////////////
			//System.out.println("@@@@@@@@ session new  : "+(session.isNew())); ///////////////
            response.sendRedirect(sCONTEXTPATH+"/mobileRelogin.do");
            
			//out.print("<script>window.location.href='sessionExpired.jsp';</script>");	
		    //out.flush();
		}
		
		activeUser = (User)session.getAttribute("activeUser");	
		activePatient = (AdminPerson)session.getAttribute("activePatient");
	}
%>