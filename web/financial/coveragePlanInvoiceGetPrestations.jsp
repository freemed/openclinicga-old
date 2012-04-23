<%@ page import="be.openclinic.finance.*,java.text.*,be.openclinic.adt.Encounter,java.util.*,be.openclinic.finance.Prestation,be.mxs.common.util.system.HTMLEntities,be.openclinic.finance.CoveragePlanInvoice" %>
<%@ page import="java.util.Date" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!

	private String addPeriodServices(Hashtable hDebets,String sClass,String sWebLanguage){
	    StringBuffer sReturn = new StringBuffer();
	    Enumeration services = hDebets.keys();
	    String serviceid="";
	    Service service=null;
	    while(services.hasMoreElements()){
	    	serviceid=(String)services.nextElement();
	    	service=Service.getService(serviceid);
	    	if(service != null){
                sReturn.append("<tr class='list" + sClass + "'><td><a href='javascript:selectService(\""+serviceid+"\");'>" + HTMLEntities.htmlentities(serviceid) + ": " + HTMLEntities.htmlentities(service.getLabel(sWebLanguage)) + "</a></td>"
                        + "<td>" + HTMLEntities.htmlentities(new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.#")).format((Double)hDebets.get(serviceid))) +" "+MedwanQuery.getInstance().getConfigString("currency","EUR")+"</td>"
                        + "</tr>");
	    	}
	    }
        return sReturn.toString();
	}

	private String addDebets(Vector vDebets, String sClass, String sWebLanguage, boolean bChecked) {
        StringBuffer sReturn = new StringBuffer();

        if (vDebets != null) {
            PrestationDebet debet;
            Prestation prestation;
            String sEncounterName, sPrestationDescription, sPatientName,sDate;
            String oldname="",oldencounter="",olddate="";
            String sChecked = "";
            Hashtable hSort = new Hashtable();

            if (bChecked) {
                sChecked = " checked";
            }
            int count=0,count2=0;

            //Firts we will sort the records
            for (int i=0;i<vDebets.size(); i++){
                debet = (PrestationDebet) vDebets.elementAt(i);
                if(debet!=null){
    				count2++;
                    hSort.put(debet.getPatientName()+"="+debet.getDate().getTime() + "=" + debet.getUid(),debet);
                }
            }
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Iterator it = keys.iterator();
            while (it.hasNext()){
                debet = (PrestationDebet) hSort.get(it.next());
                if (checkString(debet.getUid()).length() > 0) {

                    if (debet != null) {
                    	count++;
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
                            sDate = new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate());
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
                                sDate = new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate());
                                olddate=sDate;
                            }
                            else {
                                sEncounterName="";
                                if(!olddate.equalsIgnoreCase(new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate()))){
                                    sPatientName = debet.getPatientName();
                                    oldname=sPatientName;
                                    if (debet.getEncounter()!=null){
                                        sEncounterName=debet.getEncounter().getEncounterDisplayName(sWebLanguage);
                                    }
                                    else{
                                        sEncounterName=debet.getEncounterUid();
                                    }
                                    oldencounter=sEncounterName;
                                    sDate = new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate());
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
                        sReturn.append("<tr class='list" + sClass + "'><td><1>" + debet.getUid() + "=" + debet.getInsurarAmount() + "<2>" + sChecked + "></td>"
                                        + "<td>" + HTMLEntities.htmlentities(sPatientName) + "</td>"
                                        + "<td>" + HTMLEntities.htmlentities(sDate) + "</td>"
                                        + "<td>" + HTMLEntities.htmlentities(sEncounterName) + "</td>"
                                        + "<td>" +debet.getQuantity()+" x "+ HTMLEntities.htmlentities(sPrestationDescription) + "</td>"
                                        + "<td >" + debet.getInsurarAmount() + " " + MedwanQuery.getInstance().getConfigParam("currency", "€") + "</td>"
                                        + "</tr>");
                    }
                }
            }

        }
        return sReturn.toString();
    }

    private String addPeriodDebets(Vector vDebets, String sClass, String sWebLanguage, boolean bChecked,String sEditBegin,String sEditEnd) {
        StringBuffer sReturn = new StringBuffer();
        Date begin = null, end =null;
        try{
            begin = new SimpleDateFormat("dd/MM/yyyy").parse(sEditBegin);
        }
        catch(Exception e){
        }
        try{
            end = new SimpleDateFormat("dd/MM/yyyy").parse(sEditEnd);
        }
        catch(Exception e){
        }

        if (vDebets != null) {
            PrestationDebet debet;
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
                debet = (PrestationDebet) vDebets.elementAt(i);
                if(debet!=null){
                    hSort.put(debet.getPatientName()+"="+debet.getDate().getTime() + "=" + debet.getUid(),debet);
                }
            }
            Vector keys = new Vector(hSort.keySet());
            Collections.sort(keys);
            Iterator it = keys.iterator();

            while (it.hasNext()){
                debet = (PrestationDebet) hSort.get(it.next());

                if (checkString(debet.getUid()).length() > 0) {

                    if (debet != null) {
                        if(begin!=null & begin.after(debet.getDate())){
                            continue;
                        }
                        if(end!=null & end.before(debet.getDate())){
                            continue;
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
                            sDate = new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate());
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
                                sDate = new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate());
                                olddate=sDate;
                            }
                            else {
                                sEncounterName="";
                                if(!olddate.equalsIgnoreCase(new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate()))){
                                    sPatientName = debet.getPatientName();
                                    oldname=sPatientName;
                                    if (debet.getEncounter()!=null){
                                        sEncounterName=debet.getEncounter().getEncounterDisplayName(sWebLanguage);
                                    }
                                    else{
                                        sEncounterName=debet.getEncounterUid();
                                    }
                                    oldencounter=sEncounterName;
                                    sDate = new SimpleDateFormat("dd/MM/yyyy").format(debet.getDate());
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
                        sReturn.append("<tr class='list" + sClass + "'><td><1>" + debet.getUid() + "=" + debet.getInsurarAmount() + "<2>" + sChecked + "></td>"
                                        + "<td>" + HTMLEntities.htmlentities(sPatientName) + "</td>"
                                        + "<td>" + HTMLEntities.htmlentities(sDate) + "</td>"
                                        + "<td>" + HTMLEntities.htmlentities(sEncounterName) + "</td>"
                                        + "<td>" +debet.getQuantity()+" x "+ HTMLEntities.htmlentities(sPrestationDescription) + "</td>"
                                        + "<td >" + debet.getInsurarAmount() + " " + MedwanQuery.getInstance().getConfigParam("currency", "€") + "</td>"
                                        + "</tr>");
                    }
                }
            }
        }
        return sReturn.toString();
    }
%>
<%
String sEditServiceUID = checkString(request.getParameter("EditServiceUID"));
String sEditCoveragePlanInvoiceUID = checkString(request.getParameter("EditCoveragePlanInvoiceUID"));

if(sEditServiceUID.length()==0 && sEditCoveragePlanInvoiceUID.length()==0){
%>
<table width="100%" cellspacing="1">
    <tr class="gray">
        <td><%=HTMLEntities.htmlentities(getTran("web", "careprovider", sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","amount.to.reimburse",sWebLanguage))%></td>
    </tr>

<%} else { 
%>
<table width="100%" cellspacing="1">
    <tr class="gray">
        <td width="50"/>
        <td width="200"><%=HTMLEntities.htmlentities(getTran("web.control","output_h_4",sWebLanguage))%></td>
        <td width="80"><%=HTMLEntities.htmlentities(getTran("web", "date", sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web.finance","encounter",sWebLanguage))%></td>
        <td><%=HTMLEntities.htmlentities(getTran("web","prestation",sWebLanguage))%></td>
        <td width="100"><%=HTMLEntities.htmlentities(getTran("web","amount",sWebLanguage))%></td>
    </tr>
<% }
    String sEditBegin = checkString(request.getParameter("EditBegin"));
    String sEditEnd = checkString(request.getParameter("EditEnd"));
    String sClass = "";
    CoveragePlanInvoice coveragePlanInvoice = null;
    if (sEditCoveragePlanInvoiceUID.length() > 0) {
        coveragePlanInvoice = CoveragePlanInvoice.get(sEditCoveragePlanInvoiceUID);
        Vector vDebets = coveragePlanInvoice.getDebets();
        String s = addDebets(vDebets, sClass, sWebLanguage, true);
        out.print(s);
    }

    if ((coveragePlanInvoice==null)||(!checkString(coveragePlanInvoice.getStatus()).equalsIgnoreCase("closed") && !checkString(coveragePlanInvoice.getStatus()).equalsIgnoreCase("canceled"))) {
        String sInsurarUid = checkString(request.getParameter("InsurarUid"));
        Date begin=new SimpleDateFormat("dd/MM/yyyy").parse("01/01/1900");
        Date end=new Date();
        try{
            begin = new SimpleDateFormat("dd/MM/yyyy").parse(sEditBegin);
        }
        catch(Exception e){}
        try{
            end = new SimpleDateFormat("dd/MM/yyyy").parse(sEditEnd);
        }
        catch(Exception e){}
        String s="";
        if(sEditServiceUID.length()==0){
        	System.out.println("PER SERVICE! sInsurarUid="+sInsurarUid);
			Hashtable vUnassignedDebets = PrestationDebet.getUnassignedInsurarDebetsPerService(sInsurarUid, begin, end);
            s = addPeriodServices(vUnassignedDebets, sClass, sWebLanguage);
        }
        else { 
        	Vector vUnassignedDebets = PrestationDebet.getUnassignedInsurarDebets(sInsurarUid,begin,end,sEditServiceUID);
            s = addPeriodDebets(vUnassignedDebets, sClass, sWebLanguage, false,sEditBegin,sEditEnd);
        }
        out.print(s);
    }
    else {
    }
%>
</table>
