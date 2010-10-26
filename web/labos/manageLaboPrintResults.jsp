<%@include file="/includes/validateUser.jsp"%>
<%@ page import="java.util.*,be.openclinic.medical.LabRequest,java.util.Date" %>
<%=checkPermission("labos.printnewresults","select",activeUser)%>
<%!
    public class LabRow {
        int type;
        String tag;

        public LabRow(int type, String tag) {
            this.type = type;
            this.tag = tag;
        }
    }
%>
<form name="samplesForm" method="post">
    <%=writeTableHeader("Web","printnewlabresults",sWebLanguage," doBack();")%>
    <table width="100%" class="menu" cellspacing="0" cellpadding="0">
        <tr>
            <td><%=getTran("web","stardate",sWebLanguage)%>
                <input type="text" class="text" size="12" maxLength="10" name="startdate" value="<%=checkString(request.getParameter("startdate")).length()>0?checkString(request.getParameter("startdate")):new SimpleDateFormat("dd/MM/yyyy").format(new Date())%>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
                <input class="button" type="submit" name="submit" value="<%=getTran("web","find",sWebLanguage)%>"/>
            </td>
        </tr>
    </table>
</form>
<script>
    function doBack(){
        window.location.href="<c:url value="/main.do"/>?Page=labos/index.jsp";
    }
</script>
<%
    if(request.getParameter("startdate")!=null){
%>
        <form  name="printfrm" id="printfrm" target="_print" action="<c:url value='/labos/createLabResultsPdf.jsp'/>" method="post">
<%
        Date date=new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("startdate"));
        Vector r = LabRequest.findServiceValidatedRequestsSince("",date,sWebLanguage,999);

        SortedMap services = new TreeMap();
        Iterator iterator = r.iterator();
        while(iterator.hasNext()){
            LabRequest labRequest=(LabRequest)iterator.next();
            if(services.get(labRequest.getServicename())==null){
                services.put(labRequest.getServicename(),new Hashtable());
            }
            ((Hashtable)services.get(labRequest.getServicename())).put(labRequest,"1");
        }

    %>
    <table class="list" width="100%" cellspacing="1" cellpadding="0">
        <%
            Iterator servicesiterator = services.keySet().iterator();
            while(servicesiterator.hasNext()){
                String servicename=(String)servicesiterator.next();
                out.print("<tr class='admin'><td colspan='3'><b>"+servicename+"</b></td><td>"+getTran("web","patient",sWebLanguage)+"</td><td>"+getTran("web","prescriber",sWebLanguage)+"</td></tr>");
                Hashtable requests = (Hashtable)services.get(servicename);
                Enumeration requestsEnumeration = requests.keys();
                while (requestsEnumeration.hasMoreElements()){
                    LabRequest labRequest=(LabRequest)requestsEnumeration.nextElement();
                    out.print("<tr bgcolor='#FFFCD6'><td>&nbsp;</td><td><input type='checkbox' name='print."+labRequest.getServerid()+"."+labRequest.getTransactionid()+"' checked /></td><td><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + labRequest.getTransactionid() + "</b></a> "+new SimpleDateFormat("dd/MM/yyyy HH:mm").format(labRequest.getRequestdate())+"</td><td><a href='javascript:readBarcode3(\"0"+labRequest.getPersonid()+"\");'><b>" + labRequest.getPatientname() + "</b></a> (°"+(labRequest.getPatientdateofbirth()!=null?new SimpleDateFormat("dd/MM/yyyy").format(labRequest.getPatientdateofbirth()):"")+" - "+labRequest.getPatientgender()+")</td><td><i>"+MedwanQuery.getInstance().getUserName(labRequest.getUserid())+"</i></td></tr>");
                }
            }
        %>
    </table>
    <%
        if(services.size()>0){
    %>
    <input type="hidden" name="startdate" id="startdate"/>
    <input type="submit" class="button" name="submit" value="<%=getTran("web","print",sWebLanguage)%>" onclick="document.getElementById('startdate').value=document.getElementById('trandate').value"/>
    <%
        }
        
    %>
    </form>
    <script type="text/javascript">
        function showRequest(serverid,transactionid){
            window.open("<c:url value='/popup.jsp'/>?Page=labos/manageLabResult_view.jsp&s=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no");
        }
    </script>
<%
    }
%>
