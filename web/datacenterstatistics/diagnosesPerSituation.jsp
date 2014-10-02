<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sBegin = request.getParameter("begin");
    if(sBegin==null){
        sBegin="01/01/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
    String sEnd = request.getParameter("end");
    if(sEnd==null){
        sEnd="31/12/"+new SimpleDateFormat("yyyy").format(new java.util.Date());
    }
%>
<%=sJSDATE%>
<form method="post" name="statForm" id="serviceIncome">
    <table>
        <tr>
            <td class="admin">
                <%=getTran("web","from",sWebLanguage)%>&nbsp;</td><td class="admin2"><%=writeDateField("begin","statForm",sBegin,sWebLanguage)%>&nbsp;<%=getTran("web","to",sWebLanguage)%>&nbsp;<%=writeDateField("end","statForm",sEnd,sWebLanguage)%>&nbsp;
            </td>
        </tr>
        <tr>
            <td class="admin">
                <%=getTran("web","diagnosis",sWebLanguage)%>&nbsp;</td><td class="admin2">
                <select name="codetype" class="text">
                    <option value="icpc" <%="icpc".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTranNoLink("web","icpc",sWebLanguage)%></option>
                    <option value="icd10" <%="icd10".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTranNoLink("web","icd10",sWebLanguage)%></option>
                    <option value="icpcgroups" <%="icpcgroups".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTranNoLink("web","icpcgroups",sWebLanguage)%></option>
                    <option value="icd10groups" <%="icd10groups".equalsIgnoreCase(request.getParameter("codetype"))?" selected":""%>><%=getTranNoLink("web","icd10groups",sWebLanguage)%></option>
                </select>
                <input type='text' class='text' name='diagnosis'/>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","situation",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="situation" style="vertical-align:top;">
                    <%=ScreenHelper.writeSelectUnsorted("encounter.situation","",sWebLanguage)%>
                </select>
            </td>
        </tr>
        <tr>
        	<td colspan="2">
				<input type="submit" class="button" name="find" value="<%=getTranNoLink("web","find",sWebLanguage)%>"/>
        	</td>
        </tr>
    </table>
</form>
<table width="100%">
<%
    if(request.getParameter("find")!=null){
        java.util.Date begin=ScreenHelper.parseDate(request.getParameter("begin"));
        java.util.Date end=ScreenHelper.parseDate(request.getParameter("end"));
        String codetype = request.getParameter("codetype");
        String diagnosis = request.getParameter("diagnosis");
        String situation = request.getParameter("situation");

        //We zoeken alle debets op van de betreffende periode en ventileren deze per dienst
        String sQuery="select distinct personid,firstname,lastname,oc_encounter_serverid,oc_encounter_objectid,oc_encounter_begindate,oc_encounter_enddate"+
        	" from oc_diagnoses a,oc_encounters b,adminview c"+
        	" where"+
        	" b.oc_encounter_patientuid=c.personid and"+
        	" a.oc_diagnosis_encounterobjectid=b.oc_encounter_objectid and"+
        	" b.oc_encounter_situation=? and"+
        	" a.oc_diagnosis_date between ? and ? and"+
        	" a.oc_diagnosis_codetype=? and"+
        	" a.oc_diagnosis_code like ?"+
        	" order by oc_encounter_begindate";
        Connection loc_conn=MedwanQuery.getInstance().getLongOpenclinicConnection();
        PreparedStatement ps = loc_conn.prepareStatement(sQuery);
        ps.setString(1,situation);
        ps.setDate(2,new java.sql.Date(begin.getTime()));
        ps.setDate(3,new java.sql.Date(end.getTime()));
        ps.setString(4,codetype);
        ps.setString(5,diagnosis+"%");
        ResultSet rs =ps.executeQuery();
		while(rs.next()){
			java.util.Date enddate=rs.getDate("oc_encounter_enddate");
			String personid=rs.getString("personid");
			out.println("<tr class='admin'><td>"+personid+"</td><td><a href='javascript:openpatientrecord("+personid+")'>"+rs.getString("firstname").toUpperCase()+" "+rs.getString("lastname").toUpperCase()+
					"</a></td><td>"+ScreenHelper.stdDateFormat.format(rs.getDate("oc_encounter_begindate"))+"-"+(enddate==null?"?":ScreenHelper.stdDateFormat.format(enddate))+"</td></tr>");
		}
        rs.close();
        ps.close();
        loc_conn.close();
    }
%>
</table>
<script>
    function openpatientrecord(personid) {
        window.open("<c:url value='main.jsp?Page=curative/index.jsp'/>&ts=<%=getTs()%>&PersonID="+personid, "Popup" + new Date().getTime(), "toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=800,height=600,menubar=no").moveTo((screen.width - 800) / 2, (screen.height - 600) / 2);
    }
</script>