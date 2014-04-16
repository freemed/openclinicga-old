<%@page import="net.admin.system.EmailDestination"%>
<%@ page import="java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","select",activeUser)%>

<%=sJSEMAIL%>

<%
    String sAction            = checkString(request.getParameter("Action"));
    String sFindDestinationID = checkString(request.getParameter("FindDestinationID"));

    //--- SAVE -------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        String sEditDestinationLabel   = checkString(request.getParameter("EditDestinationLabel"));
        String sEditDestinationEmail   = checkString(request.getParameter("EditDestinationEmail"));
        String sEditDestinationUserIDs = checkString(request.getParameter("EditDestinationUserIDs"));

        //*** NEW ***
        if(sFindDestinationID.equals("-1")) {
            EmailDestination objEmailDestination = new EmailDestination();

            sFindDestinationID = MedwanQuery.getInstance().getNewResultCounterValue("EmailDestinationID");

            objEmailDestination.setDestinationid(Integer.parseInt(sFindDestinationID));
            objEmailDestination.setDestinationlabel(sEditDestinationLabel);
            objEmailDestination.setDestinationemail(sEditDestinationEmail);
            objEmailDestination.setDestinationuserids(sEditDestinationUserIDs);
            objEmailDestination.setUpdateuserid(Integer.parseInt(activeUser.userid));
            objEmailDestination.setUpdatetime(getSQLTime());

            EmailDestination.addEmailDestination(objEmailDestination);
        }
        //*** UPDATE ***
        else {
            EmailDestination objEmailDestination = new EmailDestination();

            objEmailDestination.setDestinationid(Integer.parseInt(sFindDestinationID));
            objEmailDestination.setDestinationlabel(sEditDestinationLabel);
            objEmailDestination.setDestinationemail(sEditDestinationEmail);
            objEmailDestination.setDestinationuserids(sEditDestinationUserIDs);
            objEmailDestination.setUpdateuserid(Integer.parseInt(activeUser.userid));
            objEmailDestination.setUpdatetime(getSQLTime());

            EmailDestination.saveEmailDestination(objEmailDestination);
        }
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete")){

        EmailDestination.deleteEmailDestination(sFindDestinationID);
    }
%>

<form name='transactionForm' method='post'>
    <input type="hidden" name="Action">

    <%-- SEARCH HEADER --%>
    <table border="0" width='100%' cellspacing="0" class="menu">
        <tr>
            <td colspan="2"><%=writeTableHeader("Web.manage","manageemails",sWebLanguage," doBack();")%></td>
        </tr>

        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.mail","destination",sWebLanguage)%></td>
            <td class="admin2">
                <select name="FindDestinationID" class="text" onChange="transactionForm.submit();">
                    <option value="-1"><%=getTran("Web.Occup","medwan.common.create-new",sWebLanguage)%></option>
                    <%
                        String sTmpDestinationID, sTmpDestinationLabel, sSelected;
                        Vector vEmailDestination = EmailDestination.getEmailDestinations(" ORDER BY destinationlabel");

                        Iterator iter = vEmailDestination.iterator();

                        EmailDestination objEmailDestination;

                        while (iter.hasNext()) {
                            objEmailDestination = (EmailDestination) iter.next();

                            sTmpDestinationID = checkString(Integer.toString(objEmailDestination.getDestinationid()));
                            sTmpDestinationLabel = checkString(objEmailDestination.getDestinationlabel());
                            sSelected = "";

                            if (sTmpDestinationID.equals(sFindDestinationID)) {
                                sSelected = " selected";
                            }

                    %><option value="<%=sTmpDestinationID%>"<%=sSelected%>><%=sTmpDestinationLabel%></option><%
                        }
                        if (sFindDestinationID.trim().length()==0){
                            sFindDestinationID = "-1";
                        }
                    %>
                </select>
            </td>
        </tr>
    </table>

    <%
        //--- GET DATA OF SELECTED EMAILDESTINATION -----------------------------------------------
        if(sFindDestinationID.length()>0) {

            objEmailDestination = EmailDestination.getEmailDestination(sFindDestinationID);

            String sDestinationLabel = "", sDestinationEmail = "", sDestinationUserIDs = "";

            if(objEmailDestination != null){
                sDestinationLabel   = checkString(objEmailDestination.getDestinationlabel());
                sDestinationEmail   = checkString(objEmailDestination.getDestinationemail());
                sDestinationUserIDs = checkString(objEmailDestination.getDestinationuserids());
            }
            %>
                <br>

                <%-- DESTINATION DETAILS --%>
                <table class="list" cellspacing="1" width="100%">
                    <%-- description --%>
                    <tr>
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.control","description",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditDestinationLabel" value="<%=sDestinationLabel%>" size="50">
                        </td>
                    </tr>

                    <%-- destination --%>
                    <tr>
                        <td class="admin"><%=getTran("web.mail","destination",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditDestinationEmail" value="<%=sDestinationEmail%>" size="50">
                        </td>
                    </tr>

                    <%-- userid --%>
                    <tr>
                        <td class="admin"><%=getTran("web.manage","Mail.UserIDs",sWebLanguage)%> *</td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditDestinationUserIDs" value="<%=sDestinationUserIDs%>" size="50">
                        </td>
                    </tr>
                    <%-- BUTTONS --%>
                    <%=ScreenHelper.setFormButtonsStart()%>
                        <%
                            // new destination
                            // display saveButton with add-label + do not display delete button
                            if(sFindDestinationID.equals("-1") || sFindDestinationID.length()==0){
                                %>
                                    <input type='button' class="button" name="saveButton" value='<%=getTran("Web","add",sWebLanguage)%>' onclick="doSave();">
                                <%
                            }
                            // existing destination
                            // display saveButton with save-label
                            else{
                                %>
                                    <input type='button' class="button" name="saveButton" value='<%=getTran("Web","save",sWebLanguage)%>' onclick="doSave();">
                                    <%=writeResetButton("transactionForm",sWebLanguage)%>
                                    <input type='button' class="button" name="deleteButton" value='<%=getTran("Web","delete",sWebLanguage)%>' onclick="doDelete();">
                                <%
                            }
                        %>
                        <input type='button' class="button" name="backButton" value='<%=getTran("Web","Back",sWebLanguage)%>' onClick='doBack();'>
                    <%=ScreenHelper.setFormButtonsStop()%>
                </table>

                <%-- indication of obligated fields --%>
                <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>

                <script>
                  transactionForm.EditDestinationLabel.focus();

                  <%-- DO SAVE --%>
                  function doSave(){
                    if(transactionForm.EditDestinationLabel.value.length > 0 &&
                       transactionForm.EditDestinationEmail.value.length > 0 &&
                       transactionForm.EditDestinationUserIDs.value.length > 0){
                      <%-- check for valid email --%>
                      if(!validEmailAddress(transactionForm.EditDestinationEmail.value)){
                        var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=invalidemailaddress";
                        var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                        window.showModalDialog(popupUrl,'',modalities);

                        transactionForm.EditDestinationEmail.focus();
                      }
                      else{
                        transactionForm.saveButton.disabled = true;
                        transactionForm.Action.value = 'save';
                        transactionForm.submit();
                      }
                    }
                    else{
                      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=okPopup.jsp&ts=<%=getTs()%>&labelType=web&labelID=somefieldsareempty";
                      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                      window.showModalDialog(popupUrl,'',modalities);

                      if(transactionForm.EditDestinationLabel.value.length == 0){
                        transactionForm.EditDestinationLabel.focus();
                      }
                      else if(transactionForm.EditDestinationEmail.value.length == 0){
                        transactionForm.EditDestinationEmail.focus();
                      }
                      else if(transactionForm.EditDestinationUserIDs.value.length == 0){
                        transactionForm.EditDestinationUserIDs.focus();
                      }
                    }
                  }

                  <%-- DO DELETE --%>
                  function doDelete(){
             		if(yesnoDialog("Web","areYouSureToDelete")){
                      transactionForm.Action.value = 'delete';
                      transactionForm.submit();
                    }
                  }

                  <%-- DO BACK --%>
                  function doBack(){
                    window.location.href = '<c:url value='/main.do'/>?Page=system/menu.jsp';
                  }
                </script>
            <%
        }
    %>
</form>