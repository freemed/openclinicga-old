<%@include file="/includes/validateUser.jsp"%>
<ul id="autocompletion">
<%
	StringBuffer items = new StringBuffer();
	boolean initialized = false;
    int iMaxRows = MedwanQuery.getInstance().getConfigInt("MaxSearchFieldsRows",30);

	String key = checkString(request.getParameter("key")),
		   search = checkString(request.getParameter("search"));
	boolean hasMoreResults = false;
	int counter = 0;
	
	//*** insurar employers ***
	if(key.equalsIgnoreCase("insuraremployers")){
		Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
		String sSql = "select distinct upper(oc_insurance_member_employer) as name"+
		              " from oc_insurances"+
				      "  where oc_insurance_member_employer like ?"+
		              " order by name";
		PreparedStatement ps=conn.prepareStatement(sSql);
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
	//*** todo ***
	else if(key.equalsIgnoreCase("insuraremployers")){
		// todo
	}
%>
</ul>
<%
	if(hasMoreResults){
	    out.write("<ul id='autocompletion'><li>...</li></ul>");
	}
%>
