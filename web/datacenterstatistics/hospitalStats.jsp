<%@ page import="be.openclinic.statistics.ServiceStats" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.statistics.ServicePeriodStats" %>
<%@ page import="be.mxs.common.util.system.ScreenHelper" %>
<%@ include file="../includes/validateUser.jsp"%>
<%@ page import="webcab.lib.statistics.correlation.Correlation" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="be.openclinic.statistics.HospitalStats" %>
<%@ page import="be.openclinic.system.Examination" %>
<%@ page import="java.util.Enumeration" %>
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
    private double sumValues(double[] values){
        double sum=0;
        for(int n=0;n<values.length;n++){
            sum+=values[n];
        }
        return sum;
    }

%>
<head>
    <%=sCSSNORMAL%>
</head>
<%
    String begin=request.getParameter("begin");
    String end=request.getParameter("end");
    if(begin==null){
        begin="01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    if(end==null){
        end=new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
    }
    if(request.getParameter("calculate")==null){
%>
<form name="diagstats" id="diagstats" method="post" action="<c:url value='/'/>statistics/hospitalStats.jsp" target="_new">
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
            <td/>
            <td>
                <input type="submit" class="button" name="calculate" value="<%=getTran("web","calculate",sWebLanguage)%>"/>
                <input type="button" class="button" name="backButton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
    </table>
    <script>
        function doBack(){
            window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
        }

    </script>
<%
}
else {
    ServiceStats serviceStats = new ServiceStats("", new SimpleDateFormat("dd/MM/yyyy").parse(begin), new SimpleDateFormat("dd/MM/yyyy").parse(end));
    out.println("<table width='100%'><tr><td class='admin'><center>"+getTran("web","contact.statistics.for",sWebLanguage)+" "+getTran("web","hospitalname",sWebLanguage)+" "+getTran("web","between",sWebLanguage)+" "+ new SimpleDateFormat("dd/MM/yyyy").format(serviceStats.getBegin())+" "+getTran("web","and",sWebLanguage)+" "+ new SimpleDateFormat("dd/MM/yyyy").format(serviceStats.getEnd())+"<center></td></tr></table>");

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
            <table class="menu" width="100%">
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
            <table class="menu" width="100%">
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
        <table class="menu" width="100%">
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
            <table class="menu" width="100%">
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
        out.println("<table width='100%'><tr><td class='admin'><center>"+getTran("web","activity.statistics.for",sWebLanguage)+" "+getTran("web","hospitalname",sWebLanguage)+" "+getTran("web","between",sWebLanguage)+" "+ new SimpleDateFormat("dd/MM/yyyy").format(serviceStats.getBegin())+" "+getTran("web","and",sWebLanguage)+" "+ new SimpleDateFormat("dd/MM/yyyy").format(serviceStats.getEnd())+"<center></td></tr></table>");
        out.print("<script type=\"text/javascript\">");
        String sComments = "";
        Enumeration transactionTypes = serviceStats.getPeriodTransactionTypes().keys();
        int n = 4;
        int jump = 200;
        double _periodCost = 0, _costY1 = 0, _costY2 = 0, _costY3 = 0, _costY4 = 0, _costY5 = 0, _costY10 = 0;
        while (transactionTypes.hasMoreElements()) {
            String transactionType = (String) transactionTypes.nextElement();
            double[] values = serviceStats.getPeriodTransactions(transactionType);
            drawGraph(values, n, out, sWebLanguage, getTran("web", "examinations", sWebLanguage), getTran("web", "weekly.evolution.of", sWebLanguage) + " # <b>" + getTran("web.occup", transactionType, sWebLanguage) + "</b>", n, 0, correlation.estimateY(serviceStats.getX(), values, 0), correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length));
            n++;
            Examination examination = new Examination(transactionType);
            _periodCost += examination.getCost() * sumValues(values);
            _costY1 += correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 52) * examination.getCost() * serviceStats.getX().length;
            _costY2 += correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 104) * examination.getCost() * serviceStats.getX().length;
            _costY3 += correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 156) * examination.getCost() * serviceStats.getX().length;
            _costY4 += correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 208) * examination.getCost() * serviceStats.getX().length;
            _costY5 += correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 260) * examination.getCost() * serviceStats.getX().length;
            _costY10 += correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 520) * examination.getCost() * serviceStats.getX().length;
            sComments += "<table height='" + jump + "'><tr><td> </td></tr></table><center>" +
                    "            <table class=\"menu\" width=\"100%\">" +
                    "                <tr>" +
                    "                    <td>" + getTran("web", "mean.value", sWebLanguage) + ": <b>" + new DecimalFormat("#0.00").format(correlation.mean(values)) + "</b></td>\n" +
                    "                    <td>" + getTran("web", "pearsson", sWebLanguage) + ": <b>" + new DecimalFormat("#0.00").format(correlation.pearsonCorrelationCoefficient(serviceStats.getX(), values)) + "</b></td>\n" +
                    "                    <td colspan=\"2\">" + getTran("web", "linear.regression", sWebLanguage) + ": <b>" + getTran("web", "examinations", sWebLanguage) + " = " + new DecimalFormat("#0.00").format(correlation.leastSquaresRegressionLineY(serviceStats.getX(), values)[0]) + " x " + getTran("web", "weeks", sWebLanguage) + " + " + new DecimalFormat("#0.00").format(correlation.leastSquaresRegressionLineY(serviceStats.getX(), values)[1]) + "</b></td>" +
                    "                   <td>" + getTran("web", "unit.cost", sWebLanguage) + ": <b>" + examination.getCost() + "</b></td>" +
                    "                   <td>" + getTran("web", "period.cost", sWebLanguage) + ": <b>" + new DecimalFormat("###,###,###,###,##0").format(examination.getCost() * sumValues(values)) + "</b></td>" +
                    "                </tr>" +
                    "                <tr>" +
                    "                    <td>+Y1: <b>" + new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 52)) + " (" + new DecimalFormat("####,###,###,###,##0").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 52) * examination.getCost() * serviceStats.getX().length) + ")</b></td>" +
                    "                    <td>+Y2: <b>" + new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 104)) + " (" + new DecimalFormat("###,###,###,###,##0").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 104) * examination.getCost() * serviceStats.getX().length) + ")</b></td>" +
                    "                    <td>+Y3: <b>" + new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 156)) + " (" + new DecimalFormat("###,###,###,###,##0").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 156) * examination.getCost() * serviceStats.getX().length) + ")</b></td>" +
                    "                    <td>+Y4: <b>" + new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 208)) + " (" + new DecimalFormat("###,###,###,###,##0").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 208) * examination.getCost() * serviceStats.getX().length) + ")</b></td>" +
                    "                    <td>+Y5: <b>" + new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 260)) + " (" + new DecimalFormat("###,###,###,###,##0").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 260) * examination.getCost() * serviceStats.getX().length) + ")</b></td>" +
                    "                    <td>+Y10: <b>" + new DecimalFormat("#0.00").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 520)) + " (" + new DecimalFormat("###,###,###,###,##0").format(correlation.estimateY(serviceStats.getX(), values, serviceStats.getX().length + 520) * examination.getCost() * serviceStats.getX().length) + ")</b></td>" +
                    "                </tr>" +
                    "            </table>" +
                    "        </center>";
            jump = 214;
        }
        %>
        </script>
        <%
            double overhead=HospitalStats.getOverheadCosts();
        sComments+="<p/><center>" +
                "            <table class=\"menu\" width=\"100%\">" +
                "              <tr><td colspan='7'><b>" +getTran("web","costtotals",sWebLanguage).toUpperCase()+"</b></td></tr>"+
                "              <tr><td colspan='7'><b>" +getTran("web","costtotals.overhead",sWebLanguage).toUpperCase()+"</b></td></tr>"+
                "                <tr>" +
                "                    <td colspan='7'>"+getTran("web","period",sWebLanguage)+": <b>"+new DecimalFormat("####,###,###,###,##0").format(overhead)+"</b></td>" +
                "                </tr>" +
                "              <tr><td colspan='7'><b>" +getTran("web","costtotals.specific",sWebLanguage).toUpperCase()+"</b></td></tr>"+
                "                <tr>" +
                "                    <td>"+getTran("web","period",sWebLanguage)+": <b>"+new DecimalFormat("####,###,###,###,##0").format(_periodCost)+"</b></td>" +
                "                    <td>+Y1: <b>"+new DecimalFormat("####,###,###,###,##0").format(_costY1)+"</b></td>" +
                "                    <td>+Y2: <b>"+new DecimalFormat("####,###,###,###,##0").format(_costY2)+"</b></td>" +
                "                    <td>+Y3: <b>"+new DecimalFormat("####,###,###,###,##0").format(_costY3)+"</b></td>" +
                "                    <td>+Y4: <b>"+new DecimalFormat("####,###,###,###,##0").format(_costY4)+"</b></td>" +
                "                    <td>+Y5: <b>"+new DecimalFormat("####,###,###,###,##0").format(_costY5)+"</b></td>" +
                "                    <td>+Y10: <b>"+new DecimalFormat("####,###,###,###,##0").format(_costY10)+"</b></td>" +
                "                </tr>" +
                "              <tr><td colspan='7'><b>" +getTran("web","costtotals.total",sWebLanguage).toUpperCase()+"</b></td></tr>"+
                "                <tr>" +
                "                    <td>"+getTran("web","period",sWebLanguage)+": <b>"+new DecimalFormat("####,###,###,###,##0").format(overhead+_periodCost)+"</b></td>" +
                "                    <td>+Y1: <b>"+new DecimalFormat("####,###,###,###,##0").format(overhead+_costY1)+"</b></td>" +
                "                    <td>+Y2: <b>"+new DecimalFormat("####,###,###,###,##0").format(overhead+_costY2)+"</b></td>" +
                "                    <td>+Y3: <b>"+new DecimalFormat("####,###,###,###,##0").format(overhead+_costY3)+"</b></td>" +
                "                    <td>+Y4: <b>"+new DecimalFormat("####,###,###,###,##0").format(overhead+_costY4)+"</b></td>" +
                "                    <td>+Y5: <b>"+new DecimalFormat("####,###,###,###,##0").format(overhead+_costY5)+"</b></td>" +
                "                    <td>+Y10: <b>"+new DecimalFormat("####,###,###,###,##0").format(overhead+_costY10)+"</b></td>" +
                "                </tr>" +
                "            </table>" +
                "        </center>";
        out.print(sComments);
    }
%>