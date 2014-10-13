<%@page import="be.openclinic.finance.*"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=sJSSORTTABLE%>

<%
    //##### SUMMARY #####
	String sStart = checkString(request.getParameter("start")),
	       sEnd   = checkString(request.getParameter("end")); 
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n****************** statistics/patientslistssummary.jsp ****************");
		Debug.println("sStart : "+sStart);
		Debug.println("sEnd   : "+sEnd+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	if(sStart.length()==0){
		sStart = "01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
	}    
	if(sEnd.length()==0){
		sEnd = "31/12/"+new SimpleDateFormat("yyyy").format(new java.util.Date());

    	// US-date
        if(ScreenHelper.stdDateFormat.toPattern().equals("MM/dd/yyyy")){
            sEnd = "12/31/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
        }
	} 
	
	DecimalFormat deciPrice = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#"));
	
    // alle patiënten met prestaties die aan de dienst verbonden zijn
    String sql = "select b.*, a.*, oc_prestation_reftype"+
                 " from oc_debets a, oc_encounters b, oc_prestations c"+
                 "  where c.oc_prestation_objectid = replace(oc_debet_prestationuid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                 "   and oc_encounter_objectid = replace(oc_debet_encounteruid,'"+MedwanQuery.getInstance().getConfigString("serverId")+".','')"+
                 "   and oc_debet_date >= ?"+
                 "   and oc_debet_date <=? "+
                 "   and oc_debet_serviceuid like ?"+
                 "   and oc_debet_patientinvoiceuid <> ''";
    Connection oc_conn = MedwanQuery.getInstance().getOpenclinicConnection();
	PreparedStatement ps = oc_conn.prepareStatement(sql);
	ps.setDate(1,new java.sql.Date(ScreenHelper.parseDate(sStart).getTime()));
	long l = 24*3600*1000-1;
	java.util.Date endDate = ScreenHelper.parseDate(sEnd);
	endDate.setTime(endDate.getTime()+l);
	ps.setTimestamp(2,new java.sql.Timestamp(endDate.getTime()));
	ps.setString(3,checkString(request.getParameter("statserviceid"))+"%");
	ResultSet rs = ps.executeQuery();
	SortedMap records = new TreeMap();
	SortedMap invoicegroups = new TreeMap();
	
	StringBuffer sOut = new StringBuffer();

	// title
	String sTitle = getTran("Web","statistics.patientslist.summary",sWebLanguage)+
	                " &nbsp;&nbsp;[<i>"+getTran("web","period",sWebLanguage)+": "+sStart+" - "+sEnd+"</i>]";
	sOut.append(writeTableHeaderDirectText(sTitle,sWebLanguage," window.close()"));
	
	sOut.append("<table width='100%' class='sortable' id='searchresults' cellpadding='0' cellspacing='1'>");
	
	while(rs.next()){
		Encounter encounter = Encounter.get(rs.getString("oc_encounter_serverid")+"."+rs.getString("oc_encounter_objectid"));
		if(encounter!=null){
			String patientid = encounter.getPatientUID();
			String date = new SimpleDateFormat("yyyy/MM/dd").format(rs.getDate("oc_debet_date"));
			String insurance = rs.getString("oc_debet_insuranceuid");
			String uid = date+";"+patientid+";"+insurance;
	
			String manager = encounter.getManagerUID(),
				   sManager = "?";
			if(manager!=null && manager.length()>0){
				try{
					sManager = MedwanQuery.getInstance().getUserName(Integer.parseInt(manager));
				}
				catch(Exception er){
					// empty
				}
			}
			
			uid+= ";"+sManager;
			
			String invoicegroup = checkString(rs.getString("oc_prestation_reftype"));
			if(invoicegroup.length()==0){
				invoicegroup = "?";
			}
			
			invoicegroups.put(invoicegroup,"1");
			if(records.get(uid)==null){
				Hashtable amounts = new Hashtable();
				amounts.put(invoicegroup,rs.getDouble("oc_debet_amount")+";"+rs.getDouble("oc_debet_insuraramount")+";"+rs.getDouble("oc_debet_extrainsuraramount"));
				records.put(uid,amounts);
			}
			else{
				Hashtable amounts = (Hashtable)records.get(uid);
				if(amounts.get(invoicegroup)==null){
					amounts.put(invoicegroup,rs.getDouble("oc_debet_amount")+";"+rs.getDouble("oc_debet_insuraramount")+";"+rs.getDouble("oc_debet_extrainsuraramount"));
				}
				else{
					String[] sAmounts = ((String)amounts.get(invoicegroup)).split(";");
					try{
						amounts.put(invoicegroup,(Double.parseDouble(sAmounts[0])+rs.getDouble("oc_debet_amount"))+";"+(Double.parseDouble(sAmounts[1])+rs.getDouble("oc_debet_insuraramount"))+";"+(Double.parseDouble(sAmounts[2])+rs.getDouble("oc_debet_extrainsuraramount")));
					}
					catch(Exception en){
						// empty
					}
				}
			}
		}
	}
	rs.close();
	ps.close();
	oc_conn.close();

	// header
	if(records.size() > 0){
		sOut.append("<tr class='admin'>"+
	                 "<td>#</td>"+
				     "<td>"+getTran("web","date",sWebLanguage)+"</td>"+
	                 "<td>"+getTran("web","insurance.number",sWebLanguage)+"</td>"+
				     "<td>"+getTran("web","patient",sWebLanguage)+"</td>"+
	                 "<td>"+getTran("web","administrator",sWebLanguage)+"</td>");
		Iterator m = invoicegroups.keySet().iterator();
		while(m.hasNext()){
			String invoicegroup = (String)m.next();
			sOut.append("<td>"+invoicegroup+"</td>");
		}
		sOut.append("<td>"+getTran("web","total",sWebLanguage)+"</td>"+
		            "<td>"+getTran("web","received",sWebLanguage)+"</td>"+
				    "<td>"+getTran("web","to.be.collected",sWebLanguage)+"</td>"+
		           "</tr>");
	}

	// alle records tonen
	Iterator iter = records.keySet().iterator();
	int counter = 0;
	double generalpatienttotal = 0, generalinsurartotal = 0;
	while(iter.hasNext()){
		counter++;
		
		String uid = (String)iter.next();
		Insurance insurance = Insurance.get(uid.split(";")[2]);
		if(insurance.getUid()==null || insurance.getUid().split("\\.").length<2){
			insurance = null;
		}
		
		try{
			int personid = Integer.parseInt(uid.split(";")[1]);
		}
		catch(Exception e){
			continue;
		}
		
		AdminPerson patient = AdminPerson.getAdminPerson(uid.split(";")[1]);
		sOut.append("<tr>"+
		             "<td class='admin2'>"+counter+"</td>"+
		             "<td class='admin2'>"+uid.split(";")[0]+"</td>"+
		             "<td class='admin2'>"+(insurance==null?"":insurance.getInsuranceNr())+"</td>"+
		             "<td class='admin2'>"+(patient.lastname==null?"":patient.lastname.toUpperCase())+", "+patient.firstname+"</td>"+
		             "<td class='admin2'>"+(uid.split(";").length<4?"?":uid.split(";")[3])+"</td>");
		Hashtable amounts = (Hashtable)records.get(uid);
		double patienttotal = 0, insurartotal = 0;
		iter = invoicegroups.keySet().iterator();
		while(iter.hasNext()){
			String invoicegroup = (String)iter.next();
			if(amounts.get(invoicegroup)==null){
				sOut.append("<td class='admin2'/>");
			}
			else{
				String amountline = (String)amounts.get(invoicegroup);
				double patientamount = 0;
				try{
					patientamount = Double.parseDouble(amountline.split(";")[0]);
				}
				catch(Exception ex){
					// empty
				}
				
				double insuraramount = 0;
				try{
					insuraramount = Double.parseDouble(amountline.split(";")[1])+Double.parseDouble(amountline.split(";")[2]);
				}
				catch(Exception e){
					// empty
				}
				
				patienttotal+= patientamount;
				insurartotal+= insuraramount;
				generalpatienttotal+= patientamount;
				generalinsurartotal+= insuraramount;
				
				sOut.append("<td class='admin2'>"+deciPrice.format(patientamount+insuraramount)+"</td>");
			}
		}
		
		sOut.append("<td class='admin2'>"+deciPrice.format(patienttotal+insurartotal)+"</td>"+
		            "<td class='admin2'>"+deciPrice.format(patienttotal)+"</td>"+
		            "<td class='admin2'>"+deciPrice.format(insurartotal)+"</td>"+
		           "</tr>");
	}
	
	sOut.append("</table>");

	// total patients
	if(counter > 0){
		sOut.append("<tr class='admin'><td colspan='5'>"+getTran("web","total",sWebLanguage)+"</td>");
		
		iter = invoicegroups.keySet().iterator();
		while(iter.hasNext()){
			String invoicegroup = (String)iter.next();
			sOut.append("<td></td>");
		}
		sOut.append("<td>"+deciPrice.format(generalpatienttotal+generalinsurartotal)+"</td>"+
		            "<td>"+deciPrice.format(generalpatienttotal)+"</td>"+
				    "<td>"+deciPrice.format(generalinsurartotal)+"</td>"+
		           "</tr>");
	}
	else{
	    sOut.append(getTran("web","noRecordsFound",sWebLanguage));	
	}
	
	out.print(sOut);
%>

<%=ScreenHelper.alignButtonsStart()%>
    <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onClick="window.close();"/>
<%=ScreenHelper.alignButtonsStop()%>
