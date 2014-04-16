<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%
    
%>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
    <input type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>" id="transactionId"/>
    <input type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>" id="serverId"/>
    <input type="hidden" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>" id="transactionType"/>
    <input type="hidden" name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/showPeriodicExaminations.do?ts=<%=getTs()%>" readonly/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

<script>
  function setAllNegative(doSet){
    if(doSet){
      for(var i=1; i<=20; i++){
        document.getElementsByName('dld-r'+i+'2')[0].checked = true;
      }
    }
    else{
      for(var i=1; i<=20; i++){
        document.getElementsByName('dld-r'+i+'1')[0].checked = true;
      }
    }
  }
</script>
<%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
<%=contextHeader(request,sWebLanguage)%>
<table class="list" width="100%" cellspacing="1">
    <%-- date --%>
    <tr>
        <td class="admin" width="40%">
            <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
            <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
        </td>
        <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" id="trandate" OnBlur='checkDate(this)'> <script>writeTranDate();</script>
        </td>
    </tr>

    <%-- category --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.actual-category-or-sub-category",sWebLanguage)%></td>
        <td class="admin2">
            <input type="checkbox" id="dld-c1"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_B" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_B;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="dld-c1">B</label>
            <input type="checkbox" id="dld-c2"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_B_E" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_B_E;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="dld-c2">B+E</label>
            <input type="checkbox" id="dld-c3"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_C" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_C;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="dld-c3">C</label>
            <input type="checkbox" id="dld-c4"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_C_E" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_C_E;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="dld-c4">C+E</label>
            <input type="checkbox" id="dld-c5"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_C1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_C1;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="dld-c5">C1</label>
            <input type="checkbox" id="dld-c6"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_C1_E" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_C1_E;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="dld-c6">C1+E</label>
            <input type="checkbox" id="dld-c7"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_D" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_D;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="dld-c7">D</label>
            <input type="checkbox" id="dld-c8"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_D_E" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_D_E;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="dld-c8">D+E</label>
            <input type="checkbox" id="dld-c9"  name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_D1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_D1;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="dld-c9">D1</label>
            <input type="checkbox" id="dld-c10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_D1_E" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_D1_E;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"><label for="dld-c10">D1+E</label>
        </td>
    </tr>

    <%-- delivery place --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.delivery-place",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_DELIVERED_TO" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_DELIVERED_TO" property="value"/>" onblur="limitLength(this);">
        </td>
    </tr>

    <%-- expiration date --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.expiration-date",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="12" maxLength="10" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_VALIDITY_DATE" property="value" formatType="date" format="dd-mm-yyyy"/>" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N  name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_VALIDITY_DATE" property="itemId"/>]>.value" id="validdate" onBlur="checkDate(this);"> <script>writeMyDate("validdate","<c:url value="/_img/calbtn.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
        </td>
    </tr>

    <%-- questionnaire valid for category --%>
    <tr>
        <td class="admin"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.valide-for-category",sWebLanguage)%></td>
        <td class="admin2">
            <input type="text" class="text" size="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_CANDIDATE_CATEGORY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_CANDIDATE_CATEGORY" property="value"/>" onblur="limitLength(this);">
        </td>
    </tr>

    <%-- previous examination date --%>
    <tr>
        <td class="admin">
            <%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.if-applicable",sWebLanguage)%>&nbsp;:
            <br>&nbsp;&nbsp;
            <%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.previous-examination-date",sWebLanguage)%>
            <br>&nbsp;&nbsp;
            <%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.examination-doctor-name",sWebLanguage)%>
        </td>
        <td class="admin2">
            <br>
            <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N  name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_EXAMINATION_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_EXAMINATION_DATE" property="value" formatType="date" format="dd-mm-yyyy"/>" id="nextdate" onBlur='if(checkDate(this)){ checkAfter("trandate",this); }'> <script>writeMyDate("nextdate","<c:url value="/_img/calbtn.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            <br>
            <input type="text" class="text" size="40" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_EXAMINATOR_NAME" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_EXAMINATOR_NAME" property="value"/>" onblur="limitLength(this);">
        </td>
    </tr>

    <%-- QUESTIONNAIRE ---------------------------------------------------------------------------%>
    <tr>
        <td colspan="2">
            <table border='0' width='100%' class='list' cellspacing="1">
                <%-- HEADER --%>
                <tr>
                    <td width="1%">
                        <img id="candidate-questionnaire-plus" border="0" src='<c:url value="/_img/plus.png"/>' onclick="hide('candidate-questionnaire-plus'); show('candidate-questionnaire-minus'); show('candidate-questionnaire-details');">
                        <img id="candidate-questionnaire-minus" style="display:none" border="0" src='<c:url value="/_img/minus.png"/>' onclick="show('candidate-questionnaire-plus'); hide('candidate-questionnaire-minus'); hide('candidate-questionnaire-details');">
                    </td>
                    <td width="*">
                        <%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire",sWebLanguage)%>
                    </td>
                    <td width="25%" align="right">
                        &nbsp;<input type="button" class="button" name="ButtonSetAllNegative" value="<%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.everything-negative",sWebLanguage)%>" onclick="hide('candidate-questionnaire-plus'); show('candidate-questionnaire-minus'); show('candidate-questionnaire-details');setAllNegative(true);">
                    </td>
                </tr>

                <%-- QUESTIONS --%>
                <tr id="candidate-questionnaire-details" style="display:none">
                    <td colspan="3">
                        <table class="list" width="100%" cellspacing="1">
                            <tr>
                                <td class="admin" width="1%">&nbsp;</td>
                                <td class="admin" width="90%">&nbsp;</td>
                                <td class="admin2" width="5%"><%=getTran("Web.Occup","medwan.common.yes",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><%=getTran("Web.Occup","medwan.common.no",sWebLanguage)%></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">1</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-1",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q1")%> id="dld-r11" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q1;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q1")%> id="dld-r12" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q1" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q1;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">2</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-2",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q2")%> id="dld-r21" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q2;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q2")%>id="dld-r22" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q2" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q2;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">3</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-3",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q3")%> id="dld-r31" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q3;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q3")%>id="dld-r32" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q3" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q3;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">4</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-4",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q4")%> id="dld-r41" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q4;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q4")%>id="dld-r42" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q4" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q4;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">5</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-5",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q5")%> id="dld-r51" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q5;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q5")%>id="dld-r52" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q5" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q5;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">6</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-6",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q6")%> id="dld-r61" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q6;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q6")%>id="dld-r62" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q6" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q6;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">7</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-7",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q7")%> id="dld-r71" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q7" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q7;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q7")%>id="dld-r72" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q7" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q7;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">8</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-8",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q8")%> id="dld-r81" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q8;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q8")%>id="dld-r82" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q8" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q8;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">9</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-9",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q9")%> id="dld-r91" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q9" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q9;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q9")%>id="dld-r92" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q9" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q9;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">10</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-10",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q10")%> id="dld-r101" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q10;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q10")%>id="dld-r102" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q10" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q10;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">11</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-11",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q11")%> id="dld-r111" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q11" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q11;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q11")%>id="dld-r112" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q11" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q11;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">12</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-12",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q12")%> id="dld-r121" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q12;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q12")%>id="dld-r122" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q12" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q12;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">13</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-13",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q13")%> id="dld-r131" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q13" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q13;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q13")%>id="dld-r132" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q13" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q13;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">14</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-14",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q14")%> id="dld-r141" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q14" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q14;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q14")%>id="dld-r142" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q14" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q14;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">15</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-15",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q15")%> id="dld-r151" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q15" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q15;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q15")%>id="dld-r152" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q15" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q15;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">16</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-16",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q16")%> id="dld-r161" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q16" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q16;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q16")%>id="dld-r162" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q16" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q16;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">17</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-17",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q17")%> id="dld-r171" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q17" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q17;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q17")%>id="dld-r172" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q17" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q17;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">18</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-18",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q18")%> id="dld-r181" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q18" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q18;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q18")%>id="dld-r182" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q18" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q18;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">19</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-19",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q19")%> id="dld-r191" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q19" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q19;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q19")%>id="dld-r192" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q19" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q19;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">20</td>
                                <td class="admin" width="90%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.question-20",sWebLanguage)%></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q20")%> id="dld-r201" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q20" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q20;value=medwan.common.yes" property="value" outputString="checked"/> value="medwan.common.yes"></td>
                                <td class="admin2" width="5%"><input <%=setRightClick("ITEM_TYPE_DLD_Q20")%>id="dld-r202" type="radio" onDblClick="uncheckRadio(this);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q20" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_Q20;value=medwan.common.no" property="value" outputString="checked"/> value="medwan.common.no"></td>
                            </tr>
                            <tr>
                                <td class="admin" width="1%">&nbsp;</td>
                                <td class="admin" width="100%"><%=getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.commitment",sWebLanguage)+" "+getTran("Web.Occup","medwan.common.driving-license-declaration.candidate-questionnaire.commitment1",sWebLanguage)%></td>
                                <td class="admin2" colspan="2" width="5%"></td>
                            </tr>
                        </table>
                    </td>
                </tr>
            </table>
        </td>
    </tr>

    <%-- comment --%>
    <tr>
        <td class="admin"><%=getTran("Web","comment",sWebLanguage)%></td>
        <td class="admin2">
            <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_DLD_REMARK")%> class="text" cols="80" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_REMARK" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DLD_REMARK" property="value"/></textarea>
        </td>
    </tr>
</table>

<%-- BUTTONS --%>
<%=ScreenHelper.alignButtonsStart()%>
    <%
        if (activeUser.getAccessRight("occupdrivinglicensedeclaration.add") || activeUser.getAccessRight("occupdrivinglicensedeclaration.edit")){
            %>
                <INPUT class="button" type="button" name="saveButton" id="save" onClick="doSubmit();" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>">
            <%
        }
    %>
    <INPUT class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="if(checkSaveButton())){window.location.href='<c:url value="/healthrecord/showPeriodicExaminations.do"/>?ts=<%=getTs()%>'}">
<%=ScreenHelper.alignButtonsStop()%>
<script>
  function doSubmit(){
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