<%@include file="/mobile/_common/head.jsp"%>
<%	
    // log in
	String username = checkString(request.getParameter("username")),
	       password = checkString(request.getParameter("password"));

	String sMsg = "";
	if(username.length()>0 && password.length()>0){
		activeUser = new User();
		byte[] encryptedPassword = activeUser.encrypt(password);
		
		// fetch user
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		if(activeUser.initialize(conn,username,encryptedPassword)){
			reloadSingleton(session);
			session.setAttribute("activeUser",activeUser);
			out.print("<script>window.location.href='welcome.jsp';</script>");
			out.flush();
		}
		else{
			sMsg = "Invalid credentials"; // no user, no language
		}
	}
	else if(username.length()>0 || password.length()>0){
		sMsg = "Incomplete credentials"; // no user, no language
	}
%>
<form name="loginForm" method="post">
    <div id="login">
		<img src="../_img/openclinic_mobile.jpg"><br><br>
		
		<table padding="0" cellspacing="1" width="<%=sTABLE_WIDTH%>">
			<tr><td style="text-align:right">Login:</td><td><input name="username" value="" type="text" class="text" size="8" style="width:88px"/></td></tr>
			<tr><td style="text-align:right">Password:</td><td><input name="password" value="" type="password" class="text" size="8" style="width:88px"/></td></tr>
			<tr><td/><td><input type="submit" class="button" name="submit" value="Login"/></td></tr>
		</table>
	    <div class="error_msg"><%=(sMsg.length()>0?sMsg:"")%><br><br></div>
    </div>
</form>

<script>loginForm.username.focus();</script>
    
<%-- CREDITS --%>
GA Open Source Edition by
<% if(MedwanQuery.getInstance().getConfigString("mxsref","rw").equalsIgnoreCase("rw")){ %>
<img src="../_img/flags/rwandaflag.jpg" height="15px" width="30px" alt="Rwanda"/>
<a href="http://mxs.rwandamed.org" target="_new"><b>The Open-IT Group Ltd</b></a>
<br>PO Box 3242 - Kigali Rwanda<br>Tel +250 07884 32 435 -
<a href="mailto:mxs@rwandamed.org">openit@rwandamed.org</a>
<% } else if(MedwanQuery.getInstance().getConfigString("mxsref","rw").equalsIgnoreCase("bi")){ %>
<img src="../_img/flags/burundiflag.jpg" height="15px" width="30px" alt="Burundi"/>
<a href="http://www.openit-burundi.net" target="_new"><b>Open-IT Burundi SPRL</b></a>
<br>Avenue de l'ONU 6, BP 7205 - Bujumbura<br>+257 78 837 342<br>
<a href="mailto:info@openit-burundi.net">info@openit-burundi.net</a>
<% } else if(MedwanQuery.getInstance().getConfigString("mxsref","rw").equalsIgnoreCase("ml")){ %>
<img src="../_img/flags/maliflag.jpg" height="15px" width="30px" alt="Mali"/>
<a href="http://www.sante.gov.ml/" target="_new"><b>ANTIM</b></a> et <a href="http://www.mxs.be" target="_new"><b>MXS</b></a>
<br>Hamdalaye ACI 2000, Rue 340, Porte 541, Bamako - Mali<br>
<a href="mailto:info@openit-burundi.net">antim@sante.gov.ml</a>
<% } else { %>
<img src="../_img/flags/belgiumflag.jpg" height="10px" width="20px" alt="Belgium"/>
<b>MXS SA/NV</b>
<br>Pastoriestraat 58, 3370 Boutersem Belgium<br>Tel: +32 16 721047 -
<a href="mailto:mxs@rwandamed.org">info@mxs.be</a>
<% } %>

<%@include file="/mobile/_common/footer.jsp"%>