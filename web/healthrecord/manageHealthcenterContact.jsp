<%@ page import="be.openclinic.medical.*" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.healthcenter.contact","select",activeUser)%>
<%!
	private String getKeywordsHTML(TransactionVO transaction,String itemId,String textField,String idsField,String language){
		String s="";
		ItemVO item = transaction.getItem(itemId);
		if(item!=null && item.getValue()!=null && item.getValue().length()>0){
			String[] ids = item.getValue().split(";");
			String keyword="";
			for(int n=0;n<ids.length;n++){
				if(ids[n].split("\\$").length==2){
					//This is a keyword, let's find it
					keyword=getTran(ids[n].split("\\$")[0],ids[n].split("\\$")[1] , language);
					s+="<a href='javascript:deleteKeyword(\""+idsField+"\",\""+textField+"\",\""+ids[n]+"\");'><img width='8' src='"+sCONTEXTPATH+"/_img/erase.png'/></a><b>"+keyword+"</b> | ";
				}
			}
		}
		return s;
	}
%>
<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
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
                <script>writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
            <td class="admin2" colspan='2'>&nbsp;</td>
        </tr>
    	<tr><td width='50%' valign='top' colspan='2'><table width='100%'>
        <%
            SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
            TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
            ItemVO oldItemVO = curTran.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
        	String activeEncounterUid="",sRfe="";
            if (oldItemVO != null && oldItemVO.getValue().length()>0) {
            	activeEncounterUid = oldItemVO.getValue();
            }
            else {
                Encounter activeEnc = Encounter.getActiveEncounterOnDate(new Timestamp(curTran.getUpdateTime().getTime()),activePatient.personid);
                if(activeEnc!=null){
                	activeEncounterUid=activeEnc.getUid();
                }
            }
            Encounter encounter = Encounter.getActiveEncounterOnDate(new Timestamp(new SimpleDateFormat("dd/MM/yyyy HH:mm").parse(new SimpleDateFormat("dd/MM/yyyy 23:99").format(curTran.getUpdateTime())).getTime()),activePatient.personid);
            String rfe="";
            if(encounter!=null){
                rfe=ReasonForEncounter.getReasonsForEncounterAsHtml(encounter,sWebLanguage,"_img/icon_delete.gif","deleteRFE($serverid,$objectid)");
                %>
                <tr class="admin">
                    <td align="center"><a href="javascript:openPopup('healthrecord/findRFE.jsp&field=rfe&encounterUid=<%=encounter.getUid()%>&ts=<%=getTs()%>',700,400)"><%=getTran("openclinic.chuk","rfe",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
                </tr>
                <tr>
                    <td id='rfe'>
                        <%=rfe%>
                    </td>
                </tr>
                <%
            }
       	 %>
       	 </table>
       	 </td><td valign='top' colspan='2'><table width='100%'>
         <tr class="admin">
             <td align="center"><a href="javascript:openPopup('healthrecord/findICPC.jsp&ts=<%=getTs()%>&patientuid=<%=activePatient.personid %>',700,400)"><%=getTran("openclinic.chuk","diagnostic",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
         </tr>
         <tr>
             <td id='icpccodes'>
             <%
         	 sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
             curTran = sessionContainerWO.getCurrentTransactionVO();
             Iterator items = curTran.getItems().iterator();
             ItemVO item;

             String sReferenceUID = curTran.getServerId() + "." + curTran.getTransactionId();
             String sReferenceType = "Transaction";
             Hashtable hDiagnoses = Diagnosis.getDiagnosesByReferenceUID(sReferenceUID, sReferenceType);
             Hashtable hDiagnosisInfo;
             String sCode, sGravity, sCertainty;

             while (items.hasNext()) {
                 item = (ItemVO) items.next();
                 if (item.getType().indexOf("ICPCCode") == 0) {
                     sCode = item.getType().substring("ICPCCode".length(), item.getType().length());
                     hDiagnosisInfo = (Hashtable) hDiagnoses.get(sCode);
                     if (hDiagnosisInfo != null) {
                         sGravity = (String) hDiagnosisInfo.get("Gravity");
                         sCertainty = (String) hDiagnosisInfo.get("Certainty");
                     } else {
                         sGravity = "";
                         sCertainty = "";
                     }
         	 %>
         	 <span id="ICPCCode<%=item.getItemId()%>">
                             <img src="<c:url value='/_img/icon_delete.gif'/>" onclick="document.getElementById('ICPCCode<%=item.getItemId()%>').innerHTML='';"/><input type='hidden' name='ICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=item.getValue().trim()%>"/><input type='hidden' name='GravityICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sCertainty%>"/>
                             <%=item.getType().replaceAll("ICPCCode","")%>&nbsp;<%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%></i>
                             <br/>
                       </span>
             <%
                 }
                 else if (item.getType().indexOf("ICD10Code")==0){
                     sCode = item.getType().substring("ICD10Code".length(),item.getType().length());
                     hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
                     if (hDiagnosisInfo != null) {
                         sGravity = (String)hDiagnosisInfo.get("Gravity");
                         sCertainty = (String)hDiagnosisInfo.get("Certainty");
                     } else {
                         sGravity = "";
                         sCertainty = "";
                     }
                     %><span id='ICD10Code<%=item.getItemId()%>'>
                             <img src='<c:url value="/_img/icon_delete.gif"/>' onclick="document.getElementById('ICD10Code<%=item.getItemId()%>').innerHTML='';"/><input type='hidden' name='ICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value='<%=item.getValue().trim()%>'/><input type='hidden' name='GravityICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sCertainty%>"/>
                             <%=item.getType().replaceAll("ICD10Code","")%>&nbsp;<%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>&nbsp;<i>G:<%=sGravity%>/C:<%=sCertainty%></i>
                             <br/>
                       </span>
                     <%
                 }
             }
             %>
             </td>
         </tr>
         </table></td></tr>
         </table>
         <table width='100%'>
         <tr><td colspan='4'><hr color='lightgray'/></td></tr>
         <tr>
         	<td class="admin2" colspan='2' width='70%'>
         		<table width="100%">
         			<tr>
			         	<td class="admin" width='20%'><%=getTran("web","biometrics",sWebLanguage) %></td>
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
			            <td class='admin2'><input <%=setRightClickMini("ITEM_TYPE_BIOMETRY_WEIGHT")%> id="weight" class="text" type="text" size="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_WEIGHT" property="value"/>"/></td>
         			</tr>
         			<tr>
			         	<td class="admin" width='20%'></td>
         				<td class='admin'><%=getTran("openclinic.chuk","temperature",sWebLanguage)%></td>
         				<td class='admin2'>
                        	<input id="temperature" <%=setRightClick("ITEM_TYPE_BIOMETRY_TEMPERATURE")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_TEMPERATURE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_TEMPERATURE" property="value"/>"> °C
                        </td>
         				<td class='admin'><%=getTran("openclinic.chuk","height",sWebLanguage)%></td>
         				<td class='admin2'>
                        	<input id="temperature" <%=setRightClick("ITEM_TYPE_BIOMETRY_HEIGHT")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEIGHT" property="value"/>"> cm
                        </td>
         				<td class='admin' colspan="2"><%=getTran("openclinic.chuk","heartfrequency",sWebLanguage)%></td>
         				<td class='admin2'>
                        	<input id="temperature" <%=setRightClick("ITEM_TYPE_BIOMETRY_HEARTFREQUENCY")%> type="text" class="text" size="3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEARTFREQUENCY" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_BIOMETRY_HEARTFREQUENCY" property="value"/>">/min
                        </td>
         			</tr>
         		</table>
         	</td>
         	<td class='admin2' colspan='2'>&nbsp;</td>
         </tr>
         <tr>
         	<td colspan='2' valign='top' width='70%'>
         		<table width='100%'>
         			<!-- Functional signs -->
         			<tr onclick='selectKeywords("functional.signs.ids","functional.signs.text","functional.signs","keywords")'>
         				<td class='admin' width='20%'>
         					<%=getTran("web","functional.signs",sWebLanguage) %>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr>
			         				<td class='admin2' width='50%'>
			         					<div id='functional.signs.text'><%=getKeywordsHTML((TransactionVO)transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_IDS","functional.signs.text","functional.signs.ids",sWebLanguage) %></div>
			         					<input type='hidden' id='functional.signs.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_COMMENT" property="itemId"/>]>.value" id='functional.signs.comment' cols='40' ><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FUNCTIONALSIGNS_COMMENT" property="value"/></textarea>
			         				</td>
			         				<td class='admin2' width='5%'><img width='16' id='key1' src='<c:url value="/_img/keywords.jpg"/>'/></td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			<!-- Inspection -->
         			<tr onclick='selectKeywords("inspection.ids","inspection.text","inspection","keywords")'>
         				<td class='admin' width='20%'>
         					<%=getTran("web","inspection",sWebLanguage) %>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr>
			         				<td class='admin2' width='50%'>
			         					<div id='inspection.text'><%=getKeywordsHTML((TransactionVO)transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_IDS","inspection.text","inspection.ids",sWebLanguage) %></div>
			         					<input type='hidden' id='inspection.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_COMMENT" property="itemId"/>]>.value" id='inspection.comment' cols='40'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INSPECTION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='5%'><img  width='16' id='key2' src='<c:url value="/_img/keywords.jpg"/>'/></td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			<!-- Palpation -->
         			<tr onclick='selectKeywords("palpation.ids","palpation.text","palpation","keywords")'>
         				<td class='admin' width='20%'>
         					<%=getTran("web","palpation",sWebLanguage) %>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr>
			         				<td class='admin2' width='50%'>
			         					<div id='palpation.text'><%=getKeywordsHTML((TransactionVO)transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_IDS","palpation.text","palpation.ids",sWebLanguage) %></div>
			         					<input type='hidden' id='palpation.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_COMMENT" property="itemId"/>]>.value" id='palpation.comment' cols='40'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PALPATION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='5%'><img  width='16' id='key3' src='<c:url value="/_img/keywords.jpg"/>'/></td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			<!-- Heart ausculation -->
         			<tr onclick='selectKeywords("heart.auscultation.ids","heart.auscultation.text","heart.auscultation","keywords")'>
         				<td class='admin' width='20%'>
         					<%=getTran("web","heart.auscultation",sWebLanguage) %>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr>
			         				<td class='admin2' width='50%'>
			         					<div id='heart.auscultation.text'><%=getKeywordsHTML((TransactionVO)transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_IDS","heart.auscultation.text","heart.auscultation.ids",sWebLanguage) %></div>
			         					<input type='hidden' id='heart.auscultation.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_COMMENT" property="itemId"/>]>.value" id='heart.auscultation.comment' cols='40'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HEARTAUSCULTATION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='5%'><img  width='16' id='key4' src='<c:url value="/_img/keywords.jpg"/>'/></td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			<!-- Lung ausculation -->
         			<tr onclick='selectKeywords("lung.auscultation.ids","lung.auscultation.text","lung.auscultation","keywords")'>
         				<td class='admin' width='20%'>
         					<%=getTran("web","lung.auscultation",sWebLanguage) %>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr>
			         				<td class='admin2' width='50%'>
			         					<div id='lung.auscultation.text'><%=getKeywordsHTML((TransactionVO)transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LUNGAUSCULTATION_IDS","lung.auscultation.text","lung.auscultation.ids",sWebLanguage) %></div>
			         					<input type='hidden' id='lung.auscultation.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LUNGAUSCULTATION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LUNGAUSCULTATION_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LUNGAUSCULTATION_COMMENT" property="itemId"/>]>.value" id='lung.auscultation.comment' cols='40'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LUNGAUSCULTATION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='5%'><img  width='16' id='key5' src='<c:url value="/_img/keywords.jpg"/>'/></td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			<!-- Reference -->
         			<tr onclick='selectKeywords("reference.ids","reference.text","reference","keywords")'>
         				<td class='admin' width='20%'>
         					<%=getTran("web","reference",sWebLanguage) %>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr>
			         				<td class='admin2' width='50%'>
			         					<div id='reference.text'><%=getKeywordsHTML((TransactionVO)transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_IDS","reference.text","reference.ids",sWebLanguage) %></div>
			         					<input type='hidden' id='reference.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_COMMENT" property="itemId"/>]>.value" id='reference.comment' cols='40'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REFERENCE_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='5%'><img  width='16' id='key6' src='<c:url value="/_img/keywords.jpg"/>'/></td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         			<!-- Evacuation -->
         			<tr onclick='selectKeywords("evacuation.ids","evacuation.text","evacuation","keywords")'>
         				<td class='admin' width='20%'>
         					<%=getTran("web","evacuation",sWebLanguage) %>
         				</td>
         				<td>
         					<table width='100%'>
         						<tr>
			         				<td class='admin2' width='50%'>
			         					<div id='evacuation.text'><%=getKeywordsHTML((TransactionVO)transaction,"be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVACUATION_IDS","evacuation.text","evacuation.ids",sWebLanguage) %></div>
			         					<input type='hidden' id='evacuation.ids' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVACUATION_IDS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVACUATION_IDS" property="value"/>"/>
			         				</td>
			         				<td class='admin2'>
			         					<textarea onkeyup="resizeTextarea(this,10)" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVACUATION_COMMENT" property="itemId"/>]>.value" id='evacuation.comment' cols='40'><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EVACUATION_COMMENT" property="value"/></textarea> 
			         				</td>
			         				<td class='admin2' width='5%'><img  width='16' id='key7' src='<c:url value="/_img/keywords.jpg"/>'/></td>
			         			</tr>
         					</table>
         				</td>
         			</tr>
         		</table>
         	</td>
         	<td colspan='2' class='admin2'>
         		<div style='height: 300px; overflow: auto' id='keywords'></div>
         	</td>
         </tr>
         <tr>
            <td class="admin2" colspan='2'>&nbsp;</td>
            <td class="admin2" colspan='2'>
			<%-- BUTTONS --%>
    		<%
      			if (activeUser.getAccessRight("occup.healthcenter.contact.add") || activeUser.getAccessRight("occup.healthcenter.contact.edit")){
    		%>
                <INPUT class="button" type="button" name="save" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>" onclick="doSubmit();"/>
    		<%
      			}
    		%>
                <INPUT class="button" type="button" value="<%=getTran("Web","back",sWebLanguage)%>" onclick="if (checkSaveButton('<%=sCONTEXTPATH%>','<%=getTran("Web.Occup","medwan.common.buttonquestion",sWebLanguage)%>')){window.location.href='<c:url value="/main.do?Page=curative/index.jsp"/>&ts=<%=getTs()%>'}">
            </td>
        </tr>
	</table>    
	<%=ScreenHelper.contextFooter(request)%>
</form>
<script type="text/javascript">
    function doSubmit(){
        document.transactionForm.save.disabled = true;
        document.transactionForm.submit();
    }
    
    function selectKeywords(destinationidfield,destinationtextfield,labeltype,divid){
    	document.getElementById('key1').width='16';
    	document.getElementById('key2').width='16';
    	document.getElementById('key3').width='16';
    	document.getElementById('key4').width='16';
    	document.getElementById('key5').width='16';
    	document.getElementById('key6').width='16';
    	document.getElementById('key7').width='16';
    	if(labeltype=='functional.signs'){
			document.getElementById('key1').width='32';
		}
    	else if(labeltype=='inspection'){
			document.getElementById('key2').width='32';
		}
    	else if(labeltype=='palpation'){
			document.getElementById('key3').width='32';
		}
    	else if(labeltype=='heart.auscultation'){
			document.getElementById('key4').width='32';
		}
    	else if(labeltype=='lung.auscultation'){
			document.getElementById('key5').width='32';
		}
    	else if(labeltype=='reference'){
			document.getElementById('key6').width='32';
		}
    	else if(labeltype=='evacuation'){
			document.getElementById('key7').width='32';
		}
    	var params = '';
        var today = new Date();
        var url= '<c:url value="/healthrecord/ajax/getKeywords.jsp"/>?destinationidfield='+destinationidfield+'&destinationtextfield='+destinationtextfield+'&labeltype='+labeltype+'&ts='+today;
        new Ajax.Request(url,{
                method: "POST",
                parameters: params,
                onSuccess: function(resp){
                    $(divid).innerHTML=resp.responseText;
                },
                onFailure: function(){
                    $(divid).innerHTML="";
                }
            }
        );
    }
    
	function selectKeyword(id,label,destinationidfield,destinationtextfield){
		var ids=document.getElementById(destinationidfield).value;
		if((ids+";").indexOf(id+";")<=-1){
			document.getElementById(destinationidfield).value=ids+";"+id;
			document.getElementById(destinationtextfield).innerHTML+="<a href='javascript:deleteKeyword(\""+destinationidfield+"\",\""+destinationtextfield+"\",\""+id+"\");'><img width='8' src='<c:url value="/_img/erase.png"/>'/></a><b>"+label+"</b> | ";
		}
	}
	
	function deleteKeyword(destinationidfield,destinationtextfield,id){
		var newids="";
		var ids=document.getElementById(destinationidfield).value.split(";");
		for(n=0;n<ids.length;n++){
			if(ids[n].indexOf("$")>-1){
				if(id!=ids[n]){
					newids+=ids[n]+";";
				}
			}
		}
		document.getElementById(destinationidfield).value=newids;
		var newlabels="";
		var labels=document.getElementById(destinationtextfield).innerHTML.split(" | ");
		for(n=0;n<labels.length;n++){
			if(labels[n].trim().length>0 && labels[n].indexOf(id)<=-1){
				newlabels+=labels[n]+" | ";
			}
		}
		document.getElementById(destinationtextfield).innerHTML=newlabels;	
	}
	
	  function deleteDiagnosis(itemid){
	      if(confirm("<%=getTran("Web","AreYouSure",sWebLanguage)%>")){
	    	  document.getElementById(itemid).innerHTML='';
	      }
	  }

	  function deleteRFE(serverid,objectid){
	      if(confirm("<%=getTran("Web","AreYouSure",sWebLanguage)%>")){
	          var params = "serverid="+serverid+"&objectid="+objectid+"&encounterUid=<%=activeEncounterUid%>&language=<%=sWebLanguage%>";
	          var today = new Date();
	          var url= '<c:url value="/healthrecord/deleteRFE.jsp"/>?ts='+today;
	          new Ajax.Request(url,{
	                  method: "GET",
	                  parameters: params,
	                  onSuccess: function(resp){
	                      rfe.innerHTML=resp.responseText;
	                  },
	                  onFailure: function(){
	                  }
	              }
	          );
	      }
	  }

	  selectKeywords("functional.signs.ids","functional.signs.text","functional.signs","keywords");
</script>