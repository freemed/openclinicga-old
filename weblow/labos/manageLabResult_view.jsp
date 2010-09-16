<%@include file="/includes/validateUser.jsp"%>
<%@ page import="be.openclinic.medical.RequestedLabAnalysis,java.util.*,be.openclinic.medical.LabRequest" %>
<%@ page import="be.openclinic.medical.LabAnalysis" %>
<%@ page import="java.text.DecimalFormat" %>
<%=checkPermission("system.management","select",activeUser)%>
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
<head>
    <%=sCSSNORMAL%>
</head>
<%
    SortedMap requestList = new TreeMap();
    Enumeration parameters = request.getParameterNames();
    while (parameters.hasMoreElements()) {
        String name = (String) parameters.nextElement();
        String[] items = name.split("\\.");
        if (items[0].equalsIgnoreCase("show")) {
            LabRequest labRequest = new LabRequest(Integer.parseInt(items[1]),Integer.parseInt(items[2]));
            if(labRequest.getRequestdate()!=null){
                requestList.put(new SimpleDateFormat("yyyyMMddHHmmss").format(labRequest.getRequestdate())+"."+items[1]+"."+items[2],labRequest);
            }
        }
    }

    SortedMap groups = new TreeMap();
    Iterator iterator = requestList.keySet().iterator();
    while(iterator.hasNext()){
        LabRequest labRequest=(LabRequest)requestList.get(iterator.next());
        Enumeration enumeration = labRequest.getAnalyses().elements();
        while(enumeration.hasMoreElements()){
            RequestedLabAnalysis requestedLabAnalysis = (RequestedLabAnalysis)enumeration.nextElement();
            if(groups.get(MedwanQuery.getInstance().getLabel("labanalysis.group",requestedLabAnalysis.getLabgroup(),sWebLanguage))==null){
                groups.put(MedwanQuery.getInstance().getLabel("labanalysis.group",requestedLabAnalysis.getLabgroup(),sWebLanguage),new Hashtable());
            }
            ((Hashtable)groups.get(MedwanQuery.getInstance().getLabel("labanalysis.group",requestedLabAnalysis.getLabgroup(),sWebLanguage))).put(requestedLabAnalysis.getAnalysisCode(),"1");
        }
    }

%>
<%=writeTableHeader("Web","patientLaboResults",sWebLanguage," doBack();")%>
<table class="list" width="100%">
    <tr>
        <td><%=getTran("web","analysis",sWebLanguage)%></td>
    <%
        LabRequest labRequest;
        Iterator requestsIterator = requestList.keySet().iterator();
        while(requestsIterator.hasNext()){
            labRequest = (LabRequest)requestList.get(requestsIterator.next());
            out.print("<td>"+new SimpleDateFormat("dd/MM/yyyy HH:mm").format(labRequest.getRequestdate())+"<br/>"+labRequest.getTransactionid()+"<br/>"+
                    "<a href='javascript:printRequest("+labRequest.getServerid()+","+labRequest.getTransactionid()+")'><b>" + getTran("web","print",sWebLanguage) + "</b></a></td>");
            out.print("<td>"+MedwanQuery.getInstance().getLabel("web","sampler",sWebLanguage)+"</td>");
            out.print("<td>"+MedwanQuery.getInstance().getLabel("web","sampletakendatetime",sWebLanguage)+"</td>");
            out.print("<td>"+MedwanQuery.getInstance().getLabel("web","samplereceptiondatetime",sWebLanguage)+"</td>");
            out.print("<td>"+MedwanQuery.getInstance().getLabel("web","worklisteddatetime",sWebLanguage)+"</td>");
            out.print("<td>"+MedwanQuery.getInstance().getLabel("web","technicalvalidator",sWebLanguage)+"</td>");
            out.print("<td>"+MedwanQuery.getInstance().getLabel("web","technicalvalidationdatetime",sWebLanguage)+"</td>");
            out.print("<td>"+MedwanQuery.getInstance().getLabel("web","finalvalidator",sWebLanguage)+"</td>");
            out.print("<td>"+MedwanQuery.getInstance().getLabel("web","finalvalidationdatetime",sWebLanguage)+"</td>");
        }
    %>
    </tr>
    <%
        String abnormal=MedwanQuery.getInstance().getConfigString("abnormalModifiers","*+*++*+++*-*--*---*h*hh*hhh*l*ll*lll*");
        Iterator groupsIterator = groups.keySet().iterator();
        while(groupsIterator.hasNext()){
            String groupname=(String)groupsIterator.next();
            out.print("<tr class='admin'><td colspan='"+(requestList.size()+9)+"'><b>"+MedwanQuery.getInstance().getLabel("labanalysis.group",groupname,sWebLanguage)+"</b></td></tr>");
            Hashtable analysisList = (Hashtable)groups.get(groupname);
            Enumeration analysisEnumeration = analysisList.keys();
            while (analysisEnumeration.hasMoreElements()){
                String analysisCode=(String)analysisEnumeration.nextElement();
                String c = analysisCode;
                String u = "";
                String refs="";
                LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(analysisCode);
                if(analysis!=null){
                    c=analysis.getLabId()+"";
                    u=" ("+analysis.getUnit()+")";
                    String min=analysis.getResultRefMin(activePatient.gender,activePatient.getAge());
                    try{
                        float f=Float.parseFloat(min);
                        min=new DecimalFormat("#,###.###").format(f);
                    }
                    catch (Exception e){}
                    String max=analysis.getResultRefMax(activePatient.gender,activePatient.getAge());
                    try{
                        float f=Float.parseFloat(max);
                        max=new DecimalFormat("#,###.###").format(f);
                    }
                    catch (Exception e){}
                    refs=" ["+min+"-"+max+"]";
                }
                out.print("<tr bgcolor='#FFFCD6'><td width='25%' nowrap><b>"+MedwanQuery.getInstance().getLabel("labanalysis",c,sWebLanguage)+" "+u+refs+"</b></td>");
                requestsIterator = requestList.keySet().iterator();
                if(requestsIterator.hasNext()){
                    labRequest = (LabRequest)requestList.get(requestsIterator.next());
                    RequestedLabAnalysis requestedLabAnalysis=(RequestedLabAnalysis)labRequest.getAnalyses().get(analysisCode);
                    String result=(requestedLabAnalysis!=null?requestedLabAnalysis.getFinalvalidation()>0 && requestedLabAnalysis.getResultValue().length()>0?requestedLabAnalysis.getResultValue():"?":"");
                    boolean bAbnormal=(result.length()>0 && !result.equalsIgnoreCase("?") && abnormal.toLowerCase().indexOf("*"+checkString(requestedLabAnalysis.getResultModifier()).toLowerCase()+"*")>-1);
                    out.print("<td"+(bAbnormal?" bgcolor='#FF8C68'":"")+">"+result+(bAbnormal?" "+checkString(requestedLabAnalysis.getResultModifier().toUpperCase()):"")+"</td>");
                    out.print("<td>"+(requestedLabAnalysis!=null && requestedLabAnalysis.getSampler()>0?MedwanQuery.getInstance().getUserName(requestedLabAnalysis.getSampler()):"")+"</td>");
                    out.print("<td>"+(requestedLabAnalysis!=null && requestedLabAnalysis.getSampletakendatetime()!=null?new SimpleDateFormat("dd/MM/yyyy HH:mm").format(requestedLabAnalysis.getSampletakendatetime()):"")+"</td>");
                    out.print("<td>"+(requestedLabAnalysis!=null && requestedLabAnalysis.getSamplereceptiondatetime()!=null?new SimpleDateFormat("dd/MM/yyyy HH:mm").format(requestedLabAnalysis.getSamplereceptiondatetime()):"")+"</td>");
                    out.print("<td>"+(requestedLabAnalysis!=null && requestedLabAnalysis.getWorklisteddatetime()!=null?new SimpleDateFormat("dd/MM/yyyy HH:mm").format(requestedLabAnalysis.getWorklisteddatetime()):"")+"</td>");
                    out.print("<td>"+(requestedLabAnalysis!=null && requestedLabAnalysis.getTechnicalvalidation()>0?MedwanQuery.getInstance().getUserName(requestedLabAnalysis.getTechnicalvalidation()):"")+"</td>");
                    out.print("<td>"+(requestedLabAnalysis!=null && requestedLabAnalysis.getTechnicalvalidationdatetime()!=null?new SimpleDateFormat("dd/MM/yyyy HH:mm").format(requestedLabAnalysis.getTechnicalvalidationdatetime()):"")+"</td>");
                    out.print("<td>"+(requestedLabAnalysis!=null && requestedLabAnalysis.getFinalvalidation()>0?MedwanQuery.getInstance().getUserName(requestedLabAnalysis.getFinalvalidation()):"")+"</td>");
                    out.print("<td>"+(requestedLabAnalysis!=null && requestedLabAnalysis.getFinalvalidationdatetime()!=null?new SimpleDateFormat("dd/MM/yyyy HH:mm").format(requestedLabAnalysis.getFinalvalidationdatetime()):"")+"</td>");
                }
                out.print("</tr>");
            }
        }
    %>
</table>

<script type="text/javascript">
    function printRequest(serverid,transactionid){
        window.open("<c:url value='/labos/createLabResultsPdf.jsp'/>?ts=<%=getTs()%>&print."+serverid+"."+transactionid+"=1","Popup"+new Date().getTime(),"toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=800, height=600, menubar=no");
    }
    function doBack(){
        window.location.href="<c:url value="/main.do"/>?Page=labos/showLabRequestList.jsp";
    }
</script>