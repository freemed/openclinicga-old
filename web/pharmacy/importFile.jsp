<%@include file="/includes/validateUser.jsp"%>
<form name="importFile" method="post">
	<label class="text"><%=getTran("web","filename",sWebLanguage)%></label> <input class="text" name="uploadfile" type="file"/>
	<input type="submit" class="button" name="submit" value="<%=getTranNoLink("web","upload",sWebLanguage)%>"/>
</form>