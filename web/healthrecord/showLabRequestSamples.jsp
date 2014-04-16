<%@include file="/includes/validateUser.jsp"%>
<%@ page import="be.openclinic.medical.LabRequest,java.util.*,be.openclinic.medical.LabSample" %>
<%
    String serverid=checkString(request.getParameter("serverid"));
    String transactionid=checkString(request.getParameter("transactionid"));
%>
<form name="samplesForm" method="post">
<script>
    function showRequest(serverid,transactionid){
        window.open("<c:url value='/labos/manageLabResult_view.jsp'/>?ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no");
    }

</script>
<%
    if (request.getParameter("findSamples") != null || request.getParameter("execute") != null) {
%>
    <table width="100%" class="list">
        <tr class="admin">
            <td><%=getTran("web","date",sWebLanguage)%></td>
            <td width='20%'><%=getTran("web","patient",sWebLanguage)%></td>
            <td><%=getTran("web","samples",sWebLanguage)%></td>
        </tr>
    <%
        LabRequest labRequest = LabRequest.getUnsampledRequest(Integer.parseInt(serverid),Integer.parseInt(transactionid),sWebLanguage);
        if(labRequest.getPersonid()>0){
            out.println("<tr>");
            out.println("<td>" + (labRequest.getRequestdate()!=null?new SimpleDateFormat("dd/MM/yyyy HH:mm").format(labRequest.getRequestdate()):"") + "<BR/><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + labRequest.getTransactionid() + "</b></a></td>");
            out.println("<td><a href='javascript:readBarcode3(\"0"+labRequest.getPersonid()+"\");'><b>" + labRequest.getPatientname() + "</b></a> (°"+(labRequest.getPatientdateofbirth()!=null?new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getPatientdateofbirth()):"")+" - "+labRequest.getPatientgender()+")<br/><i>"+labRequest.getServicename()+" - "+MedwanQuery.getInstance().getUserName(labRequest.getUserid())+"</i></td>");
            out.println("<td><table width='100%'>");
            Hashtable samples = labRequest.findOpenSamples(sWebLanguage);
            Enumeration enumeration = samples.elements();
            while (enumeration.hasMoreElements()) {
                LabSample labSample = (LabSample)enumeration.nextElement();
                out.println("<tr><td class='admin2' width='20%'><input type='checkbox' name='execute."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"."+labSample.type+"'>");
                out.println(" "+MedwanQuery.getInstance().getLabel("labanalysis.monster",labSample.type,sWebLanguage)+"</td><td class='admin2'>");
                for(int i=0;i<labSample.analyses.size();i++){
                    if(i>0){
                        out.print(", ");
                    }
                    out.print(MedwanQuery.getInstance().getLabel("labanalysis",(String)labSample.analyses.elementAt(i),sWebLanguage));
                }
                out.println("</td></tr>");
            }
            out.println("</table></td>");
            out.println("</tr>");
        }
    %>
    </table>
    <input class="button" type="button" name="printlabels" value="<%=getTran("web","printlabels",sWebLanguage)%>" onclick="printLabels();"/>
</form>
<%
    }
%>
<script>
    function printLabels(){
        samplesForm.action="<c:url value='/healthrecord/createLabSampleLabelPdf.jsp'/>";
        samplesForm.submit();
    }
</script>