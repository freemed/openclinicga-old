<%@ page import="be.openclinic.finance.*,java.util.Date" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%=checkPermission("financial.insuranceinvoice", "edit", activeUser)%>
<%=sJSPROTOTYPE%>
<%=sJSNUMBER%>
<%
    String sFindInsurarInvoiceUID = checkString(request.getParameter("FindInsurarInvoiceUID"));
    ExtraInsurarInvoice insurarInvoice;
    String sInsurarText = "";
    if (sFindInsurarInvoiceUID.length() > 0) {
        insurarInvoice = ExtraInsurarInvoice.getViaInvoiceUID(sFindInsurarInvoiceUID);
        Insurar insurar = Insurar.get(checkString(insurarInvoice.getInsurarUid()));
        if (insurar != null) {
            sInsurarText = checkString(insurar.getName());
        }
    } else {
        insurarInvoice = new ExtraInsurarInvoice();
    }
%>
<form name='FindForm' id="FindForm" method='POST'>
    <%=writeTableHeader("web", "extrainsuranceInvoiceEdit", sWebLanguage, "")%>
    <table class="menu" width="100%">
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web.finance", "invoiceid", sWebLanguage)%>
            </td>
            <td>
                <input type="text" class="text" name="FindInsurarInvoiceUID" id="FindInsurarInvoiceUID" onblur="isNumber(this)" value="<%=sFindInsurarInvoiceUID%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchInsurarInvoice();">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="doClearInsurarInvoice()">

                <input type="button" class="button" name="ButtonFind" value="<%=getTran("web","find",sWebLanguage)%>" onclick="doFind()">
                <input type="button" class="button" name="ButtonNew" value="<%=getTran("web","new",sWebLanguage)%>" onclick="doNew();searchInsurar();">
                <input type="button" class="button" name="ButtonClear" value="<%=getTran("web","clear",sWebLanguage)%>" onclick="doClear()">
            </td>
        </tr>
    </table>
</form>
<script>
    FindForm.FindInsurarInvoiceUID.focus();

    function searchInsurarInvoice() {
        openPopup("/_common/search/searchExtraInsurarInvoice.jsp&ts=<%=getTs()%>&doFunction=doFind()&ReturnFieldInvoiceNr=FindInsurarInvoiceUID&FindInvoiceInsurar=<%=sFindInsurarInvoiceUID%>");
    }

    function doFind() {
        if (FindForm.FindInsurarInvoiceUID.value.length > 0) {
            FindForm.submit();
        }
    }

    function doNew() {
        FindForm.FindInsurarInvoiceUID.value = "";
        FindForm.submit();
    }

    function doClear() {
        doClearInsurarInvoice();
    }

    function doClearInsurarInvoice() {
        FindForm.FindInsurarInvoiceUID.value = "";
        FindForm.FindInsurarInvoiceUID.focus();
    }
</script>
<div id="divOpenInsurarInvoices" style="height:120px;" class="searchResults"></div>
<form name='EditForm' id="EditForm" method='POST'>
<table class='list' border='0' width='100%' cellspacing='1'>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("medical.accident", "insurancecompany", sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="hidden" name="EditInsurarUID" value="<%=checkString(insurarInvoice.getInsurarUid())%>">
            <input type="text" class="text" readonly name="EditInsurarText" value="<%=sInsurarText%>" size="100">
            <%
                if (checkString(insurarInvoice.getUid()).length() == 0) {
            %>
            <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchInsurar();">
            <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="doClearInsurar()">
            <%
                }
            %>
        </td>
    </tr>
    <tr id="invoicedetails" style="visibility: hidden">
        <td colspan="2">
            <table class='list' border='0' width='100%' cellspacing='1' id="invoicedetailstable">
                <tr>
                    <td class="admin"><%=getTran("web.finance", "invoiceid", sWebLanguage)%>
                    </td>
                    <td class="admin2"><input type="text" class="text" readonly name="EditInvoiceUID" id="EditInvoiceUID" value="<%=checkString(insurarInvoice.getInvoiceUid())%>"></td>
                </tr>
                <tr>
                    <td class='admin'><%=getTran("Web", "date", sWebLanguage)%> *</td>
                    <%

                        Date activeDate = insurarInvoice.getDate();
                        if (activeDate == null) {
                            activeDate = new Date();
                        }
                    %>
                    <td class='admin2'><%=writeDateField("EditDate", "EditForm", ScreenHelper.getSQLDate(activeDate), sWebLanguage)%>
                    </td>
                </tr>
                <tr>
                    <td class='admin'><%=getTran("Web.finance", "patientinvoice.status", sWebLanguage)%> *</td>
                    <td class='admin2'>
                        <select class="text" id="EditStatus" name="EditStatus" onchange="doStatus()" <%=insurarInvoice.getStatus()!=null && (insurarInvoice.getStatus().equalsIgnoreCase("closed") || insurarInvoice.getStatus().equalsIgnoreCase("canceled"))?"disabled":""%>>
                            <option/>
                            <%
                                String activeStatus = checkString(insurarInvoice.getStatus());
                                if (activeStatus.length() == 0) {
                                    activeStatus = "open";
                                }
                            %>
                            <%=ScreenHelper.writeSelect("finance.patientinvoice.status", activeStatus, sWebLanguage)%>
                        </select>
                    </td>
                </tr>
                <tr id="period" style="visibility: hidden">
                    <td class='admin'><%=getTran("web", "period", sWebLanguage)%></td>
                    <td class="admin2">
                        <%
                            Date previousmonth=new Date(new Date().getTime()-30*24*3600*1000l);
                        %>
                        <%=writeDateField("EditBegin", "EditForm", new SimpleDateFormat("01/MM/yyyy").format(previousmonth), sWebLanguage)%>
                        <%=getTran("web","to",sWebLanguage)%>
                        <%=writeDateField("EditEnd", "EditForm", new SimpleDateFormat("dd/MM/yyyy").format(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("01/MM/yyyy").format(new Date())).getTime()-1), sWebLanguage)%>
		               <input type="hidden" name="EditInvoiceService" id="EditInvoiceService" value="">
                        <% if(insurarInvoice==null || insurarInvoice.getStatus()==null || insurarInvoice.getStatus().equalsIgnoreCase("open")){ %>
			               <input class="text" type="text" name="EditInvoiceServiceName" id="EditInvoiceServiceName" readonly size="<%=sTextWidth%>" value="">
			               <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchService('EditInvoiceService','EditInvoiceServiceName');">
			               <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="document.getElementById('EditInvoiceService').value='';document.getElementById('EditInvoiceServiceName').value='';">
						<%}%>                        
                        &nbsp;<input type="button" class="button" name="update" value="<%=getTran("web","update",sWebLanguage)%>" onclick="changeInsurar();"/>
                    </td>
                </tr>
                <tr>
                    <td class='admin'><%=getTran("web.finance", "balance", sWebLanguage)%>
                    </td>
                    <td class='admin2'>
                        <input class='text' readonly type='text' id='EditBalance' name='EditBalance' value='<%=new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat", "#,##0.00")).format(insurarInvoice.getBalance())%>' size='20'> <%=MedwanQuery.getInstance().getConfigParam("currency", "€")%>
                    </td>
                </tr>
                <tr>
                    <td class='admin'><%=getTran("web.finance", "prestations", sWebLanguage)%>
                    </td>
                    <td class='admin2'>
                        <div id="divPrestations" style="height:120px;" class="searchResults"></div>
                        <input class='button' type="button" name="ButtonDebetSelectAll" id="ButtonDebetSelectAll" value="<%=getTran("web","selectall",sWebLanguage)%>" onclick="selectAll('cbDebet',true,'ButtonDebetSelectAll','ButtonDebetDeselectAll',true);">&nbsp;
                        <input class='button' type="button" name="ButtonDebetDeselectAll" id="ButtonDebetDeselectAll" value="<%=getTran("web","deselectall",sWebLanguage)%>" onclick="selectAll('cbDebet',false,'ButtonDebetDeselectAll','ButtonDebetSelectAll',true);">
                    </td>
                </tr>
                <tr>
                    <td class='admin'><%=getTran("web.finance", "credits", sWebLanguage)%>
                    </td>
                    <td class='admin2'>
                        <div id="divCredits" style="height:120px;" class="searchResults"></div>
                        <input class='button' type="button" name="ButtonInsurarInvoiceSelectAll" id="ButtonInsurarInvoiceSelectAll" value="<%=getTran("web","selectall",sWebLanguage)%>" onclick="selectAll('cbInsurarInvoice',true,'ButtonInsurarInvoiceSelectAll', 'ButtonInsurarInvoiceDeselectAll',false);">&nbsp;
                        <input class='button' type="button" name="ButtonInsurarInvoiceDeselectAll" id="ButtonInsurarInvoiceDeselectAll" value="<%=getTran("web","deselectall",sWebLanguage)%>" onclick="selectAll('cbInsurarInvoice',false,'ButtonInsurarInvoiceDeselectAll', 'ButtonInsurarInvoiceSelectAll',false);">
                    </td>
                </tr>
                <tr>
                    <td class="admin"/>
                    <td class="admin2">
                        <%
                            if (!(checkString(insurarInvoice.getStatus()).equalsIgnoreCase("closed")||checkString(insurarInvoice.getStatus()).equalsIgnoreCase("canceled"))) {
                        %>
                        <input class='button' type="button" name="ButtonSave" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave(this);">&nbsp;
                        <%
                            }

                            // pdf print button for existing invoices
                            if (checkString(insurarInvoice.getUid()).length() > 0) {
                        %>
                        <%=getTran("Web.Occup", "PrintLanguage", sWebLanguage)%>

                        <%
                            String sPrintLanguage = activeUser.person.language;
                            if (sPrintLanguage.length() == 0) {
                                sPrintLanguage = sWebLanguage;
                            }

                            String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");
                        %>

                        <select class="text" name="PrintLanguage">
                            <%
                                String tmpLang;
                                StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages, ",");
                                while (tokenizer.hasMoreTokens()) {
                                    tmpLang = tokenizer.nextToken();

                                    %><option value="<%=tmpLang%>"<%if (tmpLang.equalsIgnoreCase(sPrintLanguage)){out.print(" selected");}%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
                                }
                            %>
                        </select>
                        <select class="text" name="PrintType">
                            <option value="sortbydate" <%=MedwanQuery.getInstance().getConfigString("defaultInvoiceSortType","sortbydate").equalsIgnoreCase("sortbydate")?"selected":""%>><%=getTran("web","sortbydate",sWebLanguage)%></option>
                            <option value="sortbypatient" <%=MedwanQuery.getInstance().getConfigString("defaultInvoiceSortType","sortbydate").equalsIgnoreCase("sortbypatient")?"selected":""%>><%=getTran("web","sortbypatient",sWebLanguage)%></option>
                        </select>
                        <%
                        	String defaultmodel=MedwanQuery.getInstance().getConfigString("defaultExtraInvoiceModel","default");
                        	if(insurarInvoice.getInsurar()!=null && insurarInvoice.getInsurar().getDefaultInsurarInvoiceModel()!=null){
                        		defaultmodel=insurarInvoice.getInsurar().getDefaultInsurarInvoiceModel();
                        	}
                        %>
                        <select class="text" name="PrintModel">
                            	<option value="default" <%=defaultmodel.equalsIgnoreCase("default")?"selected":""%>><%=getTranNoLink("web","defaultmodel",sWebLanguage)%></option>
                            <%	
                            	if(MedwanQuery.getInstance().getConfigInt("enableRwanda",1)==1){ 
                            %>
	                            <option value="ramanew" <%=defaultmodel.equalsIgnoreCase("ramanew")?"selected":""%>><%=getTranNoLink("web","ramanewmodel",sWebLanguage)%></option>
	                            <option value="ctams" <%=defaultmodel.equalsIgnoreCase("ctams")?"selected":""%>><%=getTranNoLink("web","ctamsmodel",sWebLanguage)%></option>
	                        <%	
	                        	}
		                      	if(MedwanQuery.getInstance().getConfigInt("enableMFP",0)==1){
		                    %>
                            	<option value="mfp" <%=defaultmodel.equalsIgnoreCase("mfp")?"selected":""%>><%=getTranNoLink("web","mfpmodel",sWebLanguage)%></option>
                           	<%
                 				}
		                    	if(MedwanQuery.getInstance().getConfigInt("enableBurundi",0)==1){
                           	%>
                            	<option value="hmk" <%=defaultmodel.equalsIgnoreCase("hmk")?"selected":""%>><%=getTranNoLink("web","hmkmodel",sWebLanguage)%></option>
	                            <option value="cplrcsv2" <%=defaultmodel.equalsIgnoreCase("cplrcsv")?"selected":""%>><%=getTranNoLink("web","cplrcsvmodel",sWebLanguage)%></option>
                            <%
		                    	}
                            %>
                        </select>
                            <%
                                if(insurarInvoice.getStatus().equalsIgnoreCase("closed")){
                            %>
                                <input class="button" type="button" name="ButtonPrint" value='<%=getTranNoLink("Web","printinvoice",sWebLanguage)%>' onclick="doPrintPdf('<%=insurarInvoice.getUid()%>');">
                            <%
                                }
                                else{
                            %>
                                <input class="button" type="button" name="ButtonPrint" value='<%=getTranNoLink("Web","printprestationlist",sWebLanguage)%>' onclick="doPrintPdf('<%=insurarInvoice.getUid()%>');">
                            <%
                                }
                            }
                        %>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<%=getTran("Web", "colored_fields_are_obligate", sWebLanguage)%>.
<div id="divMessage"></div>
<input type='hidden' name='EditInsurarInvoiceUID' id='EditInsurarInvoiceUID' value='<%=checkString(insurarInvoice.getUid())%>'>
</form>
<script>
function doSave() {

    if ((EditForm.EditDate.value.length > 0) && (EditForm.EditStatus.selectedIndex > -1 && EditForm.EditInsurarUID.value.length>0)) {
        var sCbs = "";
        for (i = 0; i < EditForm.elements.length; i++) {
            elm = EditForm.elements[i];

            if ((elm.type == 'checkbox') && (elm.checked)) {
                sCbs += elm.name.split("=")[0].replace("cbDebet","d").replace("cbInsurarInvoice","c") + ",";
            }
        }

        EditForm.ButtonSave.disabled = true;
        var today = new Date();
        var url = '<c:url value="/financial/extraInsuranceInvoiceSave.jsp"/>?ts=' + today;
        document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Saving";
        new Ajax.Request(url, {
            method: "POST",
            postBody: 'EditDate=' + EditForm.EditDate.value
                    + '&EditInsurarInvoiceUID=' + EditForm.EditInsurarInvoiceUID.value
                    + '&EditInvoiceUID=' + EditForm.EditInvoiceUID.value
                    + '&EditInsurarUID=' + EditForm.EditInsurarUID.value
                    + '&EditStatus=' + EditForm.EditStatus.value
                    + '&EditCBs=' + sCbs
                    + '&EditBalance=' + EditForm.EditBalance.value,
            onSuccess: function(resp) {
                var label = eval('(' + resp.responseText + ')');
                $('divMessage').innerHTML = label.Message;
                $('EditInsurarInvoiceUID').value = label.EditInsurarInvoiceUID;
                $('EditInvoiceUID').value = label.EditInvoiceUID;
                $('FindInsurarInvoiceUID').value = label.EditInvoiceUID;
                EditForm.ButtonSave.disabled = false;
                window.setTimeout("loadOpenInsurarInvoices()",200);
                window.setTimeout("doFind()",200);
            },
            onFailure: function() {
                $('divMessage').innerHTML = "Error in function manageTranslationsStore() => AJAX";
            }
        }
                );
    }
    else {
        var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl, '', modalities):window.confirm('<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>');
    }
}

function countDebets(){
    var tot=0;
    for (i = 0; i < EditForm.elements.length; i++) {
        var elm = EditForm.elements[i];
        if (elm.name.indexOf('cbDebet') > -1) {
            if (elm.checked) {
                var amount = elm.name.split("=")[1];
                tot = tot + parseFloat(amount.replace(",","."));
            }
        }
    }
    return tot;
}

function countCredits(){
    var tot=0;
    for (i = 0; i < EditForm.elements.length; i++) {
        var elm = EditForm.elements[i];
        if (elm.name.indexOf('cbInsurarInvoice') > -1) {
            if (elm.checked) {
                var amount = elm.name.split("=")[1];
                tot = tot + parseFloat(amount.replace(",","."));
            }
        }
    }
    return tot;
}

function updateBalance(){
    EditForm.EditBalance.value = countDebets()+countCredits();
    EditForm.EditBalance.value = format_number(EditForm.EditBalance.value, <%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
}

function selectAll(sStartsWith, bValue, buttonDisable, buttonEnable, bAdd) {
    var tot=0;
    for (i = 0; i < EditForm.elements.length; i++) {
        var elm = EditForm.elements[i];

        if (elm.name.indexOf(sStartsWith) > -1) {
            if ((elm.type == 'checkbox') && (elm.checked != bValue)) {
                elm.checked = bValue;
            }
        }
    }
	updateBalance();
}

function doBalance(oObject, bAdd) {
    var amount = oObject.name.split("=")[1];

    if (bAdd) {
        if (oObject.checked) {
            EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",",".")) + parseFloat(amount.replace(",","."));
        }
        else {
            EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",",".")) - parseFloat(amount.replace(",","."));
        }
    }
    else {
        if (oObject.checked) {
            EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",",".")) - parseFloat(amount.replace(",","."));
        }
        else {
            EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",",".")) + parseFloat(amount.replace(",","."));
        }
    }
    EditForm.EditBalance.value = format_number(EditForm.EditBalance.value, <%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
}

<%-- PRINT PDF --%>
function doPrintPdf(invoiceUid) {
    if(EditForm.PrintModel.value=='cplrcsv2'){
		var url = "<c:url value='/util/csvDocs.jsp'/>?invoiceuid=" + invoiceUid + "&ts=<%=getTs()%>&docid=invoice.cplr2";
	    window.open(url, "ExtraInsurarInvoicePdf<%=new java.util.Date().getTime()%>", "height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
    }
    else {
	    var url = "<c:url value='/financial/createExtraInsurarInvoicePdf.jsp'/>?InvoiceUid=" + invoiceUid + "&ts=<%=getTs()%>&PrintLanguage=" + EditForm.PrintLanguage.value+ "&PrintType="+EditForm.PrintType.value+"&PrintModel="+EditForm.PrintModel.value;
   		window.open(url, "InsurarInvoicePdf<%=new java.util.Date().getTime()%>", "height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
    }
}

function searchInsurar() {
    openPopup("/_common/search/searchInsurar.jsp&ts=<%=getTs()%>&ReturnFieldInsurarUid=EditInsurarUID&ReturnFieldInsurarName=EditInsurarText&doFunction=changeInsurar()&excludePatientSelfIsurarUID=true&PopupHeight=500&PopupWith=500");
}

function doClearInsurar() {
    EditForm.EditInsurarUID.value = "";
    EditForm.EditInsurarText.value = "";
}

function doStatus() {
}

function loadOpenInsurarInvoices() {
    var params = '';
    var today = new Date();
    var url = '<c:url value="/financial/extraInsurarInvoiceGetOpenInsurarInvoices.jsp"/>?ts=' + today;
    new Ajax.Request(url, {
        method: "GET",
        parameters: params,
        onSuccess: function(resp) {
            $('divOpenInsurarInvoices').innerHTML = resp.responseText;
        }
    }
            );
}

function setInsurarInvoice(sUid) {
    FindForm.FindInsurarInvoiceUID.value = sUid;
    FindForm.submit();
}

function changeInsurar() {
	var tot=0;
    if(EditForm.EditInsurarUID.value.length>0){
        document.getElementById("invoicedetails").style.visibility="visible";
        document.getElementById("invoicedetailstable").style.visibility="visible";
    }
    else {
        document.getElementById("invoicedetails").style.visibility="hidden";
        document.getElementById("invoicedetailstable").style.visibility="hidden";
    }
    var url = '<c:url value="/financial/extraInsurarInvoiceGetPrestations.jsp"/>?ts=' + <%=getTs()%>;
    document.getElementById('divPrestations').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
    var pb= 'InsurarUid=' + EditForm.EditInsurarUID.value
            + '&EditBegin=' + EditForm.EditBegin.value
            + '&EditEnd=' + EditForm.EditEnd.value
            + '&EditInvoiceService=' + EditForm.EditInvoiceService.value
            + '&EditInsurarInvoiceUID=<%=checkString(insurarInvoice.getUid())%>';

    new Ajax.Request(url, {
        method: "POST",
        postBody: pb,
        onSuccess: function(resp) {
            var s=resp.responseText;
            s=s.replace(/<1>/g,"<input type='checkbox' name='cbDebet");
            s=s.replace(/<2>/g,"' onclick='doBalance(this, true)' ");
            $('divPrestations').innerHTML = s;
            tot=tot+countDebets();
            document.getElementById('EditBalance').value=tot;
        }
    }
            );

    var url = '<c:url value="/financial/extraInsurarInvoiceGetCredits.jsp"/>?ts='  + <%=getTs()%>;
    document.getElementById('divCredits').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
    new Ajax.Request(url, {
        method: "POST",
        postBody: 'InsurarUid=' + EditForm.EditInsurarUID.value
                + '&EditInsurarInvoiceUID=<%=checkString(insurarInvoice.getUid())%>',
        onSuccess: function(resp) {
            $('divCredits').innerHTML = resp.responseText;
            tot=tot-countCredits();
            document.getElementById('EditBalance').value=tot;
        }
    }
            );
    if(document.getElementById("invoicedetails").style.visibility=="visible" && !(EditForm.EditInsurarUID.value.length>0 && (document.getElementById("EditStatus").value=='closed' || document.getElementById("EditStatus").value=='canceled'))){
        document.getElementById('period').style.visibility='visible';
    }
    else {
        document.getElementById('period').style.visibility='hidden';
    }
}

function searchService(serviceUidField,serviceNameField){
    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
    document.getElementById(serviceNameField).focus();
}

FindForm.FindInsurarInvoiceUID.focus();
loadOpenInsurarInvoices();
window.setTimeout("changeInsurar()",200);
</script>