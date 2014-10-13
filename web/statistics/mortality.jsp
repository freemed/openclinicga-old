<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics.globalpathologydistribution","select",activeUser)%>

<form method="POST">
    <%=writeTableHeader("web","statistics.mortality",sWebLanguage," doBack()")%>

    <table width="100%" cellpadding="0" cellspacing="1" class="list">
        <tr>
            <td class="admin2">
	            <%-- YEAR --%>
                <select name="year" id="year" class="text">
		        <%
		            for(int n=0; n<10; n++){
		                int activeYear = (Integer.parseInt(new SimpleDateFormat("yyyy").format(new java.util.Date()))-n);
		                out.print("<option "+((activeYear+"").equalsIgnoreCase(request.getParameter("year"))?"selected":"")+" value='"+activeYear+"'>"+activeYear+"</option>");
		            }
		        %>
	    		</select>
	    
	            <%-- BUTTONS --%>
	            <input class="button" type="submit" name="submit" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/>&nbsp;
	            <input class="button" type="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onClick="doBack()"/>
	        </td>
	    </tr>
	</table>
</form>

<table width="100%" cellpadding="0" cellspacing="1" class="list">
<%
    if(request.getParameter("submit")!=null){
    	String sYear = checkString(request.getParameter("year"));
    	
		java.util.Date firstday = ScreenHelper.parseDate("01/01/"+sYear),
		               lastday  = ScreenHelper.parseDate("31/12/"+sYear);

		// US-date
	    if(ScreenHelper.stdDateFormat.toPattern().equals("MM/dd/yyyy")){
	    	lastday = ScreenHelper.parseDate("12/31/"+sYear);
	    }
		
    	String sQuery = "select count(*) total, month(oc_encounter_enddate) month"+
		                " from oc_encounters"+
                        "  where oc_encounter_enddate>=?"+
                        "   and oc_encounter_enddate<=?"+
                        "   and oc_encounter_outcome = 'dead'"+
                        "   and oc_encounter_type = 'admission'"+
                        "  group by month(oc_encounter_enddate)";
        Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
        PreparedStatement ps = conn.prepareStatement(sQuery);
        ps.setDate(1,new java.sql.Date(firstday.getTime()));
        ps.setDate(2,new java.sql.Date(lastday.getTime()));
        ResultSet rs = ps.executeQuery();
        java.util.Hashtable months = new Hashtable();
        int total = 0;
        while(rs.next()){
            String t = rs.getString("total");
            months.put(rs.getString("month"),t);
            total+= Integer.parseInt(t);
        }
        rs.close();
        ps.close();
        conn.close();
        
        String s1 = "<tr class='admin'>", s2 = "<tr>";
        for(int n=1; n<13; n++){
            s1+= ("<td width='8%'>"+getTran("web","month"+n,sWebLanguage)+"</td>");
            s2+= ("<td class='admin2' width='8%'><a href='javascript:showDeceased("+n+","+request.getParameter("year")+")'>"+(months.get(n+"")==null?"0":months.get(n+""))+"</a></td>");
        }
        s1+= "</tr>";
        s2+= "</tr>";
        out.print(s1+s2);
        
        // total
        out.print("<tr>"+
                   "<td class='admin'>"+getTran("web","total",sWebLanguage)+"</td>"+
                   "<td class='admin2' colspan='11'><b>"+total+"</b></td>"+
                  "</tr>");
    }
%>
</table>

<script>
  function showDeceased(month,year){
    openPopup("<c:url value="statistics/showDeceased.jsp"/>&month="+month+"&year="+year+"&ts="+new Date(),600,400);
  }
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }
</script>