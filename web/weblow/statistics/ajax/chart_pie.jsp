<%@ page import="be.openclinic.statistics.*" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.common.*" %>
<%@ page import="be.openclinic.statistics.KeyValue" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@include file="/includes/validateUser.jsp" %>
<%!public static HashMap xml_entities_table = new HashMap();
    public static String xmlEntities(String str) {
        String s = "";
        s = str.replaceAll("&", "&amp;");
        s = str.replaceAll("<", "&lt;");
        s = str.replaceAll(">", "&gt;");
        s = str.replaceAll("\"", "&quot;");
        s = str.replaceAll("\'", "");
        return s;
    }%>
<%
     String sWidth = checkString(request.getParameter("width"));
    String sHeight = checkString(request.getParameter("height"));
    String sId = checkString(request.getParameter("id"));
    HospitalStats h = (HospitalStats) session.getAttribute("hospitalStats");
    PieChart chart = null;
    String sTopLegend = "";
    be.openclinic.common.KeyValue[] kv = null;
    String sLabelscode = "";
    if (sId.equals("T10FCCA")) {
        chart = h.getT10FCCAChart();
        sLabelscode = "icd10code";
    } else if (sId.equals("T10PFCCA")) {
        chart = h.getT10PFCCAChart();
        sLabelscode = "icd10code";
    } else if (sId.equals("T10ADA")) {
        chart = h.getT10ADAChart();
        sLabelscode = "icd10code";
    } else if (sId.equals("T10ADAR")) {
        chart = h.getT10ADARChart();
        sLabelscode = "icd10code";
    } else if (sId.equals("IDF")) {
        chart = h.getIDFChart();
    } else if (sId.equals("T10IDD")) {
        chart = h.getT10IDDChart();
        sLabelscode = "prestation";
    } else if (sId.equals("T10IDS")) {
        chart = h.getT10IDSChart();
    } else if (sId.indexOf("IDFSA_") == 0) {
        String[] s = sId.split("_");
        chart = h.getIDFSAChart(s[1]);
        sTopLegend = "<div class='topLegend'>"+s[1]+" "+getTran("service",s[1],sWebLanguage)+"</div>";                
    } else if (sId.indexOf("T10IDDSA_") == 0) {
        String[] s = sId.split("_");
        chart = h.getT10IDDSAChart(s[1]);
        sLabelscode = "prestation";
    } else if (sId.indexOf("IDFSV_") == 0) {
        String[] s = sId.split("_");
        chart = h.getIDFSVChart(s[1]);
        sTopLegend = "<div class='topLegend'>"+getTran("service",s[1],sWebLanguage)+"</div>";
    } else if (sId.indexOf("T10IDDSV_") == 0) {
        String[] s = sId.split("_");
        chart = h.getT10IDDSVChart(s[1]);
         sLabelscode = "prestation";
    } else if (sId.equals("T10DRA")) {
        chart = h.getT10DRAChart();
         sLabelscode = "prestation";
    } else if (sId.equals("T10DRV")) {
        chart = h.getT10DRVChart();
         sLabelscode = "prestation";
    } else if (sId.indexOf("T10DRAD_") == 0) {
        String[] s = sId.split("_");
        kv = h.getT10DRV();
        chart = h.getT10DRADChart(kv[Integer.parseInt(s[1])].getKey());
        sTopLegend = "<div class='topLegend'>"+getTran("web.statistics","clinical.condition",sWebLanguage)+ " "+s[1]+"</div>";
        sLabelscode = "prestation";
    } else if (sId.indexOf("T10DRVD_") == 0) {
        String[] s = sId.split("_");
        kv = h.getT10DRV();
        chart = h.getT10DRVDChart(kv[Integer.parseInt(s[1])].getKey());
        sTopLegend = "<div class='topLegend'>"+getTran("web.statistics","clinical.condition",sWebLanguage)+ " "+s[1]+"</div>";
        sLabelscode = "prestation";
    }

    String sLegends ="<ul class='legend'>";
    String strXML = "<graph showNames='0'  hoverCapSepChar='#' formatNumberScale='0'  showPercentageValues='1' " +
            "baseFontColor='4c4c4c' decimalPrecision='0' pieFillAlpha='60'" +
            "chartBottomMargin='0' showAlternateHGridColor='1' alternateHGridColor='EFF3E2' >";
    String sLabel = "";
    for (int n = 0; n < chart.getValues().size(); n++) {
        KeyValue value = (KeyValue) chart.getValues().elementAt(n);

        if(sLabelscode.length()>0){
            sLabel = HTMLEntities.htmlentities(xmlEntities(MedwanQuery.getInstance().getCodeTran(sLabelscode + value.getKey(), sWebLanguage))) ;
        }else{
            sLabel = HTMLEntities.htmlentities(xmlEntities(getTranNoLink("service",value.getKey(), sWebLanguage))) ;
        }
        strXML += "<set  name='" + sLabel+ "' value='" + value.getValue() + "' color='"+sCOLORS[n]+"'/>";
        sLegends+="<li><span style='background-color:"+sCOLORS[n]+"'>&nbsp;&nbsp;&nbsp;&nbsp;</span>"+sLabel+"&nbsp;</li>";
    }

    strXML += "</graph>";

    sLegends+="</ul>";

    String swf = request.getContextPath() + "/FusionCharts/FCF_Pie2D.swf";%>
<div class="statBlockHalfTop"><%=getTranNoLink("web.statistics", chart.getName(), sWebLanguage)%>&nbsp;</div>
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
<%=sLegends%>

