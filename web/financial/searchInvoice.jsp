<%@ page import="be.openclinic.finance.PatientInvoice,be.openclinic.finance.InsurarInvoice,java.util.*,java.text.DecimalFormat" %>
<%@ page import="be.openclinic.finance.ExtraInsurarInvoice" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.insuranceinvoice","select",activeUser)%>
<%=sJSSORTTABLE%>
<%
    try{
    String sFindDateBegin = checkString(request.getParameter("FindDateBegin"));
    String sFindDateEnd = checkString(request.getParameter("FindDateEnd"));
    String sFindAmountMin = checkString(request.getParameter("FindAmountMin"));
    String sFindAmountMax = checkString(request.getParameter("FindAmountMax"));
    String sFindInvoiceId = checkString(request.getParameter("FindInvoiceId"));
    String sFindInvoiceType = checkString(request.getParameter("FindInvoiceType"));
%>
<body onkeydown="if(enterEvent(event,13)){doFind();}">
<form name='FindForm' id="FindForm" method='POST'>
    <%=writeTableHeader("web","searchInvoice",sWebLanguage,"")%>
    <table class="menu" width="100%" cellspacing="0">
         <tr>
            <td width="100"><%=getTran("Web","date",sWebLanguage)%></td>
            <td width="110"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td width="130"><%=writeDateField("FindDateBegin","FindForm",sFindDateBegin,sWebLanguage)%></td>
            <td width="110"><%=getTran("Web","End",sWebLanguage)%></td>
            <td><%=writeDateField("FindDateEnd","FindForm",sFindDateEnd,sWebLanguage)%></td>
        </tr>
        <tr>
            <td><%=getTran("Web","amount",sWebLanguage)%></td>
            <td><%=getTran("Web","min",sWebLanguage)%></td>
            <td><input type="text" class="text" size="10" name="FindAmountMin" id="FindAmountMin" value="<%=sFindAmountMin%>" onblur="isNumber(this)"> <%=MedwanQuery.getInstance().getConfigParam("currency", "€")%></td>
            <td><%=getTran("Web","max",sWebLanguage)%></td>
            <td><input type="text" class="text" size="10" name="FindAmountMax" id="FindAmountMax" value="<%=sFindAmountMax%>" onblur="isNumber(this)"> <%=MedwanQuery.getInstance().getConfigParam("currency", "€")%></td>
        </tr>
        <tr>
            <td><%=getTran("web.finance","invoiceid",sWebLanguage)%></td>
            <td colspan="4"><input type="text" class="text" size="10" name="FindInvoiceId" id="FindInvoiceId" value="<%=sFindInvoiceId%>" onblur="isNumber(this)"></td>
        </tr>
        <tr>
            <td><%=getTran("web.finance","invoicetype",sWebLanguage)%></td>
            <td colspan="4">
                <input type="radio" id="FindTypePatient" onDblClick="uncheckRadio(this);" name="FindInvoiceType" value="patient" <%if (sFindInvoiceType.equalsIgnoreCase("patient")){out.print("checked");}%>><%=getLabel("web","patient",sWebLanguage,"FindTypePatient")%>
                       <input type="radio" onDblClick="uncheckRadio(this);" id="FindTypeInsurar" name="FindInvoiceType" value="insurar" <%if (sFindInvoiceType.equalsIgnoreCase("insurar") || sFindInvoiceType.equalsIgnoreCase("")){out.print("checked");}%>><%=getLabel("web","insurar",sWebLanguage,"FindTypeInsurar")%>
                       <input type="radio" onDblClick="uncheckRadio(this);" id="FindExtraInvoiceType" name="FindInvoiceType" value="extrainsurar" <%if (sFindInvoiceType.equalsIgnoreCase("extrainsurar")){out.print("checked");}%>><%=getLabel("web","extrainsurar",sWebLanguage,"FindExtraInvoiceType")%>
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
    if ((sFindDateBegin.length() > 0) || (sFindDateEnd.length() > 0) || (sFindAmountMin.length() > 0) || (sFindAmountMax.length() > 0) || (sFindInvoiceId.length() > 0)) {
        Vector vPatients = new Vector();
        Vector vInsurars = new Vector();
        Vector vExtraInsurars = new Vector();

        if ((sFindInvoiceType.equalsIgnoreCase("patient")) || (sFindInvoiceType.equals(""))) {
            vPatients = PatientInvoice.searchInvoices(sFindDateBegin, sFindDateEnd, sFindInvoiceId, sFindAmountMin, sFindAmountMax);
        }else if (sFindInvoiceType.equalsIgnoreCase("insurar")) {
            vInsurars = InsurarInvoice.searchInvoices(sFindDateBegin, sFindDateEnd, sFindInvoiceId, sFindAmountMin, sFindAmountMax);
        }else if (sFindInvoiceType.equalsIgnoreCase("extrainsurar")) {
            vExtraInsurars = ExtraInsurarInvoice.searchInvoices(sFindDateBegin, sFindDateEnd, sFindInvoiceId, sFindAmountMin, sFindAmountMax);
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
                    <tr class="list<%=sClass%>" onmouseover="this.className='list_select';" onmouseout="this.className='list<%=sClass%>';" onclick="openInvoice('<%=iInvoiceId.toString()%>','<%=sRowType%>')">
                        <td><%=iInvoiceId.toString()%></td>
                        <td><%=sRowDate%></td>
                        <td><%=sRowDestination%></td>
                        <td><%=sRowType%></td>
                        <td><%=sRowAmount%></td>
                        <td><%=sRowPayed%></td>
                        <td><%=getTran("finance.patientinvoice.status",sRowStatus,sWebLanguage)%></td>
                    </tr>
                    <%
                 }
            %>
            </tbody>
        </table>
        <%
    }
%>
<script type="text/javascript">

        function doFind(){
            if ((document.getElementById("FindDateBegin").value.length>0)
            ||(document.getElementById("FindDateEnd").value.length>0)
            ||(document.getElementById("FindAmountMin").value.length>0)
            ||(document.getElementById("FindAmountMax").value.length>0)
            ||(document.getElementById("FindInvoiceId").value.length>0)
            ){
                FindForm.submit();
            }
            else {
                alert("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
            }
        }

        function clearFields(){
            document.getElementById("FindDateBegin").value="";
            document.getElementById("FindDateEnd").value="";
            document.getElementById("FindAmountMin").value="";
            document.getElementById("FindAmountMax").value="";
            document.getElementById("FindInvoiceId").value="";
            document.getElementById("FindTypePatient").checked=false;
            document.getElementById("FindTypeInsurar").checked=false;
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
        }
    </script>
<%
    }
    catch(Exception e){
        e.printStackTrace();
    }
%>