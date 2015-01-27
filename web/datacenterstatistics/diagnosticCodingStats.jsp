<%@page import="java.util.*,
                java.util.Date,
                java.text.DecimalFormat,
                be.openclinic.adt.Encounter"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
	public class Line {
		String name;
		double total;
		double contacts;
		
		public Line(String name,double total,double contacts){
			this.name=name;
			this.total=total;
			this.contacts=contacts;
	}
}
%>

<%
    String sFindBegin = checkString(request.getParameter("FindBegin")),
           sFindEnd   = checkString(request.getParameter("FindEnd"));
%>
<form name="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doFind();}">
    <%=writeTableHeader("Web","statistics.activitystats.diagnosticcoding",sWebLanguage," doBack();")%>
    <table class="menu" width="100%" cellspacing="0">
         <tr>
            <td><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        <tr>
            <td><%=getTran("Web","End",sWebLanguage)%></td>
            <td><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        
        <%-- BUTTONS --%>
        <%=ScreenHelper.setSearchFormButtonsStart()%>
            <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doFind();">&nbsp;
            <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFields()">&nbsp;
            <input type="button" class="button" name="ButtonBack" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
        <%=ScreenHelper.setSearchFormButtonsStop()%>
    </table>
</form>
<table>

<%
    if ((sFindBegin.length() > 0) || (sFindEnd.length() > 0)) {
    	String sQuery="select count(*) total,count(distinct oc_diagnosis_encounteruid) contacts,oc_diagnosis_authoruid from "+
    					" (select distinct oc_diagnosis_encounteruid,oc_diagnosis_code,oc_diagnosis_authoruid from oc_diagnoses_view d,oc_encounters e"+ 
    					" where oc_diagnosis_date between ? and ?"+
    					" and d.oc_diagnosis_encounterobjectid=e.oc_encounter_objectid) a"+
    					" group by oc_diagnosis_authoruid"+
    					" order by count(*) DESC";
    	Date begin = ScreenHelper.parseDate(ScreenHelper.stdDateFormat.format(new Date())), end = new Date();
    	if(sFindBegin.length()>0){
    		try{
    			begin = ScreenHelper.parseDate(sFindBegin);	
    		}
    		catch(Exception e){}
    	}
    	if(sFindEnd.length()>0){
    		try{
    			end = ScreenHelper.parseDate(sFindEnd);	
    		}
    		catch(Exception e){}
    	}
        Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
    	PreparedStatement ps = oc_conn.prepareStatement(sQuery);
    	ps.setTimestamp(1,new Timestamp(begin.getTime()));
    	ps.setTimestamp(2,new Timestamp(end.getTime()));
    	ResultSet rs = ps.executeQuery();
    	Vector lines=new Vector();
    	double generaltotal=0;
    	while(rs.next()){
    		double total = rs.getInt("total");
    		double contacts = rs.getInt("contacts");
    		generaltotal+=total;
    		int userid = rs.getInt("oc_diagnosis_authoruid");
    		String username = MedwanQuery.getInstance().getUserName(userid);
    		lines.add(new Line(username,total,contacts));
    	}
    	for(int n=0;n<lines.size();n++){
    		Line line = (Line)lines.elementAt(n);
    		out.println("<tr><td class='admin2'>"+line.name.toUpperCase()+"</td><td><b>"+getTran("web","diagnoses",sWebLanguage)+": "+ new DecimalFormat("#,###").format(line.total)+" ("+new DecimalFormat("##0.0").format(100*line.total/generaltotal)+"%)</b></td><td><b>"+getTran("web","encounters",sWebLanguage)+": "+new DecimalFormat("#,###").format(line.contacts)+"</b></td></tr>");
    	}
        rs.close();
        ps.close();
        oc_conn.close();
    }
%>
</table>

<script>
  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }

  function clearFields(){
    document.getElementById("FindBegin").value="";
    document.getElementById("FindEnd").value="";
    document.getElementById("FindServiceText").value="";
    document.getElementById("FindServiceCode").value="";
  }

  function doFind(){
    if(document.getElementById("FindBegin").value.length>0){
      transactionForm.submit();
    }
    else{
      alertDialog("web.manage","dataMissing");
    }
  }

  document.getElementById("FindBegin").focus();
</script>

<a name="bottom">&nbsp;</a>