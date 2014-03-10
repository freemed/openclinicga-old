<%@page import="be.openclinic.datacenter.*" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	int serverId=Integer.parseInt(request.getParameter("serverid"));
	int graphWidth=Integer.parseInt(request.getParameter("graphwidth"));
	String code=request.getParameter("code"); //ceci représente le code du morceau à sortir de la graphique
	String period=request.getParameter("period");
	java.util.Vector financials = DatacenterHelper.getFinancials(serverId,period);

    String strXML = "<graph bgColor='F7F7F7' numberSuffix=' RWF' showNames='1' showValues='0' pieBorderAlpha='100' pieBorderThickness='0' animation='1' shadowXShift='4' shadowYShift='4' shadowAlpha='40' pieFillAlpha='95' pieBorderColor='FFFFFF' > ";
    
     for(int n=0;n<financials.size();n++){
        String financial=(String)financials.elementAt(n);
		String cls = financial.split(";")[0].toUpperCase(); //code/libellé de l'élément
		if(cls==null || cls.length()==0){
			cls="?";
		}

        double amount=Double.parseDouble(financial.split(";")[1]); //montant de l'élément

        strXML += "<set name='" + cls + "' value='" + amount + "' isSliced='"+(code.equals(cls)?'1':'0')+"'/>";
    }
    strXML+="</graph>";

%>
<script>
        var myChart = new FusionCharts( "<c:url value="/FusionCharts/FCF_Pie2D.swf" />","myChartId", "<%=graphWidth%>", "250", "0", "0" );
                              myChart.setDataXML("<%=strXML%>");
                              myChart.setTransparent(true);
                              myChart.render("financial_chart_ajax");
</script>