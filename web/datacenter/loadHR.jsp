<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.datacenter.DatacenterHelper,be.mxs.common.util.db.MedwanQuery,java.text.*" %>
<div style="float:left;">
    <table width='100%'>
    <%
        String serverid=request.getParameter("serverid");
        String period=request.getParameter("period");
		double totalhr=Double.parseDouble(DatacenterHelper.getTotalHRs(Integer.parseInt(serverid),period));
        out.println("<tr><td class='admin' colspan='2'><b>"+getTran("web","total.hr.for.period",sWebLanguage)+"</b></td><td class='admin'><b>"+new DecimalFormat("#").format(totalhr)+"</td></tr>");
        Vector hrs=DatacenterHelper.getHRs(Integer.parseInt(serverid),period);
        for(int n=0;n<hrs.size();n++){
            String hr=(String)hrs.elementAt(n);
            double pct = 0;
            try{
            	pct=Double.parseDouble(hr.split(";")[1])*100/totalhr;
            }
            catch(Exception e){
            	e.printStackTrace();
            }
            out.print("<tr><td class='admin' nowrap>"+getTran("usergroup",hr.split(";")[0],sWebLanguage)+"</td><td class='admin'>"+new DecimalFormat("#").format(Double.parseDouble(hr.split(";")[1]))+"</td><td class='admin2'>"+new DecimalFormat("#.0").format(pct)+"%</td></tr>");
        }
    %>
    </table>
</div>