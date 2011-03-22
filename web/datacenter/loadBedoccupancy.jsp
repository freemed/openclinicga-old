<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.datacenter.DatacenterHelper,be.mxs.common.util.db.MedwanQuery" %>
<%!
    public String getBar(double d){
        String sReturn = "";
        String[] sColors = new String[]{"5be25a","7be755","b8f04a","f3f93c","fffc15","fee604","fdcd0b","fb8622","fa6d2b","f83d3c"};
        for (int i=0;i<10;i++){
            sReturn+="<td";
            if(Math.ceil(d)>=i*10){
                sReturn+=" color='#"+sColors[i]+"' style='background-color:#"+sColors[i]+"'";
            }
            sReturn+=">&nbsp;</td>";
        }
        return sReturn+"";
    }
%>
<table width='100%'>
<%
	try{
		String serverid=request.getParameter("serverid");
		java.util.Vector services = DatacenterHelper.getBedoccupancy(Integer.parseInt(serverid));
		for(int n=0;n<services.size();n++){
			String diag=(String)services.elementAt(n);
            double val = Double.parseDouble((diag.split(";")[3]).replaceAll(",","."));
			out.print("<tr><td class='admin'>"+diag.split(";")[0].toUpperCase()+"</td><td class='admin'>"+diag.split(";")[1].toUpperCase()+"</td><td class='admin2'><a href='javascript:occupancyGraph(\""+diag+"\")'>"+diag.split(";")[2]+" ("+diag.split(";")[3]+"%)"+"</a></td><td>"+getBar(val)+"</td></tr>");
		}
	}
	catch(Exception e){
		e.printStackTrace();
	}
%>
</table>