<%@page import="be.openclinic.finance.PatientCredit,
                java.util.*,
                be.openclinic.adt.Encounter,
                java.text.DecimalFormat,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    DecimalFormat priceFormat = new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#,##0.00"));

    //--- ADD UNASSIGNED CREDITS ------------------------------------------------------------------
    private String addUnassignedCredits(Vector vCredits, String sWebLanguage) {
        String sHtml = "";
        String sClass = "";

        if(vCredits != null){
            PatientCredit credit;
            Encounter encounter;
            String sEncounterName, sCreditUid, sCreditType;
            Hashtable hSort = new Hashtable();
            String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");

            for(int i=0; i<vCredits.size(); i++){
                sCreditUid = checkString((String)vCredits.elementAt(i));

                if(sCreditUid.length() > 0){
                    credit = PatientCredit.get(sCreditUid);

                    if(credit != null){
                        // type
                        if(checkString(credit.getType()).length() > 0){
                            sCreditType = getTranNoLink("credit.type",credit.getType(),sWebLanguage);
                        }
                        else{
                            sCreditType = "";
                        }

                        // get encounter
                        sEncounterName = "";
                        if(checkString(credit.getEncounterUid()).length() > 0){
                            encounter = credit.getEncounter();
                            if(encounter != null){
                                sEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
                            }
                        }

                        hSort.put(credit.getDate().getTime()+"="+credit.getUid(),
                                   " onclick=\"selectCredit('"+credit.getUid()+"','"+ScreenHelper.formatDate(credit.getDate())+"','"+credit.getAmount()+"','"+credit.getType()+"','"+credit.getEncounterUid()+"','"+HTMLEntities.htmlentities(sEncounterName)+"','"+HTMLEntities.htmlentities(credit.getComment())+"');\">"+
                                   "<td>"+ScreenHelper.formatDate(credit.getDate())+"</td>"+
                                   "<td>"+HTMLEntities.htmlentities(sEncounterName)+"</td>"+
                                   "<td align='right'>"+priceFormat.format(credit.getAmount())+"&nbsp;"+sCurrency+"&nbsp;&nbsp;</td>"+
                                   "<td>"+HTMLEntities.htmlentities(sCreditType)+"</td>"+
                                   "<td>"+HTMLEntities.htmlentities(credit.getComment())+"</td>"+
                                  "</tr>"
                                 );
                    }
                }
            }

            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Iterator iter = keys.iterator();

            while(iter.hasNext()){
                // alternate row-style
                if(sClass.equals("")) sClass = "1";
                else                  sClass = "";

                sHtml+= "<tr class='list"+sClass+"' onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list"+sClass+"';\"" +
                          hSort.get(iter.next());
            }
        }
        
        return sHtml;
    }
%>

<%

    Vector vCredits = PatientCredit.getUnassignedPatientCredits(activePatient.personid);

    if(vCredits.size() > 0){
        %>
            <table width="100%" class="list" cellspacing="0" style="border:none;">
                <%-- header --%>
                <tr class="admin">
                    <td width="80"><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
                    <td width="30%"><%=HTMLEntities.htmlentities(getTran("web.finance","encounter",sWebLanguage))%></td>
                    <td width="100" align="right"><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%>&nbsp;&nbsp;</td>
                    <td width="200"><%=HTMLEntities.htmlentities(getTran("web","type",sWebLanguage))%></td>
                    <td width="*"><%=HTMLEntities.htmlentities(getTran("web","description",sWebLanguage))%></td>
                </tr>

                <tbody onmouseover="this.style.cursor='hand';" onmouseout="this.style.cursor='default';">
                    <%=addUnassignedCredits(vCredits,sWebLanguage)%>
                </tbody>
            </table>
        <%
    }
    else{
        %><%=HTMLEntities.htmlentities(getTranNoLink("web","noRecordsFound",sWebLanguage))%><%
    }
%>