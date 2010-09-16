<%@page import="be.openclinic.finance.PatientCredit,
                java.util.*,
                be.openclinic.adt.Encounter,
                java.text.DecimalFormat,
                be.mxs.common.util.system.HTMLEntities,be.openclinic.finance.PatientInvoice" %>
<%@ page import="be.openclinic.finance.WicketCredit" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    //--- ADD UNASSIGNED CREDITS ------------------------------------------------------------------
    private String addUnassignedCredits(Vector vCredits, String sWebLanguage) {

        DecimalFormat priceFormat = new DecimalFormat("#,##0.00");
        String sHtml = "";
        String sClass = "";

        if (vCredits != null) {
            PatientCredit credit;
            Encounter encounter;
            String sEncounterName, sCreditUid, sCreditType;
            Hashtable hSort = new Hashtable();
            String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");
            for (int i = 0; i < vCredits.size(); i++) {
                sCreditUid = checkString((String) vCredits.elementAt(i));

                if (sCreditUid.length() > 0) {
                    credit = PatientCredit.get(sCreditUid);

                    if (credit != null) {
                        // type
                        if (credit.getType()!=null && checkString(credit.getType()).length() > 0) {
                            sCreditType = getTranNoLink("credit.type", credit.getType(), sWebLanguage);
                        } else {
                            sCreditType = "";
                        }

                        // get encounter
                        sEncounterName = "";
                        if (credit.getEncounterUid()!=null && checkString(credit.getEncounterUid()).length() > 0) {
                            encounter = credit.getEncounter();
                            if (encounter != null) {
                                sEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
                            }
                        }
                        String invoiceref="-";
                        if (credit.getInvoiceUid()!=null && ScreenHelper.checkString(credit.getInvoiceUid()).length() > 0 && !ScreenHelper.checkString(credit.getInvoiceUid()).equalsIgnoreCase("0")) {
                            PatientInvoice invoice = PatientInvoice.get(credit.getInvoiceUid());
                            if(invoice!=null && invoice.getUid()!=null){
                                invoiceref=invoice.getUid().split("\\.")[1]+" ("+new DecimalFormat("###,###,###,###").format(-invoice.getBalance())+" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+")";
                            }
                        }
                        String wicketUid="";
                        WicketCredit wicketCredit = WicketCredit.getByReferenceUid(credit.getUid());
                        if(wicketCredit!=null && wicketCredit.getUid()!=null && wicketCredit.getUid().length()>1){
                            wicketUid=wicketCredit.getWicketUID();
                        }

                        hSort.put(credit.getDate().getTime() + "=" + credit.getUid(),
                                " onclick=\"selectCredit('" + credit.getUid() + "','" + ScreenHelper.formatDate(credit.getDate()) + "','" + credit.getAmount() + "','" + credit.getType() + "','" + credit.getEncounterUid() + "','" + HTMLEntities.htmlentities(sEncounterName) + "','" + HTMLEntities.htmlentities(ScreenHelper.checkString(credit.getComment()).replaceAll("'","´")) + "','"+checkString(credit.getInvoiceUid())+"','"+wicketUid+"');\">" +
                                        "<td><b>" + credit.getUid().split("\\.")[1] + "</b>&nbsp;</td>" +
                                        "<td>" + ScreenHelper.formatDate(credit.getDate()) + "</td>" +
                                        "<td>" + HTMLEntities.htmlentities(sEncounterName) + "</td>" +
                                        "<td align='right'>" + HTMLEntities.htmlentities(priceFormat.format(credit.getAmount())) + "&nbsp;" + sCurrency + "&nbsp;&nbsp;</td>" +
                                        "<td>" + HTMLEntities.htmlentities(sCreditType) + "</td>" +
                                        "<td>" + HTMLEntities.htmlentities(invoiceref) + "</td>" +
                                        "<td>" + HTMLEntities.htmlentities(ScreenHelper.checkString(credit.getComment()).replaceAll("'","´")) + "</td>" +
                                        "</tr>"
                        );

                    }
                }
            }

            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Collections.reverse(keys);
            Iterator iter = keys.iterator();

            while (iter.hasNext()) {
                // alternate row-style
                if (sClass.equals("")) sClass = "1";
                else sClass = "";

                sHtml += "<tr class='list" + sClass + "' onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list" + sClass + "';\"" +
                        hSort.get(iter.next());
            }
        }

        return sHtml;
    }
%>

<%
    String sEncounterUID = ScreenHelper.checkString(request.getParameter("encounterUID"));
    String sFindDateBegin = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax = checkString(request.getParameter("FindAmountMax"));
    Vector vCredits = new Vector();
    if(sEncounterUID.length()>0){
        if ((sFindDateBegin.length()==0)&&(sFindDateEnd.length()==0)&&(sFindAmountMin.length()==0)&&(sFindAmountMax.length()==0)){
            vCredits=PatientCredit.getEncounterCredits(sEncounterUID);
        }
        else {
            vCredits = PatientCredit.getPatientCredits(activePatient.personid,sFindDateBegin,sFindDateEnd,sFindAmountMin, sFindAmountMax);
        }
    }

    if(vCredits.size() > 0){
        %>
            <table width="100%" class="list" cellspacing="0" style="border:none;">
                <%-- header --%>
                <tr class="admin">
                    <td colspan="7"><%=HTMLEntities.htmlentities(getTran("web","paymentsforencounter",sWebLanguage))+" #"+sEncounterUID%></td>
                </tr>
                <tr class="admin">
                    <td width="20">#</td>
                    <td width="80"><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
                    <td width="30%"><%=HTMLEntities.htmlentities(getTran("web.finance","encounter",sWebLanguage))%></td>
                    <td width="100" align="right"><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%>&nbsp;&nbsp;</td>
                    <td width="200"><%=HTMLEntities.htmlentities(getTran("web","type",sWebLanguage))%></td>
                    <td width="200"><%=HTMLEntities.htmlentities(getTran("web","invoice",sWebLanguage))%></td>
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