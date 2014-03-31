<%@ page import="be.openclinic.medical.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.healthcenter.contact","select",activeUser)%>

<%!
    //--- GET KEYWORDS HTML -----------------------------------------------------------------------
	private String getKeywordsHTML(TransactionVO transaction, String itemId, String textField,
			                       String idsField, String language){
		StringBuffer sHTML = new StringBuffer();
		ItemVO item = transaction.getItem(itemId);
		if(item!=null && item.getValue()!=null && item.getValue().length()>0){
			String[] ids = item.getValue().split(";");
			String keyword = "";
			
			for(int n=0; n<ids.length; n++){
				if(ids[n].split("\\$").length==2){
					keyword = getTran(ids[n].split("\\$")[0],ids[n].split("\\$")[1] , language);
					
					sHTML.append("<a href='javascript:deleteKeyword(\"").append(idsField).append("\",\"").append(textField).append("\",\"").append(ids[n]).append("\");'>")
					      .append("<img width='8' src='"+sCONTEXTPATH+"/_img/erase.png' class='link' style='vertical-align:-1px'/>")
					     .append("</a>")
					     .append("&nbsp;<b>").append(keyword).append("</b> | ");
				}
			}
		}
		
		String sHTMLValue = sHTML.toString();
		if(sHTMLValue.endsWith("| ")){
			sHTMLValue = sHTMLValue.substring(0,sHTMLValue.lastIndexOf("| "));
		}
		
		return sHTMLValue;
	}
%>

<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
	<% TransactionVO tran = (TransactionVO)transaction; %>
	   
	<%
	    // this transaction seems to "loose" some items, in rare cases; thus this debug lines
		Vector tmpItems = (Vector)tran.getItems();
		for(int i=0; i<tmpItems.size(); i++){
			ItemVO item = (ItemVO)tmpItems.get(i);
			System.out.println("["+i+"] "+item.getType()+" : "+item.getValue()); 
		}
	%>
   
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
   
    <%=writeHistoryFunctions(tran.getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
   
    <table class="list" width="100%" cellspacing="1">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="10%" nowrap>
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>&nbsp;
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
            <td class="admin2" colspan='2'>&nbsp;</td>
        </tr>
    </table>
    <div style="padding-top:5px;"></div>
         
    <%-- BIOMETRICS -----------------------------------------------------------------------------%>
    <table class="list" width='100%' cellpadding="1" cellspacing="1"> 
     	<%-- title --%>
     	<tr class="gray">
            <td>&nbsp;<b><%=getTran("web","biometrics",sWebLanguage)%></b></td>
        </tr>    
        <tr>
         	<td class="admin2" width='100%' style="padding:0px;">
         	    <table width="100%" cellpadding="1" cellspacing="1">
         			<tr>
         				<td class='admin'><%=getTran("Web.Occup","medwan.healthrecord.cardial.pression-arterielle",sWebLanguage)%></td>
         				<td class='admin2'>
         					<%=getTran("Web.Occup","medwan.healthrecord.cardial.bras-droit",sWebLanguage)%> 
         					<input id="sbpr" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> /
                        	<input id="dbpr" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT" property="value"/>" onblur="setBP(this,'sbpr','dbpr');"> mmHg
                        </td>
                        <td class='admin2' colspan='2'>
	                        <%=getTran("Web.Occup","medwan.healthrecord.cardial.bras-gauche",sWebLanguage)%>
	                        <input id="sbpl" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT" property="value"/>" onblur="setBP(this,'sbpl','dbpl');"> /
	                        <input id="dbpl" <%=setRightClick("ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT" property="value"/>" onblur="setBP(this,'sbpl','dbpl');"> mmHg
                        </td>
			            <td class='admin' colspan="2"><%=getTran("Web.Occup","medwan.healthrecord.biometry.weight",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			                <input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_WEIGHT")%> id="weight" class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="value"/>"/>
			            </td>
                        <td width="30%">&nbsp;</td>
         			</tr>
         			
         			<tr>
         				<td class='admin'><%=getTran("openclinic.chuk","temperature",sWebLanguage)%></td>
         				<td class='admin2'>
                        	<input id="temperature" <%=setRightClick("ITEM_TYPE_BIOMETRY_TEMPERATURE")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_TEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_TEMPERATURE" property="value"/>"> °C
                        </td>
         				<td class='admin'><%=getTran("openclinic.chuk","height",sWebLanguage)%></td>
         				<td class='admin2'>
                        	<input id="height" <%=setRightClick("ITEM_TYPE_BIOMETRY_HEIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>"> cm
                        </td>
         				<td class='admin' colspan="2"><%=getTran("openclinic.chuk","heartfrequency",sWebLanguage)%></td>
         				<td class='admin2'>
                            <input id="hearthfreq" <%=setRightClick("ITEM_TYPE_BIOMETRY_HEARTFREQUENCY")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEARTFREQUENCY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEARTFREQUENCY" property="value"/>">/min
                        </td>
                        <td width="30%">&nbsp;</td>
         			</tr>
         		</table>
         	</td>
         </tr>
    </table>
    <div style="padding-top:5px;"></div>
    
    <%-- KEYWORDS for DIAGNOSES -----------------------------------------------------------------%>
    <table class="list" width='100%' cellpadding="1" cellspacing="1">
     	<%-- title --%>
     	<tr class="gray">
            <td colspan="5">&nbsp;<b><%=getTran("web","keywords",sWebLanguage)%></b></td>
        </tr>             
        <tr> 
         	<td class="admin2" colspan='3' width='70%' style="vertical-align:top;padding:0px;">
         		<table width="100%" cellpadding="1" cellspacing="1">
         			<%-- Functional signs --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title1"><%=getTran("web","functional.signs",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("functional.signs.ids","functional.signs.text","functional.signs","keywords")'>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='functional.signs.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_FUNCTIONALSIGNS_IDS","functional.signs.text","functional.signs.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='functional.signs.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_COMMENT" property="itemId"/>]>.value" id='functional.signs.comment' cols='45' ><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_COMMENT" property="value"/></textarea>
			         				</td>
			         				<td class='admin2' width='40' nowrap style="text-align:center">
			         				    <img width='16' id='key1' class="link" src='<c:url value="/_img/keywords.jpg"/>'/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			
         			<%-- Inspection --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title2"><%=getTran("web","inspection",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("inspection.ids","inspection.text","inspection","keywords")'>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='inspection.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_INSPECTION_IDS","inspection.text","inspection.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='inspection.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_COMMENT" property="itemId"/>]>.value" id='inspection.comment' cols='45'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='40' style="text-align:center">
			         				    <img width='16' id='key2' class="link" src='<c:url value="/_img/keywords.jpg"/>'/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			
         			<%-- Palpation --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title3"><%=getTran("web","palpation",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("palpation.ids","palpation.text","palpation","keywords")'>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='palpation.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_PALPATION_IDS","palpation.text","palpation.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='palpation.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_COMMENT" property="itemId"/>]>.value" id='palpation.comment' cols='45'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='40' style="text-align:center">
			         				    <img width='16' id='key3' class="link" src='<c:url value="/_img/keywords.jpg"/>'/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			
         			<%-- Heart ausculation --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title4"><%=getTran("web","heart.auscultation",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("heart.auscultation.ids","heart.auscultation.text","heart.auscultation","keywords")'>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='heart.auscultation.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_HEARTAUSCULTATION_IDS","heart.auscultation.text","heart.auscultation.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='heart.auscultation.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_COMMENT" property="itemId"/>]>.value" id='heart.auscultation.comment' cols='45'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='40' style="text-align:center">
			         				    <img width='16' id='key4' class="link" src='<c:url value="/_img/keywords.jpg"/>'/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			
         			<%-- Lung ausculation --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title5"><%=getTran("web","lung.auscultation",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("lung.auscultation.ids","lung.auscultation.text","lung.auscultation","keywords")'>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='lung.auscultation.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_LUNGAUSCULTATION_IDS","lung.auscultation.text","lung.auscultation.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='lung.auscultation.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LUNGAUSCULTATION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LUNGAUSCULTATION_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LUNGAUSCULTATION_COMMENT" property="itemId"/>]>.value" id='lung.auscultation.comment' cols='45'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LUNGAUSCULTATION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='40' style="text-align:center">
			         				    <img width='16' id='key5' class="link" src='<c:url value="/_img/keywords.jpg"/>'/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			
         			<%-- Reference --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title6"><%=getTran("web","reference",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("reference.ids","reference.text","reference","keywords")'>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='reference.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_REFERENCE_IDS","reference.text","reference.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='reference.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea class="text" onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_COMMENT" property="itemId"/>]>.value" id='reference.comment' cols='45'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='40' style="text-align:center">
			         				    <img width='16' id='key6' class="link" src='<c:url value="/_img/keywords.jpg"/>'/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			
         			<%-- Evacuation --%>
         			<tr height="40">
         				<td class='admin' width='20%'>
         					<div id="title7"><%=getTran("web","evacuation",sWebLanguage)%></div>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr onclick='selectKeywords("evacuation.ids","evacuation.text","evacuation","keywords")'>
			         				<td class='admin2' width='50%' style="vertical-align:top;">
			         					<div id='evacuation.text'><%=getKeywordsHTML(tran,ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_EVACUATION_IDS","evacuation.text","evacuation.ids",sWebLanguage)%></div>
			         					<input type='hidden' id='evacuation.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVACUATION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVACUATION_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea class="text" onkeyup="resizeTextarea(this,10);" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVACUATION_COMMENT" property="itemId"/>]>.value" id='evacuation.comment' cols='45'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVACUATION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='40' style="text-align:center">
			         				    <img width='16' id='key7' class="link" src='<c:url value="/_img/keywords.jpg"/>'/>
			         				</td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         		</table>
         	</td>
         	
         	<%-- KEYWORDS --%>
         	<td class="admin2" style="vertical-align:top;padding:0px;">
         		<div style="height:300px;overflow:auto" id="keywords"></div>
         	</td>
         </tr>
    </table>
    <div style="padding-top:5px;"></div>
    
    <%-- DIAGNOSES --%>
    <%ScreenHelper.setIncludePage(customerInclude("healthrecord/diagnosesEncodingWide.jsp"),pageContext);%>            
    	    
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
    <%=getButtonsHtml(request,activeUser,activePatient,"occup.healthcenter.contact",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>
        
	<%=ScreenHelper.contextFooter(request)%>
</form>

<script>
  <%-- SUBMIT FORM --%>
  function submitForm(){
    document.transactionForm.saveButton.disabled = true;
    document.transactionForm.submit();
  }
    
  <%-- SELECT KEYWORDS --%>
  function selectKeywords(destinationidfield,destinationtextfield,labeltype,divid){	
    document.getElementById("key1").width = "16";
    document.getElementById("key2").width = "16";
    document.getElementById("key3").width = "16";
    document.getElementById("key4").width = "16";
    document.getElementById("key5").width = "16";
    document.getElementById("key6").width = "16";
    document.getElementById("key7").width = "16";
    
    document.getElementById("title1").style.textDecoration = "none";
    document.getElementById("title2").style.textDecoration = "none";
    document.getElementById("title3").style.textDecoration = "none";
    document.getElementById("title4").style.textDecoration = "none";
    document.getElementById("title5").style.textDecoration = "none";
    document.getElementById("title6").style.textDecoration = "none";
    document.getElementById("title7").style.textDecoration = "none";
    
    if(labeltype=='functional.signs'){
        document.getElementById("title1").style.textDecoration = "underline";
	  document.getElementById('key1').width = '32';
	}
    else if(labeltype=='inspection'){
      document.getElementById("title2").style.textDecoration = "underline";
	  document.getElementById('key2').width = '32';
	}
    else if(labeltype=='palpation'){
      document.getElementById("title3").style.textDecoration = "underline";
	  document.getElementById('key3').width = '32';
	}
    else if(labeltype=='heart.auscultation'){
      document.getElementById("title4").style.textDecoration = "underline";
	  document.getElementById('key4').width = '32';
	}
    else if(labeltype=='lung.auscultation'){
      document.getElementById("title5").style.textDecoration = "underline";
	  document.getElementById('key5').width = '32';
	}
    else if(labeltype=='reference'){
      document.getElementById("title6").style.textDecoration = "underline";
	  document.getElementById('key6').width = '32';
	}
    else if(labeltype=='evacuation'){
      document.getElementById("title7").style.textDecoration = "underline";
	  document.getElementById('key7').width = '32';
	}
    
    var params = "";
    var today = new Date();
    var url = '<c:url value="/healthrecord/ajax/getKeywords.jsp"/>'+
              '?destinationidfield='+destinationidfield+
              '&destinationtextfield='+destinationtextfield+
              '&labeltype='+labeltype+
              '&ts='+today;
    new Ajax.Request(url,{
      method: "POST",
      parameters: params,
      onSuccess: function(resp){
        $(divid).innerHTML = resp.responseText;
      },
      onFailure: function(){
        $(divid).innerHTML = "";
      }
    });
  }

  <%-- ADD KEYWORD --%>
  function addKeyword(id,label,destinationidfield,destinationtextfield){
	var ids = document.getElementById(destinationidfield).value;
	if((ids+";").indexOf(id+";")<=-1){
	  document.getElementById(destinationidfield).value = ids+";"+id;
	  
	  if(document.getElementById(destinationtextfield).innerHTML.length > 0){
		if(!document.getElementById(destinationtextfield).innerHTML.endsWith("| ")){
          document.getElementById(destinationtextfield).innerHTML+= " | ";
	    }
	  }
	  
	  document.getElementById(destinationtextfield).innerHTML+= "<a href='javascript:deleteKeyword(\""+destinationidfield+"\",\""+destinationtextfield+"\",\""+id+"\");'><img width='8' src='<c:url value="/_img/erase.png"/>' class='link' style='vertical-align:-1px'/></a> <b>"+label+"</b> | ";
	}
  }

  <%-- DELETE KEYWORD --%>
  function deleteKeyword(destinationidfield,destinationtextfield,id){
	var newids = "";
	
	var ids = document.getElementById(destinationidfield).value.split(";");
	for(n=0; n<ids.length; n++){
	  if(ids[n].indexOf("$")>-1){
		if(id!=ids[n]){
		  newids+= ids[n]+";";
		}
	  }
	}
	
	document.getElementById(destinationidfield).value = newids;
	var newlabels = "";
	var labels = document.getElementById(destinationtextfield).innerHTML.split(" | ");
    for(n=0;n<labels.length;n++){
	  if(labels[n].trim().length>0 && labels[n].indexOf(id)<=-1){
	    newlabels+=labels[n]+" | ";
	  }
	}
    
	document.getElementById(destinationtextfield).innerHTML = newlabels;	
  }
  
  <%-- SET BP --%>
  function setBP(oObject,sbp,dbp){
    if(oObject.value.length>0){
      if(!isNumberLimited(oObject,40,300)){
        alert('<%=getTran("Web.Occup","out-of-bounds-value",sWebLanguage)%>');
      }
      else if((sbp.length>0)&&(dbp.length>0)){
        isbp = document.getElementsByName(sbp)[0].value*1;
        idbp = document.getElementsByName(dbp)[0].value*1;
        if(idbp>isbp){
          alert('<%=getTran("Web.Occup","error.dbp_greather_than_sbp",sWebLanguage)%>');
        }
      }
    }
  }

  selectKeywords("functional.signs.ids","functional.signs.text","functional.signs","keywords");
</script>