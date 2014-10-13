<%@ page import="be.openclinic.finance.Debet,java.util.*,be.openclinic.finance.Prestation,be.openclinic.adt.Encounter,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    private String addDebets(Vector vDebets, String sClass, String sWebLanguage) {
        String sReturn = "";

        if (vDebets != null) {
            Debet debet;
            Encounter encounter=null;
            Prestation prestation=null;	
            String sEncounterName, sPrestationDescription, sDebetUID, sPatientName;
            String sCredited;
            Hashtable hSort = new Hashtable();

            for (int i = 0; i < vDebets.size(); i++) {
                sDebetUID = checkString((String) vDebets.elementAt(i));

                if (sDebetUID.length() > 0) {
                    debet = Debet.get(sDebetUID);

                    if (debet != null) {
                        sEncounterName = "";
                        sPatientName = "";

                        if (checkString(debet.getEncounterUid()).length() > 0) {
                            encounter = debet.getEncounter();

                            if (encounter != null) {
                                sEncounterName = getTran("web","insurance.coverage",sWebLanguage);
                            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                                sPatientName = ScreenHelper.getFullPersonName(encounter.getPatientUID(), ad_conn);
                                try{
                                	ad_conn.close();
                                }
                                catch(Exception e){
                                	e.printStackTrace();
                                }
                            }
                        }

                        sPrestationDescription = "";

                        if (checkString(debet.getPrestationUid()).length() > 0) {
                            prestation = debet.getPrestation();

                            if (prestation != null) {
                                sPrestationDescription = checkString(prestation.getDescription());
                            }
                        }

                        sCredited = "";

                        if (debet.getCredited() > 0) {
                            sCredited = getTran("web.occup", "medwan.common.yes", sWebLanguage);
                        }
                        hSort.put(sPatientName.toUpperCase() + "=" + debet.getDate().getTime() + "=" + debet.getUid(), " onclick=\"setDebet('" + debet.getUid() + "');\">"
                                + "<td>" + ScreenHelper.getSQLDate(debet.getDate()) + "</td>"
                                + "<td>" + HTMLEntities.htmlentities(sEncounterName) + " ("+MedwanQuery.getInstance().getUser(debet.getUpdateUser()).getPersonVO().getFullName()+")</td>"
                                + "<td nowrap>" + debet.getQuantity()+" x "+HTMLEntities.htmlentities(sPrestationDescription) + "</td>"
                                + "<td "+(checkString(debet.getExtraInsurarUid()).length()>0?"style='text-decoration: line-through'":"")+">" + (debet.getAmount()+debet.getExtraInsurarAmount()) + " " + MedwanQuery.getInstance().getConfigParam("currency", "€") + "</td>"
                                + "<td>" + sCredited + "</td>"
                                + "</tr>");
                    }
                }
            }

            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            Iterator it = keys.iterator();

            while (it.hasNext()) {
                if (sClass.equals("")) {
                    sClass = "1";
                } else {
                    sClass = "";
                }
                sReturn += "<tr class='list" + sClass
                        + "' " + hSort.get((String) it.next());
            }
        }
        return sReturn;
    }
%>
<table width="100%" cellspacing="0">
    <tr class="admin">
        <td><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web.finance","encounter",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","prestation",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","canceled",sWebLanguage))%></td>
    </tr>
    <tbody class="hand">
<%
    String sFindDateBegin = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax = checkString(request.getParameter("FindAmountMax"));

    Vector vUnassignedDebets;
    if ((sFindDateBegin.length()==0)&&(sFindDateEnd.length()==0)&&(sFindAmountMin.length()==0)&&(sFindAmountMax.length()==0)){
        vUnassignedDebets = Debet.getUnassignedPatientDebets(activePatient.personid);
    }
    else {
        vUnassignedDebets = Debet.getPatientDebets(activePatient.personid,sFindDateBegin,sFindDateEnd,sFindAmountMin, sFindAmountMax);
    }
	String s=addDebets(vUnassignedDebets, "", sWebLanguage);
    out.print(s);
%>
    </tbody>
</table>