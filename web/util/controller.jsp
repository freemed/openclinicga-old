<%@ page import="java.util.*,net.admin.jtable.*,com.google.gson.*,java.sql.*,be.mxs.common.util.db.*" %>
<%
	String action = request.getParameter("action");
	List<Patient> patients = new ArrayList<Patient>();
	Gson gson = new GsonBuilder().setPrettyPrinting().create();
	response.setContentType("application/json");
	if (action.equals("list")){
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		PreparedStatement ps = conn.prepareStatement("select count(*) as count from Admin where firstname is not null and firstname <>'' order by searchname");
		ResultSet rs = ps.executeQuery();
		int totalrecordcount=0;
		if(rs.next()){
			totalrecordcount=rs.getInt("count");
		}
		rs.close();
		ps.close();
		ps = conn.prepareStatement("select * from Admin where firstname is not null and firstname <>'' order by searchname");
		rs = ps.executeQuery();
		int counter=0;
		while(rs.next() && counter++<10){
			patients.add(new Patient(rs.getInt("personid"),rs.getString("lastname"),rs.getString("firstname")));
		}
		rs.close();
		ps.close();
		conn.close();
		String jsonArray = gson.toJson(patients);
		jsonArray="{\"Result\":\"OK\",\"Records\":"+jsonArray+",\"TotalRecordCount\":"+totalrecordcount+"}";
		response.getWriter().print(jsonArray);
	}

%>