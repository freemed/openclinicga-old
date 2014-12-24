<%@ page import="be.openclinic.finance.Balance,
                 be.openclinic.common.ObjectReference"%>
<%@ page import="java.util.Vector" %>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("financial.balance","all",activeUser)%>

<%

    String sFindBalanceDate          = checkString(request.getParameter("FindBalanceDate"));
    String sFindBalanceOwner         = checkString(request.getParameter("FindBalanceOwner"));
    String sFindBalanceOwnerName     = checkString(request.getParameter("FindBalanceOwnerName"));
    String sFindBalanceOwnerType     = checkString(request.getParameter("FindBalanceOwnerType"));

    String sEditBalanceUID           = checkString(request.getParameter("EditBalanceUID"));
    //String sEditBalance              = checkString(request.getParameter("EditBalance"));
    //String sEditBalanceDate          = checkString(request.getParameter("EditBalanceDate"));
    String sEditBalanceMax           = checkString(request.getParameter("EditBalanceMax"));
    String sEditBalanceMin           = checkString(request.getParameter("EditBalanceMin"));
    String sEditBalanceOwner         = checkString(request.getParameter("EditBalanceOwner"));
    String sEditBalanceOwnerName     = checkString(request.getParameter("EditBalanceOwnerName"));
    String sEditBalanceOwnerType     = checkString(request.getParameter("EditBalanceOwnerType"));
    String sEditBalanceRemarks       = checkString(request.getParameter("EditBalanceRemarks"));

    String sAction                   = checkString(request.getParameter("Action"));

    if(Debug.enabled){
        Debug.println("####################### Find Params ###########################" +
                      "\n FindBalanceDate:      " + sFindBalanceDate +
                      "\n FindBalanceOwner:     " + sFindBalanceOwner +
                      "\n FindBalanceOwnerName: " + sFindBalanceOwnerName +
                      "\n FindBalanceOwnerType: " + sFindBalanceOwnerType +
                      "\n##############################################################");
        Debug.println("####################### Edit Params ###########################" +
                      "\n EditBalanceUID        " + sEditBalanceUID +
                      //"\n EditBalance           " + sEditBalance +
                      //"\n EditBalanceDate:      " + sEditBalanceDate +
                      "\n EditBalanceMax        " + sEditBalanceMax +
                      "\n EditBalanceMin        " + sEditBalanceMin +
                      "\n EditBalanceOwner:     " + sEditBalanceOwner +
                      "\n EditBalanceOwnerName: " + sEditBalanceOwnerName +
                      "\n EditBalanceOwnerType: " + sEditBalanceOwnerType +
                      "\n EditBalanceRemarks    " + sEditBalanceRemarks +
                      "\n##############################################################");
    }


    if(sAction.equals("SAVE")){
        ObjectReference tmpObjRef = new ObjectReference();
        Balance tmpBalance        = new Balance();

        if(sEditBalanceUID.length() > 0){//update
            tmpBalance = Balance.get(sEditBalanceUID);
        }else{//insert
            tmpBalance.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
            tmpBalance.setBalance(0);
        }
        //tmpBalance.setBalance(Double.parseDouble(sEditBalance));
        tmpBalance.setMaximumBalance(Double.parseDouble(sEditBalanceMax));
        tmpBalance.setMinimumBalance(Double.parseDouble(sEditBalanceMin));
        if(tmpBalance.getDate() == null){
            tmpBalance.setDate(ScreenHelper.getSQLDate(getDate()));
        }

        tmpBalance.setRemarks(sEditBalanceRemarks);

        tmpObjRef.setObjectType(sEditBalanceOwnerType);
        tmpObjRef.setObjectUid(sEditBalanceOwner);

        tmpBalance.setOwner(tmpObjRef);

        tmpBalance.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        tmpBalance.setUpdateUser(activeUser.userid);

        tmpBalance.store();

    }
    if(sEditBalanceUID.length() > 0){
        Balance tmpBalance;
        AdminPerson tmpPerson = new AdminPerson();

        tmpBalance            = Balance.get(sEditBalanceUID);
        //sEditBalance          = Double.toString(tmpBalance.getBalance());
        sEditBalanceMax       = Double.toString(tmpBalance.getMaximumBalance());
        sEditBalanceMin       = Double.toString(tmpBalance.getMinimumBalance());
        sEditBalanceRemarks   = tmpBalance.getRemarks();
        sEditBalanceOwner     = tmpBalance.getOwner().getObjectUid();
        sEditBalanceOwnerType = tmpBalance.getOwner().getObjectType();

        //if(tmpBalance.getDate() != null){
        //    sEditBalanceDate    = ScreenHelper.stdDateFormat.format(tmpBalance.getDate());
        //}

        if(tmpBalance.getOwner().getObjectType().equalsIgnoreCase("PERSON")){
            tmpPerson.initialize(tmpBalance.getOwner().getObjectUid());
            sEditBalanceOwnerName = tmpPerson.lastname + " " + tmpPerson.firstname;
        }else if(tmpBalance.getOwner().getObjectType().equalsIgnoreCase("SERVICE")){
            sEditBalanceOwnerName = getTran("Service",tmpBalance.getOwner().getObjectUid(),sWebLanguage);
        }
    }

%>
<%-- Find Block --%>
<form name='FindBalanceForm' id="FindBalanceForm" method='POST' action='<c:url value="/main.do"/>?Page=financial/manageBalances.jsp&ts=<%=getTs()%>'>
    <%=writeTableHeader("Web.manage","manageBalances",sWebLanguage," doBack();")%>
    <table class='menu' border='0' width='100%' cellspacing='0'>
        <%-- date --%>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("Web","date",sWebLanguage)%></td>
            <td><%=writeDateField("FindBalanceDate","FindBalanceForm",sFindBalanceDate,sWebLanguage)%></td>
        </tr>
        <%-- ownertype --%>
        <tr>
            <td>
                <%=getTran("web","ownertype",sWebLanguage)%>
            </td>
            <td>
                <%
                    String sFindCheckPerson  = "";
                    String sFindCheckService = "";
                    if(sFindBalanceOwnerType.equalsIgnoreCase("PERSON")){
                        sFindCheckPerson = " checked";
                    }else if(sFindBalanceOwnerType.equalsIgnoreCase("SERVICE")){
                        sFindCheckService = " checked";
                    }
                %>
                <input type='radio' name='FindBalanceOwnerType' id='Findperson' value='Person' onclick='changeFindType();' <%=sFindCheckPerson%>><label for='Findperson'><%=getTran("web","person",sWebLanguage)%></label>
                <input type='radio' name='FindBalanceOwnerType' id='Findservice' value='Service' onclick='changeFindType();' <%=sFindCheckService%>><label for='Findservice'><%=getTran("web","service",sWebLanguage)%></label>
            </td>
        </tr>
        <%-- owner --%>
        <tr>
            <td>
                <div id='FindTypeLabel'></div>
            </td>
            <td>
                <input type="hidden" name="FindBalanceOwner" value="<%=sFindBalanceOwner%>">
                <input class="text" type="text" name="FindBalanceOwnerName" readonly size="<%=sTextWidth%>" value="<%=sFindBalanceOwnerName%>">
                <input class="button" type="button" name="SearchOwnerButton" value="<%=getTranNoLink("Web","Select",sWebLanguage)%>" onclick="searchFindOwner('FindBalanceOwner','FindBalanceOwnerName');">
            </td>
        </tr>
        <%-- buttons: search,clear,new --%>
        <tr>
            <td/>
            <td>
                <input class='button' type='button' name='buttonfind' value='<%=getTranNoLink("Web","search",sWebLanguage)%>' onclick='doFind();'>
                <input class='button' type='button' name='buttonclear' value='<%=getTranNoLink("Web","Clear",sWebLanguage)%>' onclick='doClear();'>
                <input class='button' type='button' name='buttonnew' value='<%=getTranNoLink("Web.Occup","medwan.common.create-new",sWebLanguage)%>' onclick='doNew();'>&nbsp;
            </td>
        </tr>
        <%-- action --%>
        <input type='hidden' name='Action' value=''>
    </table>
</form>
<%-- End Find Block --%>

<%-- Find Results Block--%>
<%
    if(sAction.equals("SEARCH")){
%>
<table width='100%' cellspacing="0" cellpadding="0" class="list">
    <tr class='admin'>
        <td/>
        <td/>
        <td><%=getTran("web","owner",sWebLanguage)%></td>
        <td><%=getTran("web","date",sWebLanguage)%></td>
        <td><%=getTran("web","balance",sWebLanguage)%></td>
        <td><%=getTran("web","maxbalance",sWebLanguage)%></td>
        <td><%=getTran("web","minbalance",sWebLanguage)%></td>
    </tr>
    <%
        StringBuffer sbResults = new StringBuffer();

        Vector vBalances = Balance.getNonClosedBalancesByOwnerDate(sFindBalanceOwner,sFindBalanceDate);
        Iterator iter = vBalances.iterator();

        String sOwnerType = "",
               sOwnerUID = "",
               sName = "",
               sClass = "",
               sDate = "",
               sMinBalance = "",
               sMaxBalance = "",
               sBalance = "",
               sBalanceUID = "";
        java.util.Date dDate;

        Balance objBalance;
        while(iter.hasNext()){
            objBalance = (Balance)iter.next();
            sDate = "";
            if (sClass.equals("")) {
                sClass = "1";
            } else {
                sClass = "";
            }
            sBalanceUID = checkString(objBalance.getUid());
            sOwnerType  = checkString(objBalance.getOwner().getObjectType());
            sOwnerUID   = checkString(objBalance.getOwner().getObjectUid());
            sMaxBalance = checkString(Double.toString(objBalance.getMaximumBalance()));
            sMinBalance = checkString(Double.toString(objBalance.getMinimumBalance()));
            sBalance    = checkString(Double.toString(objBalance.getBalance()));
            dDate = objBalance.getDate();
            if (sOwnerType.equalsIgnoreCase("PERSON")) {
                sName = ScreenHelper.getFullPersonName(sOwnerUID);
            } else if (sOwnerType.equalsIgnoreCase("SERVICE")) {
                sName = getTran("Service", sOwnerUID, sWebLanguage);
            }

            if (dDate != null) {
                sDate = ScreenHelper.stdDateFormat.format(dDate);
            }
            sbResults.append("<tr class='list");
            sbResults.append(sClass);
            sbResults.append("' " + " ");
            sbResults.append("> " + "<td onmouseover=\"this.style.cursor='hand';\" onmouseout=\"this.style.cursor='default';\" onclick=\"doSelect('");
            sbResults.append(sBalanceUID);
            sbResults.append("');\"><img src='");
            sbResults.append(request.getContextPath());
            sbResults.append("/_img/icons/icon_view.gif' alt='view'></td>" + "<td onmouseover=\"this.style.cursor='hand';\" onmouseout=\"this.style.cursor='default';\" onclick=\"doEdit('");
            sbResults.append(sBalanceUID);
            sbResults.append("');\"><img src='");
            sbResults.append(request.getContextPath());
            sbResults.append("/_img/icons/icon_edit.gif' alt='edit'></td>" + "<td>");
            sbResults.append(sName);
            sbResults.append("</td>" + "<td>");
            sbResults.append(sDate);
            sbResults.append("</td>" + "<td>");
            sbResults.append(sBalance);
            sbResults.append("</td>" + "<td>");
            sbResults.append(sMaxBalance);
            sbResults.append("</td>" + "<td>");
            sbResults.append(sMinBalance);
            sbResults.append("</td>" + "</tr>");
            dDate = null;
        }
    %>
    <%=sbResults%>
</table>
<%
    }
%>
<%-- End Results Block--%>
<%
    if(sAction.equals("SELECT") || sAction.equals("NEW")){
%>
<%-- Edit Block--%>
<form name='EditBalanceForm' method='POST' action='<c:url value="/main.do"/>?Page=financial/manageBalances.jsp&ts=<%=getTs()%>'>
    <table class="list" width="100%" cellspacing="1">
        <%-- balance
        <tr>
            <td class='admin' width='<%=sTDAdminWidth%>'>
                <%=getTran("web","balance",sWebLanguage)%>
            </td>
            <td class='admin2'>
                <input class='text' type='text' name='EditBalance' value='<%=sEditBalance%>' size="40">
            </td>
        </tr>
        
        <%-- date
        <tr>
            <td class='admin'><%=getTran("Web","date",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="text" class="text" size="12" maxChars="12" value="<%=sEditBalanceDate%>" name="EditBalanceDate" id="EditDate" onBlur="checkDate(this);">
                <script>writeMyDate("EditDate");</script>
            </td>
        </tr>--%>
        
        <%-- ownertype --%>
        <tr>
            <td class='admin' ><%=getTran("web","ownertype",sWebLanguage)%></td>
            <td class='admin2'>
                <%
                    String sEditCheckPerson  = "";
                    String sEditCheckService = "";
                    if(sEditBalanceOwnerType.equalsIgnoreCase("PERSON")){
                        sEditCheckPerson = " checked";
                    }else if(sEditBalanceOwnerType.equalsIgnoreCase("SERVICE")){
                        sEditCheckService = " checked";
                    }
                %>
                <input type='radio' name='EditBalanceOwnerType' id='Editperson'  value='Person'  onclick='changeEditType();' <%=sEditCheckPerson%>><label for='Editperson'><%=getTran("web","person",sWebLanguage)%></label>
                <input type='radio' name='EditBalanceOwnerType' id='Editservice' value='Service' onclick='changeEditType();' <%=sEditCheckService%>><label for='Editservice'><%=getTran("web","service",sWebLanguage)%></label>
            </td>
        </tr>
        <%-- owner --%>
        <tr>
            <td class='admin'>
                <div id='EditTypeLabel'></div>
            </td>
            <td class='admin2'>
                <input type="hidden" name="EditBalanceOwner" value="<%=sEditBalanceOwner%>">
                <input class="text" type="text" name="EditBalanceOwnerName" readonly size="<%=sTextWidth%>" value="<%=sEditBalanceOwnerName%>">
                <input class="button" type="button" name="SearchOwnerButton" value="<%=getTranNoLink("Web","Select",sWebLanguage)%>" onclick="searchEditOwner('EditBalanceOwner','EditBalanceOwnerName');">
            </td>
        </tr>
        <%-- maxbalance --%>
        <tr>
            <td class='admin'><%=getTran("web","maxbalance",sWebLanguage)%></td>
            <td class='admin2'>
                <input class='text' type='text' name='EditBalanceMax' value='<%=sEditBalanceMax%>' size="40">
            </td>
        </tr>
        <%-- minbalance --%>
        <tr>
            <td class='admin'><%=getTran("web","minbalance",sWebLanguage)%></td>
            <td class='admin2'>
                <input class='text' type='text' name='EditBalanceMin' value='<%=sEditBalanceMin%>' size="40">
            </td>
        </tr>
        <%-- remarks --%>
        <tr>
            <td class='admin'><%=getTran("web","comment",sWebLanguage)%></td>
            <td class='admin2'><%=writeTextarea("EditBalanceRemarks","","","",sEditBalanceRemarks)%></td>
        </tr>
        <%-- UID,action --%>
        <input type='hidden' name='EditBalanceUID' value='<%=sEditBalanceUID%>'>
        <input type='hidden' name='Action' value=''>
    </table>
</form>
<%
    }
%>
<%=ScreenHelper.alignButtonsStart()%>
    <%-- Buttons --%>
    <%
        if(sAction.equals("NEW") || sAction.equals("SELECT")){
    %>
        <input class='button' type="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
    <%
        }
    %>
    <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
<%=ScreenHelper.alignButtonsStop()%>

<%-- End Edit Block--%>

<script>
<%-- Find Block --%>
  FindBalanceForm.FindBalanceDate.focus();
  
  function doClear(){
    FindBalanceForm.FindBalanceDate.value = "";
    FindBalanceForm.FindBalanceOwner.value = "";
    FindBalanceForm.FindBalanceOwnerName.value = "";
  }

  function doFind(){
    FindBalanceForm.Action.value = "SEARCH";
    FindBalanceForm.buttonfind.disabled = true;
    FindBalanceForm.submit();
  }

  function doNew(){
    FindBalanceForm.Action.value = "NEW";
    FindBalanceForm.submit();
  }

  <%-- search owner --%>
  function searchFindOwner(ownerUidField,ownerNameField){
    if(document.getElementById("Findperson").checked){
      openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+ownerUidField+"&ReturnName="+ownerNameField+"&displayImmatNew=no&isUser=no");
    }
    else if(document.getElementById("Findservice").checked){
      openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+ownerUidField+"&VarText="+ownerNameField);
    }
  }

  function changeFindType(){
    if(document.getElementById("Findperson").checked){
      document.getElementById("FindTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
    }
    else{
      document.getElementById("FindTypeLabel").innerText = "<%=getTran("Web","service",sWebLanguage)%>";
    }
    FindBalanceForm.FindBalanceOwner.value = "";
    FindBalanceForm.FindBalanceOwnerName.value = "";
  }
<%-- End Find Block --%>

<%-- FindResults Block --%>
  function doEdit(id){
    window.location.href="<c:url value='/main.do'/>?Page=financial/manageBalances.jsp&Action=SELECT&EditBalanceUID=" + id + "&ts=<%=getTs()%>";
  }

  function doSelect(id){
    window.location.href="<c:url value='/main.do'/>?Page=financial/manageBalancesOverview.jsp&EditBalanceUID=" + id + "&ts=<%=getTs()%>";
  }
<%-- End FindResults Block --%>

<%-- Edit Block --%>
  function doBack(){
    window.location.href="<c:url value='/main.do'/>?Page=financial/index.jsp&ts=<%=getTs()%>";
  }

  function doSave(){
    if(EditBalanceForm.EditBalanceOwner.value == ""){
      alertDialog("web.financial","owner_missing");
    }
    else if(EditBalanceForm.EditBalanceMin.value == ""){
      alertDialog("web.financial","min_balance_missing");
    }
    else if(EditBalanceForm.EditBalanceMax.value == ""){
      alertDialog("web.financial","max_balance_missing");
    }
    else{
      saveButton.disabled = true;
      EditBalanceForm.Action.value = "SAVE";
      EditBalanceForm.submit();
    }
  }

  <%-- search edit owner --%>
  function searchEditOwner(ownerUidField,ownerNameField){
    if(document.getElementById("Editperson").checked){
      openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+ownerUidField+"&ReturnName="+ownerNameField+"&displayImmatNew=no&isUser=no");
    }
    else if(document.getElementById("Editservice").checked){
      openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+ownerUidField+"&VarText="+ownerNameField);
    }
  }

  function changeEditType(){
    if(document.getElementById("Editperson").checked){
      document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
    }
    else{
      document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","service",sWebLanguage)%>";
    }
    EditBalanceForm.EditBalanceOwner.value = "";
    EditBalanceForm.EditBalanceOwnerName.value = "";
  }
<%-- End Edit Block --%>

<%-- General --%>
  if(FindBalanceForm.FindBalanceOwnerName.value == ""){
    document.getElementById("Findperson").checked = true;
    document.getElementById("FindTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
  }
  else{
    if(document.getElementById("Findperson").checked){
      document.getElementById("FindTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
    }
    else{
      document.getElementById("FindTypeLabel").innerText = "<%=getTran("Web","service",sWebLanguage)%>";
    }
  }

<%
    if(sAction.equals("SELECT") || sAction.equals("NEW")){
    %>
        if(EditBalanceForm.EditBalanceOwnerName.value == ""){
          document.getElementById("Editperson").checked = true;
          document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
        }
        else{
          if(document.getElementById("Editperson").checked){
            document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","person",sWebLanguage)%>";
          }
          else{
            document.getElementById("EditTypeLabel").innerText = "<%=getTran("Web","service",sWebLanguage)%>";
          }
        }
    <%
    }
%>
</script>