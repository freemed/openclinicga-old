<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.other","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/editTransaction.do?be.mxs.healthrecord.createTransaction.transactionType=<bean:write name="transaction" scope="page" property="transactionType"/>&be.mxs.healthrecord.transaction_id=currentTransaction&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

<script>
  function setTrue(itemType){
    var fieldName;
    fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.getElementsByName(fieldName)[0].value = "medwan.common.true";
  }

  function setFalse(itemType){
    var fieldName;
    fieldName = "currentTransactionVO.items.<ItemVO[hashCode="+itemType+"]>.value";
    document.getElementsByName(fieldName)[0].value = "medwan.common.false";
  }

  <%-- VALIDATE WEIGHT --%>
  <%
      int minWeight = 35;
      int maxWeight = 160;

      String weightMsg = getTran("Web.Occup","medwan.healthrecord.biometry.weight.validationerror",sWebLanguage);
      weightMsg = weightMsg.replaceAll("#min#",minWeight+"");
      weightMsg = weightMsg.replaceAll("#max#",maxWeight+"");
  %>
  function validateWeight(weightInput){
    weightInput.value = weightInput.value.replace(",",".");
    if(weightInput.value.length > 0){
      var min = <%=minWeight%>;
      var max = <%=maxWeight%>;

      if (isNaN(weightInput.value) || weightInput.value < min || weightInput.value > max){
        alert("<%=weightMsg%>");
        //weightInput.value = "";
        weightInput.focus();
      }
    }
  }

  <%-- VALIDATE HEIGHT --%>
  <%
      int minHeight = 120;
      int maxHeight = 220;

      String heightMsg = getTran("Web.Occup","medwan.healthrecord.biometry.height.validationerror",sWebLanguage);
      heightMsg = heightMsg.replaceAll("#min#",minHeight+"");
      heightMsg = heightMsg.replaceAll("#max#",maxHeight+"");
  %>
  function validateHeight(heightInput){
    heightInput.value = heightInput.value.replace(",",".");
    if(heightInput.value.length > 0){
      var min = <%=minHeight%>;
      var max = <%=maxHeight%>;

      if (isNaN(heightInput.value) || heightInput.value < min || heightInput.value > max){
        alert("<%=heightMsg%>");
        heightInput.focus();
      }
    }
  }

  <%-- CALCULATE BMI --%>
  function calculateBMI(){
    var _BMI = 0;
    var heightInput = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value')[0];
    var weightInput = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="itemId"/>]>.value')[0];

    if (heightInput.value > 0){
      _BMI = (weightInput.value * 10000) / (heightInput.value * heightInput.value);
      if (_BMI > 100 || _BMI < 5){
        document.getElementsByName('BMI')[0].value = "";
      }
      else {
        document.getElementsByName('BMI')[0].value = Math.round(_BMI*10)/10;
      }
    }
  }
</script>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="5">
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
        <%-- AV ------------------------------------------------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="7"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" valign="baseline">
               <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle",sWebLanguage)%>&nbsp;
            </td>
            <td class="admin2" colspan="5">
                <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_NORMAL")%> type="checkbox" id="nex-c1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_NORMAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_NORMAL;value=medwan.healthrecord.ophtalmology.acuite-visuelle.normale" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.normale" >
                <%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle.normale",sWebLanguage,"nex-c1")%>
                  &nbsp;&nbsp;&nbsp;&nbsp;
                <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES")%> type="checkbox" id="nex-c2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_GLASSES;value=medwan.healthrecord.ophtalmology.acuite-visuelle.lunettes" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.lunettes" >
                <%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle.lunettes",sWebLanguage,"nex-c2")%>
                  &nbsp;&nbsp;&nbsp;&nbsp;
                <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT")%> type="checkbox" id="nex-c3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_CONTACT;value=medwan.healthrecord.ophtalmology.acuite-visuelle.verres-de-contact" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.verres-de-contact" >
                <%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle.verres-de-contact",sWebLanguage,"nex-c3")%>
                 &nbsp;&nbsp;&nbsp;&nbsp;
                <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK")%> type="checkbox" id="nex-c4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_LASIK;value=medwan.healthrecord.ophtalmology.acuite-visuelle.LASIK" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.LASIK" >
               <%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle.LASIK",sWebLanguage,"nex-c4")%>
                  &nbsp;&nbsp;&nbsp;&nbsp;
                <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY")%> type="checkbox" id="nex-c5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_KERATOTOMY;value=medwan.healthrecord.ophtalmology.acuite-visuelle.keratotomie" property="value" outputString="checked"/> value="medwan.healthrecord.ophtalmology.acuite-visuelle.keratotomie" >
                <%=getLabel("Web.Occup","medwan.healthrecord.ophtalmology.acuite-visuelle.keratotomie",sWebLanguage,"nex-c5")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.tests",sWebLanguage)%></td>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.No",sWebLanguage)%></td>
            <td class="admin" colspan="2"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.OD",sWebLanguage)%></td>
            <td class="admin" colspan="2"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.OG",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin" rowspan="2"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.Acuite-VL",sWebLanguage)%></td>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.20-OD",sWebLanguage)%></td>
            <td class="admin2" colspan="2">
                <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                &#47;10
                <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.SANS-verres-2",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="2">
                <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                &#47;10
                <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.SANS-verres-2",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.21-OG",sWebLanguage)%></td>
            <td class="admin2" colspan="2"><input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OD_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                &#47;10
                <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.AVEC-verres-2",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="2">
                <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_OG_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                &#47;10
                <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.AVEC-verres-2",sWebLanguage)%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.Acuite-binoculaire-VL",sWebLanguage)%></td>
            <td class="admin">2</td>
            <td class="admin2" colspan="4">
                <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITHOUT_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                &#47;10
                <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.SANS-verres-2",sWebLanguage)%>
                <br><br>
                <input <%=setRightClick("ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPTHALMOLOGY_VISION_BONI_WITH_GLASSES" property="value"/>" class="text" size="1" onblur="isNumber(this)">
                &#47;10
                <%=getTran("Web.Occup","medwan.healthrecord.ophtalmology.AVEC-verres-2",sWebLanguage)%>
            </td>
        </tr>
        <%-- URINE ---------------------------------------------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="7"><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_URINE_EXAMINATION",sWebLanguage)%></td>
        </tr>
        <tr>
            <%-- ALBUMINE --%>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.urine-exam.albumine",sWebLanguage)%>&nbsp;</td>
            <td class='admin2' width="16%">
                <select <%=setRightClick("ITEM_TYPE_URINE_ALBUMINE")%> class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE" property="itemId"/>]>.value" class="text">
                    <option value="medwan.common.not-executed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE;value=medwan.common.not-executed" property="value" outputString="selected"/> >
                    <option value="medwan.common.negative" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE;value=medwan.common.negative" property="value" outputString="selected"/> onclick='_A="-"' ><%=getTran("Web.Occup","medwan.common.negative",sWebLanguage)%>
                    <option value="30" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE;value=30" property="value" outputString="selected"/> onclick='_A="30"'>30
                    <option value="100" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE;value=100" property="value" outputString="selected"/> onclick='_A="100"'>100
                    <option value="500" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE;value=500" property="value" outputString="selected"/> onclick='_A="500"'>500
                </select>
                mg/dl
            </td>
            <%-- GLUCOSE --%>
            <td class='admin' width="16%"><%=getTran("Web.Occup","medwan.healthrecord.urine-exam.glucose",sWebLanguage)%>&nbsp;</td>
            <td class='admin2' width="16%">
                <select <%=setRightClick("ITEM_TYPE_URINE_GLUCOSE")%> class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE" property="itemId"/>]>.value" class="text">
                    <option value="medwan.common.not-executed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=medwan.common.not-executed" property="value" outputString="selected"/> >
                    <option value="medwan.common.negative" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=medwan.common.negative" property="value" outputString="selected"/> onclick='_G="-"'><%=getTran("Web.Occup","medwan.common.negative",sWebLanguage)%>
                    <option value="50" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=50" property="value" outputString="selected"/> onclick='_G="50"'>50
                    <option value="100" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=100" property="value" outputString="selected"/> onclick='_G="100"'>100
                    <option value="300" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=300" property="value" outputString="selected"/> onclick='_G="300"'>300
                    <option value="1000" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=1000" property="value" outputString="selected"/> onclick='_G="1000"'>1000
                </select>
                mg/dl
            </td>
            <%-- BLOOD --%>
            <td class='admin' width="16%"><%=getTran("Web.Occup","medwan.healthrecord.urine-exam.blood",sWebLanguage)%>&nbsp;</td>
            <td class='admin2' width="*">
                <select <%=setRightClick("ITEM_TYPE_URINE_BLOOD")%> class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD" property="itemId"/>]>.value" class="text">
                    <option value="medwan.common.not-executed" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=medwan.common.not-executed" property="value" outputString="selected"/> >
                    <option value="medwan.common.negative" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=medwan.common.negative" property="value" outputString="selected"/> onclick='_B="-"'><%=getTran("Web.Occup","medwan.common.negative",sWebLanguage)%>
                    <option value="5-10" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=5-10" property="value" outputString="selected"/> onclick='_B="5-10"'>5-10
                    <option value="25" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=25" property="value" outputString="selected"/> onclick='_B="25"'>25
                    <option value="50" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=50" property="value" outputString="selected"/> onclick='_B="50"'>50
                    <option value="250" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=250" property="value" outputString="selected"/> onclick='_B="250"'>250
                </select>
                ery/µl
            </td>
        </tr>
        <%-- BIOMETRY -------------------------------------------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="6"><%=getTran("Web.Occup","be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_BIOMETRY",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_WEIGHT")%> id="weight" class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="value"/>" onBlur="validateWeight();calculateBMI();"/></td>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_HEIGHT")%> class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>" onBlur="validateHeight(this);calculateBMI();"/></td>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.bmi",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input tabindex="-1" class="text" type="text" size="10" readonly name="BMI"></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.robustness-muscle",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input <%=setRightClick("ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="nex-r2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE" property="itemId"/>]>.value" value="medwan.common.Strong" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE;value=medwan.common.Strong" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.Strong",sWebLanguage,"nex-r2")%></td>
            <td class='admin2'><input <%=setRightClick("ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="nex-r3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE" property="itemId"/>]>.value" value="medwan.common.Medium" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE;value=medwan.common.Medium" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.Medium",sWebLanguage,"nex-r3")%></td>
            <td class='admin2'><input <%=setRightClick("ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="nex-r4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE" property="itemId"/>]>.value" value="medwan.common.Fragile" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE;value=medwan.common.Fragile" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.Fragile",sWebLanguage,"nex-r4")%></td>
            <td class='admin2' colspan="2"><input <%=setRightClick("ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="nex-r5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE" property="itemId"/>]>.value" value="medwan.common.Insufficient" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_MUSSCLE_TYPE;value=medwan.common.Insufficient" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.Insufficient",sWebLanguage,"nex-r5")%></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.panicule-adipeux",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input <%=setRightClick("ITEM_TYPE_BIOMETRY_FAT_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="nex-r6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_FAT_TYPE" property="itemId"/>]>.value" value="medwan.common.Exaggerated" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_FAT_TYPE;value=medwan.common.Exaggerated" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.Exaggerated",sWebLanguage,"nex-r6")%></td>
            <td class='admin2'><input <%=setRightClick("ITEM_TYPE_BIOMETRY_FAT_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="nex-r7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_FAT_TYPE" property="itemId"/>]>.value" value="medwan.common.normal" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_FAT_TYPE;value=medwan.common.normal" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.normal",sWebLanguage,"nex-r7")%></td>
            <td class='admin2' colspan="3"><input <%=setRightClick("ITEM_TYPE_BIOMETRY_FAT_TYPE")%> type="radio" onDblClick="uncheckRadio(this);" id="nex-r8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_FAT_TYPE" property="itemId"/>]>.value" value="medwan.common.Insufficient" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_FAT_TYPE;value=medwan.common.Insufficient" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.Insufficient",sWebLanguage,"nex-r8")%></td>
        </tr>
        <%-- CARDIAL -------------------------------------------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="7"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.cardial",sWebLanguage)%></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.cardial.frequence-cardiaque",sWebLanguage)%></td>
            <td class='admin2' colspan="2"><input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY" property="value"/>" onBlur="if(isNumber(this)){if(!checkMinMaxOpen(30,220,this)){alertDialog('Web.Occup','medwan.common.unrealistic-value');}}"> /min</td>
            <td class='admin2'><input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH")%> type="radio" onDblClick="uncheckRadio(this);" id="nex-r9" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH" property="itemId"/>]>.value" value="medwan.healthrecord.cardial.regulier" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH;value=medwan.healthrecord.cardial.regulier" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.healthrecord.cardial.regulier",sWebLanguage,"nex-r9")%></td>
            <td class="admin2" colspan="2"><input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH")%> type="radio" onDblClick="uncheckRadio(this);" id="nex-r10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH" property="itemId"/>]>.value" value="medwan.healthrecord.cardial.irregulier" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH;value=medwan.healthrecord.cardial.irregulier" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.healthrecord.cardial.irregulier",sWebLanguage,"nex-r10")%></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.cardial.pression-arterielle",sWebLanguage)%></td>
            <%-- right --%>
            <td class='admin2'><%=getTran("Web.Occup","medwan.healthrecord.cardial.bras-droit",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="value"/>" onBlur="if(isNumber(this)){if(!checkMinMaxOpen(30,220,this)){alertDialog('Web.Occup','medwan.common.unrealistic-value');}}"> /
                <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="value"/>" onBlur="if(isNumber(this)){if(!checkMinMaxOpen(30,220,this)){alertDialog('Web.Occup','medwan.common.unrealistic-value');}}"> mmHg
            </td>
            <%-- left --%>
            <td class='admin2'><%=getTran("Web.Occup","medwan.healthrecord.cardial.bras-gauche",sWebLanguage)%></td>
            <td class="admin2" colspan="2">
                <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="value"/>" onBlur="if(isNumber(this)){if(!checkMinMaxOpen(30,220,this)){alertDialog('Web.Occup','medwan.common.unrealistic-value');}}"> /
                <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="value"/>" onBlur="if(isNumber(this)){if(!checkMinMaxOpen(30,220,this)){alertDialog('Web.Occup','medwan.common.unrealistic-value');}}"> mmHg
            </td>
        </tr>
    </table>
<%-- BUTTONS -------------------------------------------------------------------------------------%>
<%=ScreenHelper.alignButtonsStart()%>
<%
    if(activeUser.getAccessRight("occup.other.add") || activeUser.getAccessRight("occup.other.edit")) {
%>
        <INPUT class="button" type="button" name="saveButton" id="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onClick="submitForm();">
<%
    }
%>
    <INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="if(checkSaveButton()){window.location.href='<c:url value="/healthrecord/showPeriodicExaminations.do"/>?ts=<%=getTs()%>'}">
<%=ScreenHelper.alignButtonsStop()%>
<script>
  calculateBMI();

  function submitForm(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
    }
</script>
<%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","saveButton")%>