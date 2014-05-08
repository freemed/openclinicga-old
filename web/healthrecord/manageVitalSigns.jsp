<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.vitalsigns","select",activeUser)%>
<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <script>
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
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>
                    <tr>
                        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.cardial.frequence-cardiaque",sWebLanguage)%></td>
                        <td class="admin2" colspan="3"><input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY" property="value"/>" onblur="setHF(this);"> /min
                            <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH")%> type="radio" onDblClick="uncheckRadio(this);" id="sum_r1a" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH" property="itemId"/>]>.value" value="medwan.healthrecord.cardial.regulier" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH;value=medwan.healthrecord.cardial.regulier" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.healthrecord.cardial.regulier",sWebLanguage,"sum_r1a")%>
                            <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH")%> type="radio" onDblClick="uncheckRadio(this);" id="sum_r1b" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH" property="itemId"/>]>.value" value="medwan.healthrecord.cardial.irregulier" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH;value=medwan.healthrecord.cardial.irregulier" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.healthrecord.cardial.irregulier",sWebLanguage,"sum_r1b")%>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.cardial.pression-arterielle",sWebLanguage)%></td>
                        <td class="admin2" nowrap>
                            <%=getTran("Web.Occup","medwan.healthrecord.cardial.bras-droit",sWebLanguage)%>
                            <input id="sbpr" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> /
                            <input id="dbpr" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> mmHg
                            &nbsp;
                            <%=getTran("Web.Occup","medwan.healthrecord.cardial.bras-gauche",sWebLanguage)%>
                            <input id="sbpl" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="value"/>" onblur="setBP(this,'sbpl','dbpl');"> /
                            <input id="dbpl" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="value"/>" onblur="setBP(this,'sbpl','dbpl');"> mmHg
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("openclinic.chuk","temperature",sWebLanguage)%></td>
                        <td colspan="3" class="admin2">
                            <input type="text" class="text" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TEMPERATURE" property="value"/>" onBlur="if(isNumber(this)){if(!checkMinMaxOpen(0,45,this)){alertDialog('Web.Occup','medwan.common.unrealistic-value');}}" size="5"/>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("openclinic.chuk","respiratory.frequency",sWebLanguage)%></td>
                        <td colspan="3" class="admin2">
                            <input type="text" class="text" <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_RESPIRATORY_FRENQUENCY" property="value"/>" onBlur="isNumber(this)" size="5"/> /min
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("Web.Occup","Smoking",sWebLanguage)%></td>
                        <td class="admin2" colspan="3">
                            <select <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_TOBACCO_USAGE")%> id="EditSmoking" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_TOBACCO_USAGE" property="itemId"/>]>.value" class="text">
                                <option/>
                                <option value="1">0</option>
                                <option value="2">0 - 5</option>
                                <option value="3">5 - 10</option>
                                <option value="4">10 - 15</option>
                                <option value="5">15 - 25</option>
                                <option value="6">&gt; 25</option>
                            </select>
                            &nbsp;&nbsp;<%=getTran("Web.Occup","ADay",sWebLanguage)%>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.psycho.alcohol",sWebLanguage)%></td>
                        <td class="admin2" colspan="3">
                            <select <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_ALCOHOL_USAGE")%> id="EditAlcohol" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_ALCOHOL_USAGE" property="itemId"/>]>.value" class="text">
                                <option></option>
                                <option value="ce.alcohol.usage.none"><%=getTran("Web.Occup","ce.alcohol.usage.none",sWebLanguage)%></option>
                                <option value="ce.alcohol.usage.weekend"><%=getTran("Web.Occup","ce.alcohol.usage.weekend",sWebLanguage)%></option>
                                <option value="ce.alcohol.usage.social"><%=getTran("Web.Occup","ce.alcohol.usage.social",sWebLanguage)%></option>
                                <option value="ce.alcohol.usage.occasional"><%=getTran("Web.Occup","ce.alcohol.usage.occasional",sWebLanguage)%></option>
                                <option value="ce.alcohol.usage.1_a_day"><%=getTran("Web.Occup","ce.alcohol.usage.1_a_day",sWebLanguage)%></option>
                                <option value="ce.alcohol.usage.2_a_day"><%=getTran("Web.Occup","ce.alcohol.usage.2_a_day",sWebLanguage)%></option>
                                <option value="ce.alcohol.usage.3_a_day"><%=getTran("Web.Occup","ce.alcohol.usage.3_a_day",sWebLanguage)%></option>
                                <option value="ce.alcohol.usage.more_than_3_a_day"><%=getTran("Web.Occup","ce.alcohol.usage.more_than_3_a_day",sWebLanguage)%></option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.anamnese.general.sports",sWebLanguage)%></td>
                        <td class="admin2" colspan="3">
                            <select <%=setRightClick("ITEM_TYPE_CE_ANAMNESE_SPORT")%> id="EditSports" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CE_ANAMNESE_SPORT" property="itemId"/>]>.value" class="text">
                                <option/>
                                <option value="1">0</option>
                                <option value="2">0 - 1</option>
                                <option value="3">1 - 2</option>
                                <option value="4">2 - 3</option>
                                <option value="5">3 - 4</option>
                                <option value="6">&gt; 4</option>
                            </select>
                            &nbsp;&nbsp;<%=getTran("Web.Occup","hoursAWeek",sWebLanguage)%>
                            <input <%=setRightClick("[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS")%> type="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS" property="itemId"/>]>.value" class="text" size="40" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.[GENERAL.ANAMNESE]ITEM_TYPE_SPORTS" property="value"/>" onblur="limitLength(this);">
                        </td>
                    </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_WEIGHT")%> id="weight" class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="value"/>" onBlur="validateWeight();calculateBMI();"/></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_HEIGHT")%> class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>" onBlur="validateHeight(this);calculateBMI();"/></td>
        </tr>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.bmi",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input tabindex="-1" class="text" type="text" size="10" readonly name="BMI"></td>
        </tr>
        <%-- BUTTONS --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">&nbsp;</td>
            <td class="admin2">
                <%=getButtonsHtml(request,activeUser,activePatient,"occup.protocol.colonoscopy",sWebLanguage)%>
            </td>
        </tr>
    </table>
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  calculateBMI();
  if(document.getElementById("transactionId").value<=0){
     document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value')[0].value='<%=MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid),"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT")%>';
  }
  <%-- SUBMIT FORM --%>
  function submitForm(){
    var temp = Form.findFirstElement(transactionForm); // for ff compatibility
    document.getElementById("buttonsDiv").style.visibility = "hidden";
    document.transactionForm.submit();
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>