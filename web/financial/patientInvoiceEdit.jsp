<%@ page import="be.openclinic.finance.PatientInvoice,java.util.Vector,be.openclinic.finance.Debet
,be.openclinic.adt.Encounter,be.openclinic.finance.Prestation,be.openclinic.finance.PatientCredit" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.patientinvoice.edit","edit",activeUser)%>
<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%!
    private String addDebets(Vector vDebets, String sClass, String sWebLanguage, boolean bChecked){
        StringBuffer sReturn = new StringBuffer();

            if (vDebets!=null){
            Debet debet;
            Encounter encounter;
            Prestation prestation;
            String sEncounterName, sPrestationDescription, sCredited, sDebetUID;
            String sChecked = "";
            if (bChecked){
                sChecked = " checked";
            }

            for (int i = 0; i < vDebets.size(); i++) {
                sDebetUID = checkString((String) vDebets.elementAt(i));

                if (sDebetUID.length()>0){
                    debet = Debet.get(sDebetUID);

                    if (debet != null) {
                        if (sClass.equals("")) {
                            sClass = "1";
                        } else {
                            sClass = "";
                        }

                        sEncounterName = "";

                        if (checkString(debet.getEncounterUid()).length() > 0) {
                            encounter = debet.getEncounter();

                            if (encounter != null) {
                                sEncounterName = encounter.getEncounterDisplayName(sWebLanguage);
                            }
                        }

                        sPrestationDescription = "";

                        if (checkString(debet.getPrestationUid()).length()>0){
                            prestation = debet.getPrestation();

                            if (prestation!=null){
                                sPrestationDescription = checkString(prestation.getDescription());
                            }
                        }

                        sCredited = "";

                        if (debet.getCredited()>0){
                            sCredited = getTran("web","canceled",sWebLanguage);
                        }

                        sReturn.append( "<tr class='list"+sClass+"'>"
                            +"<td><input type='checkbox' name='cbDebet"+debet.getUid()+"="+debet.getAmount()+"' onclick='doBalance(this, true)'"+sChecked+"></td>"
                            +"<td>"+ScreenHelper.getSQLDate(debet.getDate())+"</td>"
                            +"<td>"+new SimpleDateFormat("dd/MM/yyyy HH:mm").format(debet.getCreateDateTime())+"</td>"
                            +"<td>"+sEncounterName+"</td>"
                            +"<td>"+debet.getQuantity()+" x "+sPrestationDescription+"</td>"
                            +"<td>"+debet.getAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>"
                            +"<td>"+sCredited+"</td>"
                            +"<td>"+ScreenHelper.checkString(debet.getInsurarInvoiceUid()).replaceAll("1\\.","")+"</td>"
                        +"</tr>");
                    }
                }
            }
        }
        return sReturn.toString();
    }

    private String addCredits(Vector vCredits, String sClass, boolean bChecked, String sWebLanguage){
        StringBuffer sReturn = new StringBuffer();

        if (vCredits!=null){
            String sPatientCreditUID;
            PatientCredit patientcredit;
            String sChecked = "";
            if (bChecked){
                sChecked = " checked";
            }

            for (int i=0;i<vCredits.size();i++){
                sPatientCreditUID = checkString((String)vCredits.elementAt(i));

                if (sPatientCreditUID.length()>0){
                    patientcredit = PatientCredit.get(sPatientCreditUID);

                    if (patientcredit!=null){
                        if (sClass.equals((""))){
                            sClass = "1";
                        }
                        else {
                            sClass = "";
                        }

                        sReturn.append( "<tr class='list"+sClass+"'>"
                            +"<td><input type='checkbox' name='cbPatientInvoice"+patientcredit.getUid()+"="+patientcredit.getAmount()+"' onclick='doBalance(this, false)'"+sChecked+"></td>"
                            +"<td>"+ScreenHelper.getSQLDate(patientcredit.getDate())+"</td>"
                            +"<td>"+getTran("credit.type",checkString(patientcredit.getType()),sWebLanguage)+"</td>"
                            +"<td align='right'>"+patientcredit.getAmount()+" "+MedwanQuery.getInstance().getConfigParam("currency","€")+"</td>"
                        +"</tr>");
                    }
                }
            }
        }
        return sReturn.toString();
    }
%>
<%

	String sFindPatientInvoiceUID = checkString(request.getParameter("FindPatientInvoiceUID"));

	PatientInvoice patientInvoice;
    String sPatientInvoiceID = "", sPatientId = "", sClosed ="", sInsurarReference="";

    if (sFindPatientInvoiceUID.length() > 0) {
        patientInvoice = PatientInvoice.getViaInvoiceUID(sFindPatientInvoiceUID);
        if (patientInvoice!=null && patientInvoice.getDate()!=null){
            sPatientInvoiceID = checkString(patientInvoice.getInvoiceUid());
            sPatientId = patientInvoice.getPatientUid();
            if(request.getParameter("LoadPatientId")!=null && (activePatient==null || !sPatientId.equalsIgnoreCase(activePatient.personid))){
            	Connection conn = MedwanQuery.getInstance().getAdminConnection();
            	if(activePatient==null){
            		activePatient=new AdminPerson();
            		session.setAttribute("activePatient",activePatient);
            	}
            	activePatient.initialize(conn,sPatientId);
            	conn.close();
            	%>
            	<script>window.location.href='<c:url value='/main.do'/>?Page=financial/patientInvoiceEdit.jsp&ts=<%=ScreenHelper.getTs()%>&FindPatientInvoiceUID=<%=sFindPatientInvoiceUID%>';</script>
            	<%
            	out.flush();
            }
            sClosed=patientInvoice.getStatus();
            sInsurarReference=patientInvoice.getInsurarreference();
        }
        else{
        	out.println(getTran("web","invoice.does.not.exist",sWebLanguage)+": "+sFindPatientInvoiceUID);
        }

    } else {
        patientInvoice = new PatientInvoice();
        patientInvoice.setDate(new java.util.Date());
        patientInvoice.setStatus(MedwanQuery.getInstance().getConfigString("defaultInvoiceStatus","open"));
        sPatientId = activePatient.personid;
    }
	if(patientInvoice!=null && patientInvoice.getDate()!=null){
	    double dBalance = 0;
	    Vector vDebets = patientInvoice.getDebetStrings();
	
	    if (vDebets!=null){
	        String sDebetUID;
	        Debet debet;
	
	        for (int i=0;i<vDebets.size();i++){
	            sDebetUID = (String) vDebets.elementAt(i);
	            debet=Debet.get(sDebetUID);
	            if (checkString(debet.getUid()).length()>0){
	                if (debet != null) {
	                    dBalance += debet.getAmount();
	                }
	            }
	        }
	    }
	
	    Vector vPatientCredits = PatientCredit.getPatientCreditsViaInvoiceUID(patientInvoice.getUid());
	
	    if (vPatientCredits!=null){
	        String sCreditUID;
	        PatientCredit patientcredit;
	
	        for (int i=0;i<vPatientCredits.size();i++){
	            sCreditUID = checkString((String) vPatientCredits.elementAt(i));
	
	            if (sCreditUID.length()>0){
	                patientcredit = PatientCredit.get(sCreditUID);
	
	                if (patientcredit != null) {
	                    dBalance -= patientcredit.getAmount();
	                }
	            }
	        }
	    }
	%>
	<form name='FindForm' id="FindForm" method='POST'>
	    <%=writeTableHeader("web","patientInvoiceEdit",sWebLanguage,"")%>
	    <table class="menu" width="100%">
	        <tr>
	            <td width="<%=sTDAdminWidth%>"><%=getTran("web.finance","invoiceid",sWebLanguage)%></td>
	            <td>
	                <input type="text" class="text" id="FindPatientInvoiceUID" name="FindPatientInvoiceUID" onblur="isNumber(this)" value="<%=sFindPatientInvoiceUID%>">
	                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchPatientInvoice();">
	                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="doClear()">
	                <input type="button" class="button" name="ButtonFind" value="<%=getTran("web","find",sWebLanguage)%>" onclick="doFind()">
	                <input type="button" class="button" name="ButtonNew" value="<%=getTran("web","new",sWebLanguage)%>" onclick="doNew()">
	            </td>
	        </tr>
	    </table>
	</form>
	<div id="divOpenPatientInvoices" class="searchResults" style="height:120px;"></div>
	<script type="text/javascript">
	    function searchPatientInvoice(){
	        openPopup("/_common/search/searchPatientInvoice.jsp&FindInvoicePatient=<%=sPatientId%>&doFunction=doFind()&ReturnFieldInvoiceNr=FindPatientInvoiceUID&FindInvoicePatientId=<%=sPatientId%>&Action=search&header=false&PopupHeight=420&ts=<%=getTs()%>");
	    }
	
	    function doFind(){
	        if (FindForm.FindPatientInvoiceUID.value.length>0){
	            FindForm.submit();
	        }
	    }
	
	    function doNew(){
	        FindForm.FindPatientInvoiceUID.value = "";
	        EditForm.EditInvoiceUID.value = "";
	
	        FindForm.submit();
	    }
	
	    function doClear(){
	        FindForm.FindPatientInvoiceUID.value='';
	        FindForm.FindPatientInvoiceUID.focus();
	    }
	</script>
	<%
	
	%>
	<form name='EditForm' id="EditForm" method='POST'>
	    <table class='list' border='0' width='100%' cellspacing='1'>
	        <tr>
	            <td class="admin" nowrap><%=getTran("web.finance","invoiceid",sWebLanguage)%></td>
	            <td class="admin2">
	                <input type="hidden" id="EditInvoiceUID" name="EditInvoiceUID" value="<%=checkString(patientInvoice.getInvoiceUid())%>">
	                <input type="text" class="text" readonly id="EditInvoiceUIDText" name="EditInvoiceUIDText" value="<%=sPatientInvoiceID%>">
	                <%
	                	if(checkString(patientInvoice.getNumber()).length()>0 && !patientInvoice.getInvoiceUid().equalsIgnoreCase(patientInvoice.getInvoiceNumber())){
	                		out.print("("+patientInvoice.getInvoiceNumber()+")");
	                	}
	                	if(checkString(patientInvoice.getInvoiceUid()).length()==0 && MedwanQuery.getInstance().getConfigString("multiplePatientInvoiceSeries","").length()>0){
	                		String[] invoiceSeries = MedwanQuery.getInstance().getConfigString("multiplePatientInvoiceSeries").split(";");
	                		out.println("<input type='radio' class='text' name='invoiceseries' value='0'/>"+getTran("web","internal",sWebLanguage));
	                		for(int n=0;n<invoiceSeries.length;n++){
	                    		out.println("<input type='radio' class='text' name='invoiceseries' value='"+invoiceSeries[n]+"'/>"+invoiceSeries[n]);
	                		}
	                	}
	
	                %>
	            </td>
	        </tr>
	        <tr>
	            <td class="admin" nowrap><%=getTran("web.finance","insurarreference",sWebLanguage)%></td>
	            <td class="admin2">
	                <input type="text" size="40" class="text" id="EditInsurarReference" name="EditInsurarReference" value="<%=sInsurarReference%>">
	            </td>
	        </tr>
	        <tr>
	            <td class='admin' nowrap><%=getTran("Web","date",sWebLanguage)%> *</td>
	            <td class='admin2'><%=writeDateField("EditDate","EditForm",ScreenHelper.getSQLDate(patientInvoice.getDate()),sWebLanguage)%></td>
	        </tr>
	        <tr>
	            <td class='admin' nowrap><%=getTran("Web.finance","patientinvoice.status",sWebLanguage)%> *</td>
	            <td class='admin2'>
	                <%
	
	                %>
	                <select id="invoiceStatus" class="text" name="EditStatus" onchange="doStatus()"  <%=patientInvoice.getStatus().equalsIgnoreCase("closed") || patientInvoice.getStatus().equalsIgnoreCase("canceled")?"disabled":""%>>
	                    <%
	
	                        if(checkString(patientInvoice.getStatus()).equalsIgnoreCase("canceled")){
	                            out.print("<option value='canceled'>"+getTran("finance.patientinvoice.status","canceled",sWebLanguage)+"</option>");
	                        }
	                        else {
	                            out.print("<option/>"+ScreenHelper.writeSelectExclude("finance.patientinvoice.status",checkString(patientInvoice.getStatus()),sWebLanguage,false,false,"canceled"));
	                        }
	                    %>
	                </select>
	            </td>
	        </tr>
	        <tr>
	            <td class='admin' nowrap><%=getTran("web.finance","balance",sWebLanguage)%></td>
	            <td class='admin2'>
	                <input class='text' readonly type='text' name='EditBalance' id='EditBalance' value='<%if (checkString(Double.toString(patientInvoice.getBalance())).length()>0){out.print(Double.toString(dBalance));}%>' size='20'> <%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
	            </td>
	        </tr>
	        <tr>
	            <td class='admin' nowrap><%=getTran("web.finance","prestations",sWebLanguage)%></td>
	            <td class='admin2'>
	                <div style="height:120px;"class="searchResults">
	                    <table width="100%" class="list" cellspacing="2">
	                        <tr class="gray">
	                            <td width="20"/>
	                            <td width="80"><%=getTran("web","date",sWebLanguage)%></td>
	                            <td><%=getTran("web","entrydate",sWebLanguage)%></td>
	                            <td><%=getTran("web.finance","encounter",sWebLanguage)%></td>
	                            <td><%=getTran("web","prestation",sWebLanguage)%></td>
	                            <td><%=getTran("web","amount",sWebLanguage)%></td>
	                            <td><%=getTran("web","credit",sWebLanguage)%></td>
	                            <td><%=getTran("web","insuranceinvoiceid",sWebLanguage)%></td>
	                        </tr>
	                    <%
	                        String sClass = "";
	                        out.print(addDebets(vDebets,sClass,sWebLanguage, true));
	
	                        if (!(checkString(patientInvoice.getStatus()).equalsIgnoreCase("closed") || checkString(patientInvoice.getStatus()).equalsIgnoreCase("canceled"))){
	                            Vector vUnassignedDebets = Debet.getUnassignedPatientDebets(sPatientId);
	                            out.print(addDebets(vUnassignedDebets,sClass,sWebLanguage, false));
	                        }
	                    %>
	                    </table>
	                </div>
	                <input class='button' type="button" id="ButtonDebetSelectAll" name="ButtonDebetSelectAll" value="<%=getTran("web","selectall",sWebLanguage)%>" onclick="selectAll('cbDebet',true,'ButtonDebetSelectAll','ButtonDebetDeselectAll',true);">&nbsp;
	                <input class='button' type="button" id="ButtonDebetDeselectAll" name="ButtonDebetDeselectAll" value="<%=getTran("web","deselectall",sWebLanguage)%>" onclick="selectAll('cbDebet',false,'ButtonDebetDeselectAll','ButtonDebetSelectAll',true);">
	            </td>
	        </tr>
	        <tr>
	            <td class='admin' nowrap><%=getTran("web.finance","credits",sWebLanguage)%></td>
	            <td class='admin2'>
	                <div style="height:120px;"class="searchResults">
	                    <table width="100%" class="list" cellspacing="1">
	                        <tr class="gray">
	                            <td width="20"/>
	                            <td width="80"><%=getTran("web","date",sWebLanguage)%></td>
	                            <td ><%=getTran("web","type",sWebLanguage)%></td>
	                            <td align="right"><%=getTran("web","amount",sWebLanguage)%></td>
	                        </tr>
	                    <%
	                        out.print(addCredits(vPatientCredits,sClass,true,sWebLanguage));
	
	                        if (!(checkString(patientInvoice.getStatus()).equalsIgnoreCase("closed")||checkString(patientInvoice.getStatus()).equalsIgnoreCase("canceled"))){
	                            Vector vUnassignedCredits = PatientCredit.getUnassignedPatientCredits(sPatientId);
	                            out.print(addCredits(vUnassignedCredits,sClass,false,sWebLanguage));
	                        }
	                    %>
	                    </table>
	                </div>
	                <input class='button' type="button" id="ButtonPatientInvoiceSelectAll" name="ButtonPatientInvoiceSelectAll" value="<%=getTran("web","selectall",sWebLanguage)%>" onclick="selectAll('cbPatientInvoice',true,'ButtonPatientInvoiceSelectAll', 'ButtonPatientInvoiceDeselectAll',false);">&nbsp;
	                <input class='button' type="button" id="ButtonPatientInvoiceDeselectAll" name="ButtonPatientInvoiceDeselectAll" value="<%=getTran("web","deselectall",sWebLanguage)%>" onclick="selectAll('cbPatientInvoice',false,'ButtonPatientInvoiceDeselectAll', 'ButtonPatientInvoiceSelectAll',false);">
	            </td>
	        </tr>
	        <tr>
	            <td class="admin"/>
	            <td class="admin2">
	                <%
	                if (!(checkString(patientInvoice.getStatus()).equalsIgnoreCase("closed")||checkString(patientInvoice.getStatus()).equalsIgnoreCase("canceled"))){
	                %>
	                <input class='button' type="button" name="buttonSave" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onclick="doSave(this);">&nbsp;
	                <%
	                }
	
	                // pdf print button for existing invoices
	                if(checkString(patientInvoice.getUid()).length() > 0){
	                    %>
	                        <%=getTran("Web.Occup","PrintLanguage",sWebLanguage)%>
	
	                        <%
	                            String sPrintLanguage = activeUser.person.language;
	
	                            if (sPrintLanguage.length()==0){
	                                sPrintLanguage = sWebLanguage;
	                            }
	
	                            String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");
	                        %>
	
	                        <select class="text" name="PrintLanguage">
	                            <%
	                                String tmpLang;
	                                StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages, ",");
	                                while (tokenizer.hasMoreTokens()) {
	                                    tmpLang = tokenizer.nextToken();
	
	                                    %><option value="<%=tmpLang%>"<%if (tmpLang.equalsIgnoreCase(sPrintLanguage)){out.print(" selected");}%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
	                                }
	                            %>
	                        </select>
	
	                        <input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print",sWebLanguage)%>' onclick="doPrintPdf('<%=patientInvoice.getUid()%>');">
	                        <input class="button" type="button" name="buttonPrint" value='PROFORMA' onclick="doPrintProformaPdf('<%=patientInvoice.getUid()%>');">
	                        <%
	                        	if(MedwanQuery.getInstance().getConfigInt("javaPOSenabled",0)==1){
	                        %>
	                        <input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print.receipt",sWebLanguage)%>' onclick="doPrintPatientReceipt('<%=patientInvoice.getUid()%>');">
	                        <%
	                        	}
	                        %>
	                        <%
	                            if (!(checkString(patientInvoice.getStatus()).equalsIgnoreCase("canceled"))){
	                            	if(!patientInvoice.getStatus().equalsIgnoreCase("closed")||(activeUser.getParameter("sa")!=null && activeUser.getParameter("sa").length() > 0)||activeUser.getAccessRight("financial.cancelclosedinvoice.select")){
	                        %>
	                                	<input class="button" type="button" name="buttonCancellation" value='<%=getTranNoLink("Web.finance","cancellation",sWebLanguage)%>' onclick="doCancel('<%=patientInvoice.getUid()%>');">
	                        <%
	                            	}
	                        %>
	                                <input class="button" type="button" name="buttonPayment" value='<%=getTranNoLink("Web.finance","payment",sWebLanguage)%>' onclick="doPayment('<%=patientInvoice.getUid()%>');">
	                        <%
	                            }
	                        %>
	                    <%
	                }
	                %>
	            </td>
	        </tr>
	    </table>
	    <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>.
	    <div id="divMessage"></div>
	    <input type='hidden' id="EditPatientInvoiceUID" name='EditPatientInvoiceUID' value='<%=checkString(patientInvoice.getUid())%>'>
	</form>
	<%
	
	%>
	<script type="text/javascript">
	    function doSave(){
	        var bInvoiceSeries=false;
	        var sInvoiceSeries="";
	        if(EditForm.invoiceseries){
	        	for (var i=0; i < EditForm.invoiceseries.length; i++){
	        	   if (EditForm.invoiceseries[i].checked){
	        	      bInvoiceSeries=true;
	        	      sInvoiceSeries=EditForm.invoiceseries[i].value;
	        	   }
	        	}
	        }
	        else {
				bInvoiceSeries=true;
	        }
	        if ((document.getElementById('EditDate').value.length>8)&&(document.getElementById('invoiceStatus').selectedIndex>-1)&&bInvoiceSeries){
	            var invoiceDate = new Date(document.getElementById('EditDate').value.substring(6)+"/"+document.getElementById('EditDate').value.substring(3,5)+"/"+document.getElementById('EditDate').value.substring(0,2));
	            if(invoiceDate> new Date()){
	                var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=dateinfuture";
	                var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
	                (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","dateinfuture",sWebLanguage)%>");
	            }
	        <%
	        	boolean canCloseUnpaidInvoice=(activeUser.getParameter("sa")!=null && activeUser.getParameter("sa").length() > 0)||activeUser.getAccessRight("financial.closeunpaidinvoice.select");
	        	if(!canCloseUnpaidInvoice){
	        %>
	            else if(document.getElementById('EditBalance').value.replace('.','').replace('0','').length>0 && document.getElementById('invoiceStatus').value=="closed"){
	                var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=cannotcloseunpaidinvoice";
	                var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
	                (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","cannotcloseunpaidinvoice",sWebLanguage)%>");
	            }
	        <%
	        	}
	        %>
	            else {
		            if ((document.getElementById('EditBalance').value*1==0)&&(document.getElementById('invoiceStatus').value!="closed")&&(document.getElementById('invoiceStatus').value!="canceled")){
		                var popupUrl = "<c:url value='/popup.jsp'/>?Page=_common/search/yesnoPopup.jsp&ts=<%=getTs()%>&labelType=web.finance&labelID=closetheinvoice";
		                var modalities = "dialogWidth:266px;dialogHeight:143px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
		                var answer = (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.finance","closetheinvoice",sWebLanguage)%>");
		
		                if(answer==1){
		                    EditForm.EditStatus.value = "closed";
		                }
		            }
		
		            var sCbs = "";
		            for(i = 0; i < EditForm.elements.length; i++) {
		                elm = EditForm.elements[i];
		
		                if ((elm.type == 'checkbox')&&(elm.checked)) {
		                    sCbs += elm.name.split("=")[0]+",";
		                }
		            }
		            var today = new Date();
		            var url= '<c:url value="/financial/patientInvoiceSave.jsp"/>?ts='+today;
		            document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
		            new Ajax.Request(url,{
		                  method: "POST",
		                  postBody: 'EditDate=' + document.getElementById('EditDate').value
		                          +'&EditPatientInvoiceUID=' + EditForm.EditPatientInvoiceUID.value
		                          +'&EditInvoiceUID=' + EditForm.EditInvoiceUID.value
		                          +'&EditStatus=' + document.getElementById('invoiceStatus').value
		                          +'&EditCBs='+sCbs
		                          +'&EditInvoiceSeries='+sInvoiceSeries
		                          +'&EditInsurarReference='+EditForm.EditInsurarReference.value
		                          +'&EditBalance=' + document.getElementById('EditBalance').value,
		                  onSuccess: function(resp){
		                      var label = eval('('+resp.responseText+')');
		                      $('divMessage').innerHTML=label.Message;
		                      $('EditPatientInvoiceUID').value=label.EditPatientInvoiceUID;
		                      $('EditInvoiceUID').value=label.EditInvoiceUID;
		                      $('EditInvoiceUIDText').value=label.EditInvoiceUID;
		                      $('EditInsurarReference').value=label.EditInsurarReference;
		                      $('FindPatientInvoiceUID').value=label.EditInvoiceUID;
		                      doFind();
		                  },
		                  onFailure: function(){
		                      $('divMessage').innerHTML = "Error in function manageTranslationsStore() => AJAX";
		                  }
		              }
		            );
		        }
	        }
	        else {
	            var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
	            var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
	            (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm("<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>");
	        }
	    }
	
	    function selectAll(sStartsWith, bValue, buttonDisable, buttonEnable, bAdd){
	        for(i = 0; i < EditForm.elements.length; i++) {
	            elm = EditForm.elements[i];
	
	            if(elm.name.indexOf(sStartsWith)>-1){
	                if ((elm.type == 'checkbox')&&(elm.checked!=bValue)) {
	                    elm.checked = bValue;
	                    doBalance(elm, bAdd);
	                }
	            }
	        }
	
	    }
	
	    function doBalance(oObject, bAdd){
	        var amount = oObject.name.split("=")[1];
	
	        if (bAdd){
	            if (oObject.checked){
	            	document.getElementById('EditBalance').value = parseFloat(document.getElementById('EditBalance').value) + parseFloat(amount);
	            }
	            else {
	            	document.getElementById('EditBalance').value = parseFloat(document.getElementById('EditBalance').value) - parseFloat(amount);
	            }
	        }
	        else {
	            if (oObject.checked){
	            	document.getElementById('EditBalance').value = parseFloat(document.getElementById('EditBalance').value) - parseFloat(amount);
	            }
	            else {
	            	document.getElementById('EditBalance').value = parseFloat(document.getElementById('EditBalance').value) + parseFloat(amount);
	            }
	        }
	        document.getElementById('EditBalance').value = format_number(document.getElementById('EditBalance').value,<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
	    }
	
	    function doPrintPdf(invoiceUid){
	        if (("<%=sClosed%>"!="closed")&&("<%=sClosed%>"!="canceled")){
	            alert("<%=getTranNoLink("web","closetheinvoicefirst",sWebLanguage)%>");
	        }
	        else {
	              var url = "<c:url value='/financial/createPatientInvoicePdf.jsp'/>?Proforma=no&InvoiceUid="+invoiceUid+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value;
	              window.open(url,"PatientInvoicePdf<%=new java.util.Date().getTime()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
	          }
	    }
	
	    function doPrintProformaPdf(invoiceUid){
	      var url = "<c:url value='/financial/createPatientInvoicePdf.jsp'/>?Proforma=yes&InvoiceUid="+invoiceUid+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value;
	      window.open(url,"PatientInvoicePdf<%=new java.util.Date().getTime()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
	    }
	
	    function setPatientInvoice(sUid){
	        FindForm.FindPatientInvoiceUID.value = sUid;
	        FindForm.submit();
	    }
	
	    function doPrintPatientReceipt(invoiceUid){
	        var params = '';
	        var today = new Date();
	        var url= '<c:url value="/financial/printPatientReceipt.jsp"/>?invoiceuid='+invoiceUid+'&ts='+today;
	        new Ajax.Request(url,{
					method: "GET",
	                parameters: params,
	                onSuccess: function(resp){
	                	var label = eval('('+resp.responseText+')');
	                	if(label.message.length>0){
	                    	alert(label.message);
	                    };
	                },
					onFailure: function(){
	                }
	            }
			);
	    }
	    
	    function loadOpenPatientInvoices(){
	        var params = '';
	        var today = new Date();
	        var url= '<c:url value="/financial/patientInvoiceGetOpenPatientInvoices.jsp"/>?PatientId=<%=sPatientId%>&ts='+today;
	        document.getElementById('divOpenPatientInvoices').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
	        new Ajax.Request(url,{
					method: "GET",
	                parameters: params,
	                onSuccess: function(resp){
	                    $('divOpenPatientInvoices').innerHTML=resp.responseText;
	                },
					onFailure: function(){
	                }
	            }
			);
	    }
	
	    function doStatus(){
	    }
	
	    function doCancel(invoiceUid){
	        if(confirm("<%=getTran("Web","AreYouSure",sWebLanguage)%>")){
	            //Factuur als 'geannuleerd' registreren
	            document.getElementById("invoiceStatus").options[document.getElementById("invoiceStatus").selectedIndex].value='canceled';
	            doSave();
	        }
	    }
	
	    function doPayment (invoiceUid){
	        openPopup("/financial/patientCreditEdit.jsp&ts=<%=getTs()%>&EditCreditInvoiceUid="+invoiceUid+"&ScreenType=doPayment");
	    }
	
	    FindForm.FindPatientInvoiceUID.focus();
	    loadOpenPatientInvoices();
	    document.getElementById('EditBalance').value = format_number(document.getElementById('EditBalance').value,<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
	</script>
<%
	}
%>
