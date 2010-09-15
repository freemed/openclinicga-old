<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.medical.LabRequest" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("labos.patientlaboresults","select",activeUser)%>
<%=writeTableHeader("Web","patientLaboResults",sWebLanguage," doBack();")%>
<form method="post" action="<c:url value="/main.do"/>?Page=healthrecord/manageLabResult_view.jsp">
    <%
        Vector requestList = LabRequest.findRequestList(Integer.parseInt(activePatient.personid));

        if (requestList.size()>0){
    %>
    <input type="submit" class="button" name="submit" value="<%=getTran("web","show",sWebLanguage)%>"/>
    <table class="list">
        <%
            LabRequest labRequest;
            for(int n=0;n<requestList.size();n++){
                labRequest = (LabRequest)requestList.elementAt(n);
                out.print("<tr><td class='text'><input type='checkbox' "+(n<5?"checked":"")+" name='show."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"'/>"+new SimpleDateFormat("dd/MM/yyyy HH:mm").format(labRequest.getRequestdate())+"</td></tr>");
            }
        %>
    </table>
    <input type="submit" class="button" name="submit" value="<%=getTran("web","show",sWebLanguage)%>"/>
    <%
        }
        else {
            out.print(getTran("web","nodataavailable",sWebLanguage));
        }
    %>
</form>
<script type="text/javascript">
    function doBack(){
        window.location.href="<c:url value="/main.do"/>?Page=labos/index.jsp";
    }
</script>