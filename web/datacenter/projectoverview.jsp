<%@page import="be.openclinic.datacenter.DatacenterHelper" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>


<%!
	public String registerSimpleValue(String server, String parameterId, Hashtable parameters,Hashtable lastvalues){
		String sVal=DatacenterHelper.getLastSimpleValue(Integer.parseInt(server),parameterId,lastvalues);
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
            //return "<a href='"+sCONTEXTPATH+"/datacenter/datacenterHome.jsp?p=/datacenter/simpleValueGraph.jsp&serverid="+server+"&parameterid="+parameterId+"&ts="+getTs()+"'>"+sVal+"</a>";
            if(sVal!=null){
            	sVal=new java.text.DecimalFormat("#,###").format(Integer.parseInt(sVal));
            }
			return "<a href='javascript:simpleValueGraph(\""+server+"\",\""+parameterId+"\")'>"+sVal+"</a>";
		}
		return sVal;
	}
    public String serverDetail(String server, String sVal){
        return "<a href='"+sCONTEXTPATH+"/datacenter/datacenterHome.jsp?p=/datacenter/serverOverview.jsp&serverid="+server+"&ts="+getTs()+"'>"+sVal+"</a>";
    }
    public String manualDataEntry(String server){
        return "<a href='"+sCONTEXTPATH+"/datacenter/datacenterHome.jsp?p=/datacenter/manualDataEntry.jsp&serverid="+server+"&ts="+getTs()+"' class='link'><span class='icon edit'>&nbsp;</span></a>";
    }
%>
<%
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	//boolean showcontent=checkString(request.getParameter("servergroups")).split(",").length<=1;
	boolean showcontent=true;
	Hashtable lastvalues=DatacenterHelper.getLastSimpleValues();
	DatacenterHelper.setLastvalues(lastvalues);
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
			sEdit=manualDataEntry(server);
		}

        if(!activeGroup.equalsIgnoreCase(group)){
			if(activeGroup.length()>0){
				//Show totals for the group
				out.print("<tr class='result'><td><td/>");
				out.print("<td class='admin'>"+(parameters.get("core.1")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.1")))+"</td>");
				out.print("<td class='admin'>"+(parameters.get("core.2")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.2")))+"</td>");
				out.print("<td class='admin'>"+(parameters.get("core.4.1")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.4.1")))+"</td>");
				out.print("<td class='admin'>"+(parameters.get("core.4.2")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.4.2")))+"</td>");
				out.print("<td class='admin'>"+(parameters.get("core.6")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.6")))+"</td>");
				out.print("<td class='admin'>"+(parameters.get("core.8.1")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.8.1")))+"</td>");
				out.print("<td class='admin'>"+(parameters.get("core.5")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.5")))+"</td>");
				out.print("</tr>");
			
				parameters = new Hashtable();
			}
            if(counter>1){
                out.write("</table></div></div>");
            }
            out.print("<div class='landlist'><h3>"+getTranNoLink("datacenterservergroup",group,sWebLanguage)+"</h3><div class='subcontent'><table width=\"100%\" class=\"content\" cellpadding=\"0\" cellspacing=\"0\"><tr class='header'>"
					+"<td class='admin'>&nbsp;</td>"
					+"<td class='admin header'>"+getTranNoLink("web","lastupdate",sWebLanguage)+"</td>"
					+"<td class='admin header'>"+getTranNoLink("web","patients",sWebLanguage)+"</td>"
					+"<td class='admin header'>"+getTranNoLink("web","users",sWebLanguage)+"</td>"
					+"<td class='admin header'>"+getTranNoLink("web","admissions",sWebLanguage)+"</td>"
					+"<td class='admin header'>"+getTranNoLink("web","consultations",sWebLanguage)+"</td>"
					+"<td class='admin header'>"+getTranNoLink("web","transactions",sWebLanguage)+"</td>"
					+"<td class='admin header'>"+getTranNoLink("web","diagnoses",sWebLanguage)+"</td>"
					+"<td class='admin header'>"+getTranNoLink("web","debets",sWebLanguage)+"</td>"
					+"</tr>");
			activeGroup=group;
			counter=1;
		}
        if(showcontent){
			out.print("<tr><td class='admin2' width='30%'>"+sEdit+serverDetail(server,counter+". "+getTranNoLink("datacenterserver",server,sWebLanguage)+" ("+server+")"+""));
			java.util.Date lastdate=DatacenterHelper.getLastDate(Integer.parseInt(server));
			String color="color='green'";
			if(lastdate!=null && new java.util.Date().getTime()-lastdate.getTime()>MedwanQuery.getInstance().getConfigInt("datacenterServerInactiveDaysRedAlert",7)*24*3600000){
				color="color='red'";
			}
			else if(lastdate!=null && new java.util.Date().getTime()-lastdate.getTime()>MedwanQuery.getInstance().getConfigInt("datacenterServerInactiveDaysOrangeAlert",2)*24*3600000){
				color="color='orange'";
			}
			out.print("<td class='admin2' width='150'>"+((lastdate==null?"&nbsp;":"<font "+color+">"+new SimpleDateFormat("dd/MM/yyyy HH:mm").format(lastdate))+"</font>")+"</td>");
			out.print("<td class='admin2' width=''>"+registerSimpleValue(server,"core.1",parameters,lastvalues)+"</td>");
			out.print("<td class='admin2' width=''>"+registerSimpleValue(server,"core.2",parameters,lastvalues)+"</td>");
			out.print("<td class='admin2' width=''>"+registerSimpleValue(server,"core.4.1",parameters,lastvalues)+"</td>");
			out.print("<td class='admin2' width=''>"+registerSimpleValue(server,"core.4.2",parameters,lastvalues)+"</td>");
			out.print("<td class='admin2' width=''>"+registerSimpleValue(server,"core.6",parameters,lastvalues)+"</td>");
			out.print("<td class='admin2' width=''>"+registerSimpleValue(server,"core.8.1",parameters,lastvalues)+"</td>");
			out.print("<td class='admin2 last' width=''>"+registerSimpleValue(server,"core.5",parameters,lastvalues)+"</td>");
			out.print("</tr>");
        }

	}
	if(activeGroup.length()>0){
		//Show totals for the group
        out.print("<tr class='result'><td/><td/>");
		out.print("<td class='admin'>"+(parameters.get("core.1")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.1")))+"</td>");
		out.print("<td class='admin'>"+(parameters.get("core.2")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.2")))+"</td>");
		out.print("<td class='admin'>"+(parameters.get("core.4.1")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.4.1")))+"</td>");
		out.print("<td class='admin'>"+(parameters.get("core.4.2")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.4.2")))+"</td>");
		out.print("<td class='admin'>"+(parameters.get("core.6")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.6")))+"</td>");
		out.print("<td class='admin'>"+(parameters.get("core.8.1")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.8.1")))+"</td>");
		out.print("<td class='admin'>"+(parameters.get("core.5")==null?"?":new java.text.DecimalFormat("#,###").format(parameters.get("core.5")))+"</td>");
		out.print("</tr>");

    }
    out.write("</table></div></div>");
    rs.close();
	ps.close();
	conn.close();
%>

<script>
	function openserverdetail(serverid){
		openPopupWindow("/datacenter/serverOverview.jsp?ts=<%=getTs()%>&serverid="+serverid,800,600,"OpenClinic Datacenter");
	}
    function simpleValueGraph(serverid,parameterid){
        openPopupWindow("/datacenter/simpleValueGraph.jsp?serverid="+serverid+"&parameterid="+parameterid+"&ts=<%=getTs()%>");
    }

   
</script>