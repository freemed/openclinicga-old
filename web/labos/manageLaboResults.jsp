<%@include file="/includes/validateUser.jsp"%>
<%@ page import="be.openclinic.medical.RequestedLabAnalysis,java.util.*,be.openclinic.medical.LabRequest" %>
<%@ page import="be.openclinic.medical.LabAnalysis" %>
<%=checkPermission("labos.openpatientlaboresults","select",activeUser)%>
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
<%
    SortedMap requestList = new TreeMap();

    Vector r = LabRequest.findUntreatedRequests(sWebLanguage,Integer.parseInt(activePatient.personid));
    for(int n=0;n<r.size();n++){
        LabRequest labRequest = (LabRequest)r.elementAt(n);
        if(labRequest.getRequestdate()!=null){
            requestList.put(new SimpleDateFormat("yyyyMMddHHmmss").format(labRequest.getRequestdate())+"."+labRequest.getServerid()+"."+labRequest.getTransactionid(),labRequest);
        }
    }

    SortedMap groups = new TreeMap();
    Iterator iterator = requestList.keySet().iterator();
    while(iterator.hasNext()){
        LabRequest labRequest=(LabRequest)requestList.get(iterator.next());
        Enumeration enumeration = labRequest.getAnalyses().elements();
        while(enumeration.hasMoreElements()){
            RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis)enumeration.nextElement();
            if(groups.get(requestedLabAnalysis.getLabgroup())==null){
                groups.put(requestedLabAnalysis.getLabgroup(),new Hashtable());
            }
            ((Hashtable)groups.get(requestedLabAnalysis.getLabgroup())).put(requestedLabAnalysis.getAnalysisCode(),"1");
        }
    }

%>
<%=writeTableHeader("Web","openPatientLaboResults",sWebLanguage," doBack();")%>
<table class="list" width="100%">
    <tr>
        <td><%=getTran("web","analysis",sWebLanguage)%></td>
    <%
        Iterator requestsIterator = requestList.keySet().iterator();
        while (requestsIterator.hasNext()) {
            LabRequest labRequest = (LabRequest) requestList.get(requestsIterator.next());
            out.print("<td>" + ScreenHelper.fullDateFormat.format(labRequest.getRequestdate()) + "<br/><a href='javascript:showRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + labRequest.getTransactionid() + "</b></a></td>");
        }
    %>
    </tr>
    <%
        String abnormal=MedwanQuery.getInstance().getConfigString("abnormalModifiers","*+*++*+++*-*--*---*h*hh*hhh*l*ll*lll*");
        Iterator groupsIterator = groups.keySet().iterator();
        while(groupsIterator.hasNext()){
            String groupname=(String)groupsIterator.next();
            out.print("<tr class='admin'><td colspan='"+(requestList.size()+1)+"'><b>"+MedwanQuery.getInstance().getLabel("labanalysis.groups",groupname,sWebLanguage)+"</b></td></tr>");
            Hashtable analysisList = (Hashtable)groups.get(groupname);
            Enumeration analysisEnumeration = analysisList.keys();
            while (analysisEnumeration.hasMoreElements()){
                String analysisCode=(String)analysisEnumeration.nextElement();
                String c = analysisCode;
                String u = "";
                LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(analysisCode);
                if(analysis!=null){
                    c=analysis.getLabId()+"";
                    u=" ("+analysis.getUnit()+")";
                }
                out.print("<tr bgcolor='#FFFCD6'><td><b>"+MedwanQuery.getInstance().getLabel("labanalysis",c,sWebLanguage)+" "+u+"</b></td>");
                requestsIterator = requestList.keySet().iterator();
                while(requestsIterator.hasNext()){
                    LabRequest labRequest = (LabRequest)requestList.get(requestsIterator.next());
                    RequestedLabAnalysis requestedLabAnalysis=(RequestedLabAnalysis)labRequest.getAnalyses().get(analysisCode);
                    String result=(requestedLabAnalysis!=null?(requestedLabAnalysis.getFinalvalidation()>0?requestedLabAnalysis.getResultValue():"?"):"");
                    boolean bAbnormal=(result.length()>0 && !result.equalsIgnoreCase("?") && abnormal.toLowerCase().indexOf("*"+checkString(requestedLabAnalysis.getResultModifier()).toLowerCase()+"*")>-1);
                    out.print("<td"+(bAbnormal?" bgcolor='#FF8C68'":"")+">"+result+(bAbnormal?" "+checkString(requestedLabAnalysis.getResultModifier().toUpperCase()):"")+"</td>");
                }
                out.print("</tr>");
            }
        }
    %>
</table>
<script>
    function showRequest(serverid,transactionid){
        window.open("<c:url value='/popup.jsp'/>?Page=labos/manageLabResult_view.jsp&ts=<%=getTs()%>&show."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no");
    }
    function doBack(){
        window.location.href="<c:url value="/main.do"/>?Page=labos/index.jsp";
    }
</script>