<%@ page import="java.util.Hashtable,java.util.Enumeration,java.text.DecimalFormat" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics.episodesperdepartment","select",activeUser)%>
<%
    String todate=request.getParameter("todate");
    String fromdate=request.getParameter("fromdate");
    if(todate==null){
        todate=ScreenHelper.stdDateFormat.format(new java.util.Date());
    }
    if(fromdate==null){
        fromdate="01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
%>
<form name="diagstats" id="diagstats" method="post">
    <%=writeTableHeader("Web","statistics.serviceepisodes",sWebLanguage," doBack();")%>
    <table width="100%" class="menu" cellspacing="0" cellpadding="0">
        <tr>
            <td>
                <%=getTran("web","from",sWebLanguage)%>&nbsp;
                <%=writeDateField("fromdate","diagstats",fromdate,sWebLanguage)%>&nbsp;
                <%=getTran("web","to",sWebLanguage)%>&nbsp;
                <%=writeDateField("todate","diagstats",todate,sWebLanguage)%>&nbsp;
                <input type="submit" class="button" name="calculate" value="<%=getTran("web","calculate",sWebLanguage)%>"/>
                <input type="button" class="button" name="backButton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
    </table>
</form>
<table class='list' cellspacing="1" cellpadding="0">
<%
    if (request.getParameter("calculate") != null) {
        String sQuery = "select a.totalbeds,count(distinct OC_ENCOUNTER_OBJECTID) total,sum(abs("+MedwanQuery.getInstance().datediff("d","begindate","enddate")+"+1)) duration,OC_ENCOUNTER_SERVICEUID,OC_ENCOUNTER_TYPE from " +
                " (select OC_ENCOUNTER_OBJECTID," +
                "   OC_ENCOUNTER_SERVICEUID," +
                "   OC_ENCOUNTER_TYPE," +
                "   OC_ENCOUNTER_BEGINDATE," +
                "   OC_ENCOUNTER_ENDDATE," +
                "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                "  from OC_ENCOUNTERS_VIEW" +
                " ) b,ServicesAddressView a where " +
                " a.serviceid=b.OC_ENCOUNTER_SERVICEUID and" +
                " b.OC_ENCOUNTER_BEGINDATE<=? and " +
                " b.OC_ENCOUNTER_ENDDATE>=?" +
                " group by OC_ENCOUNTER_SERVICEUID,OC_ENCOUNTER_TYPE,a.totalbeds" +
                " order by OC_ENCOUNTER_SERVICEUID,OC_ENCOUNTER_TYPE,a.totalbeds";
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
        ps.setDate(1, new java.sql.Date(ScreenHelper.parseDate(fromdate).getTime()));
        ps.setDate(2, new java.sql.Date(ScreenHelper.parseDate(fromdate).getTime()));
        ps.setDate(3, new java.sql.Date(ScreenHelper.parseDate(todate).getTime()));
        ps.setDate(4, new java.sql.Date(ScreenHelper.parseDate(todate).getTime()));
        ps.setDate(5, new java.sql.Date(ScreenHelper.parseDate(todate).getTime()));
        ps.setDate(6, new java.sql.Date(ScreenHelper.parseDate(fromdate).getTime()));
        ResultSet rs = ps.executeQuery();
        String activeService = "";
        Hashtable totals = new Hashtable();
        Hashtable durations = new Hashtable();
        int hosptotalbeds=0;
        long totalduration=ScreenHelper.parseDate(todate).getTime()-ScreenHelper.parseDate(fromdate).getTime();
        totalduration=totalduration/(60000*60*24);


        while (rs.next()) {
            String service = rs.getString("OC_ENCOUNTER_SERVICEUID");
            if (!activeService.equalsIgnoreCase(service)) {
                activeService = service;
                out.print("<tr class='gray'><td colspan='10'>");
                String label="";
                for(int n=0;n<service.split("\\.").length;n++){
                    if(n>0){
                        label+=".";
                        out.print(" &gt; ");
                    }
                    label+=service.split("\\.")[n];
                    out.print("<a href='javascript:fullstats(\""+label+"\");'><b>"+getTran("service", label, sWebLanguage) + "</b></a>");
                }
                out.print("</td></tr>");
                out.print("<tr><td/><td class='admin2'>" + getTran("web", "type", sWebLanguage) + "</td>" +
                        "<td class='admin2'>#</td>" +
                        "<td class='admin2'>" + getTran("web", "days", sWebLanguage) + "</td>" +
                        "<td class='admin2'>" + getTran("web", "daysperepisode", sWebLanguage) + "</td>" +
                        "<td class='admin2'>" + getTran("web", "bedoccupancy", sWebLanguage) + "</td>" +
                        "</tr>");
            }
            String type = rs.getString("OC_ENCOUNTER_TYPE");
            double total = rs.getInt("total");
            double duration = rs.getInt("duration");
            int totalbeds=rs.getInt("totalbeds");
            hosptotalbeds+=totalbeds;
            out.print("<tr><td width='20%'/><td class='admin2'><b>" + getTran("web", type, sWebLanguage) + "</b></td>" +
                    "<td class='admin2'><b>" + total + "</b></td>" +
                    (type.equalsIgnoreCase("visit")?"<td colspan='3'/>":"<td class='admin2'><b>" + duration + "</b></td>" +
                    "<td class='admin2'><b>" + new DecimalFormat("##.#").format(duration / total) + "</b></td>" +
                    "<td class='admin2'><b>" + (totalbeds>0?new DecimalFormat("##.#").format(duration *100/ (totalduration*totalbeds))+"% ("+totalbeds+" "+getTran("web","beds",sWebLanguage)+")":"") + "</b></td>") +
                    "</tr>");
            totals.put(type, "1");

        }
        out.print("<tr><td colspan='10' class='admin'>" + getTran("web", "total", sWebLanguage) + "</td></tr>");
        out.print("<tr><td/><td class='admin2'>" + getTran("web", "type", sWebLanguage) + "</td>" +
                "<td class='admin2'>#</td>" +
                "<td class='admin2'>" + getTran("web", "days", sWebLanguage) + "</td>" +
                "<td class='admin2'>" + getTran("web", "daysperepisode", sWebLanguage) + "</td>" +
                "<td class='admin2'>" + getTran("web", "bedoccupancy", sWebLanguage) + "</td>" +
                "</tr>");
        Enumeration types = totals.keys();
        while (types.hasMoreElements()) {
            String key = (String) types.nextElement();
            sQuery = "select count(distinct OC_ENCOUNTER_OBJECTID) total,sum(abs("+MedwanQuery.getInstance().datediff("d","begindate","enddate")+"+1)) duration from " +
                    " (select OC_ENCOUNTER_OBJECTID," +
                    "   OC_ENCOUNTER_SERVICEUID," +
                    "   OC_ENCOUNTER_TYPE," +
                    "   OC_ENCOUNTER_BEGINDATE," +
                    "   OC_ENCOUNTER_ENDDATE," +
                    "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_BEGINDATE>?","OC_ENCOUNTER_BEGINDATE","?")+" begindate," +
                    "   "+MedwanQuery.getInstance().iif("OC_ENCOUNTER_ENDDATE<?","OC_ENCOUNTER_ENDDATE","?")+" enddate " +
                    "  from OC_ENCOUNTERS_VIEW" +
                    " ) b where " +
                    " b.OC_ENCOUNTER_BEGINDATE<=? and " +
                    " b.OC_ENCOUNTER_ENDDATE>=? and" +
                    " OC_ENCOUNTER_TYPE=?";
            ps = oc_conn.prepareStatement(sQuery);
            ps.setDate(1, new java.sql.Date(ScreenHelper.parseDate(fromdate).getTime()));
            ps.setDate(2, new java.sql.Date(ScreenHelper.parseDate(fromdate).getTime()));
            ps.setDate(3, new java.sql.Date(ScreenHelper.parseDate(todate).getTime()));
            ps.setDate(4, new java.sql.Date(ScreenHelper.parseDate(todate).getTime()));
            ps.setDate(5, new java.sql.Date(ScreenHelper.parseDate(todate).getTime()));
            ps.setDate(6, new java.sql.Date(ScreenHelper.parseDate(fromdate).getTime()));
            ps.setString(7,key);
            rs = ps.executeQuery();
            if(rs.next()){
                double total = rs.getInt("total");
                double duration = rs.getInt("duration");
                out.print("<tr><td width='20%'/><td class='admin2'><b>" + getTran("web", key, sWebLanguage) + "<b></td>" +
                        "<td class='admin2'><b>" + total + "</b></td>" +
                        (key.equalsIgnoreCase("visit")?"<td colspan='3'":"<td class='admin2'><b>" + duration + "</b></td>" +
                        "<td class='admin2'><b>" + new DecimalFormat("##.#").format(duration / total) + "</b></td>" +
                        "<td class='admin2'><b>" + (hosptotalbeds>0?new DecimalFormat("##.#").format(duration *100/ (totalduration*hosptotalbeds))+"% ("+hosptotalbeds+" "+getTran("web","beds",sWebLanguage)+")":"") + "</b></td>") +
                        "</tr>");
            }
            rs.close();
            ps.close();
        }
        rs.close();
        ps.close();
        oc_conn.close();
    }
%>
</table>
<script>
    function fullstats(servicecode){
        window.open("<c:url value='/popup.jsp'/>?Page=statistics/diagnosisStats.jsp&ts=<%=getTs()%>&Action=SEARCH&fromdate=<%=fromdate%>&todate=<%=todate%>&codetype=icpc&calculate=true&ServiceID="+servicecode,"Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no").moveTo((screen.width-800)/2,(screen.height-600)/2);
    }
    function doBack(){
        window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
    }
</script>