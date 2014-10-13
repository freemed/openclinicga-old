<%@page import="java.sql.PreparedStatement,
                be.mxs.common.util.db.MedwanQuery,
                java.sql.*,
                java.text.SimpleDateFormat"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%
    String sMonth = checkString(request.getParameter("month")),
           sYear  = checkString(request.getParameter("year"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n*********************** statistics/showDeceased.jsp ********************");
    	Debug.println("sMonth : "+sMonth);
    	Debug.println("sYear  : "+sYear+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    String sTitle = getTranNoLink("web","died",sWebLanguage)+" - "+getTran("web","month"+sMonth,sWebLanguage)+" "+sYear;
%>

<%=writeTableHeaderDirectText(sTitle,sWebLanguage,"window.close()")%>

<table width="100%" class="sortable" id="searchresults" cellspacing="1" cellpadding="0">
    <%
        // header
        out.print("<tr class='gray'>"+
                   "<td width='16'>#</td>"+
                   "<td width='250'>"+getTran("web","lastname",sWebLanguage)+"</td>"+
                   "<td width='250'>"+getTran("web","firstname",sWebLanguage)+"</td>"+
                   "<td width='110'>"+getTran("web","dateofbirth",sWebLanguage)+"</td>"+
                   "<td width='110'>"+getTran("web","enddate",sWebLanguage)+"</td>"+
                  "</tr>");
    
        // search 
        String sQuery = "select b.firstname, b.lastname, b.dateofbirth, a.oc_encounter_enddate"+
                        " from oc_encounters a, adminview b"+
                        "  where month(a.oc_encounter_enddate)=?"+
                        "   and year(a.oc_encounter_enddate)=?"+
                        "   and a.oc_encounter_outcome = 'dead'"+
                        "   and a.oc_encounter_type = 'admission'"+
                        "   and a.oc_encounter_patientuid = b.personid"+
                        " order by oc_encounter_enddate";
	    Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = oc_conn.prepareStatement(sQuery);
        ps.setInt(1,Integer.parseInt(sMonth));
        ps.setInt(2,Integer.parseInt(sYear));
        ResultSet rs = ps.executeQuery();
        int n = 0;
        
        String sClass = "1";
        while(rs.next()){
            n++;
            
            // alternate row-style
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";
            
            try{
                out.print("<tr class='list"+sClass+"'>"+
                           "<td>"+n+"</td>"+
                           "<td>"+rs.getString("lastname").toUpperCase()+"</td>"+
                           "<td>"+rs.getString("firstname")+"</td>"+
                           "<td>"+ScreenHelper.stdDateFormat.format(rs.getDate("dateofbirth"))+"</td>"+
                           "<td>"+ScreenHelper.stdDateFormat.format(rs.getDate("oc_encounter_enddate"))+"</td>"+
                          "</tr>");
            }
            catch(Exception e){
            	// empty
            }
        }
        rs.close();
        ps.close();
        oc_conn.close();
    %>
</table>
        
<%
    if(n==0){
      	%><%=getTran("web","noRecordsFound",sWebLanguage)%><%
    }
    else{
      	%><%=n%> <%=getTran("web","recordsFound",sWebLanguage)%><%
    }
%>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="window.close();">
<%=ScreenHelper.alignButtonsStop()%>