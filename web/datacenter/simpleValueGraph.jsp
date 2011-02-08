<%@page import="be.openclinic.datacenter.TimeGraph" %>
<%@ page import="java.util.Date" %>
<%@ page import="org.jfree.data.time.Day" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	int serverId=Integer.parseInt(request.getParameter("serverid"));
	String parameterId=request.getParameter("parameterid");

    List lValues = TimeGraph.getListValueGraph(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/").format(new java.util.Date())+(Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-1)),
			new java.util.Date(new java.util.Date().getTime()+24*3600000),serverId,parameterId,sWebLanguage,activeUser.userid);
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
</div>
<script type="text/javascript">
    setGraph(<%=sJsArray%>);
    Modalbox.setTitle("<%=HTMLEntities.htmlentities(getTran("datacenterserver", serverId + "", sWebLanguage)) + "<br />" + HTMLEntities.htmlentities(getTranNoLink("datacenterparameter", parameterId, sWebLanguage))%>");

</script>