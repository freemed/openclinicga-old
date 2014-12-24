<%@page import="be.dpms.medwan.webapp.wo.common.system.SessionContainerWO,
                be.mxs.webapp.wl.session.SessionContainerFactory,java.util.StringTokenizer" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.reference","select",activeUser)%>
<%
    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
    supportedLanguages = supportedLanguages.toLowerCase();
%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
   
    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
  
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
 
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    
    <%-- ############################################### REFERENCE ################################################ --%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        
        <%-- Reference Centre --%>
        <%
            ItemVO item = ((TransactionVO)transaction).getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_REF_CENTR");
            String sCentre = "";
            if(item!=null) sCentre = item.getValue();
        %>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Occup","medwan.common.reference_centre",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <select class="text" <%=setRightClick("ITEM_TYPE_REFERENCE_REF_CENTR")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_REF_CENTR" property="itemId"/>]>.value">
                    <option><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelect("reference.referencecenter",sCentre,sWebLanguage)%>
                </select>
            </td>
        </tr>
        
        <%-- Anamnese--%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Occup","medwan.common.anamnese",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_REFERENCE_ANAMNESE")%> cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_ANAMNESE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_ANAMNESE" property="value"/></textarea>
            </td>
            
            <%-- Complementary exams--%>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Occup","medwan.common.complementary_exams",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_REFERENCE_EXAM_COMPL")%> cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_EXAM_COMPL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_EXAM_COMPL" property="value"/></textarea>
            </td>
        </tr>
        
        <%-- Treatment Recieved--%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.common.treatement_recieved",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_REFERENCE_TRAIT_RECU")%> cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_TRAIT_RECU" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_TRAIT_RECU" property="value"/></textarea>
            </td>
            
            <%-- Transfer reason--%>
            <td class="admin"><%=getTran("Web.Occup","medwan.common.transfer_reason",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_REFERENCE_RAISON_TRANSF")%> cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_RAISON_TRANSF" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_RAISON_TRANSF" property="value"/></textarea>
            </td>
        </tr>
        
       <tr>
            <td class="admin"/>
            <td class="admin2" colspan="3">
                <%=getTran("Web.Occup","PrintLanguage",sWebLanguage)%>
                <select class="text" name="PrintLanguageRef">
                    <%
                        String sPrintLanguage = checkString(request.getParameter("PrintLanguage"));
                        if (sPrintLanguage.length() == 0) {
                            sPrintLanguage = activePatient.language;
                        }

                        StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
                        String tmpLang;
                        while (tokenizer.hasMoreTokens()) {
                            tmpLang = tokenizer.nextToken();
                            tmpLang = tmpLang.toUpperCase();

                            %><option value="<%=tmpLang%>" <%=(sPrintLanguage.equalsIgnoreCase(tmpLang)?"selected":"")%>><%=tmpLang%></option><%
                        }
                    %>
                </select>

                <input class="button" type="button" name="SaveAndPrintRef" value="<%=getTranNoLink("Web.Occup","medwan.common.record-and-print",sWebLanguage)%>" onclick="doSave(true,'reference');"/>
           </td>
        </tr>
    </table>
    <br/>
    
    <%-- ############################################ CONTRA REFERENCE ############################################ --%>
    <table class="list" width="100%" cellspacing="1">
        <%-- title --%>
        <tr>
            <td colspan="4"><%=getTran("Web.Occup","medwan.common.contre_reference",sWebLanguage)%></td>
        </tr>
        
        <%-- Reference ID--%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.common.reference_id",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="text" class="text" <%=setRightClick("ITEM_TYPE_REFERENCE_ID_REF")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_ID_REF" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_ID_REF" property="value"/>">
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>
        
        <%-- Significal results--%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Occup","medwan.common.significal_results",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_REFERENCE_RESULTS_SIGNIF")%> cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_RESULTS_SIGNIF" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_RESULTS_SIGNIF" property="value"/></textarea>
            </td>
            
            <%-- Diagnostic--%>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.Occup","medwan.common.diagnostic",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_REFERENCE_DIAGN")%> cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_DIAGN" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_DIAGN" property="value"/></textarea>
            </td>
        </tr>
        
        <%-- treatment recieved and intervention--%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.common.treatment_received_intervention",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_REFERENCE_TRAIT_RECU_INTERV")%> cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_TRAIT_RECU_INTERV" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_TRAIT_RECU_INTERV" property="value"/></textarea>
            </td>
            
            <%-- Recommendations/treatment to follow--%>
            <td class="admin"><%=getTran("Web.Occup","medwan.common.recommendations_treatment_to_follow",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" <%=setRightClick("ITEM_TYPE_REFERENCE_RECOM_TRAIT_SUIVRE")%> cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_RECOM_TRAIT_SUIVRE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_RECOM_TRAIT_SUIVRE" property="value"/></textarea>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2" colspan="3">
                <%=getTran("Web.Occup","PrintLanguage",sWebLanguage)%>
                <select class="text" name="PrintLanguageContraRef">
                    <%
                        tokenizer = new StringTokenizer(supportedLanguages,",");
                        while(tokenizer.hasMoreTokens()){
                            tmpLang = tokenizer.nextToken();
                            tmpLang = tmpLang.toUpperCase();

                            %><option value="<%=tmpLang%>" <%=(sPrintLanguage.equalsIgnoreCase(tmpLang)?"selected":"")%>><%=tmpLang%></option><%
                        }
                    %>
                </select>
                
		        <%
		            if ((activeUser.getAccessRight("occup.reference.add")) || (activeUser.getAccessRight("occup.reference.edit"))){
		                %>
		                    <INPUT class="button" type="button" name="SaveAndPrintContraRef" value="<%=getTranNoLink("Web.Occup","medwan.common.record-and-print",sWebLanguage)%>" onclick="doSave(true,'contrareference');"/>
		                    <INPUT class="button" type="button" name="saveButton" id="save" value="<%=getTranNoLink("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm();"/>
		                <%
		            }
		        %>
                <INPUT class="button" type="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
    <input type="hidden" name="PrintLanguage">
</form>

<%=ScreenHelper.contextFooter(request)%>

<script>
  <%-- BACK --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = '<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';
    }
  }

  <%-- SUBMIT FORM --%>
  function submitForm(printLang){
    transactionForm.saveButton.disabled = true;
    document.transactionForm.PrintLanguage.value = printLang;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  <%-- DO SAVE --%>
  function doSave(printDocument,tranSubType){
    var maySubmit = true;
    var printLang;

    if(printDocument){
           if(tranSubType == "reference")       printLang = transactionForm.PrintLanguageRef.value;
      else if(tranSubType == "contrareference") printLang = transactionForm.PrintLanguageContraRef.value;

      document.getElementsByName('be.mxs.healthrecord.updateTransaction.actionForwardKey')[0].value = "/healthrecord/editTransaction.do?ForwardUpdateTransactionId=true&printPDF=true&ts=<%=getTs()%>&PrintLanguage="+printLang+"&tranSubType="+tranSubType;
      window.open("","_new","height=600, width=850, toolbar=yes, status=yes, scrollbars=yes, resizable=yes, menubar=yes");
      document.transactionForm.target = '_new';
    }

    submitForm(printLang);
  }

  <%-- CREATE OFFICIAL PDF --%>
  function createOfficialPdf(printLang,tranSubType){
    var tranID   = "<%=checkString(request.getParameter("be.mxs.healthrecord.transaction_id"))%>";
    var serverID = "<%=checkString(request.getParameter("be.mxs.healthrecord.server_id"))%>";

    window.location.href = "<%=sCONTEXTPATH%>/healthrecord/createOfficialPdf.jsp?tranAndServerID_1="+tranID+"_"+serverID+"&PrintLanguage="+printLang+"&tranSubType="+tranSubType+"&ts=<%=getTs()%>";

    window.opener.document.transactionForm.saveButton.disabled = false;
    window.opener.document.transactionForm.SaveAndPrintRef.disabled = false;
    window.opener.document.transactionForm.SaveAndPrintContraRef.disabled = false;
    window.opener.bSaveHasNotChanged = true;
    window.opener.location.reload();
    window.opener.location.href = "main.do?Page=curative/index.jsp&ts=<%=getTs()%>";
  }

  <%
      String sTranSubType = checkString(request.getParameter("tranSubType"));

      boolean printPDF = checkString(request.getParameter("printPDF")).equals("true");
      if(printPDF){
          %>createOfficialPdf('<%=sPrintLanguage%>','<%=sTranSubType%>');<%
      }
  %>
</script>
<%=writeJSButtons("transactionForm","saveButton")%>