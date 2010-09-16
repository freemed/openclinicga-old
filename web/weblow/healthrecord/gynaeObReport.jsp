<%@page import="be.openclinic.adt.Encounter,
                java.util.*" %>
<%@include file="/includes/validateUser.jsp" %>
<%@page errorPage="/includes/error.jsp" %>
<%=checkPermission("occup.surveillance", "select", activeUser)%>
<script type="text/javascript">
    <%-- ACTIVATE TAB --%>
    function activateTab(iTab) {
        document.all['tr1-view'].style.display = 'none';
        document.all['tr3-view'].style.display = 'none';
        $("td1").className = "tabunselected";
        $("td3").className = "tabunselected";
        if (iTab == 1) {
            document.all['tr1-view'].style.display = '';
            $("td1").className = "tabselected";
        }
        else if (iTab == 3) {
            document.all['tr3-view'].style.display = '';
            $("td3").className = "tabselected";
        }
    }
</script>
<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%=writeHistoryFunctions(((TransactionVO) transaction).getTransactionType(), sWebLanguage)%><%=contextHeader(request, sWebLanguage)%>
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;<%=getTran("Web.Occup", "medwan.common.date", sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeMyDate("trandate", "<c:url value="/_img/icon_agenda.gif"/>", "<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>
        <%-- TABS --%>
        <table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
                <td class='tabs' width="2">&nbsp;</td>
                <td class='tabunselected' width="1%" onclick="activateTab(1)" id="td1" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>
                    &nbsp;<b><%=getTran("Web.Occup", "obreport.section1", sWebLanguage)%>
                </b>&nbsp;</td>
                <td class='tabs' width="2">&nbsp;</td>
                <td class='tabunselected' width="1%" onclick="activateTab(3)" id="td3" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>
                    &nbsp;<b><%=getTran("Web.Occup", "obreport.section2", sWebLanguage)%>
                </b>&nbsp;</td>
                <td class='tabs'>&nbsp;</td>
            </tr>
        </table>
        <%-- HIDEABLE --%>
        <table valign="top" width="100%" border="0" cellspacing="0">
            <tr id="tr1-view" style="display:none">
                <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/gynaeObReportSection1.jsp"), pageContext);%></td>
            </tr>
            <tr id="tr3-view" style="display:none">
                <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/gynaeObReportSection2.jsp"), pageContext);%></td>
            </tr>
        </table>
    </table>
    <div style="text-align:center;margin:0;padding:0;">
        <INPUT class="button" type="button" name="saveButton" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="setAutocompletionValues();"/>
        <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if (checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}"/>
    </div>
</form>
<script type="text/javascript">
    //*************  INIT OF ITEMTYPES ARRAY *******************//
    var itemsTypes = new Array();
    <%
     //*************** get all ItemsTYPES   *********************//
     List itemsTypes= getItemTypeFromUser("ITEM_TYPE_OBREPORT",Integer.parseInt(activeUser.userid));
        Iterator it = itemsTypes.iterator();
        while(it.hasNext()){
        String itemType = (String)it.next();
           out.write("\nitemsTypes.push('"+itemType.substring(47)+"');");
        }
    %>
    //******  LOOP type items **********//
    itemsTypes.each(function(itemsTypes) {
        //********* set autocompletion ***//
        autocompletionItems(itemsTypes);

    });
    function setAutocompletionValues() {
        //** loop type items **//
        itemsTypes.each(function(itemsTypes) {
            //**  test if element exists ****//
            if ($('ac_' + itemsTypes)) {
                //***  get values array **//
                var itemValues = Form.Element.Methods.getValue("ac_" + itemsTypes).replace(/^\s*|\s*$/g, '');
                   //** if exists values ****//
                if (itemValues != "") {
                    //** test value **/
                    testItemValue(itemsTypes, itemValues);
                }
            }
            ;
        });
        submitForm();
    }
    function submitForm() {
        if(document.getElementById('encounteruid').value==''){
    		alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
    		searchEncounter();
    	}	
        else {
	        // waiting for last item to submit //
	        document.transactionForm.saveButton.style.visibility = "hidden";
	        var temp = Form.findFirstElement(transactionForm);//for ff compatibility
		    <%
		        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
		       out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
		    %>
        }
    }
    function searchEncounter(){
        openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
    }
    if(document.getElementById('encounteruid').value==''){
  	alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
  	searchEncounter();
    }	
    activateTab(1);
</script>