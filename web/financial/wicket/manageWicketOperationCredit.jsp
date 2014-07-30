<%@ page import="be.openclinic.finance.Wicket,be.openclinic.finance.WicketCredit,java.util.Vector" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.wicketoperation","select",activeUser)%>
<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>
<%
    String sShowReturn                          = checkString(request.getParameter("ShowReturn"));
    String sBack = "";
    boolean bShow = false;

    if(sShowReturn.equals("TRUE")){
        bShow = true;
        sBack = " doSearchBack();";
    }

    String sEditWicketOperationUID              = checkString(request.getParameter("EditWicketOperationUID"));
    String sEditWicketOperationDate             = checkString(request.getParameter("EditWicketOperationDate"));
    String sEditWicketOperationAmount           = checkString(request.getParameter("EditWicketOperationAmount"));
    String sEditWicketOperationType             = checkString(request.getParameter("EditWicketOperationType"));
    String sEditWicketOperationComment          = checkString(request.getParameter("EditWicketOperationComment"));
    String sEditWicketOperationWicket           = checkString(request.getParameter("EditWicketOperationWicket"));
    if(request.getParameter("FindWicketOperationUID")!=null){
        sEditWicketOperationUID              = checkString(request.getParameter("FindWicketOperationUID"));
    }
    SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;
    int version = 0;

    // today as default date
    if(sEditWicketOperationDate.length()==0){
        sEditWicketOperationDate = stdDateFormat.format(new java.util.Date()); // now
    }

    if (sEditWicketOperationUID.length() > 0) {
        WicketCredit wicketOp = WicketCredit.get(sEditWicketOperationUID);

        sEditWicketOperationDate = stdDateFormat.format(wicketOp.getOperationDate());
        sEditWicketOperationAmount = Double.toString(wicketOp.getAmount());
        sEditWicketOperationComment = wicketOp.getComment().toString();
        sEditWicketOperationType = wicketOp.getOperationType();
        sEditWicketOperationWicket = wicketOp.getWicketUID();
        version = wicketOp.getVersion();
    }

    if (!(sEditWicketOperationWicket.length() > 0)) {
        sEditWicketOperationWicket = activeUser.getParameter("defaultwicket");
    }
    if(sEditWicketOperationWicket.length()==0){
        sEditWicketOperationWicket = checkString((String)session.getAttribute("defaultwicket"));
    }
    %>
<form name='FindForm' id="FindForm" method='POST'>
    <%=writeTableHeader("wicket","wicketcredit",sWebLanguage,sBack)%>
    <table class="menu" width="100%">
        <tr>
            <td width="<%=sTDAdminWidth%>">ID</td>
            <td>
                <input type="text" class="text" id="FindWicketOperationUID" name="FindWicketOperationUID" onblur="isNumber(this)" value="<%=sEditWicketOperationUID%>">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="doClear()">
                <input type="button" class="button" name="ButtonFind" value="<%=getTran("web","find",sWebLanguage)%>" onclick="doFind()">
                <input type="button" class="button" name="ButtonNew" value="<%=getTran("web","new",sWebLanguage)%>" onclick="doNew()">
            </td>
        </tr>
    </table>
</form>
<form name="EditForm" method="POST" action="<c:url value='/main.do'/>?Page=financial/wicket/manageWicketOperationCredit.jsp&ts=<%=getTs()%>">
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- wicket --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("wicket","wicket",sWebLanguage)%>&nbsp;*</td>
            <td class='admin2'>
                <select class="text" name="EditWicketOperationWicket">
                    <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                    <%
                        Vector vWickets = Wicket.getWicketsForUser(activeUser.userid);
                        Iterator iter = vWickets.iterator();
                        Wicket wicket;

                        if (sEditWicketOperationUID.length()==0){
                            sEditWicketOperationWicket = checkString(activeUser.getParameter("defaultwicket"));
                        }

                        String sSelected;
                        while (iter.hasNext()) {
                            wicket = (Wicket) iter.next();
                            if (sEditWicketOperationWicket.equals(wicket.getUid())) {
                                sSelected = " selected";
                            } else {
                                sSelected = "";
                            }

                    %>
                    <option value="<%=wicket.getUid()%>" <%=sSelected%>><%=wicket.getUid()%>&nbsp;<%=getTran("service",wicket.getServiceUID(),sWebLanguage)%></option>
                    <%
                        }
                    %>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin" ><%=getTran("Web","date",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2"><%=writeDateField("EditWicketOperationDate","EditForm",sEditWicketOperationDate,sWebLanguage)%>
            <%
            if(version>1){
            %>
            <a href='javascript:void(0)' onclick='getWicketOperationHistory("<%=sEditWicketOperationUID %>",20)' class='link transactionhistory' title='<%=getTranNoLink("web","modificationshistory",sWebLanguage)%>' alt="<%=getTranNoLink("web","modificationshistory",sWebLanguage)%>">...</a>
            <%
            }
            %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("wicket","operation_type",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
            	<%
            		if(sEditWicketOperationType.equalsIgnoreCase("patient.payment")){
            			out.println(getTran("credit.type","patient.payment",sWebLanguage));
            		}
            		else {
            	%>
                <select class="text" name='EditWicketOperationType'>
                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelect("wicketcredit.type",sEditWicketOperationType,sWebLanguage)%>
                </select>
                <%
            		}
                %>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","amount",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input class="text" type="text" name="EditWicketOperationAmount" value="<%=sEditWicketOperationAmount%>" onblur="isNumberNegAndPos(this)"/> <%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="EditWicketOperationComment" cols="55" rows="4"><%=sEditWicketOperationComment%></textarea>
            </td>
        </tr>
        <%=ScreenHelper.setFormButtonsStart()%>
        	<%
        		if((activeUser.getAccessRight("financial.superuser.select") || !sEditWicketOperationType.equalsIgnoreCase("patient.payment")) && (activeUser.getAccessRight("financial.wicketoperation.edit") || sEditWicketOperationUID.length()==0)){
        	%>
            	<input class='button' type="button" name="EditSaveButton" value='<%=getTran("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
            <%
        		}
                if(sEditWicketOperationUID.length()>0){
            %>
            	<input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print",sWebLanguage)%>' onclick="doPrintPdf(document.getElementById('EditWicketOperationUID').value);">
            <%
                }
                if(bShow){
            %>
                <input class='button' type="button" name="Backbutton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doSearchBack();">
            <%
            }
            %>
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <input type="hidden" name="ShowReturn" value="<%=sShowReturn%>">
    <input type="hidden" name="EditWicketOperationUID" id="EditWicketOperationUID" value="<%=sEditWicketOperationUID%>"/>
</form>
<div id="divMessage"></div>
<div id="divTodayCredits" style="width:100%;height:250px;border: 0px solid #666666;overflow:auto;"></div>
<script>
    function doFind(){
        if (FindForm.FindWicketOperationUID.value.length>0){
            FindForm.submit();
        }
    }

    function doNew(){
        FindForm.FindWicketOperationUID.value = "";
        EditForm.EditWicketOperationUID.value = "";

        FindForm.submit();
    }

    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=financial/index.jsp&ts=<%=getTs()%>";
    }

    function doSearchBack(){
        if(EditForm.EditWicketOperationWicket.value != ""){
            window.location.href="<c:url value='/main.do'/>?Page=financial/wicket/wicketOverview.jsp&WicketUID=" + EditForm.EditWicketOperationWicket.value + "&ts=<%=getTs()%>";
        }else{
            window.location.href="<c:url value='/main.do'/>?Page=financial/wicket/findWickets.jsp&ts=<%=getTs()%>";
        }
    }

    function doClear(){
        EditForm.EditWicketOperationUID.value = "";
        EditForm.EditWicketOperationDate.value = "";
        EditForm.EditWicketOperationAmount.value = "";
        EditForm.EditWicketOperationType.value = "";
        EditForm.EditWicketOperationComment.value = "";
    }

  <%-- DO SAVE --%>
  function doSave(){
    if(EditForm.EditWicketOperationWicket.value == ""){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelValue=<%=getTranNoLink("wicket","nowicketselected",sWebLanguage)%>";
      var modalities = "dialogWidth:400px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("wicket","nowicketselected",sWebLanguage)%>");
      EditForm.EditWicketOperationWicket.focus();
    }
    else if(EditForm.EditWicketOperationDate.value == ""){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelValue=<%=getTranNoLink("wicket","nodateselected",sWebLanguage)%>";
      var modalities = "dialogWidth:400px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("wicket","nodateselected",sWebLanguage)%>");
      EditForm.EditWicketOperationDate.focus();
    }
    else if(EditForm.EditWicketOperationType.value == ""){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelValue=<%=getTranNoLink("wicket","notypeselected",sWebLanguage)%>";
      var modalities = "dialogWidth:400px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("wicket","notypeselected",sWebLanguage)%>");

      EditForm.EditWicketOperationType.focus();
    }
    else if(EditForm.EditWicketOperationAmount.value == ""){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelValue=<%=getTranNoLink("wicket","noamountselected",sWebLanguage)%>";
      var modalities = "dialogWidth:400px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,'',modalities):window.confirm("<%=getTranNoLink("wicket","noamountselected",sWebLanguage)%>");

      EditForm.EditWicketOperationAmount.focus();
    }
    else{
      EditForm.EditSaveButton.disabled = true;

      var today = new Date();
      var url = '<c:url value="/financial/wicket/manageWicketOperationCreditSave.jsp"/>?ts='+today;
      new Ajax.Request(url,{
        method: "POST",
        postBody: 'EditWicketOperationUID=' + EditForm.EditWicketOperationUID.value
                 +'&EditWicketOperationAmount=' + EditForm.EditWicketOperationAmount.value
                 +'&EditWicketOperationType=' + EditForm.EditWicketOperationType.value
                 +'&EditWicketOperationComment=' + EditForm.EditWicketOperationComment.value
                +'&EditWicketOperationDate=' + EditForm.EditWicketOperationDate.value
                 +'&EditWicketOperationWicket=' + EditForm.EditWicketOperationWicket.value,
        onSuccess: function(resp){
          var label = eval('('+resp.responseText+')');
          $('divMessage').innerHTML = label.Message;
          doClear();
          loadTodayCredits();
        },
        onFailure: function(){
          $('divMessage').innerHTML = "Error in function doSave() => AJAX";
        }
      }
    );

    EditForm.EditSaveButton.disabled = false;
  }
 }

    function searchWicket(wicketUidField,wicketNameField){
        openPopup("/_common/search/searchWicket.jsp&ts=<%=getTs()%>&VarCode="+wicketUidField+"&VarText="+wicketNameField);
    }

    <%-- search reference --%>
    function searchEditReference(referenceUidField,referenceNameField){
        if(document.getElementById("Editperson").checked){
            openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+referenceUidField+"&ReturnName="+referenceNameField+"&displayImmatNew=no&isUser=no");
        }else if(document.getElementById("Editservice").checked){
            openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+referenceUidField+"&&VarText="+referenceNameField);
        }
    }

    function changeEditType(){
        if(document.getElementById("Editperson").checked){
             document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
        }else{
             document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","service",sWebLanguage)%>";
        }
        EditForm.EditWicketOperationReference.value = "";
        EditForm.EditWicketOperationReferenceName.value = "";
    }

    function isNumberNegAndPos(sObject){
        if(sObject.value==0) return false;
        sObject.value = sObject.value.replace(",",".");
        if(sObject.value.charAt(0) == "-"){
            sObject.value = sObject.value.substring(1,sObject.value.length);
        }
        sObject.value = sObject.value.replace("-","");
        var string = sObject.value;
        var vchar = "01234567890.";
        var dotCount = 0;

        for(var i=0; i < string.length; i++){
            if (vchar.indexOf(string.charAt(i)) == -1)	{
                sObject.value = "";
                //sObject.focus();
                return false;
            }
            else{
                if(string.charAt(i)=="."){
                    dotCount++;
                    if(dotCount > 1){
                        sObject.value = "";
                        //sObject.focus();
                        return false;
                    }
                }
            }
        }

        if(sObject.value.length > 250){
            sObject.value = sObject.value.substring(0,249);
        }

        return true;
    }

    function setWicket(uid){
        EditForm.EditWicketOperationUID.value = uid;
        EditForm.submit();
    }

    function loadTodayCredits(){
        var params = '';
        var today = new Date();
        var url= '<c:url value="/financial/wicket/todayWicketCredits.jsp"/>?ts='+today;

        new Ajax.Request(url,{
              method: "POST",
              postBody: 'EditWicketOperationWicket=<%=sEditWicketOperationWicket%>',
              onSuccess: function(resp){
                  $('divTodayCredits').innerHTML=resp.responseText;
              }
          }
        );
    }

    function doPrintPdf(creditUid){
      var url = "<c:url value='/financial/createWicketPaymentReceiptPdf.jsp'/>?CreditUid="+creditUid+"&ts=<%=getTs()%>&PrintLanguage=<%=sWebLanguage%>";
      window.open(url,"WicketPaymentReceiptPdf<%=new java.util.Date().getTime()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
    }

    loadTodayCredits();
</script>
