<%@page import="net.admin.system.AccessLog,
                java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
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

    //--- DELETE ACCESS ---------------------------------------------------------------------------
    if(sAction.equals("deleteAccess")){
        String sDelAccessId = checkString(request.getParameter("DelAccessId"));
        if(sDelAccessId.length() > 0){
            net.admin.system.AccessLog.delete(sDelAccessId);
            sMsg = getTran("web","dataIsDeleted",sWebLanguage);
        }
    }
    //--- DELETE ACCESSES -------------------------------------------------------------------------
    else if(sAction.equals("deleteAccesses")){
        java.util.Date delFromDate = null, delUntilDate = null;

        SimpleDateFormat stdDateFormat = ScreenHelper.stdDateFormat;
        if(sDelFromDate.length() > 0){
            delFromDate = ScreenHelper.parseDate(sDelFromDate);
        }

        if(sDelUntilDate.length() > 0){
            delUntilDate = ScreenHelper.parseDate(ScreenHelper.getDateAdd(sDelUntilDate,"1")); // add one day
        }

        net.admin.system.AccessLog.delete(delFromDate,delUntilDate);
        sMsg = getTran("web","dataIsDeleted",sWebLanguage);
    }
%>

<form name="transactionForm" id="transactionForm" method="post" onKeyDown="if(enterEvent(event,13)){doSearchAccesses();}">
    <%-- hidden fields --%>
    <input type="hidden" name="Action" value="">
    <input type="hidden" name="DelAccessId" value="">
    <input type="hidden" name="SortCol" value="<%=sSortCol%>">
    
    <%=writeTableHeader("Web.manage","MonitorAccess",sWebLanguage," doBack();")%>
    
    <table width="100%" class="menu" cellspacing="0">
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        <tr>
            <td><%=getTran("Web","End",sWebLanguage)%></td>
            <td><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        <tr>
            <td/>
            <td>
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="doSearchAccesses();">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFields()">&nbsp;
                <input type="button" class="button" name="ButtonBack" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
    
    <%
        // message
        if(sMsg.length() > 0){
            %><%=sMsg%><br><%
        }

        //--- DISPLAY ACCESSES --------------------------------------------------------------------
        if(sFindBegin.length()>0 || sFindEnd.length()>0){
            %>
                <br>
                <%-- found accesses --%>
                <table class="sortable" cellspacing="0" cellpadding="1" width="100%" id="searchresults">
                    <%-- HEADER --%>
                    <tr class="admin">
                        <td width="20">&nbsp;</td>
                        <td width="150"><%=getTran("Web","accesstime",sWebLanguage)%></td>
                        <td width="700"><%=getTran("Web","user",sWebLanguage)%></td>
                        <%-- link to bottom --%>
                        <td width="16" height="20" align="right">
                            <a href="#bottom" class="top"><img src="<c:url value='/_img/themes/default/bottom.gif'/>" class="link" style="vertical-align:bottom;" border="0"></a>
                        </td>
                    </tr>
                    <%
                        String sClass = "", sAccessTime, sName;
                        SimpleDateFormat fullDateFormat = ScreenHelper.fullDateFormatSS;
                        Vector vAL = AccessLog.searchAccessLogs(sFindBegin, sFindEnd);
                        Iterator iter = vAL.iterator();
                        AccessLog objAL;
                        while (iter.hasNext()) {
                            iCounter++;

                            objAL = (AccessLog) iter.next();
                            sAccessTime = fullDateFormat.format(objAL.getAccesstime());
                            sName = checkString(objAL.getLastname()) + " " + checkString(objAL.getFirstname());

                            // alternate row-style
                            if(sClass.equals("")) sClass = "1";
                            else                  sClass = "";

                            %>
                                <tr class="list<%=sClass%>">
                                    <td class="hand"><img src="<c:url value='/_img/icons/icon_delete.gif'/>" border="0" alt="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="deleteAccess('<%=objAL.getAccessid()%>');" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'/></td>
                                    <td><%=sAccessTime%></td>
                                    <td><%=sName%></td>
                                    <td>&nbsp;</td>
                                </tr>
                            <%
                        }

                        // no records found
                        if(iCounter==0){
                            %><tr><td colspan="4"><%=getTran("web","norecordsfound",sWebLanguage)%></td></tr><%
                        }
                    %>
                </table>
                <%
                    // number of records found
                    if(iCounter > 0){
                        %>
                        <div style="padding-bottom:5px;padding-top:2px;"><%=getTran("Web.Occup","total-number",sWebLanguage)%> : <%=iCounter%></div>
                        <%
                    }
        }

        if(iCounter > 0){
            %>
                <table class="menu" width="100%">
                    <tr>
                        <td width="<%=sTDAdminWidth%>"><%=getTran("Web","from",sWebLanguage)%></td>
                        <td><%=writeDateField("DelFromDate","transactionForm",sDelFromDate,sWebLanguage)%></td>
                        <td><%=getTran("Web","to",sWebLanguage)%></td>
                        <td>
                            <%=writeDateField("DelUntilDate","transactionForm",sDelUntilDate,sWebLanguage)%>&nbsp;&nbsp;
                            <input type="button" class="button" name="deleteRangeButton" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onClick="deleteAccesses();">
                            <input class="button" type="button" name="backButton" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onclick="doBack();">
                            <%-- BACK BUTTON --%>
                        </td>
                        <td align="right">
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

  function doSearchAccesses(){
    if(transactionForm.DelFromDate && transactionForm.DelUntilDate){
      transactionForm.DelFromDate.value = "";
      transactionForm.DelUntilDate.value = "";
    }

    var sBeginDate = transactionForm.FindBegin.value,
        sEndDate   = transactionForm.FindEnd.value;

    <%-- both dates given --%>
    if(sBeginDate.length > 0 && sEndDate.length > 0){
      if(sBeginDate!=sEndDate && !before(sBeginDate,sEndDate)){
        alertDialog("web.occup","endMustComeAfterBegin");

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
        
      transactionForm.FindBegin.focus();
    }
    <%-- no dates given --%>
    else{
      alertDialog("web.manage","datamissing");
    }
  }

  function clearFields(){
    transactionForm.FindBegin.value = "";
    transactionForm.FindEnd.value = "";
    transactionForm.FindBegin.focus();
  }

  function doSort(sortCol){
    transactionForm.SortCol.value = sortCol;
    transactionForm.submit();
  }

  function deleteAccess(accessId){
      transactionForm.Action.value = "deleteAccess";
      transactionForm.DelAccessId.value = accessId;
      transactionForm.submit();
  }

  function deleteAccesses(){
    var fromDate  = transactionForm.DelFromDate.value,
        untilDate = transactionForm.DelUntilDate.value;

    if(fromDate.length > 0 || untilDate.length > 0){
  	  if(yesnoDialog("Web","areYouSureToDelete")){
        transactionForm.deleteRangeButton.disabled = true;
        transactionForm.Action.value = "deleteAccesses";
        transactionForm.submit();
      }
    }
    else{
      alertDialog("web.manage","datamissing");

           if(fromDate.length==0)  transactionForm.FromDate.focus();
      else if(untilDate.length==0) transactionForm.UntilDate.focus();
    }
  }

  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp&Tab=database&ts=<%=getTs()%>";
  }
</script>

<a name="bottom">&nbsp;</a>