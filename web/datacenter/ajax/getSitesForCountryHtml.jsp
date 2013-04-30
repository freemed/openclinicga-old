<%@page import="java.util.*,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%!
    //--- INNER CLASS : SiteData ------------------------------------------------------------------
	public class SiteData{
		java.util.Date date;
		int id;
		
		int patients;
		int visits;
		int admissions;
		int transactions;
		int debets;
		int invoices;
		int labs;
	}
%>

<%
    String sCountryCode = checkString(request.getParameter("CountryCode"));

    // fetch siteData for specified country
	SortedMap cities = new TreeMap(), sites = null;
    	
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try{
    	if(sCountryCode.equalsIgnoreCase("B")){
    		sCountryCode="'B','BE'";
    	}
    	else if(sCountryCode.equalsIgnoreCase("CD")){
    		sCountryCode="'CD','ZR'";
    	}
    	else {
    		sCountryCode="'"+sCountryCode+"'";
    	}
	    conn = MedwanQuery.getInstance().getStatsConnection();
		String sSql = "select distinct * from dc_monitorservers a, dc_monitorvalues b"+
		              " where b.dc_monitorvalue_serverid = a.dc_monitorserver_serverid"+
		              "  and b.dc_monitorvalue_date > ?"+
		              "  and a.dc_monitorserver_name <> ''"+
		              "  and a.dc_monitorserver_country in ("+sCountryCode+") "+
		              " order by dc_monitorserver_city, dc_monitorserver_serverid, dc_monitorvalue_date desc";
	    ps = conn.prepareStatement(sSql);
	
		// revert one month
		long monthMillis = 30*24*3600;
		monthMillis*= 1000;	
		ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()-monthMillis));	
		
		rs = ps.executeQuery();
		SiteData siteData;
		int serverid, activeServer = -1;
		int siteCount = 0;
		
		//*** 1 : fetch data **************************************************
		while(rs.next()){
			serverid = rs.getInt("dc_monitorserver_serverid");
			
			if(serverid!=activeServer){
				activeServer = serverid;
							
				String city = rs.getString("dc_monitorserver_city");
				if(cities.get(city)==null){
					cities.put(city,new TreeMap());
				}
				
				sites = (SortedMap)cities.get(city);
				
				siteData = new SiteData();
				siteData.date = rs.getTimestamp("dc_monitorvalue_date");
				
				siteData.patients   = rs.getInt("dc_monitorvalue_patientcount");
				siteData.visits     = rs.getInt("dc_monitorvalue_visitcount");
				siteData.admissions = rs.getInt("dc_monitorvalue_admissioncount");
				siteData.labs       = rs.getInt("dc_monitorvalue_labanalysescount");
				siteData.invoices   = rs.getInt("dc_monitorvalue_patientinvoicecount");
				siteData.debets     = rs.getInt("dc_monitorvalue_debetcount");
				
				sites.put(activeServer,siteData);				
				siteData.id = siteCount++;
			}
		}
		
		//*** 2 : compose data to display *************************************
		DecimalFormat deci = new DecimalFormat("#,###");
		Iterator sitesIter;
		String sCity;						

		if(cities.size() > 0){
			out.println("<table width='100%' cellpadding='0' cellspacing='1' id='dataDIV_"+sCountryCode+"'>");
			
			Iterator citiesIter = cities.keySet().iterator();
			while(citiesIter.hasNext()){
				sCity = (String)citiesIter.next();
	
				// sum sites in city
				sites = (SortedMap)cities.get(sCity);
				sitesIter = sites.keySet().iterator();
				while(sitesIter.hasNext()){
					siteData = (SiteData)sites.get(sitesIter.next());
						
					out.println("<tr bgcolor='#eeeeee'>"+
					              "<td width='30%' style='padding-left:40px;'>["+siteData.id+"] "+sCity+"</td>"+
							      //"<td width='10%'>ID #"+siteData.id+"</td>"+
							      "<td align='right' width='10%'>"+ScreenHelper.stdDateFormat.format(siteData.date)+"</td>"+
							      "<td align='right' width='10%'>"+deci.format(siteData.patients)+"</td>"+
							      "<td align='right' width='10%'>"+deci.format(siteData.visits)+"</td>"+
							      "<td align='right' width='10%'>"+deci.format(siteData.admissions)+"</td>"+
							      "<td align='right' width='10%'>"+deci.format(siteData.labs)+"</td>"+
							      "<td align='right' width='10%'>"+deci.format(siteData.invoices)+"</td>"+
							      "<td align='right' width='10%'>"+deci.format(siteData.debets)+"</td>"+
					            "</tr>");
				}
			}
				
			out.println("</table>");
	    }
		else{
			out.println(HTMLEntities.htmlentities(getTran("web","noDataFound",sWebLanguage)));
		}
    }
    catch(Exception e){
    	e.printStackTrace();
    }
    finally{
    	try{
    		if(rs!=null) rs.close();
    		if(ps!=null) ps.close();
    		if(conn!=null) conn.close();
    	}
    	catch(Exception e){
    		e.printStackTrace();
    	}
    }
%>

