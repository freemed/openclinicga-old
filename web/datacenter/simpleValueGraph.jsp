<%@page import="be.openclinic.datacenter.TimeGraph" %>
<%@page import="java.util.Date" %>
<%@page import="org.jfree.data.time.Day" %>
<%@page import="be.mxs.common.util.system.HTMLEntities" %>
<%@include file="/includes/validateUser.jsp"%>

<%
	int serverId      = -1,
        servergroupId = -1;

    String sTitle = "";

	String parameterId = request.getParameter("parameterid");
	
	// revert one year by default
	java.util.Date beginDate = ScreenHelper.parseDate(new SimpleDateFormat("dd/MM/").format(new java.util.Date())+
	                             (Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-(request.getParameter("fullperiod")==null?1:999)));
	java.util.Date endDate = new java.util.Date(new java.util.Date().getTime()+24*3600*1000);

	List lValues = null;

	// serverid specified
    if(checkString(request.getParameter("serverid")).length() > 0){
    	serverId = Integer.parseInt(request.getParameter("serverid"));
    	lValues = TimeGraph.getListValueGraph(beginDate,endDate,serverId,parameterId,sWebLanguage,activeUser.userid);
   
        sTitle = HTMLEntities.htmlentities(getTran("datacenterserver", serverId + "", sWebLanguage)) + "<br />" + HTMLEntities.htmlentities(getTranNoLink("datacenterparameter", parameterId, sWebLanguage))+
                                          (request.getParameter("fullperiod")!=null?" <a href=\\\"javascript:simpleValueGraph('"+serverId+"','"+parameterId+"')\\\">("+ScreenHelper.getTranNoLink("web", "lastyear", sWebLanguage)+")</a>":" <a href=\\\"javascript:simpleValueGraphFull('"+serverId+"','"+parameterId+"')\\\">("+ScreenHelper.getTranNoLink("web", "fullperiod", sWebLanguage)+")</a>");
    }
	// OR servergroupid specified
    else if(checkString(request.getParameter("servergroupid")).length() > 0){
    	servergroupId = Integer.parseInt(request.getParameter("servergroupid"));    	
    	lValues = TimeGraph.getListValueGraphForServerGroup(beginDate,endDate,servergroupId,parameterId,sWebLanguage,activeUser.userid);

        sTitle = HTMLEntities.htmlentities(getTran("datacenterServerGroup",servergroupId+"",sWebLanguage))+"<br />"+HTMLEntities.htmlentities(getTranNoLink("datacenterparameter", parameterId, sWebLanguage))+
                                          (request.getParameter("fullperiod")!=null?" <a href=\\\"javascript:simpleValueGraphForServerGroup('"+servergroupId+"','"+parameterId+"')\\\">("+ScreenHelper.getTranNoLink("web", "lastyear", sWebLanguage)+")</a>":" <a href=\\\"javascript:simpleValueGraphFullForServerGroup('"+servergroupId+"','"+parameterId+"')\\\">("+ScreenHelper.getTranNoLink("web", "fullperiod", sWebLanguage)+")</a>");
    }

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
    <div id="barchart" style="width: 620px; height: 305px; position: relative;"></div>
        <div style="float:left;height:30px;font-size:15px;text-align:center;width:100%;"><%=ScreenHelper.getTranNoLink("web", "time", sWebLanguage)%></div>
    </div>
</div>

<script>
  setGraph(<%=sJsArray%>);
  Modalbox.setTitle("<%=sTitle%>");
</script>