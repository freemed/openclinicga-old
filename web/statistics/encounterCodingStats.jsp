<%@ page import="java.util.*,java.util.Date,java.text.DecimalFormat,be.openclinic.adt.Encounter" %>
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
    String sFindBegin = checkString(request.getParameter("FindBegin"));
    String sFindEnd = checkString(request.getParameter("FindEnd"));
%>
<form name="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doFind();}">
    <%=writeTableHeader("Web","statistics.activitystats.encountercoding",sWebLanguage," doBack();")%>
    <table class="menu" width="100%" cellspacing="0">
         <tr>
            <td><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        <tr>
            <td><%=getTran("Web","End",sWebLanguage)%></td>
            <td><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
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
    	String sQuery="select count(*) total,count(distinct oc_encounter_objectid) contacts,oc_encounter_updateuid from "+
    					" oc_encounters"+ 
    					" where oc_encounter_updatetime between ? and ?"+
    					" group by oc_encounter_updateuid"+
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
    		int userid = rs.getInt("oc_encounter_updateuid");
    		String username = MedwanQuery.getInstance().getUserName(userid);
    		lines.add(new Line(username,total,contacts));
    	}
		rs.close();
		ps.close();
		oc_conn.close();
    	for(int n=0;n<lines.size();n++){
    		Line line = (Line)lines.elementAt(n);
    		out.println("<tr><td class='admin2'>"+line.name.toUpperCase()+"</td><td><b>"+getTran("web","encounters",sWebLanguage)+": "+new DecimalFormat("#,###").format(line.contacts)+"</b></td></tr>");
    	}

    }
%>
</table>
<script>
  <%-- PRINT PDF --%>
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
        if (document.getElementById("FindBegin").value.length>0){
            transactionForm.submit();
        }
        else {
            alertDialog("web.manage","datamissing");
        }
    }

    document.getElementById("FindBegin").focus();
</script>

<a href="#" name="bottom"></a>