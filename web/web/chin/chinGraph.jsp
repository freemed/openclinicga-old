<%@ page import="be.openclinic.statistics.chin.CHINAnalyser" %>
<%@ page import="java.util.Vector" %>
<%@ page import="be.openclinic.statistics.chin.Indicator" %>
<%@ page import="be.openclinic.statistics.chin.DiagnosisTrend" %>
<%@ page import="be.openclinic.statistics.chin.Alert" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ include file="../includes/validateUser.jsp"%>
<%=checkPermission("statistics.chin","select",activeUser)%>
<SCRIPT Language="JavaScript" src="<c:url value='/_common/_script/diagram2.js'/>"></SCRIPT>
<SCRIPT Language="JavaScript">
document.open();

_BFont="font-family:Verdana;font-weight:bold;font-size:8pt;line-height:8pt;"; 
<%
    CHINAnalyser chinAnalyser = new CHINAnalyser();
    Vector indicators = chinAnalyser.getCHINIndicators();
    int graphcounter=0;
    for (int n = 0; n < indicators.size(); n++) {
        Indicator indicator = (Indicator) indicators.elementAt(n);
        if (indicator.getType().equalsIgnoreCase("diagnosistrend")) {
            DiagnosisTrend diagnosisTrend = (DiagnosisTrend) indicator;
            diagnosisTrend.analyse();
            Vector alerts = diagnosisTrend.getAlerts();
            for (int a = 0; a < alerts.size(); a++) {
                Alert alert=(Alert)alerts.elementAt(a);
                double[] values = alert.getValues();
                if(values!=null && values.length>0){
                    double maxVal=0;
                    for(int v=0;v<values.length;v++){
                        if(values[v]>maxVal){
                            maxVal=values[v];
                        }
                    }
                    %>
                    var D<%=n+"_"+a%>=new Diagram();
                    D<%=n+"_"+a%>.SetFrame(60, 50+<%=graphcounter%>*300, 984, <%=graphcounter%>*300+300);
                    var maxRef=Math.pow(10,Math.ceil(Math.log(<%=maxVal%>)/Math.log(10)));
                    if(maxRef>0){
                        while (maxRef><%=maxVal%>*2){
                            maxRef/=2;
                        }
                    }
                    D<%=n+"_"+a%>.SetBorder(-1, <%=values.length+1%>, 0, maxRef);
                    D<%=n+"_"+a%>.SetText("<%=getTranNoLink("web","period",sWebLanguage)%>","<%=getTranNoLink("web",alert.getType().startsWith("relative")?"casespct":"cases",sWebLanguage)%>", "<%=diagnosisTrend.getComment(sWebLanguage)%>");
                    D<%=n+"_"+a%>.SetGridColor("#000000");
                    D<%=n+"_"+a%>.XScale=0;
                    D<%=n+"_"+a%>.Draw("lightgray", "#000000", true);
                    var i, j, y;
                    <%
                    for(int v=0;v<values.length;v++){
                        %>
                        j=D<%=n+"_"+a%>.ScreenX(<%=values.length-v%>+0.5);
                        new Bar(j-5, D<%=n+"_"+a%>.ScreenY(<%=values[v]%>), j+5, D<%=n+"_"+a%>.ScreenY(0), "<%=values[v]>alert.getLevel()?"#FF6500":"#FF6500"%>", "<%=new DecimalFormat("#").format(values[v])%>", "#000000", "<%=new DecimalFormat("#.00").format(values[v])+(alert.getType().startsWith("relative")?"%":"")%>");
                        <%
                    }
                    graphcounter++;
                }
            }
        }
    }
%>
document.close();
</SCRIPT>