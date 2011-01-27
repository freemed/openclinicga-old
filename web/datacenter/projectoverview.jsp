<%@page import="be.openclinic.datacenter.DatacenterHelper" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width="100%">
<tr>
	<td><img height="150px" src="<c:url value="/_img/ghb.png"/>"/></td>
<%
	if(session.getAttribute("datacenteruser")!=null){
%>
	<td align="right"><img src="<%=MedwanQuery.getInstance().getConfigString("datacenterUserLogo."+session.getAttribute("datacenteruser"))%>"/></td>
<%
	}
%>
</tr>
</table>
<table width="100%">
<%!
	public String registerSimpleValue(String server, String parameterId, Hashtable parameters){
		String sVal=DatacenterHelper.getLastSimpleValue(Integer.parseInt(server),parameterId);
		int iVal;
		if(!sVal.equalsIgnoreCase("?")){
			if(parameters.get(parameterId)==null){
				parameters.put(parameterId,new Integer(0));
			}
			try{
				iVal=Integer.parseInt(sVal);
				parameters.put(parameterId,new Integer(((Integer)parameters.get(parameterId)).intValue()+iVal));
			}
			catch (Exception e){
				e.printStackTrace();
			}
			return "<a href='javascript:simpleValueGraph(\""+server+"\",\""+parameterId+"\")'>"+sVal+"</a>";
		}
		return sVal;
	}
%>
<%	
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="select * from DC_SERVERGROUPS order by DC_SERVERGROUP_ID,DC_SERVERGROUP_SERVERID";
	if(request.getParameter("servergroups")!=null && request.getParameter("servergroups").length()>0){
		sQuery="select * from DC_SERVERGROUPS where DC_SERVERGROUP_ID in ("+request.getParameter("servergroups")+") order by DC_SERVERGROUP_ID,DC_SERVERGROUP_SERVERID";
	}
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ResultSet rs = ps.executeQuery();
	String activeGroup="";
	String group,server,sVal;
	Hashtable parameters = new Hashtable();
	String colspan="9";
	int counter=0;
	while(rs.next()){
		counter++;
		group=rs.getString("DC_SERVERGROUP_ID");
		server=rs.getString("DC_SERVERGROUP_SERVERID");
		String sEdit="";
		if(session.getAttribute("datacenteruser")!=null && ((String)session.getAttribute("datacenteruser")).toLowerCase().equalsIgnoreCase("mxs")){
			sEdit="<a href='javascript:openmanualdataentry("+server+");'><img class='link' src='../_img/icon_edit.gif' /></a> ";
		}
		if(!activeGroup.equalsIgnoreCase(group)){
			if(activeGroup.length()>0){
				//Show totals for the group
				out.print("<tr><td/><td/>");
				out.print("<td class='admin'>"+parameters.get("core.1")+"</td>");
				out.print("<td class='admin'>"+parameters.get("core.2")+"</td>");
				out.print("<td class='admin'>"+parameters.get("core.4.1")+"</td>");
				out.print("<td class='admin'>"+parameters.get("core.4.2")+"</td>");
				out.print("<td class='admin'>"+parameters.get("core.6")+"</td>");
				out.print("<td class='admin'>"+parameters.get("core.8.1")+"</td>");
				out.print("<td class='admin'>"+parameters.get("core.5")+"</td>");
				out.print("</tr>");
				out.println("<tr><td colspan='"+colspan+"' class='admin2'><hr/></td></tr>");
				parameters = new Hashtable();
			}
			out.print("<tr><td class='admin'>"+getTran("datacenterservergroup",group,sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","lastupdate",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","patients",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","users",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","admissions",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","consultations",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","transactions",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","diagnoses",sWebLanguage)+"</td>"
					+"<td class='admin'>"+getTran("web","debets",sWebLanguage)+"</td>"
					+"</tr>");
			activeGroup=group;
			counter=1;
		}
		out.print("<tr><td class='admin2'>"+sEdit+"<a href='javascript:openserverdetail("+server+")'>"+counter+". "+getTran("datacenterserver",server,sWebLanguage)+" ("+server+")</a></td>");
		java.util.Date lastdate=DatacenterHelper.getLastDate(Integer.parseInt(server));
		String color="color='green'";
		if(lastdate!=null && new java.util.Date().getTime()-lastdate.getTime()>MedwanQuery.getInstance().getConfigInt("datacenterServerInactiveDaysRedAlert",7)*24*3600000){
			color="color='red'";
		}
		else if(lastdate!=null && new java.util.Date().getTime()-lastdate.getTime()>MedwanQuery.getInstance().getConfigInt("datacenterServerInactiveDaysOrangeAlert",2)*24*3600000){
			color="color='orange'";
		}
		out.print("<td class='admin2'>"+(lastdate==null?"":"<font "+color+">"+new SimpleDateFormat("dd/MM/yyyy HH:mm").format(lastdate))+"</font></td>");
		out.print("<td class='admin2'>"+registerSimpleValue(server,"core.1",parameters)+"</td>");
		out.print("<td class='admin2'>"+registerSimpleValue(server,"core.2",parameters)+"</td>");
		out.print("<td class='admin2'>"+registerSimpleValue(server,"core.4.1",parameters)+"</td>");
		out.print("<td class='admin2'>"+registerSimpleValue(server,"core.4.2",parameters)+"</td>");
		out.print("<td class='admin2'>"+registerSimpleValue(server,"core.6",parameters)+"</td>");
		out.print("<td class='admin2'>"+registerSimpleValue(server,"core.8.1",parameters)+"</td>");
		out.print("<td class='admin2'>"+registerSimpleValue(server,"core.5",parameters)+"</td>");
		out.print("</tr>");
	}
	if(activeGroup.length()>0){
		//Show totals for the group
		out.print("<tr><td/><td/>");
		out.print("<td class='admin'><b>"+parameters.get("core.1")+"</b></td>");
		out.print("<td class='admin'>"+parameters.get("core.2")+"</td>");
		out.print("<td class='admin'>"+parameters.get("core.4.1")+"</td>");
		out.print("<td class='admin'>"+parameters.get("core.4.2")+"</td>");
		out.print("<td class='admin'>"+parameters.get("core.6")+"</td>");
		out.print("<td class='admin'>"+parameters.get("core.8.1")+"</td>");
		out.print("<td class='admin'>"+parameters.get("core.5")+"</td>");
		out.print("</tr>");
	}
	rs.close();
	ps.close();
	conn.close();
%>
</table>

<script>

	function openmanualdataentry(serverid){
		openPopupWindow("/datacenter/manualDataEntry.jsp?ts=<%=getTs()%>&serverid="+serverid,800,600,"OpenClinic Datacenter");
	}
	function openserverdetail(serverid){
		openPopupWindow("/datacenter/serverOverview.jsp?ts=<%=getTs()%>&serverid="+serverid,800,600,"OpenClinic Datacenter");
	}
    function simpleValueGraph(serverid,parameterid){
        openPopupWindow("/datacenter/simpleValueGraph.jsp&serverid="+serverid+"&parameterid="+parameterid+"&ts=<%=getTs()%>");
    }
    <%-- OPEN POPUP --%>
    function openPopupWindow(page, width, height, title) {
        var url = "<c:url value="/popup.jsp"/>?Page=" + page;
        if (width != undefined) url += "&PopupWidth=" + width;
        if (height != undefined) url += "&PopupHeight=" + height;
        if (title == undefined) {
            if (page.indexOf("&") < 0) {
                title = page.replace("/", "_");
                title = replaceAll(title, ".", "_");
            }
            else {
                title = replaceAll(page.substring(1, page.indexOf("&")), "/", "_");
                title = replaceAll(title, ".", "_");
            }
        }
        var w = window.open(url, title, "toolbar=no, status=yes, scrollbars=yes, resizable=yes, width=1, height=1, menubar=no");
        w.moveBy(2000, 2000);
    }
    function replaceAll(s, s1, s2) {
        while (s.indexOf(s1) > -1) {
            s = s.replace(s1, s2);
        }
        return s;
    }

	
</script>