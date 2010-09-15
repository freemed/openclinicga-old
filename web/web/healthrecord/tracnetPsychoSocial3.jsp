<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<table width="100%" height="100%" cellspacing="1" cellpadding="0">
	<tr>
		<td width="50%" valign="top">
			<table width="100%" cellspacing="1" cellpadding="0">
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.besoins",sWebLanguage)%>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.repas",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="text" id="repas" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REPAS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REPAS" property="value"/>" onblur="isNumber(this);" onchange="checkPage3Settings();">
						<div id="repas_block" style="display:none;">
							<br/><br/>
							<%=getTran("openclinic.chuk","tracnet.psychosocial.repas.suivi",sWebLanguage)%>
							<br/>
							<textarea id="repas_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REPAS_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REPAS_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.eau.portable",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EAU_PORTABLE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_EAU_PORTABLE" property="value"/></textarea>						
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.électricité",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="electricite_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ELECTRICITE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ELECTRICITE;value=medwan.common.yes" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"electricite_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="electricite_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ELECTRICITE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ELECTRICITE;value=medwan.common.no" property="value" outputString="checked"/>><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"electricite_no")%>				
					</td>
				</tr>
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.mutuelle.de.sante",sWebLanguage)%>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.santé.mutuelle",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="sante_mutuelle_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage3Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"sante_mutuelle_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="sante_mutuelle_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage3Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"sante_mutuelle_no")%>
                        <div id="sante_mutuelle_block" style="display:none;">
							<br/><br/>
							<%=getTran("openclinic.chuk","tracnet.psychosocial.santé.mutuelle.suivi",sWebLanguage)%>
							<br/>
							<textarea id="sante_mutuelle_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE_SUIVI" property="value"/></textarea>
						</div>
					</td>
				</tr>
				<tr id="sante_mutuelle1" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.santé.mutuelle.quelle",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea id="sante_mutuelle_quelle" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE_QUELLE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE_QUELLE" property="value"/></textarea>
					</td>
				</tr>
				<tr id="sante_mutuelle2" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.santé.mutuelle.couvre",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea id="sante_mutuelle_couvre" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE_COUVRE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SANTE_MUTUELLE_COUVRE" property="value"/></textarea>
					</td>
				</tr>
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.transport",sWebLanguage)%>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.moyen.transport",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOYEN_TRANSPORT" property="itemId"/>]>.value">
		                    <option/>
		                    <%
		                        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        String sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_MOYEN_TRANSPORT");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.transport",sType,sWebLanguage,false,true)%>
		                </select>
		                <br/><br/>
		                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOYEN_TRANSPORT_AUTRE" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MOYEN_TRANSPORT_AUTRE" property="value"/></textarea>
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.temps.transport",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TEMPS_TRANSPORT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TEMPS_TRANSPORT" property="value"/></textarea>
					</td>
				</tr>
			</table>
		</td>
		<td width="50%" valign="top">
			<table width="100%" cellspacing="1" cellpadding="0">
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.adherence",sWebLanguage)%>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.appris.statut",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_APPRIS_STATUT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_APPRIS_STATUT" property="value"/></textarea>
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.contraintes.traitement",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="checkbox" id="contrainte1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRAINTE1_CONTRAINTES_TRAITEMENT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRAINTE1_CONTRAINTES_TRAITEMENT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuck","contrainte1.contraintes.traitement",sWebLanguage,"contrainte1")%><br/>
                        <input type="checkbox" id="contrainte2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRAINTE2_CONTRAINTES_TRAITEMENT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRAINTE2_CONTRAINTES_TRAITEMENT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuck","contrainte2.contraintes.traitement",sWebLanguage,"contrainte2")%><br/>
                        <input type="checkbox" id="contrainte3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRAINTE3_CONTRAINTES_TRAITEMENT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRAINTE3_CONTRAINTES_TRAITEMENT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuck","contrainte3.contraintes.traitement",sWebLanguage,"contrainte3")%><br/>
                        <input type="checkbox" id="contrainte4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRAINTE4_CONTRAINTES_TRAITEMENT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRAINTE4_CONTRAINTES_TRAITEMENT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuck","contrainte4.contraintes.traitement",sWebLanguage,"contrainte4")%><br/><br/>
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=getTran("openclinic.chuck","contrainte5.contraintes.traitement",sWebLanguage)%><br/>
                        <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRAINTE5_CONTRAINTES_TRAITEMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTRAINTE5_CONTRAINTES_TRAITEMENT" property="value"/></textarea>
					</td>
				</tr>
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.medecine.traditionnelle",sWebLanguage)%>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.autre.prestataires",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="autre_prestataires_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUTRE_PRESTATAIRES" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUTRE_PRESTATAIRES;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage3Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"autre_prestataires_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="autre_prestataires_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUTRE_PRESTATAIRES" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUTRE_PRESTATAIRES;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage3Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"autre_prestataires_no")%>
					</td>
				</tr>
				<tr id="autre_prestataires1" style="display:block;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.autre.prestataires.oui",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea id="autre_prestataires_oui" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUTRE_PRESTATAIRES_OU" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AUTRE_PRESTATAIRES_OU" property="value"/></textarea>
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.medicament.base.herbes.médicinales",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="herbes_médicinales_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HERBES_MEDICINALES" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HERBES_MEDICINALES;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage3Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"herbes_médicinales_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="herbes_médicinales_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HERBES_MEDICINALES" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HERBES_MEDICINALES;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage3Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"herbes_médicinales_no")%>
					</td>
				</tr>
				<tr id="medicament_base_herbes_med1" style="display:block;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.herbes.médicinales.inclure.description.servent.pour",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea id="herbes_medicinales_inclure" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HERBES_MEDICINALES_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_HERBES_MEDICINALES_DESCRIPTION" property="value"/></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>