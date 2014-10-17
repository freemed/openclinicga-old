<%@page import="be.openclinic.medical.RequestedLabAnalysis"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.management","all",activeUser)%>
<%=sJSSORTTABLE%>

<%!
    //--- OBJECTS TO HTML (type1 : user or patient) -----------------------------------------------
    private StringBuffer objectsToHtmlType1(Vector objects, String resultType, boolean showOnlyOpenResults, 
    		                                String sWebLanguage, String resultsOnly){
        StringBuffer html = new StringBuffer();
        String sClass = "list1", resultDate, personFullName;
        
        // frequently used translations
        String detailsTran = getTranNoLink("web","showdetails",sWebLanguage),
               deleteTran = getTranNoLink("Web","delete",sWebLanguage),
               labrequestTran = getTranNoLink("Web.manage","showlabrequest",sWebLanguage);

        // run thru found objects
        RequestedLabAnalysis labResult;
        String activeTransactionId = "";

        for(int i=0; i<objects.size(); i++){
            labResult = (RequestedLabAnalysis)objects.get(i);
            if(resultsOnly.length() > 0 && (labResult.getResultValue()==null || labResult.getResultValue().length()==0)){
                continue;
            }
            
            String tranId = labResult.getServerId()+"."+labResult.getTransactionId();
            
            // person full name
           	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();

            if(resultType.equals("patient")){
                personFullName = ScreenHelper.getFullUserName(labResult.getRequestUserId(),ad_conn);
            }
            else{
                personFullName = ScreenHelper.getFullPersonName(labResult.getPatientId(),ad_conn);
            }
            
			try{
				ad_conn.close();
			}
			catch(Exception e){
				e.printStackTrace();
			}
			
            if(!activeTransactionId.equalsIgnoreCase(tranId)){
                activeTransactionId = tranId;
                html.append("<tr class='gray' title='"+detailsTran+"'>")
                     .append("<td colspan='4'>"+(labResult.getRequestDate()!=null?ScreenHelper.formatDate(labResult.getRequestDate()) : "")+"</td>")
                     .append("<td colspan='4'>"+personFullName+"</td>")
                    .append("</tr>");
            }

            // format result date
            resultDate = stdDateFormat.format(labResult.getResultDate());

            // alternate row-style
            if(showOnlyOpenResults) {
                if(sClass.equals("list")) sClass = "list1";
                else                      sClass = "list";
            }
            else {
                // red when empty resultModifier
                if(labResult.getResultModifier().length()!=0 && !labResult.getResultModifier().equalsIgnoreCase("n")){
                    sClass = "red";
                }
                else{
                    if(sClass.equals("list")) sClass = "list1";
                    else                      sClass = "list";
                }
            }

            //*** display product in one row ***
            html.append("<tr class='"+sClass+"' onmouseover=\"this.style.cursor='hand'\" onmouseout=\"this.style.cursor='default'\" title='"+detailsTran+"'>")
                 .append("<td>&nbsp;</td>")
                 .append("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' class='link' title='"+deleteTran+"' onclick=\"doDelete('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">")
                 .append("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_view.gif' class='link' title='"+labrequestTran+"' onclick=\"showLabRequest('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"');\">")
                 .append("<td onclick=\"showResultDetails('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">"+labResult.getAnalysisCode()+"</td>")
                 .append("<td onclick=\"showResultDetails('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">"+getTran("labanalysis",labResult.getAnalysisCode(),sWebLanguage)+"</td>")
                 .append("<td onclick=\"showResultDetails('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">"+labResult.getResultValue()+" "+labResult.getResultUnit()+"</td>")
                 .append("<td onclick=\"showResultDetails('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">"+(labResult.getResultValue()!=null && labResult.getResultValue().length()>0?resultDate:"")+"</td>")
                 .append("<td onclick=\"showResultDetails('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">"+(labResult.getResultModifier().length()>0?getTran("labanalysis.resultmodifier",labResult.getResultModifier(),sWebLanguage):"")+"</td>")
                .append("</tr>");
        }

        return html;
    }

    //--- OBJECTS TO HTML (type2 : user NOR patient) ----------------------------------------------
    private StringBuffer objectsToHtmlType2(Vector objects, boolean showOnlyOpenResults, String sWebLanguage){
        StringBuffer html = new StringBuffer();
        String sClass = "list1", resultDate;

        // frequently used translations
        String detailsTran = getTranNoLink("web","showdetails",sWebLanguage),
               deleteTran = getTranNoLink("Web","delete",sWebLanguage),
               labrequestTran = getTranNoLink("Web.manage","showlabrequest",sWebLanguage);

        // run through found objects
        RequestedLabAnalysis labResult;
        String activeTransactionId = "";

        for(int i=0; i<objects.size(); i++){
            labResult = (RequestedLabAnalysis)objects.get(i);
            String tranId = labResult.getServerId()+"."+labResult.getTransactionId();
           
            // person full name
	      	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
            String userFullName = ScreenHelper.getFullUserName(labResult.getRequestUserId(),ad_conn);
            String patientFullName = ScreenHelper.getFullPersonName(labResult.getPatientId(),ad_conn);
            ad_conn.close();

            if(!activeTransactionId.equalsIgnoreCase(tranId)){
                activeTransactionId = tranId;
                html.append("<tr class='gray' title='"+detailsTran+"'>")
                     .append("<td colspan='4'>"+(labResult.getRequestDate()!=null?ScreenHelper.formatDate(labResult.getRequestDate()):"")+"</td>")
                     .append("<td>"+patientFullName+"</td>")
                     .append("<td colspan='5'>"+userFullName+"</td>")
                    .append("</tr>");
            }

            // format result date
            resultDate = ScreenHelper.formatDate(labResult.getResultDate());

            // alternate row-style
            if(showOnlyOpenResults){
                if(sClass.equals("list")) sClass = "list1";
                else                      sClass = "list";
            }
            else{
                // red when empty resultModifier
                if(labResult.getResultModifier().length()!=0 && !labResult.getResultModifier().equalsIgnoreCase("n")){
                    sClass = "red";
                }
                else{
                    if(sClass.equals("list")) sClass = "list1";
                    else                      sClass = "list";
                }
            }

            //*** display product in one row ***
            html.append("<tr class='"+sClass+"' onmouseover=\"this.style.cursor='hand'\" onmouseout=\"this.style.cursor='default'\" title='"+detailsTran+"'>")
                 .append("<td>&nbsp;</td>")
                 .append("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.gif' class='link' title='"+deleteTran+"' onclick=\"doDelete('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">")
                 .append("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_view.gif' class='link' title='"+labrequestTran+"' onclick=\"showLabRequest('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"');\">")
                 .append("<td onclick=\"showResultDetails('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">"+labResult.getAnalysisCode()+"</td>")
                 .append("<td colspan='3' onclick=\"showResultDetails('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">"+getTran("labanalysis",labResult.getAnalysisCode(),sWebLanguage)+"</td>")
                 .append("<td onclick=\"showResultDetails('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">"+labResult.getResultValue()+" "+labResult.getResultUnit()+"</td>")
                 .append("<td onclick=\"showResultDetails('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">"+resultDate+"</td>")
                 .append("<td onclick=\"showResultDetails('"+labResult.getServerId()+"','"+labResult.getTransactionId()+"','"+labResult.getAnalysisCode()+"');\">"+(labResult.getResultModifier().length()>0?getTran("labanalysis.resultmodifier",labResult.getResultModifier(),sWebLanguage):"")+"</td>")
                .append("</tr>");
        }

        return html;
    }
%>

<%
    // action
    String sAction = checkString(request.getParameter("Action"));
    if(sAction.length()==0){
        sAction = checkString(request.getParameter("AutoAction"));
    }

    // form data
    String sEditServerId      = checkString(request.getParameter("EditServerId")),
           sResultsOnly       = checkString(request.getParameter("resultsOnly")),
           sEditTransactionId = checkString(request.getParameter("EditTransactionId")),
           sEditPatientId     = checkString(request.getParameter("EditPatientId")),
           sEditLabCode       = checkString(request.getParameter("EditLabCode")).toLowerCase(),
           sFindLabCode       = checkString(request.getParameter("FindLabCode")).toLowerCase(),
           sFindResultDate    = checkString(request.getParameter("FindResultDate"));

    String msg = "";

    // default search date : one month ago
    if(sFindResultDate.length()==0){
        String showLabResultsSinceDays = MedwanQuery.getInstance().getConfigString("showLabResultsSinceDays","7");
        java.util.Date now = new java.util.Date();
        java.util.Date since = new java.util.Date(now.getTime()-(Long.parseLong(showLabResultsSinceDays)*24*3600*1000));
        sFindResultDate = stdDateFormat.format(since);
    }

    // parameter-options
    String resultType = checkString(request.getParameter("type")),
           open       = checkString(request.getParameter("open"));
    boolean showOpenResultsOnly = false;
    if(open.length() > 0 && open.equalsIgnoreCase("true")){
        showOpenResultsOnly = true;
    }

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************** system/manageLaboResults.jsp ********************");
    	Debug.println("sAction             : "+sAction);
    	Debug.println("sEditServerId       : "+sEditServerId);
    	Debug.println("sEditTransactionId  : "+sEditTransactionId);
    	Debug.println("sEditLabCode        : "+sEditLabCode);
    	Debug.println("sFindLabCode        : "+sFindLabCode);
    	Debug.println("sFindResultDate     : "+sFindResultDate);
    	Debug.println("resultType          : "+resultType);
    	Debug.println("showOpenResultsOnly : "+showOpenResultsOnly+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();
%>
<%-- SEARCHFORM ---------------------------------------------------------------------------------%>
<form name="transactionForm" id="transactionForm" method="post" onKeyDown="if(window.event.keyCode==13){doFind();}">
    <input type="hidden" name="resultsOnly" value="<%=sResultsOnly%>"/>
    <input type="hidden" name="Action" value="find"/>
    <input type="hidden" name="EditServerId" value=""/>
    <input type="hidden" name="EditTransactionId" value=""/>
    <input type="hidden" name="EditLabCode" value=""/>

    <%-- page title --%>
    <%
        String personName = "";
        String titleType = "manageLabResults";
        if(showOpenResultsOnly) titleType = "manageOpenLabResults";

        if(resultType.equals("user")){
            titleType+= "User";
            personName = activeUser.person.lastname+" "+activeUser.person.firstname;
        }
        else if(resultType.equals("patient")){
            titleType+= "Patient";
            personName = activePatient.lastname+" "+activePatient.firstname;
        }
    %>
    <table width="100%" cellspacing="0">
        <tr class="Admin">
            <td><%=getTran("Web.manage",titleType,sWebLanguage)%>&nbsp;<%=personName%></td>
        </tr>
    </table>

    <%-- search table --%>
    <table width="100%" class="menu" cellspacing="0" cellpadding="1">
        <tr>
            <td class="admin2" colspan="2" height="22">
                <%-- RESULT DATE --%>
                &nbsp;<%=getTran("Web.manage","labanalysis.cols.resultdate",sWebLanguage)%>&nbsp;
                <%=writeDateField("FindResultDate","transactionForm",sFindResultDate,sWebLanguage)%>&nbsp;

                <%-- LAB CODE --%>
                &nbsp;<%=getTran("Web.manage","labanalysis.cols.analysiscode",sWebLanguage)%>&nbsp;
                <input type="text" class="text" name="FindLabCode" value="<%=sFindLabCode%>" size="5" maxLength="5">

                <%-- buttons --%>
                &nbsp;&nbsp;
                <input class="button" type="button" name="findButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>" onclick="doFind();">&nbsp;
                <input class="button" type="button" name="clearButton" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearSearchFields();">&nbsp;
            </td>
        </tr>
    </table>
</form>
<%
    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        // create and save a LabAnalysis
        RequestedLabAnalysis analysis = new RequestedLabAnalysis();
        analysis.setServerId(sEditServerId);
        analysis.setTransactionId(sEditTransactionId);
        analysis.setPatientId(sEditPatientId);
        analysis.setAnalysisCode(sEditLabCode);
        analysis.setPatientId(activePatient.personid);

        // fill in result-data
        analysis.setComment(checkString(request.getParameter("EditComment")));
        analysis.setResultValue(checkString(request.getParameter("EditResultValue")));
        analysis.setResultUnit(checkString(request.getParameter("EditResultUnit")));
        analysis.setResultModifier(checkString(request.getParameter("EditResultModifier")));
        analysis.setResultComment(checkString(request.getParameter("EditResultComment")));
        analysis.setResultRefMax(checkString(request.getParameter("EditResultRefMax")));
        analysis.setResultRefMin(checkString(request.getParameter("EditResultRefMin")));
        analysis.setResultDate(ScreenHelper.parseDate(request.getParameter("EditResultDate")));
        analysis.setResultUserId(checkString(request.getParameter("EditResultUserId")));

        analysis.store(true); // object exists, so update

        // message
        msg = getTran("web.manage","labResultIsSaved",sWebLanguage);
        sAction = "find";
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete")){
        RequestedLabAnalysis.delete(Integer.parseInt(sEditServerId),Integer.parseInt(sEditTransactionId),sEditLabCode);

        // message
        msg = getTran("web.manage","labResultIsDeleted",sWebLanguage);
        sAction = "find";
    }

    //--- FIND ------------------------------------------------------------------------------------
    if(sAction.equals("find")){
        Vector foundObjects;

        if(resultType.equals("user")){
            // search labResults for activeUser
            foundObjects = RequestedLabAnalysis.find("","","",sFindLabCode,"","","","","","","","",
                                                     sFindResultDate,"updateTime DESC,a.serverid,a.transactionid,resultDate","DESC",
                                                     showOpenResultsOnly,activeUser.userid);
        }
        else if(resultType.equals("patient")){
            // search labresults for activePatient
            foundObjects = RequestedLabAnalysis.find("","",activePatient.personid,sFindLabCode,"","","","","","","","",
                                                     sFindResultDate,"updateTime DESC,a.serverid,a.transactionid,resultDate","DESC",
                                                     showOpenResultsOnly,"");
        }
        else{
            // search all open labresults
            foundObjects = RequestedLabAnalysis.find("","","",sFindLabCode,"","","","","","","","",
                                                     sFindResultDate,"updateTime DESC,a.serverid,a.transactionid,resultDate","DESC",
                                                     showOpenResultsOnly,"");
        }

        StringBuffer labResultsHtml;
        if(resultType.length() > 0){
            labResultsHtml = objectsToHtmlType1(foundObjects,resultType,showOpenResultsOnly,sWebLanguage,sResultsOnly);
        }
        else{
            labResultsHtml = objectsToHtmlType2(foundObjects,showOpenResultsOnly,sWebLanguage);
        }
        
        int foundObjectCount = foundObjects.size();
        if(foundObjectCount > 0){
            %>
                <table id="tblLA" width="100%" cellspacing="0" class="sortable">
                    <%-- header --%>
                    <tr class="admin">
                        <td width="18"></td>
                        <td width="18"></td>
                        <td width="18"></td>
                        <td width="12%">&nbsp;<%=getTran("Web.manage","labanalysis.cols.analysiscode",sWebLanguage)%></td>

                        <%
                            if(resultType.equals("")){
                                // display both patient and user
                                %>
                                    <td width="30%">&nbsp;<%=getTran("Web.manage","labanalysis.cols.patient",sWebLanguage)%></td>
                                    <td width="30%">&nbsp;<%=getTran("Web.manage","labanalysis.cols.user",sWebLanguage)%></td>
                                <%
                            }
                            else{
                                // display patient OR user
                                %>
                                    <td width="30%">&nbsp;<%=getTran("Web.manage","labanalysis.cols."+(resultType.equalsIgnoreCase("user")?"patient":"user"),sWebLanguage)%></td>
                                <%
                            }

                            // urgency
                            if(resultType.equals("")){
                                %><td width="10%">&nbsp;<%=getTran("Web.manage","labanalysis.cols.urgency",sWebLanguage)%></td><%
                            }
                        %>

                        <td width="*">&nbsp;<%=getTran("Web.manage","labanalysis.cols.resultvalue",sWebLanguage)%></td>
                        <td width="*">&nbsp;<%=getTran("Web.manage","labanalysis.cols.resultdate",sWebLanguage)%></td>
                        <td width="10%">&nbsp;<%=getTran("Web.manage","labanalysis.cols.resultmodifier",sWebLanguage)%></td>
                    </tr>

                    <%=labResultsHtml%>
                </table>

                <%-- MESSAGE --%>
                <%
                    if(msg.length() > 0){
                        %><%=msg%><br><%
                    }
                %>

                <%-- number of records found --%>
                <span style="width:49%;text-align:left;">
                    <a href="#topp" class="topbutton">&nbsp;</a> &nbsp; <%=foundObjectCount%> <%=getTran("web","recordsfound",sWebLanguage)%>
                </span>
            <%
        }
        else{
            // no records found
            %><%=getTran("web","norecordsfound",sWebLanguage)%><%
        }
    }
%>
<script>
  <%-- SORT LABANALYSES --%>
  function sortLabAnalyses(){
    var sortLink = document.getElementById('lnk1');
    if(sortLink!=null){
      ts_resortTable(sortLink,1,false);
    }
  }

  <%-- UPDATE ROW STYLES (especially after sorting, red row when no resultmodifier) --%>
  function updateRowStyles(){
    for(i=1; i<tblLA.rows.length; i++){
      tblLA.rows[i].className = "list1";
      tblLA.rows[i].style.cursor = 'hand';
    }

    for(i=1; i<tblLA.rows.length; i++){
      <%
          if(!showOpenResultsOnly){
              int modifierCellIdx = 5;
              if(resultType.length()==0) modifierCellIdx = 7;

              %>
                if(tblLA.rows[i].cells(<%=modifierCellIdx%>).innerHTML == ""){
                  tblLA.rows[i].className = "red";
                }
                else{
              <%
          }
      %>

      if(i%2>0){
        tblLA.rows[i].className = "list";
      }

      <%
          if(!showOpenResultsOnly){
              %>
                  }
              <%
          }
      %>
    }
  }

  <%-- DO FIND --%>
  function doFind(){
    if(transactionForm.FindResultDate.value.length > 0){
      transactionForm.Action.value = "find";
      transactionForm.submit();
    }
    else{
      alertDialog("web.manage","dataMissing");
      transactionForm.FindResultDate.focus();
    }
  }

  <%-- CLEAR SEARCH FIELDS --%>
  function clearSearchFields(){
    transactionForm.FindResultDate.value = '';
    transactionForm.FindLabCode.value = '';

    transactionForm.FindResultDate.focus();
  }

  <%-- DO DELETE --%>
  function doDelete(serverid,transactionid,labcode){
	if(yesnoDialog("Web","areYouSureToDelete")){
      transactionForm.Action.value = "delete";

      transactionForm.EditServerId.value = serverid;
      transactionForm.EditTransactionId.value = transactionid;
      transactionForm.EditLabCode.value = labcode;

      transactionForm.submit();
    }
  }

  <%-- SHOW LAB LABRESULT DETAILS --%>
  function showResultDetails(serverId,transactionId,analysisCode){
    var url = "<%=sCONTEXTPATH%>/healthrecord/labResultPopup.jsp?serverId="+serverId+"&transactionId="+transactionId+"&analysisCode="+analysisCode+"&editable=true";
    window.open(url,"","height=1,width=1,toolbar=no,status=no,scrollbars=no,resizable=no,menubar=no");
  }

  <%-- SHOW LAB LABREQUEST --%>
  function showLabRequest(serverId,transactionId){
    var url = "<%=sCONTEXTPATH%>/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUESTpopup&be.mxs.healthrecord.createTransaction.context=<%=activeUser.activeService.defaultContext%>&be.mxs.healthrecord.transaction_id="+transactionId+"&be.mxs.healthrecord.server_id="+serverId;
    window.open(url,"","height=1,width=1,toolbar=no,status=no,scrollbars=no,resizable=yes,menubar=no");
  }

  <%-- REFRESH CONTENT --%>
  function refreshContent(){
    window.location.href = "<c:url value='../main.jsp?Page=system/manageLaboResults.jsp'/>&AutoAction=find&type=<%=resultType%>&open=<%=showOpenResultsOnly%>&resultsOnly=<%=sResultsOnly%>&ts=<%=getTs()%>";
  }
</script>

<%=writeJSButtons("transactionForm","SaveButton")%>