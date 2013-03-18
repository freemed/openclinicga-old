<%@include file="/includes/validateUser.jsp"%>
<%@ page import="java.io.*" %>

<%
try{
	StringBuffer exportfile = new StringBuffer();
	java.util.Date lastexport = new SimpleDateFormat("yyyyMMddHHmmssSSS").parse(MedwanQuery.getInstance().getConfigString("lasAMOexport","19000101000000000"));
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = conn.prepareStatement(	"select * from oc_debets a,oc_encounters b,adminview c,oc_patientinvoices d,oc_insurances e,oc_prestations f"+
													" where"+
													" b.oc_encounter_objectid=replace(a.oc_debet_encounteruid,'1.','') and"+
													" d.oc_patientinvoice_objectid=replace(oc_debet_patientinvoiceuid,'1.','') and" +
													" d.oc_patientinvoice_status='closed' and" +
													" b.oc_encounter_patientuid=c.personid and"+
													" length(oc_debet_patientinvoiceuid)>0  and" +
													" d.oc_patientinvoice_updatetime>? and" +
													" e.oc_insurance_objectid=replace(a.oc_debet_insuranceuid,'1.','') and" +
													" e.oc_insurance_insuraruid=? and" +
													" f.oc_prestation_objectid=replace(a.oc_debet_prestationuid,'1.','')" +
													" order by d.oc_patientinvoice_objectid");
	ps.setTimestamp(1, new Timestamp(lastexport.getTime()));
	ps.setString(2, MedwanQuery.getInstance().getConfigString("MFP","$erfaefaef"));
	ResultSet rs = ps.executeQuery();
	exportfile.append("ID prestation;");
	exportfile.append("date prestation;");
	exportfile.append("consultation (C) ou hospitalisation (H);");
	exportfile.append("ID consultation ou hopitalisation;");
	exportfile.append("numero AMO;");
	exportfile.append("adherent (affiliate) enfant (child) parent (parent) ou conjoint (partner);");
	exportfile.append("INPS ou CMSS;");
	exportfile.append("nom du patient;");
	exportfile.append("prénom du patient;");
	exportfile.append("code prestation;");
	exportfile.append("dénomination prestation;");
	exportfile.append("prix prestation;");
	exportfile.append("part AMO prestation;");
	exportfile.append("numéro facture patient\n");
	while(rs.next()){
		exportfile.append(rs.getString("oc_debet_objectid")+";");
		exportfile.append(new SimpleDateFormat("dd/MM/yyyy").format(rs.getDate("oc_debet_date"))+";");
		exportfile.append((rs.getString("oc_encounter_type").equalsIgnoreCase("admission")?"H":"C")+";");
		exportfile.append(rs.getString("oc_encounter_objectid")+";");
		exportfile.append(rs.getString("oc_insurance_nr")+";");
		exportfile.append(rs.getString("oc_insurance_status")+";");
		exportfile.append((rs.getString("oc_insurance_insurancecategoryletter").equalsIgnoreCase("A")?"INPS":"CMSS")+";");
		exportfile.append(rs.getString("lastname")+";");
		exportfile.append(rs.getString("firstname")+";");
		exportfile.append(rs.getString("oc_prestation_code")+";");
		exportfile.append(rs.getString("oc_prestation_description")+";");
		exportfile.append(rs.getString("oc_prestation_price")+";");
		exportfile.append(rs.getString("oc_debet_insuraramount")+";");
		exportfile.append(rs.getString("oc_patientinvoice_objectid")+"\n");
	}
	rs.close();
	ps.close();
	conn.close();
    BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(MedwanQuery.getInstance().getConfigString("exportAMOfile","/temp/exportAMO.csv")));
    bufferedWriter.write(exportfile.toString());
    bufferedWriter.flush();
    bufferedWriter.close();

} catch (Exception e) {
	// TODO Auto-generated catch block
	e.printStackTrace();
}

%>
 
