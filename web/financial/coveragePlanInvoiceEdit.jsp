<%@page import="be.openclinic.finance.*,
                java.util.Date,
                java.text.DecimalFormat"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("financial.reimbursements","edit",activeUser)%>
<%=sJSPROTOTYPE%>
<%=sJSNUMBER%>

<%
    String sFindCoveragePlanInvoiceUID = checkString(request.getParameter("FindCoveragePlanInvoiceUID"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n***************** financial/coveragePlanInvoiceEdit.jsp ****************");
		Debug.println("sFindCoveragePlanInvoiceUID : "+sFindCoveragePlanInvoiceUID+"\n");
	}    
	///////////////////////////////////////////////////////////////////////////////////////////////

    CoveragePlanInvoice coveragePlanInvoice;
    String sInsurarText = "";
    if(sFindCoveragePlanInvoiceUID.length() > 0){
    	coveragePlanInvoice = CoveragePlanInvoice.getViaInvoiceUID(sFindCoveragePlanInvoiceUID);
        Insurar insurar = Insurar.get(checkString(coveragePlanInvoice.getInsurarUid()));
        if(insurar!=null){
            sInsurarText = checkString(insurar.getName());
        }
    }
    else{
        coveragePlanInvoice = new CoveragePlanInvoice();
    }
%>
<form name='FindForm' id="FindForm" method='POST'>
    <%=writeTableHeader("web","coveragePlanInvoiceEdit",sWebLanguage,"")%>
    
    <table class="menu" width="100%">
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web.finance","reimbursement.documentid",sWebLanguage)%></td>
            <td>
                <input type="text" class="text" name="FindCoveragePlanInvoiceUID" id="FindCoveragePlanInvoiceUID" onblur="isNumber(this)" value="<%=sFindCoveragePlanInvoiceUID%>">
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchCoveragePlanInvoice();">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="doClearCoveragePlanInvoice()">

                <%-- BUTTONS --%>
                <input type="button" class="button" name="ButtonFind" value="<%=getTranNoLink("web","find",sWebLanguage)%>" onclick="doFind()">
                <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="doNew();searchInsurar();">
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("web","clear",sWebLanguage)%>" onclick="doClear()">
            </td>
        </tr>
    </table>
</form>

<script>
  FindForm.FindCoveragePlanInvoiceUID.focus();

  function searchCoveragePlanInvoice(){
    openPopup("/_common/search/searchCoveragePlanInvoice.jsp&ts=<%=getTs()%>&doFunction=doFind()&ReturnFieldInvoiceNr=FindCoveragePlanInvoiceUID&FindInvoiceInsurar=<%=sFindCoveragePlanInvoiceUID%>");
  }

  function doFind(){
    if(FindForm.FindCoveragePlanInvoiceUID.value.length > 0){
      FindForm.submit();
    }
  }

  function doNew(){
    FindForm.FindCoveragePlanInvoiceUID.value = "";
    FindForm.submit();
  }

  function doClear(){
    doClearCoveragePlanInvoice();
  }

  function doClearCoveragePlanInvoice(){
    FindForm.FindCoveragePlanInvoiceUID.value = "";
    FindForm.FindCoveragePlanInvoiceUID.focus();
  }
</script>

<div id="divOpenCoveragePlanInvoices" style="height:120px;" class="searchResults"></div>

<form name='EditForm' id="EditForm" method='POST'>
    <input type='hidden' name='EditServiceUID' id='EditServiceUID' value=''/>

<table class='list' border='0' width='100%' cellspacing='1'>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","coverageplan",sWebLanguage)%></td>
        <td class="admin2">
            <input type="hidden" name="EditInsurarUID" value="<%=checkString(coveragePlanInvoice.getInsurarUid())%>">
            <input type="text" class="text" readonly name="EditInsurarText" value="<%=sInsurarText%>" size="100">
            <%
                if(checkString(coveragePlanInvoice.getUid()).length() == 0){
		            %>
		            <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInsurar();">
		            <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="doClearInsurar()">
		            <%
                }
            %>
        </td>
    </tr>
    
    <%-- DETAILS --%>
    <tr id="invoicedetails" style="visibility:hidden">
        <td colspan="2">
            <table class='list' width='100%' cellspacing='1' id="invoicedetailstable">
                <%-- DOCUMENT ID --%>
                <tr>
                    <td class="admin"><%=getTran("web.finance","reimbursement.documentid",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="text" class="text" readonly name="EditInvoiceUID" id="EditInvoiceUID" value="<%=checkString(coveragePlanInvoice.getInvoiceUid())%>">
                    </td>
                </tr>
                
                <%-- DATE --%>
                <tr>
                    <td class='admin'><%=getTran("Web","date",sWebLanguage)%> *</td>
                    <%
                        Date activeDate = coveragePlanInvoice.getDate();
                        if(activeDate==null) activeDate = new Date();
                    %>
                    <td class='admin2'><%=writeDateField("EditDate","EditForm",ScreenHelper.getSQLDate(activeDate),sWebLanguage)%></td>
                </tr>
                
                <%-- STATUS --%>
                <tr>
                    <td class='admin'><%=getTran("Web.finance","patientinvoice.status",sWebLanguage)%> *</td>
                    <td class='admin2'>
                        <select class="text" id="EditStatus" name="EditStatus" onchange="doStatus()" <%=coveragePlanInvoice.getStatus()!=null && (coveragePlanInvoice.getStatus().equalsIgnoreCase("closed") || coveragePlanInvoice.getStatus().equalsIgnoreCase("canceled"))?"disabled":""%>>
                            <option/>
                            <%
                                String activeStatus = checkString(coveragePlanInvoice.getStatus());
                                if(activeStatus.length() == 0){
                                    activeStatus = "open";
                                }
                            %>
                            <%=ScreenHelper.writeSelect("finance.patientinvoice.status",activeStatus,sWebLanguage)%>
                        </select>
                    </td>
                </tr>
                
                <%-- PERIOD --%>
                <tr id="period" style="visibility: hidden">
                    <td class='admin'><%=getTran("web","period",sWebLanguage)%></td>
                    <td class="admin2">
                        <%
                            Date previousmonth=new Date(ScreenHelper.parseDate(new SimpleDateFormat("01/MM/yyyy").format(new Date())).getTime()-1);
                        %>
                        <%=writeDateField("EditBegin","EditForm",new SimpleDateFormat("01/MM/yyyy").format(previousmonth),sWebLanguage)%>
                        <%=getTran("web","to",sWebLanguage)%>
                        <%=writeDateField("EditEnd","EditForm",ScreenHelper.stdDateFormat.format(previousmonth),sWebLanguage)%>
                     
                        &nbsp;<input type="button" class="button" name="update" value="<%=getTranNoLink("web","update",sWebLanguage)%>" onclick="changeCoveragePlan();"/>
                        &nbsp;<input type="button" class="button" name="updateBalance" value="<%=getTranNoLink("web","updateBalance",sWebLanguage)%>" onclick="updateBalance();"/>
                    </td>
                </tr>
                
                <%-- BALANCE --%>
                <tr>
                    <td class='admin'><%=getTran("web.finance","balance",sWebLanguage)%></td>
                    <td class='admin2'>
                        <input class='text' readonly type='text' id='EditBalance' name='EditBalance' value='<%=new DecimalFormat("#.#").format(coveragePlanInvoice.getBalance())%>' size='20'> <%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
                    </td>
                </tr>
                
                <%-- PRESTATIONS --%>
                <tr>
                    <td class='admin'><%=getTran("web","prestations",sWebLanguage)%></td>
                    <td class='admin2'>
                        <div id="divPrestations" style="height:120px;" class="searchResults"></div>
                        <input class='button' type="button" name="ButtonDebetSelectAll" id="ButtonDebetSelectAll" value="<%=getTranNoLink("web","selectall",sWebLanguage)%>" onclick="selectAll('cbDebet',true,'ButtonDebetSelectAll','ButtonDebetDeselectAll',true);">&nbsp;
                        <input class='button' type="button" name="ButtonDebetDeselectAll" id="ButtonDebetDeselectAll" value="<%=getTranNoLink("web","deselectall",sWebLanguage)%>" onclick="selectAll('cbDebet',false,'ButtonDebetDeselectAll','ButtonDebetSelectAll',true);">
                    </td>
                </tr>
                
                <%-- CREDITS --%>
                <tr>
                    <td class='admin'><%=getTran("web.finance","credits",sWebLanguage)%></td>
                    <td class='admin2'>
                        <div id="divCredits" style="height:120px;" class="searchResults"></div>
                      
                        <input class='button' type="button" name="ButtoncoveragePlanInvoiceSelectAll" id="ButtoncoveragePlanInvoiceSelectAll" value="<%=getTranNoLink("web","selectall",sWebLanguage)%>" onclick="selectAll('cbcoveragePlanInvoice',true,'ButtoncoveragePlanInvoiceSelectAll','ButtoncoveragePlanInvoiceDeselectAll',false);">&nbsp;
                        <input class='button' type="button" name="ButtoncoveragePlanInvoiceDeselectAll" id="ButtoncoveragePlanInvoiceDeselectAll" value="<%=getTranNoLink("web","deselectall",sWebLanguage)%>" onclick="selectAll('cbcoveragePlanInvoice',false,'ButtoncoveragePlanInvoiceDeselectAll','ButtoncoveragePlanInvoiceSelectAll',false);">
                    </td>
                </tr>
                
                <%-- BUTTONS --%>
                <tr>
                    <td class="admin"/>
                    <td class="admin2">
                        <%
                            if(!(checkString(coveragePlanInvoice.getStatus()).equalsIgnoreCase("closed")||checkString(coveragePlanInvoice.getStatus()).equalsIgnoreCase("canceled"))){
                                %><input class='button' type="button" name="ButtonSave" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave(this);">&nbsp;<%
                            }

                            // pdf print button for existing invoices
                            if(checkString(coveragePlanInvoice.getUid()).length() > 0){
                        %>
                        <%=getTran("Web.Occup","PrintLanguage",sWebLanguage)%>

                        <%
                            String sPrintLanguage = activeUser.person.language;
                            if(sPrintLanguage.length() == 0){
                                sPrintLanguage = sWebLanguage;
                            }

                            String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");
                        %>

                        <select class="text" name="PrintLanguage">
                            <%
                                String tmpLang;
                                StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages,",");
                                while (tokenizer.hasMoreTokens()){
                                    tmpLang = tokenizer.nextToken();

                                    %><option value="<%=tmpLang%>"<%if(tmpLang.equalsIgnoreCase(sPrintLanguage)){out.print(" selected");}%>><%=getTranNoLink("Web.language",tmpLang,sWebLanguage)%></option><%
                                }
                            %>
                        </select>
                        
                        <select class="text" name="PrintType">
                            <option value="sortbydate" <%=MedwanQuery.getInstance().getConfigString("defaultInvoiceSortType","sortbydate").equalsIgnoreCase("sortbydate")?"selected":""%>><%=getTran("web","sortbydate",sWebLanguage)%></option>
                            <option value="sortbypatient" <%=MedwanQuery.getInstance().getConfigString("defaultInvoiceSortType","sortbydate").equalsIgnoreCase("sortbypatient")?"selected":""%>><%=getTran("web","sortbypatient",sWebLanguage)%></option>
                        </select>
                        
                        <select class="text" name="PrintModel">
                            <option value="default" <%=MedwanQuery.getInstance().getConfigString("defaultIncomingInvoiceModel","default").equalsIgnoreCase("default")?"selected":""%>><%=getTranNoLink("web","defaultmodel",sWebLanguage)%></option>
                        </select>
                        	<%
	                            if(coveragePlanInvoice.getStatus().equalsIgnoreCase("closed")){
	                                %><input class="button" type="button" name="ButtonPrint" value='<%=getTranNoLink("Web","printreimbursementnote",sWebLanguage)%>' onclick="doPrintPdf('<%=coveragePlanInvoice.getUid()%>');"><%
	                            }
	                            else{
	                                %><input class="button" type="button" name="ButtonPrint" value='<%=getTranNoLink("Web","printproformareimbursementnote",sWebLanguage)%>' onclick="doPrintPdf('<%=coveragePlanInvoice.getUid()%>');"><%
	                            }
                            }
                        %>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
<%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>

<div id="divMessage"></div>

<input type='hidden' name='EditCoveragePlanInvoiceUID' id='EditCoveragePlanInvoiceUID' value='<%=checkString(coveragePlanInvoice.getUid())%>'>
</form>

<script>
  <%-- DO SAVE --%>
  function doSave(){
    if((EditForm.EditDate.value.length > 0) && (EditForm.EditStatus.selectedIndex > -1 && EditForm.EditInsurarUID.value.length>0)){
      var sCbs = "";
      for(i=0; i < EditForm.elements.length; i++){
        elm = EditForm.elements[i];

        if(elm.type=='checkbox' && elm.checked){
          sCbs+= elm.name.split("=")[0].replace("cbDebet","d").replace("cbcoveragePlanInvoice","c")+",";
        }
      }
     
      EditForm.ButtonSave.disabled = true;
      var url = '<c:url value="/financial/coveragePlanInvoiceSave.jsp"/>?ts='+new Date();
      document.getElementById('divMessage').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Saving";
      new Ajax.Request(url,{
        method: "POST",
        postBody: 'EditDate='+EditForm.EditDate.value
                 +'&EditCoveragePlanInvoiceUID='+EditForm.EditCoveragePlanInvoiceUID.value
                 +'&EditInvoiceUID='+EditForm.EditInvoiceUID.value
                 +'&EditInsurarUID='+EditForm.EditInsurarUID.value
                 +'&EditStatus='+EditForm.EditStatus.value
                 +'&EditCBs='+sCbs
                 +'&EditBalance='+EditForm.EditBalance.value,
        onSuccess: function(resp){
          var label = eval('('+resp.responseText+')');
          $('divMessage').innerHTML = label.Message;
          $('EditCoveragePlanInvoiceUID').value = label.EditCoveragePlanInvoiceUID;
          $('EditInvoiceUID').value = label.EditInvoiceUID;
          $('FindCoveragePlanInvoiceUID').value = label.EditInvoiceUID;
          EditForm.ButtonSave.disabled = false;
          window.setTimeout("loadOpenCoveragePlanInvoices()",200);
          window.setTimeout("doFind()",200);
        },
        onFailure: function(){
          $('divMessage').innerHTML = "Error in function manageTranslationsStore() => AJAX";
        }
      });
    }
    else{
                window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
    }
  }

  <%-- COUNT DEBETS --%>
  function countDebets(){
    var tot = 0;
    for(i=0; i < EditForm.elements.length; i++){
      var elm = EditForm.elements[i];
      if(elm.name.indexOf('cbDebet') > -1){
        if(elm.checked){
          var amount = elm.name.split("=")[1];
          tot = tot+parseFloat(amount.replace(",","."));
        }
      }
    }
    return tot;
  }

<%-- COUNT CREDITS --%>
function countCredits(){
  var tot=0;
  for(i=0; i < EditForm.elements.length; i++){
    var elm = EditForm.elements[i];
    if(elm.name.indexOf('cbcoveragePlanInvoice') > -1){
      if(elm.checked){
        var amount = elm.name.split("=")[1];
        tot = tot+parseFloat(amount.replace(",","."));
      }
    }
  }
  return tot;
}

<%-- UPDATE BALANCE --%>
function updateBalance(){
  EditForm.EditBalance.value = countDebets()+countCredits();
  EditForm.EditBalance.value = format_number(EditForm.EditBalance.value,<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
}

<%-- SELECT ALL --%>
function selectAll(sStartsWith,bValue,buttonDisable,buttonEnable,bAdd){
  var tot=0;
  for(i=0; i < EditForm.elements.length; i++){
    var elm = EditForm.elements[i];

    if(elm.name.indexOf(sStartsWith) > -1){
      if(elm.type=='checkbox' && elm.checked!=bValue){
        elm.checked = bValue;
      }
    }
  }
  updateBalance();
}

<%-- DO BALANCE --%>
function doBalance(oObject,bAdd){
  var amount = oObject.name.split("=")[1];

  if(bAdd){
    if(oObject.checked){
      EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",","."))+parseFloat(amount.replace(",","."));
    }
    else {
      EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",",".")) - parseFloat(amount.replace(",","."));
    }
  }
  else {
    if(oObject.checked){
      EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",",".")) - parseFloat(amount.replace(",","."));
    }
    else {
      EditForm.EditBalance.value = parseFloat(EditForm.EditBalance.value.replace(",","."))+parseFloat(amount.replace(",","."));
    }
  }
  EditForm.EditBalance.value = format_number(EditForm.EditBalance.value,<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
}

<%-- PRINT PDF --%>
function doPrintPdf(invoiceUid){
  var url = "<c:url value='/financial/createCoveragePlanInvoicePdf.jsp'/>?InvoiceUid="+invoiceUid+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value+ "&PrintType="+EditForm.PrintType.value+"&PrintModel="+EditForm.PrintModel.value;
  window.open(url,"coveragePlanInvoicePdf<%=getTs()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
}

function searchInsurar(){
  openPopup("/_common/search/searchCoveragePlan.jsp&ts=<%=getTs()%>&VarCompUID=EditInsurarUID&VarText=EditInsurarText&doFunction=changeCoveragePlan()&PopupHeight=500&PopupWith=500");
}

function doClearInsurar(){
  EditForm.EditInsurarUID.value = "";
  EditForm.EditInsurarText.value = "";
}

function doStatus(){
  // empty
}

<%-- LOAD OPEN COVERAGE PLAN INVOICES --%>
function loadOpenCoveragePlanInvoices(){
  var url = '<c:url value="/financial/coveragePlanInvoiceGetOpenCoveragePlanInvoices.jsp"/>?ts='+new Date();
  new Ajax.Request(url,{
    method: "GET",
    parameters: "",
    onSuccess: function(resp){
      $('divOpenCoveragePlanInvoices').innerHTML = resp.responseText;
    }
  });
}

function setCoveragePlanInvoice(sUid){
  FindForm.FindCoveragePlanInvoiceUID.value = sUid;
  FindForm.submit();
}

<%-- CHANGE COVERAGE PLAN --%>
function changeCoveragePlan(){
  var tot = 0;
  if(EditForm.EditInsurarUID.value.length>0){
    document.getElementById("invoicedetails").style.visibility="visible";
    document.getElementById("invoicedetailstable").style.visibility="visible";
  }
  else{
    document.getElementById("invoicedetails").style.visibility="hidden";
    document.getElementById("invoicedetailstable").style.visibility="hidden";
  }
  
  var url = '<c:url value="/financial/coveragePlanInvoiceGetPrestations.jsp"/>?ts='+new Date();
  document.getElementById('divPrestations').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading..";
  
  var pb= 'InsurarUid='+EditForm.EditInsurarUID.value
         +'&EditBegin='+EditForm.EditBegin.value
         +'&EditEnd='+EditForm.EditEnd.value
         +'&EditServiceUID='+EditForm.EditServiceUID.value
         +'&EditCoveragePlanInvoiceUID=<%=checkString(coveragePlanInvoice.getUid())%>';
  new Ajax.Request(url,{
    method: "POST",
    postBody: pb,
    onSuccess: function(resp){
      var s=resp.responseText;
      s=s.replace(/<1>/g,"<input type='checkbox' name='cbDebet");
      s=s.replace(/<2>/g,"' onclick='doBalance(this,true)' ");
      $('divPrestations').innerHTML = s;
      tot=tot+countDebets();
      document.getElementById('EditBalance').value=tot;
    }
  });

  var url = '<c:url value="/financial/coveragePlanInvoiceGetCredits.jsp"/>?ts=' +<%=getTs()%>;
  document.getElementById('divCredits').innerHTML = "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br/>Loading..";
  new Ajax.Request(url,{
    method: "POST",
    postBody: 'InsurarUid='+EditForm.EditInsurarUID.value
             +'&EditCoveragePlanInvoiceUID=<%=checkString(coveragePlanInvoice.getUid())%>',
    onSuccess: function(resp){
      $('divCredits').innerHTML = resp.responseText;
      tot=tot-countCredits();
      document.getElementById('EditBalance').value=tot;
    }
  });
  
  if(document.getElementById("invoicedetails").style.visibility=="visible" && !(EditForm.EditInsurarUID.value.length>0 && (document.getElementById("EditStatus").value=='closed' || document.getElementById("EditStatus").value=='canceled'))){
    document.getElementById('period').style.visibility='visible';
  }
  else{
     document.getElementById('period').style.visibility='hidden';
  }
}

function selectService(serviceid){
  document.getElementById("EditServiceUID").value=serviceid;
  changeCoveragePlan();
}

FindForm.FindCoveragePlanInvoiceUID.focus();
loadOpenCoveragePlanInvoices();
window.setTimeout("changeCoveragePlan();",1000);
</script>