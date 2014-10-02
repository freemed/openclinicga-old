<%@page import="java.util.Vector"%>
<%@page import="be.openclinic.medical.LabRequest"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("labos.patientlaboresults","select",activeUser)%>

<%=writeTableHeader("Web","patientLaboResults",sWebLanguage," doBack();")%>

<%
    Vector requestList = LabRequest.findRequestList(Integer.parseInt(activePatient.personid));
    if(requestList.size() > 0){
        %>
        <form method="post" action="<c:url value="/main.do"/>?Page=healthrecord/manageLabResult_view.jsp">
            <input type="submit" class="button" name="submit" value="<%=getTranNoLink("web","show",sWebLanguage)%>"/>
            <div style="padding:3px"></div>
   
            <table class="list">
            <%
                LabRequest labRequest;
                for(int n=0; n<requestList.size(); n++){
                    labRequest = (LabRequest)requestList.elementAt(n);
                    out.print("<tr>"+
                               "<td class='text'>"+
                                "<input type='checkbox' "+(n<5?"checked":"")+" name='show."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"'/>"+ScreenHelper.formatDate(labRequest.getRequestdate(),ScreenHelper.fullDateFormat)+
                               "</td>"+
                              "</tr>");
                }
            %>
            </table>
   
            <div style="padding:3px"></div>
            <input type="submit" class="button" name="submit" value="<%=getTranNoLink("web","show",sWebLanguage)%>"/>
        </form>
        <%
    }
    else{
        out.print(getTran("web","noDataAvailable",sWebLanguage));
    }
%>

<script>
  function doBack(){
    window.location.href="<c:url value='/main.do'/>?Page=labos/index.jsp";
  }
</script>