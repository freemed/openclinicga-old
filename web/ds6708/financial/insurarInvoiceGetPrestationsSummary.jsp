<%@ page import="be.openclinic.adt.Encounter,java.util.*,be.openclinic.finance.*,be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.Date,java.text.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<table width="100%" cellspacing="1">
<%
	int totalDebets=0,totalPatients=0,totalEncounters=0;
	double totalPatientAmount=0,totalInsurarAmount=0,totalExtraInsurarAmount=0;
	
	String sServiceUid = checkString(request.getParameter("EditInvoiceService"));
	if(sServiceUid.length()>0){
		sServiceUid = Service.getChildIdsAsString(sServiceUid);
	}
    String sEditInsurarInvoiceUID = checkString(request.getParameter("EditInsurarInvoiceUID"));
    String sEditBegin = checkString(request.getParameter("EditBegin"));
    String sEditEnd = checkString(request.getParameter("EditEnd"));
    InsurarInvoice insurarInvoice = null;
    Hashtable hPatients = new Hashtable(), hEncounters = new Hashtable();
    if (sEditInsurarInvoiceUID.length() > 0) {
        insurarInvoice = InsurarInvoice.get(sEditInsurarInvoiceUID);
        Vector debets = insurarInvoice.getDebets();
        totalDebets=debets.size();
        for(int n=0;n<debets.size();n++){
        	Debet debet = (Debet)debets.elementAt(n);
        	hPatients.put(debet.getEncounter().getPatientUID(), 1);
        	hPatients.put(debet.getEncounterUid(), 1);
        	totalPatientAmount+=debet.getAmount();
        	totalInsurarAmount+=debet.getInsurarAmount();
        	totalExtraInsurarAmount+=debet.getExtraInsurarAmount();
        }
    }
%>
	<tr>
		<td><%=getTran("web","prestations",sWebLanguage)+": "+totalDebets %></td>
		<td><%=getTran("web","patients",sWebLanguage)+": "+hPatients.size() %></td>
		<td><%=getTran("web","encounters",sWebLanguage)+": "+hEncounters.size() %></td>
	</tr>
	<tr>
		<td><%=getTran("web","insuraramount",sWebLanguage)+": "+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(totalInsurarAmount) %></td>
		<td><%=getTran("web","extrainsuraramount",sWebLanguage)+": "+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(totalExtraInsurarAmount) %></td>
		<td><%=getTran("web","patientamount",sWebLanguage)+": "+new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat","#.00")).format(totalPatientAmount) %></td>
	</tr>
</table>
<%
%>
