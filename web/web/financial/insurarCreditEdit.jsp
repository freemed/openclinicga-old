<%@page import="be.openclinic.finance.InsurarCredit, be.openclinic.finance.Insurar"%>
<%@include file="/includes/validateUser.jsp"%>
<%@include file="/includes/ajaxRequirements.jsp"%>
<%=checkPermission("financial.insurarCreditEdit","edit",activeUser)%>
<%
    String sAction = checkString(request.getParameter("Action"));

    String sEditCreditUid        = checkString(request.getParameter("EditCreditUid")),
           sEditCreditDate       = checkString(request.getParameter("EditCreditDate")),
           sEditCreditInsurarUid = checkString(request.getParameter("EditCreditInsurarUid")),
           sEditCreditInvoiceUid = checkString(request.getParameter("EditCreditInvoiceUid")),
           sEditCreditInvoiceNr  = checkString(request.getParameter("EditCreditInvoiceNr")),
           sEditCreditAmount     = checkString(request.getParameter("EditCreditAmount")),
           sEditCreditType       = checkString(request.getParameter("EditCreditType")),
           sEditCreditDescr      = checkString(request.getParameter("EditCreditDescription"));
    
    String sFindDateBegin        = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd          = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin        = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax        = checkString(request.getParameter("FindAmountMax")),
           sFindCreditInsurarUid = checkString(request.getParameter("FindCreditInsurarUid")),
           sFindCreditInsurarName= checkString(request.getParameter("FindCreditInsurarName"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n################## insurarEditCredit : "+sAction+" ###############");
        System.out.println("* sEditCreditUid        : "+sEditCreditUid);
        System.out.println("* sEditCreditInsurarUid : "+sEditCreditInsurarUid);
        System.out.println("* sEditCreditDate       : "+sEditCreditDate);
        System.out.println("* sEditCreditInvoiceUid : "+sEditCreditInvoiceUid);
        System.out.println("* sEditCreditInvoiceNr  : "+sEditCreditInvoiceNr);
        System.out.println("* sEditCreditAmount     : "+sEditCreditAmount);
        System.out.println("* sEditCreditType       : "+sEditCreditType);
        System.out.println("* sEditCreditDescr      : "+sEditCreditDescr+"\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////

    String sEditCreditInsurarName, msg = "";

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        InsurarCredit credit;
        if(sEditCreditUid.length() > 0){
            credit = InsurarCredit.get(sEditCreditUid);
        }
        else{
            credit = new InsurarCredit();
            credit.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }

        credit.setDate(ScreenHelper.getSQLDate(sEditCreditDate));
        credit.setInsurarUid(sEditCreditInsurarUid);
        credit.setInvoiceUid(sEditCreditInvoiceUid);
        credit.setAmount(Double.parseDouble(sEditCreditAmount));
        credit.setType(sEditCreditType);
        credit.setComment(sEditCreditDescr);

        credit.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        credit.setUpdateUser(activeUser.userid);
        credit.store(Integer.parseInt(activeUser.userid));

        msg = getTran("web","dataIsSaved",sWebLanguage);
    }

    //--- LOAD SPECIFIED CREDIT -------------------------------------------------------------------
    if ((sEditCreditUid.length() > 0)&&(!sAction.equalsIgnoreCase("save"))){
        InsurarCredit credit = InsurarCredit.get(sEditCreditUid);

        sEditCreditUid         = credit.getUid();
        sEditCreditDate        = checkString(new SimpleDateFormat("dd/MM/yyyy").format(credit.getDate()));
        sEditCreditInsurarUid  = credit.getInsurarUid();
        sEditCreditInsurarName = Insurar.get(sEditCreditInsurarUid).getName();
        sEditCreditInvoiceUid  = credit.getInvoiceUid();
        sEditCreditInvoiceNr   = sEditCreditInvoiceUid.substring(sEditCreditInvoiceUid.indexOf(".")+1);
        sEditCreditAmount      = Double.toString(credit.getAmount());
        sEditCreditDescr       = credit.getComment();
        sEditCreditType        = credit.getType();
    }
    else{
        // new credit
        sEditCreditUid         = "";
        sEditCreditDate        = getDate(); // now
        sEditCreditInsurarUid  = "";
        sEditCreditInsurarName = "";
        sEditCreditInvoiceUid  = "";
        sEditCreditInvoiceNr   = "";
        sEditCreditAmount      = "";
        sEditCreditType        = MedwanQuery.getInstance().getConfigString("defaultInsuranceCreditType","insurance.payment");
        sEditCreditDescr       = "";
    }

    if(sEditCreditType.length()==0) sEditCreditType = "insurance.payment";
%>
<form name="EditForm" id="EditForm" method="POST" onClick="clearMessage();">
    <%=writeTableHeader("financial","insurarCreditEdit",sWebLanguage," doBack();")%>
    <table class="menu" width="100%" cellspacing="0">
        <tr>
            <td><%=getTran("web","insurar",sWebLanguage)%>&nbsp;*</td>
            <td colspan="4">
                <input type="hidden" name="FindCreditInsurarUid" id="FindCreditInsurarUid" value="<%=sFindCreditInsurarUid%>">
                <input class="text" type="text" name="FindCreditInsurarName" id="FindCreditInsurarName" readonly size="60" value="<%=sFindCreditInsurarName%>">
                <img src="<c:url value='/_img/icon_search.gif'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInsurar('FindCreditInsurarUid','FindCreditInsurarName');">
                <img src="<c:url value='/_img/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.FindCreditInsurarUid.value='';EditForm.FindCreditInsurarName.value='';">
            </td>
        </tr>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web.occup","medwan.common.date",sWebLanguage)%></td>
            <td width="100"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td width="150"><%=writeDateField("FindDateBegin","EditForm",sFindDateBegin,sWebLanguage)%></td>
            <td width="100"><%=getTran("Web","end",sWebLanguage)%></td>
            <td><%=writeDateField("FindDateEnd","EditForm",sFindDateEnd,sWebLanguage)%></td>
        </tr>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web","amount",sWebLanguage)%></td>
            <td><%=getTran("Web","min",sWebLanguage)%></td>
            <td><input type="text" class="text" name="FindAmountMin" id="FindAmountMin" value="<%=sFindAmountMin%>" onblur="isNumber(this)"></td>
            <td><%=getTran("Web","max",sWebLanguage)%></td>
            <td><input type="text" class="text" name="FindAmountMax" id="FindAmountMax" value="<%=sFindAmountMax%>" onblur="isNumber(this)"></td>
        </tr>
        <tr>
            <td/>
            <td colspan="4">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="loadUnassignedCredits(EditForm.FindCreditInsurarUid.value)">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFindFields()">&nbsp;
                <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="clearEditFields();">&nbsp;
            </td>
        </tr>
    </table>
    <br>
    <div id="divCredits" class="searchResults" style="height:122px">
        <%-- Filled by Ajax --%>
        <%=getTran("financial","selectInsurar",sWebLanguage)%>
        <br><br><br>
        <%-- Ajax loader logo --%>
        <div id="ajaxLoader" style="display:none;text-align:center;"><img src="<c:url value='/_img/ajax-loader.gif'/>"/><br>Loading...</div>
    </div>
    <br>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditCreditUid" value="<%=sEditCreditUid%>">
    <table class="list"width="100%" cellspacing="1">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","date",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2"><%=writeDateField("EditCreditDate","EditForm",sEditCreditDate,sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","insurar",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input type="hidden" name="EditCreditInsurarUid" value="<%=sEditCreditInsurarUid%>">
                <input class="text" type="text" name="EditCreditInsurarName" readonly size="60" value="<%=sEditCreditInsurarName%>">
                <%-- icons --%>
                <img src="<c:url value='/_img/icon_search.gif'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInsurar('EditCreditInsurarUid','EditCreditInsurarName');">
                <img src="<c:url value='/_img/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditCreditInsurarUid.value='';EditForm.EditCreditInsurarName.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","invoice",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input type="hidden" name="EditCreditInvoiceUid" value="<%=sEditCreditInvoiceUid%>">
                <input class="text" type="text" name="EditCreditInvoiceNr" readonly size="10" value="<%=sEditCreditInvoiceNr%>">
                <%-- icons --%>
                <img src="<c:url value='/_img/icon_search.gif'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInvoice('EditCreditInvoiceUid','EditCreditInvoiceNr','EditCreditAmount','EditCreditInsurarUid','EditCreditInsurarName');">
                <img src="<c:url value='/_img/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditCreditInvoiceUid.value='';EditForm.EditCreditInvoiceNr.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","amount",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input class="text" type="text" name="EditCreditAmount" value="<%=sEditCreditAmount%>" size="10" maxLength="9" onKeyUp="isNumberNegativeAllowed(this)">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","type",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <select class="text" name="EditCreditType">
                <option value=""></option>
                    <%=ScreenHelper.writeSelectUnsorted("credit.type",sEditCreditType,sWebLanguage)%>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","description",sWebLanguage)%></td>
            <td class="admin2"><%=writeTextarea("EditCreditDescription","","","",sEditCreditDescr)%></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input class="button" type="button" name="buttonSave" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;
            </td>
        </tr>
    </table>
    <%=getTran("web","asterisk_fields_are_obligate",sWebLanguage)%>
    <%-- display message --%>
    <br><br><span id="msgArea">&nbsp;<%=msg%></span>
</form>
<script>
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById("msgArea").innerHTML = "";<%
        }
    %>
  }

  function doSave(){
    if(EditForm.EditCreditDate.value.length > 0 &&
       EditForm.EditCreditInsurarUid.value.length > 0 &&
       EditForm.EditCreditInsurarName.value.length > 0 &&
       EditForm.EditCreditInvoiceUid.value.length > 0 &&
       EditForm.EditCreditAmount.value.length > 0 &&
       EditForm.EditCreditType.value.length > 0){
       EditForm.Action.value = "save";
       EditForm.submit();
    }
    else{
      if(EditForm.EditCreditDate.value.length==0){
        EditForm.EditCreditDate.focus();
      }
      else if(EditForm.EditCreditInsurarName.value.length==0){
        EditForm.EditCreditInsurarName.focus();
      }
      else if(EditForm.EditCreditAmount.value.length==0){
        EditForm.EditCreditAmount.focus();
      }
      else if(EditForm.EditCreditInvoiceUid.value.length==0){
        EditForm.EditCreditInvoiceNr.focus();
      }
      else if(EditForm.EditCreditType.value.length==0){
        EditForm.EditCreditType.focus();
      }

      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
    }
  }

  function searchInsurar(insurarUidField,insurarNameField){
    openPopup("/_common/search/searchInsurar.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldInsurarUid="+insurarUidField+
              "&ReturnFieldInsurarName="+insurarNameField);
  }

  function searchInvoice(invoiceUidField,invoiceNrField,invoiceBalanceField,insurarUidField,insurarNameField){
    var url = "/_common/search/searchInsurarInvoice.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldInvoiceUid="+invoiceUidField+
              "&ReturnFieldInvoiceNr="+invoiceNrField+
              "&FindInvoiceStatus=<%=MedwanQuery.getInstance().getConfigString("defaultInvoiceStatus","open")%>"+
              "&FindInvoiceInsurar="+EditForm.EditCreditInsurarUid.value+
              "&FindInvoiceBalanceMin=0.01"+
              "&Action=search";

    if(invoiceBalanceField!=undefined){
      url+= "&ReturnFieldInvoiceBalance="+invoiceBalanceField;
    }

    if(insurarUidField!=undefined){
      url+= "&ReturnFieldInsurarUid="+insurarUidField;
    }
      
    if(insurarNameField!=undefined){
      url+= "&ReturnFieldInsurarName="+insurarNameField;
    }

    openPopup(url);
  }             

  function loadUnassignedCredits(sInsurarUid){
      if (EditForm.FindCreditInsurarUid.value.length>0){
        document.getElementById('divCredits').innerHTML="<br><br><br><div id='ajaxLoader' style='display:block;text-align:center;'><img src='<c:url value='/_img/ajax-loader.gif'/>'/><br>Loading..</div>";
        var params = 'FindDateBegin=' + document.getElementById('FindDateBegin').value
                +"&FindDateEnd="+document.getElementById('FindDateEnd').value
                +"&FindAmountMin="+document.getElementById('FindAmountMin').value
                +"&FindAmountMax="+document.getElementById('FindAmountMax').value
                +"&insurarUid="+sInsurarUid;
        var today = new Date();
        var url= "<c:url value="/financial/getUnassignedInsurarCredits.jsp"/>?ts="+today;
        new Ajax.Request(url,
          {
            method: "GET",
            parameters: params,
            onSuccess: function(resp){
              $("divCredits").innerHTML = resp.responseText;
            },
            onFailure: function(){
            }
          }
        );
      }
  }

  function selectCredit(creditUid,creditDate,amount,type,descr, invoiceUid){
    EditForm.EditCreditUid.value = creditUid;
    EditForm.EditCreditDate.value = creditDate;
    EditForm.EditCreditAmount.value = amount;
    EditForm.EditCreditType.value = type;
    EditForm.EditCreditDescription.value = descr;
    EditForm.EditCreditInvoiceUid.value = invoiceUid;

    if (invoiceUid.indexOf(".")>-1){
        EditForm.EditCreditInvoiceNr.value = invoiceUid.split(".")[1];
    }
    else {
        EditForm.EditCreditInvoiceNr.value = "";
    }
    EditForm.EditCreditInsurarUid.value = EditForm.FindCreditInsurarUid.value;
    EditForm.EditCreditInsurarName.value = EditForm.FindCreditInsurarName.value;
  }

  function clearEditFields(){
    EditForm.EditCreditUid.value = "";
    EditForm.EditCreditDate.value = "<%=getDate()%>";
    EditForm.EditCreditInsurarUid.value = "";
    EditForm.EditCreditInsurarName.value = "";
    EditForm.EditCreditInvoiceUid.value = "";
    EditForm.EditCreditInvoiceNr.value = "";
    EditForm.EditCreditAmount.value = "";
    EditForm.EditCreditType.value = "<%=MedwanQuery.getInstance().getConfigString("defaultInsurarCreditType","insurance.payment")%>";
    EditForm.EditCreditDescription.value = "";
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=financial/historyBalance.jsp&ts=<%=getTs()%>";
  }

  function clearFindFields(){
      EditForm.FindDateBegin.value = "";
      EditForm.FindDateEnd.value = "";
      EditForm.FindAmountMin.value = "";
      EditForm.FindAmountMax.value = "";
  }

  EditForm.EditCreditDate.focus();
  loadUnassignedCredits(EditForm.FindCreditInsurarUid.value);
</script>