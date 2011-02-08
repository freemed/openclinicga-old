<%@page import="be.openclinic.datacenter.DiagnosisGraph" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	int serverId=Integer.parseInt(request.getParameter("serverid"));
	String code=request.getParameter("diagnosiscode");
	List lValues = DiagnosisGraph.getListValueGraph(serverId,code,sWebLanguage,activeUser.userid);

    String sJsArray = "[";
    for(Iterator it=lValues.iterator();it.hasNext();){
        Object[] o = (Object[])it.next();
        Date dDate = (Date)o[0];
        Integer iValue = (Integer)o[1];
        sJsArray+="["+dDate.getTime()+","+iValue+"],";
    }
    sJsArray+="]";
%>
<div style="float:left;padding-left:20px;">
<div id="barchart" style="width: 620px; height: 300px; position: relative;"></div>
    <div style="float:left;height:30px;font-size:15px;text-align:center;width:100%;"><%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%></div>
</div>
<script type="text/javascript">
    setGraph(<%=sJsArray%>);
    Modalbox.setTitle("<%=HTMLEntities.htmlentities(getTran("datacenterserver", serverId + "", sWebLanguage))%>");
</script>