<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sCSSNORMAL%>

<%
	// label value is given OR label type and id
    String labelValue = checkString(request.getParameter("labelValue"));
    String labelType, labelID, questionTran;

    if(labelValue.length() == 0){
        labelType = ScreenHelper.checkDbString(request.getParameter("labelType"));
        labelID   = ScreenHelper.checkDbString(request.getParameter("labelID"));
        questionTran = getTran(labelType,labelID,sWebLanguage);
    }
    else{
        questionTran = labelValue;
    }
%>
<script type="text/javascript">window.resizeTo(400,300);</script>

<body class="Geenscroll">
<table width="100%" height="100%">
    <tr>
        <td align="center" style="padding:1px">
            <br>
            <img src="<c:url value='/_img/warning.gif'/>"/> <%=questionTran%>
            <br><br><br>

            <input type="button" name="buttonOk" id="buttonOk" class="button" value="&nbsp;&nbsp;<%=getTran("web.occup","medwan.common.ok",sWebLanguage)%>&nbsp;&nbsp;" onclick="doClose(1);"/>
            <br><br>
        </td>
    </tr>
</table>

<script>
  document.getElementById("buttonOk").focus();
  
  <%-- DO CLOSE --%>
  function doClose(iReturn){
    window.returnValue = iReturn;
    window.close();
  }
</script>
</body>