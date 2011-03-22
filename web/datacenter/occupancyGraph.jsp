<%@page import="be.openclinic.datacenter.BedOccupancyGraph" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.Date" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	int serverId=Integer.parseInt(request.getParameter("serverid"));
	String code=request.getParameter("servicecode");
	List lValues = BedOccupancyGraph.getListValueGraph(serverId,code.split(";")[0],sWebLanguage,activeUser.userid);

    String sJsArray = "[";
    for(Iterator it=lValues.iterator();it.hasNext();){
        Object[] o = (Object[])it.next();
        Date dDate = (Date)o[0];
        Double iValue = (Double)o[1];
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
    Modalbox.setTitle("<%=HTMLEntities.htmlentities(getTran("datacenterserver", serverId + "", sWebLanguage)+"<br/>"+code.split(";")[0]+" - "+code.split(";")[1]+" (%"+getTranNoLink("web","occupancy",sWebLanguage)+")")%>");
</script>