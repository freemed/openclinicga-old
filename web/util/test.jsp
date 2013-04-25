
<%@ page import="be.openclinic.finance.Balance,
                java.sql.*,be.mxs.common.util.db.*" %><%
System.out.println(new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(new java.util.Date())+": util 1");
      double total=0;
      Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
      try{
       	String sSelect = "select sum(total) balance from" +
                   " (" +
                   " select sum(oc_patientcredit_amount) total from oc_patientcredits a,oc_encounters b" +
                   " where" +
                   " a.oc_patientcredit_encounteruid='"+MedwanQuery.getInstance().getConfigString("serverId")+".'"+MedwanQuery.getInstance().concatSign()+"b.oc_encounter_objectid and" +
                   " b.oc_encounter_patientuid=?" +
                   " union" +
                   " select -sum(oc_debet_amount) total from oc_debets a,oc_encounters b" +
                   " where" +
                   " a.oc_debet_encounteruid='"+MedwanQuery.getInstance().getConfigString("serverId")+".'"+MedwanQuery.getInstance().concatSign()+"b.oc_encounter_objectid and" +
                   " b.oc_encounter_patientuid=? and" +
                   " (a.oc_debet_extrainsuraruid2 is null or a.oc_debet_extrainsuraruid2 ='')" +
                   ") a";
          PreparedStatement ps = oc_conn.prepareStatement(sSelect);
          System.out.println(sSelect);
          ps.setInt(1,16500);
          ps.setInt(2,16500);
          ResultSet rs = ps.executeQuery();
          if(rs.next()){
              total=rs.getDouble("balance");
          }
          rs.close();
          ps.close();
      }
      catch(Exception e){
          e.printStackTrace();
      }
      try {
	oc_conn.close();
} catch (SQLException e) {
	// TODO Auto-generated catch block
	e.printStackTrace();
}
System.out.println(new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss SSS").format(new java.util.Date())+": util 2");

%>