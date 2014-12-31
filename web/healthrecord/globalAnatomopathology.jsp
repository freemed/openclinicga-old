<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("occup.anatomopathology","select",activeUser)%>

<form name="transactionForm" id="transactionForm" method="POST" action='<c:url value="/healthrecord/updateTransaction.do"/>?ts=<%=getTs()%>'>
    <bean:define id="transaction" name="be.mxs.webapp.wl.session.SessionContainerFactory.WO_SESSION_CONTAINER" property="currentTransactionVO"/>
	<%=checkPrestationToday(activePatient.personid, false,activeUser,(TransactionVO)transaction) %>
  
    <input type="hidden" id="transactionId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionId" value="<bean:write name="transaction" scope="page" property="transactionId"/>"/>
    <input type="hidden" id="serverId" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.serverId" value="<bean:write name="transaction" scope="page" property="serverId"/>"/>
    <input type="hidden" id="transactionType" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.transactionType" value="<bean:write name="transaction" scope="page" property="transactionType"/>"/>
    <input type="hidden" readonly name="be.mxs.healthrecord.updateTransaction.actionForwardKey" value="/main.do?Page=curative/index.jsp&ts=<%=getTs()%>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT" translate="false" property="value"/>"/>
    <input type="hidden" readonly name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT" translate="false" property="value"/>"/>

    <%=writeHistoryFunctions(((TransactionVO)transaction).getTransactionType(),sWebLanguage)%>
    <%=contextHeader(request,sWebLanguage)%>

    <%
        SessionContainerWO sessionContainerWO = (SessionContainerWO) SessionContainerFactory.getInstance().getSessionContainerWO(request, SessionContainerWO.class.getName());
        String sIdentificationNr = "";
        if(sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue() > 0){
            ItemVO item = sessionContainerWO.getCurrentTransactionVO().getItem(sPREFIX+"ITEM_TYPE_ANATOMOPATHOLOGY_IDENTIFICATION_NUMBER");
            if(item!=null){
                sIdentificationNr = item.getValue();
            }
        }
        else{
            String sServerID = sessionContainerWO.getCurrentTransactionVO().getServerId()+"";
            sIdentificationNr = "5"+ScreenHelper.padLeft(sServerID,"0",3)+MedwanQuery.getInstance().getNewOccupCounterValue("IdentificationAnatomopathologyID");
        }
        
        TransactionVO tran = (TransactionVO)transaction;
    %>

    <table class="list" cellspacing="1" cellpadding="0" width="100%">
        <%-- DATE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <a href="javascript:openHistoryPopup();" title="<%=getTranNoLink("Web.Occup","History",sWebLanguage)%>">...</a>&nbsp;
                <%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.<TransactionVO[hashCode=<bean:write name="transaction" scope="page" property="transactionId"/>]>.updateTime" value="<mxs:propertyAccessorI18N name="transaction" scope="page" property="updateTime" formatType="date"/>" id="trandate" OnBlur='checkDate(this)'>
                <script>writeTranDate();</script>
            </td>
        </tr>

        <%-- identification number --%>
        <tr>
            <td class='admin'><%=getTran("openclinic.chuk","identificationumber",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="text" id='rxid' class="text" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_IDENTIFICATION_NUMBER" property="itemId"/>]>.value" value="<%=sIdentificationNr%>" READONLY>
            </td>
        </tr>
        
        <%-- internal number --%>
        <tr>
            <td class='admin'><%=getTran("openclinic.chuk","internalNumber",sWebLanguage)%></td>
            <td class='admin2'>
                <input type="text" class="text" size="20" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_INTERNAL_NUMBER" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_INTERNAL_NUMBER" property="value"/>">
            </td>
        </tr>

		<%-- dates (reception, reported) --%>
		<tr>
            <td class="admin" width="<%=sTDAdminWidth%>">
                <%=getTran("Web.Occup","specimen.reception.date",sWebLanguage)%>
            </td>
            <td class="admin2">
            	<table width='100%'>
            		<tr>
            			<td class='admin2' width='200px' nowrap>
			                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_SPECIMEN_RECEPTION_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_SPECIMEN_RECEPTION_DATE" property="value"/>" id="specimenreceptiondate" OnBlur='checkDate(this)'>
			                <script>writeMyDate("specimenreceptiondate");</script>
            			</td>
			            <td class="admin" width="<%=sTDAdminWidth%>">
			                <%=getTran("Web.Occup","reported.date",sWebLanguage)%>
			            </td>
            			<td class='admin2'>
			                <input type="text" class="text" size="12" maxLength="10" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_SPECIMEN_REPORTED_DATE" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_SPECIMEN_REPORTED_DATE" property="value"/>" id="reporteddate" OnBlur='checkDate(this)'>
			                <script>writeMyDate("reporteddate");</script>
            			</td>
            		</tr>
            	</table>
            </td>
		</tr>
		
		<%-- physician --%>
        <tr>
            <td class='admin'><%=getTran("web","physician",sWebLanguage)%></td>
            <td class='admin2'>
            	<table width='100%'>
            		<tr>
            			<td class='admin2' width='200px' nowrap>
			                <input type="text" class="text" size="30" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_PHYSICIAN")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_PHYSICIAN" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_PHYSICIAN" property="value"/>">
            			</td>
			            <td class="admin" width="<%=sTDAdminWidth%>">
			                <%=getTran("web","address",sWebLanguage)%>
			            </td>
            			<td class='admin2'>
			                <input type="text" class="text" size="40" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_ADDRESS")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_ADDRESS" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_ADDRESS" property="value"/>">
            			</td>
            		</tr>
            	</table>
            </td>
        </tr>
		
        <%-- location-site, -organ, -detail --%>
        <tr>
            <td class="admin"><%=getTran("web","anatomical.location",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
            	<table width='100%'>
            		<tr>
            		    <td class="admin2" width='1%' nowrap><%=getTran("web","anatomical.location.site",sWebLanguage)%>&nbsp;</td>
            		    <td>
			            	<select id='location.site' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_LOCATION_SITE" property="itemId"/>]>.value" class="text" onchange="fillDetail('location.organ',this.value,'<%=tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_LOCATION_ORGAN")%>');">
				                <option/>
				                <%=ScreenHelper.writeSelect("location.site", tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_LOCATION_SITE"), sWebLanguage)%>
				            </select>
            		    </td>
            		</tr>
            		<tr>
            		    <td class="admin2" width='1%' nowrap><%=getTran("web","anatomical.location.organ",sWebLanguage)%>&nbsp;</td>
            		    <td>
			            	<select id='location.organ' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_LOCATION_ORGAN" property="itemId"/>]>.value" class="text">
				            <option/>
				                <%=ScreenHelper.writeSelect("location.site."+tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_LOCATION_SITE"), tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_LOCATION_ORGAN"), sWebLanguage,false,false)%>
				            </select>
            		    </td>
            		</tr>
            		<tr>
            		    <td class="admin2" width='1%' nowrap><%=getTran("web","anatomical.location.detail",sWebLanguage)%>&nbsp;</td>
            		    <td>
							<input type="text" class="text" size="80" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_LOCATION_DETAIL")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_LOCATION_DETAIL" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_LOCATION_DETAIL" property="value"/>">
            		    </td>
            		</tr>
            	
            	</table>
            </td>
        </tr>

        <%-- procedure --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","procedure_type",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
	           	<select id='procedure.type' name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_PROCEDURE_TYPE" property="itemId"/>]>.value" class="text" onchange="checkprocedure();">
		            <option>
	                <%=ScreenHelper.writeSelect("procedure.type", tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_PROCEDURE_TYPE"), sWebLanguage,false,false)%>
		            <option value='0' <%=(tran.getItemValue("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_PROCEDURE_TYPE")+"").equals("0")?"selected":"" %>><%=getTran("web","other.procedure",sWebLanguage) %></option>
	            </select>
				<input id='proceduretext' type="text" class="text" size="40" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_LOCATION_PROCEDURE_TEXT")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_PROCEDURE_TEXT" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_PROCEDURE_TEXT" property="value"/>">
            </td>
        </tr>

        <%-- history --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","clinical_data",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,2999);" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_HISTORY")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_HISTORY" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_HISTORY" property="value"/></textarea>
            </td>
        </tr>

        <%-- gross description --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","gross.description",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,2999);" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_GROSS_DESCRIPTION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_GROSS_DESCRIPTION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_GROSS_DESCRIPTION" property="value"/></textarea>
            </td>
        </tr>

        <%-- microscopic examination --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","microscopic.examination",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,2999);" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_MICROSCOPIC_EXAMINATION")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_MICROSCOPIC_EXAMINATION" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_MICROSCOPIC_EXAMINATION" property="value"/></textarea>
            </td>
        </tr>

        <%-- result / conclusion --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","conclusion",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,2999);" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_RESULT")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_RESULT" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_RESULT" property="value"/></textarea>
            </td>
        </tr>

        <%-- canreg --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","canreg",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
				<input type="text" class="text" size="20" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_CANREG")%> name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_CANREG" property="itemId"/>]>.value" value="<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_CANREG" property="value"/>">
            </td>
        </tr>

        <%-- declared valid --%>
        <tr>
            <td class="admin"><%=getTran("openclinic.chuk","declared_valid",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <textarea onKeyup="resizeTextarea(this,10);limitChars(this,2999);" <%=setRightClick("ITEM_TYPE_ANATOMOPATHOLOGY_DECLARED_VALID")%> class="text" cols="100" rows="2" name="currentTransactionVO.items.<ItemVO[hashCode=<mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_DECLARED_VALID" property="itemId"/>]>.value"><mxs:propertyAccessorI18N name="transaction.items" scope="page" compare="type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_ANATOMOPATHOLOGY_DECLARED_VALID" property="value"/></textarea>
            </td>
        </tr>
    </table>
    
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>   
        <%=getButtonsHtml(request,activeUser,activePatient,"occup.anatomopathology",sWebLanguage)%>
    <%=ScreenHelper.alignButtonsStop()%>

    <%=ScreenHelper.contextFooter(request)%>
</form>

<script>
    <%-- CHECK PROCEDURE --%>
	function checkprocedure(){
		if(document.getElementById('procedure.type').value=='0'){
			document.getElementById('proceduretext').style.display='';
		}	
		else{
			document.getElementById('proceduretext').style.display='none';
		}
	}
	
	checkprocedure();

	<%-- FILL DETAIL --%>	
	function fillDetail(selectname,type,selectedvalue){
		document.getElementById(selectname).options.length = 0;
		
		<%
			Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
			if(labelTypes!=null){
				Hashtable labelIds = (Hashtable)labelTypes.get("location.site");
				if(labelIds!=null){
					Enumeration idEnum = labelIds.keys();
					while(idEnum.hasMoreElements()){
						String type = (String)idEnum.nextElement();
						out.println("if(type=='"+type+"'){");
						
						// Voor dit type gaan we nu de opties zetten
						Hashtable options = (Hashtable)labelTypes.get("location.site."+type.toLowerCase());
						SortedMap sortedoptions = new TreeMap(); 
						if(options!=null){
							Enumeration optionEnum = options.elements();
							int counter = 0;
							
							while(optionEnum.hasMoreElements()){
								String optionkey = ((Label)optionEnum.nextElement()).id.replace("'", "´");
								String optionvalue = ((Label)options.get(optionkey)).value.replace("'", "´");
								sortedoptions.put(Integer.parseInt(optionkey), optionvalue);
							}
							
							Iterator iOptions = sortedoptions.keySet().iterator();
							while(iOptions.hasNext()){
								int optionkey=(Integer)iOptions.next();
								String optionvalue=(String)sortedoptions.get(optionkey);
								out.println("document.getElementById(selectname).options["+counter+"] = new Option('"+optionvalue+"','"+optionkey+"',false,selectedvalue=='"+optionkey+"');");
								counter++;
							}
						}
						
						//out.println("Array.prototype.sort.call(document.getElementById(selectname).options,function(a,b){return a.text < b.text ? -1 : a.text > b.text ? 1 : 0;});");
						out.println("if(document.getElementById(selectname).onchange) document.getElementById(selectname).onchange();");
						out.println("}");
					}
				}
			}
		%>
	}
	
  <%-- PRINT LABELS --%>
  function printLabels(){
    var url = "<c:url value='/healthrecord/createAnatomopathologyLabelPdf.jsp'/>"+
              "?imageid="+document.getElementsByName("rxid")[0].value+
    		  "&trandate="+document.getElementsByName("trandate")[0].value+
    		  "&ts=<%=getTs()%>";
    window.open(url,"Popup"+new Date().getTime(),"toolbar=no,status=yes,scrollbars=yes,resizable=yes,width=400,height=300,menubar=no").moveTo((screen.width-400)/2,(screen.height-300)/2);
  }

  <%-- SUBMIT FORM --%>
  function submitForm(){
    var temp = Form.findFirstElement(transactionForm);// FOR COMPATIBILITY WITH FIREFOX
    document.getElementById("buttonsDiv").style.visibility = "hidden";
    <% out.print(takeOverTransaction(sessionContainerWO,activeUser,"document.transactionForm.submit();")); %>
  }
  
  checkprocedure();
</script>

<%=writeJSButtons("transactionForm","saveButton")%>