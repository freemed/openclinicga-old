<%@ page import="be.openclinic.finance.Balance,
                 be.openclinic.common.ObjectReference"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.balance","edit",activeUser)%>

<%
    String sEditBalanceUID = checkString(request.getParameter("EditBalanceUID"));
    String sAction = checkString(request.getParameter("Action"));

    Balance tmpBalance = new Balance();

    if(sAction.equals("SAVE")){
        String sEditBalanceMax           = checkString(request.getParameter("EditBalanceMax"));
        String sEditBalanceMin           = checkString(request.getParameter("EditBalanceMin"));
        String sEditBalanceRemarks       = checkString(request.getParameter("EditBalanceRemarks"));

        if(sEditBalanceUID.length() > 0){//update
            tmpBalance = Balance.get(sEditBalanceUID);
        }else{//insert
            tmpBalance.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
            tmpBalance.setBalance(0);
        }

        tmpBalance.setMaximumBalance(Double.parseDouble(sEditBalanceMax));
        tmpBalance.setMinimumBalance(Double.parseDouble(sEditBalanceMin));
        if(tmpBalance.getDate() == null){
            tmpBalance.setDate(ScreenHelper.getSQLDate(getDate()));
        }

        tmpBalance.setRemarks(sEditBalanceRemarks);

        ObjectReference tmpObjRef = new ObjectReference();
        tmpObjRef.setObjectType("Person");
        tmpObjRef.setObjectUid(activePatient.personid);
        tmpBalance.setOwner(tmpObjRef);
        tmpBalance.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        tmpBalance.setUpdateUser(activeUser.userid);

        tmpBalance.store();

         %>
        <script>
            window.location.href="<c:url value='/main.do'/>?Page=financial/historyBalance.jsp&ts=<%=getTs()%>";
        </script>
        <%
    }
    else if(sEditBalanceUID.length() > 0){
        tmpBalance = Balance.get(sEditBalanceUID);
    }
    else {
        tmpBalance = Balance.getActiveBalance(activePatient.personid);

        if (tmpBalance==null){
            ObjectReference tmpObjRef = new ObjectReference();
            tmpObjRef.setObjectType("Person");
            tmpObjRef.setObjectUid(activePatient.personid);
            tmpBalance = new Balance();
            tmpBalance.setOwner(tmpObjRef);
        }
    }
    String sCurrency = MedwanQuery.getInstance().getConfigParam("currency","€");
%>
<%-- Edit Block--%>
<form name='editForm' method='POST' action='<c:url value="/main.do"/>?Page=financial/editBalance.jsp&ts=<%=getTs()%>'>
    <%=writeTableHeader("Web","editBalance",sWebLanguage," doBack();")%>
    <table class="list" width="100%" cellspacing="1">
        <%-- maxbalance --%>
        <tr>
            <td class='admin' width="<%=sTDAdminWidth%>"><%=getTran("balance","maxbalance",sWebLanguage)%></td>
            <td class='admin2'>
                <input class='text' type='text' name='EditBalanceMax' value='<%=tmpBalance.getMaximumBalance()%>' size="10" onblur="isNumber(this)"> <%=sCurrency%>
            </td>
        </tr>
        <%-- minbalance --%>
        <tr>
            <td class='admin'><%=getTran("balance","minbalance",sWebLanguage)%></td>
            <td class='admin2'>
                <input class='text' type='text' name='EditBalanceMin' value='<%=tmpBalance.getMinimumBalance()%>' size="10" onblur="isNumber(this)"> <%=sCurrency%>
            </td>
        </tr>
        <%-- remarks --%>
        <tr>
            <td class='admin'><%=getTran("web","comment",sWebLanguage)%></td>
            <td class='admin2'><%=writeTextarea("EditBalanceRemarks","","","",checkString(tmpBalance.getRemarks()))%></td>
        </tr>

        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input class='button' type="button" name="buttonSave" value='<%=getTran("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
                <input class='button' type="button" name="buttonBack" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
        <%-- UID,action --%>
        <input type='hidden' name='EditBalanceUID' value='<%=tmpBalance.getUid()%>'>
        <input type='hidden' name='Action'>
    </table>
</form>

<script>
  editForm.EditBalanceMax.focus();

  function doBack(){
    history.go(-1);
    return false;
  }

  function doSave(){
    editForm.buttonSave.disabled = true;
    editForm.Action.value = "SAVE";
    editForm.submit();
  }

  function doHistory(){
    window.location.href="<c:url value='/main.do'/>?Page=financial/historyBalance.jsp&EditCreditBalanceUID=<%=tmpBalance.getUid()%>&ts=<%=getTs()%>";
  }
</script>