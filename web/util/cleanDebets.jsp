<%@ page import="be.openclinic.finance.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%
	Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
	String sQuery="select count(*) total,oc_debet_objectid from oc_debets group by oc_debet_objectid having count(*)>1";
	PreparedStatement ps = conn.prepareStatement(sQuery);
	ResultSet rs = ps.executeQuery();
	String sServerId=MedwanQuery.getInstance().getConfigString("serverId");
	int nObjectId;
	while(rs.next()){
		nObjectId=rs.getInt("oc_debet_objectid");
		//Voor dit objectid gaan we nu alle bijhorende records ophalen
		PreparedStatement ps2 = conn.prepareStatement("select distinct * from oc_debets where oc_debet_objectid=?");
		ps2.setInt(1,nObjectId);
		ResultSet rs2 = ps2.executeQuery();
		while(rs2.next()){
			Debet debet = new Debet();
            debet.setUid(sServerId+"."+MedwanQuery.getInstance().getOpenclinicCounter("OC_DEBETS"));
            debet.setDate(rs2.getTimestamp("OC_DEBET_DATE"));
            debet.setAmount(rs2.getDouble("OC_DEBET_AMOUNT"));
            debet.setInsurarAmount(rs2.getDouble("OC_DEBET_INSURARAMOUNT"));
            debet.setInsuranceUid(rs2.getString("OC_DEBET_INSURANCEUID"));
            debet.setPrestationUid(rs2.getString("OC_DEBET_PRESTATIONUID"));
            debet.setEncounterUid(rs2.getString("OC_DEBET_ENCOUNTERUID"));
            debet.setSupplierUid(rs2.getString("OC_DEBET_SUPPLIERUID"));
            debet.setPatientInvoiceUid(rs2.getString("OC_DEBET_PATIENTINVOICEUID"));
            debet.setInsurarInvoiceUid(rs2.getString("OC_DEBET_INSURARINVOICEUID"));
            debet.setComment(rs2.getString("OC_DEBET_COMMENT"));
            debet.setCredited(rs2.getInt("OC_DEBET_CREDITED"));
            debet.setQuantity(rs2.getInt("OC_DEBET_QUANTITY"));
            debet.setExtraInsurarUid(rs2.getString("OC_DEBET_EXTRAINSURARUID"));
            debet.setExtraInsurarInvoiceUid(rs2.getString("OC_DEBET_EXTRAINSURARINVOICEUID"));
            debet.setExtraInsurarAmount(rs2.getDouble("OC_DEBET_EXTRAINSURARAMOUNT"));
            debet.setCreateDateTime(rs2.getTimestamp("OC_DEBET_CREATETIME"));
            debet.setUpdateDateTime(rs2.getTimestamp("OC_DEBET_UPDATETIME"));
            debet.setUpdateUser(rs2.getString("OC_DEBET_UPDATEUID"));
            debet.setVersion(rs2.getInt("OC_DEBET_VERSION"));
            debet.setRenewalInterval(rs2.getInt("OC_DEBET_RENEWALINTERVAL"));
            debet.setRenewalDate(rs2.getTimestamp("OC_DEBET_RENEWALDATE"));
            debet.setPerformeruid(rs2.getString("OC_DEBET_PERFORMERUID"));
            debet.setRefUid(rs2.getString("OC_DEBET_REFUID"));
            debet.setExtraInsurarUid2(rs2.getString("OC_DEBET_EXTRAINSURARUID2"));
            debet.setExtraInsurarInvoiceUid2(rs2.getString("OC_DEBET_EXTRAINSURARINVOICEUID2"));
            debet.store();
		}
		rs2.close();
		ps2.close();
		ps2=conn.prepareStatement("delete from oc_debets where oc_debet_objectid=?");
		ps2.setInt(1,nObjectId);
		ps2.execute();
		ps2.close();
	}
	rs.close();
	ps.close();
	conn.close();
%>