<%@ page import="java.text.SimpleDateFormat,
                 java.sql.*"%>
<%!
    private String findPar(String parName,String defaultValue,String[] array){
        for (int n=0;n<array.length;n++){
            if (array[n].indexOf(parName+"=")>-1){
                return array[n].substring(array[n].indexOf("=")+1,array[n].length());
            }
        }
        return defaultValue;
    }
%>
<%
    String b=(request.getParameter("beginDate")==null?"":request.getParameter("beginDate"));
    String e=(request.getParameter("endDate")==null?"":request.getParameter("endDate"));
%>
<form method='POST'>
Van: <input type='text' size='10' name='beginDate' maxcols='10' value='<%=b%>'> (dd/mm/yyyy) tot: <input type='text' size='10' name='endDate' value='<%=e%>'> (dd/mm/yyyy), einddatum niet inbegrepen<br/>
Bedrijf: <select name='company'>
<%
    //Paar parameterkes initialiseren
    String[] args = {};
    String dbuser=findPar("dbuser","helpdesk",args),dbpassword=findPar("dbpassword","helpdesk",args),dbname=findPar("dbname","jdbc:mysql://10.1.3.110/helpdesk",args),dbdriver=findPar("dbdriver","com.mysql.jdbc.Driver",args),gwuser=findPar("gwuser","fve",args);
    Class.forName(dbdriver);
    Connection dbConnection = DriverManager.getConnection(dbname,dbuser,dbpassword);
    PreparedStatement ps = dbConnection.prepareStatement("select * from phpgw_categories where cat_appname='tts'");
    ResultSet rs = ps.executeQuery();
    while (rs.next()){
        out.print("<option value='"+rs.getString("cat_name")+"' "+(rs.getString("cat_name").equalsIgnoreCase(request.getParameter("company"))?"selected":"")+">"+rs.getString("cat_name")+"</option>");
    }
    rs.close();
    ps.close();
%>
</select>
<input type='submit' name='submit' value='uitvoeren'/>
</form>
<table border="1" width="100%">
<%
    if (request.getParameter("submit")!=null){
        //Connectie maken
        try {
            java.util.Date beginDate = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("beginDate"));
            java.util.Date endDate = new SimpleDateFormat("dd/MM/yyyy").parse(request.getParameter("endDate"));
            ps = dbConnection.prepareStatement("select * from phpgw_tts_tickets a,phpgw_categories b,phpgw_accounts c where a.ticket_owner=c.account_id and a.ticket_category=b.cat_id and b.cat_appname='tts' and cat_name='"+request.getParameter("company")+"'");
            rs = ps.executeQuery();
            PreparedStatement ps2;
            int totalRecords;
            String open;
            while (rs.next()){
                ps2 = dbConnection.prepareStatement("select count(*) total from phpgw_history_log where history_record_id="+rs.getString("ticket_id")+" and history_appname='tts' and history_status='C' and history_timestamp>? and history_timestamp<?");
                ps2.setTimestamp(1,new Timestamp(beginDate.getTime()));
                ps2.setTimestamp(2,new Timestamp(endDate.getTime()));
                ResultSet rs2 = ps2.executeQuery();
                rs2.next();
                totalRecords = rs2.getInt("total");
                ps2.close();
                if (totalRecords>0 || rs.getString("ticket_status").equalsIgnoreCase("O")){
                    open="";
                    rs2.close();
                    ps2.close();
                    ps2 = dbConnection.prepareStatement("select * from phpgw_history_log b where history_record_id=? and history_appname='tts' and history_status='O' order by history_timestamp");
                    ps2.setInt(1,rs.getInt("ticket_id"));
                    rs2 = ps2.executeQuery();
                    if (rs2.next()){
                        open= new SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs2.getTimestamp("history_timestamp"));
                    }
                    out.print("<tr><td><table width='100%' border='1'>");
                    out.print("<tr><td bgcolor='lightgrey' width='15%'><b>#"+rs.getString("ticket_id")+" "+(rs.getString("ticket_status").equalsIgnoreCase("O")?"OPEN":"CLOSED")+"</b></td><td bgcolor='lightgrey' width='20%'><b>"+rs.getString("account_firstname")+" "+rs.getString("account_lastname")+"</b></td><td colspan='2' bgcolor='lightgrey'><b>"+rs.getString("ticket_subject")+"</b></td></tr>");
                    out.print("<tr><td width='35%' colspan='2'>Detail<br/>"+open+"</td><td colspan='2'>"+rs.getString("ticket_details").replaceAll("\n","<br/>")+"</td></tr>");
                    rs2.close();
                    ps2.close();
                    ps2 = dbConnection.prepareStatement("select * from phpgw_history_log a,phpgw_accounts b where a.history_owner=b.account_id and history_record_id=? and history_appname='tts' and history_status='C' order by history_timestamp");
                    ps2.setInt(1,rs.getInt("ticket_id"));
                    rs2 = ps2.executeQuery();
                    while (rs2.next()){
                        if (rs2.getTimestamp("history_timestamp").before(new Timestamp(endDate.getTime())) && rs2.getTimestamp("history_timestamp").after(new Timestamp(beginDate.getTime()))){
                            out.print("<tr><td width='15%' bgcolor='lightgreen'>"+new SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs2.getTimestamp("history_timestamp"))+"</td><td width='20%' bgcolor='lightgreen'>"+rs2.getString("account_firstname")+" "+rs2.getString("account_lastname")+"</td><td colspan='2' bgcolor='lightgreen'>"+rs2.getString("history_new_value").replaceAll("\n","<br/>")+"</td></tr>");
                        }
                        else {
                            out.print("<tr><td width='15%'>"+new SimpleDateFormat("dd/MM/yyyy HH:mm").format(rs2.getTimestamp("history_timestamp"))+"</td><td width='20%'>"+rs2.getString("account_firstname")+" "+rs2.getString("account_lastname")+"</td><td colspan='2'>"+rs2.getString("history_new_value").replaceAll("\n","<br/>")+"</td></tr>");
                        }
                    }
                    out.print("</table></td></tr>");
                }
                rs2.close();
                ps2.close();
            }
            rs.close();
            ps.close();
        }
        catch (Exception ex){
            ex.printStackTrace();
        }
    }
%>
</table>