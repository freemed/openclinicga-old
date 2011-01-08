<%@include file="/includes/helper.jsp" %>
<%@include file="/includes/SingletonContainer.jsp"%>

<%
	autoLogin("4","overmeire",request);
    Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
    if(langHashtable == null || langHashtable.size()==0){
        reloadSingleton(request.getSession());
    }
%>
<script>
	window.location.href='datacenterHome.jsp';
</script>