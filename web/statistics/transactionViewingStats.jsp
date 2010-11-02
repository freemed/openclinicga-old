<%@ page import="java.util.*,java.util.Date,java.text.DecimalFormat,be.openclinic.adt.Encounter" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	public class Line {
		String name, profile, service;
		double total;
		double contacts;
		String userid;
		
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
    <%=writeTableHeader("Web","statistics.activitystats.transactionviewing",sWebLanguage," doBack();")%>
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
		%>
		<tr><td class='admin'/><td class='admin'><%=getTran("web","user",sWebLanguage) %></td><td class='admin'><%=getTran("web","profile",sWebLanguage) %></td><td class='admin'><%=getTran("web","service",sWebLanguage) %></td><td class='admin'><%=getTran("web","documents",sWebLanguage) %></td></tr>
		<%
    	String sQuery="select count(*) total,userid "+
						" from accesslogs "+
						" where "+
						" accesstime between ? and ? and "+
						" accesscode like 'T.%' and "+
						" "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(accesscode)>2 "+
						" group by userid "+
						" order by count(*) desc";
    	Date begin = new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new Date())), end = new Date();
    	if(sFindBegin.length()>0){
    		try{
    			begin = new SimpleDateFormat("dd/MM/yyyy").parse(sFindBegin);	
    		}
    		catch(Exception e){}
    	}
    	if(sFindEnd.length()>0){
    		try{
    			end = new SimpleDateFormat("dd/MM/yyyy").parse(sFindEnd);	
    		}
    		catch(Exception e){}
    	}
        Connection oc_conn=MedwanQuery.getInstance().getAdminConnection();
    	PreparedStatement ps = oc_conn.prepareStatement(sQuery);
    	ps.setTimestamp(1,new Timestamp(begin.getTime()));
    	ps.setTimestamp(2,new Timestamp(end.getTime()));
    	ResultSet rs = ps.executeQuery();
    	Vector lines=new Vector();
    	double generaltotal=0;
    	while(rs.next()){
    		double total = rs.getInt("total");
    		double contacts = total;
    		generaltotal+=total;
    		int userid = rs.getInt("userid");
    		String username = MedwanQuery.getInstance().getUserName(userid);
    		Line line = new Line(username,total,contacts);
    		PreparedStatement ps2 = oc_conn.prepareStatement("select b.userprofilename from UserParameters a,Userprofiles b where a.userid=? and a.active=1 and a.parameter='userprofileid' and a.value=b.userprofileid");
    		ps2.setInt(1,userid);
    		ResultSet rs2=ps2.executeQuery();
    		if(rs2.next()){
    			line.profile=rs2.getString("userprofilename");
    		}
    		else {
    			line.profile="";
    		}
    		rs2.close();
    		ps2.close();
    		ps2 = oc_conn.prepareStatement("select value from UserParameters where userid=? and active=1 and parameter='defaultserviceid'");
    		ps2.setInt(1,userid);
    		rs2=ps2.executeQuery();
    		if(rs2.next()){
    			line.service=MedwanQuery.getInstance().getService(rs2.getString("value")).getLabel(sWebLanguage);
    		}
    		else {
    			line.service="";
    		}
    		rs2.close();
    		ps2.close();
    		line.userid=userid+"";
    		
    		lines.add(line);
    	}
		rs.close();
		ps.close();
		oc_conn.close();
    	for(int n=0;n<lines.size();n++){
    		Line line = (Line)lines.elementAt(n);
    		out.println("<tr><td class='admin2'>"+line.userid+"</td><td class='admin2'>"+line.name.toUpperCase()+"</td><td class='admin2'>"+line.profile+"</td><td class='admin2'>"+line.service+"</td><td class='admin2'><b>"+new DecimalFormat("#,###").format(line.contacts)+"</b></td></tr>");
    	}

    }
%>
</table>
<script type="text/javascript">
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
            alert("<%=getTran("web.manage","datamissing",sWebLanguage)%>");
        }
    }

    document.getElementById("FindBegin").focus();
</script>

<a href="#" name="bottom"></a>