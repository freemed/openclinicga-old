<%@page import="net.admin.*,java.sql.*,be.mxs.common.util.db.*,java.util.*" %>

<%!
//--- RELOAD SINGLETON ------------------------------------------------------------------------
public void reloadSingleton(HttpSession session) {
    Hashtable labelLanguages = new Hashtable();
    Hashtable labelTypes = new Hashtable();
    Hashtable labelIds;
    net.admin.Label label;

    // only load labels in memory that are service nor function.
    Vector vLabels = net.admin.Label.getNonServiceFunctionLabels();
    Iterator iter = vLabels.iterator();

    while(iter.hasNext()){
        label = (net.admin.Label)iter.next();
        // type
        labelTypes = (Hashtable) labelLanguages.get(label.language);
        if (labelTypes == null) {
            labelTypes = new Hashtable();
            labelLanguages.put(label.language, labelTypes);
        }

        // id
        labelIds = (Hashtable) labelTypes.get(label.type);
        if (labelIds == null) {
            labelIds = new Hashtable();
            labelTypes.put(label.type, labelIds);
        }

        labelIds.put(label.id, label);
    }

    MedwanQuery.getInstance().putLabels(labelLanguages);
}

%>
<%
	
	String username = request.getParameter("username");
	String password = request.getParameter("password");
	
	if(username != null && username.trim().length()>0 && password != null && password.trim().length()>0){
		User activeUser = new User();
		byte[] encryptedPassword = activeUser.encrypt(password);
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		if (activeUser.initialize(conn,username,encryptedPassword)){
			reloadSingleton(session);
			session.setAttribute("activeuser",activeUser);
			out.println("<script>window.location.href='welcome.jsp';</script>");
			out.flush();
		}
	}
%>
<body >
<center><img width='75%' src='../_img/openclinic_mobile.jpg'/>
<form name='loginForm' method='post'>
	<table>
		<tr><td>Login:</td><td><input name='username' value='' type='text' size='10'/></td></tr>
		<tr><td>Password:</td><td><input name='password' value='' type='password' size='10'/></td></tr>
		<tr><td/><td><input type='submit' name='submit' value='login'/></td></tr>
	</table>
</form>
</center>
</body>