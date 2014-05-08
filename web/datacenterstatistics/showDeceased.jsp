<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="be.mxs.common.util.db.MedwanQuery" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<table width="100%" border="0">
    <%
        String sQuery="select b.firstname,b.lastname,b.dateofbirth,a.oc_encounter_enddate " +
                        " from oc_encounters a, adminview b" +
                        " where" +
                        " datepart(mm,a.oc_encounter_enddate)=? and" +
                        " datepart(yy,a.oc_encounter_enddate)=? and" +
                        " a.oc_encounter_outcome='dead' and" +
                        " a.oc_encounter_type='admission' and" +
                        " a.oc_encounter_patientuid=b.personid" +
                        " order by oc_encounter_enddate";
	    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
        ps.setInt(1,Integer.parseInt(request.getParameter("month")));
        ps.setInt(2,Integer.parseInt(request.getParameter("year")));
        ResultSet rs=ps.executeQuery();
        int n=0;
        while(rs.next()){
            n++;
            try{
                out.println("<tr class='list'><td>"+n+
                    "</td><td>"+rs.getString("lastname").toUpperCase()+
                    "</td><td>"+rs.getString("firstname")+
                    "</td><td>"+ScreenHelper.stdDateFormat.format(rs.getDate("dateofbirth"))+
                    "</td><td>"+ScreenHelper.stdDateFormat.format(rs.getDate("oc_encounter_enddate"))+"<td></tr>");
            }
            catch(Exception e){
            }
        }
        rs.close();
        ps.close();
        oc_conn.close();
    %>
</table>