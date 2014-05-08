<%@ page import="be.openclinic.statistics.ServiceStats" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.statistics.ServicePeriodStats" %>
<%@ page import="be.mxs.common.util.system.ScreenHelper" %>
<%@ include file="../includes/validateUser.jsp"%>
<%@ page import="webcab.lib.statistics.correlation.Correlation" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="be.openclinic.statistics.HospitalStats" %>
<%!
    private void drawGraph(double[] values,int a,javax.servlet.jsp.JspWriter out,String sWebLanguage,String label,String titel,int graphcounter,int limit,double y0, double y1) throws Exception{
        int n=a;
        //Patients
        if(values!=null && values.length>0){
            double maxVal=0;
            for(int v=0;v<values.length;v++){
                if(values[v]>maxVal){
                    maxVal=values[v];
                }
            }
            out.println("var D"+n+"_"+a+"=new Diagram();");
            out.println("D"+n+"_"+a+".SetFrame((screen.availWidth-1050)/2+70, 50+"+graphcounter+"*250, (screen.availWidth-1050)/2+1020, "+graphcounter+"*250+200);");
            out.println("var maxRef=Math.pow(10,Math.ceil(Math.log("+maxVal+")/Math.log(10)));");
            out.println("if(maxRef>0){");
                out.println("while (maxRef>"+maxVal+"*2){");
                    out.println("maxRef/=2;");
                out.println("}");
            out.println("}");
            out.println("D"+n+"_"+a+".SetBorder(-1, "+(values.length+1)+", 0, maxRef);");
            out.println("D"+n+"_"+a+".SetText(\""+getTranNoLink("web","period",sWebLanguage)+"\",\""+getTranNoLink("web",label,sWebLanguage)+"\", \""+titel+(limit>0?" ("+getTranNoLink("web","limit",sWebLanguage)+"="+limit+")":"")+"\");");
            out.println("D"+n+"_"+a+".SetGridColor(\"#44CC44\");");
            out.println("D"+n+"_"+a+".XScale=0;");
            out.println("D"+n+"_"+a+".Draw(\"#FFFF80\", \"#004080\", true);");
            out.println("var i, j, y, w;");
            if(limit==0) limit=9999999;
            double mod=Math.ceil(values.length/52.0);
            if (mod<=1){
                mod=1;
            }
            else{
                mod*=2;
            }
            for(int v=0;v<values.length;v++){
                out.println("j=D"+n+"_"+a+".ScreenX("+v+"+0.5);");
                if(v % mod==0){
                    out.println("new Bar(j-"+Math.min(10,Math.floor(450.0/values.length))+", D"+n+"_"+a+".ScreenY(0), j+"+Math.min(10,Math.floor(450.0/values.length))+", D"+n+"_"+a+".ScreenY(0), \""+(limit>0 && values[v]>limit?"red":limit<0 && v>0 && values[v]>-limit*values[v-1]?"red":"green")+"\", \""+ScreenHelper.padLeft(v+1+"","0",2)+"\", \"#FFFFFF\", \""+new DecimalFormat("#.00").format(values[v])+"\");");
                }
                out.println("new Bar(j-"+Math.min(5,Math.floor(450.0/values.length))+", D"+n+"_"+a+".ScreenY("+values[v]+"), j+"+Math.min(5,Math.floor(450.0/values.length))+", D"+n+"_"+a+".ScreenY(0), \""+(limit>0 && values[v]>limit?"red":limit<0 && v>0 && values[v]>-limit*values[v-1]?"red":"green")+"\", \"\", \"#FFFFFF\", \""+new DecimalFormat("#.00").format(values[v])+"\");");
            }
            out.println("new Line(D"+n+"_"+a+".ScreenX(0), D"+n+"_"+a+".ScreenY("+y0+"), D"+n+"_"+a+".ScreenX("+values.length+"), D"+n+"_"+a+".ScreenY("+y1+"), \"black\", 3, \"linear regression\");");
        }
    }
%>
<head>
    <%=sCSSNORMAL%>
</head>
<%
    String begin=request.getParameter("begin");
    String end=request.getParameter("end");
    String service=checkString(request.getParameter("ServiceID"));
    String serviceName = "";
    if(service.length()>0){
        serviceName=getTran("service",service,sWebLanguage);
    }
    if(begin==null){
        begin="01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    if(end==null){
        end=ScreenHelper.stdDateFormat.format(new java.util.Date());
    }
    if(request.getParameter("calculate")==null){
%>
<form name="diagstats" id="diagstats" method="post" action="<c:url value='/'/>statistics/serviceStats.jsp" target="_new">
    <%=writeTableHeader("Web","statistics.servicestats",sWebLanguage," doBack();")%>
    <table width="100%" class="menu" cellspacing="0" cellpadding="0">
        <tr>
            <td><%=getTran("web","from",sWebLanguage)%>&nbsp;</td>
            <td>
                <%=writeDateField("begin","diagstats",begin,sWebLanguage)%>&nbsp;
                <%=getTran("web","to",sWebLanguage)%>&nbsp;
                <%=writeDateField("end","diagstats",end,sWebLanguage)%>&nbsp;
            </td>
        </tr>
        <tr>
            <td><%=getTran("Web","service",sWebLanguage)%></td>
            <td colspan='2'>
                <input type="hidden" name="ServiceID" value="<%=service%>">
                <input class="text" type="text" name="ServiceName" readonly size="<%=sTextWidth%>" value="<%=serviceName%>" >
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchService('ServiceID','ServiceName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="ServiceID.value='';ServiceName.value='';">
            </td>
        </tr>
        <tr>
            <td/>
            <td>
                <input type="submit" class="button" name="calculate" value="<%=getTran("web","calculate",sWebLanguage)%>"/>
                <input type="button" class="button" name="backButton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
    </table>
    <script>
        function searchService(serviceUidField,serviceNameField){
            openPopup("_common/search/searchService.jsp&ts=<%=getTs()%>&showinactive=1&VarCode="+serviceUidField+"&VarText="+serviceNameField);
            document.getElementsByName(serviceNameField)[0].focus();
        }
        function doBack(){
            window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
        }

    </script>
<%
}
else {
    Service myservice = Service.getService(service);
    ServiceStats serviceStats = new ServiceStats(service, ScreenHelper.parseDate(begin), ScreenHelper.parseDate(end));
    out.println("<table width='100%'><tr><td class='admin'><center>"+getTran("web","statistics.for",sWebLanguage)+" "+(myservice!=null?myservice.getLabel(sWebLanguage):getTran("web","hospitalname",sWebLanguage))+" "+getTran("web","between",sWebLanguage)+" "+ ScreenHelper.stdDateFormat.format(serviceStats.getBegin())+" "+getTran("web","and",sWebLanguage)+" "+ ScreenHelper.stdDateFormat.format(serviceStats.getEnd())+"<center></td></tr></table>");

%>
<SCRIPT Language="JavaScript" src="<c:url value='/_common/_script/diagram2.js'/>"></SCRIPT>
<SCRIPT Language="JavaScript">
document.open();
_BFont="font-family:arial;font-weight:bold;font-size:8pt;line-height:8pt;";
<%
    Correlation correlation = new Correlation();
    if (serviceStats.nonPeriodPatientsZero()) drawGraph(serviceStats.getPeriodPatients(),0,out,sWebLanguage,getTran("web","patients",sWebLanguage),getTran("web","weekly.evolution.of",sWebLanguage)+" # <b>"+getTran("web","patients",sWebLanguage)+"<b>",0,HospitalStats.getBedCapacity(),correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),0),correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length));
    if (serviceStats.nonPeriodAdmissionsZero()) drawGraph(serviceStats.getPeriodAdmissions(),1,out,sWebLanguage,getTran("web","admissions.short",sWebLanguage),getTran("web","weekly.evolution.of",sWebLanguage)+" # <b>"+getTran("web","admissions",sWebLanguage)+"<b>",1,-2,correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),0),correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length));
    if (serviceStats.nonPeriodAdmissionDaysZero()) drawGraph(serviceStats.getPeriodAdmissionDays(),2,out,sWebLanguage,getTran("web","admission.days.short",sWebLanguage),getTran("web","weekly.evolution.of",sWebLanguage)+" # <b>"+getTran("web","admission.days",sWebLanguage)+"<b>",2,-2,correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),0),correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length));
    if (serviceStats.nonPeriodVisitsZero()) drawGraph(serviceStats.getPeriodVisits(),3,out,sWebLanguage,getTran("web","visits",sWebLanguage),getTran("web","weekly.evolution.of",sWebLanguage)+" # <b>"+getTran("web","visits",sWebLanguage)+"<b>",3,-2,correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),0),correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length));
%>
window.moveTo(0,0);
window.resizeTo(screen.width,screen.height);
</script>
        <table height='200'><tr><td> </td></tr></table>
        <center>
            <table class="menu" width="60%">
                <tr>
                    <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=new DecimalFormat("#0.00").format(correlation.mean(serviceStats.getPeriodPatientsY()))%></b></td>
                    <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=new DecimalFormat("#0.00").format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodPatientsY()))%></b></td>
                    <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>patients = <%=new DecimalFormat("#0.00").format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodPatientsY())[0])%> x weeks + <%=new DecimalFormat("#0.00").format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodPatientsY())[1])%></b></td>
                </tr>
                <tr>
                    <td>+Y1: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+52))%></b></td>
                    <td>+Y2: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+104))%></b></td>
                    <td>+Y3: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+156))%></b></td>
                    <td>+Y5: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodPatientsY(),serviceStats.getX().length+260))%></b></td>
                </tr>
            </table>
        </center>
        <table height='214'><tr><td> </td></tr></table>
        <center>
            <table class="menu" width="60%">
                <tr>
                    <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=new DecimalFormat("#0.00").format(correlation.mean(serviceStats.getPeriodAdmissionsY()))%></b></td>
                    <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=new DecimalFormat("#0.00").format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodAdmissionsY()))%></b></td>
                    <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>admissions = <%=new DecimalFormat("#0.00").format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY())[0])%> x weeks + <%=new DecimalFormat("#0.00").format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY())[1])%></b></td>
                </tr>
                <tr>
                    <td>+Y1: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+52))%></b></td>
                    <td>+Y2: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+104))%></b></td>
                    <td>+Y3: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+156))%></b></td>
                    <td>+Y5: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionsY(),serviceStats.getX().length+260))%></b></td>
                </tr>
            </table>
        </center>
    <table height='214'><tr><td> </td></tr></table>
    <center>
        <table class="menu" width="60%">
            <tr>
                <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=new DecimalFormat("#0.00").format(correlation.mean(serviceStats.getPeriodAdmissionDaysY()))%></b></td>
                <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=new DecimalFormat("#0.00").format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY()))%></b></td>
                <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>admission days = <%=new DecimalFormat("#0.00").format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY())[0])%> x weeks + <%=new DecimalFormat("#0.00").format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY())[1])%></b></td>
            </tr>
            <tr>
                <td>+Y1: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+52))%></b></td>
                <td>+Y2: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+104))%></b></td>
                <td>+Y3: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+156))%></b></td>
                <td>+Y5: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodAdmissionDaysY(),serviceStats.getX().length+260))%></b></td>
            </tr>
        </table>
    </center>
    <%
        if (serviceStats.nonPeriodVisitsZero()){
    %>
    <table height='214'><tr><td> </td></tr></table>
        <center>
            <table class="menu" width="60%">
                <tr>
                    <td><%=getTran("web","mean.value",sWebLanguage)%>: <b><%=new DecimalFormat("#0.00").format(correlation.mean(serviceStats.getPeriodVisitsY()))%></b></td>
                    <td><%=getTran("web","pearsson",sWebLanguage)%>: <b><%=new DecimalFormat("#0.00").format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(),serviceStats.getPeriodVisitsY()))%></b></td>
                    <td colspan="2"><%=getTran("web","linear.regression",sWebLanguage)%>: <b>visits = <%=new DecimalFormat("#0.00").format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodVisitsY())[0])%> x weeks + <%=new DecimalFormat("#0.00").format(correlation.leastSquaresRegressionLineY(serviceStats.getX(),serviceStats.getPeriodVisitsY())[1])%></b></td>
                </tr>
                <tr>
                    <td>+Y1: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+52))%></b></td>
                    <td>+Y2: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+104))%></b></td>
                    <td>+Y3: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+156))%></b></td>
                    <td>+Y5: <b><%=new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(),serviceStats.getPeriodVisitsY(),serviceStats.getX().length+260))%></b></td>
                </tr>
            </table>
        </center>
    <%
        }
    }

%>
