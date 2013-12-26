<%@page import="java.awt.geom.GeneralPath"%>
<%@page errorPage="/includes/error.jsp"%>
<%@ page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSSORTTABLE %>
<table width='100%' border='0'>
<%
    String sBegin = request.getParameter("start");
    if(sBegin==null){
        sBegin="01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    String sEnd = request.getParameter("end");
    if(sEnd==null){
        sEnd="31/12/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    String sql ="";
    //Eerst zoeken we alle patiënten op met prestaties die aan de dienst verbonden zijn
    sql="select b.*,a.*,oc_prestation_reftype from oc_debets a,oc_encounters b,oc_prestations c where c.oc_prestation_objectid=replace(oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and oc_encounter_objectid=replace(oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','') and oc_debet_date>=? and oc_debet_date<=? and oc_debet_serviceuid like ? and oc_debet_patientinvoiceuid<>''";
    Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = oc_conn.prepareStatement(sql);
	ps.setDate(1,new java.sql.Date(new SimpleDateFormat("dd/MM/yyyy").parse(sBegin).getTime()));
	long l = 24*3600*1000-1;
	java.util.Date e = new SimpleDateFormat("dd/MM/yyyy").parse(sEnd);
	e.setTime(e.getTime()+l);
	ps.setTimestamp(2,new java.sql.Timestamp(e.getTime()));
	ps.setString(3,checkString(request.getParameter("statserviceid"))+"%");
	ResultSet rs = ps.executeQuery();
	SortedMap records = new TreeMap();
	SortedMap invoicegroups = new TreeMap();
	while(rs.next()){
		Encounter encounter = Encounter.get(rs.getString("oc_encounter_serverid")+"."+rs.getString("oc_encounter_objectid"));
		if(encounter!=null){
			String patientid = encounter.getPatientUID();
			String date = new SimpleDateFormat("yyyy/MM/dd").format(rs.getDate("oc_debet_date"));
			String insurance = rs.getString("oc_debet_insuranceuid");
			String uid = date+";"+patientid+";"+insurance;
			String manager = encounter.getManagerUID(),sManager="?";
			if(manager!=null && manager.length()>0){
				try{
					sManager=MedwanQuery.getInstance().getUserName(Integer.parseInt(manager));
				}
				catch(Exception er){}
			}
			uid+=";"+sManager;
			String invoicegroup = checkString(rs.getString("oc_prestation_reftype"));
			if(invoicegroup.length()==0){
				invoicegroup="?";
			}
			invoicegroups.put(invoicegroup,"1");
			if(records.get(uid)==null){
				Hashtable amounts = new Hashtable();
				amounts.put(invoicegroup,rs.getDouble("oc_debet_amount")+";"+rs.getDouble("oc_debet_insuraramount")+";"+rs.getDouble("oc_debet_extrainsuraramount"));
				records.put(uid,amounts);
			}
			else {
				Hashtable amounts = (Hashtable)records.get(uid);
				if(amounts.get(invoicegroup)==null){
					amounts.put(invoicegroup,rs.getDouble("oc_debet_amount")+";"+rs.getDouble("oc_debet_insuraramount")+";"+rs.getDouble("oc_debet_extrainsuraramount"));
				}
				else {
					String[] sAmounts = ((String)amounts.get(invoicegroup)).split(";");
					try{
						amounts.put(invoicegroup,(Double.parseDouble(sAmounts[0])+rs.getDouble("oc_debet_amount"))+";"+(Double.parseDouble(sAmounts[1])+rs.getDouble("oc_debet_insuraramount"))+";"+(Double.parseDouble(sAmounts[2])+rs.getDouble("oc_debet_extrainsuraramount")));
					}
					catch(Exception en){}
				}
			}
		}
	}
	rs.close();
	ps.close();
	oc_conn.close();
	//Nu gaan we alle records tonen
	if(records.size()>0){
		out.println("<tr class='admin'><td>#</td><td>"+getTran("web","date",sWebLanguage)+"</td><td>"+getTran("web","insurance.number",sWebLanguage)+"</td><td>"+getTran("web","patient",sWebLanguage)+"</td><td>"+getTran("web","administrator",sWebLanguage)+"</td>");
		Iterator m = invoicegroups.keySet().iterator();
		while(m.hasNext()){
			String invoicegroup=(String)m.next();
			out.println("<td>"+invoicegroup+"</td>");
		}
		out.println("<td>"+getTran("web","total",sWebLanguage)+"</td><td>"+getTran("web","received",sWebLanguage)+"</td><td>"+getTran("web", "to.be.collected", sWebLanguage)+"</td></tr>");
	}
	Iterator i = records.keySet().iterator();
	int counter=0;
	double generalpatienttotal=0,generalinsurartotal=0;
	while(i.hasNext()){
		counter++;
		String uid = (String)i.next();
		Insurance insurance = Insurance.get(uid.split(";")[2]);
		try{
			int personid=Integer.parseInt(uid.split(";")[1]);
		}
		catch(Exception ea){
			continue;
		}
		AdminPerson patient = AdminPerson.getAdminPerson(uid.split(";")[1]);
		out.println("<tr><td class='admin2'>"+counter+"</td><td class='admin2'>"+uid.split(";")[0]+"</td><td class='admin2'>"+(insurance==null?"":insurance.getInsuranceNr())+"</td><td class='admin2'>"+(patient.lastname==null?"":patient.lastname.toUpperCase())+", "+patient.firstname+"</td><td class='admin2'>"+uid.split(";")[3]+"</td>");
		Hashtable amounts = (Hashtable)records.get(uid);
		double patienttotal=0,insurartotal=0;
		Iterator m = invoicegroups.keySet().iterator();
		while(m.hasNext()){
			String invoicegroup=(String)m.next();
			if(amounts.get(invoicegroup)==null){
				out.println("<td class='admin2'/>");
			}
			else {
				String amountline=(String)amounts.get(invoicegroup);
				double patientamount=0;
				try{
					patientamount = Double.parseDouble(amountline.split(";")[0]);
				}
				catch(Exception ex){}
				double insuraramount = 0;
				try {
					insuraramount = Double.parseDouble(amountline.split(";")[1])+Double.parseDouble(amountline.split(";")[2]);
				}
				catch(Exception ey){}
				patienttotal+=patientamount;
				insurartotal+=insuraramount;
				generalpatienttotal+=patientamount;
				generalinsurartotal+=insuraramount;
				out.println("<td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patientamount+insuraramount)+"</td>");
			}
		}
		out.println("<td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patienttotal+insurartotal)+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(patienttotal)+"</td><td class='admin2'>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(insurartotal)+"</td></tr>");
	}
	out.println("<tr class='admin'><td colspan='5'>"+getTran("web","total",sWebLanguage)+"</td>");
	Iterator m = invoicegroups.keySet().iterator();
	while(m.hasNext()){
		String invoicegroup=(String)m.next();
		out.println("<td></td>");
	}
	out.println("<td>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(generalpatienttotal+generalinsurartotal)+"</td><td>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(generalpatienttotal)+"</td><td>"+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#")).format(generalinsurartotal)+"</td></tr>");
%>
</table>
