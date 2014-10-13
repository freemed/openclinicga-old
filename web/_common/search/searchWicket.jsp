<%@ page import="be.openclinic.finance.Wicket,java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sFindWicketService     = checkString(request.getParameter("FindWicketService"));
    String sFindWicketServiceName = checkString(request.getParameter("FindWicketServiceName"));

    String sVarCode  = checkString(request.getParameter("VarCode"));
    String sVarText  = checkString(request.getParameter("VarText"));

    //String sSelectOwner  = Helper.normalizeSpecialCharacters(sFindBalanceOwner);
%>
    <form name='SearchForm' method="POST" onSubmit="doFind();" onkeydown="if(enterEvent(event,13)){doFind();}">
        <input type="hidden" name="VarCode" value="<%=sVarCode%>">
        <input type="hidden" name="VarText" value="<%=sVarText%>">
        <table width='100%' border='0' cellspacing='0' cellpadding='0' class='menu'>
            <%-- search fields row 1 --%>
            <%-- service --%>
            <tr>
                <td><%=getTran("Web","service",sWebLanguage)%></td>
                <td>
                    <input type="hidden" name="FindWicketService" value="<%=sFindWicketService%>">
                    <input class="text" type="text" name="FindWicketServiceName" readonly size="<%=sTextWidth%>" value="<%=sFindWicketServiceName%>">
                    <input class="button" type="button" name="SearchServiceButton" value="<%=getTranNoLink("Web","Select",sWebLanguage)%>" onclick="searchService('FindWicketService','FindWicketServiceName');">
                </td>
            </tr>
            <tr height='25'>
                <td/>
                <td>
                    <%-- BUTTONS --%>
                    <input class="button" type="button" onClick="doFind();" name="findButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>">
                    <input class="button" type="button" onClick="clearFields();" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>">&nbsp;
                </td>
            </tr>

            <%-- SEARCH RESULTS TABLE --%>
            <tr>
                <td style="vertical-align:top;" colspan="3" align="center" class="white" width="100%">
                    <div class="search" style="width:484">
                        <table border='0' width='100%' cellspacing="1" cellpadding="0">
                            <%
                                Vector vWickets = Wicket.getWicketsByService(sFindWicketService);

                                String sClass = "", sWicketUID, sWicketName, sCreatedate = "";
                                boolean recsFound = false;
                                StringBuffer results = new StringBuffer();

                                if (vWickets.size() > 0) {

                                    Iterator iter = vWickets.iterator();

                                    Wicket objWicket;

                                    while (iter.hasNext()) {
                                        recsFound = true;
                                        objWicket = (Wicket) iter.next();

                                        // alternate row-style
                                        if (sClass.equals("")) sClass = "1";
                                        else sClass = "";

                                        // names
                                        sWicketUID = objWicket.getUid();
                                        sWicketName = objWicket.getUid() + " " + objWicket.getServiceUID();
                                        if (objWicket.getCreateDateTime() != null) {
                                            sCreatedate = ScreenHelper.stdDateFormat.format(objWicket.getCreateDateTime());
                                        } else {
                                            sCreatedate = "";
                                        }


                                        results.append("<tr class='list" + sClass + "' onclick=\"setWicket(" + sWicketUID + ", '" + sWicketName.toUpperCase() + "');\">")
                                                .append("<td>" + sWicketName.toUpperCase() + "</td>")
                                                .append("<td>" + checkString(getTran("Service", objWicket.getServiceUID(), sWebLanguage)) + "</td>")
                                                .append("<td>" + sCreatedate + "</td>")
                                                .append("</tr>");
                                    }

                                    if (recsFound) {
                            %>
                                            <tbody class="hand">
                                                <tr class="admin">
                                                    <td width='33%' nowrap><%=getTran("Web","name",sWebLanguage)%></td>
                                                    <td width='*' nowrap><%=getTran("Web","service",sWebLanguage)%></td>
                                                    <td width='15%' nowrap><%=getTran("Web","created",sWebLanguage)%></td>
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
            <input type="button" class="button" name="buttonclose" value='<%=getTranNoLink("Web","Close",sWebLanguage)%>' onclick='window.close()'>
        </center>

        <script>
          window.resizeTo(500,510);

          <%-- CLEAR FIELDS --%>
          function clearFields() {
            SearchForm.FindWicketService.value="";
            SearchForm.FindWicketServiceName.value="";
          }

          <%-- DO FIND --%>
          function doFind(){
              ToggleFloatingLayer('FloatingLayer',1);
              SearchForm.findButton.disabled = true;
              SearchForm.submit();
          }

          <%-- SET BALANCE --%>
          function setWicket(sWicketUID, sWicketName) {
            window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sWicketUID;

            if ('<%=sVarText%>'!=''){
                window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sWicketName;
            }

            window.close();
          }

          <%-- search service --%>
          function searchService(serviceUidField,serviceNameField){
            openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
          }
        </script>
    </form>
