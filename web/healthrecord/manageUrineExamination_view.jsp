<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.urineexamination","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input id="transactionId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input id="serverId" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input id="transactionType" type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/managePeriodicExaminations.do?ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

<script>
  function submitForm(){
    var _A = "";
    var _G = "";
//  var _B = "";
//  var _P = "";
    var result = "";

    _A = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE" property="itemId"/>]>.value')[0].options[document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE" property="itemId"/>]>.value')[0].selectedIndex].value;
    _G = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE" property="itemId"/>]>.value')[0].options[document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE" property="itemId"/>]>.value')[0].selectedIndex].value;
//  _B = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD" property="itemId"/>]>.value')[0].options[document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD" property="itemId"/>]>.value')[0].selectedIndex].value;
//  _P = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_PREGNANCY" property="itemId"/>]>.value')[0].options[document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_PREGNANCY" property="itemId"/>]>.value')[0].selectedIndex].value;

    if (_A == "medwan.common.negative"){
      _A="-";
    }
    if (_G == "medwan.common.negative"){
      _G="-";
    }
//  if (_B == "medwan.common.negative"){
//    _B="-";
//  }
//  if (_P == "medwan.common.negative"){
//    _P="-";
//  }
//  else if (_P == "medwan.common.positive"){
//    _P="+";
//  }

//  result = "A:"+_A+" G:"+_G+" B:"+_B+" P:"+_P;
    result = "A:"+_A+" G:"+_G;

    document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTION_RESULT" property="itemId"/>]>.value')[0].value=result;
    document.transactionForm.save.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }
</script>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="30%">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'> <script>writeMyDate("trandate","<c:url value="/_img/calbtn.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
        <%-- albumine --%>
        <tr>
            <td class='admin'>
                <%=getTran("Web.Occup","medwan.healthrecord.urine-exam.albumine",sWebLanguage)%>&nbsp;
            </td>
            <td class='admin2'>
                <select <%=setRightClick("ITEM_TYPE_URINE_ALBUMINE")%> class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE" property="itemId"/>]>.value" class="text">
                    <option/>
                    <option value="medwan.common.negative" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE;value=medwan.common.negative" property="value" outputString="selected"/> onclick='_A="-"' ><%=getTran("Web.Occup","medwan.common.negative",sWebLanguage)%>
                    <option value="30" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE;value=30" property="value" outputString="selected"/> onclick='_A="30"'>30
                    <option value="100" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE;value=100" property="value" outputString="selected"/> onclick='_A="100"'>100
                    <option value="500" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_ALBUMINE;value=500" property="value" outputString="selected"/> onclick='_A="500"'>500
                </select>
                mg/dl
            </td>
        </tr>
        <%-- glucose --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.urine-exam.glucose",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <select <%=setRightClick("ITEM_TYPE_URINE_GLUCOSE")%> class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE" property="itemId"/>]>.value" class="text">
                    <option/>
                    <option value="medwan.common.negative" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=medwan.common.negative" property="value" outputString="selected"/> onclick='_G="-"'><%=getTran("Web.Occup","medwan.common.negative",sWebLanguage)%>
                    <option value="50" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=50" property="value" outputString="selected"/> onclick='_G="50"'>50
                    <option value="100" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=100" property="value" outputString="selected"/> onclick='_G="100"'>100
                    <option value="300" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=300" property="value" outputString="selected"/> onclick='_G="300"'>300
                    <option value="1000" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_GLUCOSE;value=1000" property="value" outputString="selected"/> onclick='_G="1000"'>1000
                </select>
                mg/dl
            </td>
        </tr>
        <%--
        <tr>
        <td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.urine-exam.blood",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <select <%=setRightClick("ITEM_TYPE_URINE_BLOOD")%> class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD" property="itemId"/>]>.value" class="text">
                    <option/>
                    <option value="medwan.common.negative" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=medwan.common.negative" property="value" outputString="selected"/> onclick='_B="-"'><%=getTran("Web.Occup","medwan.common.negative",sWebLanguage)%>
                    <option value="5-10" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=5-10" property="value" outputString="selected"/> onclick='_B="5-10"'>5-10
                    <option value="25" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=25" property="value" outputString="selected"/> onclick='_B="25"'>25
                    <option value="50" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=50" property="value" outputString="selected"/> onclick='_B="50"'>50
                    <option value="250" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_BLOOD;value=250" property="value" outputString="selected"/> onclick='_B="250"'>250
                </select>
                ery/µl
            </td>
        </tr>
        --%>
        <%-- remark --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_URINE_REMARK")%> class="text" cols="75" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_URINE_REMARK" property="value"/></textarea>
            </td>
        </tr>
    </table>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%
            if ((activeUser.getAccessRight("occupurineexamination.add"))||(activeUser.getAccessRight("occupurineexamination.edit"))){
            %>
                <INPUT class="button" type="button" name="save" id="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="submitForm()"/>
            <%
            }
        %>
        <INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="if (checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value="/healthrecord/managePeriodicExaminations.do"/>?ConvocationID=currentConvocation&ts=<%=getTs()%>'}">
    <%=ScreenHelper.alignButtonsStop()%>
    <%=ScreenHelper.contextFooter(request)%>
</form>
<%=writeJSButtons("transactionForm","save")%>