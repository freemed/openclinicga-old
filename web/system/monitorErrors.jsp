<%@page import="java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("system.management","all",activeUser)%>
<%=sJSSORTTABLE%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindBegin = checkString(request.getParameter("FindBegin")),
           sFindEnd   = checkString(request.getParameter("FindEnd"));

    String sDelFromDate  = checkString(request.getParameter("DelFromDate")),
           sDelUntilDate = checkString(request.getParameter("DelUntilDate"));

    // sortCol
    String sSortCol = checkString(request.getParameter("SortCol"));
    if(sSortCol.length()==0) sSortCol = "updatetime"; // default

    int iCounter = 0;
    String sMsg = "";

    //--- DELETE ERROR ----------------------------------------------------------------------------
    if(sAction.equals("deleteError")){
        String sDelErrorId = checkString(request.getParameter("DelErrorId"));
        if(sDelErrorId.length() > 0){
            be.openclinic.system.Error.delete(sDelErrorId);
            sMsg = getTran("web","dataIsDeleted",sWebLanguage);
        }
    }
    //--- DELETE ERROR ----------------------------------------------------------------------------
    else if(sAction.equals("deleteErrors")){
        java.util.Date delFromDate = null, delUntilDate = null;

        SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;
        if(sDelFromDate.length() > 0){
            delFromDate = ScreenHelper.parseDate(sDelFromDate);
        }

        if(sDelUntilDate.length() > 0){
            delUntilDate = ScreenHelper.parseDate(ScreenHelper.getDateAdd(sDelUntilDate,"2")); // add one day
        }

        be.openclinic.system.Error.delete(delFromDate,delUntilDate);
        sMsg = getTran("web","dataIsDeleted",sWebLanguage);
    }
%>

<form name="transactionForm" id="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doSearchErrors();}">
    <%-- hidden fields --%>
    <input type="hidden" name="Action" value="">
    <input type="hidden" name="DelErrorId" value="">
    <input type="hidden" name="SortCol" value="<%=sSortCol%>">
    
    <%=writeTableHeader("Web.manage","ViewErrors",sWebLanguage," doBack();")%>
    <table width="100%" class="list" cellspacing="1" cellpadding="1">
        <%-- BEGIN & END --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web","End",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doSearchErrors();">
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearSearchFields();">
                <input class="button" type="button" name="backButton" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
    <%
        // message
        if(sMsg.length() > 0){
            %><%=sMsg%><br><%
        }

        //--- DISPLAY ERRORS ----------------------------------------------------------------------
        if(sFindBegin.length()>0 || sFindEnd.length()>0){
            %>
                <br>
                <%-- BUTTONS at TOP --%>
                <table width="100%" cellspacing="1">
                    <tr>
                        <td style="vertical-align:bottom;">
                            <a href="javascript:viewAllErrors(true);"><%=getTran("Web.Manage","viewAllErrors",sWebLanguage)%></a>
                            <a href="javascript:viewAllErrors(false);"><%=getTran("Web.Manage","hideAllErrors",sWebLanguage)%></a>
                        </td>
                        <%-- link to bottom --%>
                        <td align="right">
                            <a href="#bottom" class="top"><img src="<c:url value='/_img/themes/default/bottom.gif'/>" class="link" border="0"></a>
                        </td>
                    </tr>
                </table>
                <%-- found errors --%>
                <table class="sortable" cellspacing="0" cellpadding="1" width="100%" id="searchresults">
                    <%-- HEADER --%>
                    <tr class="admin">
                        <td width="20">&nbsp;</td>
                        <td width="150"><%=getTran("Web","date",sWebLanguage)%></td>
                        <td width="220"><%=getTran("Web.Occup","medwan.authentication.login",sWebLanguage)%></td>
                        <td width="*"><%=getTran("Web.Statistics","Page",sWebLanguage)%></td>
                    </tr>
                    <tbody class="hand">
                    <%
                        Vector vErrors = be.openclinic.system.Error.searchErrors(sFindBegin, sFindEnd);

                        SimpleDateFormat dateHourFormat = ScreenHelper.fullDateFormat;
                        String sClickTran = getTranNoLink("web.manage", "clickToView", sWebLanguage);
                        String sClass = "", sErrorId, sAccessTime, sName, sError, sPage;

                        // run thru found records
                        be.openclinic.system.Error objError;
                        Iterator iter = vErrors.iterator();
                        while(iter.hasNext()){
                            objError = (be.openclinic.system.Error)iter.next();
                            iCounter++;

                            sErrorId    = objError.getErrorId()+"";
                            sAccessTime = dateHourFormat.format(objError.getUpdatetime());
                            sName       = objError.getUpdateuserid() + " " + objError.getLastname() + " " + objError.getFirstname();
                            sPage       = objError.getErrorpage();
                            sError      = new String(objError.getErrortext());

                            // alternate row-style
                            if(sClass.equals("")) sClass = "1";
                            else                  sClass = "";

                            %>
                                <tr class="list<%=sClass%>" title="<%=sClickTran%>" id="header_<%=iCounter%>">
                                    <td class="hand"><img src="<c:url value='/_img/icons/icon_delete.gif'/>" border="0" alt="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="deleteError('<%=sErrorId%>');" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'/></td>
                                    <td class="hand" onClick="toggleError('error_<%=iCounter%>');"><%=sAccessTime%></td>
                                    <td class="hand" onClick="toggleError('error_<%=iCounter%>');"><%=sName%></td>
                                    <td class="hand" onClick="toggleError('error_<%=iCounter%>');"><%=sPage%></td>
                                </tr>
                                <tr id="error_<%=iCounter%>" style="display:none;">
                                    <td colspan="4" style="padding:5px 5px 5px 20px;"><div style="border:1px solid #ccc;"><%=sError%></div></td>
                                </tr>
                            <%
                        }

                        // no records found
                        if(iCounter==0){
                            %><tr><td colspan="4"><%=getTran("web","norecordsfound",sWebLanguage)%></td></tr><%
                        }
                    %>
                    </tbody>
                </table>
                <%-- HIDE/SHOW ALL --%>
                <%
                    if(iCounter > 15){
                       %>
                           <div>
                               <a href="javascript:viewAllErrors(true);"><%=getTran("Web.Manage","viewAllErrors",sWebLanguage)%></a>
                               <a href="javascript:viewAllErrors(false);"><%=getTran("Web.Manage","hideAllErrors",sWebLanguage)%></a>
                           </div>
                       <%
                    }

                    // number of records found
                    if(iCounter > 0){
                        %>
                            <div style="padding-bottom:5px;padding-top:2px;"><%=getTran("Web.Occup","total-number",sWebLanguage)%> : <%=iCounter%></div>
                        <%
                    }
                %>
            <%
        }
    %>

    <%-- DELETE RANGE OF ERRORS --%>
    <%
        if(iCounter > 0){
            %>
                <table class="list" width="100%" cellspacing="0" cellpadding="1">
                    <tr height="22">
                        <td class="admin2" align="right"><%=getTran("Web","from",sWebLanguage)%></td>
                     
                        <td class="admin2" align="left"><%=writeDateField("DelFromDate","transactionForm",sDelFromDate,sWebLanguage)%> <%=getTran("Web","to",sWebLanguage)%> 
                            <%=writeDateField("DelUntilDate","transactionForm",sDelUntilDate,sWebLanguage)%>&nbsp;&nbsp;
                            
                            <input type="button" class="button" name="deleteRangeButton" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onClick="deleteErrors();">
                            <input class="button" type="button" name="backButton" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onclick="doBack();">
                        </td>
                        <td class="admin2" style="text-align:right">
                        <%
                            if(iCounter > 15){
                                %><a href="#topp" class="topbutton">&nbsp;</a><%
                            }
                        %>
                        </td>
                    </tr>
                </table>
            <%
        }
    %>
</form>

<script>
  transactionForm.FindBegin.focus();

  <%-- suggest searchDates as deleteDates if no deleteDates were specified --%>
  if(transactionForm.DelFromDate && transactionForm.DelUntilDate){
    var sDelFromDate  = transactionForm.DelFromDate.value,
        sDelUntilDate = transactionForm.DelUntilDate.value;

    if(sDelFromDate.length==0 && sDelUntilDate.length==0){
      transactionForm.DelFromDate.value = transactionForm.FindBegin.value;
      transactionForm.DelUntilDate.value = transactionForm.FindEnd.value;
    }
  }

  <%-- DO SEARCH ERRORS --%>
  function doSearchErrors(){
    if(transactionForm.DelFromDate && transactionForm.DelUntilDate){
      transactionForm.DelFromDate.value = "";
      transactionForm.DelUntilDate.value = "";
    }

    var sBeginDate = transactionForm.FindBegin.value,
        sEndDate   = transactionForm.FindEnd.value;

    <%-- both dates given --%>
    if(sBeginDate.length > 0 && sEndDate.length > 0){
      if(sBeginDate!=sEndDate && !before(sBeginDate,sEndDate)){
        alertDialog("Occup","endMustComeAfterBegin");
        transactionForm.FindEnd.focus();
      }
      else{
        transactionForm.ButtonSearch.disabled = true;
        transactionForm.ButtonClear.disabled = true;
        transactionForm.submit();
      }
    }
    <%-- only one date given --%>
    else if(sBeginDate.length > 0 || sEndDate.length > 0){
      transactionForm.ButtonSearch.disabled = true;
      transactionForm.ButtonClear.disabled = true;
      transactionForm.submit();
    }
    <%-- no dates given --%>
    else{
      alertDialog("web.manage","datamissing");
      transactionForm.FindBegin.focus();
    }
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    transactionForm.FindBegin.value = "";
    transactionForm.FindEnd.value = "";
    transactionForm.FindBegin.focus();
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp&Tab=database&ts=<%=getTs()%>";
  }

  <%-- DO SORT --%>
  function doSort(sortCol){
    transactionForm.SortCol.value = sortCol;
    transactionForm.submit();
  }

  <%-- TOGGLE ERROR --%>
  function toggleError(errorIdx){
    if(document.all[errorIdx].style.display==""){
      document.all[errorIdx].style.display = "none";
    }
    else{
      document.all[errorIdx].style.display = "";
    }
  }

  <%-- DELETE ERROR --%>
  function deleteError(errorId){
    transactionForm.Action.value = "deleteError";
    transactionForm.DelErrorId.value = errorId;
    transactionForm.submit();
  }

  <%-- DELETE ERRORS --%>
  function deleteErrors(){
    var fromDate  = transactionForm.DelFromDate.value,
        untilDate = transactionForm.DelUntilDate.value;

    if(fromDate.length > 0 || untilDate.length > 0){
  	  if(yesnoDialog("Web","areYouSureToDelete")){
        transactionForm.deleteRangeButton.disabled = true;
        transactionForm.Action.value = "deleteErrors";
        transactionForm.submit();
      }
    }
    else{
      alertDialog("web.manage","datamissing");

           if(fromDate.length==0)  transactionForm.FromDate.focus();
      else if(untilDate.length==0) transactionForm.UntilDate.focus();
    }
  }

  <%-- VIEW ALL ERRORS --%>
  function viewAllErrors(displaySwitch){
    var rows = document.getElementsByTagName("tr");
    var errorCounter = 0;

    for(var i=0; i<rows.length; i++){
      if(rows[i].id.indexOf("error_")==0){
        errorCounter++;
        rows[i].style.display = (displaySwitch?"block":"none");

        if(displaySwitch){
          document.getElementById("header_"+errorCounter).className = "list";
        }
        else{
          if(errorCounter%2==1){
            document.getElementById("header_"+errorCounter).className = "list1";
          }
        }
      }
    }
  }
</script>

<a name="bottom">&nbsp;</a>