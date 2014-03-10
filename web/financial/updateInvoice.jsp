<%@ page import="be.openclinic.finance.*,java.util.*,java.text.DecimalFormat" %>
<%@ page import="be.openclinic.finance.ExtraInsurarInvoice" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.invoiceupdate","edit",activeUser)%>
<%=sJSSORTTABLE%>
<%
    try{
    String sAction = checkString(request.getParameter("action"));
    String sFindInvoiceId = checkString(request.getParameter("FindInvoiceId"));
        if(sFindInvoiceId.indexOf(",")>0){
           sFindInvoiceId = sFindInvoiceId.substring(sFindInvoiceId.indexOf(",")+1);
        }else if(sFindInvoiceId.indexOf(".")>0){
           sFindInvoiceId = sFindInvoiceId.substring(sFindInvoiceId.indexOf(".")+1);
        }
    String sFindInvoiceType = checkString(request.getParameter("FindInvoiceType"));
    String sInvoiceType = checkString(request.getParameter("invoiceType"));
%>
<body onkeydown="if(enterEvent(event,13)){doFind();}">
<form name='FindForm' id="FindForm" method='POST'>
    <%=writeTableHeader("web","searchInvoice",sWebLanguage,"")%>
    <input type="hidden" name="action" id="actionType" value="<%=sAction%>"/>
    <input type="hidden" name="invoiceType" id="invoiceType" value="<%=sInvoiceType%>"/>

    <table class="menu" width="100%" cellspacing="0">
        <tr>
            <td><%=getTran("web.finance","invoiceid",sWebLanguage)%></td>
            <td colspan="4"><input type="text" class="text" size="10" name="FindInvoiceId" id="FindInvoiceId" value="<%=sFindInvoiceId%>" ></td>
        </tr>
        <tr>
            <td><%=getTran("web.finance","invoicetype",sWebLanguage)%></td>
            <td colspan="4">
				<%	if(activeUser.getAccessRight("financial.patientinvoiceupdate.edit")){ %>
	                <input type="radio" id="FindTypePatient" name="FindInvoiceType" value="patient" <%if (sFindInvoiceType.equalsIgnoreCase("patient")||!activeUser.getAccessRight("financial.insurerinvoiceupdate.edit")){out.print("checked");}%>><%=getLabel("web","patient",sWebLanguage,"FindTypePatient")%>
	            <%	}
					if(activeUser.getAccessRight("financial.insurerinvoiceupdate.edit")){ 
				%>
                <input type="radio" id="FindTypeInsurar" name="FindInvoiceType" value="insurar" <%if (sFindInvoiceType.equalsIgnoreCase("insurar") || sFindInvoiceType.equalsIgnoreCase("")){out.print("checked");}%>><%=getLabel("web","insurar",sWebLanguage,"FindTypeInsurar")%>
                <input type="radio" id="FindExtraInvoiceType" name="FindInvoiceType" value="extrainsurar" <%if (sFindInvoiceType.equalsIgnoreCase("extrainsurar")){out.print("checked");}%>><%=getLabel("web","extrainsurar",sWebLanguage,"FindTypeInsurar")%>
                <input type="radio" id="FindExtraInvoiceType2" name="FindInvoiceType" value="complementarycoverage2" <%if (sFindInvoiceType.equalsIgnoreCase("complementarycoverage2")){out.print("checked");}%>><%=getLabel("web","complementarycoverage2",sWebLanguage,"FindTypeInsurar")%>
                <%	} %>
            </td>	
            
        </tr>
        <tr>
            <td/>
            <td colspan="4">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doFind();">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFields()">&nbsp;
            </td>
        </tr>
    </table>
</form>
<%
   //----------- IF to search invoice --------------/
    if(sFindInvoiceId.length()>0 && sAction.equalsIgnoreCase("update")){
        boolean isOk = false;

        if(sFindInvoiceType.equalsIgnoreCase("patient")){
            isOk =(PatientInvoice.setStatusOpen(sFindInvoiceId,activeUser.userid));
        }else if(sFindInvoiceType.equalsIgnoreCase("insurar")){
            isOk =(InsurarInvoice.setStatusOpen(sFindInvoiceId,activeUser.userid));
        }else if(sFindInvoiceType.equalsIgnoreCase("extrainsurar")){
            isOk =(ExtraInsurarInvoice.setStatusOpen(sFindInvoiceId,activeUser.userid));
        }else if(sFindInvoiceType.equalsIgnoreCase("complementarycoverage2")){
            isOk =(ExtraInsurarInvoice2.setStatusOpen(sFindInvoiceId,activeUser.userid));
        }
        if(isOk){
            out.write("<tr><td>"+getTran("web","saved",sWebLanguage)+"</td></tr>");
        }else{
            out.write("<tr><td>"+getTran("web","not.saved",sWebLanguage)+"</td></tr>");
        }
    }

    if ((sFindInvoiceId.length() > 0)) {
        Vector vPatients = new Vector();
        Vector vInsurars = new Vector();
        Vector vExtraInsurars = new Vector();
        Vector vExtraInsurars2 = new Vector();
        if ((sFindInvoiceType.equalsIgnoreCase("patient"))) {
            vPatients = PatientInvoice.searchInvoices("", "", sFindInvoiceId, "", "");
        }else if ((sFindInvoiceType.equalsIgnoreCase("insurar"))) {
            vInsurars = InsurarInvoice.searchInvoices("", "", sFindInvoiceId, "", "");
        }else if ((sFindInvoiceType.equalsIgnoreCase("extrainsurar"))) {
            vExtraInsurars = ExtraInsurarInvoice.searchInvoices("", "", sFindInvoiceId, "", "");
        }else if ((sFindInvoiceType.equalsIgnoreCase("complementarycoverage2"))) {
            vExtraInsurars2 = ExtraInsurarInvoice2.searchInvoices("", "", sFindInvoiceId, "", "");
        }

        Hashtable hInvoices = new Hashtable();
        PatientInvoice patientInvoice;
        for (int i=0;i<vPatients.size();i++){
            patientInvoice = (PatientInvoice)vPatients.elementAt(i);

            if (patientInvoice!=null){
                hInvoices.put(new Integer(patientInvoice.getInvoiceUid()),patientInvoice);
            }
        }

        InsurarInvoice insurarInvoice;
        for (int i=0;i<vInsurars.size();i++){
            insurarInvoice = (InsurarInvoice)vInsurars.elementAt(i);

            if (insurarInvoice!=null){
                hInvoices.put(new Integer(insurarInvoice.getInvoiceUid()),insurarInvoice);
            }
        }
        ExtraInsurarInvoice extrainsurarInvoice;
        for (int i=0;i<vExtraInsurars.size();i++){
            extrainsurarInvoice = (ExtraInsurarInvoice)vExtraInsurars.elementAt(i);

            if (extrainsurarInvoice!=null){
                hInvoices.put(new Integer(extrainsurarInvoice.getInvoiceUid()),extrainsurarInvoice);
            }
        }
        ExtraInsurarInvoice2 extrainsurarInvoice2;
        for (int i=0;i<vExtraInsurars2.size();i++){
            extrainsurarInvoice2 = (ExtraInsurarInvoice2)vExtraInsurars2.elementAt(i);

            if (extrainsurarInvoice2!=null){
                hInvoices.put(new Integer(extrainsurarInvoice2.getInvoiceUid()),extrainsurarInvoice2);
            }
        }
%>
        <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
            <tr class="admin">
                <td width="100"><%=getTran("web.finance","invoiceid",sWebLanguage)%></td>
                <td width="80"><%=getTran("web","date",sWebLanguage)%></td>
                <td><%=getTran("web","destination",sWebLanguage)%></td>
                <td width="80"><%=getTran("web.finance","invoicetype",sWebLanguage)%></td>
                <td width="100"><%=getTran("Web","amount",sWebLanguage)+" "+MedwanQuery.getInstance().getConfigParam("currency", "€")%></td>
                <td width="100"><%=getTran("Web.finance","payed",sWebLanguage)%></td>
                <td width="105"><%=getTran("web.finance","patientinvoice.status",sWebLanguage)%></td>
            </tr>
            <tbody onmouseover='this.style.cursor="pointer"' onmouseout='this.style.cursor="default"'>
            <%

                String sClass = "", sRowDate="", sRowDestination="", sRowType="", sRowAmount="", sRowPayed="", sRowStatus="";
                Integer iInvoiceId;
                Vector v = new Vector(hInvoices.keySet());
                Collections.sort(v);
                Iterator it = v.iterator();

                while (it.hasNext()) {
                    iInvoiceId = (Integer) it.next();

                    Object object = hInvoices.get(iInvoiceId);

                    sRowPayed = "";

                    try{
                    if (object.getClass().getName().equals("be.openclinic.finance.PatientInvoice")) {
                        patientInvoice = (PatientInvoice) object;
                        sRowDate = ScreenHelper.getSQLDate(patientInvoice.getDate());
                        sRowDestination = patientInvoice.getPatient().lastname + ", " + patientInvoice.getPatient().firstname;
                        sRowAmount = new DecimalFormat("#0.00").format(patientInvoice.getBalance());
                        sRowStatus = patientInvoice.getStatus();
                        sRowType = getTran("web","patient",sWebLanguage);
                    } else if (object.getClass().getName().equals("be.openclinic.finance.InsurarInvoice")) {
                        insurarInvoice = (InsurarInvoice) object;
                        sRowDate = ScreenHelper.getSQLDate(insurarInvoice.getDate());
                        sRowDestination = insurarInvoice.getInsurar().getName();
                        sRowAmount = new DecimalFormat("#0.00").format(insurarInvoice.getBalance());
                        sRowStatus = insurarInvoice.getStatus();
                        sRowType = getTran("web","insurar",sWebLanguage);
                    }else if (object.getClass().getName().equals("be.openclinic.finance.ExtraInsurarInvoice")) {
                        extrainsurarInvoice = (ExtraInsurarInvoice) object;
                        sRowDate = ScreenHelper.getSQLDate(extrainsurarInvoice.getDate());
                        sRowDestination = extrainsurarInvoice.getInsurar().getName();
                        sRowAmount = new DecimalFormat("#0.00").format(extrainsurarInvoice.getBalance());
                        sRowStatus = extrainsurarInvoice.getStatus();
                        sRowType = getTran("web","extrainsurar",sWebLanguage);
                    }else if (object.getClass().getName().equals("be.openclinic.finance.ExtraInsurarInvoice2")) {
                        extrainsurarInvoice2 = (ExtraInsurarInvoice2) object;
                        sRowDate = ScreenHelper.getSQLDate(extrainsurarInvoice2.getDate());
                        sRowDestination = extrainsurarInvoice2.getInsurar().getName();
                        sRowAmount = new DecimalFormat("#0.00").format(extrainsurarInvoice2.getBalance());
                        sRowStatus = extrainsurarInvoice2.getStatus();
                        sRowType = getTran("web","complementarycoverage2",sWebLanguage);
                    }
                    if (sRowStatus.equalsIgnoreCase("closed")||sRowStatus.equalsIgnoreCase("canceled")){
                        sRowPayed = "Ok";
                    }

                    if (sClass.equals("1")) {
                        sClass = "";
                    } else {
                        sClass = "1";
                    }

                    }
                    catch(Exception e2){
                        e2.printStackTrace();
                    }
            %>
                    <tr class="list<%=sClass%>"  onclick="openInvoice('<%=iInvoiceId.toString()%>','<%=sRowType%>')">
                        <td><%=iInvoiceId.toString()%></td>
                        <td><%=sRowDate%></td>
                        <td><%=sRowDestination%></td>
                        <td><%=sRowType%></td>
                        <td><%=sRowAmount%></td>
                        <td><%=sRowPayed%></td>
                        <td><%=getTran("finance.patientinvoice.status",sRowStatus,sWebLanguage)%></td>
                    </tr>
                    <tr >
                        <td colspan="2">&nbsp;</td>
                        <td colspan="5"><input type="button" class="button" onclick="setInvoice('<%=iInvoiceId.toString()%>','<%=sRowType%>')" value="<%=getTran("financial","financial.status.set.open",sWebLanguage)%>"/> </td>
                    </tr>
                    <%
                 }
                    //-------------- IF TO UPDATE THE INVOICE STATUS TO OPEN -------/

                 
            %>
            </tbody>
        </table>
        <%
    }
%>
<script>

        function doFind(){
            if ($("FindInvoiceId").value.length>0){
                $("actionType").value = "search";
                FindForm.submit();
            }
            else {
                alert("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
            }
        }

        function clearFields(){
            $("FindInvoiceId").value="";
            $("FindTypePatient").checked=false;
            $("FindTypeInsurar").checked=false;
            $("FindTypeExtraInsurar").checked=false;
        }

        function setInvoice(sInvoiceId, sType){
            $("actionType").value = "update";
            $("invoiceType").value = sType;
            FindForm.submit();

        }
     function openInvoice(sInvoiceId, sType){
            if (sType=="<%=getTran("web","patient",sWebLanguage)%>"){
                openPopup("/financial/patientInvoiceEdit.jsp&ts=<%=getTs()%>&PopupWidth=610&PopupHeight=660&FindPatientInvoiceUID="+sInvoiceId);
            }
            else if(sType=="<%=getTran("web","insurar",sWebLanguage)%>"){
                openPopup("/financial/insuranceInvoiceEdit.jsp&ts=<%=getTs()%>&PopupWidth=600&PopupHeight=690&FindInsurarInvoiceUID="+sInvoiceId);
            }
            else if(sType=="<%=getTran("web","extrainsurar",sWebLanguage)%>"){
                openPopup("/financial/extraInsuranceInvoiceEdit.jsp&ts=<%=getTs()%>&PopupWidth=600&PopupHeight=690&FindInsurarInvoiceUID="+sInvoiceId);
            }
            else if(sType=="<%=getTran("web","complementarycoverage2",sWebLanguage)%>"){
                openPopup("/financial/extraInsuranceInvoiceEdit.jsp&ts=<%=getTs()%>&PopupWidth=600&PopupHeight=690&FindInsurarInvoiceUID="+sInvoiceId);
            }
        }
    </script>
<%
    }
    catch(Exception e){
        e.printStackTrace();
    }
%>