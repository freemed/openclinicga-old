<%@include file="/includes/validateUser.jsp"%>
<ul id="autocompletion">
<%
	StringBuffer items=new StringBuffer();
	boolean initialized=false;
    int iMaxRows = MedwanQuery.getInstance().getConfigInt("MaxSearchFieldsRows", 30);

	String key=checkString(request.getParameter("key"));
	String search=checkString(request.getParameter("search"));
	boolean hasMoreResults=false;
	int counter=0;
	if(key.equalsIgnoreCase("insuraremployers")){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		PreparedStatement ps=conn.prepareStatement("select distinct upper(oc_insurance_member_employer) as name from oc_insurances where oc_insurance_member_employer like ? order by name");
		ps.setString(1,"%"+search+"%");
		ResultSet rs = ps.executeQuery();
		while(rs.next()){
			counter++;
			if(counter>iMaxRows){
				hasMoreResults=true;
				break;
			}
			out.write("<li>"+rs.getString("name")+"</li>");
		}
	}
%>
</ul>
<%
	if (hasMoreResults) {
	    out.write("<ul id='autocompletion'><li>....</li></ul>");
	}
%>
