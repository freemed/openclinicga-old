<%@page import="be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                be.mxs.webapp.wl.session.SessionContainerFactory"%>
<%@ page import="java.util.StringTokenizer" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.physioconsultation","select",activeUser)%>
<%!
//--- USE TERMINOLOGYLIST
public String setTerminologyList() {
    String sTerminology = " onkeydown='if(enterEvent(event,123)){" +
            " openPopup(\"/_common/search/terminologyList.jsp&ts=" + getTs() + "&VarText=\" + this.name + \"&displayImmatNew=no&isUser=no\");" +
            " }'";
    return sTerminology;
}

%>
<%
    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();
%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <table width="100%">
    <tr><td>
<table class="list" width="100%" cellspacing="1">
    <%-- DATE --%>
    <tr>
        <td class="admin" width="20%">
            <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
            <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
        </td>
    </tr>
    <%-- Medical Diagnose--%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.diagnose_medical",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_DIAG_MEDIC")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_DIAG_MEDIC" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_DIAG_MEDIC" property="value"/></textarea>
        </td>
    </tr>
    <%-- Anamnese--%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.anamnese",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_ANAMNESE")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_ANAMNESE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_ANAMNESE" property="value"/></textarea>
        </td>
    </tr>
    <%-- Physical Exam--%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.physical_exam",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_EXAM_PHYS")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_EXAM_PHYS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_EXAM_PHYS" property="value"/></textarea>
        </td>
    </tr>
    <%-- Physical Diagnose--%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.physical_diagnose",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_DIAG_PHYS")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_DIAG_PHYS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_DIAG_PHYS" property="value"/></textarea>
        </td>
    </tr>
    <%-- Physical treatment plan--%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.physical_treatment_plan",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_PLAN_TRAIT_PHYS")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_PLAN_TRAIT_PHYS" property="itemId"/>]>.value" <%=setTerminologyList()%>><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_PLAN_TRAIT_PHYS" property="value"/></textarea>
        </td>
    </tr>
    <%-- Reevalution--%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.reeval",sWebLanguage)%>&nbsp;</td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_PHYSIO_CONS_REEVAL")%> cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_REEVAL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_REEVAL" property="value"/></textarea>
        </td>
    </tr>
    <%-- End Treatment DATE --%>
    <tr>
        <td class='admin'><%=getTran("web.occup","medwan.common.enddate_treatment",sWebLanguage)%>&nbsp;</td>
        <td class='admin2'>
            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_FIN_TRAIT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PHYSIO_CONS_FIN_TRAIT" property="value" formatType="date" format="dd-mm-yyyy"/>" id="endtreatdate"/>
            <script>writeMyDate("endtreatdate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
        </td>
    </tr>
<%-- BUTTONS --%>
    <tr>
        <td class="admin"/>
        <td class="admin2">
            <%=getTran("Web.Occup","PrintLanguage",sWebLanguage)%>
    <%
    String sPrintLanguage = checkString(activePatient.language);

    if (sPrintLanguage.length()==0){
        sPrintLanguage = sWebLanguage;
    }

    String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("SupportedLanguages");

    if(sSupportedLanguages.length()==0){
        sSupportedLanguages = "nl,fr";
    }
    %>
    <select class="text" name="PrintLanguage">
    <%
        String tmpLang;
        StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages, ",");
        while (tokenizer.hasMoreTokens()) {
            tmpLang = tokenizer.nextToken();

    %><option value="<%=tmpLang%>"<%if (tmpLang.equalsIgnoreCase(sPrintLanguage)){out.print(" selected");}%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
      }

      %>
      </select>
    <%
        if ((activeUser.getAccessRight("occup.physioconsultation.add")) || (activeUser.getAccessRight("occup.physioconsultation.edit"))){
            %>
                <INPUT class="button" type="button" name="SaveAndPrint" value="<%=getTran("Web.Occup","medwan.common.record-and-print",sWebLanguage)%>" onclick="doSave(true);"/>
                <INPUT class="button" type="button" name="save" id="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm();"/>
            <%
        }
    %>
            <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="doBack();">
        </td>
    </tr>
</table>
</td>
<td valign="top">
        	<%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncoding.jsp"),pageContext);%>
</td>
</tr>
</table>
<%=ScreenHelper.contextFooter(request)%>
<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
    document.transactionForm.save.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  <%-- DO BACK --%>
  function doBack(){
    if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){
      window.location.href = '<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';
    }
  }

    <%-- DO SAVE --%>
  function doSave(printDocument){
    if(printDocument){
      document.all['be.mxs.healthrecord.updateTransaction.actionForwardKey'].value = "/healthrecord/editTransaction.do?ForwardUpdateTransactionId=true&printPDF=true&PrintLanguage="+transactionForm.PrintLanguage.value+"&ts=<%=getTs()%>";
      window.open("","newwindow","height=600, width=850, toolbar=yes, status=yes, scrollbars=yes, resizable=yes, menubar=yes");
      document.transactionForm.target = 'newwindow';
    }

    submitForm();
  }

  <%-- CREATE OFFICIAL PDF --%>
  function createOfficialPdf(printLang){
    var tranID   = "<%=checkString(request.getParameter("be.mxs.healthrecord.transaction_id"))%>";
    var serverID = "<%=checkString(request.getParameter("be.mxs.healthrecord.server_id"))%>";

    window.location.href = "<%=sCONTEXTPATH%>/healthrecord/createOfficialPdf.jsp?tranAndServerID_1="+tranID+"_"+serverID+"&PrintLanguage="+printLang+"&ts=<%=getTs()%>";

    window.opener.document.transactionForm.save.disabled = false;
    window.opener.document.transactionForm.SaveAndPrint.disabled = false;
    window.opener.bSaveHasNotChanged = true;
    window.opener.location.reload();
    window.opener.location.href = "main.do?Page=curative/index.jsp&ts=<%=getTs()%>";
  }

  <%
      boolean printPDF = checkString(request.getParameter("printPDF")).equals("true");
      if(printPDF){
          %>createOfficialPdf('<%=sPrintLanguage%>');<%
      }
  %>
</script>
</form>
<%=writeJSButtons("transactionForm","save")%>