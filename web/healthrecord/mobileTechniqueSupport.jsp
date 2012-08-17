<%@page import="java.util.Hashtable,
                be.openclinic.medical.Diagnosis"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("mobile.service.support","select",activeUser)%>

<form id="transactionForm" name="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>' onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>

    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>

    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <%
        StringBuffer sDivSeances = new StringBuffer(),
                     sSeances    = new StringBuffer();
        String sActAutre, sStartDate, sEndDate;

        TransactionVO tran = (TransactionVO)transaction;

        sActAutre = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ACT_AUTRE");
        sStartDate = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_STARTDATE");
        sEndDate   = getItemType(tran.getItems(),sPREFIX+"ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_ENDDATE");


    %>
    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE --%>
        <tr>
            <td class="admin">
                <a href="javascript:openHistoryPopup();" title="<%=getTran("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2" colspan="5">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date" format="dd-mm-yyyy"/>" id="trandate" OnBlur='checkDate(this)'>
                <script type="text/javascript">writeMyDate("trandate","<c:url value="/_img/icon_agenda.gif"/>","<%=getTran("Web","PutToday",sWebLanguage)%>");</script>
            </td>
        </tr>

        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","anamnesis",sWebLanguage)%></td>
            <td class="admin2">
            	<%
            	String history = tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANAMNESIS");
            	if(tran.getTransactionId()==null || tran.getTransactionId()<=0){
            		history=MedwanQuery.getInstance().getLastItemValue(Integer.parseInt(activePatient.personid), "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANAMNESIS");
            	}
            	
            	%>
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_ANAMNESIS")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="ITEM_TYPE_ANAMNESIS" property="itemId"/>]>.value"><%=history %></textarea>
            </td>
        </tr>


        <%-- ICPC / ICD10 --%>
        <tr>
            <td class="admin"><a href="javascript:openPopup('healthrecord/findICPC.jsp&ts=<%=getTs()%>&patientuid=<%=activePatient.personid %>')"><%=getTran("openclinic.chuk","diagnostic",sWebLanguage)%> <%=getTran("Web.Occup","ICPC-2",sWebLanguage)%>/<%=getTran("Web.Occup","ICD-10",sWebLanguage)%></a></td>
            <td id='icpccodes' class="admin2">
                <%
                    SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
                    TransactionVO curTran = sessionContainerWO.getCurrentTransactionVO();
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
                            }
                            else {
                                sGravity = "";
                                sCertainty = "";
                            }

                            %>
                              <span id="ICPCCode<%=item.getItemId()%>">
                                    <img src="<c:url value='/_img/icon_delete.gif'/>" onclick="window.ICPCCode<%=item.getItemId()%>.innerHTML='';"/><input type='hidden' name='ICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=item.getValue().trim()%>"/><input type='hidden' name='GravityICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICPCCode<%=item.getType().replaceAll("ICPCCode","")%>' value="<%=sCertainty%>"/>
                                    <%=item.getType().replaceAll("ICPCCode","")%>&nbsp;<%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>
                                    <br/>
                              </span>
                            <%
                        }
                        else if (item.getType().indexOf("ICD10Code")==0){
                            sCode = item.getType().substring("ICD10Code".length(),item.getType().length());
                            hDiagnosisInfo = (Hashtable)hDiagnoses.get(sCode);
                            sGravity = (String)hDiagnosisInfo.get("Gravity");
                            sCertainty = (String)hDiagnosisInfo.get("Certainty");

                            %>
                                <span id='ICD10Code<%=item.getItemId()%>'>
                                    <img src='<c:url value="/_img/icon_delete.gif"/>' onclick="window.ICD10Code<%=item.getItemId()%>.innerHTML='';"/><input type='hidden' name='ICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value='<%=item.getValue().trim()%>'/><input type='hidden' name='GravityICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sGravity%>"/><input type='hidden' name='CertaintyICD10Code<%=item.getType().replaceAll("ICD10Code","")%>' value="<%=sCertainty%>"/>
                                    <%=item.getType().replaceAll("ICD10Code","")%>&nbsp;<%=MedwanQuery.getInstance().getCodeTran(item.getType().trim(),sWebLanguage)%> <%=item.getValue().trim()%>
                                    <br/>
                                </span>
                            <%
                        }
                    }
                %>
            </td>
        </tr>

		<%-- SCEANCES --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","orthesis.acts",sWebLanguage)%></td>
            <td class="admin2">
            	<table>
            		<tr>
            			<td/>
            			<td><%=getTran("web","type",sWebLanguage) %></td>
            			<td><%=getTran("web","precision",sWebLanguage) %></td>
            			<td><%=getTran("openclinic.cnar","production",sWebLanguage) %></td>
            			<td><%=getTran("openclinic.cnar","action",sWebLanguage) %></td>
            			<td><%=getTran("web","quantity",sWebLanguage) %></td>
            		</tr>
            		<tr>
            			<td>1:</td>
            			<td>
			            	<select id='mobile.type.1' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_TYPE1" property="itemId"/>]>.value" class="text" >
				                <option/>
				                <%=ScreenHelper.writeSelect("mobile.type", tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_TYPE1"), sWebLanguage) %>
				            </select>
				        </td>
            			<td>
			            	<select id='mobile.detail.1' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_DETAIL1" property="itemId"/>]>.value" class="text">
				                <option/>
				                <%=ScreenHelper.writeSelect("mobile.detail", tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_DETAIL1"), sWebLanguage) %>
				            </select>
				        </td>
            			<td>
			            	<select id='orthesis.production.1' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_PRODUCTION1" property="itemId"/>]>.value" class="text">
				                <option/>
				                <%=ScreenHelper.writeSelect("ortho.production", tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_PRODUCTION1"), sWebLanguage) %>
				            </select>
				        </td>
            			<td>
			            	<select id='orthesis.action.1' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_ACTION1" property="itemId"/>]>.value" class="text">
				                <option/>
				                <%=ScreenHelper.writeSelect("ortho.action", tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_ACTION1"), sWebLanguage) %>
				            </select>
				        </td>
				        <td>
                			<input type="text" class="text" <%=setRightClick("ITEM_TYPE_ORTHESIS_QUANTITY1")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_QUANTITY1" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_QUANTITY1" property="value"/>" onBlur="isNumber(this);" size="5"/>
				        </td>
		            </tr>
            		<tr>
            			<td>2:</td>
            			<td>
			            	<select id='mobile.type.2' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_TYPE2" property="itemId"/>]>.value" class="text" >
				                <option/>
				                <%=ScreenHelper.writeSelect("mobile.type", tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_TYPE2"), sWebLanguage) %>
				            </select>
				        </td>
            			<td>
			            	<select id='mobile.detail.2' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_DETAIL2" property="itemId"/>]>.value" class="text">
				                <option/>
				                <%=ScreenHelper.writeSelect("mobile.detail", tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_DETAIL2"), sWebLanguage) %>
				            </select>
				        </td>
            			<td>
			            	<select id='orthesis.production.2' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_PRODUCTION2" property="itemId"/>]>.value" class="text">
				                <option/>
				                <%=ScreenHelper.writeSelect("ortho.production", tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_PRODUCTION2"), sWebLanguage) %>
				            </select>
				        </td>
            			<td>
			            	<select id='orthesis.action.2' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_ACTION2" property="itemId"/>]>.value" class="text">
				                <option/>
				                <%=ScreenHelper.writeSelect("ortho.action", tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_ACTION2"), sWebLanguage) %>
				            </select>
				        </td>
				        <td>
                			<input type="text" class="text" <%=setRightClick("ITEM_TYPE_ORTHESIS_QUANTITY2")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_QUANTITY2" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_QUANTITY2" property="value"/>" onBlur="isNumber(this);" size="5"/>
				        </td>
		            </tr>

	            </table>
            </td>
        </tr>

        <%-- CONCLUSION --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_CONCLUSION" property="value"/></textarea>
            </td>
        </tr>

        <%-- DATE --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","remarks",sWebLanguage)%></td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,255);" <%=setRightClick("ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS")%> class="text" cols="50" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_KINESITHERAPY_CONSULTATION_TREATMENT_REMARKS" property="value"/></textarea>
            </td>
        </tr>

        <%-- BUTTONS --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <%=getButtonsHtml(request,activeUser,activePatient,"occup.kinesitherapy.consultation.treatment",sWebLanguage)%>
            </td>
        </tr>
    </table>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>

	function fillDetail(selectname,type,selectedvalue){
		document.getElementById(selectname).options.length=0;
		<%
			Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
			if(labelTypes!=null){
				Hashtable labelIds = (Hashtable)labelTypes.get("orthesis.type");
				if(labelIds!=null){
					Enumeration e = labelIds.keys();
					while (e.hasMoreElements()){
						String type = (String)e.nextElement();
						out.println("if(type=='"+type+"'){");
						//Voor dit type gaan we nu de opties zetten
						Hashtable options = (Hashtable)labelTypes.get("orthesis.detail."+type.toLowerCase());
						if(options!=null){
							Enumeration oe = options.elements();
							int counter=0;
							while(oe.hasMoreElements()){
								String optionkey=((Label)oe.nextElement()).id.replace("'", "�");
								String optionvalue=((Label)options.get(optionkey)).value.replace("'", "�");
								out.println("document.getElementById(selectname).options["+counter+"] = new Option('"+optionvalue+"','"+optionkey+"',false,selectedvalue=='"+optionkey+"');");
								counter++;
							}
						}
						out.println("Array.prototype.sort.call(document.getElementById(selectname).options,function(a,b){return a.text < b.text ? -1 : a.text > b.text ? 1 : 0;});");
						out.println("}");
					}
				}
			}
		%>
	}

  <%-- SUBMIT FORM --%>
  function submitForm() {
    if(document.getElementById('encounteruid').value==''){
		alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
		searchEncounter();
	}	
    else {
	    var maySubmit = true;
	    var sTmpBegin;
	    var sTmpEnd;
	
	    if(maySubmit){
	      document.transactionForm.saveButton.style.visibility = "hidden";
	      var temp = Form.findFirstElement(transactionForm);
	      <%
	          sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO(request,SessionContainerWO.class.getName());
	          out.print(takeOverTransaction(sessionContainerWO, activeUser,"document.transactionForm.submit();"));
	      %>
	    }
    }
  }
  function searchEncounter(){
      openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>&VarCode=currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID" property="itemId"/>]>.value&VarText=&FindEncounterPatient=<%=activePatient.personid%>");
  }
  if(document.getElementById('encounteruid').value==''){
	alert('<%=getTranNoLink("web","no.encounter.linked",sWebLanguage)%>');
	searchEncounter();
  }	


  <%-- SEARCH ICPC --%>
  function searchICPC(code,codelabel,codetype){
    openPopup("/_common/search/searchICPC.jsp&ts=<%=getTs()%>&returnField=" + code + "&returnField2=" + codelabel + "&returnField3=" + codetype + "&ListChoice=FALSE");
  }

  fillDetail('orthesis.detail.1',document.getElementById('orthesis.type.1').value,'<%=tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_DETAIL1")%>');				            
  fillDetail('orthesis.detail.2',document.getElementById('orthesis.type.2').value,'<%=tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_DETAIL2")%>');				            
  fillDetail('orthesis.detail.3',document.getElementById('orthesis.type.3').value,'<%=tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_DETAIL3")%>');				            
  fillDetail('orthesis.detail.4',document.getElementById('orthesis.type.4').value,'<%=tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_DETAIL4")%>');				            
  fillDetail('orthesis.detail.5',document.getElementById('orthesis.type.5').value,'<%=tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ORTHESIS_DETAIL5")%>');				            

  function loadSelect(labeltype,select){
      var today = new Date();
      var url='<c:url value="/"/>/_common/search/searchByAjax/loadSelect.jsp?ts=' + today;
      new Ajax.Request(url,{
              method: "POST",
              postBody: 'labeltype=' + labeltype,
              onSuccess: function(resp){
                  var sOptions = resp.responseText;
                  if (sOptions.length>0){
                      var aOptions = sOptions.split("$");
                      select.options.length=0;
                      for(var i=0; i<aOptions.length; i++){
                      	aOptions[i] = aOptions[i].replace(/^\s+/,'');
                      	aOptions[i] = aOptions[i].replace(/\s+$/,'');
                          if ((aOptions[i].length>0)&&(aOptions[i]!=" ")){
                          	select.options[i] = new Option(aOptions[i].split("�")[1], aOptions[i].split("�")[0]);
                          }
                      }
                  }
              },
              onFailure: function(){
              }
          }
      );
  }

</script>

<%=writeJSButtons("transactionForm","saveButton")%>