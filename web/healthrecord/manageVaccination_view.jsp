<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("occup.vaccinations","select",activeUser)%>

<%
	/// DEBUG //////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n******** healthrecord/manageVaccination_view.jsp ********");
	    Debug.println("No parameters\n");
	}
	////////////////////////////////////////////////////////////////////////////////
%>

<form name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' focus='itemType'>
    <bean:define id="vaccinationInfo" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentVaccinationInfoVO"/>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

	<%=checkPrestationToday(activePatient.personid,false,activeUser,(TransactionVO)transaction)%>
	<%
	    TransactionVO tran = (TransactionVO)transaction;        
    %>
	
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    
    <input type="hidden" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>]>.itemId" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>"/>
    <input type="hidden" readonly id="vaccination-type" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="value" translate="false"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/healthrecord/showVaccinationSummary.do?ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>">
   
    <%=writeTableHeader("web.occup","be.mxs.healthrecord.vaccination.Vaccination",sWebLanguage,"doBack();")%>
   
    <table border="0" width="100%" class="list" cellspacing="1">
        <%-- VACCINATION TYPE --%>
        <tr>
            <td class="admin" width="*"><%=getTran("Web.Occup","medwan.common.type",sWebLanguage)%>&nbsp;</td>
            <td class="admin2" width="80%">
                <input type="text" readonly class="text" size="20" name="itemType" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE" property="value"/>" onblur="validateText(this);limitLength(this);"/>
            </td>
        </tr>
        
        <%-- VACCINATION NAME --%>
        <tr id="vaccination-name" style="display:none">
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input id="vname" type="text" class="text" size="20" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME" property="value"/>" onblur="validateText(this);limitLength(this);"/>
                <%
                    // other vaccinations
                    String sOtherVaccins = MedwanQuery.getInstance().getConfigString("otherVaccinations");
                    if(sOtherVaccins.length()==0){
                        sOtherVaccins = "ENGERIX,HAVRIX";
                    }

                    int counter = 0;
                    String sVaccination;
                    while(sOtherVaccins.length() > 0){
                        counter++;

                        if(sOtherVaccins.indexOf(",") > -1){
                            sVaccination = sOtherVaccins.substring(0,sOtherVaccins.indexOf(","));
                            sOtherVaccins = sOtherVaccins.substring(sOtherVaccins.indexOf(",")+1);
                        }
                        else{
                            sVaccination = sOtherVaccins;
                            sOtherVaccins = "";
                        }

                        if(sVaccination.trim().length() > 0){
                            out.print("<input type='radio' onDblClick='uncheckRadio(this);document.getElementsByName(\"vname\")[0].value=\"\";' id='mv_r"+counter+"' name='vacnam' onclick='document.getElementsByName(\"vname\")[0].value=\""+sVaccination+"\";' />");
                            out.print("<label for='mv_r"+counter+"'>"+sVaccination+"</label>");
                        }
                    }
                %>
            </td>
        </tr>
        
        <%-- CURRENT STATUS --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.vaccination.current-status",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <mxs:propertyAccessorI18N name="transaction.items" output="false" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS" property="value" translate="false" toBean="vaccinationCurrentStatus" toScope="page"/>
                <select id="status" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS" property="itemId"/>]>.value" class="text" onchange="setRetakeOptions();">
                    <logic:iterate id="vaccinationStatus" scope="session" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentVaccinationInfoVO.valueList">
                        <%
                            // At vaccination creation the parameter "status" is given to this jsp page.
                            // If that parameter is empty, get the saved value.
                            String status = checkString(request.getParameter("status"));
                            if(status.length()==0){
                                status = tran.getItemValue(ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_VACCINATION_STATUS");
                            }

                            if(((String)vaccinationStatus).equalsIgnoreCase(status)){
                                %><option value="<bean:write name="vaccinationStatus"/>" SELECTED><%=getTran("Web.Occup",vaccinationStatus.toString(),sWebLanguage)%><%
                            }
                            else{
                                %><option value="<bean:write name="vaccinationStatus"/>"><%=getTran("Web.Occup",vaccinationStatus.toString(),sWebLanguage)%><%
                            }
                        %>
                    </logic:iterate>
                </select>
            </td>
        </tr>
        
        <%-- DATE --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="value" formatType="date" format="dd-mm-yyyy"/>" id="trandate" onBlur='checkDate(this);'/>
                <script>writeTranDate();</script>
            </td>
        </tr>
        
        <%-- NEXT DATE --%>
        <tr>
            <td class='admin'><%=getTran("Web.Occup","be.mxs.healthrecord.vaccination.next-date",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE" property="value" formatType="date" format="dd-mm-yyyy"/>" id="nextdate" onBlur='if(checkDate(this)){ checkBefore("trandate",this); }'/>
                <script>
                	if(document.getElementById("trandate").value==document.getElementById("nextdate").value){
                		document.getElementById("nextdate").value="";
                	}
                	writeMyDate("nextdate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");
                </script>&nbsp;
                <%-- calculate bbutton --%>
                <input type="button" class="button" name="calculate" value="<%=getTran("Web.Occup","Calculate",sWebLanguage)%>" onclick="calculateNextDate();">
            </td>
        </tr>
        
        <%-- REMARK --%>
        <tr id="vaccination-remark" style="display:none">
            <td class='admin'><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_COMMENT")%> id="vaccination-remarktext" class="text" cols="80" rows="4" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT" property="value"/></textarea>
            </td>
        </tr>
        
         <%-- POS/NEG --%>
        <tr id="vaccination-positive-negative" style="display:none">
            <td class='admin'><%=getTran("Web.Occup","medwan.common.remark",sWebLanguage)%>&nbsp;</td>
            <td class='admin2'>
                <select name="posneg" class="text">
                    <option value="medwan.common.negative" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT;value=medwan.common.negative" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.common.negative",sWebLanguage)%>
                    <option value="medwan.common.positive" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_COMMENT;value=medwan.common.positive" property="value" outputString="selected"/>><%=getTran("Web.Occup","medwan.common.positive",sWebLanguage)%>
                </select>
            </td>
        </tr>
        
         <%-- PREGNANT --%>
        <% 
        	if(!activePatient.gender.equalsIgnoreCase("m") && activePatient.getAge()>8 && activePatient.getAge()<51){
		        %>
			        <tr id="pregnant" >
			            <td class='admin'><%=getTran("Web","pregnant",sWebLanguage)%>&nbsp;</td>
			            <td class='admin2'>
			                <input type="checkbox" id="pregnancy" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PREGNANT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PREGNANT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true" >
			            </td>
			        </tr>
		        <% 
        	}
        %>
        
        <%-- ALS PRESTATIE HERNEMEN (action / product) --%>
        <tr>
            <td class="admin"><%=getTran("Web.Occup","medwan.healthrecord.prestation_recapture",sWebLanguage)%></td>
            <td class="admin2">
                <input type="checkbox" id="recaptureAction" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION_ACTION" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION_ACTION;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true" onDblClick="uncheckRadio(this);"><%=getLabel("Web.Occup","medwan.healthrecord.prestation_recapture_action",sWebLanguage,"recaptureAction")%>
                <input type="checkbox" id="recaptureProduct" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION_PRODUCT" property="itemId"/>]>.value" <mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION_PRODUCT;value=medwan.common.true" property="value" outputString="checked"/> value="medwan.common.true" onDblClick="uncheckRadio(this);"><%=getLabel("Web.Occup","medwan.healthrecord.prestation_recapture_product",sWebLanguage,"recaptureProduct")%>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
		        <%
		            if((activeUser.getAccessRight("occup.vaccinations.add"))||(activeUser.getAccessRight("occup.vaccinations.edit"))){
		                %><input class="button" type="button" name="save" onClick="submitForm();" value="<%=getTran("Web.Occup","medwan.common.record",sWebLanguage)%>"/><%
		            }
		        %>
                <input class="button" type="button" value="<%=getTran("Web","Back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>    
</form>

<script>
  transactionForm.itemType.focus();

  <%-- check action & product unless type is 'immune' --%>
  function setRetakeOptions(){
    if(document.getElementsByName('status')[0].value == 'be.mxs.healthrecord.vaccination.subtype.immune'){
      document.getElementsByName('recaptureAction')[0].checked = false;
      document.getElementsByName('recaptureAction')[0].disabled = true;

      document.getElementsByName('recaptureProduct')[0].checked = false;
      document.getElementsByName('recaptureProduct')[0].disabled = true;
    }
    else {
      document.getElementsByName('recaptureAction')[0].disabled = false;
      document.getElementsByName('recaptureProduct')[0].disabled = false;

      document.getElementsByName('recaptureAction')[0].checked = true;
      document.getElementsByName('recaptureProduct')[0].checked = true;
    }
  }


  if (document.getElementsByName('vaccination-type')[0].value=='be.mxs.healthrecord.vaccination.Other'){
    show('vaccination-name');
  }

  if (document.getElementsByName('vaccination-type')[0].value=='be.mxs.healthrecord.vaccination.Intradermo'){
    show('vaccination-positive-negative');
  }
  else{
    show('vaccination-remark');
  }

  function calculateNextDate(){
    vaccinationType = document.getElementsByName('vaccination-type')[0].value;
    vaccinationSubType= document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_STATUS" property="itemId"/>]>.value')[0].value;
    vaccinationDate = document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="itemId"/>]>.value')[0].value;
    sourceField = 'currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE" property="itemId"/>]>.value';

    window.open("<c:url value="/util/getCalculatedValues.jsp"/>?valueType=nextVaccinationDate&vaccinationType="+vaccinationType+"&vaccinationSubType="+vaccinationSubType+"&vaccinationDate="+vaccinationDate+"&sourceField="+sourceField,"Select","toolbar=no, status=no, scrollbars=no, resizable=no, width=1, height=1, menubar=no");
  }

  function submitForm(){
    document.getElementsByName('currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime')[0].value=document.getElementsByName('currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_DATE" property="itemId"/>]>.value')[0].value;
    document.transactionForm.saveButton.disabled = true;
    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
        out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
    %>
  }

  function doBack(){
    window.location.href = '<c:url value="/healthrecord/showVaccinationSummary.do"/>?ts=<%=getTs()%>';
  }

  if(document.getElementsByName('transactionId')[0].value*1 < 0){
    setRetakeOptions();
  }
</script>