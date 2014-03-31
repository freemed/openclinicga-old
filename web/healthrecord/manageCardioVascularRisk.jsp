<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%!
    //--- GET LAST ITEM VALUE ---------------------------------------------------------------------
    private String getLastItemValue(javax.servlet.http.HttpServletRequest request, String itemType){
        try{
            SessionContainerWO sessionContainerWO= (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
            if(sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue()<0){
                // New transaction, find last values
                return MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(((AdminPerson)(request.getSession().getAttribute("activePatient"))).personid),itemType);
            }
            else{
                // Existing transaction, return active values
                ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(itemType);
                if(item != null && item.getValue()!=null){
                    return item.getValue();
                }
            }
        }
        catch(Exception e){
            e.printStackTrace();
        }

        return "";
    }
%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false, activeUser, (TransactionVO)transaction) %>

    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.jsp?Page=curative/index.jsp&ts=<%=getTs()%>"/>

    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <script>
      function submitForm(){
        document.transactionForm.saveButton.disabled = true;
        <%
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
            out.print(takeOverTransaction(sessionContainerWO,activeUser,"document.transactionForm.submit();"));
        %>
      }
    </script>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="20%">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" onblur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- SYSTOLIC PRESSURE --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup",sPREFIX+"item_type_recruitment_sce_sbp",sWebLanguage)%></td>
            <td class="admin2" nowrap>
                <input id="sbpr" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<%=getLastItemValue(request,sPREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")%>" onblur="setBP(this);"> mmHg
            </td>
        </tr>

        <%-- CHOLESTEROL --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.laboratory-examinations.blood.totale-cholesterol",sWebLanguage)%></td>
            <td class="admin2" nowrap>
                <input id="chol" <%=setRightClick("ext_medidoc_57131a.b")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.iconstants.ext_medidoc_57131a.b" property="itemId"/>]>.value" value="<%=getLastItemValue(request,sPREFIX+"ext_medidoc_57131a.b")%>" onblur="setCholesterol(this);"> mg/dl
            </td>
        </tr>

        <%-- SMOKING ? --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","Smoking",sWebLanguage)%></td>
            <td class="admin2">
                <input id="smoker" type="radio" onDblClick="uncheckRadio(this);" <%=setRightClick("ITEM_TYPE_CE_ROKER")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ROKER" property="itemId"/>]>.value" <%=getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_ROKER").equalsIgnoreCase("healthrecord.ce.smoker")?"checked":""%> value="healthrecord.ce.smoker" onclick="showCardio()">
                <%=getLabel("Web.Occup","healthrecord.ce.smoker",sWebLanguage, "smoker")%>&nbsp;
                <input id="nonsmoker" type="radio" onDblClick="uncheckRadio(this);" <%=setRightClick("ITEM_TYPE_CE_ROKER")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ROKER" property="itemId"/>]>.value" <%=getLastItemValue(request,sPREFIX+"ITEM_TYPE_CE_ROKER").equalsIgnoreCase("healthrecord.ce.not_smoker")?"checked":""%> value="healthrecord.ce.not_smoker" onclick="showCardio()">
                <%=getLabel("Web.Occup","healthrecord.ce.not_smoker",sWebLanguage, "nonsmoker")%>
            </td>
        </tr>

        <%-- NOTICED PHYSICIAN --%>
        <tr>
            <td class="admin"><%=getTran("Web.occup","noticed_physician",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIOVASCULAR_RISK_NOTICED_PHYSICIAN")%> type="checkbox" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIOVASCULAR_RISK_NOTICED_PHYSICIAN" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIOVASCULAR_RISK_NOTICED_PHYSICIAN;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true">
            </td>
        </tr>

        <%-- COMMENT --%>
        <tr>
            <td class="admin"><%=getTran("Web","Comment",sWebLanguage)%></td>
            <td class="admin2">
                <textarea id="comment" onkeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_CARDIOVASCULAR_RISK_COMMENT")%> class="text" cols="80" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIOVASCULAR_RISK_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIOVASCULAR_RISK_COMMENT" property="value"/></textarea>
            </td>
        </tr>    

        <%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2" colspan="3">
                <input class="button" type="button" name="ButtonCalculateCardio" value="<%=getTran("Web.Occup","calculate",sWebLanguage)%>" onclick="calculateRisk();"/>&nbsp;
            </td>
        </tr>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>                    
	    <%=getButtonsHtml(request,activeUser,activePatient,"",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>
        
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  function doBack(){
    if(checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){
      window.location.href='<c:url value="/main.jsp?Page=curative/index.jsp&ts="/><%=getTs()%>';
    }
  }

  function calculateRisk(){
    var smoker='no';
    if(document.getElementById('smoker').checked){
      smoker='yes';
    }

    if(document.getElementById("sbpr").value.length==0){
      alertDialogMessage("<%=getTran("web.manage","datamissing",sWebLanguage)%> (<%=getTran("Web.Occup",sPREFIX+"item_type_recruitment_sce_sbp",sWebLanguage)%>)");
      document.getElementById("sbpr").focus();
      return 0;
    }
    else if(document.getElementById("chol").value.length==0){
      alertDialogMessage("<%=getTran("web.manage","datamissing",sWebLanguage)%> (<%=getTran("Web.Occup","medwan.healthrecord.laboratory-examinations.blood.totale-cholesterol",sWebLanguage)%>)");
      document.getElementById("chol").focus();
      return 0;
    }
    
    var url = "<c:url value="/healthrecord/viewCardioVascularRiskBelgium.jsp"/>"+
              "?Action=ShowCardio"+
              "&smoker="+smoker+
              "&chol="+document.getElementById("chol").value+
              "&syst="+document.getElementById("sbpr").value+
              "&comment="+document.getElementById("comment").value;
    window.open(url,"CardioVacularRisk","toolbar=no,status=no,scrollbars=yes,resizable=yes,width=1,height=1,menubar=yes");
  }

  <%-- set bloodpressure --%>
  <%
      int minBP = 40;
      int maxBP = 300;

      String outOfBoundsMsgBP = getTran("Web.Occup","out-of-bounds-value-minmax",sWebLanguage);
      outOfBoundsMsgBP = outOfBoundsMsgBP.replaceAll("#min#",minBP+"");
      outOfBoundsMsgBP = outOfBoundsMsgBP.replaceAll("#max#",maxBP+"");
  %>
  function setBP(obj){
    if(!isNumberLimited(obj,<%=minBP%>,<%=maxBP%>)){
      alertDialogMessage("<%=outOfBoundsMsgBP%>");
    }
  }

  <%-- set cholesterol --%>
  <%
      int minChol = 0;
      int maxChol = 1000;

      String outOfBoundsMsgChol = getTran("Web.Occup","out-of-bounds-value-minmax",sWebLanguage);
      outOfBoundsMsgChol = outOfBoundsMsgChol.replaceAll("#min#",minChol+"");
      outOfBoundsMsgChol = outOfBoundsMsgChol.replaceAll("#max#",maxChol+"");
  %>
  function setCholesterol(obj){
    if(!isNumberLimited(obj,<%=minChol%>,<%=maxChol%>)){
      alertDialogMessage("<%=outOfBoundsMsgChol%>");
    }
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>