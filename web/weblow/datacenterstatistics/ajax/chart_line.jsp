<%@ page import="be.openclinic.statistics.HospitalStats" %>
<%@ page import="be.openclinic.statistics.BaseChart" %>
<%@ page import="be.openclinic.statistics.XYValue" %>
<%@ page import="be.mxs.common.util.system.StatFunctions" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sId = checkString(request.getParameter("id"));
    HospitalStats h = (HospitalStats)session.getAttribute("hospitalStats");
    int iModulo = 5;
    int iAnchors = 1;
    BaseChart chart = null;
    int[] iValues = null;
    if(sId.equals("WA")){
      chart = h.getWAChart();
      iValues = h.getWA();
    }else if(sId.equals("WV")){
       chart = h.getWVChart();
        iValues = h.getWV();
    }else if(sId.equals("DAP")){
       chart = h.getDAPChart();
        iValues = h.getDAP();
        iModulo = 30;
        iAnchors=0;
    }else if(sId.equals("WD")){
       chart = h.getWDChart();
       iValues = h.getWD();
        iModulo = 50;
    }else if(sId.equals("WI")){
        chart = h.getWIChart();
    }

    String sWidth = checkString(request.getParameter("width"));
    String sHeight = checkString(request.getParameter("height"));
    String strXML = "<graph showAnchors='"+iAnchors+"' xAxisName='"+getTranNoLink("web.statistics",chart.getXlabel(),sWebLanguage)+"' yAxisName='"+getTranNoLink("web.statistics",chart.getYlabel(),sWebLanguage)+"' showValues='0' "+
    "baseFontColor='4c4c4c'  divLineColor='CCCCCC' bgAlpha='0' " +
    "canvasBorderColor='dddddd' divLineAlpha='80' decimalPrecision='0' "+
     "chartBottomMargin='0' showAlternateHGridColor='1' alternateHGridColor='EFF3E2' ";
    double min = 0;
    double max = 0;
    String sSets = "";
    for (int n = 0; n < chart.getValues().size(); n++) {
        XYValue xyvalue = (XYValue) chart.getValues().elementAt(n);
        if(min==0 || min>xyvalue.getY()){
            min =  xyvalue.getY();
        }
        if(max==0 || max<xyvalue.getY()){
            max =  xyvalue.getY();
        }
        sSets += "<set  name='" + (int) xyvalue.getX() + "' value='" + xyvalue.getY() + "'" + (n % iModulo == 0 ? " showName='1'" : " showName='0'") + "/>";
    }
    double start = 0;
    double end = 0;
    if(iValues!=null){
        start = StatFunctions.getSimpleRegression(iValues,0);
        end = StatFunctions.getSimpleRegression(iValues,iValues.length-1);
        sSets +="<trendlines><line startvalue='"+start+"' endValue='"+end+"' displayValue=' ' color='009999' thickness='1.5' isTrendZone='0' /></trendlines>";
    }
    if(min>start){
      strXML+=" yAxisMinValue='"+start+"'";
    }else if(min>end){
      strXML+=" yAxisMinValue='"+end+"'";
    }
    if(max<start){
      strXML+=" yAxisMaxValue='"+start+"'";
    }else if(max<end){
      strXML+=" yAxisMaxValue='"+end+"'";
    }
    strXML += " >"+sSets+"</graph>";
    String swf = request.getContextPath() + "/FusionCharts/FCF_Line.swf";
%>
<div class="statBlockHalfTop"><%=getTranNoLink("web.statistics",chart.getName(),sWebLanguage)%>&nbsp;</div>
<jsp:include page="/FusionCharts/FusionChartsHTMLRenderer.jsp" flush="true">
    <jsp:param name="chartSWF" value="<%=swf%>"/>
    <jsp:param name="strURL" value=""/>
    <jsp:param name="strXML" value="<%=strXML%>"/>
    <jsp:param name="chartId" value="<%=sId+"_swf"%>"/>
    <jsp:param name="chartWidth" value="<%=sWidth%>"/>
    <jsp:param name="chartHeight" value="<%=sHeight%>"/>
    <jsp:param name="render" value="printchart"/>
</jsp:include>
