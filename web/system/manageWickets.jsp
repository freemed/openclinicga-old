<%@ page import="be.openclinic.finance.Wicket,java.util.Vector,java.util.StringTokenizer" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.wicket","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- ADD AUTHORIZED USER ---------------------------------------------------------------------
    private String addAuthorizedUser(int userIdx, String userName, String sWebLanguage){
        StringBuffer html = new StringBuffer();

        html.append("<tr id='rowAuthorizedUsers"+userIdx+"'>")
            .append(" <td width='16'>")
            .append("  <a href='#' onclick='deleteAuthorizedUser(rowAuthorizedUsers"+userIdx+")'>")
            .append("   <img src='"+sCONTEXTPATH+"/_img/icon_delete.gif' alt='"+getTran("Web","delete",sWebLanguage)+"' class='link'>")
            .append("  </a>")
            .append(" </td>")
            .append(" <td>"+userName+"</td>")
            .append("</tr>");

        return html.toString();
    }
%>

<%
    //GENERAL
    StringBuffer authorizedUsersHTML = new StringBuffer(),
            authorizedUsersJS = new StringBuffer(),
            authorizedUsersDB = new StringBuffer();
    int authorisedUsersIdx = 1;
    String sDefaultSortDir = "DESC";
    String sSortDir = checkString(request.getParameter("SortDir"));
    if (sSortDir.length() == 0) sSortDir = sDefaultSortDir;

    String sAction = checkString(request.getParameter("Action"));

    String sEditWicketUID = checkString(request.getParameter("EditWicketUID"));
    String sEditWicketService = checkString(request.getParameter("EditWicketService"));
    String sEditWicketServiceName = checkString(request.getParameter("EditWicketServiceName"));
    String sEditWicketBalance = checkString(request.getParameter("EditWicketBalance"));
    String sEditWicketAuthorizedUsers = checkString(request.getParameter("EditAuthorizedUsers"));
    String sFindWicketBegin = checkString(request.getParameter("FindWicketBegin"));
    String sFindWicketEnd = checkString(request.getParameter("FindWicketEnd"));
    String sFindWicketService = checkString(request.getParameter("FindWicketService"));
    String sFindWicketServiceName = checkString(request.getParameter("FindWicketServiceName"));
    String sFindSortColumn = checkString(request.getParameter("FindSortColumn"));
    if (sAction.equals("DELETE")) {
        Wicket wicket = Wicket.get(sEditWicketUID);
        wicket.delete();
        sEditWicketUID = "";
        sAction = "SEARCH";
    }

    if (sAction.equals("SAVE")) {
        Wicket wicket = new Wicket();
        Service service;

        if (sEditWicketUID.length() > 0) {
            wicket = Wicket.get(sEditWicketUID);
        } else {
            wicket.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
            wicket.setBalance(0);
        }

        wicket.setServiceUID(sEditWicketService);
        service = Service.getService(sEditWicketService);
        wicket.setService(service);
        //wicket.setBalance(Double.valueOf(sEditWicketBalance).doubleValue());
        wicket.setAuthorizedUsersId(sEditWicketAuthorizedUsers);
        wicket.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        wicket.setUpdateUser(activeUser.userid);
        wicket.store();
        sEditWicketUID = wicket.getUid();
    }

    if (sEditWicketUID.length() > 0) {
        Wicket wicket = Wicket.get(sEditWicketUID);

        sEditWicketService = wicket.getServiceUID();
        sEditWicketServiceName = ScreenHelper.checkString(checkString(getTranNoLink("Service", wicket.getServiceUID(), sWebLanguage)));
        sEditWicketBalance = Double.toString(wicket.getBalance());
        sEditWicketAuthorizedUsers = wicket.getAuthorizedUsersId();
    }
%>
<!-- FIND BLOCK -->
<%
    if(sAction.equals("SEARCH") || sAction.equals("")){
%>
<form name="FindWicketForm" method="POST" action="<c:url value='/main.do'/>?Page=system/manageWickets.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("Web.manage","manageWickets",sWebLanguage," doBack();")%>
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- service --%>
        <tr>
            <td class="admin2"><%=getTran("Web","wicket",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="hidden" name="FindWicketService" value="<%=sEditWicketService%>">
                <input class="text" type="text" name="FindWicketServiceName" readonly size="<%=sTextWidth%>" value="<%=sFindWicketServiceName%>">
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchService('FindWicketService','FindWicketServiceName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="FindWicketForm.FindWicketServiceName.value='';FindWicketForm.FindWicketService.value='';">
                <input class='button' type='button' name='buttonfind' value='<%=getTran("Web","search",sWebLanguage)%>' onclick='doFind();'>
                <input class='button' type='button' name='buttonclear' value='<%=getTran("Web","Clear",sWebLanguage)%>' onclick='doClear();'>
                <input class='button' type='button' name='buttonnew' value='<%=getTran("Web.Occup","medwan.common.create-new",sWebLanguage)%>' onclick='doNew();'>
                <input class='button' type="button" name="Backbutton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
        <%-- action,sortcolumn --%>
        <input type='hidden' name='Action' value=''>
        <input type='hidden' name='FindSortColumn' value='<%=sFindSortColumn%>'>
    </table>
</form>
<!-- END FIND BLOCK -->
<%
    }
%>
<!-- RESULTS BLOCK -->
<%
    if (sAction.equals("SEARCH")) {
        //RESULTS

        Vector vWickets = Wicket.selectWicketsInService(sFindWicketService);
        StringBuffer sbResults = new StringBuffer();
        String sClass = "";

        Wicket wicket;

        Iterator iter = vWickets.iterator();

        while (iter.hasNext()) {
            if (sClass.equals("")) {
                sClass = "1";
            } else {
                sClass = "";
            }
            wicket = (Wicket) iter.next();
            String sDate = "";
            if (wicket.getCreateDateTime() != null) {
                sDate = checkString(new SimpleDateFormat("dd/MM/yyyy").format(wicket.getCreateDateTime()));
            }
            sbResults.append("<tr class=\"list" + sClass + "\"" +
                    " onmouseover=\"this.style.cursor='hand';\"" +
                    " onmouseout=\"this.style.cursor='default';\">" +
                    "   <td><a href='#' onclick='deleteWicket(\"" + wicket.getUid() + "\")'>" +
                    "       <img src='" + sCONTEXTPATH + "/_img/icon_delete.gif' alt='" + getTran("Web", "delete", sWebLanguage) + "' class='link'>" +
                    "       </a>" +
                    "   </td>" +
                    "   <td onclick=\"doSelect('" + wicket.getUid() + "');\">" + sDate + "</td>" +
                    "   <td onclick=\"doSelect('" + wicket.getUid() + "');\">" + wicket.getUid() + "&nbsp;" + checkString(getTran("Service", wicket.getServiceUID(), sWebLanguage)) + "</td>" +
                    "   <td onclick=\"doSelect('" + wicket.getUid() + "');\">" + wicket.getBalance() + "</td>" +
                    "</tr>");

        }
        String sortTran = getTran("web", "clicktosort", sWebLanguage);
        if (vWickets.size() > 0) {
%>
    <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
        <tr class="admin">
            <td/>
            <td width="15%"><a href="#" title="<%=sortTran%>" class="underlined"><<%=sSortDir%>><%=getTranNoLink("Web","created",sWebLanguage)%></<%=sSortDir%>></a></td>
            <td width="30%"><%=getTranNoLink("web","name",sWebLanguage)%></td>
            <td width="*"><%=getTranNoLink("financial","balance",sWebLanguage)%></td>
        </tr>
        <%=sbResults%>
    </table>
    <%
    }else{
    %>
        <%=getTran("web","norecordsfound",sWebLanguage)%>
        <br><br>
    <%
    }
    %>
<!-- END RESULTS BLOCK -->
<%
    }
%>
<%-- EDIT BLOCK --%>
<%
    if (sAction.equals("NEW") || sAction.equals("SELECT") || sAction.equals("SAVE")) {

        String authorizedUserId = "";
        String authorizedUserName = "";
        // authorized users
        //String authorizedUserIds = checkString(serviceStock.getAuthorizedUserIds());
        if (sEditWicketAuthorizedUsers.length() > 0) {
            authorisedUsersIdx = 1;
            StringTokenizer idTokenizer = new StringTokenizer(sEditWicketAuthorizedUsers, "$");
            while (idTokenizer.hasMoreTokens()) {
                authorizedUserId = idTokenizer.nextToken();
              	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                authorizedUserName = ScreenHelper.getFullUserName(authorizedUserId, ad_conn);
                ad_conn.close();
                authorisedUsersIdx++;

                authorizedUsersJS.append("rowAuthorizedUsers" + authorisedUsersIdx + "=" + authorizedUserId + "£" + authorizedUserName + "$");
                authorizedUsersHTML.append(addAuthorizedUser(authorisedUsersIdx, authorizedUserName, sWebLanguage));
                authorizedUsersDB.append(authorizedUserId + "$");
            }
        }


%>
<form name="EditWicketForm" method="POST" action="<c:url value='/main.do'/>?Page=system/manageWickets.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("Web.manage","manageWickets",sWebLanguage," doSearchBack();")%>
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- service --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","wicket",sWebLanguage)%></td>
            <td class='admin2'>
                <select class="text" name="EditWicketService">
                    <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
        <%
            Vector vServices = Service.getWickets();

            Iterator iter = vServices.iterator();

            String sServiceId = "";
            String sSelected = "";
            while(iter.hasNext()){
                sServiceId = (String)iter.next();
                if(sEditWicketService.equals(sServiceId)){
                    sSelected = " selected";
                }else{
                    sSelected = "";
                }
                %>
                    <option value="<%=sServiceId%>" <%=sSelected%>><%=getTran("service",sServiceId,sWebLanguage)%></option>
                <%

            }
        %>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin" nowrap><%=getTran("Web","Authorizedusers",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <%-- add row --%>
                <input type="hidden" name="AuthorizedUserIdAdd" value="">
                <input class="text" type="text" name="AuthorizedUserNameAdd" size="<%=sTextWidth%>" value="" readonly>

                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchAuthorizedUser('AuthorizedUserIdAdd','AuthorizedUserNameAdd');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditWicketForm.AuthorizedUserIdAdd.value='';EditWicketForm.AuthorizedUserNameAdd.value='';">
                <img src="<c:url value="/_img/icon_add.gif"/>" class="link" alt="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addAuthorizedUser();">

                <table width="100%" cellspacing="1" id="tblAuthorizedUsers">
                    <%=authorizedUsersHTML%>
                </table>

                <input type="hidden" name="EditAuthorizedUsers" value="<%=authorizedUsersDB%>">
            </td>
        </tr>
<%=ScreenHelper.setFormButtonsStart()%>
    <input class='button' type="button" name="EditSaveButton" value='<%=getTran("Web","save",sWebLanguage)%>' onclick="doSave();">&nbsp;
    <input class='button' type="button" name="Backbutton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doSearchBack();">
<%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <input type="hidden" name="Action" value=""/>
    <input type="hidden" name="EditWicketUID" value="<%=sEditWicketUID%>"/>
</form>
<!-- END EDIT BLOCK -->
<%
    }
%>
<script>
    var iAuthorizedUsersIdx = <%=authorisedUsersIdx%>;
    var sAuthorizedUsers = "<%=authorizedUsersJS%>";
    <%-- ADD AUTHORIZED USER --%>
      function addAuthorizedUser(){
        if(EditWicketForm.AuthorizedUserIdAdd.value.length > 0){
          iAuthorizedUsersIdx++;

          sAuthorizedUsers+= "rowAuthorizedUsers"+iAuthorizedUsersIdx+"£"+
                             EditWicketForm.AuthorizedUserIdAdd.value+"£"+
                             EditWicketForm.AuthorizedUserNameAdd.value+"$";
          var tr = tblAuthorizedUsers.insertRow(tblAuthorizedUsers.rows.length);
          tr.id = "rowAuthorizedUsers"+iAuthorizedUsersIdx;

          var td = tr.insertCell(0);
          td.width = 16;
          td.innerHTML = "<a href='#' onclick='deleteAuthorizedUser(rowAuthorizedUsers"+iAuthorizedUsersIdx+")'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web","delete",sWebLanguage)%>' border='0'></a>";
          tr.appendChild(td);

          td = tr.insertCell(1);
          td.innerHTML = EditWicketForm.AuthorizedUserNameAdd.value;
          tr.appendChild(td);

          <%-- update the hidden field containing just the userids --%>
          EditWicketForm.EditAuthorizedUsers.value = EditWicketForm.EditAuthorizedUsers.value+EditWicketForm.AuthorizedUserIdAdd.value+"$";

          clearAuthorizedUserFields();
        }
        else{
            var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=firstselectaperson";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            if(window.showModalDialog){
                window.showModalDialog(popupUrl,'',modalities);
            }else{
                window.confirm("<%=getTranNoLink("web","firstselectaperson",sWebLanguage)%>");
            }

            EditWicketForm.AuthorizedUserNameAdd.focus();
        }
      }

      <%-- CLEAR AUTHORIZED USER FIELDS --%>
  function clearAuthorizedUserFields(){
    EditWicketForm.AuthorizedUserIdAdd.value = "";
    EditWicketForm.AuthorizedUserNameAdd.value = "";
  }

  <%-- DELETE AUTHORIZED USER --%>
  function deleteAuthorizedUser(rowid){
    var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer;

    if(window.showModalDialog){
        answer = window.showModalDialog(popupUrl,'',modalities);
    }else{
        answer = window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");
    }

    if(answer==1){
      sAuthorizedUsers = deleteRowFromArrayString(sAuthorizedUsers,rowid.id);

      <%-- update the hidden field containing just the userids --%>
      EditWicketForm.EditAuthorizedUsers.value = extractUserIds(sAuthorizedUsers);

      tblAuthorizedUsers.deleteRow(rowid.rowIndex);
      clearAuthorizedUserFields();
    }
  }

  <%-- EXTRACT USER IDS (between '=' and '£') --%>
  function extractUserIds(sourceString){
    var array = sourceString.split("$");
    for (var i=0;i<array.length;i++){
       array[i] = array[i].substring(array[i].indexOf("=")+1,array[i].indexOf("£"));
    }
    return array.join("$");
  }

  <%-- DELETE ROW FROM ARRAY STRING --%>
  function deleteRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    for (var i=0;i<array.length;i++){
      if (array[i].indexOf(rowid)>-1){
        array.splice(i,1);
      }
    }
    return array.join("$");
  }

    function doClear(){
        FindWicketForm.FindWicketService.value = "";
        FindWicketForm.FindWicketServiceName.value = "";
    }
    function doFind(){
        if(FindWicketForm.FindWicketService.value != "")
        {
            FindWicketForm.Action.value = "SEARCH";
            FindWicketForm.buttonfind.disabled = true;
            FindWicketForm.submit();
        }
    }

    function doNew(){
        FindWicketForm.Action.value = "NEW";
        FindWicketForm.submit();
    }
    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=system/menu.jsp&ts=<%=getTs()%>";
    }

    function doSearchBack(){
        window.location.href="<c:url value='/main.do'/>?Page=system/manageWickets.jsp&ts=<%=getTs()%>";
    }

<%-- search service --%>
    function searchService(serviceUidField,serviceNameField){
        openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
    }

    function doSave(){
        if(EditWicketForm.EditWicketService.value == ""){
            var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=wicket&labelID=no_service";
            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
            var answer;
            if(window.showModalDialog){
                window.showModalDialog(popupUrl,'',modalities);
            }else{
                window.confirm("<%=getTranNoLink("wicket","no_service",sWebLanguage)%>");
            }
        }else{
            EditWicketForm.EditSaveButton.disabled = true;
            EditWicketForm.Action.value = "SAVE";
            EditWicketForm.submit();
        }
    }

    function doSelect(id){
        window.location.href="<c:url value='/main.do'/>?Page=system/manageWickets.jsp&EditWicketUID=" + id + "&Action=SELECT&ts=<%=getTs()%>";
    }

    <%-- popup : search authorized user --%>
  function searchAuthorizedUser(userUidField,userNameField){
    openPopup("/_common/search/searchUser.jsp&ts=<%=getTs()%>&ReturnUserID="+userUidField+"&ReturnName="+userNameField+"&displayImmatNew=no");
  }

  function deleteWicket(id){
    window.location.href="<c:url value='/main.do'/>?Page=system/manageWickets.jsp&EditWicketUID=" + id + "&Action=DELETE&ts=<%=getTs()%>";
  }
</script>