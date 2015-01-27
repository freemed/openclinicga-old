<%@ page import="be.openclinic.medical.Problem,java.util.Vector" %>
<%@ page errorPage="/includes/error.jsp" %>
<%@ include file="/includes/validateUser.jsp" %>
<%!
    public StringBuffer getActiveProblemsDisplay(AdminPerson activePatient, String sWebLanguage){
        StringBuffer sbProblemList = new StringBuffer();

        Vector activeProblems = Problem.getActiveProblems(activePatient.personid);
        if (activeProblems.size() > 0){
            sbProblemList.append("<table width='100%' cellspacing='0'>" +
                                  "<tr class='admin'>" +
                                   "<td>"+getTran("web.occup", "medwan.common.description", sWebLanguage)+"</td>" +
                                   "<td>"+getTran("web.occup", "medwan.common.datebegin", sWebLanguage)+"</td>" +
                                  "</tr>");
        }
        
        String sClass = "1";
        for (int n = 0; n < activeProblems.size(); n++){
            if(sClass.length()==0) sClass = "1";
            else                   sClass = "";

            Problem activeProblem = (Problem) activeProblems.elementAt(n);
            String comment = "";
            if (activeProblem.getComment().trim().length() > 0){
                comment = ":&nbsp;<i>"+activeProblem.getComment().trim()+"</i>";
            }
            sbProblemList.append("<tr class='list"+sClass+"'><td><b>"+(activeProblem.getCode() != null && activeProblem.getCode().length() > 0 ? (activeProblem.getCode()+" "+MedwanQuery.getInstance().getCodeTran(activeProblem.getCodeType()+"code"+activeProblem.getCode(), sWebLanguage)+"</b>") : "")+comment+"</td><td>"+ScreenHelper.stdDateFormat.format(activeProblem.getBegin())+"</td></tr>");
        }

        if (activeProblems.size() > 0){
            sbProblemList.append("</table>");
        }

        return sbProblemList;
    }
%>
<%
    String sFindProblemCode = checkString(request.getParameter("FindProblemCode"));
    String sFindProblemCodeLabel = checkString(request.getParameter("FindProblemCodeLabel"));
    String sFindProblemCodeType = checkString(request.getParameter("FindProblemCodeType"));
    String sFindProblemCertainty = checkString(request.getParameter("FindProblemCertainty"));
    String sFindProblemGravity = checkString(request.getParameter("FindProblemGravity"));
    String sFindProblemPatient = activePatient.personid;//checkString(request.getParameter(""));
    String sFindProblemBeginDate = checkString(request.getParameter("FindProblemBeginDate"));
    String sFindProblemEndDate = checkString(request.getParameter("FindProblemEndDate"));

    String sAction = checkString(request.getParameter("Action"));

    String sEditProblemCode = checkString(request.getParameter("EditProblemCode"));
    String sEditProblemCodeLabel = checkString(request.getParameter("EditProblemCodeLabel"));
    String sEditProblemCodeType = checkString(request.getParameter("EditProblemCodeType"));
    String sEditProblemCertainty = checkString(request.getParameter("EditProblemCertainty"));
    String sEditProblemGravity = checkString(request.getParameter("EditProblemGravity"));
    String sEditProblemComment = checkString(request.getParameter("EditProblemComment"));
    String sEditProblemPatient = checkString(request.getParameter("EditProblemPatient"));
    String sEditProblemBeginDate = checkString(request.getParameter("EditProblemBeginDate"));
    String sEditProblemEndDate = checkString(request.getParameter("EditProblemEndDate"));
    String sEditProblemUID = checkString(request.getParameter("EditProblemUID"));

    if (sAction.equals("SAVE")){
        Problem tmpProblem = new Problem();
        if (sEditProblemUID.length() > 0){
            tmpProblem = Problem.get(sEditProblemUID);
        } else {
            tmpProblem.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }

        tmpProblem.setCodeType(sEditProblemCodeType);
        tmpProblem.setCode(sEditProblemCode);
        if (sEditProblemCertainty.length() > 0){
            tmpProblem.setCertainty(Integer.parseInt(sEditProblemCertainty));
        }
        if (sEditProblemGravity.length() > 0){
            tmpProblem.setGravity(Integer.parseInt(sEditProblemGravity));
        }
        tmpProblem.setComment(sEditProblemComment);
        tmpProblem.setPatientuid(sEditProblemPatient);

        if (sEditProblemBeginDate.length() > 0){
            tmpProblem.setBegin(ScreenHelper.getSQLDate(sEditProblemBeginDate));
        }

        if (sEditProblemEndDate.length() > 0){
            tmpProblem.setEnd(ScreenHelper.getSQLDate(sEditProblemEndDate));
        } else {
            tmpProblem.setEnd(null);
        }

        tmpProblem.setPatientuid(activePatient.personid);
        tmpProblem.setUpdateUser(activeUser.userid);
        tmpProblem.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));

        tmpProblem.store();
        sEditProblemUID = tmpProblem.getUid();
    }

    if (sAction.equals("DELETE")){
        String sDeleteUID = checkString(request.getParameter("DeleteUID"));

        if (sDeleteUID.length() > 0){
            Problem tmpProblem = Problem.get(sDeleteUID);
            tmpProblem.delete();
        }
        sAction = "";
    }

    if (sEditProblemUID.length() > 0){
        Problem tmpProblem = Problem.get(sEditProblemUID);
        sEditProblemCode = checkString(tmpProblem.getCode());
        sEditProblemCodeType = checkString(tmpProblem.getCodeType());
        if (sEditProblemCode.length() > 0){
            sEditProblemCodeLabel = checkString(sEditProblemCode+" "+MedwanQuery.getInstance().getCodeTran(sEditProblemCodeType+"code"+sEditProblemCode, sWebLanguage));
        } else {
            sEditProblemCodeLabel = "";
        }

        sEditProblemComment = checkString(tmpProblem.getComment());
        sEditProblemCertainty = Integer.toString(tmpProblem.getCertainty());
        sEditProblemGravity = Integer.toString(tmpProblem.getGravity());
        sEditProblemPatient = tmpProblem.getPatientuid();
        if (tmpProblem.getBegin() != null){
            sEditProblemBeginDate = checkString(ScreenHelper.stdDateFormat.format(tmpProblem.getBegin()));
        } else {
            sEditProblemBeginDate = "";
        }
        if (tmpProblem.getEnd() != null){
            sEditProblemEndDate = checkString(ScreenHelper.stdDateFormat.format(tmpProblem.getEnd()));
        } else {
            sEditProblemEndDate = "";
        }
    }

    if (sAction.equals("SEARCH")){
%>
<form name="FindProblemForm" id="FindProblemForm" method="POST"
      action="popup.jsp?Page=medical/manageProblems.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("Web.manage", "manageProblems", sWebLanguage, "")%>
    <table class="list" width="100%" cellspacing="1"
           onKeyDown='if(enterEvent(event,13)){doFind();return false;}else{return true;}'>
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>">
                <%=getTran("medical.diagnosis", "period", sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=getTran("web", "from", sWebLanguage)%>&nbsp;
                <%
                    String sBeginDate = "";
                    if (sFindProblemBeginDate != null && sFindProblemBeginDate.length() > 0){
                        sBeginDate = ScreenHelper.stdDateFormat.format(ScreenHelper.getSQLDate(sFindProblemBeginDate));
                    }
                    out.print(writeDateField("FindProblemBeginDate", "FindProblemForm", sBeginDate, sWebLanguage));
                %>&nbsp;
                <%=getTran("web", "to", sWebLanguage)%>&nbsp;
                <%
                    String sEndDate = "";
                    if (sFindProblemEndDate != null && sFindProblemEndDate.length() > 0){
                        sEndDate = ScreenHelper.stdDateFormat.format(ScreenHelper.getSQLDate(sFindProblemEndDate));
                    }
                    out.print(writeDateField("FindProblemEndDate", "FindProblemForm", sEndDate, sWebLanguage));
                %>&nbsp;
            </td>
        </tr>
        <tr>
            <td class="admin2">
                <%=getTran("medical.diagnosis", "diagnosiscode", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input class="text" type="text" id="fLabel" name="FindProblemCodeLabel"
                       value="<%=sFindProblemCodeLabel%>" size="<%=sTextWidth%>">
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link"
                     alt="<%=getTranNoLink("Web","select",sWebLanguage)%>"
                     onclick="searchICPC('fCode','fLabel','fType');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link"
                     alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>"
                     onclick="FindProblemForm.FindProblemCode.value='';FindProblemForm.FindProblemCodeLabel.value='';FindProblemForm.FindProblemCodeType.value='';">
            </td>
            <input type="hidden" id="fCode" name="FindProblemCode" value="<%=sFindProblemCode%>">
            <input type="hidden" id="fType" name="FindProblemCodeType" value="<%=sFindProblemCodeType%>">
        </tr>
        <%-- certainty --%>
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis", "certainty", sWebLanguage)%> *</td>
            <td class="admin2">
                <select class="text" name="FindProblemCertainty">
                    <option/>
                    <%=ScreenHelper.writeSelect("medical.diagnosis.certainty", "", sWebLanguage, false, false)%>
                </select>
            </td>
        </tr>
        <%-- gravity --%>
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis", "gravity", sWebLanguage)%> *</td>
            <td class="admin2">
                <select class="text" name="FindProblemGravity">
                    <option/>
                    <%=ScreenHelper.writeSelect("medical.diagnosis.gravity", "", sWebLanguage, false, false)%>
                </select>
            </td>
        </tr>
        <%=ScreenHelper.setSearchFormButtonsStart()%>
        <input class="button" type="button" name="FindButton" value="<%=getTranNoLink("web","search",sWebLanguage)%>"
               onclick="doFind();">&nbsp;
        <input class="button" type="button" name="EmptyButton" value="<%=getTranNoLink("web","clear",sWebLanguage)%>"
               onclick="empty();">&nbsp;
        <input class="button" type="button" name="NewButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>"
               onclick="doNew();">&nbsp;
        <%=ScreenHelper.setSearchFormButtonsStop()%>
    </table>
    <input type="hidden" name="Action" value="">
    <script>
        FindProblemForm.FindProblemBeginDate.focus();
    </script>
</form>
<%
    }

    if (sAction.equals("SEARCH") || sAction.equals("")){
        StringBuffer sResultsActive = new StringBuffer();
        StringBuffer sResultsPassive = new StringBuffer();
        int iFoundActiveRecords = 0;
        int iFoundPassiveRecords = 0;

        try {
            String sSearchCode;
            if (sFindProblemCode.length() > 0){
                sSearchCode = sFindProblemCode;
            } else {
                sSearchCode = sFindProblemCodeLabel;
            }

            Vector vProblems = Problem.selectProblems("", "", sFindProblemCodeType, sSearchCode, "", sFindProblemPatient,
                    sFindProblemBeginDate, sFindProblemEndDate, sFindProblemCertainty, sFindProblemGravity, "OC_PROBLEM_BEGIN DESC");

            if (vProblems.size() == 0){
%>
<script>window.location.href = "<c:url value='/popup.jsp'/>?Page=medical/manageProblems.jsp&Action=NEW&ts=<%=getTs()%>&PopupWidth=700&PopupHeight=300";</script>
<%
        }

        Iterator iter = vProblems.iterator();

        Problem tmpProblem;

        String sBegin, sEnd, sClassActive = "", sClassPassive = "", sClass, sOutput = "";
        java.util.Date tmpDate;

        while (iter.hasNext()){
            tmpProblem = (Problem) iter.next();
            tmpDate = tmpProblem.getEnd();
            if (tmpProblem.getBegin() != null){
                sBegin = ScreenHelper.stdDateFormat.format(tmpProblem.getBegin());
            } else {
                sBegin = "";
            }

            if (tmpDate == null){
                sEnd = "";
                if (sClassActive.equals("")){
                    sClassActive = "1";
                } else {
                    sClassActive = "";
                }
                sClass = sClassActive;
            } else {
                sEnd = ScreenHelper.stdDateFormat.format(tmpProblem.getEnd());
                if (sClassPassive.equals("")){
                    sClassPassive = "1";
                } else {
                    sClassPassive = "";
                }
                sClass = sClassPassive;
            }
            if (activeUser.getAccessRight("occup.restricteddiagnosis.select") || !MedwanQuery.getInstance().isRestrictedDiagnosis(tmpProblem.getCodeType(), tmpProblem.getCode())){
                sOutput = "<tr class=\"list"+sClass+"\"" +
                        " onmouseover=\"this.style.cursor='hand';\"" +
                        " onmouseout=\"this.style.cursor='default';\">" +
                        "<td>&nbsp;<img src='http://"+request.getServerName()+":"+request.getServerPort()+request.getContextPath()+"/_img/icons/icon_delete.gif' alt='"+getTranNoLink("web", "delete", sWebLanguage)+"' border='0' onclick='doDelete(\""+tmpProblem.getUid()+"\");'>&nbsp;</td>" +

                        "<td onclick=\"doSelect('"+tmpProblem.getUid()+"');\"><b>"+checkString(tmpProblem.getCode())+"</b></td>" +
                        "<td onclick=\"doSelect('"+tmpProblem.getUid()+"');\"><b>"+(tmpProblem.getCode() != null && tmpProblem.getCode().length() > 0 ? MedwanQuery.getInstance().getCodeTran(tmpProblem.getCodeType()+"code"+tmpProblem.getCode(), sWebLanguage) : "")+(tmpProblem.getCode() != null && tmpProblem.getCode().length() > 0 & tmpProblem.getComment().trim().length() > 0 ? ": " : "")+(tmpProblem.getComment().trim().length() > 0 ? "</b><i>"+tmpProblem.getComment()+"</i>" : "</b>")+"</td>" +
                        "<td onclick=\"doSelect('"+tmpProblem.getUid()+"');\">"+sBegin+"</td>" +
                        "<td onclick=\"doSelect('"+tmpProblem.getUid()+"');\">"+sEnd+"</td>" +
                        "</tr>";
            } else {
                sOutput = "<tr valign='top'><td/><td style='{color: red}'><b><i>!!!</i></b></td><td style='{color: red}'><b><i>"+getTran("web", "diagnosis.restrictedaccess", sWebLanguage).toUpperCase()+"</i></td><td>"+sBegin+"</td><td>"+sEnd+"</td></tr>";
            }


            if (tmpDate == null || tmpDate.after(new java.util.Date())){
                sResultsActive.append(sOutput);
                iFoundActiveRecords++;
            } else {
                sResultsPassive.append(sOutput);
                iFoundPassiveRecords++;
            }
        }
    } catch (Exception e){
        e.printStackTrace();
    }

%>
<%=writeTableHeader("Web.manage", "manageProblems", sWebLanguage, "")%>
<table class="list" width="100%" cellspacing="0">
    <tr>
        <td class="titleadmin" colspan="5">&nbsp;<%=getTran("medical.problem","active",sWebLanguage)%></td>
    </tr>
    <tr class="admin">
        <td width="1%"/>
        <td width="10%"><%=getTran("web","code",sWebLanguage)%></td>
        <td width="59%"><%=getTran("web","comment",sWebLanguage)%></td>
        <td width="15%"><%=getTran("web","begindate",sWebLanguage)%></td>
        <td width="15%"><%=getTran("web","enddate",sWebLanguage)%></td>
    </tr>
    <%=sResultsActive%>
    <tr>
        <td>&nbsp;</td>
    </tr>
    <%
        if(iFoundActiveRecords > 0){
            out.print("<tr><td colspan='5'>&nbsp;"+iFoundActiveRecords+" "+getTran("web", "recordsfound", sWebLanguage)+"</td></tr>");
        } 
        else{
            out.print("<tr><td colspan='5'>&nbsp;"+getTran("web", "norecordsfound", sWebLanguage)+"</td></tr>");
        }
    %>
    <tr>
        <td>&nbsp;</td>
    </tr>
    <tr>
        <td class="titleadmin" colspan="5">&nbsp;<%=getTran("medical.problem", "passive", sWebLanguage)%>
        </td>
    </tr>
    <tr class="admin">
        <td width="1%"/>
        <td width="10%"><%=getTran("web", "code", sWebLanguage)%></td>
        <td width="59%"><%=getTran("web", "comment", sWebLanguage)%></td>
        <td width="15%"><%=getTran("web", "begindate", sWebLanguage)%></td>
        <td width="15%"><%=getTran("web", "enddate", sWebLanguage)%></td>
    </tr>
    <%=sResultsPassive%>
    <tr>
        <td>&nbsp;</td>
    </tr>
    <%
        if (iFoundPassiveRecords > 0){
            out.print("<tr><td colspan='5'>&nbsp;"+iFoundPassiveRecords+" "+getTran("web", "recordsfound", sWebLanguage)+"</td></tr>");
        } 
        else {
            out.print("<tr><td colspan='5'>&nbsp;"+getTran("web", "norecordsfound", sWebLanguage)+"</td></tr>");
        }
    %>
    <tr>
        <td>&nbsp;</td>
    </tr>
    <%
        if((iFoundActiveRecords+iFoundPassiveRecords) > 0){
            out.print("<tr><td colspan='5'>&nbsp;"+getTran("web.occup", "total", sWebLanguage)+": "+(iFoundActiveRecords+iFoundPassiveRecords)+" "+getTran("web", "recordsfound", sWebLanguage)+"</td></tr>");
        }
        else {
            out.print("<tr><td colspan='5'>&nbsp;"+getTran("web", "norecordsfound", sWebLanguage)+"</td></tr>");
        }
    %>
</table>

<%=ScreenHelper.alignButtonsStart()%>
	<input class="button" type="button" name="NewButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">&nbsp;
	<input class="button" type="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="doClose();">
<%=ScreenHelper.alignButtonsStop()%>
<%
    }

    if (sAction.equals("NEW") || sAction.equals("SELECT") || sAction.equals("SAVE")){
%>
<form name="EditProblemForm" id="EditProblemForm" method="POST" action="popup.jsp?Page=medical/manageProblems.jsp&ts=<%=getTs()%>">
    <input type="hidden" name="EditProblemUID" value="<%=sEditProblemUID%>">
    
    <%=writeTableHeader("Web.manage","manageProblems",sWebLanguage," doSearchBack();")%>
    
    <table class="list" width="100%" cellspacing="1">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","begin",sWebLanguage)%> *</td>
            <td class="admin2">
                <%
                    String sBeginDate;
                    if(sEditProblemBeginDate!=null && sEditProblemBeginDate.length() > 0){
                        sBeginDate = ScreenHelper.formatDate(ScreenHelper.getSQLDate(sEditProblemBeginDate));
                    }
                    else{
                        sBeginDate = ScreenHelper.formatDate(ScreenHelper.getSQLDate(getDate()));
                    }
                    out.print(writeDateField("EditProblemBeginDate","EditProblemForm",sBeginDate,sWebLanguage));
                %>
            </td>
        </tr>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","end",sWebLanguage)%></td>
            <td class="admin2">
                <%
                    String sEndDate = "";
                    if(sEditProblemEndDate != null && sEditProblemEndDate.length() > 0){
                        sEndDate = ScreenHelper.stdDateFormat.format(ScreenHelper.getSQLDate(sEditProblemEndDate));
                    }

                    out.print(writeDateField("EditProblemEndDate","EditProblemForm",sEndDate,sWebLanguage));
                %>
            </td>
        </tr>
        <%-- code --%>
        <tr>
            <td class="admin"><%=getTran("medical.problems","problem",sWebLanguage)%> *</td>
            <td class="admin2">
                <input class="text" type="text" id="eLabel" name="EditProblemCodeLabel" value="<%=sEditProblemCodeLabel%>" readonly size="<%=sTextWidth%>">
              
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchICPC('eCode','eLabel','eType');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditProblemForm.EditProblemCode.value='';EditProblemForm.EditProblemCodeLabel.value='';EditProblemForm.EditProblemCodeType.value='';">
            </td>
            
            <input type="hidden" id="eCode" name="EditProblemCode" value="<%=sEditProblemCode%>">
            <input type="hidden" id="eType" name="EditProblemCodeType" value="<%=sEditProblemCodeType%>">
        </tr>
        <%-- certainty --%>
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","certainty",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="EditProblemCertainty">
                    <option/>
                    <%=ScreenHelper.writeSelect("medical.diagnosis.certainty", sEditProblemCertainty, sWebLanguage, false, false)%>
                </select>
            </td>
        </tr>
        <%-- gravity --%>
        <tr>
            <td class="admin"><%=getTran("medical.diagnosis","gravity",sWebLanguage)%></td>
            <td class="admin2">
                <select class="text" name="EditProblemGravity">
                    <option/>
                    <%=ScreenHelper.writeSelect("medical.diagnosis.gravity",sEditProblemGravity,sWebLanguage,false,false)%>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","comment",sWebLanguage)%></td>
            <td class="admin2">
                <%=writeTextarea("EditProblemComment","","","",sEditProblemComment)%>
            </td>
        </tr>
        
        <%=ScreenHelper.setFormButtonsStart()%>
            <input class="button" type="button" name="EditSaveButton" value="<%=getTranNoLink("web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;
            <input class="button" type="button" name="BackButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick="doSearchBack();">&nbsp;
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    
    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
    <input type="hidden" name="Action" value="">
</form>

<%=ScreenHelper.alignButtonsStart()%>
    <input class="button" type="button" name="closeButton" value="<%=getTranNoLink("web","close",sWebLanguage)%>" onclick="doClose();">
<%=ScreenHelper.alignButtonsStop()%>
<%
    }
    if (sAction.equals("SAVE")){
		%>
		<script>
		  window.location.href = '<c:url value="/"/>popup.jsp?Page=medical/manageProblems.jsp&ts=<%=getTs()%>&PopupWidth=700&PopupHeight=500';
		</script>
		<%
    }
%>
<script>
  window.resizeTo(700, 480);
    
  function doFind(){
    if(FindProblemForm.FindProblemBeginDate.value == ""
        && FindProblemForm.FindProblemEndDate.value == ""
        && FindProblemForm.FindProblemCode.value == ""
        && FindProblemForm.FindProblemCodeLabel.value == ""
        && FindProblemForm.FindProblemCodeType.value == ""
        && FindProblemForm.FindProblemCertainty.value == ""
        && FindProblemForm.FindProblemGravity.value == ""){
                  alertDialog("web.manage","dataMissing");
    }
    else {
      FindProblemForm.FindButton.disabled = true;
      FindProblemForm.Action.value = "SEARCH";
      FindProblemForm.submit();
    }
  }

  function doNew(){
    window.location.href = "<c:url value='/popup.jsp'/>?Page=medical/manageProblems.jsp&Action=NEW&ts=<%=getTs()%>&PopupWidth=700&PopupHeight=300";
  }

  function doBack(){
    window.location.href = "<c:url value='/popup.jsp'/>?Page=curative/index.jsp&ts=<%=getTs()%>";
  }

  function doClose(){
    var URL = unescape(window.opener.location);
    window.opener.location.href = URL;
    window.close();
  }

  function doSearchBack(){
    window.location.href = "<c:url value='/popup.jsp'/>?Page=medical/manageProblems.jsp&ts=<%=getTs()%>";
  }

  function empty(){
    FindProblemForm.FindProblemBeginDate.value = "";
    FindProblemForm.FindProblemEndDate.value = "";
    FindProblemForm.FindProblemCode.value = "";
    FindProblemForm.FindProblemCodeLabel.value = "";
    FindProblemForm.FindProblemCodeType.value = "";
    FindProblemForm.FindProblemCertainty.value = "";
    FindProblemForm.FindProblemGravity.value = "";
  }

  function searchICPC(code, codelabel, codeType){
    openPopup("/_common/search/searchICPC.jsp&ts=<%=getTs()%>&returnField="+code+"&returnField2="+codelabel+"&returnField3="+codeType+"&ListChoice=TRUE&ListMode=ALL", 700, 300);
  }

  function isNumber(val){
    if(isNaN(val)){
      return false;
    } 
    else{
      return true;
    }
  }

  function doSave(){
    if(EditProblemForm.EditProblemBeginDate.value == ""){
  	  alertDialog("medical","no_date");
    }
    else if (EditProblemForm.EditProblemCode.value == "" && EditProblemForm.EditProblemComment.value == ""){
      alertDialog("medical","no_code");      
    }
    else{
      EditProblemForm.EditSaveButton.disabled = true;
      EditProblemForm.Action.value = "SAVE";
      EditProblemForm.submit();
    }
  }

  function doSelect(problem){
    window.location = "<c:url value='/popup.jsp'/>?Page=medical/manageProblems.jsp&Action=SELECT&EditProblemUID="+problem+"&ts=<%=getTs()%>";
  }

  function doDelete(problem){
      if(yesnoDeleteDialog()){
      window.location = "<c:url value='/popup.jsp'/>?Page=medical/manageProblems.jsp&Action=DELETE&DeleteUID="+problem+"&ts=<%=getTs()%>";
    }
  }
</script>