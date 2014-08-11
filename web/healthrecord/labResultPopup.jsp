<%@page import="be.openclinic.medical.LabAnalysis"%>
<%@page import="be.openclinic.medical.RequestedLabAnalysis"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=sJSDROPDOWNMENU%>
<%
    String msg = "";

    String sAction = checkString(request.getParameter("Action"));

    // get data from request
    String analysisCode  = checkString(request.getParameter("analysisCode")),
           serviceId     = checkString(request.getParameter("serverId")),
           transactionId = checkString(request.getParameter("transactionId")),
           sEditable     = checkString(request.getParameter("editable"));

    // option : editable fields
    boolean editable = false;
    if(sEditable.length() > 0){
        if(sEditable.equals("true")) editable = true;
    }

    /// DEBUG /////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("### action : "+sAction+" ###################################");
        Debug.println("# analysisCode  : "+analysisCode);
        Debug.println("# serviceId     : "+serviceId);
        Debug.println("# transactionId : "+transactionId);
        Debug.println("# editable      : "+editable);
    }
    ///////////////////////////////////////////////////////////////////////////////

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("Save")){
        RequestedLabAnalysis reqLabAnalysis = new RequestedLabAnalysis();
        reqLabAnalysis.setPatientId(activePatient.personid);
        reqLabAnalysis.setComment(checkString(request.getParameter("EditComment")));
        reqLabAnalysis.setResultValue(checkString(request.getParameter("EditResultValue")));
        reqLabAnalysis.setResultUnit(checkString(request.getParameter("EditResultUnit")));
        reqLabAnalysis.setResultModifier(checkString(request.getParameter("EditResultModifier")));
        reqLabAnalysis.setResultComment(checkString(request.getParameter("EditResultComment")));
        reqLabAnalysis.setResultRefMax(checkString(request.getParameter("EditResultRefMax")));
        reqLabAnalysis.setResultRefMin(checkString(request.getParameter("EditResultRefMin")));
        reqLabAnalysis.setResultDate(new java.util.Date(ScreenHelper.parseDate(request.getParameter("EditResultDate")).getTime()));
        reqLabAnalysis.setResultUserId(request.getParameter("EditResultUserId"));
        reqLabAnalysis.setResultProvisional(request.getParameter("EditResultProvisional"));

        reqLabAnalysis.update(serviceId,transactionId,analysisCode);
        //msg = getTran("web.manage","labanalysissaved",sWebLanguage);
    }

    // get specified analysis from Db
    RequestedLabAnalysis analysis = RequestedLabAnalysis.get(Integer.parseInt(serviceId),Integer.parseInt(transactionId),analysisCode);
%>
<form name="transactionForm" id="transactionForm" method="post" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
<%=writeTableHeader("Web.Occup","labresult",sWebLanguage,"")%>
<table width="100%" class="list" cellspacing="1" cellpadding="0">
    <%-- hidden fields --%>
    <input type="hidden" name="serverid" value="<%=analysis.getServerId()%>">
    <input type="hidden" name="transactionid" value="<%=analysis.getTransactionId()%>">
    <input type="hidden" name="Action">
    <%-- ANALYSIS CODE (uneditable) --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","labanalysis.cols.code",sWebLanguage)%></td>
        <td class="admin2"><%=analysis.getAnalysisCode()%></td>
    </tr>
    <%-- ANALYSIS TYPE (uneditable) --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","labanalysis.cols.type",sWebLanguage)%></td>
        <td class="admin2"><%=RequestedLabAnalysis.getAnalysisType(analysis.getAnalysisCode(),sWebLanguage)%></td>
    </tr>
    <%-- ANALYSIS NAME (uneditable) --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","labanalysis.cols.name",sWebLanguage)%></td>
        <td class="admin2"><%=LabAnalysis.labelForCode(analysis.getAnalysisCode(), sWebLanguage) %></td>
    </tr>
    <%-- ANALYSIS MONSTER (uneditable) --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","labanalysis.cols.monster",sWebLanguage)%></td>
        <td class="admin2"><%=getTran("labanalysis.monster",RequestedLabAnalysis.getAnalysisMonster(analysis.getAnalysisCode()),sWebLanguage)%></td>
    </tr>
    <%-- COMMENT --%>
    <tr>
        <td class="admin"><%=getTran("Web.manage","labanalysis.cols.comment",sWebLanguage)%></td>
        <td class="admin2">
            <%
                if(editable){
                    %><input type="text" class="text" name="EditComment" size="80" maxLength="255" value="<%=analysis.getComment()%>"><%
                }
                else{
                    %><%=analysis.getComment()%><%
                }
            %>
        </td>
    </tr>
</table>
<br>
<%-- ####################################### RESULT ########################################## --%>
<table width="100%" class="list" cellspacing="1" cellpadding="0">
    <%-- RESULT VALUE AND UNIT --%>
    <tr>
        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","labanalysis.cols.resultvalue",sWebLanguage)%><%=(editable?"&nbsp;*&nbsp;":"")%></td>
        <td class="admin2">
            <%
                // value
                if(editable){
                    %><input type="text" class="text" name="EditResultValue" size="10" maxLength="10" value="<%=analysis.getResultValue()%>" onblur="calculateModifier()">&nbsp;<%
                }
                else{
                    %><%=analysis.getResultValue()%>&nbsp;<%
                }

                %><%=analysis.getResultUnit()%><%
            %>
        </td>
    </tr>
    <%-- RESULT REF MIN --%>
    <tr>
        <td class="admin"><%=getTran("Web.manage","labanalysis.cols.resultrefmin",sWebLanguage)%></td>
        <td class="admin2">
            <%
                if(editable){
                    %><input type="text" class="text" name="EditResultRefMin" size="10" maxLength="10" value="<%=analysis.getResultRefMin()%>" onblur="calculateModifier()">&nbsp;<%
                }
                else{
                    %><%=analysis.getResultRefMin()%>&nbsp;<%
                }
            %>
        </td>
    </tr>
    <%-- RESULT REF MAX --%>
    <tr>
        <td class="admin"><%=getTran("Web.manage","labanalysis.cols.resultrefmax",sWebLanguage)%></td>
        <td class="admin2">
            <%
                if(editable){
                    %><input type="text" class="text" name="EditResultRefMax" size="10" maxLength="10" value="<%=analysis.getResultRefMax()%>" onblur="calculateModifier()">&nbsp;<%
                }
                else{
                    %><%=analysis.getResultRefMax()%>&nbsp;<%
                }

            %>
        </td>
    </tr>
    <%-- RESULT MODIFIER --%>
    <tr>
        <td class="admin"><%=getTran("Web.manage","labanalysis.cols.resultmodifier",sWebLanguage)%></td>
        <td class="admin2">
            <%
                if(editable){
                    %>
                        <select class="text" name="EditResultModifier">
                            <option></option>
                            <%=ScreenHelper.writeSelect("labanalysis.resultmodifier",analysis.getResultModifier(),sWebLanguage)%>
                        </select>
                    <%
                }
                else{
                    %><%=getTran("labanalysis.resultmodifier",analysis.getResultModifier(),sWebLanguage)%><%
                }
            %>
        </td>
    </tr>
    <%-- RESULT COMMENT --%>
    <tr>
        <td class="admin"><%=getTran("Web.manage","labanalysis.cols.resultcomment",sWebLanguage)%></td>
        <td class="admin2">
            <%
                if(editable){
                    %><textArea name="EditResultComment" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="80"><%=analysis.getResultComment()%></textArea><%
                }
                else{
                    %><%=analysis.getResultComment().replaceAll("\r\n","<br>")%><%
                }
            %>
        </td>
    </tr>
    <%-- provisional --%>
    <tr>
        <td class="admin"><%=getTran("Web.occup","lab.provisional",sWebLanguage)%></td>
        <td class="admin2">
            <%
                if(editable){
                    %><input type="checkbox" name="EditResultProvisional" value="1"<%if (checkString(analysis.getResultProvisional()).length()>0){out.print(" checked");}%>/><%
                }
                else{
                    if(checkString(analysis.getResultProvisional()).length()>0){
                        out.println(getTran("web.occup","lab.provisional",sWebLanguage));
                    }
                }
            %>
        </td>
    </tr>
    <%-- RESULT DATE --%>
    <tr>
        <td class="admin"><%=getTran("Web.manage","labanalysis.cols.resultdate",sWebLanguage)%><%=(editable?"&nbsp;*&nbsp;":"")%></td>
        <td class="admin2">
            <%
                if(editable){
                    %><%=writeDateField("EditResultDate","transactionForm",ScreenHelper.stdDateFormat.format(analysis.getResultDate()),sWebLanguage)%><%
                }
                else{
                    %><%=ScreenHelper.stdDateFormat.format(analysis.getResultDate())%><%
                }
            %>
        </td>
    </tr>
    <%-- RESULT USER --%>
    <%
        if(editable){
            %><input type="hidden" class="text" name="EditResultUserId" value="<%=activeUser.userid%>"><%
        }
        else if(analysis.getResultUserId().length() > 0){
           	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            String resultUserFullName = ScreenHelper.getFullUserName(analysis.getResultUserId(),ad_conn);
            ad_conn.close();

            %>
                <tr>
                    <td class="admin"><%=getTran("Web.manage","labanalysis.cols.resultuserid",sWebLanguage)%></td>
                    <td class="admin2">
                        <input type="hidden" name="EditResultUserId" value="<%=analysis.getResultUserId()%>">
                        <%=resultUserFullName%>
                    </td>
                </tr>
            <%
        }
    %>
    <%-- MESSAGE --%>
    <%
        if(msg.length() > 0){
            %><tr><td class="admin2" colspan="2"><%=msg%></td></tr><%
        }
    %>
</table>
<%-- BUTTONS ------------------------------------------------------------------------------------%>
<p align="center">
    <%
        if(editable){
            %><input class="button" type="button" name="saveButton" id="saveButton" value="<%=getTran("Web","save",sWebLanguage)%>" onClick="doSave();"/><%
        }
    %>
    <input class="button" type="button" value="<%=getTran("Web","close",sWebLanguage)%>" onclick="window.close();">
</p>
<script>
  window.resizeTo(670,430);
  if(transactionForm.EditResultValue!=null) transactionForm.EditResultValue.focus();

  resizeAllTextareas(10);

  <%-- SAVE --%>
  function doSave(){
    if(transactionForm.EditResultValue.value.length > 0 && transactionForm.EditResultDate.value.length > 0){
      transactionForm.saveButton.disabled = true;
      transactionForm.Action.value = "Save";
      transactionForm.submit();
    }
    else{
      alertDialog("web.manage","datamissing");
      if(transactionForm.EditResultValue!=null) transactionForm.EditResultValue.focus();
    }
  }

  <%-- CALCULATE MODIFIER --%>
  function calculateModifier(){
    sResult = isMyNumber(transactionForm.EditResultValue.value);
    sMin = isMyNumber(transactionForm.EditResultRefMin.value);
    sMax = isMyNumber(transactionForm.EditResultRefMax.value);

    if(sResult.length>0&&sMin.length>0&&sMax.length>0){
      iResult = sResult*1;
      iMin = sMin*1;
      iMax = sMax*1;
      sResult = "";

      if((iResult >= iMin)&&(iResult <= iMax)){
        sResult = "n";
      }
      else{
        iAverage = (iMin+iMax)/2;

        if(iResult > iMax+iAverage){
          sResult = "+++";
        }
        else if(iResult > iMax + iAverage/2){
          sResult = "++";
        }
        else if(iResult > iMax){
          sResult = "+";
        }
        else if(iResult < iMin - iAverage){
          sResult = "---";
        }
        else if(iResult < iMin - iAverage/2){
          sResult = "--";
        }
        else if(iResult < iMin){
          sResult = "-";
        }
      }

      if(sResult.length>0){
        for(var n=0;n<transactionForm.EditResultModifier.length;n++){
          if(transactionForm.EditResultModifier.options[n].value==sResult){
            transactionForm.EditResultModifier.selectedIndex = n;
            break;
          }
        }
      }
    }
    else{
      transactionForm.EditResultModifier.selectedIndex = -1;
    }
  }

  function isMyNumber(sObject){
    sObject = sObject.replace(",",".");

    if(sObject.charAt(0)=="<"||sObject.charAt(0)==">"){
      sObject = sObject.substring(1);
    }
    var string = sObject;
    var vchar = "01234567890.";
    var dotCount = 0;

    for(var i=0; i<string.length; i++){
      if(vchar.indexOf(string.charAt(i))==-1){
        return "";
      }
      else{
        if(string.charAt(i)=="."){
          dotCount++;
          if(dotCount > 1){
            return "";
          }
        }
      }
    }

    if(sObject.length > 250){
      sObject = sObject.substring(0,249);
    }
    return sObject;
  }

  <%-- The following script is used to hide the calendar whenever you click the document. --%>
  <%-- When using it you should set the name of popup button or image to "popcal", otherwise the calendar won't show up. --%>
  document.onmousedown = function(e){
    var n=!e?self.event.srcElement.name:e.target.name;

    if(document.layers){
  	  with(gfPop) var l=pageX, t=pageY, r=l+clip.width, b=t+clip.height;
	  if(n!="popcal"&&(e.pageX>r||e.pageX<l||e.pageY>b||e.pageY<t)){
        gfPop1.fHideCal();
        gfPop2.fHideCal();
        gfPop3.fHideCal();
      }
	  return routeEvent(e);
    }
    else if(n!="popcal"){
      gfPop1.fHideCal();
      gfPop2.fHideCal();
      gfPop3.fHideCal();
    }
  }
</script>
</form>

<%=writeJSButtons("transactionForm","saveButton")%>

<%
    if(sAction.equals("Save")){
        %>
            <script>
              window.opener.refreshContent();
              window.close();
            </script>
        <%
    }
%>

<%-- CALENDAR FRAMES --%>
<% String sDateType = MedwanQuery.getInstance().getConfigString("dateType","eu"); // eu/us %>

<iframe width=174 height=189 name="gToday:normal1_<%=sDateType%>:agenda.js:gfPop1" id="gToday:normal1_<%=sDateType%>:agenda.js:gfPop1"
  src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
  style="visibility:visible;z-index:999;position:absolute;top:-500px;left:-500px;">
</iframe>

<iframe width=174 height=189 name="gToday:normal2_<%=sDateType%>:agenda.js:gfPop2" id="gToday:normal2_<%=sDateType%>:agenda.js:gfPop2"
  src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
  style="visibility:visible;z-index:999;position:absolute;top:-500px;left:-500px;">
</iframe>

<iframe width=174 height=189 name="gToday:normal3_<%=sDateType%>:agenda.js:gfPop3" id="gToday:normal3_<%=sDateType%>:agenda.js:gfPop3"
  src="<c:url value='/_common/_script/ipopeng.htm'/>" scrolling="no" frameborder="0"
  style="visibility:visible;z-index:999;position:absolute;top:-500px;left:-500px;">
</iframe>