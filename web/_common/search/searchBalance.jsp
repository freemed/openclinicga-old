<%@ page import="be.openclinic.finance.Balance"%>
<%@ page import="java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sFindBalanceOwner     = checkString(request.getParameter("FindBalanceOwner"));
    String sFindBalanceOwnerName = checkString(request.getParameter("FindBalanceOwnerName"));

    String sVarCode  = checkString(request.getParameter("VarCode"));
    String sVarText  = checkString(request.getParameter("VarText"));

    String sSelectOwner  = Helper.normalizeSpecialCharacters(sFindBalanceOwner);
%>
<html>
<head>
    <title><%=sAPPTITLE%></title>
</head>
<body class="Geenscroll">
    <form name='SearchForm' method="POST" onSubmit="doFind();" onkeydown="if(window.event.keyCode==13){doFind();}">
        <input type="hidden" name="VarCode" value="<%=sVarCode%>">
        <input type="hidden" name="VarText" value="<%=sVarText%>">
        <table width='100%' border='0' cellspacing='0' cellpadding='0' class='menu'>
            <%-- search fields row 1 --%>
            <tr height='25'>
                <td nowrap>
                    &nbsp;<%=getTran("web","owner",sWebLanguage)%>
                </td>
                <td nowrap>
                    <input type="hidden" name="FindBalanceOwner" value="<%=sFindBalanceOwner%>">
                    <input class="text" type="text" name="FindBalanceOwnerName" readonly size="70" value="<%=sFindBalanceOwnerName%>">
                    <input class="button" type="button" name="SearchOwnerButton" value="<%=getTran("Web","Select",sWebLanguage)%>" onclick="searchOwner('FindBalanceOwner','FindBalanceOwnerName');">
                </td>
            </tr>
            <tr height='25'>
                <td/>
                <td>
                    <%-- BUTTONS --%>
                    <input class="button" type="button" onClick="doFind();" name="findButton" value="<%=getTran("Web","find",sWebLanguage)%>">
                    <input class="button" type="button" onClick="clearFields();" name="clearButton" value="<%=getTran("Web","clear",sWebLanguage)%>">&nbsp;
                </td>
            </tr>

            <%-- SEARCH RESULTS TABLE --%>
            <tr>
                <td style="vertical-align:top;" colspan="3" align="center" class="white" width="100%">
                    <div class="search" style="width:484">
                        <table border='0' width='100%' cellspacing="1" cellpadding="0">
                            <%
                                Vector vBalances = Balance.searchBalances(sSelectOwner);

                                String sClass = "", sOwnerName, sOwnerUID, sBalanceName;
                                boolean recsFound = false;
                                StringBuffer results = new StringBuffer();

                                if (vBalances.size() > 0) {


                                    Iterator iter = vBalances.iterator();

                                    Balance objBalance = new Balance();

                                    while (iter.hasNext()) {
                                        recsFound = true;
                                        objBalance = (Balance) iter.next();

                                        // alternate row-style
                                        if (sClass.equals("")) sClass = "1";
                                        else sClass = "";

                                        // names
                                        sOwnerUID = objBalance.getOwner().getObjectUid();
                                        sOwnerName = ScreenHelper.getFullUserName(sOwnerUID);

                                        sBalanceName = objBalance.getUid();

                                        results.append("<tr class='list" + sClass + "' onclick=\"setBalance(" + sBalanceName + ", '" + sBalanceName.toUpperCase() + "');\">")
                                                .append(" <td>" + sOwnerName.toUpperCase() + "</td>")
                                                .append(" <td>" + objBalance.getDate() + "</td>")
                                                .append("</tr>");
                                    }

                                    if (recsFound) {
                            %>
                                            <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                                                <tr class="admin">
                                                    <td width='*' nowrap><%=getTran("Web","name",sWebLanguage)%></td>
                                                    <td width='50' nowrap><%=getTran("Web","date",sWebLanguage)%></td>
                                                </tr>

                                                <%=results%>
                                            </tbody>
                                        <%
                                    }
                                    else{
                                        // display 'no results' message
                                        %>
                                            <tr>
                                                <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                                            </tr>
                                        <%
                                    }
                                }
                            %>
                        </table>
                    </div>
                </td>
            </tr>
        </table>
        <br>

        <%-- CLOSE BUTTON --%>
        <center>
            <input type="button" class="button" name="buttonclose" value='<%=getTran("Web","Close",sWebLanguage)%>' onclick='window.close()'>
        </center>

        <script>
          window.resizeTo(500,510);

          <%-- CLEAR FIELDS --%>
          function clearFields() {
            SearchForm.FindBalanceOwner.value="";
            SearchForm.FindBalanceOwnerName.value="";
          }

          <%-- DO FIND --%>
          function doFind(){
              ToggleFloatingLayer('FloatingLayer',1);
              SearchForm.findButton.disabled = true;
              SearchForm.submit();
          }

          <%-- SET BALANCE --%>
          function setBalance(sBalanceUID, sBalanceName) {
            window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sBalanceUID;

            if ('<%=sVarText%>'!=''){
                window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sBalanceName;
            }

            window.close();
          }

          <%-- search owner --%>
          function searchOwner(ownerUidField,ownerNameField){
              openPopup("/_common/search/searchPatient.jsp&ts=<%=getTs()%>&ReturnPersonID="+ownerUidField+"&ReturnName="+ownerNameField+"&displayImmatNew=no&isUser=no");
          }
        </script>
    </form>
</body>
</html>