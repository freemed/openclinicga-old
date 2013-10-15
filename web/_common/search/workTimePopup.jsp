<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
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

<table class="menu" width="100%" height="100%">
    <tr>
        <td align="center" width="100">
            <img src="<c:url value='/_img/men_at_work.gif'/>">
        </td>
        <td align="center">
            <%=questionTran%>
        </td>
    </tr>

    <tr>
        <td colspan="2" align="center">
            <input type="button" name="buttonOk" class="button" value="&nbsp;&nbsp;<%=getTranNoLink("web.occup","medwan.common.ok",sWebLanguage)%>&nbsp;&nbsp;" onclick="doClose(1);"/>
            <br><br>
        </td>
    </tr>
</table>

<script>
  //document.getElementById("buttonOk").focus();
  //window.resizeTo(400,300);
  
  <%-- DO CLOSE --%>
  function doClose(iReturn){
    window.returnValue = iReturn;
    window.close();
  }
</script>
