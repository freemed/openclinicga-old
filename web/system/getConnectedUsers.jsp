<%@page import="java.util.*,java.text.*,net.admin.User,
                be.mxs.common.util.db.MedwanQuery,
                java.util.GregorianCalendar,
                java.util.Calendar,
                be.mxs.common.util.system.*,
                net.admin.system.AccessLog,
                uk.org.primrose.pool.core.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<table width='100%' class="list" cellpadding="0" cellspacing="1">
<%
    String sNoUsers = checkString(request.getParameter("nousers"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* system/getConnectedUsers.jsp *********************");
    	Debug.println("sNoUsers : "+sNoUsers+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    if(sNoUsers.length()==0){
%>
<tr>
	<td class='admin'><%=getTran("web","firstconnection",sWebLanguage)%></td>
	<td class='admin'><%=getTran("web","lastconnection",sWebLanguage)%></td>
	<td class='admin'><%=getTran("web","duration",sWebLanguage)%></td>
	<td class='admin'><%=getTran("web","inactif",sWebLanguage)%></td>
	<td class='admin'><%=getTran("web","ipaddress",sWebLanguage) %></td>
	<td class='admin'><%=getTran("web","browser",sWebLanguage) %></td>
	<td class='admin'><%=getTran("web","userid",sWebLanguage) %></td>
	<td class='admin'><%=getTran("web","user",sWebLanguage) %></td>
	<td class='admin'><%=getTran("web","profile",sWebLanguage) %></td>
	<td class='admin'><%=getTran("web","patient",sWebLanguage) %></td>
</tr>

<%
	Hashtable users = new Hashtable();
	Hashtable userprofiles = new Hashtable();
	Vector ups = UserProfile.getUserProfiles();
	for(int n=0; n<ups.size(); n++){
		UserProfile userProfile = (UserProfile)ups.elementAt(n);
		userprofiles.put(userProfile.getUserprofileid()+"",userProfile.getUserprofilename());
	}
	
	Hashtable sessions = MedwanQuery.getSessions();
	SortedMap sortedSessions = new TreeMap();
	Enumeration e = sessions.keys();
	while(e.hasMoreElements()){
		HttpSession s = (HttpSession)e.nextElement();
		try{
			if(s!=null){
				User user = (User)sessions.get(s);
				if(user!=null && user.person!=null){
					String sActivePatient = "-", profile = "-";
					
					AdminPerson ap = (AdminPerson)s.getAttribute("activePatient");
					if(ap!=null){
						sActivePatient = ap.lastname+", "+ap.firstname+" ("+ap.personid+")";
					}
					
					String browser = (String)s.getAttribute("mon_browser");
					if(browser.startsWith("Internet Explorer")){
						browser = "<img style='vertical-align:middle' src='"+sCONTEXTPATH+"/_img/ie.jpg' height='20px' width='20px'/> "+browser;
					}
					else if(browser.startsWith("Firefox")){
						browser = "<img style='vertical-align:middle' src='"+sCONTEXTPATH+"/_img/firefox.jpg' height='20px' width='20px'/> "+browser;
					} 
					else if(browser.startsWith("Opera")){
						browser = "<img style='vertical-align:middle' src='"+sCONTEXTPATH+"/_img/opera.jpg' height='20px' width='20px'/> "+browser;
					} 
					else if(browser.startsWith("Chrome")){
						browser = "<img style='vertical-align:middle' src='"+sCONTEXTPATH+"/_img/chrome.jpg' height='20px' width='20px'/> "+browser;
					} 
					else if(browser.startsWith("Safari")){
						browser = "<img style='vertical-align:middle' src='"+sCONTEXTPATH+"/_img/safari.jpg' height='20px' width='20px'/> "+browser;
					} 
					else{
						browser = "<img style='vertical-align:middle' src='"+sCONTEXTPATH+"/_img/globe.jpg' height='20px' width='20px'/> "+browser;
					} 
					
					if((new java.util.Date().getTime()-new Long(s.getLastAccessedTime()).longValue())<1200000){
						profile = checkString((String)userprofiles.get(user.getParameter("userprofileid"))).toUpperCase();
						if(profile.length()==0){
							profile = "-";
						}
						
						String line = s.getId()+";"+
									  user.userid+";"+
									  user.person.lastname+", "+user.person.firstname+";"+
									  ScreenHelper.fullDateFormatSS.format((java.util.Date)s.getAttribute("mon_start"))+";"+
									  s.getAttribute("mon_ipaddress")+";"+
									  browser+";"+
									  (new java.util.Date().getTime()-((java.util.Date)s.getAttribute("mon_start")).getTime())+";"+
									  sActivePatient.replaceAll(";"," ")+";"+
									  (new java.util.Date().getTime()-new Long(s.getLastAccessedTime()).longValue())+";"+
									  profile+";";
						sortedSessions.put(new Long(36000000-s.getLastAccessedTime()),line);
						users.put(user.userid,"1");
					}
					else{
						s.invalidate();
					}
				}
			}
		}
		catch(Exception e2){
			// invalid session
		}
	}
	
	Iterator iterator = sortedSessions.keySet().iterator();
	int counter = 0, expiring = 0;
	while(iterator.hasNext()){
		Long k = (Long)iterator.next();
		String u = (String)sortedSessions.get(k);
		
		long sss = Long.parseLong(u.split(";")[6]);
		long hh = (sss/1000)/3600;
		long mm = (sss/1000-hh*3600)/60;
		long ss = (sss/1000)%60;
		
		long sssd = Long.parseLong(u.split(";")[8]);
		long hhd = (sssd/1000)/3600;
		long mmd = (sssd/1000-hhd*3600)/60;
		long ssd = (sssd/1000)%60;
		counter++;
		
		if(hhd*60+mmd>=15){
			expiring++;
		}
		
		out.print("<tr>"+
		           "<td class='admin2'><a href='javascript:opensession(\""+u.split(";")[0]+"\");'>"+u.split(";")[3]+"</td>"+
		           "<td class='admin2'>"+ScreenHelper.fullDateFormatSS.format(new java.util.Date(36000000-k.longValue()))+"</td>"+
		           "<td class='admin2'>"+new DecimalFormat("#00").format(hh)+":"+new DecimalFormat("00").format(mm)+":"+new DecimalFormat("00").format(ss)+"</td>"+
		           "<td class='admin2'>"+(hhd*60+mmd>=15?"<font color='red'>":"")+new DecimalFormat("#00").format(hhd)+":"+new DecimalFormat("00").format(mmd)+":"+new DecimalFormat("00").format(ssd)+(hhd*60+mmd>=15?"</font>":"")+"</td>"+
		           "<td class='admin2'>"+u.split(";")[4]+"</td>"+
		           "<td class='admin2' nowrap>"+u.split(";")[5]+"</td>"+
		           "<td class='admin2'>"+u.split(";")[1]+"</td>"+
		           "<td class='admin2'><b>"+u.split(";")[2]+"</b></td>"+
		           "<td class='admin2'>"+u.split(";")[9]+"</td>"+
		           "<td class='admin2'><i>"+u.split(";")[7]+"</i></td>"+
		          "</tr>");		
	}
%>
</table>
<div style="padding-top:5px;"></div>

<table width='100%' class="list" cellpadding="0" cellspacing="0">
<tr>
	<td class='admin2' width='33%'><center><%=getTran("web","total_active_sessions",sWebLanguage)%>: <%=counter%></center></td>
	<td class='admin2' width='33%'><center><%=getTran("web","total_expiring_users",sWebLanguage)%>: <%=expiring%></center></td>
	<td class='admin2' width='34%'><center><%=getTran("web","total_active_logins",sWebLanguage)%>: <%=users.size()%></center></td>
</tr>
</table>
<div style="padding-top:5px;"></div>
<%
    }
%>
<table width='100%' class="list" cellpadding="0" cellspacing="0">
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_server_memory",sWebLanguage)%>: <%=new DecimalFormat("#,###").format(Runtime.getRuntime().totalMemory()/1048576)%> Mb</center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","free_server_memory",sWebLanguage)%>: <%=new DecimalFormat("#,###").format(Runtime.getRuntime().freeMemory()/1048576)%> Mb</center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","max_server_memory",sWebLanguage)%>: <%=new DecimalFormat("#,###").format(Runtime.getRuntime().maxMemory()/1048576)%> Mb</center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","available_processors",sWebLanguage)%>: <%=Runtime.getRuntime().availableProcessors()%></center></td>
</tr>
</table>
<div style="padding-top:5px;"></div>
<%
	if(MedwanQuery.getInstance().getConfigInt("enableMonitorMiniStats",0)==1 || sNoUsers.length()>0){
		// admin-conn
		Connection conn = MedwanQuery.getInstance().getAdminConnection();
		PreparedStatement ps = conn.prepareStatement("select count(*) total from Admin");
		ResultSet rs = ps.executeQuery();
		rs.next();
		int totalpatients = rs.getInt("total");
		rs.close();
		ps.close();
		
		ps = conn.prepareStatement("select count(*) total from admin where archivefilecode is not null and archivefilecode<>''");
		rs = ps.executeQuery();
		rs.next();
		int totalarchivedpatients = rs.getInt("total");
		rs.close();
		ps.close();
		conn.close();

		// oc-conn
		conn = MedwanQuery.getInstance().getOpenclinicConnection();
		ps = conn.prepareStatement("select count(*) total from OC_ENCOUNTERS");
		rs = ps.executeQuery();
		rs.next();
		int totalencounters = rs.getInt("total");
		rs.close();
		ps.close();
		
		ps = conn.prepareStatement("select count(*) total from OC_PATIENTINVOICES");
		rs = ps.executeQuery();
		rs.next();
		int totalpatientinvoices = rs.getInt("total");
		rs.close();
		ps.close();
		
		ps = conn.prepareStatement("select count(*) total from OC_DEBETS");
		rs = ps.executeQuery();
		rs.next();
		int totaldebets = rs.getInt("total");
		rs.close();
		ps.close();
		conn.close();
%>
<table width='100%' class="list" cellpadding="0" cellspacing="1">
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_patients",sWebLanguage)%>: <%=new DecimalFormat("#,###").format(totalpatients)%></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_encounters",sWebLanguage)%>: <%=new DecimalFormat("#,###").format(totalencounters)%></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_patientinvoices",sWebLanguage)%>: <%=new DecimalFormat("#,###").format(totalpatientinvoices)%></center></td>
	<td class='admin2' width='25%'><center><%=getTran("web","total_debets",sWebLanguage)%>: <%=new DecimalFormat("#,###").format(totaldebets)%></center></td>
</tr>
<tr>
	<td class='admin2' width='25%'><center><%=getTran("web","total_archived_patients",sWebLanguage)%>: <%=new DecimalFormat("#,###").format(totalarchivedpatients)%></center></td>
	<td class='admin2' colspan='3'></td>
</tr>
<%
	}
%>
</table>

<script>
function opensession(id){
  openPopup("system/getSessionAttributes.jsp&ts=<%=getTs()%>&sessionid="+id,400,300);
}
</script>