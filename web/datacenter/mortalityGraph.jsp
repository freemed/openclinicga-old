<%@page import="be.openclinic.datacenter.MortalityGraph" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	int serverId=Integer.parseInt(request.getParameter("serverid"));
	String code=request.getParameter("diagnosiscode");

	List lValues = MortalityGraph.getListValueGraph(serverId,code,sWebLanguage,activeUser.userid);
    String sJsArray = "[";
    for(Iterator it=lValues.iterator();it.hasNext();){
        Object[] o = (Object[])it.next();
        Date dDate = (Date)o[0];
        Double iValue = (Double)o[1];
        sJsArray+="["+dDate.getTime()+","+iValue+"],";
    }
    sJsArray+="]";

	lValues = MortalityGraph.getListValueGraphAbsolute(serverId,code,sWebLanguage,activeUser.userid);
    String sJsArray2 = "[";
    for(Iterator it=lValues.iterator();it.hasNext();){
        Object[] o = (Object[])it.next();
        Date dDate = (Date)o[0];
        Double iValue = (Double)o[1];
        sJsArray2+="["+dDate.getTime()+","+iValue+"],";
    }
    sJsArray2+="]";

    lValues = MortalityGraph.getListValueGraphYear(serverId,code,sWebLanguage,activeUser.userid);
    String sJsArray3 = "[";
    for(Iterator it=lValues.iterator();it.hasNext();){
        Object[] o = (Object[])it.next();
        Date dDate = (Date)o[0];
        Double iValue = (Double)o[1];
        sJsArray3+="["+dDate.getTime()+","+iValue+"],";
    }
    sJsArray3+="]";

    lValues = MortalityGraph.getListValueGraphYearAbsolute(serverId,code,sWebLanguage,activeUser.userid);
    String sJsArray4 = "[";
    for(Iterator it=lValues.iterator();it.hasNext();){
        Object[] o = (Object[])it.next();
        Date dDate = (Date)o[0];
        Double iValue = (Double)o[1];
        sJsArray4+="["+dDate.getTime()+","+iValue+"],";
    }
    sJsArray4+="]";
%>
<div style="float:left;padding-left:20px;">
	<div id="barchart" style="width: 620px; height: 300px; position: relative;"></div>
    <div style="float:left;height:30px;font-size:15px;text-align:center;width:100%;"><%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%></div>
</div>
<div style="float:left;padding-left:20px;">
	<div id="barchart2" style="width: 620px; height: 300px; position: relative;"></div>
    <div style="float:left;height:30px;font-size:15px;text-align:center;width:100%;"><%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%></div>
</div>
<script>
    //setGraph4(<%=sJsArray%>,<%=sJsArray2%>,<%=sJsArray3%>,<%=sJsArray4%>,'<%=getTranNoLink("web","monthlymortalitypct",sWebLanguage)%>','<%=getTranNoLink("web","monthlymortalityabs",sWebLanguage)%>','<%=getTranNoLink("web","yearlymortalitypct",sWebLanguage)%>','<%=getTranNoLink("web","yearlymortalityabs",sWebLanguage)%>');
    setGraph2Named(<%=sJsArray%>,<%=sJsArray2%>,'barchart','<%=getTranNoLink("web","monthlymortalitypct",sWebLanguage)%>','<%=getTranNoLink("web","monthlymortalityabs",sWebLanguage)%>');
    setGraph2Named(<%=sJsArray3%>,<%=sJsArray4%>,'barchart2','<%=getTranNoLink("web","yearlymortalitypct",sWebLanguage)%>','<%=getTranNoLink("web","yearlymortalityabs",sWebLanguage)%>');
    
    Modalbox.setTitle("<%=HTMLEntities.htmlentities(getTran("datacenterserver", serverId + "", sWebLanguage)+"<br/>"+code+" - "+MedwanQuery.getInstance().getCodeTran("ICD10Code"+code,sWebLanguage)+" ("+getTranNoLink("web","mortality",sWebLanguage)+")")%>");
</script>