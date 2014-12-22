<%@page import="java.util.*,
                java.util.Date,
                java.text.DecimalFormat,
                be.openclinic.adt.Encounter"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%!
	public class Line {
		String name, profile, service, userid;
		double total, contacts;
		
		public Line(String name, double total, double contacts){
			this.name = name;
			this.total = total;
			this.contacts = contacts;
		}
	}
%>

<%
    String sFindBegin = checkString(request.getParameter("FindBegin")),
           sFindEnd   = checkString(request.getParameter("FindEnd"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n**************** statistics/transactionViewingStats.jsp ****************");
		Debug.println("sFindBegin : "+sFindBegin);
		Debug.println("sFindEnd   : "+sFindEnd+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	Vector lines = new Vector();	
%>
<form name="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doFind();}">
    <%=writeTableHeader("Web","statistics.activitystats.transactionviewing",sWebLanguage," doBack();")%>
    
    <table class="menu" width="100%" cellspacing="1" cellpadding="0">
         <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td class="admin2" width="*"><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web","End",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doFind();">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
                <input type="button" class="button" name="ButtonBack" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
</form>

<%
    if(sFindBegin.length() > 0 || sFindEnd.length() > 0){
		%>
    	    <table width="100%" class="sortable" id="searchresults" cellspacing="1" cellpadding="0">
    	        <%-- HEADER --%>
    	        <tr class="gray">
			        <td width="15">&nbsp;</td>
			        <td width="200"><%=getTran("web","user",sWebLanguage)%></td>
			        <td width="120"><%=getTran("web","profile",sWebLanguage)%></td>
			        <td width="250"><%=getTran("web","service",sWebLanguage)%></td>
			        <td width="150"><%=getTran("web","documents",sWebLanguage)%></td>
			    </tr>
		<%
		
    	String sQuery = "select count(*) total, userid"+
						" from accesslogs"+
						"  where accesstime between ? and ?"+
						"   and accesscode like 'T.%'"+
						"   and "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(accesscode)>2"+
						"  group by userid"+
						"  order by count(*) desc";						
    	Date begin = ScreenHelper.parseDate(ScreenHelper.formatDate(new Date())),
    	     end = new Date();
    	if(sFindBegin.length() > 0){
    		try{
    			begin = ScreenHelper.parseDate(sFindBegin);	
    		}
    		catch(Exception e){
    			// empty
    		}
    	}
    	
    	if(sFindEnd.length() > 0){
    		try{
    			end = ScreenHelper.parseDate(sFindEnd);	
    		}
    		catch(Exception e){
    			// empty
    		}
    	}
    	
        Connection oc_conn = MedwanQuery.getInstance().getAdminConnection();
    	PreparedStatement ps = oc_conn.prepareStatement(sQuery);
    	ps.setTimestamp(1,new Timestamp(begin.getTime()));
    	ps.setTimestamp(2,new Timestamp(end.getTime()));
    	ResultSet rs = ps.executeQuery();
    	double generaltotal = 0;
    	
    	while(rs.next()){
    		double total = rs.getInt("total");
    		double contacts = total;
    		generaltotal+= total;
    		
    		int userid = rs.getInt("userid");
    		String username = MedwanQuery.getInstance().getUserName(userid);
    		Line line = new Line(username,total,contacts);
    		
    		PreparedStatement ps2 = oc_conn.prepareStatement("select b.userprofilename from UserParameters a, Userprofiles b"+
    		                                                 " where a.userid = ? and a.active = 1 and a.parameter = 'userprofileid'"+
    		                                                 "  and a.value = b.userprofileid");
    		ps2.setInt(1,userid);
    		ResultSet rs2 = ps2.executeQuery();
    		if(rs2.next()){
    			line.profile = rs2.getString("userprofilename");
    		}
    		else{
    			line.profile = "";
    		}
    		rs2.close();
    		ps2.close();
    		
    		ps2 = oc_conn.prepareStatement("select value from UserParameters"+
    		                               " where userid = ? and active = 1 and parameter = 'defaultserviceid'");
    		ps2.setInt(1,userid);
    		rs2 = ps2.executeQuery();
    		if(rs2.next()){
    			line.service = MedwanQuery.getInstance().getService(rs2.getString("value")).getLabel(sWebLanguage);
    		}
    		else{
    			line.service = "";
    		}
    		rs2.close();
    		ps2.close();
    		
    		line.userid = userid+"";
    		lines.add(line);
    	}
		rs.close();
		ps.close();
		oc_conn.close();

		String sClass = "1";
		DecimalFormat deci = new DecimalFormat("#,###");
    	for(int n=0; n<lines.size(); n++){
    		Line line = (Line)lines.elementAt(n);
    		
    		// alternate row-style
    		if(sClass.length()==0) sClass = "1";
    		else                   sClass = "";
    		
    		out.print("<tr class='list"+sClass+"'>"+
    		           "<td>"+line.userid+"</td>"+
    		           "<td>"+line.name.toUpperCase()+"</td>"+
    		           "<td>"+line.profile+"</td>"+
    		           "<td>"+line.service+"</td>"+
    		           "<td><b>"+deci.format(line.contacts)+"</b></td>"+
    		          "</tr>");
    	}
    	
    	%></table><%
    }

	if(lines.size()==0){
		%><%=getTran("web","noRecordsFound",sWebLanguage)%><%
	}
	else{
	    %>
	        <%=lines.size()%> <%=getTran("web","recordsFound",sWebLanguage)%>
	    
			<%=ScreenHelper.alignButtonsStart()%>
			    <input type="button" class="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onClick="doBack();"/>
			<%=ScreenHelper.alignButtonsStop()%>
	    <%
	}
%>

<script>
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    document.getElementById("FindBegin").value = "";
    document.getElementById("FindEnd").value = "";
    
    document.getElementById("FindBegin").focus();
  }

  <%-- DO FIND --%>
  function doFind(){
    if(document.getElementById("FindBegin").value.length>0){
      transactionForm.submit();
    }
    else{
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
    }
  }

  document.getElementById("FindBegin").focus();
</script>

<a name="bottom">&nbsp;</a>