<%@include file="/includes/helper.jsp" %>
<%@include file="/includes/SingletonContainer.jsp"%>

<%
	if(session.getAttribute("activeUser")==null){
		autoLogin("4","overmeire",request);
		User activeUser = (User)session.getAttribute("activeUser");
		activeUser.person.language=MedwanQuery.getInstance().getConfigString("datacenterUserLanguage."+request.getParameter("username"),"FR");
        session.setAttribute(sAPPTITLE + "WebLanguage", activeUser.person.language);
	}
    Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
    if(langHashtable == null || langHashtable.size()==0){
        reloadSingleton(request.getSession());
    }
%>
<script>
	window.location.href='datacenterHome.jsp';
</script>