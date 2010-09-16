<%@page import="java.util.*,net.admin.*,java.text.*,
                be.mxs.common.util.db.MedwanQuery,
                java.util.GregorianCalendar,
                java.util.Calendar,
                be.mxs.common.util.system.*,
                net.admin.system.AccessLog"%>
<table>
<%
	if(request.getParameter("sessionid")!=null){
		Enumeration sessions = MedwanQuery.getSessions().keys();
		while(sessions.hasMoreElements()){
			HttpSession s = (HttpSession)sessions.nextElement();
			if(s.getId().equalsIgnoreCase(request.getParameter("sessionid"))){
				Enumeration vars = s.getAttributeNames();
				while (vars.hasMoreElements()){
					String name = (String)vars.nextElement();
					Object value=s.getAttribute(name);
					if(value.getClass().getName().indexOf("String")>-1){
						out.println("<tr><td class='admin2'>"+name+"</td><td>"+(name.equalsIgnoreCase("password")?"******":value)+"</td></tr>");
					}
					else if(value.getClass().getName().indexOf("AdminPerson")>-1){
						out.println("<tr><td class='admin2'>"+name+"</td><td>"+((AdminPerson)value).lastname+", "+((AdminPerson)value).firstname+"</td></tr>");
					}
					else if(value.getClass().getName().indexOf("User")>-1){
						out.println("<tr><td class='admin2'>"+name+"</td><td>"+((User)value).person.lastname+", "+((User)value).person.firstname+"</td></tr>");
					}
					else if(value.getClass().getName().indexOf("java.util.Date")>-1){
						out.println("<tr><td class='admin2'>"+name+"</td><td>"+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format((java.util.Date)value)+"</td></tr>");
					}
					else if(value.getClass().getName().indexOf("java.sql.Date")>-1){
						out.println("<tr><td class='admin2'>"+name+"</td><td>"+new SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format((java.sql.Date)value)+"</td></tr>");
					}
				}
				break;
			}
		}
	}
%>
</table>