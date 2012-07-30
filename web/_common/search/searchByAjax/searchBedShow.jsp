<%@ page
        import="be.mxs.common.util.system.HTMLEntities,be.openclinic.adt.Bed,be.openclinic.adt.Encounter,java.util.Vector,java.util.Hashtable" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%!
    public String createEncounterInfo(String sEncounterUID, String sLanguage, Connection dbConnection) {
        String sOutput;

        Encounter eTmp;
        String sBegin, sEnd;

        eTmp = Encounter.get(sEncounterUID);

        if (eTmp.getBegin() != null) {
            sBegin = new SimpleDateFormat("dd/MM/yyyy").format(eTmp.getBegin());
        } else {
            sBegin = "";
        }

        if (eTmp.getEnd() != null) {
            sEnd = new SimpleDateFormat("dd/MM/yyyy").format(eTmp.getEnd());
        } else {
            sEnd = "";
        }
    	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();

        sOutput = "<table class='list' width='100%' cellspacing='1' cellpadding='0'>" +
                "<tr>" +
                "<td colspan='2'>" + writeTableHeader("Web.manage", "manageEncounters", sLanguage, "") + "</td>" +
                "</tr>" +
                "<tr>" +
                "<td class='admin'>" + getTran("Web", "type", sLanguage) + "</td>" +
                "<td class='admin2'>" + getTran("Web", checkString(eTmp.getType()), sLanguage) + "</td>" +
                "</tr>" +
                "<tr>" +
                "<td class='admin'>" + getTran("Web", "begindate", sLanguage) + "</td>" +
                "<td class='admin2'>" + sBegin + "</td>" +
                "</tr>" +
                "<tr>" +
                "<td class='admin'>" + getTran("Web", "enddate", sLanguage) + "</td>" +
                "<td class='admin2'>" + sEnd + "</td>" +
                "</tr>" +
                "<tr>" +
                "<td class='admin'>" + getTran("Web", "manager", sLanguage) + "</td>" +
                "<td class='admin2'>" +
                (checkString(eTmp.getManagerUID()).length() > 0 ? ScreenHelper.getFullPersonName("" + MedwanQuery.getInstance().getPersonIdFromUserId(Integer.parseInt(eTmp.getManagerUID())), ad_conn) : "") +
                "</td>" +
                "</tr>" +
                "<tr>" +
                "<td class='admin'>" + getTran("Web", "service", sLanguage) + "</td>" +
                "<td class='admin2'>" + getTran("Service", checkString(eTmp.getServiceUID()), sLanguage) + "</td>" +
                "</tr>" +
                "</table>";
                try{
                	ad_conn.close();
                }
                catch(Exception e){
                	e.printStackTrace();
                }
        return sOutput;
    }
%>
<%
    String sFindBedName = checkString(request.getParameter("FindBedName"));

    String sViewCode = checkString(request.getParameter("ViewCode"));
    String sServiceUID = checkString(request.getParameter("ServiceUID"));
    String sSelectBedName = ScreenHelper.normalizeSpecialCharacters(sFindBedName);
%>

<div class="search">
<table border='0' width='100%' cellspacing="0" cellpadding="0" class="list">
    <%
        String sortColumn = " OC_BED_NAME";
        Vector vBeds = new Vector();
        if(sSelectBedName.length()>0||sServiceUID.length()>0){
        	vBeds = Bed.selectBeds("", "", sSelectBedName, sServiceUID, "", "", sortColumn);
        }

        Iterator iter = vBeds.iterator();

        boolean recsFound = false;
        String sClass = "";
        String sClassOccupied;
        StringBuffer results = new StringBuffer();
        Hashtable hOccupiedInfo;
        Bed tmpBed;
        String sSelectable;
        String sPatientName = "";
        String sEncounterUid = "";
        Boolean bStatus;

        while (iter.hasNext()) {
            recsFound = true;
            tmpBed = (Bed) iter.next();

            // alternate row-style
            if (sClass.equals("")) sClass = "1";
            else sClass = "";

            hOccupiedInfo = tmpBed.isOccupied();
            bStatus = (Boolean) hOccupiedInfo.get("status");

            if (bStatus.booleanValue()) {
                //if occupied
                sEncounterUid = (String) hOccupiedInfo.get("encounterUid");
                if ((hOccupiedInfo.get("patientUid")).equals(activePatient.personid)) {
                    sSelectable = "onclick=\"setBed('" + tmpBed.getUid() + "', '" + tmpBed.getName().toUpperCase() + "');\"";
                } else {
                    sSelectable = "";//onclick=\"editEncounter('" + sEncounterUid + "');\"";
                }

            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                sPatientName = ScreenHelper.getFullPersonName((String) hOccupiedInfo.get("patientUid"), ad_conn);
                ad_conn.close();
                sClassOccupied = "occupied";
            } else {
                //if not occupied
                sSelectable = "onclick=\"setBed('" + tmpBed.getUid() + "', '" + tmpBed.getName().toUpperCase() + "');\"";
                sClassOccupied = "";
            }

            results.append("<tr");

            if (sClassOccupied.equals("")) {
                sIcon = "";
                results.append(" class='list" + sClass + "'><td/>");
                results.append("<td/>");
            } else {
                sIcon = "<img src='" + sCONTEXTPATH + "/_img/menu_tee_plus.gif' onclick='toggleBedInfo(\"" + tmpBed.getUid() + "\");'"
                        + " alt='" + getTran("Web.Occup", "medwan.common.open", sWebLanguage) + "'>";
                results.append(" class='list" + sClassOccupied + sClass + "'><td>"
                        + "<img src='" + sCONTEXTPATH + "/_img/icon_edit.gif' alt='" + getTran("Web", "edit", sWebLanguage) + "' onclick=\"editEncounter('" + sEncounterUid + "');\"></td>");
                results.append("<td>" + sIcon + "</td>");
            }

            results.append("<td " + sSelectable + ">" + tmpBed.getName().toUpperCase() + (sViewCode.equalsIgnoreCase("on") ? " (" + tmpBed.getUid() + ")" : "") + "</td>")
                    .append("<td " + sSelectable + ">" + sPatientName + "</td>")
                    .append("</tr>");
            if (bStatus.booleanValue()) {
                Connection oc_conn=MedwanQuery.getInstance().getOpenclinicConnection();
                results.append(
                        "<tr id='" + tmpBed.getUid() + "' style='display: none;'>" +
                                "<td/>" +
                                "<td/>" +
                                "<td colspan='2'>" +
                                createEncounterInfo(sEncounterUid, sWebLanguage, oc_conn) +
                                "</td>" +
                                "</tr>");
                oc_conn.close();
            }
            sPatientName = "";
        }

        if (recsFound) {
    %>
    <tr class="admin">
        <td width="20"/>
        <td width="20"/>
        <td width='100'><%=getTran("web", "bed", sWebLanguage)%>
        </td>
        <td><%=HTMLEntities.htmlentities(getTran("Web", "patient", sWebLanguage))%>
        </td>
    </tr>
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=HTMLEntities.htmlentities(results.toString())%>
    </tbody>
    <%
        }
    %>
</table>

<%
    if (!recsFound) {
        // display 'no results' message
%>
<div style='text-align:left;'><%=HTMLEntities.htmlentities(getTran("web", "norecordsfound", sWebLanguage))%>
</div>
<%
    }
%>
</div>
