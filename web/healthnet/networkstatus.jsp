<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<table width="100%">
    <tr class="admin">
        <td colspan="2"><%=getTran("healthnet","networkstatus",sWebLanguage)%></td>
    </tr>
    <tr>
        <td  style="vertical-align:top;" class="list" width="1%" nowrap><b><%=getTran("healthnet","todayactivity",sWebLanguage)%></b></td>
        <td>
            <table width="100%">
                <tr>
                    <td class="titleadmin" width="1%" nowrap><%=getTran("healthnet","received messages",sWebLanguage)%>:</td>
                    <td class="titleadmin">
                    <%
                        String sQuery="select count(*) total from HealthNetIntegratedMessages where receivedDateTime>=?";
                        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
                        ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()-24*3600*1000));
                        ResultSet rs = ps.executeQuery();
                        if(rs.next()){
                            out.println(rs.getInt("total"));
                        }
                        rs.close();
                        ps.close();
                    %>
                    </td>
                </tr>
                <tr>
                    <td class="titleadmin" width="1%" nowrap><%=getTran("healthnet","received.messages.per.type",sWebLanguage)%>:</td>
                    <td class="titleadmin">
                    <%
                        sQuery="select count(*) total,type from HealthNetIntegratedMessages where receivedDateTime>=? group by type order by count(*) desc";
                        ps = oc_conn.prepareStatement(sQuery);
                        ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()-24*3600*1000));
                        rs = ps.executeQuery();
                        while(rs.next()){
                            String type=rs.getString("type");
                            out.println((type==null?"?":getTran("messagetype",type,sWebLanguage))+" = "+rs.getInt("total")+"<br/>");
                        }
                        rs.close();
                        ps.close();
                    %>
                    </td>
                </tr>
                <tr>
                    <td class="titleadmin" width="1%" nowrap><%=getTran("healthnet","active sites",sWebLanguage)%>:</td>
                    <td class="titleadmin">
                        <%
                            sQuery="select count(*) total,hn_source from HealthNetIntegratedMessages where receivedDateTime>=? group by hn_source order by count(*) desc";
                            ps = oc_conn.prepareStatement(sQuery);
                            ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()-24*3600*1000));
                            rs = ps.executeQuery();
                            while(rs.next()){
                                out.println(getTran("healthnet.site",rs.getString("hn_source"),sWebLanguage)+" = "+rs.getInt("total")+"<br/>");
                            }
                            rs.close();
                            ps.close();
                        %>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td  style="vertical-align:top;" class="list" width="1%" nowrap><b><%=getTran("healthnet","weekactivity",sWebLanguage)%></b></td>
        <td>
            <table width="100%">
                <tr>
                    <td class="titleadmin" width="1%" nowrap><%=getTran("healthnet","received messages",sWebLanguage)%>:</td>
                    <td class="titleadmin">
                    <%
                        sQuery="select count(*) total from HealthNetIntegratedMessages where receivedDateTime>=?";
                        ps = oc_conn.prepareStatement(sQuery);
                        ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()-7*24*3600*1000));
                        rs = ps.executeQuery();
                        if(rs.next()){
                            out.println(rs.getInt("total"));
                        }
                        rs.close();
                        ps.close();
                    %>
                    </td>
                </tr>
                <tr>
                    <td class="titleadmin" width="1%" nowrap><%=getTran("healthnet","received.messages.per.type",sWebLanguage)%>:</td>
                    <td class="titleadmin">
                    <%
                        sQuery="select count(*) total,type from HealthNetIntegratedMessages where receivedDateTime>=? group by type order by count(*) desc";
                        ps = oc_conn.prepareStatement(sQuery);
                        ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()-7*24*3600*1000));
                        rs = ps.executeQuery();
                        while(rs.next()){
                            String type=rs.getString("type");
                            out.println((type==null?"?":getTran("messagetype",type,sWebLanguage))+" = "+rs.getInt("total")+"<br/>");
                        }
                        rs.close();
                        ps.close();
                    %>
                    </td>
                </tr>
                <tr>
                    <td class="titleadmin" width="1%" nowrap><%=getTran("healthnet","active sites",sWebLanguage)%>:</td>
                    <td class="titleadmin">
                        <%
                            sQuery="select count(*) total,hn_source from HealthNetIntegratedMessages where receivedDateTime>=? group by hn_source order by count(*) desc";
                            ps = oc_conn.prepareStatement(sQuery);
                            ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()-24*3600*1000));
                            rs = ps.executeQuery();
                            while(rs.next()){
                                out.println(getTran("healthnet.site",rs.getString("hn_source"),sWebLanguage)+" = "+rs.getInt("total")+"<br/>");
                            }
                            rs.close();
                            ps.close();
                        %>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
    <tr>
        <td  style="vertical-align:top;" class="list" width="1%" nowrap><b><%=getTran("healthnet","monthactivity",sWebLanguage)%></b></td>
        <td>
            <table width="100%">
                <tr>
                    <td class="titleadmin" width="1%" nowrap><%=getTran("healthnet","received messages",sWebLanguage)%>:</td>
                    <td class="titleadmin">
                    <%
                        sQuery="select count(*) total from HealthNetIntegratedMessages where receivedDateTime>=?";
                        ps = oc_conn.prepareStatement(sQuery);
                        long l=30*24*3600;
                        l=l*1000;
                        ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()-l));
                        rs = ps.executeQuery();
                        if(rs.next()){
                            out.println(rs.getInt("total"));
                        }
                        rs.close();
                        ps.close();
                    %>
                    </td>
                </tr>
                <tr>
                    <td class="titleadmin" width="1%" nowrap><%=getTran("healthnet","received.messages.per.type",sWebLanguage)%>:</td>
                    <td class="titleadmin">
                    <%
                        sQuery="select count(*) total,type from HealthNetIntegratedMessages where receivedDateTime>=? group by type order by count(*) desc";
                        ps = oc_conn.prepareStatement(sQuery);
                        l=30*24*3600;
                        l=l*1000;
                        ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()-l));
                        rs = ps.executeQuery();
                        while(rs.next()){
                            String type=rs.getString("type");
                            out.println((type==null?"?":getTran("messagetype",type,sWebLanguage))+" = "+rs.getInt("total")+"<br/>");
                        }
                        rs.close();
                        ps.close();
                    %>
                    </td>
                </tr>
                <tr>
                    <td class="titleadmin" width="1%" nowrap><%=getTran("healthnet","active sites",sWebLanguage)%>:</td>
                    <td class="titleadmin">
                        <%
                            sQuery="select count(*) total,hn_source from HealthNetIntegratedMessages where receivedDateTime>=? group by hn_source order by count(*) desc";
                            ps = oc_conn.prepareStatement(sQuery);
                            ps.setTimestamp(1,new Timestamp(new java.util.Date().getTime()-24*3600*1000));
                            rs = ps.executeQuery();
                            while(rs.next()){
                                out.println(getTran("healthnet.site",rs.getString("hn_source"),sWebLanguage)+" = "+rs.getInt("total")+"<br/>");
                            }
                            rs.close();
                            ps.close();
                            oc_conn.close();
                        %>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>