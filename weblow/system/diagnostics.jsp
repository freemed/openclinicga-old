<%@page import="org.dom4j.io.SAXReader,
                java.net.URL,
                org.dom4j.Element,
                be.mxs.common.util.diagnostics.Diagnostic,
                be.mxs.common.util.diagnostics.Diagnosis, java.util.Hashtable"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.management","all",activeUser)%>
<script>window.clearInterval(userinterval);</script>
<%!
    //--- RUN DIAGNOSTIC --------------------------------------------------------------------------
    private void runDiagnostic(Diagnostic diagnostic, javax.servlet.jsp.JspWriter out){
        try{
            status(out,"Cleaning "+diagnostic.getName()+"...");

            Diagnosis diagnosis = diagnostic.check();
            if(diagnosis.hasProblems){
                if(diagnostic.correct(diagnosis)){
                    status(out,diagnostic.getName()+" cleanup was OK");
                }
                else{
                    status(out,diagnostic.getName()+" ERROR: cleanup was not OK>");
                }
            }
            else{
                status(out,diagnostic.getName()+" had no problems");
            }
        }
        catch(IOException e){
            e.printStackTrace();
        }
    }
%>

<%
    String sAction = checkString(request.getParameter("Action"));
    //if(sAction.length()==0) sAction = "verifyAll"; // default

    java.util.Hashtable diagnosisHash = new Hashtable();

    //--- CORRECT DIAGNOSTICS ---------------------------------------------------------------------
    // run checked diagnostics
    if(sAction.equals("correct")){
        Iterator diagnosticsIter = new SAXReader(false).read(new URL(ScreenHelper.getConfigString("templateSource") + "/application.xml")).getRootElement().element("integrityChecks").elements("integrityCheck").iterator();
        Diagnostic diagnostic;

        while(diagnosticsIter.hasNext()){
            diagnostic = (Diagnostic)Class.forName(((Element)diagnosticsIter.next()).attributeValue("className")).newInstance();
            if(request.getParameter(diagnostic.getName()) != null){
                runDiagnostic(diagnostic, out);
            }
        }

        sAction = "verify";
    }

    //--- VERIFY DIAGNOSTICS ----------------------------------------------------------------------
    if(sAction.startsWith("verify")){
        Iterator diagnosticsIter = new SAXReader(false).read(new URL(ScreenHelper.getConfigString("templateSource") + "/application.xml")).getRootElement().element("integrityChecks").elements("integrityCheck").iterator();
        Diagnostic diagnostic;
        Diagnosis diagnosis;

        while(diagnosticsIter.hasNext()){
            diagnostic = (Diagnostic)Class.forName(((Element)diagnosticsIter.next()).attributeValue("className")).newInstance();

            if(request.getParameter(diagnostic.getName()) != null || sAction.equals("verifyAll")){
                diagnosis = diagnostic.check();
                status(out, "Executing diagnostic " + diagnostic.getName() + " version " + diagnostic.getVersion());
                diagnosisHash.put(diagnostic.getName(), diagnosis);
            }
        }
    }
%>

<form name="transactionForm" method="post">
    <input type="hidden" name="Action">

    <table border="0" width="100%" align="center" cellspacing="1" cellpadding="0" class="list">
        <%-- TITLE --%>
        <tr>
            <td colspan="3"><%=writeTableHeader("Web.manage","diagnostics",sWebLanguage," doBack();")%></td>
        </tr>

        <%
            // display available diagnostics
            Iterator diagnosticsIter = new SAXReader(false).read(new URL(ScreenHelper.getConfigString("templateSource")+"/application.xml")).getRootElement().element("integrityChecks").elements("integrityCheck").iterator();
            Diagnostic diagnostic;
            Diagnosis diagnosis;
            int counter = 0;

            while(diagnosticsIter.hasNext()){
                try{
                    counter++;

                    diagnostic = (Diagnostic)Class.forName(((Element)diagnosticsIter.next()).attributeValue("className")).newInstance();
                    diagnosis = (Diagnosis)diagnosisHash.get(diagnostic.getName());

                    out.print("<tr>");
                    out.print(" <td class='admin2' width='25'>");
                    out.print("  <input type='checkbox' name='"+diagnostic.getName()+"' id='diagnostic_"+counter+"' "+((diagnosis!=null && diagnosis.hasProblems)?"checked":"")+"/>");
                    out.print(" </td>");
                    out.print(" <td class='admin2' onClick='selectDiagnostic("+counter+");'><b>"+diagnostic.getName()+"</b> ("+diagnostic.getDescription()+")</td>");

                    if(diagnosis!=null){
                        if(diagnosis.hasProblems) out.print("<td width='65' class='red'>&nbsp;ERROR</td>");
                        else                      out.print("<td width='65' class='green'>&nbsp;OK</td>");
                    }
                    else{
                        out.print("<td width='65' class='admin2'>UNVERIFIED&nbsp;</td>");
                    }

                    out.print("</tr>");
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        %>
    </table>

    <%-- CHECK ALL --%>
    <table width="100%" cellspacing="1">
        <tr>
            <td colspan="3">
                <a href="#" onclick="checkAll(true);"><%=getTran("Web.Manage.CheckDb","CheckAll",sWebLanguage)%></a>
                <a href="#" onclick="checkAll(false);"><%=getTran("Web.Manage.CheckDb","UncheckAll",sWebLanguage)%></a>
            </td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <div align="center">
        <input class="button" type="button" name="verifyButton" value="<%=getTranNoLink("web.occup","medwan.healthrecord.ophtalmology.verify",sWebLanguage)%>" onclick="verifyDiagnostics();"/>
        <input class="button" type="button" name="correctButton" value="<%=getTranNoLink("web.occup","medwan.healthrecord.ophtalmology.correction",sWebLanguage)%>" onclick="correctDiagnostics();"/>
        <input class="button" type="button" name="backButton" value="<%=getTran("Web","Back",sWebLanguage)%>" OnClick="doBack();"/>
    </div>
</form>

<script>
  <%-- VERIFY DIAGNOSTICS --%>
  function verifyDiagnostics(){
    if(atLeastDiagnosticSelected()){
      transactionForm.Action.value = "verify";
      transactionForm.submit();
    }
    else{
      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=selectAtLeastOneDiagnostic";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","selectAtLeastOneDiagnostic",sWebLanguage)%>");
    }
  }

  <%-- CORRECT DIAGNOSTICS --%>
  function correctDiagnostics(){
    if(atLeastDiagnosticSelected()){
      transactionForm.Action.value = "correct";
      transactionForm.submit();
    }
    else{
      var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=selectAtLeastOneDiagnostic";
      var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","selectAtLeastOneDiagnostic",sWebLanguage)%>");
    }
  }

  <%-- CHECK ALL --%>
  function checkAll(setchecked){
    for(var i=0; i<transactionForm.elements.length; i++){
      if(transactionForm.elements[i].type=="checkbox"){
        transactionForm.elements[i].checked = setchecked;
      }
    }
  }

  <%-- SELECT DIAGNOSTIC --%>
  function selectDiagnostic(diagnosticIdx){
    var cb = document.getElementById("diagnostic_"+diagnosticIdx);
    cb.checked = !cb.checked;
  }

  <%-- AT LEAST ONE DIAGNOSTIC SELECTED --%>
  function atLeastDiagnosticSelected(){
    var inputs = document.getElementsByTagName('input');

    for(var i=0; i<inputs.length; i++){
      if(inputs[i].type=='checkbox'){
        if(inputs[i].checked){
          return true;
        }
      }
    }

    return false;
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp&Tab=other&ts=<%=getTs()%>";
  }
</script>
