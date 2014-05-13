<%@ page import="be.openclinic.finance.PatientInvoice,java.util.*,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency", "€");
    String sPatientId = checkString(request.getParameter("PatientId"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n########## financial/patientInvoiceGetOpenPatientInvoices.jsp ##########");
        Debug.println("sCurrency  : "+sCurrency);
        Debug.println("sPatientId : "+sPatientId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    Vector vOpenPatientInvoices = PatientInvoice.getPatientInvoicesWhereDifferentStatus(sPatientId, "'closed','canceled'");
    String sReturn = "";
    Hashtable hSort = new Hashtable();
    PatientInvoice patientinvoice;

    for(int i=0; i<vOpenPatientInvoices.size(); i++){
        patientinvoice = (PatientInvoice)vOpenPatientInvoices.elementAt(i);

        if (patientinvoice!=null){
            hSort.put(patientinvoice.getDate().getTime()+"="+patientinvoice.getUid()," onclick=\"setPatientInvoice('"+patientinvoice.getInvoiceUid()+"');\">"
                 +"<td class='hand'>"+ScreenHelper.getSQLDate(patientinvoice.getDate())+"</td>"
                 +"<td class='hand'>"+patientinvoice.getInvoiceUid()+"</td>"
                 +"<td class='hand' style='text-align:right;'>"+patientinvoice.getBalance()+"&nbsp;</td>"
                 +"<td class='hand' >"+getTran("finance.patientinvoice.status",patientinvoice.getStatus(),sWebLanguage)+"</td></tr>");
        }
    }

    Vector keys = new Vector(hSort.keySet());
    Collections.sort(keys);
    Collections.reverse(keys);
    Iterator it = keys.iterator();
    String sClass = "";
    while(it.hasNext()){
        if(sClass.equals("")) sClass = "1";
        else                  sClass = "";
        
        sReturn+= "<tr class='list"+sClass+ "' "+hSort.get(it.next());
    }
%>
<table id="searchresults" width="100%" cellspacing="0">
    <tr class="admin">
        <td class="hand" width="100" nowrap><%=HTMLEntities.htmlentities(getTran("web","date",sWebLanguage))%></td>
        <td class="hand" width="120" nowrap><%=HTMLEntities.htmlentities(getTran("web", "invoicenumber", sWebLanguage))%></td>
        <td class="hand" width="150" nowrap style="text-align:right;"><%=HTMLEntities.htmlentities(getTran("web","balance",sWebLanguage))%>&nbsp;<%=sCurrency%></td>
        <td class="hand" > <%=HTMLEntities.htmlentities(getTran("Web.finance","patientinvoice.status",sWebLanguage))%></td>
    </tr>
    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%=sReturn%>
    </tbody>
</table>