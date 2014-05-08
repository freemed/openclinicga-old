<%@page errorPage="/includes/error.jsp"%>
<%@include file="/_common/patient/patienteditHelper.jsp"%>

<%=sJSEMAIL%>

<%
    if((activePatient!=null)&&(request.getParameter("SavePatientEditForm")==null)) {
        %>
            <table border='0' width='100%' class="list" cellspacing="1">
        <%

        Service service;
        AdminFunction function;
        boolean bNew = false;
        AdminWorkContact awc = ScreenHelper.getActiveWork(activePatient);
        String sStartDate;

        if (awc == null) {
          awc = new AdminWorkContact();
          awc.begin = getDate();
          bNew = true;
          sStartDate = "PatientEditForm.DateOfBirth.value";
        }
        else {
            sStartDate = "\""+awc.begin+"\"";
        }

        String sBeginDate = (normalRow("Web","begin","WBegin","AdminWork",sWebLanguage)+"<input class='text' type='text' name='WBegin' value=\""+awc.begin.trim()+"\"");

        if (bEditable) {
            sBeginDate+=sBackground;
        }

        sBeginDate+=(" size='12' onblur='checkBegin(this, "+sStartDate+")'>"
            +"&nbsp;<img name='popcal' class='link' src='"+sCONTEXTPATH+"/_img/icon_agenda.gif' ALT='"
            +getTran("Web","Select",sWebLanguage)+"' onclick='gfPop1.fPopCalendar(document.getElementsByName(\"WBegin\")[0]);return false;'>"
            +"&nbsp;<img class='link'src='"+sCONTEXTPATH+"/_img/icon_compose.gif' alt='"+getTranNoLink("Web","PutToday",sWebLanguage)+"' OnClick=\"getToday(WBegin);\">");

        if (!bNew){
//            sBeginDate += "&nbsp;<input type='button' name='buttonNewAWC' class='button' onclick='newAWC()' value='"+getTran("Web","new",sWebLanguage)+"'>";
            sBeginDate+= " <img src='"+sCONTEXTPATH+"/_img/icon_new.gif' id='buttonNewAWC' class='link' alt='"+getTranNoLink("Web","new",sWebLanguage)+"' onclick='newAWC()'>";
        }
        sBeginDate += "</td></tr>";
        out.print(sBeginDate);

        String sRankCode = awc.rank.code;
        if (sRankCode.length()==0) {
            sRankCode = "";
        }
        else {
            sRankCode = getTran("Rank",awc.rank.code,sWebLanguage);
        }
%>

    <input type='hidden' name='WRank' value='<%=awc.rank.code%>'>
    <%=normalRow("Web","Rank","WRank","AdminWork",sWebLanguage)%>
    <input class='text' size='<%=sTextWidth%>' readonly type='text' name='WRankDescription' value='<%=sRankCode%>'<% if (bEditable) {out.print(sBackground);}%>>&nbsp;
    <%=ScreenHelper.writeSearchButton("buttonRank", "", "Rank", "WRank", "WRankDescription", "",sWebLanguage,sCONTEXTPATH)%></td></tr>
    <%=inputRow("Web","email","WEmail","AdminWork",awc.email,"T",bEditable,false,sWebLanguage,sBackground)%>
    <%=inputRow("Web","telephone","WTelephone","AdminWork",awc.telephone,"T",bEditable,false,sWebLanguage,sBackground)%>
    <%=inputRow("Web","fax","WFax","AdminWork",awc.fax,"T",bEditable,false,sWebLanguage,sBackground)%>
    <%=normalRow("Web","function","divFunction","AdminWork",sWebLanguage)%>
    <input type='text' class='text' size='<%=sTextWidth%>' name='NewFunctionCode' value=''>&nbsp;
    <br>
    <%=getTran("Web.Occup","medwan.common.type",sWebLanguage)%>&nbsp;
    <select name='NewFunctionType' class='text'>
        <option/>
        <%=ScreenHelper.writeSelect("FunctionType","",sWebLanguage)%>
    </select>
    &nbsp;<img src="<c:url value="/_img/icon_add.gif"/>" class="link" alt="<%=getTran("Web","add",sWebLanguage)%>" onclick="addFunction()">
    <div id='divFunction'></div>

<%
    int iFunctions = 0;
    String sCode, sType;
    for (int i=0; i<awc.functions.size();i++){
        function  = (AdminFunction) awc.functions.elementAt(i);
        if (function==null) {
          function = new AdminFunction();
        }

        sCode = function.code;
        if (sCode.length()==0) {
            sCode = "";
        }
        else {
            sCode = function.code;
        }

        sType = function.type;
        if (checkString(sType).length()==0) {
            sType = "";
        }
        else {
            sType = " ("+getTran("functionType",function.type,sWebLanguage)+")";
        }
        iFunctions++;

        %>
            <script>
              divFunction.innerHTML += "<div id='divFunction<%=iFunctions%>'>"
                +"<img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' class='link' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick='deleteFunction(divFunction<%=iFunctions%>)'>&nbsp;"
                +"<%=sCode+sType%>"
                +"<input type='hidden' name='EditFunctionType<%=iFunctions%>' value='<%=function.type%>'>"
                +"<input type='hidden' name='EditFunctionCode<%=iFunctions%>' value='<%=function.code%>'><br></div>";
            </script>
        <%
    }
%>
    </td>
  </tr>

    <%=inputRow("Web","status","WStatus","AdminWork",awc.status,"T",bEditable,false,sWebLanguage,sBackground)
        +inputRow("Web","statussituation","WStatusSituation","AdminWork",awc.statusSituation,"T",bEditable,false,sWebLanguage,sBackground)
        +inputRow("Web","companybegin","WCompanyBegin","AdminWork",awc.companyBegin,"D",bEditable,false,sWebLanguage,sBackground)
        +inputRow("Web","companyend","WCompanyEnd","AdminWork",awc.companyEnd,"D",bEditable,false,sWebLanguage,sBackground)
        +inputRow("Web","companyEndReason","WCompanyEndReason","AdminWork",awc.companyEndReason,"T",bEditable,false,sWebLanguage,sBackground)
    %>

    <%
      String sCategory = "<select name='WCategory' select-one class='text'";
      sCategory+="><option value='' SELECTED>"+getTran("web","choose",sWebLanguage)+"</option>";
      sCategory+=(ScreenHelper.writeSelect("Web.Statute",awc.category,sWebLanguage));
      out.print(normalRow("Web","Category","WCategory","AdminWork",sWebLanguage)+sCategory+"</select></td></tr>");
    %>

    <%
        service = getService(awc);

        if (service==null) {
          service = new Service();
        }

        String sServiceCode = service.code;
        if (sServiceCode.length()==0) {
            sServiceCode = "";
        }
        else {
            sServiceCode = getTran("service",service.code,sWebLanguage);
        }
    %>

    <input type=hidden name='WUnit' VALUE='<%=service.code%>'>
    <%=normalRow("Web","service","WUnit","AdminWork",sWebLanguage)%>
    <input class='text' size='<%=sTextWidth%>' readonly type='text' name='WUnitDescription' value='<%=(MedwanQuery.getInstance().getConfigString("showUnitID").equals("1")?service.code+" ":"")+sServiceCode+"'"%>'>&nbsp;
    <a href="#"><img src="<c:url value='/_img/icon_info.gif'/>" border="0" alt="<%=getTran("Web","Information",sWebLanguage)%>" onclick='searchInfoService(PatientEditForm.WUnit)'/></a>
    <%=ScreenHelper.writeServiceButton("buttonService", "", "WUnit", "WUnitDescription", "ok",sWebLanguage,sCONTEXTPATH)%>
    </td></tr>
    <%=inputRow("Web","comment","WComment","AdminWork",awc.comment,"T",bEditable,false,sWebLanguage,sBackground)%>

    <tr height="0">
        <td width='<%=sTDAdminWidth%>'></td><td width='*'></td>
    </tr>
</table>

<script>
  var iFunctions = <%=iFunctions%>;

  function newAWC(){
    getToday(document.getElementsByName("WBegin")[0]);
    document.getElementsByName("WRank")[0].value = "";
    document.getElementsByName("WRankDescription")[0].value = "";
    document.getElementsByName("WEmail")[0].value = "";
    document.getElementsByName("WTelephone")[0].value = "";
    document.getElementsByName("WFax")[0].value = "";
    document.getElementsByName("NewFunctionCode")[0].value = "";
    document.getElementsByName("NewFunctionType")[0].selectedIndex = -1;
    document.getElementsByName("divFunction")[0].innerHTML = "";
    document.getElementsByName("WStatus")[0].value = "";
    document.getElementsByName("WStatusSituation")[0].value = "";
    document.getElementsByName("WCompanyBegin")[0].value = "";
    document.getElementsByName("WCompanyEnd")[0].value = "";
    document.getElementsByName("WCompanyEndReason")[0].value = "";
    document.getElementsByName("WCategory")[0].selectedIndex = -1;
    document.getElementsByName("WUnit")[0].value = "";
    document.getElementsByName("WUnitDescription")[0].value = "";
    document.getElementsByName("WComment")[0].value = "";

    document.getElementsByName("WBegin")[0].focus();
  }

  function checkSubmitAdminWork() {
    var maySubmit = true;

    var sObligatoryFields = "<%=MedwanQuery.getInstance().getConfigString("ObligatoryFields_AdminWork")%>";
    var aObligatoryFields = sObligatoryFields.split(",");

    <%-- check for valid email --%>
    if(PatientEditForm.WEmail.value.length > 0){
      if(!validEmailAddress(PatientEditForm.WEmail.value)){
        maySubmit = false;
        displayGenericAlert = false;

        var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=999999999&labelType=Web&labelID=invalidemailaddress";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        window.showModalDialog(popupUrl,'',modalities);

        activateTab('AdminWork');
        PatientEditForm.WEmail.focus();
      }
    }

    <%-- add selected function that is not added yet by user --%>
    if (PatientEditForm.NewFunctionCode.value.length>0){
      addFunction();
    }

    <%-- check obligatory fields for content --%>
    for(var i=0; i<aObligatoryFields.length; i++){
      var obligatoryField = document.all(aObligatoryFields[i]);

      if(obligatoryField != null){
        if(obligatoryField.type == undefined){
          if(obligatoryField.innerHTML == null || obligatoryField.innerHTML == " " || obligatoryField.innerHTML.length == 0 ){
            if(document.all('NewFunctionCode')!=null){
              activateTab('AdminWork');
              document.all('NewFunctionCode').focus();
            }
            maySubmit = false;
            break;
          }
        }
        else if(obligatoryField.value == null || obligatoryField.value == " " || obligatoryField.value.length == 0){
          if(obligatoryField.type != "hidden"){
            activateTab('AdminWork');
            obligatoryField.focus();
          }

          maySubmit = false;
          break;
        }
      }
    }

    <%-- check company dates --%>
    var beginDate = PatientEditForm.WCompanyBegin.value;
    var endDate   = PatientEditForm.WCompanyEnd.value;

    if((beginDate!="" && endDate!="") && !before(beginDate,endDate)){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=999999999&labelType=Web.Occup&labelID=endMustComeAfterBegin";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      window.showModalDialog(popupUrl,'',modalities);

      activateTab('AdminWork');
      PatientEditForm.WCompanyEnd.focus();
      maySubmit = false;
      displayGenericAlert = false;
    }

    return maySubmit;
  }

  function addFunction() {
    if (PatientEditForm.NewFunctionCode.value.length>0) {
      var sFunctionCode = PatientEditForm.NewFunctionCode.value;
      var sFunctionType = "", sFunctionTypeDescr = "";
      if (PatientEditForm.NewFunctionType.selectedIndex > 0){
        sFunctionTypeDescr = " ("+PatientEditForm.NewFunctionType.options[PatientEditForm.NewFunctionType.selectedIndex].text+")";
        sFunctionType = PatientEditForm.NewFunctionType.options[PatientEditForm.NewFunctionType.selectedIndex].value;
      }
      iFunctions ++;

      divFunction.innerHTML += "<div id='divFunction"+iFunctions+"'><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' class='link' alt='<%=getTranNoLink("Web","delete",sWebLanguage)%>' onclick='deleteFunction(divFunction"+iFunctions+")'>&nbsp;"
        +PatientEditForm.NewFunctionCode.value+sFunctionTypeDescr
        +"<input type='hidden' name='EditFunctionType"+iFunctions+"' value='"+sFunctionType+"'>"
        +"<input type='hidden' name='EditFunctionCode"+iFunctions+"' value='"+sFunctionCode+"'><br></div>";

      PatientEditForm.NewFunctionCode.value = "";
      PatientEditForm.NewFunctionType.selectedIndex = -1;
    }
  }

  function deleteFunction(divName){
    divFunction.removeChild(divName);
  }
</script>
<%
    }
%>
