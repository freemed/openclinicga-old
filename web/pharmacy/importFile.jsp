<%@include file="/includes/validateUser.jsp"%>
<form name="importFile" method="post">
	<label class='text'><%=getTran("web","filename",sWebLanguage) %></label> <input class='text' name='uploadfile' type='file'/>
	<input class='text' type='submit' name='submit' value='<%=getTran("web","upload",sWebLanguage)%>'/>
</form>