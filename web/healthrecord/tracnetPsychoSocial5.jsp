<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<table width="100%" height="100%" cellspacing="1" cellpadding="0">
	<tr>
		<td width="50%" style="vertical-align:top;">
			<table width="100%" cellspacing="1" cellpadding="0">
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.autre.soutien.communautaires",sWebLanguage)%>	
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.services.communautaires",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_COMMUNAUTAIRES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_COMMUNAUTAIRES" property="value"/></textarea>
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.services.communautaires.oui",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_COMMUNAUTAIRES_OUI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_COMMUNAUTAIRES_OUI" property="value"/></textarea>					
					</td>
				</tr>
			</table>
		</td>
		<td width="50%" style="vertical-align:top;">
			<table width="100%" cellspacing="1" cellpadding="0">
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.notes.apres.evaluation",sWebLanguage)%>	
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.conclusion.première.séance",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONCLUSION_PREMIERE_SEANCE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONCLUSION_PREMIERE_SEANCE" property="value"/></textarea>
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.obstacles.adhérence.counsellor",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBSTACLES_ADHERENCE_COUNSELLOR" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OBSTACLES_ADHERENCE_COUNSELLOR" property="value"/></textarea>					
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.questions.problèmes.spécifique.patient",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_QUESTIONS_PROBLEMES_SPECIFIQUES_PATIENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_QUESTIONS_PROBLEMES_SPECIFIQUES_PATIENT" property="value"/></textarea>					
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.orientations",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORIENTATIONS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORIENTATIONS" property="value"/></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
	