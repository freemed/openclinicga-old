<%@page import="java.util.*,net.admin.*,java.text.*,
                be.mxs.common.util.db.MedwanQuery,
                java.util.GregorianCalendar,
                java.util.Calendar,
                be.mxs.common.util.system.*,
                net.admin.system.AccessLog"%>
<table class="list" cellpadding="0" cellspacing="1" width="100%">
<%
    String sSessionId = ScreenHelper.checkString(request.getParameter("sessionid"));
    Debug.println("sSessionId : "+sSessionId);
    
	if(sSessionId.length() > 0){
		Enumeration sessions = MedwanQuery.getSessions().keys();
		
		while(sessions.hasMoreElements()){
			HttpSession s = (HttpSession)sessions.nextElement();
			if(s.getId().equalsIgnoreCase(request.getParameter("sessionid"))){
				Enumeration vars = s.getAttributeNames();
				while(vars.hasMoreElements()){
					String name = (String)vars.nextElement();
					Object value = s.getAttribute(name);
					
					if(value.getClass().getName().indexOf("String")>-1){
						out.print("<tr><td class='admin2' width='150'>"+name+"</td><td>"+(name.equalsIgnoreCase("password")?"******":value)+"</td></tr>");
					}
					else if(value.getClass().getName().indexOf("AdminPerson")>-1){
						out.print("<tr><td class='admin2'>"+name+"</td><td>"+((AdminPerson)value).lastname+", "+((AdminPerson)value).firstname+"</td></tr>");
					}
					else if(value.getClass().getName().indexOf("User")>-1){
						out.print("<tr><td class='admin2'>"+name+"</td><td>"+((User)value).person.lastname+", "+((User)value).person.firstname+"</td></tr>");
					}
					else if(value.getClass().getName().indexOf("java.util.Date")>-1){
						out.print("<tr><td class='admin2'>"+name+"</td><td>"+ScreenHelper.fullDateFormatSS.format((java.util.Date)value)+"</td></tr>");
					}
					else if(value.getClass().getName().indexOf("java.sql.Date")>-1){
						out.print("<tr><td class='admin2'>"+name+"</td><td>"+ScreenHelper.fullDateFormatSS.format((java.sql.Date)value)+"</td></tr>");
					}
				}
				break;
			}
		}
	}
%>
</table>
<br>

<center><input type="button" class="button" value="Close" onclick="window.close()"/></center>