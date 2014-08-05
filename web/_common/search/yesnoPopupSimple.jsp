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
        <td align="center">
            <br>
            <%=labelValue%>
            <br><br><br>

            <input type="button" name="buttonYes" class="button" value="&nbsp;&nbsp;<%=getTranNoLink("web.occup","medwan.common.yes","en")%>&nbsp;&nbsp;" onclick="doClose(1);"/>&nbsp;
            <input type="button" name="buttonNo" class="button" value="&nbsp;&nbsp;<%=getTranNoLink("web.occup","medwan.common.no","en")%>&nbsp;&nbsp;" onclick="doClose(0);"/>
            <br><br>
        </td>
    </tr>
</table>

<script>
  <%=sCenterWindow%>

  <%-- DO CLOSE --%>
  function doClose(iReturn){
    window.returnValue = iReturn;
    window.close();
  }
</script>
</body>
