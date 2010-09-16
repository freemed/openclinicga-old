<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String src=checkString(request.getParameter("source"));
    String where="";
    if(src.length()>0){
        where=" and hn_source='"+src+"' ";
    }

%>
<table width="100%">
    <tr class="admin">
        <td colspan="5"><%=getTran("healthnet","bedutilization",sWebLanguage)%></td>
    </tr>
    <%
        String sQuery = "select hn_beds,hn_id,hn_source,hn_label" + sWebLanguage.toLowerCase() + " as label from HealthNetServices where 1=1 "+where+" order by hn_source,hn_id";
	    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
        ResultSet rs = ps.executeQuery();
        String activeSource = "";
        while (rs.next()) {
            String source = rs.getString("hn_source");
            String service = rs.getString("hn_id");
            if (!activeSource.equalsIgnoreCase(source)) {
                activeSource = source;
                String sQuery2 = "select sum(hn_beds) total from HealthNetServices where hn_source=?";
                PreparedStatement ps2 = oc_conn.prepareStatement(sQuery2);
                ps2.setString(1, source);
                ResultSet rs2 = ps2.executeQuery();
                int total=0;
                if(rs2.next()){
                	total=rs2.getInt("total");
                }
                rs2.close();
                ps2.close();
                sQuery2 = "select count(*) total from HealthNetEncounters where hn_source=? and hn_end is null";
                ps2 = oc_conn.prepareStatement(sQuery2);
                ps2.setString(1, source);
                rs2 = ps2.executeQuery();
                int occupied=0;
                if(rs2.next()){
                	 occupied=rs2.getInt("total");
                }
                rs2.close();
                ps2.close();
                sQuery2 = "select max(receivedDateTime) as maxdate from HealthNetIntegratedMessages where hn_source=?";
                ps2 = oc_conn.prepareStatement(sQuery2);
                ps2.setString(1, source);
                rs2 = ps2.executeQuery();
            	Timestamp maxDate=null;
                if(rs2.next()){
                    try{
                        maxDate=rs2.getTimestamp("maxdate");
                    }
                    catch(Exception e){}
                }
                rs2.close();
                ps2.close();
                out.println("<tr><td class='admin' colspan='2'>" + getTran("healthnet.site", source, sWebLanguage) + (maxDate!=null?" ("+new SimpleDateFormat("dd/MM/yyyy HH:mm").format(maxDate)+")":"")+ "</td><td class='admin'>" + getTran("web", "total", sWebLanguage) +"<br/>"+total+ "</td><td class='admin'>" + getTran("web", "occupied", sWebLanguage) + "<br/>"+occupied + (total>0?" (" + occupied*100/total+"%)":"")+ "</td><td class='admin'>" + getTran("web", "available", sWebLanguage) +"<br/>"+(occupied>=total?"0":"<b>"+(total-occupied)+"</b>") + (total>0?" (" + (occupied>total?0:total-occupied)*100/total+"%)":"")+ "</td></tr>");
            }
            String sQuery2 = "select count(*) total from HealthNetEncounters where hn_source=? and hn_serviceid=? and hn_end is null";
            PreparedStatement ps2 = oc_conn.prepareStatement(sQuery2);
            ps2.setString(1, source);
            ps2.setString(2, service);
            ResultSet rs2 = ps2.executeQuery();
            int total=0,occupied=0;
            if(rs2.next()){
	            total = rs.getInt("hn_beds");
	            occupied = rs2.getInt("total");
            }
            out.println("<tr><td>" + service + "</td><td><b>" + rs.getString("label") + "</b></td><td>" + total + "</td><td>" + occupied + (total>0?" (" + occupied*100/total+"%)":"")+"</td><td>" + (occupied>=total?"0":"<b>"+(total-occupied)+"</b>") + (total>0?" (" + (occupied>total?0:total-occupied)*100/total+"%)":"")+"</td></tr>");
            rs2.close();
            ps2.close();
        }
        rs.close();
        ps.close();
        oc_conn.close();

    %>
</table>