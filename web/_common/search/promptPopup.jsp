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

<body class="Geenscroll" onLoad="document.getElementById("buttonOk").focus();" onBlur="self.focus();document.getElementById("buttonOk").focus();">
<form name="promptForm" method="POST" onkeydown="if(enterKeyPressed(event)){doClose(document.getElementById('promptField').value);}">
    <table width="260" height="120">
        <tr>
            <td align="center">
                <br>
                <%=questionTran%>
                <br><br><br>

                <input type="text" class="text" size="20" name="promptField" id="promptField">
                <input type="button" name="buttonOk" class="button" value="&nbsp;&nbsp;<%=getTranNoLink("web.occup","medwan.common.ok",sWebLanguage)%>&nbsp;&nbsp;" onclick="doClose(document.getElementById('promptField').value);"/>
                <br><br>
            </td>
        </tr>
    </table>
</form>

<script>
  <%=sCenterWindow%>
  document.getElementById("buttonOk").focus();
  //window.resizeTo(400,300);

  <%-- DO CLOSE --%>
  function doClose(iReturn){
    window.returnValue = iReturn;
    window.close();
  }
  
  <%-- ENTER KEY PRESSED --%>
  function enterKeyPressed(e){
    var eventKey = e.which?e.which:window.event.keyCode;
	return (eventKey==13);
  }
</script>
</body>
