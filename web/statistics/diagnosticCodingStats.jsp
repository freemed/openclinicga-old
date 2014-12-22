<%@page import="java.util.*,
                java.util.Date,
                java.text.DecimalFormat,
                be.openclinic.adt.Encounter"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE%>

<%!
	public class Line {
		String name;
		double total;
		double contacts;
		
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
		Debug.println("\n***************** statistics/diagnosticCodingStats.jsp *****************");
		Debug.println("sFindBegin : "+sFindBegin);
		Debug.println("sFindEnd   : "+sFindEnd+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
    Vector lines = new Vector();	
%>

<form name="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doFind();}">
    <%=writeTableHeader("Web","statistics.activitystats.diagnosticcoding",sWebLanguage," doBack();")%>
    
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
    	           <td width="250"><%=getTran("web","patient",sWebLanguage)%></td>
    	           <td width="120"><%=getTran("web","diagnoses",sWebLanguage)%></td>
    	           <td width="*"><%=getTran("web","encounters",sWebLanguage)%></td>
    	        </tr>
    	<%
    	
    	String sQuery = "select count(*) total, count(distinct oc_diagnosis_encounteruid) contacts, oc_diagnosis_authoruid"+
                        " from ("+
    	                "  select distinct oc_diagnosis_encounteruid, oc_diagnosis_code, oc_diagnosis_authoruid"+
                        "   from oc_diagnoses_view d, oc_encounters e"+ 
    					"    where oc_diagnosis_date between ? and ?"+
    					"     and d.oc_diagnosis_encounterobjectid = e.oc_encounter_objectid) a"+
    					"  group by oc_diagnosis_authoruid"+
    					"  order by count(*) DESC";
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
    	
        Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
    	PreparedStatement ps = oc_conn.prepareStatement(sQuery);
    	ps.setTimestamp(1,new Timestamp(begin.getTime()));
    	ps.setTimestamp(2,new Timestamp(end.getTime()));
    	ResultSet rs = ps.executeQuery();
    	double generaltotal = 0;
    	
    	while(rs.next()){
    		double total = rs.getInt("total");
    		double contacts = rs.getInt("contacts");
    		generaltotal+= total;
    		int userid = rs.getInt("oc_diagnosis_authoruid");
    		String username = MedwanQuery.getInstance().getUserName(userid);
    		
    		lines.add(new Line(username,total,contacts));
    	}
		rs.close();
		ps.close();
		oc_conn.close();
		
		String sClass = "1";
		DecimalFormat deci1 = new DecimalFormat("#,###"),
				      deci2 = new DecimalFormat("##0.0");
    	for(int n=0; n<lines.size(); n++){
    		Line line = (Line)lines.elementAt(n);
    		
    		// alternate row-style
    		if(sClass.length()==0) sClass = "1";
    		else                   sClass = "";
    		
    		out.print("<tr class='list"+sClass+"'>"+
    		           "<td>"+line.name.toUpperCase()+"&nbsp;</td>"+
    		           "<td><b>"+deci1.format(line.total)+" ("+deci2.format(100*line.total/generaltotal)+"%)</b></td>"+
    		           "<td><b>"+deci1.format(line.contacts)+"</b></td>"+
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
      document.getElementById("FindBegin").focus();
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
    }
  }

  document.getElementById("FindBegin").focus();
</script>

<a name="bottom">&nbsp;</a>