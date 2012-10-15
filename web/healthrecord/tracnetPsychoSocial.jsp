<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("occup.tracnetPsychoSocial", "select",activeUser)%>

<script>
  <%-- ACTIVATE TAB --%>
  function activateTab(iTab){
    document.getElementById('tr1-view').style.display = 'none';
    document.getElementById('tr2-view').style.display = 'none';
    document.getElementById('tr3-view').style.display = 'none';
    document.getElementById('tr4-view').style.display = 'none';
    document.getElementById('tr5-view').style.display = 'none';

    td1.className = "tabunselected";
    td2.className = "tabunselected";
    td3.className = "tabunselected";
    td4.className = "tabunselected";
    td5.className = "tabunselected";

    if (iTab==1){
      document.getElementById('tr1-view').style.display = '';
      td1.className="tabselected";
    }
    else if (iTab==2){
      document.getElementById('tr2-view').style.display = '';
      td2.className="tabselected";
    }
    else if (iTab==3){
      document.getElementById('tr3-view').style.display = '';
      td3.className="tabselected";
    }
    else if (iTab==4){
      document.getElementById('tr4-view').style.display = '';
      td4.className="tabselected";
    }
    else if (iTab==5){
      document.getElementById('tr5-view').style.display = '';
      td5.className="tabselected";
    }
  }
</script>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'  onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="subClass" value="GENERAL"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>
    <br>

    <%-- TABS --%>
    <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(1)" id="td1" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("openclinic.chuk","tracnet.psychosocial.page1",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(2)" id="td2" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("openclinic.chuk","tracnet.psychosocial.page2",sWebLanguage)%></b>&nbsp;</td>
            <td style="border-bottom: 1px solid Black;" width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(3)" id="td3" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("openclinic.chuk","tracnet.psychosocial.page3",sWebLanguage)%></b>&nbsp;</td>
            <td class='tabs' width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(4)" id="td4" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("openclinic.chuk","tracnet.psychosocial.page4",sWebLanguage)%></b>&nbsp;</td>
            <td style="border-bottom: 1px solid Black;" width='5'>&nbsp;</td>
            <td class='tabunselected' width="1%" onclick="activateTab(5)" id="td5" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"' nowrap>&nbsp;<b><%=getTran("openclinic.chuk","tracnet.psychosocial.page5",sWebLanguage)%></b>&nbsp;</td>
            <td width="*" class='tabs'>&nbsp;</td>
        </tr>
    </table>

    <%-- HIDEABLE --%>
    <table valign="top" width="100%" border="0" cellspacing="0">
        <tr id="tr1-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/tracnetPsychoSocial1.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr2-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/tracnetPsychoSocial2.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr3-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/tracnetPsychoSocial3.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr4-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/tracnetPsychoSocial4.jsp"),pageContext);%></td>
        </tr>
        <tr id="tr5-view" style="display:none">
            <td><%ScreenHelper.setIncludePage(customerInclude("healthrecord/tracnetPsychoSocial5.jsp"),pageContext);%></td>
        </tr>
    </table>
<%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.tracnetPsychoSocial",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>

<script>
  	activateTab(1);
  	checkPage1Settings();
	
	checkPage2Settings();

	checkPage3Settings();
	
	checkPage4Settings();
	var maySubmit = true;
	
	function submitForm(){
	  maySubmit = true;
	    
	  if(maySubmit){
	  	
	  	if(document.getElementById('fosa_yes').checked){
	  		document.getElementById('fosa_suivi').value = "";
	  	}
	  	
	  	if(document.getElementById('demenage').value == "one.or.two" || document.getElementById('demenage').value == ""  || document.getElementById('demenage').value == "none"){
	  		document.getElementById('demenage_suivi').value = "";
	  	}
	  	
	  	if(document.getElementById('visite_domicile_yes').checked){
			document.getElementById('visite_domicile_suivi').value = "";
		}
		
		if(document.getElementById('statut_social').value != "maried" && document.getElementById('statut_social').value != "union.libre"){
			document.getElementById('name_conjoint').value = "";
			document.getElementById('age_conjoint').value = "";
			document.getElementById('vih_yes').chekced = false;
			document.getElementById('vih_no').checked = false;
			document.getElementById('vih_suivi').value = "";
			document.getElementById('serologique').value = "";
			document.getElementById('vih_prise_charge_yes').checked = false;
			document.getElementById('vih_prise_charge_no').checked = false;
			document.getElementById('vih_prise_charge_suivi').value = "";
			document.getElementById('prise_charge_ou').value = "";
			document.getElementById('prise_charge_ou_suivi').value = "";
			document.getElementById('incomprehensions_conjoint').value = "";
			document.getElementById('seropositive_yes').checked = false;
			document.getElementById('seropositive_no').checked = false;
			document.getElementById('seropositive_suivi').value = "";
			document.getElementById('usage_condoms_conjoint').value = "";
			document.getElementById('usage_condoms_conjoint_suivi').value = "";
			
		}
		
		if(document.getElementById('vih_yes').checked){
			document.getElementById('vih_suivi').value = "";
		}
		
		if(document.getElementById('vih_prise_charge_yes').checked){
			document.getElementById('vih_prise_charge_suivi').value = "";
		}
		
		if(document.getElementById('prise_charge_ou').value.length == 0){
			document.getElementById('prise_charge_ou_suivi').value = "";
		}
		
		if(document.getElementById('seropositive_yes').checked){
			document.getElementById('seropositive_suivi').value = "";
		}
	  	
	  	if(document.getElementById('usage_condoms_conjoint').value == "toujours"){
	  		document.getElementById('usage_condoms_conjoint_suivi').value = "";
	  	}
	  	
	  	if(document.getElementById('partenaires_occasionnels_condoms').value == "toujours"){
	  		document.getElementById('partenaires_occasionnels_condoms_suivi').value = "";
	  	}
	  	
	  	if(document.getElementById('partenaires_occa_no').checked){
	  		document.getElementById('partenaires_occa_nombre').value = "";	
	  	}
	  	
	  	<%-- page2 --%>
	  	
	  	if(document.getElementById('enfants_encore_no').checked){
			document.getElementById('enfants_encore_suivi').value= "";
		}
		
		if(document.getElementById('planning_familial_no').checked){
			document.getElementById('methode1').checked = false;
			document.getElementById('methode2').checked = false;
			document.getElementById('methode3').checked = false;
			document.getElementById('methode4').checked = false;
			document.getElementById('methode5').checked = false;
			document.getElementById('methode6').checked = false;
			document.getElementById('planning_familial_frequence').value = "";
		}else if(document.getElementById('planning_familial_yes').checked){
			document.getElementById('planning_familial_suivi').value = "";
		}
		
		if(document.getElementById('assist_eco_no').checked){
			document.getElementById('assist_eco_decrivez').value = "";
		}
		
		<%-- page3 --%>
	  	
		if(document.getElementById('sante_mutuelle_yes').checked){
			document.getElementById('sante_mutuelle_suivi').value = "";
		}else if(document.getElementById('sante_mutuelle_no').checked){
			document.getElementById('sante_mutuelle_quelle').value = "";
			document.getElementById('sante_mutuelle_quelle').value = "";
		}
		var a = document.getElementById('repas').value;
		
		if(a == "" || a >= 2 ){
			document.getElementById('repas_suivi').value = "";
		}
		
		if(document.getElementById('autre_prestataires_no').checked){
			document.getElementById('autre_prestataires_oui').value = "";
		}
		
		if(document.getElementById('herbes_médicinales_no').checked){
			document.getElementById('herbes_medicinales_inclure').value = "";
		}
		
		<%-- page4 --%>
		
		if(document.getElementById('prise_charge_ou').value.length == 0){
			document.getElementById('service_arv_oui_suivi').value = '';
		}
		
		if(document.getElementById('revele_statut_yes').checked){
			document.getElementById('revele_statut_proches_suivi').value = "";
		}
		
		if(document.getElementById('choisi_parrain_no').checked){
			document.getElementById('parrain1').value = "";
			document.getElementById('parrain2').value = "";
			document.getElementById('parrain3').value = "";
			document.getElementById('parrain4_a').value = "";
			document.getElementById('parrain4_b').value = "";
			document.getElementById('parrain4_c').value = "";
			document.getElementById('parrain4_d').value = "";
			document.getElementById('parrain4_e').value = "";
			document.getElementById('parrain5').value = "";
			document.getElementById('parrain6').value = "";
			document.getElementById('parrain7').value = "";
			document.getElementById('parrain_instruction').value = "";
			document.getElementById('parrain_instruction_autre').value = "";
			document.getElementById('assister_sessions_yes').checked = false;
			document.getElementById('assister_sessions_no').checked = false;
			document.getElementById('parrain9').value = "";
		}else if(document.getElementById('choisi_parrain_yes').checked){
			document.getElementById('sante_mutuelle_suivi_parrain').value = "";
		}
		
		if(document.getElementById('assister_sessions_yes').checked){
			document.getElementById('parrain9').value = "";
		}
		
		if(document.getElementById('parrain_instruction').value != "autre"){
			document.getElementById('parrain_instruction_autre').value = '';
		}
		
	  	document.transactionForm.saveButton.style.visibility = "hidden";
        var temp = Form.findFirstElement(transactionForm);//for ff compatibility
	  	document.transactionForm.submit();
	  }
	}

	function checkPage1Settings(){
		<%--  ITEM_TYPE_FOSA --%>		
		if(document.getElementById('fosa_no').checked){
			document.getElementById('fosa_block').style.display = "block";
		}else if(document.getElementById('fosa_yes').checked){
			document.getElementById('fosa_block').style.display = "none";
		}else{
			document.getElementById('fosa_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_DEMENAGE --%>
		if(document.getElementById('demenage').value == "one.or.two" || document.getElementById('demenage').value == ""  || document.getElementById('demenage').value == "none"){
			document.getElementById('demenage_block').style.display = "none";
		}else{
			document.getElementById('demenage_block').style.display = "block";
		}
		
		<%--  ITEM_TYPE_VISITE_DOMICILE --%>		
		if(document.getElementById('visite_domicile_no').checked){
			document.getElementById('visite_domicile_block').style.display = "block";
		}else if(document.getElementById('visite_domicile_yes').checked){
			document.getElementById('visite_domicile_block').style.display = "none";
		}else{
			document.getElementById('visite_domicile_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_STATUT_SOCIAL --%>
		if(document.getElementById('statut_social').value == "maried" || document.getElementById('statut_social').value == "union.libre"){
			document.getElementById('statut_social_block1').style.display = "block";
			document.getElementById('statut_social_block2').style.display = "block";
			document.getElementById('statut_social_block3').style.display = "block";
			document.getElementById('statut_social_block4').style.display = "block";
			document.getElementById('statut_social_block5').style.display = "block";
			document.getElementById('statut_social_block6').style.display = "block";
			document.getElementById('statut_social_block7').style.display = "block";
			document.getElementById('statut_social_block8').style.display = "block";
			document.getElementById('statut_social_block9').style.display = "block";
		}else{
			document.getElementById('statut_social_block1').style.display = "none";
			document.getElementById('statut_social_block2').style.display = "none";
			document.getElementById('statut_social_block3').style.display = "none";
			document.getElementById('statut_social_block4').style.display = "none";
			document.getElementById('statut_social_block5').style.display = "none";
			document.getElementById('statut_social_block6').style.display = "none";
			document.getElementById('statut_social_block7').style.display = "none";
			document.getElementById('statut_social_block8').style.display = "none";
			document.getElementById('statut_social_block9').style.display = "none";
		}
		
		<%--  ITEM_TYPE_VIH --%>		
		if(document.getElementById('vih_no').checked){
			document.getElementById('vih_block').style.display = "block";
		}else if(document.getElementById('vih_yes').checked){
			document.getElementById('vih_block').style.display = "none";
		}else{
			document.getElementById('vih_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_VIH_PRISE_CHARGE --%>		
		if(document.getElementById('vih_prise_charge_no').checked){
			document.getElementById('vih_prise_charge_block').style.display = "block";
		}else if(document.getElementById('vih_prise_charge_yes').checked){
			document.getElementById('vih_prise_charge_block').style.display = "none";
		}else{
			document.getElementById('vih_prise_charge_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_VIH_PRISE_CHARGE_OU --%>		
		if(document.getElementById('prise_charge_ou').value.length > 0){
			document.getElementById('prise_charge_ou_block').style.display = "block";
			document.getElementById('service_arv_oui_block').style.display = "block";
		}else{
			document.getElementById('prise_charge_ou_block').style.display = "none";
			document.getElementById('service_arv_oui_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_SEROPOSITIVE_CONJOINT --%>		
		if(document.getElementById('seropositive_no').checked){
			document.getElementById('seropositive_block').style.display = "block";
		}else if(document.getElementById('seropositive_yes').checked){
			document.getElementById('seropositive_block').style.display = "none";
		}else{
			document.getElementById('seropositive_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_USAGE_CONDOMS_CONJOINT --%>
		if(document.getElementById('usage_condoms_conjoint').value != "toujours"){
			document.getElementById('usage_condoms_conjoint_block').style.display = "block";
		}else{
			document.getElementById('usage_condoms_conjoint_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_partenaires.occasionnels.condoms --%>
		if(document.getElementById('partenaires_occasionnels_condoms').value != "toujours"){
			document.getElementById('partenaires_occasionnels_condoms_block').style.display = "block";
		}else{
			document.getElementById('partenaires_occasionnels_condoms_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_PARTENAIRES_OCCA --%>
		if(document.getElementById('partenaires_occa_yes').checked){
			document.getElementById('partenaires_occa_block').style.display = "block";
		}else if(document.getElementById('partenaires_occa_no').checked){
			document.getElementById('partenaires_occa_block').style.display = "none";
		}else{
			document.getElementById('partenaires_occa_block').style.display = "none";
		}
	}
	
	function checkPage2Settings(){
		<%--  ITEM_TYPE_ENFANTS_ENCORE --%>
		if(document.getElementById('enfants_encore_yes').checked){
			document.getElementById('enfants_encore_block').style.display = "block";
		}else if(document.getElementById('enfants_encore_no').checked){
			document.getElementById('enfants_encore_block').style.display = "none";
		}else{
			document.getElementById('enfants_encore_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_PLANNING_FAMILIAL --%>
		if(document.getElementById('planning_familial_no').checked){
			document.getElementById('planning_familial_block').style.display = "block";
			document.getElementById('planning_familial1').style.display = "none";
			document.getElementById('planning_familial2').style.display = "none";
		}else if(document.getElementById('planning_familial_yes').checked){
			document.getElementById('planning_familial_block').style.display = "none";
			document.getElementById('planning_familial1').style.display = "block";
			document.getElementById('planning_familial2').style.display = "block";
		}else{
			document.getElementById('planning_familial_block').style.display = "none";
			document.getElementById('planning_familial1').style.display = "none";
			document.getElementById('planning_familial2').style.display = "none";
		}
		
		<%--  ITEM_TYPE_ASSISTANCE_ECONOMIQUE --%>
		if(document.getElementById('assist_eco_yes').checked){
			document.getElementById('assistance_economique_decrivez').style.display = "block";
		}else if(document.getElementById('assist_eco_no').checked){
			document.getElementById('assistance_economique_decrivez').style.display = "none";
		}else{
			document.getElementById('assistance_economique_decrivez').style.display = "block";
		}
	}
	
	function checkPage3Settings(){
		<%--  ITEM_TYPE_SANTE_MUTUELLE --%>
		if(document.getElementById('sante_mutuelle_yes').checked){
			document.getElementById('sante_mutuelle_block').style.display = "none";
			document.getElementById('sante_mutuelle1').style.display = "block";
			document.getElementById('sante_mutuelle2').style.display = "block";
		}else if(document.getElementById('sante_mutuelle_no').checked){
			document.getElementById('sante_mutuelle_block').style.display = "block";
			document.getElementById('sante_mutuelle1').style.display = "none";
			document.getElementById('sante_mutuelle2').style.display = "none";
		}else{
			document.getElementById('sante_mutuelle_block').style.display = "none";
			document.getElementById('sante_mutuelle1').style.display = "block";
			document.getElementById('sante_mutuelle2').style.display = "block";
		}
		
		<%--  ITEM_TYPE_REPAS --%>
		var a = document.getElementById('repas').value;
		
		if(a != "" && a < 2 ){
			document.getElementById('repas_block').style.display = "block";
		}else{
			document.getElementById('repas_block').style.display = "none";
		}
		
		<%--  IITEM_TYPE_AUTRE_PRESTATAIRES --%>
		if(document.getElementById('autre_prestataires_yes').checked){
			document.getElementById('autre_prestataires1').style.display = "block";
		}else if(document.getElementById('autre_prestataires_no').checked){
			document.getElementById('autre_prestataires1').style.display = "none";
		}else{
			document.getElementById('autre_prestataires1').style.display = "block";
		}
		
		<%--  IITEM_TYPE_HERBES_MEDICINALES --%>
		if(document.getElementById('herbes_médicinales_yes').checked){
			document.getElementById('medicament_base_herbes_med1').style.display = "block";
		}else if(document.getElementById('herbes_médicinales_no').checked){
			document.getElementById('medicament_base_herbes_med1').style.display = "none";
		}else{
			document.getElementById('medicament_base_herbes_med1').style.display = "block";
		}
	}
	
	function checkPage4Settings(){
		<%-- ITEM_TYPE_SERVICE_ARV_OUI --%>
		//alert(document.getElementById('prise_charge_ou').value.length);
		if(document.getElementById('prise_charge_ou').value.length > 0){
			document.getElementById('service_arv_oui_block').display = 'block';
		}else{
			document.getElementById('service_arv_oui_block').display = 'none';
		}
		
		<%--  ITEM_TYPE_REVELE_STATUT_PROCHE --%>		
		if(document.getElementById('revele_statut_no').checked){
			document.getElementById('revele_statut_proches_block').style.display = "block";
		}else if(document.getElementById('revele_statut_yes').checked){
			document.getElementById('revele_statut_proches_block').style.display = "none";
		}else{
			document.getElementById('revele_statut_proches_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_CHOISI_PARRAIN_MARRAINE --%>		
		if(document.getElementById('choisi_parrain_no').checked){
			document.getElementById('choisi_parrain_marraine_block').style.display = "block";
			document.getElementById('choisi_parrain1').style.display = "none";
			document.getElementById('choisi_parrain2').style.display = "none";
			document.getElementById('choisi_parrain3').style.display = "none";
			document.getElementById('choisi_parrain4').style.display = "none";
			document.getElementById('choisi_parrain5').style.display = "none";
			document.getElementById('choisi_parrain6').style.display = "none";
			document.getElementById('choisi_parrain7').style.display = "none";
			document.getElementById('choisi_parrain8').style.display = "none";
			document.getElementById('choisi_parrain9').style.display = "none";
		}else if(document.getElementById('choisi_parrain_yes').checked){
			document.getElementById('choisi_parrain_marraine_block').style.display = "none";
			document.getElementById('choisi_parrain1').style.display = "block";
			document.getElementById('choisi_parrain2').style.display = "block";
			document.getElementById('choisi_parrain3').style.display = "block";
			document.getElementById('choisi_parrain4').style.display = "block";
			document.getElementById('choisi_parrain5').style.display = "block";
			document.getElementById('choisi_parrain6').style.display = "block";
			document.getElementById('choisi_parrain7').style.display = "block";
			document.getElementById('choisi_parrain8').style.display = "block";
			document.getElementById('choisi_parrain9').style.display = "block";
		}else{
			document.getElementById('choisi_parrain_marraine_block').style.display = "none";
			document.getElementById('choisi_parrain1').style.display = "none";
			document.getElementById('choisi_parrain2').style.display = "none";
			document.getElementById('choisi_parrain3').style.display = "none";
			document.getElementById('choisi_parrain4').style.display = "none";
			document.getElementById('choisi_parrain5').style.display = "none";
			document.getElementById('choisi_parrain6').style.display = "none";
			document.getElementById('choisi_parrain7').style.display = "none";
			document.getElementById('choisi_parrain8').style.display = "none";
			document.getElementById('choisi_parrain9').style.display = "none";
		}
		
		<%--  ITEM_TYPE_PARRAIN_MARRAINE_ASSISTER_SESSIONS --%>		
		if(document.getElementById('assister_sessions_no').checked){
			document.getElementById('parrain_assister_sessions_education_block').style.display = "block";
		}else if(document.getElementById('assister_sessions_yes').checked){
			document.getElementById('parrain_assister_sessions_education_block').style.display = "none";
		}else{
			document.getElementById('parrain_assister_sessions_education_block').style.display = "none";
		}
		
		<%--  ITEM_TYPE_PARRAIN_MARRAINE_INSTRUCTION --%>
		if(document.getElementById('parrain_instruction').value == "autre"){
			document.getElementById('parrain_instruction_autre').style.display = "block";
		}else{
			document.getElementById('parrain_instruction_autre').style.display = "none";
		}
	}
</script>

<%=writeJSButtons("transactionForm","save")%>
<%=ScreenHelper.contextFooter(request)%>

</form>
