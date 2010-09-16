<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<table width="100%" height="100%" cellspacing="0" cellpadding="0">
	<tr>
		<td width="50%" valign="top">
			<table width="100%" cellspacing="1" cellpadding="0">
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.localisation",sWebLanguage)%>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.fosa",sWebLanguage)%>
					</td>
					<td class="admin2">
                        <input type="radio" onDblClick="uncheckRadio(this);" id="fosa_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FOSA" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FOSA;value=medwan.common.yes" property="value" outputString="checked"/> onclick=" checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"fosa_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="fosa_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FOSA" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FOSA;value=medwan.common.no" property="value" outputString="checked"/> onclick=" checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"fosa_no")%>
                        <div id="fosa_block" style="display:none;">
							<br/><br/>
							<%=getTran("openclinic.chuk","tracnet.psychosocial.fosa.suivi",sWebLanguage)%>
							<br/>
							<textarea id="fosa_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FOSA_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FOSA_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.déménagé",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select class="text" id="demenage" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DEMENAGE" property="itemId"/>]>.value" onchange="checkPage1Settings();">
		                    <option/>
		                    <%
		                        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        String sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_DEMENAGE");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.déménagé.fois",sType,sWebLanguage,false,true)%>
		                </select>
		                <div id="demenage_block" style="display:none;">
							<br/>
							<br/>
							<%=getTran("openclinic.chuk","tracnet.psychosocial.déménagé.suivi",sWebLanguage)%>
							<br/>
							<textarea id="demenage_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DEMENAGE_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DEMENAGE_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.visite.domicile",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="visite_domicile_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISITE_DOMICILE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISITE_DOMICILE;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"visite_domicile_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="visite_domicile_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISITE_DOMICILE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISITE_DOMICILE;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"visite_domicile_no")%>
                        <br/>
                        <br/>
                        <%=getTran("openclinic.chuk","tracnet.psychosocial.visite.domicile.importance",sWebLanguage)%>
                        <div id="visite_domicile_block" style="display:none;">
                        	<br/>
	                        <%=getTran("openclinic.chuk","tracnet.psychosocial.visite.domicile.suivi",sWebLanguage)%>
	                        <br/>
							<textarea id="visite_domicile_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISITE_DOMICILE_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VISITE_DOMICILE_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.statut.social",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select class="text" id="statut_social" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_STATUT_SOCIAL" property="itemId"/>]>.value" onchange="checkPage1Settings();">
		                    <option/>
		                    <%
		                        sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_STATUT_SOCIAL");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.statut",sType,sWebLanguage,false,true)%>
		                </select>
					</td>
				</tr>
			</table>
		</td>
		<td width="50%" valign="top">
			<table width="100%" cellspacing="1" cellpadding="0">
				<tr class="admin" width="<%=sTDAdminWidth%>">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.info.couple.risques",sWebLanguage)%>	
					</td>
				</tr>
				<tr id="statut_social_block1" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.conjoint.name",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input id="name_conjoint" type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NAME_CONJOINT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NAME_CONJOINT" property="value"/>">
					</td>
				</tr>
				<tr id="statut_social_block2" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.conjoint.age",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input id="age_conjoint" type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AGE_CONJOINT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_AGE_CONJOINT" property="value"/>">
					</td>
				</tr>
				<tr id="statut_social_block3" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.vih",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="vih_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"vih_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="vih_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"vih_no")%>
                        <div  id="vih_block" style="display:none;"> 
	                        <br/>
	                        <br/>
	                        <%=getTran("openclinic.chuk","tracnet.psychosocial.vih.suivi",sWebLanguage)%>
	                        <br/>
							<textarea id="vih_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH_SUIVI" property="value"/></textarea>
						</div>
					</td>
				</tr>
				<tr id="statut_social_block4" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.sérologique",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select id="serologique" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEROLOGIQUE" property="itemId"/>]>.value">
		                    <option/>
		                    <%
		                        sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_SEROLOGIQUE");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.sérologique",sType,sWebLanguage,false,true)%>
		                </select>
					</td>
				</tr>
				<tr id="statut_social_block5" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.vih.prise.charge",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="vih_prise_charge_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH_PRISE_CHARGE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH_PRISE_CHARGE;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"vih_prise_charge_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="vih_prise_charge_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH_PRISE_CHARGE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH_PRISE_CHARGE;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"vih_prise_charge_no")%>
                        <div id="vih_prise_charge_block" style="display:none;">
	                        <br/>
	                        <br/>
	                        <%=getTran("openclinic.chuk","tracnet.psychosocial.vih.prise.charge.suivi",sWebLanguage)%>
	                        <br/>
							<textarea id="vih_prise_charge_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH_PRISE_CHARGE_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VIH_PRISE_CHARGE_SUIVI" property="value"/></textarea>
						</div>
					</td>
				</tr>
				<tr id="statut_social_block6" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.prise.charge.ou",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="text" id="prise_charge_ou" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRISE_CHARGE_OU" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRISE_CHARGE_OU" property="value"/>" onchange="checkPage1Settings();">
						<div id="prise_charge_ou_block" style="display:none;">
							<br/>
							<br/>
	                        <%=getTran("openclinic.chuk","tracnet.psychosocial.prise.charge.ou.suivi",sWebLanguage)%>
	                        <br/>
							<textarea id="prise_charge_ou_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRISE_CHARGE_OU_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRISE_CHARGE_OU_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
				<tr id="statut_social_block7" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.incompréhensions.conjoint",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea id="incomprehensions_conjoint" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INCOMPREHENSIONS_CONJOINT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_INCOMPREHENSIONS_CONJOINT" property="value"/></textarea>
					</td>
				</tr>
				<tr id="statut_social_block8" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.séropositive.conjoint",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="seropositive_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEROPOSITIVE_CONJOINT" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEROPOSITIVE_CONJOINT;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"seropositive_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="seropositive_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEROPOSITIVE_CONJOINT" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEROPOSITIVE_CONJOINT;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"seropositiv_no")%>
                        <div id="seropositive_block" style="display:none;">
	                        <br/>
	                        <br/>
	                        <%=getTran("openclinic.chuk","tracnet.psychosocial.séropositive.conjoint.suivi",sWebLanguage)%>
	                        <br/>
							<textarea id="seropositive_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEROPOSITIVE_CONJOINT_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SEROPOSITIVE_CONJOINT_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
				<tr id="statut_social_block9" style="display:none;">
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.usage.condoms.conjoint",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select class="text" id="usage_condoms_conjoint" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_USAGE_CONDOMS_CONJOINT" property="itemId"/>]>.value" onchange="checkPage1Settings();">
		                    <option/>
		                    <%
		                        sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_USAGE_CONDOMS_CONJOINT");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.usage.condoms",sType,sWebLanguage,false,true)%>
		                </select>
		                <div id="usage_condoms_conjoint_block" style="display:none;">
			                <br/>
			                <br/>
	                        <%=getTran("openclinic.chuk","tracnet.psychosocial.usage.condoms.conjoint.suivi",sWebLanguage)%>
	                        <br/>
							<textarea id="usage_condoms_conjoint_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_USAGE_CONDOMS_CONJOINT_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_USAGE_CONDOMS_CONJOINT_SUIVI" property="value"/></textarea>
						</div>	
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.partenaires.occasionnels",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="partenaires_occa_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARTENAIRES_OCCASIONNELS" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARTENAIRES_OCCASIONNELS;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"partenaires_occa_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="partenaires_occa_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARTENAIRES_OCCASIONNELS" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PARTENAIRES_OCCASIONNELS;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage1Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"partenaires_occa_no")%>
                        <div id="partenaires_occa_block" style="display:none;">
	                        <br/>
	                        <br/>
	                        <%=getTran("openclinic.chuk","tracnet.psychosocial.partenaires.occasionnels.nombre",sWebLanguage)%>&nbsp;
	                        <input id="partenaires_occa_nombre" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NOMBRE_PARTENAIRES_OCCASIONNELS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NOMBRE_PARTENAIRES_OCCASIONNELS" property="value"/>" onblur="isNumber(this);">
	                    </div>    
					</td>
				</tr>
				<tr>
					<td class="admin" width="<%=sTDAdminWidth%>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.partenaires.occasionnels.condoms",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select class="text" id="partenaires_occasionnels_condoms" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_USAGE_CONDOMS_PARTENAIRES_OCCA" property="itemId"/>]>.value" onchange="checkPage1Settings();">
		                    <option/>
		                    <%
		                        sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_USAGE_CONDOMS_PARTENAIRES_OCCA");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.usage.condoms",sType,sWebLanguage,false,true)%>
		                </select>
		                <div id="partenaires_occasionnels_condoms_block" style="display:none;">
			                <br/>
			                <br/>
	                        <%=getTran("openclinic.chuk","tracnet.psychosocial.partenaires.occasionnels.condoms.suivi",sWebLanguage)%>
	                        <br/>
							<textarea id="partenaires_occasionnels_condoms_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_USAGE_CONDOMS_PARTENAIRES_OCCA_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_USAGE_CONDOMS_PARTENAIRES_OCCA_SUIVI" property="value"/></textarea>
						</div>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>