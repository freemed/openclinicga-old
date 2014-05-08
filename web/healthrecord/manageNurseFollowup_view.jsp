<%@page import="be.openclinic.medical.Problem,
                java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("occup.nursefollowup","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false,activeUser,(TransactionVO)transaction)%>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp?ts=<%=getTs()%>"/>

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

      if(isNaN(weightInput.value) || weightInput.value < min || weightInput.value > max){
    	alertDialogMessage("<%=weightMsg%>");
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

      if(isNaN(heightInput.value) || heightInput.value < min || heightInput.value > max){
        alertDialogMessage("<%=heightMsg%>");
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
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="3">
                <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'> <script>writeTranDate();</script>
            </td>
        </tr>
        
        <%-- PROBLEMS ---------------------------------------------------------------------------%>
        <tr>
            <td class="admin" style="vertical-align:top;padding-top:3px;"><%=getTran("openclinic.chuk","problems",sWebLanguage)%></td>
            <td class="admin2" style="vertical-align:top;padding-top:3px;">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NURSE_PROBLEMS")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_PROBLEMS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_PROBLEMS" property="value"/></textarea>
            </td>
            <td colspan="2">
                <%-- PROBLEM LIST --%>
                <table width="100%">
                    <tr class="admin">
                        <td align="center" colspan='2'><a href="javascript:showProblemlist();"><%=getTran("web.occup","medwan.common.problemlist",sWebLanguage)%></a></td>
                    </tr>
                    <tr>
                        <td colspan="2" id="problemList">
                            <%
                                Vector activeProblems = Problem.getActiveProblems(activePatient.personid);
                                if(activeProblems.size() > 0){
                                    out.print("<table width='100%' cellspacing='1' cellpadding='0'><tr class='gray'><td>"+getTran("web.occup","medwan.common.description",sWebLanguage)+"</td><td width='100'>"+getTran("web.occup","medwan.common.datebegin",sWebLanguage)+"</td></tr>");

                                    String sClass = "1";
	                                for(int n=0;n<activeProblems.size();n++){
	                                    if(sClass.equals("")) sClass = "1";
	                                    else                  sClass = "";
	
	                                    Problem activeProblem = (Problem)activeProblems.elementAt(n);
	                                    String comment = "";
	                                    if(activeProblem.getComment().trim().length()>0){
	                                        comment = ":&nbsp;<i>"+activeProblem.getComment().trim()+"</i>";
	                                    }
	                                    out.print("<tr class='list" + sClass + "'><td><b>"+(activeProblem.getCode()+" "+MedwanQuery.getInstance().getCodeTran(activeProblem.getCodeType()+"code"+activeProblem.getCode(),sWebLanguage)+"</b>"+comment)+"</td><td>"+ScreenHelper.stdDateFormat.format(activeProblem.getBegin())+"</td></tr>");
	                                }
	                                
	                                out.print("</table>");
	                            }
                            %>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        
        <%-- ATTITUDE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","interventions.attitude",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NURSE_INTERVENTIONS")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_INTERVENTIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_INTERVENTIONS" property="value"/></textarea>
            </td>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("openclinic.chuk","observations",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_NURSE_OBSERVATIONS")%> class="text" cols="60" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_OBSERVATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_OBSERVATIONS" property="value"/></textarea>
            </td>
        </tr>
        
        <%-- VITAL SIGNS ----------------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","vital.signs",sWebLanguage).toUpperCase()%></td>
        </tr>
        
        <%-- TEMPERATURE --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","temperature",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_BIOMETRY_TEMPERATURE")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_TEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_TEMPERATURE" property="value"/>"> °C
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","bloodpressure",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="value"/>">
                 / <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="value"/>"> mmHg
            </td>
        </tr>
        
        <%-- HEART FREQUENCY --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","heartfrequency",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY" property="value"/>"> /min
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","respiration",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_BIOMETRY_RESPIRATION")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_RESPIRATION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_RESPIRATION" property="value"/>"> /min
            </td>
        </tr>
        
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","sao2",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_SURV_SAO2")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_SAO2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_SAO2" property="value"/>"> %
            </td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- URINE ---------------------------------------------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="4"><%=getTran("Web.Occup",sPREFIX+"TRANSACTION_TYPE_URINE_EXAMINATION",sWebLanguage).toUpperCase()%></td>
        </tr>
        <tr>
            <%-- ALBUMINE --%>
            <td class='admin'>
                <%=getTran("Web.Occup","medwan.healthrecord.urine-exam.albumine",sWebLanguage)%>&nbsp;
            </td>
            <td class='admin2'>
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
            <td class='admin'>
                <%=getTran("Web.Occup","medwan.healthrecord.urine-exam.glucose",sWebLanguage)%>&nbsp;
            </td>
            <td class='admin2'>
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
        </tr>
        
        <tr>
            <%-- BLOOD --%>
            <td class='admin'>
                <%=getTran("Web.Occup","medwan.healthrecord.urine-exam.blood",sWebLanguage)%>&nbsp;
            </td>
            <td class='admin2'>
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
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- BIOMETRY -------------------------------------------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="4"><%=getTran("Web.Occup",sPREFIX+"TRANSACTION_TYPE_BIOMETRY",sWebLanguage).toUpperCase()%></td>
        </tr>
        
        <%-- WEIGHT --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_WEIGHT")%> id="weight" class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="value"/>" onBlur="validateWeight();calculateBMI();"/></td>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.length",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_HEIGHT")%> class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>" onBlur="validateHeight(this);calculateBMI();"/></td>
        </tr>
        
        <%-- BMI --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.biometry.bmi",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'><input tabindex="-1" class="text" type="text" size="10" readonly name="BMI"></td>
            <td class="admin"/>
            <td class="admin2"/>
        </tr>

        <%-- OTHER ------------------------------------------------------------------------------%>
        <tr class="admin">
            <td colspan="4"><%=getTran("openclinic.chuk","other",sWebLanguage).toUpperCase()%></td>
        </tr>
        
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","diuresis.24h",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_NURSE_DIURESIS24")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_DIURESIS24" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_DIURESIS24" property="value"/>"> ml
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","vomiting",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_SURV_VOMITING")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_VOMITING" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_VOMITING" property="value"/>"> ml
            </td>
        </tr>
        
        <%-- POSITION CHANGE --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","position.change",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_SURV_POSITION")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_POSITION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_POSITION" property="value"/>">
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","stool",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_SURV_STOOL")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_STOOL" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_STOOL" property="value"/>">
            </td>
        </tr>
        
        <%-- TUBEFEEDING --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","tubefeeding",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_NURSE_TUBEFEEDING")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_TUBEFEEDING" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NURSE_TUBEFEEDING" property="value"/>">
            </td>
            <td class="admin"><%=getTran("openclinic.chuk","toilet",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_SURV_TOILET")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_TOILET" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_TOILET" property="value"/>">
            </td>
        </tr>
        
        <%-- BEDSORE --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","bedsore.prevention",sWebLanguage)%></td>
            <td class="admin2">
                <input <%=setRightClick("ITEM_TYPE_SURV_SCARR")%> type="text" class="text" size="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_SCARR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SURV_SCARR" property="value"/>">
            </td>
            <td class="admin2" colspan="2"/>
        </tr>
    </table>
            
	<%-- BUTTONS --%>
	<%=ScreenHelper.alignButtonsStart()%>
	    <%=getButtonsHtml(request,activeUser,activePatient,"occup.nursefollowup",sWebLanguage)%>
	<%=ScreenHelper.alignButtonsStop()%>
	
    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  calculateBMI();

  <%-- SUBMIT FORM --%>
  function submitForm(){
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }
  
  <%-- SHOW PROBLEM LIST --%>
  function showProblemlist(){
	var url = "<c:url value='/popup.jsp'/>?Page=medical/manageProblems.jsp&ts=<%=getTs()%>";
    window.open(url,"Popup","toolbar=no,status=no,scrollbars=yes,resizable=yes,width=1,height=1,menubar=no").moveBy(2000,2000);
  }
</script>

<%=writeJSButtons("transactionForm","saveButton")%>