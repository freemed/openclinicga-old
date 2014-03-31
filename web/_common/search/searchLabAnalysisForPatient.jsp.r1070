<%@ page import="be.openclinic.medical.LabAnalysis,be.openclinic.medical.LabProfile" %>
<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
    //--- WRITE ROW -------------------------------------------------------------------------------
    private String writeRow(String sType, String sCode, String sLabel, String sCodeOther, String sComment,int unavailable, int iTotal,String language){
        StringBuffer out = new StringBuffer();

        out.append("<tr class='"+(iTotal%2==0?"list":"list1")+"'>")
           .append(" <td><input type='checkbox' name='cb_"+iTotal+"'></td>")
           .append(" <td"+(unavailable==1?" class='strike'":"")+">"+sCode+"</td><td"+(unavailable==1?" class='strike'":"")+">"+sType+"</td><td"+(unavailable==1?" class='strike'":"")+">"+sLabel+"</td>");

            if(unavailable==1){
                out.append("<td>"+MedwanQuery.getInstance().getLabel("web.manage","labanalysis.cols.unavailable",language)+"</td>");
            }
            else if(sCodeOther.equals("1")){
                out.append("<td><input type='text' id='comment"+iTotal+"' class='text' value='"+sComment+"' size='32'></td>");
            }
            else{
                out.append("<td>&nbsp;</td>");
            }

        out.append("</tr>");

        return out.toString();
    }
%>
<%
    String sVarID = checkString(request.getParameter("VarID")),
            sVarCode = checkString(request.getParameter("VarCode")),
            sVarType = checkString(request.getParameter("VarType")),
            sVarText = checkString(request.getParameter("VarText"));

    String sSelectedLabCodes = checkString(request.getParameter("selectedLabCodes")).replaceAll(",", "','"),
            sSearchCode = checkString(request.getParameter("FindCode")),
            sSearchProfileID = checkString(request.getParameter("FindProfileID")),
            sSortCol = checkString(request.getParameter("sortCol"));

    if (sSortCol.length() == 0) sSortCol = "code";


    String sLabID, sLabType, sLabCode, sLabLabel, sCodeOther, sComment, sMonster;
    StringBuffer sOut = new StringBuffer(),
            sScript = new StringBuffer();
    boolean showMsg = false;
    int iTotal = 0;

    //--- search on LABCODE -----------------------------------------------------------------------
    if (sSearchCode.length() > 0 || sSearchProfileID.length() == 0) {
        Vector hLabAnalysis = LabAnalysis.searchByLabCodeForPatient(sSearchProfileID, sSelectedLabCodes, sSearchCode, sSortCol, sWebLanguage);
        LabAnalysis objLabAnalysis;

        for (int n=0;n<hLabAnalysis.size();n++) {
            objLabAnalysis = (LabAnalysis) hLabAnalysis.elementAt(n);

            iTotal++;

            sLabID = Integer.toString(objLabAnalysis.getLabId());
            sLabType = objLabAnalysis.getLabtype();
            sLabCode = objLabAnalysis.getLabcode();
            sLabLabel = getTran("labanalysis",objLabAnalysis.getLabId()+"",sWebLanguage);
            sCodeOther = objLabAnalysis.getLabcodeother();
            sComment = objLabAnalysis.getComment();
            sMonster = getTranNoLink("labanalysis.monster",objLabAnalysis.getMonster(),sWebLanguage);

            // translate labtype
            if (sLabType.equals("1")) sLabType = getTran("Web.occup", "labanalysis.type.blood", sWebLanguage);
            else if (sLabType.equals("2")) sLabType = getTran("Web.occup", "labanalysis.type.urine", sWebLanguage);
            else if (sLabType.equals("3")) sLabType = getTran("Web.occup", "labanalysis.type.other", sWebLanguage);
            else if (sLabType.equals("4")) sLabType = getTran("Web.occup", "labanalysis.type.stool", sWebLanguage);
            else if (sLabType.equals("5")) sLabType = getTran("Web.occup", "labanalysis.type.sputum", sWebLanguage);
            else if (sLabType.equals("6")) sLabType = getTran("Web.occup", "labanalysis.type.smear", sWebLanguage);
            else if (sLabType.equals("7")) sLabType = getTran("Web.occup", "labanalysis.type.liquid", sWebLanguage);

            sOut.append(writeRow(sLabType, sLabCode, sLabLabel, sCodeOther, sComment,objLabAnalysis.getUnavailable(), iTotal,sWebLanguage));
            sScript.append("<script>addLabAnalysisToArray(")
                    .append("'").append(sLabID).append("',")
                    .append("'").append(sLabCode).append("',")
                    .append("'").append(sLabType).append("',")
                    .append("'").append(sLabLabel.replaceAll("\'","´")).append("',")
                    .append("'").append(sCodeOther.replaceAll("\'","´")).append("',")
                    .append("'").append(sMonster.replaceAll("\'","´")).append("');</script>");
        }

        showMsg = true;
    }
    //--- search on PROFILE -----------------------------------------------------------------------
    else if (sSearchProfileID.length() > 0) {
        Vector hLabAnalysis = LabAnalysis.searchByProfileIdForPatient(sSearchProfileID, sSelectedLabCodes, sSortCol, sWebLanguage);
        Iterator e = hLabAnalysis.iterator();

        String sKey;
        LabAnalysis objLabAnalysis;

        while (e.hasNext()) {
            objLabAnalysis = (LabAnalysis) e.next();

            iTotal++;

            sLabID = Integer.toString(objLabAnalysis.getLabId());
            sLabType = objLabAnalysis.getLabtype();
            sLabCode = objLabAnalysis.getLabcode();
            sLabLabel = getTran("labanalysis",objLabAnalysis.getLabId()+"",sWebLanguage);
            sCodeOther = objLabAnalysis.getLabcodeother();
            sComment = objLabAnalysis.getComment();
            sMonster = getTranNoLink("labanalysis.monster",objLabAnalysis.getMonster(),sWebLanguage);

            // translate labtype
            if (sLabType.equals("1")) sLabType = getTran("Web.occup", "labanalysis.type.blood", sWebLanguage);
            else if (sLabType.equals("2")) sLabType = getTran("Web.occup", "labanalysis.type.urine", sWebLanguage);
            else if (sLabType.equals("3")) sLabType = getTran("Web.occup", "labanalysis.type.other", sWebLanguage);
            else if (sLabType.equals("4")) sLabType = getTran("Web.occup", "labanalysis.type.stool", sWebLanguage);
            else if (sLabType.equals("5")) sLabType = getTran("Web.occup", "labanalysis.type.sputum", sWebLanguage);
            else if (sLabType.equals("6")) sLabType = getTran("Web.occup", "labanalysis.type.smear", sWebLanguage);
            else if (sLabType.equals("7")) sLabType = getTran("Web.occup", "labanalysis.type.liquid", sWebLanguage);

            sOut.append(writeRow(sLabType, sLabCode, sLabLabel, sCodeOther, sComment,objLabAnalysis.getUnavailable(), iTotal,sWebLanguage));
            sScript.append("<script>addLabAnalysisToArray(")
                    .append("'").append(sLabID).append("',")
                    .append("'").append(sLabCode).append("',")
                    .append("'").append(sLabType).append("',")
                    .append("'").append(sLabLabel.replaceAll("\'","´")).append("',")
                    .append("'").append(sCodeOther.replaceAll("\'","´")).append("',")
                    .append("'").append(sMonster.replaceAll("\'","´")).append("');</script>");
        }

        showMsg = true;
    }
    //--- show ALL (unselected) RECORDS -----------------------------------------------------------
    else {
        if (MedwanQuery.getInstance().getConfigString("fillUpSearchScreens").equalsIgnoreCase("on")) {
            Vector hLabAnalysis = LabAnalysis.searchByLabCodeForPatient("%", sSelectedLabCodes, "%", sSortCol, sWebLanguage);
            LabAnalysis objLabAnalysis;

            for (int n=0;n<hLabAnalysis.size();n++) {
                objLabAnalysis = (LabAnalysis) hLabAnalysis.elementAt(n);

                iTotal++;

                sLabID = Integer.toString(objLabAnalysis.getLabId());
                sLabType = objLabAnalysis.getLabtype();
                sLabCode = objLabAnalysis.getLabcode();
                sLabLabel = objLabAnalysis.getMedidoccode();
                sCodeOther = objLabAnalysis.getLabcodeother();
                sComment = objLabAnalysis.getComment();
                sMonster = getTranNoLink("labanalysis.monster",objLabAnalysis.getMonster(),sWebLanguage);

                // translate labtype
                if (sLabType.equals("1")) sLabType = getTran("Web.occup", "labanalysis.type.blood", sWebLanguage);
                else if (sLabType.equals("2")) sLabType = getTran("Web.occup", "labanalysis.type.urine", sWebLanguage);
                else if (sLabType.equals("3")) sLabType = getTran("Web.occup", "labanalysis.type.other", sWebLanguage);
                else if (sLabType.equals("4")) sLabType = getTran("Web.occup", "labanalysis.type.stool", sWebLanguage);
                else if (sLabType.equals("5")) sLabType = getTran("Web.occup", "labanalysis.type.sputum", sWebLanguage);
                else if (sLabType.equals("6")) sLabType = getTran("Web.occup", "labanalysis.type.smear", sWebLanguage);
                else if (sLabType.equals("7")) sLabType = getTran("Web.occup", "labanalysis.type.liquid", sWebLanguage);

                sOut.append(writeRow(sLabType, sLabCode, sLabLabel, sCodeOther, sComment,objLabAnalysis.getUnavailable(), iTotal,sWebLanguage));
                sScript.append("<script>addLabAnalysisToArray(")
                        .append("'").append(sLabID).append("',")
                        .append("'").append(sLabCode).append("',")
                        .append("'").append(sLabType).append("',")
                        .append("'").append(sLabLabel.replaceAll("\'","´")).append("',")
                        .append("'").append(sCodeOther.replaceAll("\'","´")).append("',")
                        .append("'").append(sMonster.replaceAll("\'","´")).append("');</script>");
            }

            showMsg = true;
        }
    }
%>
<script>
    var foundAnalysis = new Array();
    analysisCount = 0;
</script>
<form name="searchForm" method="POST" onSubmit="doFind();">
  <input type="hidden" name="sortCol" value="code">

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="menu">
    <%-- SEARCH INPUTS --------------------------------------------------------------------------%>
    <tr>
      <td width="50%" height="25">
        &nbsp;<%=getTran("web.manage","labanalysis.cols.code",sWebLanguage)%>/<%=getTran("web.manage","labanalysis.cols.name",sWebLanguage)%>&nbsp;<input class="text" type="text" id="FindCode" name="FindCode" value="<%=sSearchCode%>" size="16">
        &nbsp;<%=getTran("web.occup","labprofiles.profile",sWebLanguage)%>

        <%-- SELECT A LABPROFILE --%>
        <select name="FindProfileID" class="text" onchange="searchForm.submit()">
          <option value=""/>
          <%
              String sID, sLabel;
              Hashtable hProfiles = LabProfile.getProfiles(sWebLanguage);

              Enumeration e = hProfiles.keys();
              LabProfile objLabProf;
			  // sort profiles
			  SortedSet sortedProfiles = new TreeSet();
              while(e.hasMoreElements()){
                  sLabel = (String)e.nextElement();
            	  sortedProfiles.add(sLabel);
              }
           	  // display each profile as an option
           	  Iterator i = sortedProfiles.iterator();
              while(i.hasNext()){
                  sLabel = (String)i.next();
                  objLabProf = (LabProfile)hProfiles.get(sLabel);
                  sID = Integer.toString(objLabProf.getProfileID());

                  %><option value="<%=sID%>" <%=(sID.equals(sSearchProfileID)?"selected":"")%>><%=sLabel%></option><%
              }
          %>
        </select>&nbsp;

        <%-- BUTTONS --%>
        <input class="button" type="button" name="FindButton" value="<%=getTran("Web","find",sWebLanguage)%>" onClick="doFind();">&nbsp;
        <input class="button" type="button" name="ClearButton" value="<%=getTran("Web","clear",sWebLanguage)%>" onClick="clearForm();">
      </td>
    </tr>

    <tr><td colspan="2" class="navigation_line" height="1"></td></tr>

    <script>
    function clearForm(){
        searchForm.FindCode.value = "";
        searchForm.FindProfileID.selectedIndex = 0;
        searchForm.FindCode.focus();
      }

      function doFind(){
        ToggleFloatingLayer('FloatingLayer',1);
        searchForm.FindButton.disabled = true;
        searchForm.submit();
      }
    </script>

    <%-- SEARCH RESULTS -------------------------------------------------------------------------%>
    <tr>
      <td colspan="2" class="white" valign="top">
        <div class="search" style="overflow: auto;width: 595px;height: 360px">
          <table width="100%" cellspacing="1" cellpadding="0">
            <%-- HEADER --%>
            <tr class="admin">
              <td width="17">&nbsp;</td>
              <td width="80">&nbsp;<a class="underlined" href="#" onClick="searchForm.sortCol.value='code';searchForm.submit();"><%=getTran("web.manage","labanalysis.cols.code",sWebLanguage)%></a></td>
              <td width="80">&nbsp;<a class="underlined" href="#" onClick="searchForm.sortCol.value='type';searchForm.submit();"><%=getTran("web.manage","labanalysis.cols.type",sWebLanguage)%></a></td>
              <td width="180">&nbsp;<a class="underlined" href="#" onClick="searchForm.sortCol.value='name';searchForm.submit();"><%=getTran("web.manage","labanalysis.cols.name",sWebLanguage)%></a></td>
              <td width="170">&nbsp;<a class="underlined" href="#" onClick="searchForm.sortCol.value='comment';searchForm.submit();"><%=getTran("web.manage","labanalysis.cols.comment",sWebLanguage)%></a></td>
            </tr>
            <%=sOut%>

            <%
                if(showMsg){
                    out.print("<tr><td colspan='5'><br>"+iTotal+" "+getTran("web","recordsfound",sWebLanguage)+"</td></tr>");
                }
            %>
          </table>
        </div>
      </td>
    </tr>
  </table>

  <br>
  <%-- BUTTONS --%>
  <center>
    <input type="button" name="buttonadd"    class="button" value="<%=getTran("Web","add",sWebLanguage)%>" onclick="addSelection();">&nbsp;
    <input type="button" name="buttonaddall" class="button" value="<%=getTran("Web","addall",sWebLanguage)%>" onclick="addAllLabAnalysis();setFocusToCode();">&nbsp;
    <input type="button" name="buttonclose"  class="button" value="<%=getTran("Web","Close",sWebLanguage)%>" onclick="window.close();">
  </center>

  <%-- HIDDEN FIELDS --%>
  <input type="hidden" name="VarID"   value="<%=sVarID%>">
  <input type="hidden" name="VarType" value="<%=sVarType%>">
  <input type="hidden" name="VarCode" value="<%=sVarCode%>">
  <input type="hidden" name="VarText" value="<%=sVarText%>">

  <script>
  <%-- ADD SELECTION --%>
	 function addSelection(){
	   if(atLeastOneLabAnalysisSelected()){
	     addSelectedLabAnalysis();
	   }
	 }
</script>
<script>
	window.resizeTo(595,485);
    searchForm.FindCode.focus();
    <%-- ADD ALL LABANALYSIS --%>
    function addLabAnalysis(code,type,label,other,monster,total){
      if(other=="1"){
        var comment = document.getElementById('comment'+total).value;
        window.opener.addLabAnalysis(code,type,label,comment,monster);
      }
      else{
        window.opener.addLabAnalysis(code,type,label,'',monster);
      }
    }
    <%-- ADD ALL LABANALYSIS --%>
    function addAllLabAnalysis(){
      for(var i=0; i<foundAnalysis.length; i++){
        addLabAnalysis(foundAnalysis[i][1],foundAnalysis[i][2],foundAnalysis[i][3],foundAnalysis[i][4],foundAnalysis[i][5],(i+1));
      }
      window.opener.sortLabAnalyses();
    }
    <%-- ADD SELECTED LAB ANALYSIS --%>
    function addSelectedLabAnalysis(){
    	var inputs = document.getElementsByTagName("input");
      var cbCount = 0;
      var closeWindow = true;

      for(var i=0; i<inputs.length; i++){
        if(inputs[i].type=="checkbox"){
          cbCount++;
          if(inputs[i].checked){
        	  var id = inputs[i].name.substring(3);
            var analysis = foundAnalysis[id-1];
            <%-- if analysis of code 'other', check if comment is not empty. --%>
            if(analysis[4] == "1"){
              var commentObj = document.getElementById("comment"+cbCount);
              if(commentObj.value == ""){
                commentObj.focus();
                var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=999999999&labelType=Web.occup&labelID=specifycomment";
                var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.occup","specifycomment",sWebLanguage)%>");

                closeWindow = false;
              }
              else{
                addLabAnalysis(analysis[1],analysis[2],analysis[3],analysis[4],analysis[5],cbCount);
              }
            }
            else{
              addLabAnalysis(analysis[1],analysis[2],analysis[3],analysis[4],analysis[5],cbCount);
            }
          }
        }
      }

      window.opener.sortLabAnalyses();
      //if(closeWindow) window.close();
    }

    <%-- ADD LABANALYSIS TO ARRAY --%>
    function addLabAnalysisToArray(id,code,type,label,other,monster){
      foundAnalysis[analysisCount] = new Array(id,code,type,label,other,monster);
      analysisCount++;
    }


    <%-- AT LEAST ONE LAB ANALYSIS SELECTED --%>
    function atLeastOneLabAnalysisSelected(){
      var inputs = document.getElementsByTagName("input");

      for(var i=0; i<inputs.length; i++){
        if(inputs[i].type=="checkbox"){
          if(inputs[i].checked){
            return true;
          }
        }
      }
      return false;
    }
    </script>
    <%=sScript%>
</form>

<script>
    function setFocusToCode(){
        window.setTimeout("document.getElementById('FindCode').focus();",200);
    }

    setFocusToCode();
</script>
