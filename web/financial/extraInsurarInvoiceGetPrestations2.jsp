<%@ page import="be.openclinic.finance.*,be.openclinic.adt.Encounter,java.util.*,be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.Date" %>
<%@ page import="be.openclinic.finance.ExtraInsurarInvoice2" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    private String addDebets(Vector vDebets, String sClass, String sWebLanguage, boolean bChecked) {
        StringBuffer sReturn = new StringBuffer();

        if (vDebets != null) {
            Debet debet;
            Prestation prestation;
            String sEncounterName, sPrestationDescription, sPatientName,sDate;
            String oldname="",oldencounter="",olddate="";
            String sChecked = "";
            Hashtable hSort = new Hashtable();

            if (bChecked) {
                sChecked = " checked";
            }

            //Firts we will sort the records
            for (int i=0;i<vDebets.size(); i++){
                debet = (Debet) vDebets.elementAt(i);
                if(debet!=null){
                    hSort.put(debet.getPatientName()+"="+debet.getDate().getTime() + "=" + debet.getUid(),debet);
                }
            }
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Iterator it = keys.iterator();

            while (it.hasNext()){
                debet = (Debet) hSort.get(it.next());

                if (checkString(debet.getUid()).length() > 0) {

                    if (debet != null) {
                        if(!oldname.equalsIgnoreCase(debet.getPatientName())){
                            sPatientName = debet.getPatientName();
                            oldname=sPatientName;
                            if (debet.getEncounter()!=null){
                                sEncounterName=debet.getEncounter().getEncounterDisplayName(sWebLanguage);
                            }
                            else{
                                sEncounterName=debet.getEncounterUid();
                            }
                            oldencounter=sEncounterName;
                            sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
                            olddate=sDate;
                        }
                        else {
                            sPatientName="";
                            if(!oldencounter.equalsIgnoreCase(debet.getEncounter().getEncounterDisplayName(sWebLanguage))){
                                sPatientName = debet.getPatientName();
                                oldname=sPatientName;
                                if (debet.getEncounter()!=null){
                                    sEncounterName=debet.getEncounter().getEncounterDisplayName(sWebLanguage);
                                }
                                else{
                                    sEncounterName=debet.getEncounterUid();
                                }
                                oldencounter=sEncounterName;
                                sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
                                olddate=sDate;
                            }
                            else {
                                sEncounterName="";
                                if(!olddate.equalsIgnoreCase(ScreenHelper.stdDateFormat.format(debet.getDate()))){
                                    sPatientName = debet.getPatientName();
                                    oldname=sPatientName;
                                    if (debet.getEncounter()!=null){
                                        sEncounterName=debet.getEncounter().getEncounterDisplayName(sWebLanguage);
                                    }
                                    else{
                                        sEncounterName=debet.getEncounterUid();
                                    }
                                    oldencounter=sEncounterName;
                                    sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
                                    olddate=sDate;
                                }
                                else {
                                    sDate="";
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

                        if (sClass.equals("")) {
                            sClass = "1";
                        } else {
                            sClass = "";
                        }
                        sReturn.append("<tr class='list" + sClass + "'><td><1>" + debet.getUid() + "=" + debet.getAmount() + "<2>" + sChecked + "></td>"
                                        + "<td>" + HTMLEntities.htmlentities(sPatientName) + "</td>"
                                        + "<td>" + HTMLEntities.htmlentities(sDate) + "</td>"
                                        + "<td>" + HTMLEntities.htmlentities(sEncounterName) + "</td>"
                                        + "<td>" +debet.getQuantity()+" x "+ HTMLEntities.htmlentities(sPrestationDescription) + "</td>"
                                        + "<td >" + debet.getAmount() + " " + MedwanQuery.getInstance().getConfigParam("currency", "€") + "</td>"
                                        + "</tr>");
                    }
                }
            }
        }
        return sReturn.toString();
    }

    private String addPeriodDebets(Vector vDebets, String sClass, String sWebLanguage, boolean bChecked,java.util.Date begin,java.util.Date end, String sServiceUid) {
        StringBuffer sReturn = new StringBuffer();
        if (vDebets != null) {
            Debet debet;
            Prestation prestation;
            String sEncounterName, sPrestationDescription, sPatientName,sDate;
            String sChecked = "";
            Hashtable hSort = new Hashtable();

            if (bChecked) {
                sChecked = " checked";
            }
            String oldname="",oldencounter="",olddate="";
            //Firts we will sort the records
            for (int i=0;i<vDebets.size(); i++){
                debet = (Debet) vDebets.elementAt(i);
                if(debet!=null){
                    hSort.put(debet.getPatientName()+"="+debet.getDate().getTime() + "=" + debet.getUid(),debet);
                }
            }
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Iterator it = keys.iterator();

            while (it.hasNext()){
                debet = (Debet) hSort.get(it.next());

                if (checkString(debet.getUid()).length() > 0) {

                    if (debet != null) {
                        if(begin!=null & begin.after(debet.getDate())){
                            continue;
                        }
                        if(end!=null & end.before(debet.getDate())){
                            continue;
                        }
                        if(sServiceUid.length()>0){
                       		if(sServiceUid.indexOf("'"+debet.determineServiceUid()+"'")<0){
                       			continue;
                       		}
                        }

                        if(!oldname.equalsIgnoreCase(debet.getPatientName())){
                            sPatientName = debet.getPatientName();
                            oldname=sPatientName;
                            if (debet.getEncounter()!=null){
                                sEncounterName=debet.getEncounter().getEncounterDisplayName(sWebLanguage);
                            }
                            else{
                                sEncounterName=debet.getEncounterUid();
                            }
                            oldencounter=sEncounterName;
                            sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
                            olddate=sDate;
                        }
                        else {
                            sPatientName="";
                            if(!oldencounter.equalsIgnoreCase(debet.getEncounter().getEncounterDisplayName(sWebLanguage))){
                                sPatientName = debet.getPatientName();
                                oldname=sPatientName;
                                if (debet.getEncounter()!=null){
                                    sEncounterName=debet.getEncounter().getEncounterDisplayName(sWebLanguage);
                                }
                                else{
                                    sEncounterName=debet.getEncounterUid();
                                }
                                oldencounter=sEncounterName;
                                sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
                                olddate=sDate;
                            }
                            else {
                                sEncounterName="";
                                if(!olddate.equalsIgnoreCase(ScreenHelper.stdDateFormat.format(debet.getDate()))){
                                    sPatientName = debet.getPatientName();
                                    oldname=sPatientName;
                                    if (debet.getEncounter()!=null){
                                        sEncounterName=debet.getEncounter().getEncounterDisplayName(sWebLanguage);
                                    }
                                    else{
                                        sEncounterName=debet.getEncounterUid();
                                    }
                                    oldencounter=sEncounterName;
                                    sDate = ScreenHelper.stdDateFormat.format(debet.getDate());
                                    olddate=sDate;
                                }
                                else {
                                    sDate="";
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

                        if (sClass.equals("")) {
                            sClass = "1";
                        } else {
                            sClass = "";
                        }
                        sReturn.append("<tr class='list" + sClass + "'><td><1>" + debet.getUid() + "=" + debet.getAmount() + "<2>" + sChecked + "></td>"
                                        + "<td>" + HTMLEntities.htmlentities(sPatientName) + "</td>"
                                        + "<td>" + HTMLEntities.htmlentities(sDate) + "</td>"
                                        + "<td>" + HTMLEntities.htmlentities(sEncounterName) + "</td>"
                                        + "<td>" +debet.getQuantity()+" x "+ HTMLEntities.htmlentities(sPrestationDescription) + "</td>"
                                        + "<td >" + debet.getAmount() + " " + MedwanQuery.getInstance().getConfigParam("currency", "€") + "</td>"
                                        + "</tr>");
                    }
                }
            }
        }
        return sReturn.toString();
    }
%>
<table width="100%" cellspacing="1" cellpadding="0">
    <tr class="gray">
        <td width="50"/>
        <td width="200"><%=HTMLEntities.htmlentities(getTran("web.control","output_h_4",sWebLanguage))%></td>
        <td width="80"><%=HTMLEntities.htmlentities(getTran("web", "date", sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web.finance","encounter",sWebLanguage))%></td>
        <td width="200"><%=HTMLEntities.htmlentities(getTran("web","prestation",sWebLanguage))%></td>
        <td width="100"><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%></td>
    </tr>
<%
	String sServiceUid = checkString(request.getParameter("EditInvoiceService"));
	if(sServiceUid.length()>0){
		sServiceUid = Service.getChildIdsAsString(sServiceUid);
	}
	
    String sEditInsurarInvoiceUID = checkString(request.getParameter("EditInsurarInvoiceUID"));
    String sEditBegin = checkString(request.getParameter("EditBegin"));
    String sEditEnd = checkString(request.getParameter("EditEnd"));
    String sClass = "";
    ExtraInsurarInvoice2 insurarInvoice = null;

    if(sEditInsurarInvoiceUID.length() > 0){
        insurarInvoice = ExtraInsurarInvoice2.get(sEditInsurarInvoiceUID);
        Vector vDebets = insurarInvoice.getDebets();
        out.print(addDebets(vDebets,sClass,sWebLanguage,true));
    }

    if(insurarInvoice==null || (!checkString(insurarInvoice.getStatus()).equalsIgnoreCase("closed") && !checkString(insurarInvoice.getStatus()).equalsIgnoreCase("canceled"))) {
        String sInsurarUid = checkString(request.getParameter("InsurarUid"));
        Date begin = ScreenHelper.parseDate("01/01/1900");
        Date end = new Date();
        try{
            begin = ScreenHelper.parseDate(sEditBegin);
        }
        catch(Exception e){}
        try{
            end = ScreenHelper.parseDate(sEditEnd);
            end = new java.util.Date(end.getTime()+(24*3600*1000)-1);
        }
        catch(Exception e){}
        
        Vector vUnassignedDebets = new Vector();
		Insurar insurar = Insurar.get(sInsurarUid);
        if(insurar!=null && insurar.getRequireValidation()==1){
        	vUnassignedDebets = Debet.getUnassignedValidatedAndSignedExtraInsurarDebets2(sInsurarUid,begin,end);
        }
        else {
        	vUnassignedDebets = Debet.getUnassignedExtraInsurarDebets2(sInsurarUid,begin,end);
        }
        
        out.print(addPeriodDebets(vUnassignedDebets, sClass, sWebLanguage, false,begin,end,sServiceUid));
       	out.print("<tr><td colspan='6'>"+vUnassignedDebets.size()+" "+getTranNoLink("web","records.loaded",sWebLanguage)+"</td></tr>");
    }
%>
</table>