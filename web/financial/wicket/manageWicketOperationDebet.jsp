<%@page import="be.openclinic.finance.WicketDebet,
                be.openclinic.finance.Wicket,
                java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.wicketoperation","edit",activeUser)%>
<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>

<%
    String sShowReturn = checkString(request.getParameter("ShowReturn"));
    String sBack = "";
    boolean bShow = false;

    if(sShowReturn.equals("TRUE")){
        bShow = true;
        sBack = " doSearchBack();";
    }

    String sEditWicketOperationUID     = checkString(request.getParameter("EditWicketOperationUID")),
		   sEditWicketOperationDate    = checkString(request.getParameter("EditWicketOperationDate")),
		   sEditWicketOperationAmount  = checkString(request.getParameter("EditWicketOperationAmount")),
		   sEditWicketOperationType    = checkString(request.getParameter("EditWicketOperationType")),
		   sEditWicketOperationComment = checkString(request.getParameter("EditWicketOperationComment")),
		   sEditWicketOperationWicket  = checkString(request.getParameter("EditWicketOperationWicket"));
    
    if(request.getParameter("FindWicketOperationUID")!=null){
        sEditWicketOperationUID = checkString(request.getParameter("FindWicketOperationUID"));
    }

    // today as default date
    if(sEditWicketOperationDate.length()==0){
        sEditWicketOperationDate = ScreenHelper.stdDateFormat.format(new java.util.Date()); // now
    }
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********** financial/wicket/manageWicketOperationDebet.jsp ***********"); 
    	Debug.println("sEditWicketOperationUID     : "+sEditWicketOperationUID); 
    	Debug.println("sEditWicketOperationDate    : "+sEditWicketOperationDate); 
    	Debug.println("sEditWicketOperationAmount  : "+sEditWicketOperationAmount); 
    	Debug.println("sEditWicketOperationType    : "+sEditWicketOperationType); 
    	Debug.println("sEditWicketOperationComment : "+sEditWicketOperationComment); 
    	Debug.println("sEditWicketOperationWicket  : "+sEditWicketOperationWicket+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sMsg = "";
    
    if(sEditWicketOperationUID.length() > 0){
        WicketDebet wicketOp = WicketDebet.get(sEditWicketOperationUID);

        if(checkString(wicketOp.getUid()).length() > 0){
	        if(wicketOp.getOperationDate()!=null){
	            sEditWicketOperationDate = ScreenHelper.stdDateFormat.format(wicketOp.getOperationDate());
	        }        
	        sEditWicketOperationAmount = Double.toString(wicketOp.getAmount());
	        if(wicketOp.getComment()!=null){
	            sEditWicketOperationComment = wicketOp.getComment().toString();
	        }
	        sEditWicketOperationType = checkString(wicketOp.getOperationType());
	        sEditWicketOperationWicket = checkString(wicketOp.getWicketUID());
        }
        else{
        	sMsg = getTran("web","noRecordsFound",sWebLanguage);
        }
    }

    if(sEditWicketOperationWicket.length()==0){
        sEditWicketOperationWicket = checkString((String)session.getAttribute("defaultwicket"));
    }
%>
<form name='FindForm' id="FindForm" method='POST'>
    <%=writeTableHeader("wicket","wicketdebet",sWebLanguage,sBack)%>
    
    <table class='menu' border='0' width='100%' cellspacing='1' cellpadding="0">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">ID&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" id="FindWicketOperationUID" name="FindWicketOperationUID" onblur="isNumber(this)" value="<%=sEditWicketOperationUID%>">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="FindForm.FindWicketOperationUID.value = '';">
                
                <%-- BUTTONS --%>
                <input type="button" class="button" name="ButtonFind" value="<%=getTranNoLink("web","find",sWebLanguage)%>" onclick="doFind()">
                <input type="button" class="button" name="ButtonNew" value="<%=getTranNoLink("web","new",sWebLanguage)%>" onclick="doNew()">
            </td>
        </tr>
    </table>
    
    <%
        if(sMsg.length() > 0){
            %><%=sMsg%><br><%
        }
    %>
</form>

<form name="EditForm" method="POST" action="<c:url value='/main.do'/>?Page=financial/wicket/manageWicketOperationDebet.jsp&ts=<%=getTs()%>">
    <table class='list' border='0' width='100%' cellspacing='1' cellpadding="0">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("wicket","wicket",sWebLanguage)%>&nbsp;*</td>
            <td class='admin2'>
                <select class="text" name="EditWicketOperationWicket">
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        Vector vWickets = Wicket.getWicketsForUser(activeUser.userid);
                        Iterator iter = vWickets.iterator();
                        Wicket wicket;

                        String sSelected;
                        while(iter.hasNext()){
                            wicket = (Wicket) iter.next();
                            if(sEditWicketOperationWicket.equals(wicket.getUid())){
                                sSelected = " selected";
                            }
                            else{
                                sSelected = "";
                            }
                            
                            %><option value="<%=wicket.getUid()%>" <%=sSelected%>><%=wicket.getUid()%>&nbsp;<%=getTranNoLink("service",wicket.getServiceUID(),sWebLanguage)%></option><%
                        }
                    %>
                </select>
            </td>
        </tr>
        
        <%-- DATE --%>
        <tr>
            <td class="admin" ><%=getTran("Web","date",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2"><%=writeDateField("EditWicketOperationDate","EditForm",sEditWicketOperationDate,sWebLanguage)%></td>
        </tr>
        
        <%-- TYPE --%>
        <tr>
            <td class="admin"><%=getTran("wicket","operation_type",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <select class="text" name='EditWicketOperationType'>
                <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelectUnsorted("debet.type",sEditWicketOperationType,sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- AMOUNT --%>
        <tr>
            <td class="admin"><%=getTran("web","amount",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input class="text" type="text" name="EditWicketOperationAmount" value="<%=sEditWicketOperationAmount%>" onblur="isNumberNegAndPos(this)"/> <%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
            </td>
        </tr>
        
        <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran("web","comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea class="text" name="EditWicketOperationComment" cols="55" rows="4"><%=sEditWicketOperationComment%></textarea>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class='button' type="button" name="EditSaveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
            <%
                if(sEditWicketOperationUID.length()>0){
                    %><input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print",sWebLanguage)%>' onclick="doPrintPdf(document.getElementById('EditWicketOperationUID').value);"><%
                }
            
                if(bShow){
                    %><input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doSearchBack();"><%
                }
            %>
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    
    <input type="hidden" name="EditWicketOperationUID" id="EditWicketOperationUID" value="<%=sEditWicketOperationUID%>"/>
    <input type="hidden" name="ShowReturn" value="<%=sShowReturn%>">

    <span id="divMessage"></span>
</form>
    
<div id="divTodayDebets" style="width:100%;height:250px;overflow:auto;"></div>

<script>
  <%-- DO FIND --%>
  function doFind(){
    if(FindForm.FindWicketOperationUID.value.length>0){
      FindForm.submit();
    }
    else{
      FindForm.FindWicketOperationUID.focus();	
    }
  }

  <%-- DO NEW --%>
  function doNew(){
    FindForm.FindWicketOperationUID.value = "";
    EditForm.EditWicketOperationUID.value = "";
    FindForm.submit();
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=financial/index.jsp&ts=<%=getTs()%>";
  }

  <%-- DO SEARCH BACK --%>
  function doSearchBack(){
    if(EditForm.EditWicketOperationWicket.value!=""){
      window.location.href="<c:url value='/main.do'/>?Page=financial/wicket/wicketOverview.jsp&WicketUID="+EditForm.EditWicketOperationWicket.value+"&ts=<%=getTs()%>";
    }
    else{
      window.location.href="<c:url value='/main.do'/>?Page=financial/wicket/findWickets.jsp&ts=<%=getTs()%>";
    }
  }

  <%-- DO CLEAR --%>
  function doClear(){
    EditForm.EditWicketOperationUID.value = "";
    EditForm.EditWicketOperationDate.value = "";
    EditForm.EditWicketOperationAmount.value = "";
    EditForm.EditWicketOperationType.value = "";
    EditForm.EditWicketOperationComment.value = "";
  }

  <%-- DO SAVE --%>
  function doSave(){
    if(EditForm.EditWicketOperationWicket.value==""){
      alertDialog("web.manage","datamissing");
      EditForm.EditWicketOperationWicket.focus();
    }
    else if(EditForm.EditWicketOperationDate.value==""){
      alertDialog("web.manage","datamissing");
      EditForm.EditWicketOperationDate.focus();
    }
    else if(EditForm.EditWicketOperationType.value==""){
      alertDialog("web.manage","datamissing");
      EditForm.EditWicketOperationType.focus();
    }
    else if(EditForm.EditWicketOperationAmount.value==""){
      alertDialog("web.manage","datamissing");
      EditForm.EditWicketOperationAmount.focus();
    }
    else{
      EditForm.EditSaveButton.disabled = true;
      var today = new Date();
      var url = '<c:url value="/financial/wicket/manageWicketOperationDebetSave.jsp"/>?ts='+today;
      new Ajax.Request(url,{
        method: "POST",
        postBody: 'EditWicketOperationUID='+EditForm.EditWicketOperationUID.value+
                  '&EditWicketOperationAmount='+EditForm.EditWicketOperationAmount.value+
                  '&EditWicketOperationType='+EditForm.EditWicketOperationType.value+
                  '&EditWicketOperationComment='+EditForm.EditWicketOperationComment.value+
                  '&EditWicketOperationDate='+EditForm.EditWicketOperationDate.value+
                  '&EditWicketOperationWicket='+EditForm.EditWicketOperationWicket.value,
        onSuccess: function(resp){
          var label = eval('('+resp.responseText+')');
          $('divMessage').innerHTML=label.Message;
          doClear();
          loadTodayDebets();
        },
        onFailure: function(){
          $('divMessage').innerHTML = "Error in function doSave() => AJAX";
        }
      });

      EditForm.EditSaveButton.disabled = false;
    }
  }

  <%-- SEARCH WICKET --%>
  function searchWicket(wicketUidField,wicketNameField){
    openPopup("/_common/search/searchWicket.jsp&ts=<%=getTs()%>&VarCode="+wicketUidField+"&VarText="+wicketNameField);
  }

  <%-- SEARCH EDIT REFERENCE --%>
  function searchEditReference(referenceUidField,referenceNameField){
    if(document.getElementById("Editperson").checked){
      openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+referenceUidField+"&ReturnName="+referenceNameField+"&displayImmatNew=no&isUser=no");
    }
    else if(document.getElementById("Editservice").checked){
      openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+referenceUidField+"&VarText="+referenceNameField);
    }
  }

  <%-- CHANGE EDIT TYPE --%>
  function changeEditType(){
    if(document.getElementById("Editperson").checked){
      document.getElementById("EditTypeLabel").innerText = "<%=getTranNoLink("Web","person",sWebLanguage)%>";
    }
    else{
      document.getElementById("EditTypeLabel").innerText = "<%=getTranNoLink("Web","service",sWebLanguage)%>";
    }
    EditForm.EditWicketOperationReference.value = "";
    EditForm.EditWicketOperationReferenceName.value = "";
  }

  <%-- IS NUMBER NEG AND POS --%>
  function isNumberNegAndPos(sObject){
    if(sObject.value==0) return false;
    sObject.value = sObject.value.replace(",",".");
    if(sObject.value.charAt(0)=="-"){
      sObject.value = sObject.value.substring(1,sObject.value.length);
    }
    sObject.value = sObject.value.replace("-","");
    var string = sObject.value;
    var vchar = "01234567890.";
    var dotCount = 0;
    for(var i=0; i<string.length; i++){
      if(vchar.indexOf(string.charAt(i))==-1){
        sObject.value = "";
        //sObject.focus();
        return false;
      }
      else if(string.charAt(i)=="."){
        dotCount++;
        if(dotCount > 1){
          sObject.value = "";
          //sObject.focus();
          return false;
        }
      }
    }
    
    if(sObject.value.length > 250){
      sObject.value = sObject.value.substring(0,249);
    }

    return true;
  }

  <%-- SET WICKET --%>
  function setWicket(uid){
    EditForm.EditWicketOperationUID.value = uid;
    EditForm.submit();
  }

  <%-- LOAD TODAY DEBETS --%>
  function loadTodayDebets(){
    var url = '<c:url value="/financial/wicket/todayWicketDebets.jsp"/>?ts='+new Date();
    new Ajax.Request(url,{
      method: "POST",
      postBody: 'EditWicketOperationWicket=<%=sEditWicketOperationWicket%>',
      onSuccess: function(resp){
        $('divTodayDebets').innerHTML = resp.responseText;
      }
    });
  }

  <%-- DO PRINT PDF --%>
  function doPrintPdf(creditUid){
    var url = "<c:url value='/financial/createWicketDebetProofPdf.jsp'/>?CreditUid="+creditUid+"&ts=<%=getTs()%>&PrintLanguage=<%=sWebLanguage%>";
    window.open(url,"WicketDebetProofPdf<%=new java.util.Date().getTime()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
  }

  loadTodayDebets();
</script>