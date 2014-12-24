<%@ page import="be.openclinic.system.Healthrecord" %>
<%@ page import="java.util.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.respiratoryfunction","select",activeUser)%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>

    <logic:present name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeBiometry">
        <bean:define id="lastTransaction_biometry" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeBiometry"/>
        <input type="hidden" readonly name="height" value="<mxs:propertyAccessorI18N name="lastTransaction_biometry.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>"/>
    </logic:present>

    <logic:notPresent name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="lastTransactionTypeBiometry">
        <input type="hidden" readonly name="height" value="0"/>
    </logic:notPresent>

    <bean:define id="patient" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="personVO"/>
    <bean:define id="flags" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="flags"/>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="gender" value="<mxs:propertyAccessorI18N name="patient" scope="page" property="gender"/>"/>
    <input type="hidden" readonly name="age" value="<%=MedwanQuery.getInstance().getAge(Integer.parseInt(activePatient.personid))%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="value"/>"/>
    <input type="hidden" name="alive" value="1"/>

<script>
  function submitForm(){
    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value')[0].value="FEV1:"+document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1" property="itemId"/>]>.value')[0].value+"L/"+document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1_A" property="itemId"/>]>.value')[0].value+"%  FVC:"+document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC" property="itemId"/>]>.value')[0].value+"L/"+document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC_A" property="itemId"/>]>.value')[0].value+"%";
    transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  <%-- CALCULATE PEF -----------------------------------------------------------------------------%>
  function calculatePEFPercent(){
    if (isNaN(parseFloat(document.getElementsByName('height')[0].value.replace(",","."))) || document.getElementsByName('height')[0].value==0) {
      return;
    }

    var PEFRef;
    var PEF = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_PEF" property="itemId"/>]>.value')[0].value.replace(',','.');
    if((document.getElementsByName('height')[0].value * document.getElementsByName('age')[0].value)>0){
      if (document.getElementsByName('gender')[0].value == 'M' || document.getElementsByName('gender')[0].value == 'm'){
        PEFRef = 0.97*(0.068*document.getElementsByName('height')[0].value-0.036*document.getElementsByName('age')[0].value)*60;
      }
      else {
        PEFRef = 0.97*(0.052*document.getElementsByName('height')[0].value-0.034*document.getElementsByName('age')[0].value)*60;
      }

      var PEFPCT = PEF*100/PEFRef;
      if (PEFPCT > 0){
        if (PEFPCT < 10) {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_PEF_A" property="itemId"/>]>.value')[0].value = PEFPCT.toString().substring(0,1)
        }
        else if (PEFPCT < 100) {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_PEF_A" property="itemId"/>]>.value')[0].value = PEFPCT.toString().substring(0,2)
        }
        else {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_PEF_A" property="itemId"/>]>.value')[0].value = PEFPCT.toString().substring(0,3)
        }
      }
      else {
        document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_PEF_A" property="itemId"/>]>.value')[0].value = "";
      }
    }
  }

  <%-- CALCULATE TIFFENEAU -----------------------------------------------------------------------%>
  function calculateTiffeneau(){
    var FEV1 = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1" property="itemId"/>]>.value')[0].value.replace(',','.');
    var VC   = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_VC" property="itemId"/>]>.value')[0].value.replace(',','.');

    if (FEV1.length==0 || isNaN(FEV1) || VC.length==0 || isNaN(VC) || VC==0){
        document.getElementsByName('Tiffeneau')[0].value = '';
        return;
    }

    document.getElementsByName('Tiffeneau')[0].value=FEV1/VC;
    document.getElementsByName('Tiffeneau')[0].value=document.getElementsByName('Tiffeneau')[0].value.substr(0,4);
  }

  <%-- CALCULATE VC ------------------------------------------------------------------------------%>
  function calculateVCPercent(){
    calculateTiffeneau();
    if (isNaN(parseFloat(document.getElementsByName('height')[0].value.replace(",","."))) || document.getElementsByName('height')[0].value==0){
      return;
    }

    var VCRef;
    var VC = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_VC" property="itemId"/>]>.value')[0].value.replace(',','.');
    if((document.getElementsByName('height')[0].value * document.getElementsByName('age')[0].value)>0){
      if (document.getElementsByName('gender')[0].value == 'M' || document.getElementsByName('gender')[0].value == 'm'){
        VCRef = 0.1626*0.39*document.getElementsByName('height')[0].value-0.031*document.getElementsByName('age')[0].value-5.335;
      }
      else {
        VCRef = 0.1321*0.39*document.getElementsByName('height')[0].value-0.018*document.getElementsByName('age')[0].value-4.360;
      }

      var VCPCT = VC*100/VCRef;
      if (VCPCT > 0){
        if (VCPCT < 10) {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_VC_A" property="itemId"/>]>.value')[0].value = VCPCT.toString().substring(0,1)
        }
        else if (VCPCT < 100) {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_VC_A" property="itemId"/>]>.value')[0].value = VCPCT.toString().substring(0,2)
        }
        else {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_VC_A" property="itemId"/>]>.value')[0].value = VCPCT.toString().substring(0,3)
        }
      }
      else {
        document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_VC_A" property="itemId"/>]>.value')[0].value = "";
      }
    }
  }

  <%-- CALCULATE FEV1 ----------------------------------------------------------------------------%>
  function calculateFEV1Percent(){
    calculateTiffeneau();
    if (isNaN(parseFloat(document.getElementsByName('height')[0].value.replace(",","."))) || document.getElementsByName('height')[0].value==0) {
      return;
    }

    var FEV1Ref;
    var FEV1 = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1" property="itemId"/>]>.value')[0].value.replace(',','.');
    if((document.getElementsByName('height')[0].value * document.getElementsByName('age')[0].value)>0){
      if (document.getElementsByName('gender')[0].value == 'M' || document.getElementsByName('gender')[0].value == 'm'){
        FEV1Ref = 1.08*(0.0443*document.getElementsByName('height')[0].value-0.026*document.getElementsByName('age')[0].value-2.89);
      }
      else {
        FEV1Ref = 1.08*(0.0395*document.getElementsByName('height')[0].value-0.025*document.getElementsByName('age')[0].value-2.60);
      }

      var FEV1PCT = FEV1*100/FEV1Ref;
      if (FEV1PCT > 0){
        if (FEV1PCT < 10) {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1_A" property="itemId"/>]>.value')[0].value = FEV1PCT.toString().substring(0,1)
        }
        else if (FEV1PCT < 100) {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1_A" property="itemId"/>]>.value')[0].value = FEV1PCT.toString().substring(0,2)
        }
        else {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1_A" property="itemId"/>]>.value')[0].value = FEV1PCT.toString().substring(0,3)
        }
      }
      else {
        document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1_A" property="itemId"/>]>.value')[0].value = "";
      }
    }
  }

  <%-- CALCULATE FVC -----------------------------------------------------------------------------%>
  function calculateFVCPercent(){
    if (isNaN(parseFloat(document.getElementsByName('height')[0].value.replace(",","."))) || document.getElementsByName('height')[0].value==0){
      return;
    }

    var FVCRef;
    var FVC = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC" property="itemId"/>]>.value')[0].value.replace(',','.');
    if((document.getElementsByName('height')[0].value * document.getElementsByName('age')[0].value)>0){
      if (document.getElementsByName('gender')[0].value == 'M'){
        FVCRef = 1.10*(0.0576*document.getElementsByName('height')[0].value-0.026*document.getElementsByName('age')[0].value-4.34);
      }
      else {
        FVCRef = 1.15*(0.0443*document.getElementsByName('height')[0].value-0.026*document.getElementsByName('age')[0].value-2.89);
      }

      var FVCPCT = FVC*100/FVCRef;
      if (FVCPCT > 0){
        if (FVCPCT < 10) {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC_A" property="itemId"/>]>.value')[0].value = FVCPCT.toString().substring(0,1)
        }
        else if (FVCPCT < 100) {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC_A" property="itemId"/>]>.value')[0].value = FVCPCT.toString().substring(0,2)
        }
        else {
          document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC_A" property="itemId"/>]>.value')[0].value = FVCPCT.toString().substring(0,3)
        }
      }
      else {
        document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC_A" property="itemId"/>]>.value')[0].value = "";
      }
    }
  }

  var today = new Date();
  var printDate = today.getDate()+"";
  if(printDate.length == 1){
    printDate = "0"+printDate;
  }

  var printMonth = (today.getMonth()+1)+"";
  if(printMonth.length == 1){
    printMonth = "0"+printMonth;
  }
</script>
<%
    //--- LENGTH ---
    Float rLength = new Float(0);
    Vector vRespiratoryFunctionLength = Healthrecord.getRespiratoryFunctionLengthData(activePatient.personid);
    Iterator iterLength = vRespiratoryFunctionLength.iterator();

    while (iterLength.hasNext()) {

        String sTmpLength = (String)iterLength.next();

        if (sTmpLength.length() > 0) {
            rLength = new Float(sTmpLength.replaceAll(",", "."));
            rLength = new Float(rLength.floatValue() / 100.0);
        }
    }

    //--- BIRTHDAY ---
    int iBirthday = 0;
    if (activePatient.dateOfBirth.trim().length() == 10) {
        iBirthday = Integer.parseInt(activePatient.dateOfBirth.substring(6));
    }

    //--- FEV1 ---
    boolean bFound = false;
    Vector vRespiratoryFunctionFev1 = new Vector();
    Iterator iterFev1 = vRespiratoryFunctionFev1.iterator();
    String sFEV1Date = "", sFEV1Value = "", sFEV1EndDate = "", sFEV1BeginDate = "";

    Hashtable hRespiratoryFunctionFev1;
    while (iterFev1.hasNext()) {
        hRespiratoryFunctionFev1 = (Hashtable) iterFev1.next();
        bFound = true;
        sFEV1EndDate = checkString(ScreenHelper.stdDateFormat.format((java.sql.Date) hRespiratoryFunctionFev1.get("updatetime")));
        if (sFEV1BeginDate.trim().length() == 0) {
            sFEV1BeginDate = sFEV1EndDate;
        }
        sFEV1Date += "'" + sFEV1EndDate + "',";
        sFEV1Value += "'" + hRespiratoryFunctionFev1.get("ow_value") + "',";
    }

    if (sFEV1Date.trim().length() > 0) {
        sFEV1Date = sFEV1Date.substring(0, sFEV1Date.length() - 1);
        sFEV1Value = sFEV1Value.substring(0, sFEV1Value.length() - 1);
    }

    //--- FVC ---
    String sFVCDate = "", sFVCValue = "", sFVCEndDate = "", sFVCBeginDate = "";

    Vector vRespiratoryFunctionFVC = new Vector();
    Iterator iterFVC = vRespiratoryFunctionFVC.iterator();

    Hashtable hRespiratoryFunctionFVC;

    while (iterFVC.hasNext()) {
        hRespiratoryFunctionFVC = (Hashtable) iterFVC.next();
        sFVCEndDate = checkString(ScreenHelper.stdDateFormat.format((java.sql.Date) hRespiratoryFunctionFVC.get("updatetime")));
        if (sFVCBeginDate.trim().length() == 0) {
            sFVCBeginDate = sFVCEndDate;
        }
        sFVCDate += "'" + sFVCEndDate + "',";
        sFVCValue += "'" + hRespiratoryFunctionFVC.get("ow_value") + "',";
    }

    if (sFVCDate.trim().length() > 0) {
        sFVCDate = sFVCDate.substring(0, sFVCDate.length() - 1);
        sFVCValue = sFVCValue.substring(0, sFVCValue.length() - 1);
    }

    if (bFound) {
%>
        <br><br><br><br><br><br><br><br><br><br><br><br><br><br><br>
        <%-- DATES --%>
        <table border="0" width="100%">
            <tr>
                <td width="30">&nbsp;</td>
                <td width="220" align="left"><%=sFEV1BeginDate%></td>
                <td width="100" align="left"><script>document.write(printDate+"/"+printMonth+"/"+today.getYear());</script></td>
                <td width="220" align="left"><%=sFVCBeginDate%></td>
                <td width="*"   align="left"><script>document.write(printDate+"/"+printMonth+"/"+today.getYear());</script></td>
            </tr>
        </table>
        <br>
        <%-- LEGEND --%>
        <b>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <font color="red"><%=getTran("Web.Occup","medwan.common.normal",sWebLanguage)%></font>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <font color="blue"><%=getTran("Web.Occup","medwan.recruitment.measurement",sWebLanguage)%></font>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <font color="green"><%=getTran("Web.Occup","medwan.common.today",sWebLanguage)%></font>
        </b>
        <br><br>
    <%
    }
%>
    <%-- BENEETH GRAPHS --------------------------------------------------------------------------%>
    <%=contextHeader(request,sWebLanguage)%>
    <%
        int maxValueY = MedwanQuery.getInstance().getConfigInt("maxValueY_respi");
        if(maxValueY < 0) maxValueY = 10; // default
    %>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input id="trandate" onchange="calculateToday()" type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>"> <script>writeTranDate();</script>
            </td>
        </tr>
        <%-- FEV1 --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.respiratory-function-examination.fev1",sWebLanguage)%></td>
            <td class='admin2'>
                <input id="MyFEV1" onKeyUp="calculateFEV1Percent()" onchange="calculateToday()" <%=setRightClick("ITEM_TYPE_RESP_FUNC_EX_FEV1")%> type="text" class="text" size="7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1" property="value"/>" onBlur="checkValue(this,0,<%=maxValueY%>,true);">
                &nbsp;<%=getTran("Web.Occup","medwan.common.liter",sWebLanguage)%>
                &nbsp;<input id="MyFEV1pct" readonly <%=setRightClick("ITEM_TYPE_RESP_FUNC_EX_FEV1_A")%> tabindex="-1" type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1_A" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FEV1_A" property="value"/>">%
            </td>
        </tr>
        <%-- FVC --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.respiratory-function-examination.fvc",sWebLanguage)%></td>
            <td class='admin2'>
                <input id="MyFVC" onKeyUp="calculateFVCPercent()" onchange="calculateToday()" <%=setRightClick("ITEM_TYPE_RESP_FUNC_EX_FVC")%> type="text" class="text" size="7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC" property="value"/>" onBlur="checkValue(this,0,<%=maxValueY%>,true);">
                &nbsp;<%=getTran("Web.Occup","medwan.common.liter",sWebLanguage)%>
                &nbsp;<input id="MyFVCpct" readonly <%=setRightClick("ITEM_TYPE_RESP_FUNC_EX_FVC_A")%> tabindex="-1" type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC_A" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_FVC_A" property="value"/>">%
            </td>
        </tr>
        <%-- VC --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.respiratory-function-examination.vc",sWebLanguage)%></td>
            <td class='admin2'>
                <input  id="MyVC" onKeyUp="calculateVCPercent()" <%=setRightClick("ITEM_TYPE_RESP_FUNC_EX_VC")%> type="text" class="text" size="7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_VC" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_VC" property="value"/>" onBlur="checkValue(this,0,<%=maxValueY%>,true);">
                &nbsp;<%=getTran("Web.Occup","medwan.common.liter",sWebLanguage)%>
                &nbsp;<input id="MyVCpct" readonly <%=setRightClick("ITEM_TYPE_RESP_FUNC_EX_VC_A")%> tabindex="-1" type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_VC_A" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_VC_A" property="value"/>">%
            </td>
        </tr>
        <%-- Tiffeneau (readonly) --%>
        <tr>
            <td class='admin'>Tiffeneau</td>
            <td class='admin2'>
                <input type="text" class="text" size="7" name="Tiffeneau" value="" readonly>
            </td>
        </tr>
        <%-- PEF --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.respiratory-function-examination.pef",sWebLanguage)%></td>
            <td class='admin2'>
                <input id="MyPEF" onKeyUp="calculatePEFPercent()" onchange="calculateToday()" type="text" class="text" size="7" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_PEF" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_PEF" property="value"/>"  onBlur="checkValue(this,0,1500,false);">
                &nbsp;<%=getTran("Web.Occup","medwan.common.liter-per-minute",sWebLanguage)%>
                &nbsp;<input id="MyPEFpct" <%=setRightClick("ITEM_TYPE_RESP_FUNC_EX_PEF_A")%> tabindex="-1" type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_PEF_A" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_PEF_A" property="value"/>">%
            </td>
        </tr>
        <%-- CAUSE OF FAILURE (dropdown) --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.respiratory-function-examination.raison-failure",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <select <%=setRightClick("ITEM_TYPE_RESP_FUNC_EX_RAISON_FAILURE")%> id="EditFailure" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_RAISON_FAILURE" property="itemId"/>]>.value" class="text">
                    <option/>
                    <option value="medwan.healthrecord.technical-problem"><%=getTran("Web.Occup","medwan.healthrecord.technical-problem",sWebLanguage)%>
                    <option value="medwan.healthrecord.non-compliance"><%=getTran("Web.Occup","medwan.healthrecord.non-compliance",sWebLanguage)%>
                    <option value="medwan.healthrecord.illness-employer"><%=getTran("Web.Occup","medwan.healthrecord.illness-employer",sWebLanguage)%>
                </select>
            </td>
        </tr>
        <%-- COMMENT --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.respiratory-function-examination.comment",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_RESP_FUNC_EX_COMMENT")%> class="text" cols="120" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_COMMENT" property="value"/></textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2">
<%-- BUTTONS -------------------------------------------------------------------------------------%>
    <%
        if (activeUser.getAccessRight("occup.respiratoryfunction.add") || activeUser.getAccessRight("occup.respiratoryfunction.edit")) {
        %>
            <input class="button" type="button" name="saveButton" id="save" value="<%=getTranNoLink("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="checkSubmit();"/>
        <%
        }

        if (MedwanQuery.getInstance().getConfigInt("spiroBankEnabled")==1){
        %>
            <input class="button" type="button" name="spirobank" value="<%=getTranNoLink("Web.Occup","medwan.common.spirobank",sWebLanguage)%>" onclick="loadSpirobank();"/>
        <%
        }
    %>
            <input class="button" type="button" value="<%=getTranNoLink("Web","Back",sWebLanguage)%>" onclick="doBack();">
        </td>
    </tr>
</table>
<%=sJSDIAGRAM%>
<script>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = '<c:url value="/main.do"/>?Page=curative/index.jsp&ts=<%=getTs()%>';
    }
  }

  function checkValue(inputField,min,max,focus){
    if(isNumber(inputField)){
      if(!checkMinMaxOpen(min,max,inputField)){
        var msg = '<%=getTran("Web.Occup","out-of-bounds-value-minmax",sWebLanguage)%>';
        msg = msg.replace('#min#',min);
        msg = msg.replace('#max#',max);
        alert(msg);
        if(focus){
          inputField.focus();
        }
      }
    }
  }

  function loadSpirobank(){
      var url = "<c:url value='/_common/search/template.jsp'/>?Page=/healthrecord/loadSpirobank.jsp&load=yes";
    window.open(url,'search','height=1, width=1, toolbar=no, status=no, scrollbars=yes, resizable=no, menubar=no');
  }

  function checkSubmit(){
    var trandate = document.getElementById("trandate");
    if(trandate.value!=""){
      submitForm();
    }
    else{
      trandate.focus();
    }
  }

  var failure = "<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESP_FUNC_EX_RAISON_FAILURE" property="value"/>";
  var select = document.getElementById('EditFailure');
  for(var n=0; n<select.length; n++){
    if(select.options[n].text == failure){
      select.selectedIndex = n;
      break;
    }
  }

  <%-- GET FEV1 NORMAL --%>
  function getFEV1Normal(iTmpDate) {
    iTmpAge = iTmpDate.substring(iTmpDate.lastIndexOf("/")+1)-yearOfBirth;
    iTmp = 0.0;
    if ("<%=checkString(activePatient.gender).toUpperCase()%>"=="F") {
      iTmp = (1.08*(3.95*<%=rLength.floatValue()%> - 0.025 * iTmpAge - 2.6));
    }
    else {
      iTmp = (1.08*(4.3*<%=rLength.floatValue()%> - 0.029 * iTmpAge - 2.49));
    }

    if (iTmp<0){
      iTmp = 0;
    }

    return iTmp;
  }

  <%-- GET FVC NORMAL --%>
  function getFVCNormal(iTmpDate){
    iTmpAge = iTmpDate.substring(iTmpDate.lastIndexOf("/")+1)-yearOfBirth;
    iTmp = 0.0;
    if ("<%=checkString(activePatient.gender).toUpperCase()%>"=="F") {
      iTmp = (1.15*(4.43*<%=rLength.floatValue()%> - 0.026 * iTmpAge - 2.89));
    }
    else {
      iTmp = (1.1*(5.76*<%=rLength.floatValue()%> - 0.026 * iTmpAge - 4.34));
    }

    if (iTmp<0){
        iTmp = 0;
    }

    return iTmp;
  }


  var i, rNormal, rNextNormal;
  var yearOfBirth = <%=iBirthday%>;
  var dFEV1Today, dFVC1Today;
  var maxValueY = <%=maxValueY%>;

  <%-- DRAW FEV1 GRAPH --%>
  aFEV1Value = new Array(<%=sFEV1Value%>);
  aFEV1Date = new Array(<%=sFEV1Date%>);

  if (aFEV1Date.length>0){
    var DFEV1 = new Diagram();
    DFEV1.SetFrame(50, 50, 300, 175);
    DFEV1.XScale = "";
    DFEV1.YScale = " l";
    DFEV1.SetText(" "," ","<%=getTran("Web.Occup","be.mxs.healthrecord.respiratory-function-examination.fev1",sWebLanguage)%>");

    DFEV1.SetBorder(Date.UTC(aFEV1Date[0].substr(aFEV1Date[0].lastIndexOf("/")+1), aFEV1Date[0].substr(aFEV1Date[0].indexOf("/")+1,2)*1-1, 28,0,0,0), Date.UTC(today.getYear(), today.getMonth()+1,today.getDate(),0,0,0),0,maxValueY);
    DFEV1.Draw("#FFFFFF", "#000000", false, "", "", "#DDDDFF");
    var iX, iXNext;
    for (i=0; i<aFEV1Value.length; i++) {
      iX = Date.UTC(aFEV1Date[i].substr(aFEV1Date[i].lastIndexOf("/")+1),aFEV1Date[i].substr(aFEV1Date[i].indexOf("/")+1,2),aFEV1Date[i].substr(0,aFEV1Date[i].indexOf("/")),0,0,0);
      new Dot(DFEV1.ScreenX(iX), DFEV1.ScreenY(aFEV1Value[i]), 8, 1, "0000ff",aFEV1Date[i]+": "+aFEV1Value[i]);

      if (yearOfBirth>0) {
        rNormal = getFEV1Normal(aFEV1Date[i]);
        new Dot(DFEV1.ScreenX(iX), DFEV1.ScreenY(rNormal), 8, 6, "ff0000",aFEV1Date[i]+": "+rNormal);
      }

      if (i<aFEV1Value.length-1) {
        iXNext = Date.UTC(aFEV1Date[i+1].substr(aFEV1Date[i+1].lastIndexOf("/")+1),aFEV1Date[i+1].substr(aFEV1Date[i+1].indexOf("/")+1,2),aFEV1Date[i+1].substr(0,aFEV1Date[i+1].indexOf("/")),0,0,0);
        new Line(DFEV1.ScreenX(iX), DFEV1.ScreenY(aFEV1Value[i]), DFEV1.ScreenX(iXNext), DFEV1.ScreenY(aFEV1Value[i+1]), "0000ff", 2, "");
        if (yearOfBirth>0)
        {
          rNextNormal = getFEV1Normal(aFEV1Date[i+1]);
          new Line(DFEV1.ScreenX(iX), DFEV1.ScreenY(rNormal), DFEV1.ScreenX(iXNext), DFEV1.ScreenY(rNextNormal), "ff0000", 2, "");
        }
      }
    }
    dFEV1Today = new Dot(DFEV1.ScreenX(Date.UTC(today.getYear(), today.getMonth()+1, today.getDate(),0,0,0,0)), DFEV1.ScreenY(document.getElementsByName('MyFEV1')[0].value), 9, 5, "32CD32",document.getElementsByName('MyFEV1')[0].value);
  }

  <%-- DRAW FVC GRAPH --%>
  aFVCValue = new Array(<%=sFVCValue%>);
  aFVCDate = new Array(<%=sFVCDate%>);

  if (aFVCValue.length>0){
    var DFVC=new Diagram();
    DFVC.SetFrame(375, 50, 625, 175);
    DFVC.XScale="";
    DFVC.YScale=" l";

    DFVC.SetBorder(Date.UTC(aFVCDate[0].substr(aFVCDate[0].lastIndexOf("/")+1), aFVCDate[0].substr(aFVCDate[0].indexOf("/")+1,2)*1-1, 28,0,0,0), Date.UTC(today.getYear(), today.getMonth()+1,today.getDate(),0,0,0),0,maxValueY);
    DFVC.SetText(" "," ","<%=getTran("Web.Occup","be.mxs.healthrecord.respiratory-function-examination.fvc",sWebLanguage)%>");
    DFVC.Draw("#FFFFFF", "#000000", false, "", "", "#DDDDFF");

    for (i=0; i<aFVCValue.length; i++) {
      iX = Date.UTC(aFVCDate[i].substr(aFVCDate[i].lastIndexOf("/")+1),aFVCDate[i].substr(aFVCDate[i].indexOf("/")+1,2),aFVCDate[i].substr(0,aFVCDate[i].indexOf("/")),0,0,0);
      new Dot(DFVC.ScreenX(iX), DFVC.ScreenY(aFVCValue[i]), 8, 1, "0000ff",aFVCDate[i]+": "+aFVCValue[i]);

      if (yearOfBirth>0){
        rNormal = getFVCNormal(aFVCDate[i]);
        new Dot(DFVC.ScreenX(iX), DFVC.ScreenY(rNormal), 8, 6, "ff0000",aFVCDate[i]+": "+rNormal);
      }

      if (i<aFVCValue.length-1){
        iXNext = Date.UTC(aFVCDate[i+1].substr(aFVCDate[i+1].lastIndexOf("/")+1),aFVCDate[i+1].substr(aFVCDate[i+1].indexOf("/")+1,2),aFVCDate[i+1].substr(0,aFVCDate[i+1].indexOf("/")),0,0,0);
        new Line(DFVC.ScreenX(iX), DFVC.ScreenY(aFVCValue[i]), DFVC.ScreenX(iXNext), DFVC.ScreenY(aFVCValue[i+1]), "0000ff", 2, "");

        if (yearOfBirth>0){
          rNextNormal = getFVCNormal(aFVCDate[i+1]);
          new Line(DFVC.ScreenX(iX), DFVC.ScreenY(rNormal), DFVC.ScreenX(iXNext), DFVC.ScreenY(rNextNormal), "ff0000", 2, "");
        }
      }
    }
    dFVCToday = new Dot(DFVC.ScreenX(Date.UTC(today.getYear(), today.getMonth()+1, today.getDate(),0,0,0,0)), DFVC.ScreenY(document.getElementsByName('MyFVC')[0].value), 9, 5, "32CD32",document.getElementsByName('MyFVC')[0].value);
  }

  <%-- CALCULATE TODAY --%>
  function calculateToday(){
    var sDate = document.getElementsByName('trandate')[0].value;

    if (aFEV1Value.length>0) {
      document.getElementsByName('MyFEV1')[0].value = document.getElementsByName('MyFEV1')[0].value.replace(",",".");
      var iFEVValue = document.getElementsByName('MyFEV1')[0].value * 1;
      aY = DFEV1.GetYGrid();

      if (iFEVValue > (aY[aY.length - 1]) ) {
        iFEVValue = aY[aY.length - 1];
      }

      if (iFEVValue < (aY[0]) ) {
        iFEVValue = aY[0];
      }

      dFEV1Today.MoveTo(DFEV1.ScreenX(Date.UTC(today.getYear(), today.getMonth()+1,today.getDate(),0,0,0)),DFEV1.ScreenY(iFEVValue));
    }

    if (aFVCValue.length>0) {
      document.getElementsByName('MyFVC')[0].value = document.getElementsByName('MyFVC')[0].value.replace(",",".");
      var iFVCValue = document.getElementsByName('MyFVC')[0].value * 1;
      aY = DFVC.GetYGrid();

      if (iFVCValue > (aY[aY.length - 1]) ) {
        iFVCValue = aY[aY.length - 1];
      }

      if (iFVCValue < (aY[0]) ) {
        iFVCValue = aY[0];
      }

      dFVCToday.MoveTo(DFVC.ScreenX(Date.UTC(today.getYear(), today.getMonth()+1, today.getDate(),0,0,0)), DFVC.ScreenY(iFVCValue));
    }
  }

  calculateTiffeneau();
</script>
<%=ScreenHelper.contextFooter(request)%>
</form>
<script>document.getElementById("trandate").focus();</script>
<%=writeJSButtons("transactionForm","saveButton")%>