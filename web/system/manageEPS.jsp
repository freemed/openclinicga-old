<%@ page import="net.admin.system.ExternalPreventionService"%>
<%@ page import="java.util.Vector" %>
<%@include file="/_common/patient/patienteditHelper.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));
    String sFindEPS = checkString(request.getParameter("FindEPS"));

    String sName = "", sAddress = "", sID = "", sZipcode = "", sCity = "",
            sPhone = "", sFax = "", sPhysicianLastname = "", sPhysicianFirstname = "";

    //--- SAVE ------------------------------------------------------------------------------------
    if (sAction.equals("save") && sFindEPS != null && sFindEPS.length() > 0) {
        sName = checkString(request.getParameter("EditEPSName"));
        sAddress = checkString(request.getParameter("EditEPSAddress"));
        sZipcode = checkString(request.getParameter("EditEPSZipcode"));
        sCity = checkString(request.getParameter("EditEPSCity"));
        sPhone = checkString(request.getParameter("EditEPSPhone"));
        sFax = checkString(request.getParameter("EditEPSFax"));
        sPhysicianLastname = checkString(request.getParameter("EditEPSPhysicianLastname"));
        sPhysicianFirstname = checkString(request.getParameter("EditEPSPhysicianFirstname"));

        ExternalPreventionService objEPS = new ExternalPreventionService();

        objEPS.setEPSName(sName);
        objEPS.setEPSAddress(sAddress);
        objEPS.setEPSZipcode(sZipcode);
        objEPS.setEPSCity(sCity);
        objEPS.setEPSPhone(sPhone);
        objEPS.setEPSFax(sFax);
        objEPS.setEPSPhysicianLastname(sPhysicianLastname);
        objEPS.setEPSPhysicianFirstname(sPhysicianFirstname);
        objEPS.setUpdateuserid(Integer.parseInt(activeUser.userid));
        objEPS.setUpdatetime(getSQLTime());

        // insert
        if (sFindEPS.equals("-1")) {
            sFindEPS = MedwanQuery.getInstance().getNewResultCounterValue("EPSID");
            objEPS.setEPSID(Integer.parseInt(sFindEPS));

            ExternalPreventionService.addExternalPreventionService(objEPS);
        }
        // update
        else {
            objEPS.setEPSID(Integer.parseInt(sFindEPS));

            ExternalPreventionService.saveExternalPreventionService(objEPS);
        }
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if (sAction.equals("delete") && sFindEPS != null && sFindEPS.length() > 0) {
        ExternalPreventionService.deleteExternalPreventionService(getSQLTime(), sFindEPS);

        sFindEPS = "-1";
    }

    //--- COMPOSE EPS SELECTOR --------------------------------------------------------------------
    StringBuffer sEPSOptions = new StringBuffer();
    String sTmpName;

    Vector vEPS = ExternalPreventionService.getExternalPreventionServices();
    Iterator iter = vEPS.iterator();

    ExternalPreventionService objEPS;

    while (iter.hasNext()) {
        objEPS = (ExternalPreventionService) iter.next();

        sID = Integer.toString(objEPS.getEPSID());
        sTmpName = objEPS.getEPSName();

        sEPSOptions.append("<option value='" + sID + "'");

        if (sID.equals(sFindEPS)) {
            sName = sTmpName;
            sAddress = objEPS.getEPSAddress();
            sZipcode = objEPS.getEPSZipcode();
            sCity = objEPS.getEPSZipcode();
            sPhone = objEPS.getEPSPhone();
            sFax = objEPS.getEPSFax();
            sPhysicianLastname = objEPS.getEPSPhysicianLastname();
            sPhysicianFirstname = objEPS.getEPSPhysicianFirstname();

            sEPSOptions.append("selected");
        }

        sEPSOptions.append(">" + sTmpName + "</option>");
    }
%>

<%=checkPermission("system.management","select",activeUser)%>

<form name="transactionForm" method="post">
    <input type="hidden" name="Action">

    <table width='100%' cellspacing="0" cellpadding="0" class="menu">
        <%-- TITLE --%>
        <tr>
            <td colspan="2"><%=writeTableHeader("Web.manage","manage_external_prevention_services",sWebLanguage," doBack();")%></td>
        </tr>

        <%-- EPS selector --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Admin","external_prevention_service",sWebLanguage)%></td>
            <td class="admin2">
                <select name="FindEPS" class="text" onchange="transactionForm.submit();">
                    <option value="-1"><%=getTran("Web.Occup","medwan.common.create-new",sWebLanguage)%></option>
                    <%=sEPSOptions%>
                </select>
            </td>
        </tr>
    </table>

    <br>

    <%-- EPS DETAILS ----------------------------------------------------------------------------%>
    <table class="list" width="100%" cellspacing="1">
        <%-- EPS name --%>
        <tr>
            <td class="admin"><%=getTran("Web.Admin","external_prevention_service",sWebLanguage)%> *</td>
            <td class="admin2">
                <input class="text" type="text" name="EditEPSName" value="<%=sName%>" size="50">
            </td>
        </tr>

        <%=inputRow("Web","address","EditEPSAddress","",sAddress,"T",true, false,sWebLanguage,"")%>
        <%=writeZipcode(sZipcode, "EditEPSZipcode","","EditEPSCity",true,"Zipcode",sWebLanguage,"")%>
        <%=inputRow("Web","city","EditEPSCity","",sCity,"T",true, false,sWebLanguage,"")%>
        <%=inputRow("Web","telephone","EditEPSPhone","",sPhone,"T",true,false,sWebLanguage,"")%>
        <%=inputRow("Web","fax","EditEPSFax","",sFax,"T",true,false,sWebLanguage,"")%>

        <%-- Physician Lastname --%>
        <tr>
            <td class="admin"><%=getTran("Web.Admin","physician",sWebLanguage)%></td>
            <td class="admin2">
                <input class="text" type="text" name="EditEPSPhysicianLastname" value="<%=sPhysicianLastname%>" size="50">
            </td>
        </tr>

        <%-- Physician Firstname --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","firstname",sWebLanguage)%></td>
            <td class="admin2">
                <input class="text" type="text" name="EditEPSPhysicianFirstname" value="<%=sPhysicianFirstname%>" size="50">
            </td>
        </tr>
        <%-- BUTTONS --%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <%
                // new EPS
                // display saveButton with add-label + do not display delete button
                if(sFindEPS.equals("-1") || sFindEPS.length()==0){
                    %>
                        <input type='button' name='saveButton' class="button" value='<%=getTranNoLink("Web","add",sWebLanguage)%>' onclick="doSave();">
                    <%
                }
                else{
                    // existing EPS
                    // display saveButton with save-label
                    %>
                        <input type='button' name='saveButton' class="button" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave();">
                        <%=writeResetButton("transactionForm",sWebLanguage)%>
                        <input type="button" name='deleteButton' class="button" value="<%=getTranNoLink("Web","delete",sWebLanguage)%>" onclick="doDelete();"/>
                    <%
                }
            %>
            <input type='button' name='backButton' class="button" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' onClick='doBack();'>
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>

    <%-- indication of obligated fields --%>
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>

    <script>
      transactionForm.EditEPSName.focus();

      <%-- DO DELETE --%>
      function doDelete(){
          if(yesnoDeleteDialog()){
          transactionForm.deleteButton.disabled = true;
          transactionForm.Action.value = "delete";
          transactionForm.submit();
        }
      }

      <%-- DO SAVE --%>
      function doSave(){
        if(transactionForm.EditEPSName.value.length > 0){
          transactionForm.Action.value = 'save';
          transactionForm.saveButton.disabled = true;
          transactionForm.submit();
        }
        else{
          var popupUrl = "<%=sCONTEXTPATH%>/_common/search/template.jsp?Page=okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
          var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
          var answer = window.showModalDialog(popupUrl,'',modalities);

          if(transactionForm.EditEPSName.value.length==0){
             transactionForm.EditEPSName.focus();
          }
        }
      }

      <%-- DO BACK --%>
      function doBack(){
        window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
      }
    </script>
</form>