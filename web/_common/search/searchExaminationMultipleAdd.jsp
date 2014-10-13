<%@page import="be.openclinic.system.Examination,java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sAction = checkString(request.getParameter("Action"));

    // display options
    boolean displayAllExaminations = false; // show user examinations by default
    String sDisplayAllExaminations = checkString(request.getParameter("displayAllExaminations"));

    if(sDisplayAllExaminations.length() > 0){
        displayAllExaminations = sDisplayAllExaminations.equalsIgnoreCase("true");
    }

    if(sAction.length()==0){
        if(displayAllExaminations){
            sAction = "showAllExaminations";
        }
        else{
            sAction = "showUserExaminations";
        }
    }
%>
<form name="SearchForm" method="POST">
    <input type="hidden" name="Action">

    <table cellpadding="0" cellspacing="0">
        <%-- title --%>
        <tr class="admin">
            <td colspan="2"><%=getTran("web.manage","examinations",sWebLanguage)%></td>
        </tr>

        <tr>
            <td class="white" width="100%" colspan="2">
                <div class="search" style="width:440px;" id="examinationsList">
                    <table width="100%" cellpadding="1" cellspacing="0">
                        <%
                            String sVarUserID = checkString(request.getParameter("VarUserID"));
                            StringBuffer examsHtml = new StringBuffer("");
                            Hashtable hExaminations = new Hashtable();
                            Hashtable hResults;
                            String examId;

                            // all examinations
                            if (sAction.equalsIgnoreCase("showAllExaminations")) {
                                Vector vResults = Examination.searchAllExaminations();
                                Iterator iter = vResults.iterator();

                                while (iter.hasNext()) {
                                    hResults = (Hashtable) iter.next();
                                    hExaminations.put(getTran("examination", (String) hResults.get("id"), sWebLanguage), hResults.get("id"));
                                }
                            }
                            // user specific examinations
                            else if (sAction.equalsIgnoreCase("showUserExaminations")) {
                                Parameter parameter;
                                String sValue;

                                if (sVarUserID.length() > 0) {
                                    activeUser.initialize(Integer.parseInt(sVarUserID));
                                }

                                for (int i = 0; i < activeUser.parameters.size(); i++) {
                                    parameter = (Parameter) activeUser.parameters.elementAt(i);

                                    if (parameter.parameter.toLowerCase().startsWith("showexamination_")) {
                                        examId = parameter.parameter.substring(16);
                                        sValue = Examination.searchExamination(Integer.parseInt(examId));

                                        if (sValue.length() > 0) {
                                            hExaminations.put(getTran("examination", examId, sWebLanguage), examId);
                                        }
                                    }
                                }
                            }

                            // determine exams that are allready selected
                            Vector selectedExams = new Vector();
                            String selectedExamIds = checkString(request.getParameter("selectedExamIds"));
                            if (selectedExamIds.length() > 0) {
                                StringTokenizer tokenizer = new StringTokenizer(selectedExamIds, ",");
                                while (tokenizer.hasMoreTokens()) {
                                    examId = tokenizer.nextToken();
                                    selectedExams.add(examId);
                                }
                            }

                            // sort examinations
                            Vector examNames = new Vector(hExaminations.keySet());
                            Collections.sort(examNames);

                            // run thru examinations, leaving out the examinations that are indicated as selected
                            Iterator namesIter = examNames.iterator();
                            String sClass = "1", examName, examNameNoLink, excludedExamId;
                            String sSelectTran = getTran("web", "select", sWebLanguage);
                            int displayedExamCounter = 0;
                            boolean displayExam;
                            while (namesIter.hasNext()) {
                                displayExam = true;
                                examName = (String) namesIter.next();
                                examId = (String) hExaminations.get(examName);

                                // yet selected ?
                                for (int i = 0; i < selectedExams.size(); i++) {
                                    excludedExamId = (String) selectedExams.get(i);
                                    if (examId.equalsIgnoreCase(excludedExamId)) {
                                        displayExam = false;
                                        break;
                                    }
                                }

                                if (displayExam) {
                                    displayedExamCounter++;
                                    examName = getTran("examination", examId, sWebLanguage);
                                    examNameNoLink = getTranNoLink("examination", examId, sWebLanguage);

                                    // alternate row-style
                                    if (sClass.equals("")) sClass = "1";
                                    else                   sClass = "";

                                    examsHtml.append("<tr class='list" + sClass + "' title='" + sSelectTran + "'>")
                                             .append("<td width='20'><input type='checkbox' name='examId_" + examId + "'></td>");

                                    // link to manageTranslations when no label found
                                    if (examName.indexOf("<a") > -1) {
                                        examsHtml.append("<td>" + examName + "</td>");
                                    }
                                    else {
                                        examsHtml.append("<td onClick=\"toggleExamCheck('examId_" + examId + "');\">" + examName + "</td>");
                                    }

                                    examsHtml.append("</tr>")
                                             .append("<input type='hidden' id='examName_" + examId + "' value=\"" + examNameNoLink + "\">");
                                }
                            }

                            if (displayedExamCounter > 0) {
                                %>
                                    <tbody class="hand">
                                        <%=examsHtml%>
                                    </tbody>
                                <%
                            }
                            else{
                                // display 'no results' message
                                %>
                                    <tr>
                                        <td><%=getTran("web","noexaminationsfoundorallselected",sWebLanguage)%></td>
                                    </tr>
                                <%
                            }
                        %>
                    </table>
                              
                    <%
                        if(displayedExamCounter > 0){
                            %>
                                <%-- LINK TO TOP OF DIV --%>
                                <table width="100%" cellspacing="1">
                                    <tr>
                                        <%
                                            if(displayedExamCounter > 17){
                                                %>
                                                    <td align="right">
                                                        <a href="#" class="topbutton" onClick="examinationsList.scrollTop=0;">&nbsp;</a>
                                                    </td>
                                                <%
                                            }
                                        %>
                                    </tr>
                                </table>
                            <%
                        }
                    %>
                </div>
            </td>
        </tr>

        <tr>
            <%-- UN/CHECK ALL --%>
            <td>
                <a href="javascript:checkAll(true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
                <a href="javascript:checkAll(false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a>
            </td>

            <%
                // show all examinations or just examinations of user
                if(sAction.equalsIgnoreCase("showAllExaminations")){
                    %><td align="right"><a href="javascript:showUserExaminations()"><%=getTran("web.manage","showonlyuserexaminations",sWebLanguage)%></a></td><%
                }
                else{
                    %><td align="right"><a href="javascript:showAllExaminations()"><%=getTran("web.manage","showallexaminations",sWebLanguage)%></a></td><%
                }
            %>
        </tr>
    </table>

    <br>

    <%-- BUTTONS --%>
    <center>
        <input type="button" class="button" name="addButton" value="<%=getTranNoLink("Web","add",sWebLanguage)%>" onclick="addSelectedExaminations();">
        <input type="button" class="button" name="closeButton" value="<%=getTranNoLink("Web","Close",sWebLanguage)%>" onclick="window.close();">
    </center>
</form>

<script>
  window.resizeTo(450,500);

  <%-- CHECK ALL --%>
  function checkAll(setchecked){
    for(var i=0; i<SearchForm.elements.length; i++){
      if(SearchForm.elements[i].type=="checkbox"){
        SearchForm.elements[i].checked = setchecked;
      }
    }
  }
          
  <%-- TOGGLE EXAM CHECK --%>
  function toggleExamCheck(checkBoxName){
    document.getElementsByName(checkBoxName)[0].checked = !document.getElementsByName(checkBoxName)[0].checked;
  }

  <%-- ADD SELECTED EXAMINATIONS --%>
  function addSelectedExaminations(){
    if(atLeastOneExamSelected()){
      var examId, examName;

      for(var i=0; i<SearchForm.elements.length; i++){
        if(SearchForm.elements[i].type=="checkbox"){
          var idx = SearchForm.elements[i].name.indexOf("examId_");
          if(idx > -1){
            if(SearchForm.elements[i].checked){
              examId = SearchForm.elements[i].name.substring(idx+7);
              examName = document.getElementById("examName_"+examId).value;
              window.opener.addExamination(examId,examName);
            }
          }
        }
      }

      if(window.opener.sortExaminations) window.opener.sortExaminations();
      window.close();
    }
    else{
      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=selectatleastoneexamination";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","selectatleastoneexamination",sWebLanguage)%>");
    }
  }

  <%-- AT LEAST ONE EXAMINATION SELECTED --%>
  function atLeastOneExamSelected(){
    for(var i=0; i<SearchForm.elements.length; i++){
      if(SearchForm.elements[i].type=="checkbox"){
        if(SearchForm.elements[i].name.indexOf("examId_") > -1){
          if(SearchForm.elements[i].checked) return true;
        }
      }
    }
    return false;
  }

  <%-- show all examinations --%>
  function showAllExaminations(){
    SearchForm.Action.value = "showAllExaminations";
    SearchForm.submit();
  }

  <%-- show only user examinations --%>
  function showUserExaminations(){
    SearchForm.Action.value = "showUserExaminations";
    SearchForm.submit();
  }
</script>
