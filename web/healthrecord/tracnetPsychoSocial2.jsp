<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
<table width="100%" height="100%" cellspacing="1" cellpadding="0">
	<tr>
		<td width="50%" style="vertical-align:top;">
			<table width="100%" cellspacing="1" cellpadding="0">
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.enfants",sWebLanguage)%>	
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.composition.famille",sWebLanguage)%>
					</td>
					<td class="admin2">
						<table>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.type",sWebLanguage)%></td>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.nombre",sWebLanguage)%></td>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.nombre.charge",sWebLanguage)%></td>
							</tr>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.enfants.moins.six",sWebLanguage)%></td>
								<td>
									<input id="composition_type1_nombre" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE1_NOMBRE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE1_NOMBRE" property="value"/>" onblur="isNumber(this);" onchange="calculateCompositionTotal();">
								</td>
								<td>
									<input id="composition_type1_nombre_en_charge" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE1_NOMBRE_EN_CHARGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE1_NOMBRE_EN_CHARGE" property="value"/>" onblur="isNumber(this);" onchange="calculateCompositionTotal();">								
								</td>
							</tr>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.enfants.plus.six.scolarisés",sWebLanguage)%></td>
								<td>
									<input id="composition_type2_nombre" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE2_NOMBRE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE2_NOMBRE" property="value"/>" onblur="isNumber(this);" onchange="calculateCompositionTotal();">
								</td>
								<td>
									<input id="composition_type2_nombre_en_charge" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE2_NOMBRE_EN_CHARGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE2_NOMBRE_EN_CHARGE" property="value"/>" onblur="isNumber(this);" onchange="calculateCompositionTotal();">
								</td>
							</tr>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.enfants.plus.six.non.scolarisés",sWebLanguage)%></td>
								<td>
									<input id="composition_type3_nombre" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE3_NOMBRE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE3_NOMBRE" property="value"/>" onblur="isNumber(this);" onchange="calculateCompositionTotal();">
								</td>
								<td>
									<input id="composition_type3_nombre_en_charge" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE3_NOMBRE_EN_CHARGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE3_NOMBRE_EN_CHARGE" property="value"/>" onblur="isNumber(this);" onchange="calculateCompositionTotal();">
								</td>
							</tr>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.adultes",sWebLanguage)%></td>
								<td>
									<input id="composition_type4_nombre" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE4_NOMBRE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE4_NOMBRE" property="value"/>" onblur="isNumber(this);" onchange="calculateCompositionTotal();">
								</td>
								<td>
									<input id="composition_type4_nombre_en_charge" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE4_NOMBRE_EN_CHARGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE4_NOMBRE_EN_CHARGE" property="value"/>" onblur="isNumber(this);" onchange="calculateCompositionTotal();">
								</td>
							</tr>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.total",sWebLanguage)%></td>
								<td>
									<input id="composition_type_total_nombre" readonly="readonly" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE5_NOMBRE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE5_NOMBRE" property="value"/>" onblur="isNumber(this);">
								</td>
								<td>
									<input id="composition_type_total_nombre_en_charge" readonly="readonly" type="text" class="text" size="5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE5_NOMBRE_EN_CHARGE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMPOSITION_TYPE5_NOMBRE_EN_CHARGE" property="value"/>" onblur="isNumber(this);">
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.enfants.encore",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="enfants_encore_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENFANTS_ENCORE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENFANTS_ENCORE;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage2Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"enfants_encore_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="enfants_encore_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENFANTS_ENCORE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENFANTS_ENCORE;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage2Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"enfants_encore_no")%>
                        <div id="enfants_encore_block" style="display:none">
							<br/><br/>
							<%=getTran("openclinic.chuk","tracnet.psychosocial.enfants.encore.suivi",sWebLanguage)%>
							<br/>
							<textarea id="enfants_encore_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENFANTS_ENCORE_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ENFANTS_ENCORE_SUIVI" property="value"/></textarea>
						</div>
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.planning.familial",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="planning_familial_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PLANNING_FAMILIAL" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PLANNING_FAMILIAL;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage2Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"planning_familial_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="planning_familial_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PLANNING_FAMILIAL" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PLANNING_FAMILIAL;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage2Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"planning_familial_no")%>
                        <div id="planning_familial_block" style="display:none;">
							<br/><br/>
							<%=getTran("openclinic.chuk","tracnet.psychosocial.planning.familial.suivi",sWebLanguage)%>
							<br/>
							<textarea id="planning_familial_suivi" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PLANNING_FAMILIAL_SUIVI" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PLANNING_FAMILIAL_SUIVI" property="value"/></textarea>
						</div>						
					</td>
				</tr>
				<tr id="planning_familial1" style="display:none;">		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.methode.planning.familial",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="checkbox" id="methode1" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE1_PLANNING_FAMILIAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE1_PLANNING_FAMILIAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuck","methode1.plannging.familial",sWebLanguage,"methode1")%><br/>
                        <input type="checkbox" id="methode2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE2_PLANNING_FAMILIAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE2_PLANNING_FAMILIAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuck","methode2.plannging.familial",sWebLanguage,"methode2")%><br/>
                        <input type="checkbox" id="methode3" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE3_PLANNING_FAMILIAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE3_PLANNING_FAMILIAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuck","methode3.plannging.familial",sWebLanguage,"methode3")%><br/>
                        <input type="checkbox" id="methode4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE4_PLANNING_FAMILIAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE4_PLANNING_FAMILIAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuck","methode4.plannging.familial",sWebLanguage,"methode4")%><br/>
                        <input type="checkbox" id="methode5" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE5_PLANNING_FAMILIAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE5_PLANNING_FAMILIAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuck","methode5.plannging.familial",sWebLanguage,"methode5")%><br/>
                        <input type="checkbox" id="methode6" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE6_PLANNING_FAMILIAL" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_METHODE6_PLANNING_FAMILIAL;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true"/><%=getLabel("openclinic.chuck","methode6.plannging.familial",sWebLanguage,"methode6")%>
					</td>
				</tr>
				<tr id="planning_familial2" style="display:none;">		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.fréquence.planning.familial",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select id="planning_familial_frequence" class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_FREQUENCE_PLANNING" property="itemId"/>]>.value">
		                    <option/>
		                    <%
		                        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        String sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_FREQUENCE_PLANNING");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.fréquence.planning",sType,sWebLanguage,false,true)%>
		                </select>
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.décisions.familiale",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DECISION_FAMILIAL" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DECISION_FAMILIAL" property="value"/></textarea>
					</td>
				</tr>
			</table>
		</td>
		<td width="50%" style="vertical-align:top;">
			<table width="100%" cellspacing="1" cellpadding="0">
				<tr class="admin">
					<td colspan="2">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.info.socio.eco",sWebLanguage)%>	
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.niveau.instruction",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_NIVEAU_INSTRUCTION" property="itemId"/>]>.value">
		                    <option/>
		                    <%
		                        sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_NIVEAU_INSTRUCTION");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.niveau.instruction",sType,sWebLanguage,false,true)%>
		                </select>
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.profession",sWebLanguage)%>
					</td>
					<td class="admin2">
						<select class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROFESSION" property="itemId"/>]>.value">
		                    <option/>
		                    <%
		                        sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
		                        sType = checkString(request.getParameter("type"));
		
		                        if(sType.length() == 0){
		                            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_PROFESSION");
		                            if (item!=null){
		                                sType = checkString(item.getValue());
		                            }
		                        }
		                    %>
		                    <%=ScreenHelper.writeSelect("tracnet.profession",sType,sWebLanguage,false,true)%>
		                </select>
		                <input type="text" class="text" size="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROFESSION_AUTRE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PROFESSION_AUTRE" property="value"/>">
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.revenu.ménage",sWebLanguage)%>
					</td>
					<td class="admin2">
						<table>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.patient",sWebLanguage)%></td>
								<td>
									<input id="patient_revenu" type="text" class="text" size="8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVENU_PATIENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVENU_PATIENT" property="value"/>" onblur="isNumber(this);" onchange="calculateRevenuTotal();">
                                    <%=MedwanQuery.getInstance().getConfigString("localMoney","RWF")%>
                                </td>
							</tr>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.conjoint",sWebLanguage)%></td>
								<td>
									<input id="conjoint_revenu" type="text" class="text" size="8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVENU_CONJOINT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVENU_CONJOINT" property="value"/>" onblur="isNumber(this);" onchange="calculateRevenuTotal();">
                                    <%=MedwanQuery.getInstance().getConfigString("localMoney","RWF")%>
								</td>
							</tr>
							<tr>
								<td><%=getTran("openclinic.chuk","tracnet.psychosocial.autre.personne",sWebLanguage)%></td>
								<td>
									<input id="autre_revenu" type="text" class="text" size="8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVENU_AUTRE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVENU_AUTRE" property="value"/>" onblur="isNumber(this);" onchange="calculateRevenuTotal();">
                                    <%=MedwanQuery.getInstance().getConfigString("localMoney","RWF")%>
								</td>
							</tr>
							<tr>
								<td><b><%=getTran("openclinic.chuk","tracnet.psychosocial.total",sWebLanguage)%></b></td>
								<td>
									<input id="total_revenu" readonly="readonly" type="bold" class="text" size="8" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVENU_TOTAL" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_REVENU_TOTAL" property="value"/>" onblur="isNumber(this);">
                                    <b><%=MedwanQuery.getInstance().getConfigString("localMoney","RWF")%></b>
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.assistance.économique",sWebLanguage)%>
					</td>
					<td class="admin2">
						<input type="radio" onDblClick="uncheckRadio(this);" id="assist_eco_yes" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASSISTANCE_ECONOMIQUE" property="itemId"/>]>.value" value="medwan.common.yes" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASSISTANCE_ECONOMIQUE;value=medwan.common.yes" property="value" outputString="checked"/> onclick="checkPage2Settings();"><%=getLabel("Web.Occup","medwan.common.yes",sWebLanguage,"assist_eco_yes")%>
                        <input type="radio" onDblClick="uncheckRadio(this);" id="assist_eco_no" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASSISTANCE_ECONOMIQUE" property="itemId"/>]>.value" value="medwan.common.no" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASSISTANCE_ECONOMIQUE;value=medwan.common.no" property="value" outputString="checked"/> onclick="checkPage2Settings();"><%=getLabel("Web.Occup","medwan.common.no",sWebLanguage,"assist_eco_no")%>
					</td>
				</tr>
				<tr id="assistance_economique_decrivez" style="display:block;">		
					<td class="admin" width="<%=sTDAdminWidth %>">
						<%=getTran("openclinic.chuk","tracnet.psychosocial.assistance.économique.décrivez",sWebLanguage)%>
					</td>
					<td class="admin2">
						<textarea id="assist_eco_decrivez" onKeyup="resizeTextarea(this,10);limitChars(this,255);" class="text" rows="2" cols="50" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASSISTANCE_ECONOMIQUE_DECRIVATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ASSISTANCE_ECONOMIQUE_DECRIVATION" property="value"/></textarea>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>
<script>
	function calculateCompositionTotal(){
		var b1 = document.getElementById("composition_type1_nombre").value;
		var b2 = document.getElementById("composition_type2_nombre").value;
		var b3 = document.getElementById("composition_type3_nombre").value;
		var b4 = document.getElementById("composition_type4_nombre").value;
		
		document.getElementById("composition_type_total_nombre").value = (b1*1)+(b2*1)+(b3*1)+(b4*1);
		
		var a1 = document.getElementById("composition_type1_nombre_en_charge").value;
		var a2 = document.getElementById("composition_type2_nombre_en_charge").value;
		var a3 = document.getElementById("composition_type3_nombre_en_charge").value;
		var a4 = document.getElementById("composition_type4_nombre_en_charge").value;
		
		document.getElementById("composition_type_total_nombre_en_charge").value = (a1*1)+(a2*1)+(a3*1)+(a4*1);
	}
	
	function calculateRevenuTotal(){
		var b1 = document.getElementById("patient_revenu").value;
		var b2 = document.getElementById("conjoint_revenu").value;
		var b3 = document.getElementById("autre_revenu").value;
		
		document.getElementById("total_revenu").value = (b1*1)+(b2*1)+(b3*1);
	}
</script>