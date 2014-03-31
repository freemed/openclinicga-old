<%@page errorPage="/includes/error.jsp"%>
<%@ include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.printlabel","select",activeUser)%>
<html>
    <head>
        <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
    <object id="factory" style="display:none" viewastext
classid="clsid:1663ed61-23eb-11d2-b92f-008048fdd814"
codebase="<c:url value="/util/cab/"/>ScriptX.cab#Version=6,1,428,2">
</object>
<script defer>
function window.onload() {
  factory.printing.header = "";
  factory.printing.footer = "";
  factory.printing.portrait = true;
  factory.printing.leftMargin = 0.0;
  factory.printing.topMargin = 0.0;
  factory.printing.rightMargin = 0.0;
  factory.printing.bottomMargin = 0.0;
  factory.printing.Print(true);
}
</script>
    <head>
    <body>
        <script>function noError(){return true;} window.onerror = noError;</script>
<%
    if (activePatient!=null){
    %>
    <table width="100" height="300" border="0">
        <tr>
            <td height="120"><img src="<c:url value="/projects/chuk/_img/logochklabel.gif"/>" alt="" border="0"/></td>
        </tr>
        <tr>
            <td align="left" style="vertical-align:top;" nowrap>
                <div style='writing-mode:tb-rl;font-family: Arial, Helvetica, sans-serif;'>
                <%=activePatient.lastname+"  "+activePatient.firstname%><br/>
                <%=activePatient.gender+"  "+activePatient.dateOfBirth%><br/>
                <%=activePatient.getID("immatnew")%><br/>
                </div>
            </td>
        </tr>
    </table>
<script>
    window.resizeTo(300,300);
</script>
    <%
    }
%>
    </body>
</html>