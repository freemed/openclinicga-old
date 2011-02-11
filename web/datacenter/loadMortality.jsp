<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.openclinic.datacenter.DatacenterHelper,be.mxs.common.util.db.MedwanQuery" %>
<div style="float:left;">
    <table width='100%'>
    <%
        String serverid=request.getParameter("serverid");
        String period=request.getParameter("period");
        //First provide the total mortality rate for the period
        out.println("<tr><td class='admin' colspan='2'><b>"+getTran("web","total.mortality.for.period",sWebLanguage)+"</b></td><td class='admin'><b>"+DatacenterHelper.getTotalMortalities(Integer.parseInt(serverid),period)+"</td></tr>");
        //Then provide diagnosis-specific mortality rates
        Vector mortalities=DatacenterHelper.getMortalities(Integer.parseInt(serverid),period,"KPGS");
        for(int n=0;n<mortalities.size();n++){
            String diag=(String)mortalities.elementAt(n);
            double pct = 0;
            try{
            	pct=Double.parseDouble(diag.split(";")[1])*100/Double.parseDouble(diag.split(";")[2]);
            }
            catch(Exception e){
            	e.printStackTrace();
            }
            out.print("<tr><td class='admin' nowrap>"+diag.split(";")[0].toUpperCase()+"</td><td class='admin'>"+MedwanQuery.getInstance().getCodeTran("icd10code"+diag.split(";")[0],sWebLanguage)+"</td><td class='admin2'><a href='javascript:mortalityGraph(\""+diag.split(";")[0]+"\")'>"+diag.split(";")[1]+"/"+diag.split(";")[2]+" = "+new java.text.DecimalFormat("#.0").format(pct)+"%</a></td></tr>");
        }
    %>
    </table>
</div>