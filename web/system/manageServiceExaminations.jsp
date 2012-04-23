<%@page import="be.openclinic.system.ServiceExamination,java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/SingletonContainer.jsp"%>
<%=checkPermission("system.manageserviceexaminations","all",activeUser)%>
<%=sJSSORTTABLE%>
<%!
    //--- ADD EXAMINATION -------------------------------------------------------------------------
    private String addExamination(int iTotal, String examName, String sWebLanguage){
        StringBuffer buf = new StringBuffer();
        buf.append("<tr id='rowExam"+iTotal+"' class='"+(iTotal%2==0?"list":"")+"'>")
           .append(" <td>")
           .append("  <a href='#' onclick=\"deleteExamination(rowExam"+iTotal+");\">")
           .append("   <img src='"+sCONTEXTPATH+"/_img/icon_delete.gif' alt='").append(getTran("Web","delete",sWebLanguage)).append("' border='0'>")
           .append("  </a>")
           .append(" </td>")
           .append(" <td>"+examName+"</td>")
           .append("</tr>");

        return buf.toString();
    }
%>
<%
    String sAction          = checkString(request.getParameter("Action")),
           sFindServiceCode = checkString(request.getParameter("FindServiceCode")),
           sFindServiceText = checkString(request.getParameter("FindServiceText"));

    // DEBUG //////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n### mngServiceExaminations ###");
        Debug.println("# sAction          : "+sAction);
        Debug.println("# sFindServiceCode : "+sFindServiceCode);
        Debug.println("# sFindServiceText : "+sFindServiceText+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    // declarations
    String msg = "", sExamsJS = "";
    int examCount = 0;

    //--- SAVE ------------------------------------------------------------------------------------
    // delete all examinations for the specified service,
    // then add all selected examinations (those in request)
    if (sAction.equals("save")) {
        ServiceExamination.deleteAllExaminationsForService(sFindServiceCode);

        String examId;
        String examsToSave = checkString(request.getParameter("selectedExamIds"));
        StringTokenizer tokenizer = new StringTokenizer(examsToSave, ",");
        ServiceExamination exam;
        while (tokenizer.hasMoreTokens()) {
            examId = tokenizer.nextToken();

            exam = new ServiceExamination();
            exam.setServiceid(sFindServiceCode);
            exam.setExaminationid(examId);

            exam.saveToDB();
        }
        MedwanQuery.getInstance().removeServiceExaminations(sFindServiceCode);

        //sAction = "edit";
    }
%>
<script>
  var examsArray = new Array();
  var examIds = new Array();
</script>
<form id="transactionForm" name="transactionForm" method="post">
    <input type="hidden" name="Action">
    <%=writeTableHeader("Web.manage","ManageServiceExaminations",sWebLanguage," doBackToMenu();")%>
    <%-- SEARCH SERVICE --%>
    <table width="100%" class="menu" cellspacing="0">
        <tr height="22">
            <td width="<%=sTDAdminWidth%>">&nbsp;<%=getTran("Web","Unit",sWebLanguage)%></td>
            <td>
                <input class="text" type="text" name="FindServiceText" READONLY size="<%=sTextWidth%>" title="<%=sFindServiceText%>" value="<%=sFindServiceText%>">
                <%=ScreenHelper.writeServiceButton("buttonService","FindServiceCode","FindServiceText",sWebLanguage,sCONTEXTPATH)%>
                <input type="hidden" name="FindServiceCode" value="<%=sFindServiceCode%>">&nbsp;

                <%-- BUTTONS --%>
                <input type="button" class="button" name="editButton" value="<%=getTran("Web","Edit",sWebLanguage)%>" onclick="doEdit(transactionForm.FindServiceCode.value);">
                <input type="button" class="button" name="backButton" value="<%=getTran("Web","Back",sWebLanguage)%>" OnClick="doBackToMenu();">
            </td>
        </tr>
    </table>

    <%
        //--- EDIT FIELDS -------------------------------------------------------------------------
        if (sAction.equals("edit") && sFindServiceCode.length() > 0) {
            ServiceExamination serviceExam;
            Vector serviceExams = ServiceExamination.selectServiceExaminations(sFindServiceCode);
            Iterator iter = serviceExams.iterator();

            String examId, examName;
            StringBuffer examsHtml = new StringBuffer();
            Hashtable exams = new Hashtable();

            while (iter.hasNext()) {
                serviceExam = (ServiceExamination) iter.next();

                examId = serviceExam.getExaminationid();
                examName = getTran("examination", examId, sWebLanguage);

                exams.put(examName, examId);
            }

            // sort examinations
            Vector examNames = new Vector(exams.keySet());
            Collections.sort(examNames);

            // display examinations
            for (int i = 0; i < examNames.size(); i++) {
                examName = (String) examNames.get(i);
                examId = (String) exams.get(examName);

                sExamsJS += "rowExam" + examCount + "=" + examId + "£" + examName + "$";
                examsHtml.append(addExamination(examCount, examName, sWebLanguage));
                examCount++;
            }

            %>
                <br>

                <%-- selected examinations for current service --%>
                <table id="tblExams" width="100%" cellspacing="0" class="sortable">
                    <%-- header --%>
                    <tr class="admin">
                        <td width="20"></td>
                        <td><%=getTran("Web.manage","selectedexaminations",sWebLanguage)%></td>
                    </tr>

                    <%=examsHtml%>
                </table>

                <%-- number of records found --%>
                <span id="recordsFoundMsg" style="width:49%;text-align:left;vertical-align:top;">
                    <%
                        if(examCount > 0){
                            %><%=examCount%> <%=getTran("web.manage","examinationsfound",sWebLanguage)%><%
                        }
                        else{
                            %><%=getTran("web.manage","noexaminationsfound",sWebLanguage)%><%
                        }
                    %>
                </span>

                <%
                    if(examCount > 20){
                        // link to top of page
                        %>
                            <span style="width:51%;text-align:right;padding-top:2px;">
                                <a href="#topp" class="topbutton">&nbsp;</a>
                            </span>
                        <%
                    }
                %>

                <%-- delete all examinations --%>
                <a href="#" onClick="deleteAllExaminations();"><%=getTran("web","deleteAllExaminations",sWebLanguage)%></a>

                <br>

                <%
                    // display message
                    if(msg.length() > 0){
                        %><%=msg%><br><%
                    }
                %>

                <%-- BUTTONS --%>
                <%=ScreenHelper.alignButtonsStart()%>
                    <input class="button" type="button" name="selectButton" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="selectExaminations();">&nbsp;

                    <button accesskey="<%=ScreenHelper.getAccessKey(getTranNoLink("accesskey","save",sWebLanguage))%>" class="buttoninvisible" onclick="doSave();"></button>
                    <input type="button" class="button" name="saveButton" onclick="doSave();" value="<%=getTran("accesskey","save",sWebLanguage)%>"/>

                    <input class="button" type="button" name="backButton" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBackToMenu();">
                <%=ScreenHelper.alignButtonsStop()%>
            <%
        }
    %>

    <%-- hidden fields --%>
    <input type="hidden" name="selectedExamIds" value="">
</form>

<script>
  <%-- popup : SELECT EXAMINATIONS --%>
  function selectExaminations(){
    openPopup("/_common/search/searchExaminationMultipleAdd.jsp&ts=<%=getTs()%>&displayAllExaminations=true&selectedExamIds="+transactionForm.selectedExamIds.value,200,600);
  }

  <%-- DO EDIT SERVICE --%>
  function doEdit(serviceCode){
    if(serviceCode.length > 0){
      transactionForm.Action.value = "edit";
      transactionForm.submit();
    }
  }

  <%-- BACK TO MENU --%>
  function doBackToMenu(){
    window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
  }

  var iIndexExams = <%=examCount%>;
  var sExams = "<%=sExamsJS%>";

  <%-- ADD EXAMINATION --%>
  function addExamination(examId,examName){
    if(!allreadySelected(examId)){
      sExams+= "rowExam"+iIndexExams+"="+examId+"£"+examName+"$";
      var row = tblExams.insertRow(tblExams.rows.length);
      row.id = "rowExam"+iIndexExams;

      if(tblExams.rows.length%2==0) row.className = "list";
      else                          row.className = "";

      row.style.height = "20px";

      <%-- insert cells in row --%>
      for(var i=0; i<2; i++){
        row.insertCell(i);
      }

      row.cells[0].innerHTML = "<a href=\"#\" onclick=\"deleteExamination(rowExam"+iIndexExams+");\"><img src='<%=sCONTEXTPATH%>/_img/icon_delete.gif' alt='<%=getTran("Web","delete",sWebLanguage)%>' border='0'></a>";
      row.cells[1].innerHTML = examName;

      iIndexExams++;
      examsArray[examsArray.length] = new Array(examId,examName);
      examIds.push(examId);
      transactionForm.selectedExamIds.value = examIds.join(",");

      if(document.getElementById("recordsFoundMsg")!=undefined){
        recordsFoundMsg.innerHTML = examIds.length+" <%=getTran("web.manage","examinationsfound",sWebLanguage)%>";
      }
    }
  }

  <%-- SORT EXAMINATIONS --%>
  function sortExaminations(){
    var sortLink = document.getElementById("lnk0");
    if(sortLink!=null){
      ts_resortTable(sortLink,1,false);
    }
  }

  <%-- DELETE EXAMINATION --%>
  function deleteExamination(rowid){
    var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
    var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
    var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");

    if(answer==1){
      sExams = deleteRowFromArrayString(sExams,rowid.id);
      initExamsArray(sExams);
      tblExams.deleteRow(rowid.rowIndex);
      updateRowStyles();
    }

    recordsFoundMsg.innerHTML = (tblExams.rows.length-1)+" <%=getTran("web.manage","examinationsfound",sWebLanguage)%>";
  }

  <%-- INIT EXAMS ARRAY --%>
  function initExamsArray(sArray){
    examsArray = new Array();
    examIds = new Array();
    transactionForm.selectedExamIds.value = "";

    if(sArray != ""){
      var sOneExam;
      for(var i=0; i<iIndexExams; i++){
        sOneExam = getRowFromArrayString(sExams,"rowExam"+i);
        if(sOneExam != ""){
          var oneExam = sOneExam.split("£");
          examsArray.push(oneExam);
          examIds.push(oneExam[0]);
        }
      }

      transactionForm.selectedExamIds.value = examIds.join(",");
    }
  }

  <%-- ALLREADY SELECTED --%>
  function allreadySelected(examId){
    for(var i=0; i<examsArray.length; i++){
      if(examsArray[i][0] == examId){
        return true;
      }
    }
    return false;
  }

  <%-- GET ROW FROM ARRAY STRING --%>
  function getRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    var row = "";
    for(var i=0;i<array.length;i++){
      if(array[i].indexOf(rowid)>-1){
        row = array[i].substring(array[i].indexOf("=")+1);
        break;
      }
    }
    return row;
  }

  <%-- DELETE ROW FROM ARRAY STRING --%>
  function deleteRowFromArrayString(sArray,rowid){
    var array = sArray.split("$");
    for(var i=0; i<array.length; i++){
      if(array[i].indexOf(rowid) > -1){
        array.splice(i,1);
      }
    }
    return array.join("$");
  }

  <%-- DELETE ALL EXAMINATIONS --%>
  function deleteAllExaminations(){
    if(tblExams.rows.length > 1){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/yesnoPopup.jsp?ts=<%=getTs()%>&labelType=web&labelID=areyousuretodelete";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web","areyousuretodelete",sWebLanguage)%>");

      if(answer==1){
        deleteAllExaminationsNoConfirm();
      }
    }
  }

  <%-- DELETE ALL EXAMINATIONS --%>
  function deleteAllExaminationsNoConfirm(){
    if(tblExams.rows.length > 1){
      var len = tblExams.rows.length;
      for(var i=len-1; i!=0; i--){
        tblExams.deleteRow(i);
      }

      sExams = "";
      initExamsArray("");
      recordsFoundMsg.innerHTML = (tblExams.rows.length-1)+" <%=getTran("web.manage","examinationsfound",sWebLanguage)%>";
    }
  }

  <%-- DO SAVE --%>
  function doSave(){
    <%-- remove row id --%>
    while(sExams.indexOf("rowExam") > -1){
      var sTmpBegin = sExams.substring(sExams.indexOf("rowExam"));
      var sTmpEnd = sTmpBegin.substring(sTmpBegin.indexOf("=")+1);
      sExams = sExams.substring(0,sExams.indexOf("rowExam"))+sTmpEnd;
    }

    transactionForm.saveButton.disabled = true;
    transactionForm.Action.value = "save";
    document.getElementById("transactionForm").submit();
  }

  <%-- UPDATE ROW STYLES (after sorting) --%>
  function updateRowStyles(){
    for(var i=1; i<tblExams.rows.length; i++){
      if(i%2>0) tblExams.rows[i].className = "list";
      else      tblExams.rows[i].className = "";
    }
  }

  initExamsArray(sExams);
</script>