<%@ page import="java.util.*,java.util.Date,java.text.DecimalFormat,be.openclinic.adt.Encounter" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	public class Line {
		String name,profile,service;
		double total;
		double contacts;
		String userid;
		
		public Line(String name,double total,double contacts,String userid){
			this.name=name;
			this.total=total;
			this.contacts=contacts;
			this.userid=userid;
		}
	}
%>
<%
    String sFindBegin = checkString(request.getParameter("FindBegin"));
    String sFindEnd = checkString(request.getParameter("FindEnd"));
%>
<form name="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doFind();}">
    <%=writeTableHeader("Web","statistics.activitystats.recordviewing",sWebLanguage," doBack();")%>
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
		<tr><td class='admin'><td class='admin'/><%=getTran("web","user",sWebLanguage) %></td><td class='admin'><%=getTran("web","profile",sWebLanguage) %></td><td class='admin'><%=getTran("web","service",sWebLanguage) %></td><td class='admin'><%=getTran("web","opened_records",sWebLanguage)%></td><td class='admin'><%=getTran("web","creations_modifications",sWebLanguage)%></td></tr>
		<%
    	String sQuery="select count(*) total,userid "+
						" from accesslogs "+
						" where "+
						" accesstime between ? and ? and "+
						" accesscode like 'A.%' and "+
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
    	double total=0;
    	double rows=0;
    	while(rs.next()){
    		total = rs.getInt("total");
    		double contacts = total;
    		generaltotal+=total;
    		int userid = rs.getInt("userid");
    		String username = MedwanQuery.getInstance().getUserName(userid);
    		Line line = new Line(username,total,contacts,userid+"");
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
    		
    		lines.add(line);
    	}
		rs.close();
		ps.close();
    	sQuery="select count(*) total,userid "+
		" from accesslogs "+
		" where "+
		" accesstime between ? and ? and "+
		" accesscode like 'M.%' and "+
		" "+MedwanQuery.getInstance().getConfigString("lengthFunction","len")+"(accesscode)>2 "+
		" group by userid";
    	ps = oc_conn.prepareStatement(sQuery);
    	ps.setTimestamp(1,new Timestamp(begin.getTime()));
    	ps.setTimestamp(2,new Timestamp(end.getTime()));
    	rs = ps.executeQuery();
    	Hashtable hModif = new Hashtable();
    	while (rs.next()){
    		hModif.put(rs.getString("userid"),rs.getInt("total"));
    	}
		rs.close();
		ps.close();
		oc_conn.close();
    	for(int n=0;n<lines.size();n++){
    		rows++;
    		Line line = (Line)lines.elementAt(n);
    		int creations=0;
    		if(hModif.get(line.userid)!=null){
    			creations=((Integer)hModif.get(line.userid)).intValue();
    		}
    		out.println("<tr><td class='admin2'>"+line.userid+"</td><td class='admin2'>"+line.name.toUpperCase()+"</td><td class='admin2'>"+line.profile+"</td><td class='admin2'>"+line.service+"</td><td class='admin2'><b>"+new DecimalFormat("#,###").format(line.contacts)+"</b></td><td class='admin2'><b>"+new DecimalFormat("#,###").format(creations)+"</b></td></tr>");
    	}
		out.println("<tr><td class='admin2'>total</td><td class='admin2'>"+rows+"</td><td class='admin2'></td><td class='admin2'></td><td class='admin2'><b></b></td><td class='admin2'><b></b></td></tr>");

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