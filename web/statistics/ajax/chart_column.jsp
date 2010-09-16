<%@ page import="be.openclinic.statistics.*" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sId = checkString(request.getParameter("id"));
    HospitalStats h = (HospitalStats)session.getAttribute("hospitalStats");
    int iModulo = 5;
    int iAnchors = 1;
    ColumnChart chart = null;
     String[] s = sId.split("_");
    be.openclinic.common.KeyValue[] kv = null;
    String sTopLegend = "";
    if(sId.indexOf("ACP_")==0){
        kv = h.getT10PFCCA();
        chart = h.getACPChart(kv[Integer.parseInt(s[1])].getKey());
        sTopLegend = "<div class='topLegend'>"+getTran("web.statistics","comorbidity.index",sWebLanguage)+": "+h.getACPI(kv[Integer.parseInt(s[1])].getKey())+"</div>";
    }else if(sId.indexOf("ACPW_")==0){
        kv = h.getT10PFCCA();
        chart = h.getACPWChart(kv[Integer.parseInt(s[1])].getKey());
        sTopLegend = "<div class='topLegend'>"+getTran("web.statistics","weighed.comorbidity.index",sWebLanguage)+": "+h.getACPIW(kv[Integer.parseInt(s[1])].getKey())+"</div>";
    }else if(sId.indexOf("ACMP_")==0){
        kv = h.getT10PFCCA();
        chart = h.getACMPChart(kv[Integer.parseInt(s[1])].getKey());
        sTopLegend = "<div class='topLegend'>"+getTran("web.statistics","comortality.index",sWebLanguage)+": "+h.getACMPI(kv[Integer.parseInt(s[1])].getKey())+"</div>";
    }else if(sId.indexOf("ACMPW_")==0){
        kv = h.getT10PFCCA();
        chart = h.getACMPWChart(kv[Integer.parseInt(s[1])].getKey());
        sTopLegend = "<div class='topLegend'>"+getTran("web.statistics","weighed.comortality.index",sWebLanguage)+": "+h.getACMPIW(kv[Integer.parseInt(s[1])].getKey())+"</div>";
    }

    String sWidth = checkString(request.getParameter("width"));
    String sHeight = checkString(request.getParameter("height"));
    String strXML = "<graph showAnchors='"+iAnchors+"' xAxisName='"+getTranNoLink("web.statistics",chart.getXlabel(),sWebLanguage)+"' yAxisName='"+getTranNoLink("web.statistics",chart.getYlabel(),sWebLanguage)+"' showValues='0' "+
    "baseFontColor='4c4c4c'  divLineColor='CCCCCC' bgAlpha='0' " +
    "canvasBorderColor='dddddd' divLineAlpha='80' decimalPrecision='0' "+
     "chartBottomMargin='0' showAlternateHGridColor='1' alternateHGridColor='EFF3E2' >";

    for (int n = 0; n < chart.getValues().size(); n++) {
        be.openclinic.common.KeyValue value = (be.openclinic.common.KeyValue) chart.getValues().elementAt(n);
        strXML += "<set  name='" + value.getKey()+ "' value='" + value.getValue() + "' alpha='60'/>";
    }
    strXML += "</graph>";
    String swf = request.getContextPath() + "/FusionCharts/FCF_Column2D.swf";
%>
<div class="statBlockHalfTop"><%=getTranNoLink("web.statistics",chart.getName(),sWebLanguage)%>&nbsp;</div>
<%=sTopLegend%>
<jsp:include page="/FusionCharts/FusionChartsHTMLRenderer.jsp" flush="true">
    <jsp:param name="chartSWF" value="<%=swf%>"/>
    <jsp:param name="strURL" value=""/>
    <jsp:param name="strXML" value="<%=strXML%>"/>
    <jsp:param name="chartId" value="<%=sId+"_swf"%>"/>
    <jsp:param name="chartWidth" value="<%=sWidth%>"/>
    <jsp:param name="chartHeight" value="<%=sHeight%>"/>
    <jsp:param name="render" value="printchart"/>
</jsp:include>
