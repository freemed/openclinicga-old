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
        <td colspan="5"><b><%=getTran("healthnet","adt",sWebLanguage)%> <%=getTran("healthnet","today",sWebLanguage)%></b></td>
    </tr>
<%
    String sQuery = "select distinct hn_source from HealthNetIntegratedMessages where 1=1 "+where+" order by hn_source";
	Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    PreparedStatement ps = oc_conn.prepareStatement(sQuery);
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        String source=rs.getString("hn_source");
        out.println("<tr><td class='admin' colspan='3'>"+getTran("healthnet.site",source,sWebLanguage)+"</td></tr>");
        String sQuery2="select count(*) total from HealthNetEncounters where hn_source=? and hn_begin>?";
        PreparedStatement ps2 = oc_conn.prepareStatement(sQuery2);
        ps2.setString(1,source);
        ps2.setTimestamp(2,new Timestamp(new java.util.Date().getTime()-24*3600*1000));
        ResultSet rs2 = ps2.executeQuery();
        if(rs2.next()){
        	int hn_in=rs2.getInt("total");
        }
        rs2.close();
        ps2.close();
        sQuery2="select count(*) total from HealthNetEncounters where hn_source=? and hn_end>?";
        ps2 = oc_conn.prepareStatement(sQuery2);
        ps2.setString(1,source);
        ps2.setTimestamp(2,new Timestamp(new java.util.Date().getTime()-24*3600*1000));
        rs2 = ps2.executeQuery();
        if(rs2.next()){
        	int hn_out=rs2.getInt("total");
        }
        rs2.close();
        ps2.close();
        sQuery2="select count(*) total from HealthNetEncounters where hn_source=? and hn_begin<>hn_servicebegin and hn_servicebegin>?";
        ps2 = oc_conn.prepareStatement(sQuery2);
        ps2.setString(1,source);
        ps2.setTimestamp(2,new Timestamp(new java.util.Date().getTime()-24*3600*1000));
        rs2 = ps2.executeQuery();
        if(rs2.next()){
        	int hn_trans=rs2.getInt("total");
        }
        rs2.close();
        ps2.close();
        out.println("<tr><td>"+getTran("healthnet","in",sWebLanguage)+": "+hn_in+"</td><td>"+getTran("healthnet","out",sWebLanguage)+": "+hn_out+"</td><td>"+getTran("healthnet","transfert",sWebLanguage)+": "+hn_trans+"</td></tr>");
    }
    rs.close();
    ps.close();
%>
    <tr class="admin">
        <td colspan="5"><%=getTran("healthnet","adt",sWebLanguage)%> <%=getTran("healthnet","week",sWebLanguage)%></td>
    </tr>
<%
    sQuery = "select distinct hn_source from HealthNetIntegratedMessages where 1=1 "+where+" order by hn_source";
    ps = oc_conn.prepareStatement(sQuery);
    rs = ps.executeQuery();
    while (rs.next()) {
        String source=rs.getString("hn_source");
        out.println("<tr><td class='admin' colspan='3'>"+getTran("healthnet.site",source,sWebLanguage)+"</td></tr>");
        String sQuery2="select count(*) total from HealthNetEncounters where hn_source=? and hn_begin>?";
        PreparedStatement ps2 = oc_conn.prepareStatement(sQuery2);
        ps2.setString(1,source);
        ps2.setTimestamp(2,new Timestamp(new java.util.Date().getTime()-7*24*3600*1000));
        ResultSet rs2 = ps2.executeQuery();
        if(rs2.next()){
        	int hn_in=rs2.getInt("total");
        }
        rs2.close();
        ps2.close();
        sQuery2="select count(*) total from HealthNetEncounters where hn_source=? and hn_end>?";
        ps2 = oc_conn.prepareStatement(sQuery2);
        ps2.setString(1,source);
        ps2.setTimestamp(2,new Timestamp(new java.util.Date().getTime()-7*24*3600*1000));
        rs2 = ps2.executeQuery();
        if(rs2.next()){
        	int hn_out=rs2.getInt("total");
        }
        rs2.close();
        ps2.close();
        sQuery2="select count(*) total from HealthNetEncounters where hn_source=? and hn_begin<>hn_servicebegin and hn_servicebegin>?";
        ps2 = oc_conn.prepareStatement(sQuery2);
        ps2.setString(1,source);
        ps2.setTimestamp(2,new Timestamp(new java.util.Date().getTime()-7*24*3600*1000));
        rs2 = ps2.executeQuery();
        if(rs2.next()){
        	int hn_trans=rs2.getInt("total");
        }
        rs2.close();
        ps2.close();
        out.println("<tr><td>"+getTran("healthnet","in",sWebLanguage)+": "+hn_in+"</td><td>"+getTran("healthnet","out",sWebLanguage)+": "+hn_out+"</td><td>"+getTran("healthnet","transfert",sWebLanguage)+": "+hn_trans+"</td></tr>");
    }
    rs.close();
    ps.close();
%>
    <tr class="admin">
        <td colspan="5"><%=getTran("healthnet","adt",sWebLanguage)%> <%=getTran("healthnet","month",sWebLanguage)%></td>
    </tr>
<%
    sQuery = "select distinct hn_source from HealthNetIntegratedMessages where 1=1 "+where+" order by hn_source";
    ps = oc_conn.prepareStatement(sQuery);
    rs = ps.executeQuery();
    while (rs.next()) {
        String source=rs.getString("hn_source");
        out.println("<tr><td class='admin' colspan='3'>"+getTran("healthnet.site",source,sWebLanguage)+"</td></tr>");
        String sQuery2="select count(*) total from HealthNetEncounters where hn_source=? and hn_begin>?";
        PreparedStatement ps2 = oc_conn.prepareStatement(sQuery2);
        ps2.setString(1,source);
        long l=24*3600*1000;
        l=30*l;
        ps2.setTimestamp(2,new Timestamp(new java.util.Date().getTime()-l));
        ResultSet rs2 = ps2.executeQuery();
        if(rs2.next()){
        	int hn_in=rs2.getInt("total");
        }
        rs2.close();
        ps2.close();
        sQuery2="select count(*) total from HealthNetEncounters where hn_source=? and hn_end>?";
        ps2 = oc_conn.prepareStatement(sQuery2);
        ps2.setString(1,source);
        ps2.setTimestamp(2,new Timestamp(new java.util.Date().getTime()-l));
        rs2 = ps2.executeQuery();
        if(rs2.next()){
        	int hn_out=rs2.getInt("total");
        }
        rs2.close();
        ps2.close();
        sQuery2="select count(*) total from HealthNetEncounters where hn_source=? and hn_begin<>hn_servicebegin and hn_servicebegin>?";
        ps2 = oc_conn.prepareStatement(sQuery2);
        ps2.setString(1,source);
        ps2.setTimestamp(2,new Timestamp(new java.util.Date().getTime()-l));
        rs2 = ps2.executeQuery();
        if(rs2.next()){
        	int hn_trans=rs2.getInt("total");
        }
        rs2.close();
        ps2.close();
        out.println("<tr><td>"+getTran("healthnet","in",sWebLanguage)+": "+hn_in+"</td><td>"+getTran("healthnet","out",sWebLanguage)+": "+hn_out+"</td><td>"+getTran("healthnet","transfert",sWebLanguage)+": "+hn_trans+"</td></tr>");
    }
    rs.close();
    ps.close();
    oc_conn.close();
%>
</table>