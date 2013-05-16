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
		String softwareversion;
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
	    conn = MedwanQuery.getInstance().getStatsConnection();
		String sSql = "select distinct * from dc_monitorservers a, dc_monitorvalues b"+
		              " where b.dc_monitorvalue_serverid = a.dc_monitorserver_serverid"+
		              "  and b.dc_monitorvalue_date > ?"+
		              "  and a.dc_monitorserver_name <> ''"+
		              "  and a.dc_monitorserver_country = ?"+
		              " order by dc_monitorserver_city, dc_monitorserver_serverid, dc_monitorvalue_date desc";
	    ps = conn.prepareStatement(sSql);
	
		// revert one month
		long monthMillis = 30*24*3600;
		monthMillis*= 1000;	
		ps.setTimestamp(1,new java.sql.Timestamp(new java.util.Date().getTime()-monthMillis));	
		ps.setString(2,sCountryCode);
		
		rs = ps.executeQuery();
		SiteData siteData;
		int serverid, activeServer = -1;
		
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
				siteData.softwareversion = checkString(rs.getString("dc_monitorserver_softwareversion"));
				sites.put(activeServer,siteData);
			}
		}
		
		//*** 2 : compose data to display *************************************
		DecimalFormat deci = new DecimalFormat("#,###");
		Iterator sitesIter;
		String sCity;						

		%>
		    "sites":{
		<%
		
		Iterator citiesIter = cities.keySet().iterator();
		while(citiesIter.hasNext()){
			sCity = (String)citiesIter.next();

			// sum sites in city
			sites = (SortedMap)cities.get(sCity);
			sitesIter = sites.keySet().iterator();
			while(sitesIter.hasNext()){
				siteData = (SiteData)sites.get(sitesIter.next());
					
				%>
				    "site":{
					  "city":"<%=sCity%>",
					  "id":"<%=siteData.id%>",
					  "date":"<%=ScreenHelper.stdDateFormat.format(siteData.date)%>",
					  "patients":"<%=deci.format(siteData.patients)%>",
					  "visits":"<%=deci.format(siteData.visits)%>",
					  "admissions":"<%=deci.format(siteData.admissions)%>",
					  "labs":"<%=deci.format(siteData.labs)%>",
					  "invoices":"<%=deci.format(siteData.invoices)%>",
				      "debets":"<%=deci.format(siteData.debets)%>",
				      "softwareversion":"<%=siteData.softwareversion%>"
				    },
				}
				<%
			}
		}

		%>
		    }
		<%
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

