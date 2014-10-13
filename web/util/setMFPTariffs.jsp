<%@ page import="java.util.*,be.openclinic.finance.*" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
	String mfpid=MedwanQuery.getInstance().getConfigString("MFP");
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps2;
	PreparedStatement ps = conn.prepareStatement("delete FROM OC_TARIFFS where OC_TARIFF_INSURARUID=?");
	ps.setString(1,mfpid);
	ps.execute();
	ps.close();
	ps = conn.prepareStatement("select * from OC_PRESTATIONS where OC_PRESTATION_MFPPERCENTAGE>=0");
	ResultSet rs = ps.executeQuery();
	int counter=0;
	while(rs.next()){
		counter++;
		ps2=conn.prepareStatement("insert into OC_TARIFFS(OC_TARIFF_INSURARUID,OC_TARIFF_PRESTATIONUID,OC_TARIFF_PRICE,OC_TARIFF_VERSION) values(?,?,?,?)");
		ps2.setString(1,mfpid);
		ps2.setString(2,rs.getString("OC_PRESTATION_SERVERID")+"."+rs.getString("OC_PRESTATION_OBJECTID"));
		ps2.setDouble(3,rs.getDouble("OC_PRESTATION_PRICE")*rs.getDouble("OC_PRESTATION_MFPPERCENTAGE")/100);
		ps2.setInt(4,rs.getInt("OC_PRESTATION_VERSION"));
		ps2.execute();
		ps2.close();
	}
	rs.close();
	ps.close();
	ps = conn.prepareStatement("select * from OC_PRESTATIONS");
	rs = ps.executeQuery();
	while(rs.next()){
		Prestation prestation = Prestation.get(rs.getString("OC_PRESTATION_SERVERID")+"."+rs.getString("OC_PRESTATION_OBJECTID"));
		if(prestation!=null && prestation.getMfpAdmissionPercentage()>=0){
			counter++;
			ps2=conn.prepareStatement("insert into OC_TARIFFS(OC_TARIFF_INSURARUID,OC_TARIFF_PRESTATIONUID,OC_TARIFF_PRICE,OC_TARIFF_INSURANCECATEGORY,OC_TARIFF_VERSION) values(?,?,?,?,?)");
			ps2.setString(1,mfpid);
			ps2.setString(2,rs.getString("OC_PRESTATION_SERVERID")+"."+rs.getString("OC_PRESTATION_OBJECTID"));
			ps2.setDouble(3,rs.getDouble("OC_PRESTATION_PRICE")*prestation.getMfpAdmissionPercentage()/100);
			ps2.setString(4,"*H");
			ps2.setInt(5,rs.getInt("OC_PRESTATION_VERSION"));
			ps2.execute();
			ps2.close();
		}
	}
	rs.close();
	ps.close();
	conn.close();

	
%>
<label class='text'><%=counter %> <%=getTran("web","tariffs.calculated",sWebLanguage)%></label>