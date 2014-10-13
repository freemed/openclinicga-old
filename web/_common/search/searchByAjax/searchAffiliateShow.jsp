<%@ page import="java.util.Vector,
                 java.util.Hashtable,
                 be.mxs.common.util.system.HTMLEntities,be.openclinic.finance.*" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%
    String sFindLastname = checkString(request.getParameter("FindLastname")),
           sFindFirstname = checkString(request.getParameter("FindFirstname")),
           sFindDOB = checkString(request.getParameter("FindDOB")),
           sFindGender = checkString(request.getParameter("FindGender")),
           sFindInsuranceNr = checkString(request.getParameter("EditInsuranceNr")),
           sExclude = checkString(request.getParameter("exclude")),
           sFindInsurarUID = checkString(request.getParameter("EditInsurarUID"));

	String sInsurarName="";
	if(sFindInsurarUID.length()>0){
		Insurar insurar = Insurar.get(sFindInsurarUID);
		if(insurar!=null){
			sInsurarName=insurar.getName();
		}
	}

    boolean displayImmatNew = !checkString(request.getParameter("displayImmatNew")).equalsIgnoreCase("no");

    String sSelectLastname = ScreenHelper.normalizeSpecialCharacters(sFindLastname),
            sSelectFirstname = ScreenHelper.normalizeSpecialCharacters(sFindFirstname);
%>
<table width="100%" cellspacing="0" cellpadding="0">
    <%
        Vector vPersons = new Vector();
        Hashtable hPersonInfo;
        if ((sSelectLastname.length() > 0 || sSelectFirstname.length() > 0 || sFindGender.length() > 0 || sFindDOB.length() > 0 || sFindInsurarUID.length() > 0)) {
        	vPersons=AdminPerson.searchAffiliates(sSelectLastname, sSelectFirstname, sFindGender, sFindDOB, sFindInsurarUID,sFindInsuranceNr);
            Iterator personIter = vPersons.iterator();
        	String sClass = "", sLastname, sFirstname,sInsuranceNr,sEmployer,sPersonid;
            boolean recsFound = false;
            StringBuffer results = new StringBuffer();

            while (personIter.hasNext()) {
                hPersonInfo = (Hashtable) personIter.next();
                recsFound = true;

                // alternate row-style
                if (sClass.equals("")) sClass = "1";
                else sClass = "";

                // names
				sPersonid=(String)hPersonInfo.get("personid");
                sLastname = (String) hPersonInfo.get("lastname");
                sFirstname = (String) hPersonInfo.get("firstname");
                sInsuranceNr=(String) hPersonInfo.get("insurancenr");
                sEmployer=(String)hPersonInfo.get("employer");
                sLastname = sLastname.replace('\'', '´');
                sFirstname = sFirstname.replace('\'', '´');
				if(!sPersonid.equalsIgnoreCase(sExclude)){
	                results.append("<tr class='list" + sClass + "' onclick=\"setPerson(" + sPersonid + ", '" + sLastname.toUpperCase() + ", " + sFirstname + "','"+sEmployer+"','"+sInsuranceNr+"');\">")
	                        .append("<td><a href='#'>" + sLastname + " " + sFirstname+"</a></td>")
	                        .append("<td>"+sInsuranceNr+"</td>")
	                        .append("<td>" + ((String) hPersonInfo.get("gender")).toUpperCase() + "</td>")
	                        .append("<td colspan='2'>" + hPersonInfo.get("dateofbirth") + "</td>")
	                        .append("</tr>");
				}

            }
            if (recsFound) {
    %>
    <%-- header --%>
    <tr class="admin">
        <td colspan='4'><%=HTMLEntities.htmlentities(getTran("Web", "affiliates.for.insurer", sWebLanguage))%> <%=sInsurarName.length()==0?"?":sInsurarName %> <%=HTMLEntities.htmlentities(getTran("Web", "and", sWebLanguage))%> <%=HTMLEntities.htmlentities(getTran("Web", "insurancenumber", sWebLanguage))%> <%=sFindInsuranceNr.length()==0?"?":sFindInsuranceNr %></td>
    </tr>
    <tr class="admin">
        <td nowrap><%=HTMLEntities.htmlentities(getTran("Web", "name", sWebLanguage))%></td>
        <td nowrap><%=HTMLEntities.htmlentities(getTran("Web", "insurancenr", sWebLanguage))%></td>
        <td width="50" nowrap><%=HTMLEntities.htmlentities(getTran("Web", "gender", sWebLanguage))%></td>
        <td width="110" nowrap><%=HTMLEntities.htmlentities(getTran("Web", "dateofbirth", sWebLanguage))%></td>
    </tr>

    <tbody class="hand">
        <%=HTMLEntities.htmlentities(results.toString())%>
    </tbody>
    <%
    } else {
        // display 'no results' message
    %>
    <tr>
        <td colspan="3">
            <%=HTMLEntities.htmlentities(getTran("web", "norecordsfound", sWebLanguage))%><br>
        </td>
    </tr>
    <%
            }
        }
    %>
</table>
