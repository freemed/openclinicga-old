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

<body class="Geenscroll">
<form name="promptForm" method="POST" onkeydown="if(enterEvent(event,13)){doClose(document.getElementById('promptField').value);}">
    <table width="260" height="120">
        <tr>
            <td align="center">
                <br>
                <%=questionTran%>
                <br><br><br>

                <input type="text" class="text" size="20" name="promptField" id="promptField">
                <input type="button" name="buttonOk" class="button" value="&nbsp;&nbsp;<%=getTran("web.occup","medwan.common.ok",sWebLanguage)%>&nbsp;&nbsp;" onclick="doClose(document.getElementById('promptField').value);"/>
                <br><br>
            </td>
        </tr>
    </table>
</form>

<script>
  //document.getElementById("buttonOk").focus();
  //window.resizeTo(400,300);

  <%-- DO CLOSE --%>
  function doClose(iReturn){
    window.returnValue = iReturn;
    window.close();
  }
</script>
</body>
