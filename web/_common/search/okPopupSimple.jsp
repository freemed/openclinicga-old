<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/helper.jsp"%>
<%=sCSSNORMAL%>

<%
    // label value is given OR label type and id
    String labelValue = checkString(request.getParameter("labelValue"));
%>

<body class="Geenscroll">
<table width="100%" height="100%">
    <tr>
        <td align="center" style="padding:1px">
            <br><img src="<c:url value='/_img/icons/icon_warning.gif'/>"/> <%=labelValue%>
            <br><br><br>

            <input type="button" name="buttonOk" id="buttonOk" class="button" value="&nbsp;&nbsp;<%=getTranNoLink("web.occup","medwan.common.ok","e")%>&nbsp;&nbsp;" onclick="doClose(1);"/>
            <br><br>
        </td>
    </tr>
</table>

<script>
  <%=sCenterWindow%>
  setTimeout("document.getElementById('buttonOk').focus()",100);

  <%-- DO CLOSE --%>
  function doClose(iReturn){
    window.returnValue = iReturn;
    window.close();
  }
</script>
</body>
