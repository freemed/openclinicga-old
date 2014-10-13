<%@page import="java.util.Vector,
                java.util.Hashtable,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindLastname   = checkString(request.getParameter("FindLastname")),
           sFindFirstname  = checkString(request.getParameter("FindFirstname")),
           sFindDOB        = checkString(request.getParameter("FindDOB")),
           sFindGender     = checkString(request.getParameter("FindGender")),
           sReturnPersonID = checkString(request.getParameter("ReturnPersonID")),
           sPersonID       = checkString(request.getParameter("PersonID"));

    if(sReturnPersonID.length()==0){
        sReturnPersonID = checkString(request.getParameter("ReturnField"));
    }

    boolean bIsUser = checkString(request.getParameter("isUser")).equalsIgnoreCase("yes");
    boolean displayImmatNew = !checkString(request.getParameter("displayImmatNew")).equalsIgnoreCase("no");

    String sSelectLastname  = ScreenHelper.normalizeSpecialCharacters(sFindLastname),
           sSelectFirstname = ScreenHelper.normalizeSpecialCharacters(sFindFirstname);
%>

<table width="100%" cellspacing="0" cellpadding="0">
    <%
        Vector vPersons = new Vector();
    	if(!bIsUser && sPersonID.length()>0){
    		AdminPerson person = AdminPerson.getAdminPerson(sPersonID);
    		
    		if(person!=null && person.lastname!=null && person.lastname.length()>0){
                Hashtable hInfo = new Hashtable();
                hInfo.put("personid",ScreenHelper.checkString(sPersonID));
                hInfo.put("dateofbirth",ScreenHelper.checkString(person.dateOfBirth));
                hInfo.put("gender",ScreenHelper.checkString(person.gender));
                hInfo.put("lastname",ScreenHelper.checkString(person.lastname));
                hInfo.put("firstname",ScreenHelper.checkString(person.firstname));
                hInfo.put("immatnew",ScreenHelper.checkString(person.getID("immatnew")));

                vPersons.addElement(hInfo);
    		}
    	}
    	else {
    		vPersons = AdminPerson.searchPatients(sSelectLastname, sSelectFirstname, sFindGender, sFindDOB, bIsUser);
    	}
        Iterator personIter = vPersons.iterator();

        Hashtable hPersonInfo;
        if ((sSelectLastname.length() > 0 || sSelectFirstname.length() > 0 || sFindGender.length() > 0 || sFindDOB.length() > 0) || bIsUser || sPersonID.length()>0) {
            String sClass = "", sLastname, sFirstname;
            boolean recsFound = false;
            StringBuffer results = new StringBuffer();

            while (personIter.hasNext()) {
                hPersonInfo = (Hashtable) personIter.next();
                recsFound = true;

                // alternate row-style
                if(sClass.equals("")) sClass = "1";
                else                  sClass = "";

                // names
                sLastname = (String) hPersonInfo.get("lastname");
                sFirstname = (String) hPersonInfo.get("firstname");
                if(displayImmatNew){
                    sFirstname += " " + hPersonInfo.get("immatnew");
                }
                sLastname = sLastname.replace('\'', '´');
                sFirstname = sFirstname.replace('\'', '´');

                // one row
                if
                (bIsUser) {
                    results.append("<tr class='list" + sClass + "' onclick=\"setPerson(" + hPersonInfo.get("userid") + ", '" + sLastname + " " + sFirstname + "');\">")
                            .append("<td>" + hPersonInfo.get("userid")+"</td>")
                            .append("<td>" + sLastname + " " + sFirstname + " (" + hPersonInfo.get("userid") + ")</td>")
                            .append("<td>" + ((String) hPersonInfo.get("gender")).toUpperCase() + "</td>")
                            .append("<td colspan='2'>" + hPersonInfo.get("dateofbirth") + "</td>")
                            .append("</tr>");
                } 
                else {
                    results.append("<tr class='list" + sClass + "' onclick=\"setPerson(" + hPersonInfo.get("personid") + ", '" + sLastname + " " + sFirstname + "');\">")
                            .append("<td>" + hPersonInfo.get("personid") + "</td>")
                            .append("<td>" + sLastname + " " + sFirstname + "</td>")
                            .append("<td>" + ((String) hPersonInfo.get("gender")).toUpperCase() + "</td>")
                            .append("<td colspan='2'>" + hPersonInfo.get("dateofbirth") + "</td>")
                            .append("</tr>");
                }

            }
            
            if(recsFound){
			    %>
			    <%-- header --%>
			    <tr class="admin">
			        <td nowrap><%=HTMLEntities.htmlentities(getTran("Web", "personid", sWebLanguage))%></td>
			        <td nowrap><%=HTMLEntities.htmlentities(getTran("Web", "name", sWebLanguage))%></td>
			        <td width="50" nowrap><%=HTMLEntities.htmlentities(getTran("Web", "gender", sWebLanguage))%></td>
			        <td width="110" nowrap><%=HTMLEntities.htmlentities(getTran("Web", "dateofbirth", sWebLanguage))%></td>
			    </tr>
			
			    <tbody class="hand">
			        <%=HTMLEntities.htmlentities(results.toString())%>
			    </tbody>
			    <%
		    }
		    else{
		        // display 'no results' message
		        %>
		        <tr>
		            <td colspan="3">
		                <%=HTMLEntities.htmlentities(getTran("web", "norecordsfound", sWebLanguage))%><br>
		                <a href="javascript:addPerson()"><%=HTMLEntities.htmlentities(getTranNoLink("web", "add.this.person", sWebLanguage))%></a>
		            </td>
		        </tr>
		        <%
		    }
		}
	%>
</table>