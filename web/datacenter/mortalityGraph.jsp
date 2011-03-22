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
	List lValues2 = MortalityGraph.getListValueGraphYear(serverId,code,sWebLanguage,activeUser.userid);

    String sJsArray2 = "[";
    for(Iterator it=lValues2.iterator();it.hasNext();){
        Object[] o = (Object[])it.next();
        Date dDate = (Date)o[0];
        Double iValue = (Double)o[1];
        sJsArray2+="["+dDate.getTime()+","+iValue+"],";
    }
    sJsArray2+="]";
%>
<div style="float:left;padding-left:20px;">
<div id="barchart" style="width: 620px; height: 300px; position: relative;"></div>
    <div style="float:left;height:30px;font-size:15px;text-align:center;width:100%;"><%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%></div>
</div>
<script type="text/javascript">
    setGraph2(<%=sJsArray%>,<%=sJsArray2%>);
    Modalbox.setTitle("<%=HTMLEntities.htmlentities(getTran("datacenterserver", serverId + "", sWebLanguage)+"<br/>"+code+" - "+MedwanQuery.getInstance().getCodeTran("ICD10Code"+code,sWebLanguage)+" (%"+getTranNoLink("web","mortality",sWebLanguage)+")")%>");
</script>