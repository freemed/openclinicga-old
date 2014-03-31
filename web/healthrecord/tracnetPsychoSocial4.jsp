<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<table width="100%" height="100%" cellspacing="1" cellpadding="0">
	<tr>
		<td width="50%" style="vertical-align:top;">
			<table width="100%" cellspacing="1" cellpadding="0">
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.connaissance.maladie",sWebLanguage)%>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.vih.sida",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH_SIDA" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH_SIDA" property="value"/></textarea>
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.services.arv",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="service_arv_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_ARV" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_ARV;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"service_arv_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="service_arv_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_ARV" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_ARV;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"service_arv_no")%>
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.services.arv.oui",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_ARV_OUI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_ARV_OUI" property="value"/></textarea>
						<div id="service_arv_oui_block" style="display:none">
							<br/><br/>
							<%=getTran("openclinic.chuk","tracnet.psychosocial.services.arv.oui.suivi",sWebLanguage)%>
							<br/>
							<textarea id="service_arv_oui_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_ARV_OUI_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVICES_ARV_OUI_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.soutien.proches",sWebLanguage)%>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.révélé.statut.proches",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="revele_statut_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVELE_STATUT_PROCHES" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVELE_STATUT_PROCHES;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage4Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"revele_statut_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="revele_statut_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVELE_STATUT_PROCHES" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVELE_STATUT_PROCHES;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage4Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"revele_statut_no")%>
                        <div id="revele_statut_proches_block" style="display:none;">
							<br/><br/>
							<%=getTran("openclinic.chuk","tracnet.psychosocial.révélé.statut.proches.suivi",sWebLanguage)%>
							<br/>
							<textarea id="revele_statut_proches_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVELE_STATUT_PROCHES_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVELE_STATUT_PROCHES_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.reaction",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REACTION" property="value"/></textarea>
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.trois.personnes.plu.proches.révélé.tableau",sWebLanguage)%>
					</td>
					<td class="admin2">
						<table cellpadding="0" cellspacing="1" border="1">
							<tr class="admin">
								<td colspan="2">
									<%=getTran("openclinic.chuk","tracnet.psychosocial.personne",sWebLanguage)%> 1
								</td>
							</tr>
							<tr>
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.nom",sWebLanguage)%></td>
								<td class="admin2">
									<input type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE1_NOM" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE1_NOM" property="value"/>">								
								</td>
							</tr>	
							<tr>	
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.relation",sWebLanguage)%></td>
								<td class="admin2">
									<input type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE1_RELATION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE1_RELATION" property="value"/>">								
								</td>
							</tr>	
							<tr>
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.habite.avec",sWebLanguage)%></td>	
								<td class="admin2">
									<input type="radio" onDblClick="uncheckRadio(this);" id="habite_avec1_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE1_HABITE_AVEC_PATIENT" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE1_HABITE_AVEC_PATIENT;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"habite_avec1_yes")%>
                        			<input type="radio" onDblClick="uncheckRadio(this);" id="habite_avec1_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE1_HABITE_AVEC_PATIENT" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE1_HABITE_AVEC_PATIENT;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"habite_avec1_no")%>
								</td>
							</tr>	
							<tr>	
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.contact.téléphonique",sWebLanguage)%></td>
								<td class="admin2">
									<input type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE1_CONTACT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE1_CONTACT" property="value"/>">								
								</td>
							</tr>
						</table>	
						<table cellpadding="0" cellspacing="1" border="1">	
							<tr class="admin">
								<td colspan="2">
									<%=getTran("openclinic.chuk","tracnet.psychosocial.personne",sWebLanguage)%> 2
								</td>
							</tr>
							<tr>
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.nom",sWebLanguage)%></td>
								<td class="admin2">
									<input type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE2_NOM" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE2_NOM" property="value"/>">								
								</td>
							</tr>	
							<tr>	
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.relation",sWebLanguage)%></td>
								<td class="admin2">
									<input type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE2_RELATION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE2_RELATION" property="value"/>">								
								</td>
							</tr>
							<tr>
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.habite.avec",sWebLanguage)%></td>
								<td class="admin2">
									<input type="radio" onDblClick="uncheckRadio(this);" id="habite_avec2_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE2_HABITE_AVEC_PATIENT" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_PERSONNE2_HABITE_AVEC_PATIENT;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"habite_avec2_yes")%>
                        			<input type="radio" onDblClick="uncheckRadio(this);" id="habite_avec2_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE2_HABITE_AVEC_PATIENT" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_PERSONNE21_HABITE_AVEC_PATIENT;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"habite_avec2_no")%>
								</td>
							</tr>	
							<tr>	
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.contact.téléphonique",sWebLanguage)%></td>
								<td class="admin2">
									<input type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE2_CONTACT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE2_CONTACT" property="value"/>">								
								</td>
							</tr>
						</table>	
						<table cellpadding="0" cellspacing="1" border="1">
							<tr class="admin">
								<td colspan="2">
									<%=getTran("openclinic.chuk","tracnet.psychosocial.personne",sWebLanguage)%> 3
								</td>
							</tr>	
							<tr>
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.nom",sWebLanguage)%></td>
								<td class="admin2">
									<input type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE3_NOM" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE3_NOM" property="value"/>">								
								</td>
							</tr>	
							<tr>	
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.relation",sWebLanguage)%></td>
								<td class="admin2">
									<input type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE3_RELATION" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE3_RELATION" property="value"/>">								
								</td>
							</tr>
							<tr>
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.habite.avec",sWebLanguage)%></td>
								<td class="admin2">
									<input type="radio" onDblClick="uncheckRadio(this);" id="habite_avec3_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE3_HABITE_AVEC_PATIENT" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE3_HABITE_AVEC_PATIENT;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"habite_avec3_yes")%>
                        			<input type="radio" onDblClick="uncheckRadio(this);" id="habite_avec3_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE3_HABITE_AVEC_PATIENT" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE3_HABITE_AVEC_PATIENT;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"habite_avec3_no")%>
								</td>
							</tr>	
							<tr>	
								<td class="admin"><%=getTran("openclinic.chuk","tracnet.psychosocial.reaction.contact.téléphonique",sWebLanguage)%></td>
								<td class="admin2">
									<input type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE3_CONTACT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONNE3_CONTACT" property="value"/>">
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.pas.révélé.statut.proches",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RAISON_PAS_REVELE_PROCHES" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RAISON_PAS_REVELE_PROCHES" property="value"/></textarea>
					</td>
				</tr>
			</table>
		</td>
		<td width="50%" style="vertical-align:top;">
			<table width="100%" cellspacing="1" cellpadding="0">
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.parrain.marraine",sWebLanguage)%>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.choisi.parrain.marraine",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="choisi_parrain_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CHOISI_PARRAIN_MARRAINE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CHOISI_PARRAIN_MARRAINE;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage4Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"choisi_parrain_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="choisi_parrain_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CHOISI_PARRAIN_MARRAINE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CHOISI_PARRAIN_MARRAINE;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage4Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"choisi_parrain_no")%>
                        <div id="choisi_parrain_marraine_block" style="display:none;">
							<br/><br/>
							<%=getTran("openclinic.chuk","tracnet.psychosocial.santé.mutuelle.suivi",sWebLanguage)%>
							<br/>
							<textarea id="sante_mutuelle_suivi_parrain" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
				<tr id="choisi_parrain1" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.nom.prenom.parrain.marraine",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input id="parrain1" type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NOM_PARRAIN_MARRAINE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NOM_PARRAIN_MARRAINE" property="value"/>">
					</td>
				</tr>
				<tr id="choisi_parrain2" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.age.parrain.marraine",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input id="parrain2" type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AGE_PARRAIN_MARRAINE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AGE_PARRAIN_MARRAINE" property="value"/>">
					</td>
				</tr>
				<tr id="choisi_parrain3" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.sexe.parrain.marraine",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input id="parrain3" type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEXE_PARRAIN_MARRAINE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEXE_PARRAIN_MARRAINE" property="value"/>">
					</td>
				</tr>
				<tr id="choisi_parrain4" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.résidence.parrain.marraine",sWebLanguage)%>
					</td>
					<td class="admin2">
						<table>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.résidence.parrain.marraine.province",sWebLanguage)%></td>
								<td>
									<input id="parrain4_a" type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESIDENCE_PARRAIN_MARRAINE_PROVINCE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESIDENCE_PARRAIN_MARRAINE_PROVINCE" property="value"/>">
								</td>
							</tr>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.résidence.parrain.marraine.district",sWebLanguage)%></td>
								<td>
									<input id="parrain4_b" type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESIDENCE_PARRAIN_MARRAINE_DISTRICT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESIDENCE_PARRAIN_MARRAINE_DISTRICT" property="value"/>">
								</td>
							</tr>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.résidence.parrain.marraine.secteur",sWebLanguage)%></td>
								<td>
									<input id="parrain4_c" type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESIDENCE_PARRAIN_MARRAINE_SECTEUR" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESIDENCE_PARRAIN_MARRAINE_SECTEUR" property="value"/>">
								</td>
							</tr>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.résidence.parrain.marraine.cellule",sWebLanguage)%></td>
								<td>
									<input id="parrain4_d" type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESIDENCE_PARRAIN_MARRAINE_CELLULE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESIDENCE_PARRAIN_MARRAINE_CELLULE" property="value"/>">
								</td>
							</tr>
							<tr>
								<td colspan="2">&nbsp;</td>
							</tr>
							<tr>
								<td colspan="2">
									<%=getTran("openclinic.chuk","tracnet.psychosocial.résidence.parrain.marraine.trop.loin",sWebLanguage)%>
								</td>
							</tr>
							<tr>
								<td colspan="2">
									<textarea id="parrain4_e" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESIDENCE_PARRAIN_MARRAINE_TROP_LOIN" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RESIDENCE_PARRAIN_MARRAINE_TROP_LOIN" property="value"/></textarea>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr id="choisi_parrain5" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.parrain.marraine.téléphone",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input id="parrain5" type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_TELEPHONE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_TELEPHONE" property="value"/>">											
					</td>
				</tr>
				<tr id="choisi_parrain6" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.parrain.marraine.contact",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input id="parrain6" type="text" class="text" size="25" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_AUTRES_CONTACT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_AUTRES_CONTACT" property="value"/>">
					</td>
				</tr>
				<tr id="choisi_parrain7" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.instruction.parrain.marraine",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select id="parrain7" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_INSTRUCTION" property="itemId"/>]>.value">
		                    <option/>
		                    <%
		                        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        String sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_PARRAIN_MARRAINE_INSTRUCTION");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.niveau.instruction",sType,sWebLanguage,false,true)%>
		                </select>
					</td>
				</tr>
				<tr id="choisi_parrain8" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.profession.parrain.marraine",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select id="parrain_instruction" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_PROFESSION" property="itemId"/>]>.value" onchange="checkPage4Settings();">
		                    <option/>
		                    <%
		                        sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_PARRAIN_MARRAINE_PROFESSION");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.profession",sType,sWebLanguage,false,true)%>
		                </select><br/>
		                <input id="parrain_instruction_autre" type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_PROFESSION_AUTRE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_PROFESSION_AUTRE" property="value"/>">
					</td>
				</tr>
				<tr id="choisi_parrain9" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.parrain.assister.sessions.education.vih.sida",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="assister_sessions_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_ASSISTER_SESSIONS" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_ASSISTER_SESSIONS;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage4Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"assister_sessions_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="assister_sessions_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_ASSISTER_SESSIONS" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_ASSISTER_SESSIONS;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage4Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"assister_sessions_no")%>
                        <div id="parrain_assister_sessions_education_block" style="display:none;">
							<br/><br/>
							<%=getTran("openclinic.chuk","tracnet.psychosocial.santé.mutuelle.suivi",sWebLanguage)%>
							<br/>
							<textarea  id="parrain9" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_ASSISTER_SESSIONS_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARRAIN_MARRAINE_ASSISTER_SESSIONS_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>