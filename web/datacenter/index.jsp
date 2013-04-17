<%@include file="/includes/helper.jsp" %>
<%@include file="/includes/SingletonContainer.jsp"%>

<%
	if(session.getAttribute("activeUser")==null){
		autoLogin("4","overmeire",request);
		reloadSingleton(session);
		User activeUser = (User)session.getAttribute("activeUser");
		activeUser.person.language=MedwanQuery.getInstance().getConfigString("datacenterUserLanguage."+request.getParameter("username"),"fr");
        session.setAttribute(sAPPTITLE + "WebLanguage", activeUser.person.language);
	}
    Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
    if(langHashtable == null || langHashtable.size()==0){
        reloadSingleton(request.getSession());
    }
    MedwanQuery.getInstance().reloadConfigValues();
%>
<script>
	window.location.href='datacenterHomePublic.jsp';
</script>