<%@ page import="be.openclinic.finance.*,be.openclinic.adt.Encounter,java.text.*,be.mxs.common.util.system.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.patientinvoice","edit",activeUser)%>
<%=sJSPROTOTYPE%>
<%=sJSNUMBER%> 
<%=sJSSTRINGFUNCTIONS%>
<%!
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
                            +"<td><input type='checkbox' name='cbPatientInvoice"+patientcredit.getUid()+"="+patientcredit.getAmount()+"' id='"+patientcredit.getType()+"."+patientcredit.getUid()+"' onclick='doBalance(this, false)'"+sChecked+"></td>"
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
	boolean isInsuranceAgent=false;
	if(activeUser!=null && activeUser.getParameter("insuranceagent")!=null && activeUser.getParameter("insuranceagent").length()>0 && MedwanQuery.getInstance().getConfigString("InsuranceAgentAcceptationNeededFor","").indexOf("*"+activeUser.getParameter("insuranceagent")+"*")>-1){
		//This is an insurance agent, limit the functionalities
		isInsuranceAgent=true;
	}
	
	String sExternalSignatureCode= checkString(request.getParameter("externalsignaturecode"));
	String sFindPatientInvoiceUID = checkString(request.getParameter("FindPatientInvoiceUID"));
	boolean automaticPayment=false;
	
	if(!isInsuranceAgent && checkString(request.getParameter("quick")).equals("1")){
		Vector unassignedDebets = Debet.getUnassignedPatientDebets(activePatient.personid);
		if(unassignedDebets.size()>0){
			PatientInvoice invoice=new PatientInvoice();
			invoice.setCreateDateTime(new java.util.Date());
			invoice.setDate(new java.util.Date());
			invoice.setPatientUid(activePatient.personid);
			invoice.setStatus("open");
			invoice.setUpdateDateTime(new java.util.Date());
			invoice.setUpdateUser(activeUser.userid);
			invoice.setVersion(1);
			invoice.setDebets(new Vector());
			for(int n=0;n<unassignedDebets.size();n++){
				Debet debet = Debet.get((String)unassignedDebets.elementAt(n));
				invoice.getDebets().add(debet);
			}
			invoice.store();
			sFindPatientInvoiceUID=invoice.getUid();
			automaticPayment=true;
		}
	}
	
	PatientInvoice patientInvoice=null;
    String sPatientInvoiceID = "", sPatientId = "", sClosed ="", sInsurarReference="", sInsurarReferenceDate="", sVerifier="",sEditComment="",sPatientInvoiceMfpDoctor="",sPatientInvoiceMfpPost="",sPatientInvoiceMfpAgent="",sPatientInvoiceMfpDrugsRecipient="",sPatientInvoiceMfpDrugsIdCard="",sPatientInvoiceMfpDrugsIdCardPlace="",sPatientInvoiceMfpDrugsIdCardDate="";

    if (sFindPatientInvoiceUID.length() > 0) {
    	if(sFindPatientInvoiceUID.split("\\.").length==2){
    		patientInvoice=patientInvoice.get(sFindPatientInvoiceUID);
    	}
    	else {
    		patientInvoice = PatientInvoice.getViaInvoiceUID(sFindPatientInvoiceUID);
    	}
        if (patientInvoice!=null && patientInvoice.getDate()!=null){
            sPatientInvoiceID = checkString(patientInvoice.getInvoiceUid());
            sPatientId = patientInvoice.getPatientUid();
            if(request.getParameter("LoadPatientId")!=null && (activePatient==null || !sPatientId.equalsIgnoreCase(activePatient.personid))){
            	if(activePatient==null){
            		activePatient=new AdminPerson();
            		session.setAttribute("activePatient",activePatient);
            	}
            	activePatient.initialize(sPatientId);
            	%>
            	<script>window.location.href='<c:url value='/main.do'/>?Page=financial/patientInvoiceEdit.jsp&ts=<%=ScreenHelper.getTs()%>&FindPatientInvoiceUID=<%=sFindPatientInvoiceUID%>';</script>
            	<%
            	out.flush();
            }
            sClosed=patientInvoice.getStatus();
            sInsurarReference=checkString(patientInvoice.getInsurarreference());
            sInsurarReferenceDate=checkString(patientInvoice.getInsurarreferenceDate());
            sVerifier=checkString(patientInvoice.getVerifier());
            sEditComment=checkString(patientInvoice.getComment());
            sPatientInvoiceMfpDoctor=checkString(patientInvoice.getMfpDoctor());
            sPatientInvoiceMfpPost=checkString(patientInvoice.getMfpPost());
            sPatientInvoiceMfpAgent=checkString(patientInvoice.getMfpAgent());
            sPatientInvoiceMfpDrugsRecipient=checkString(patientInvoice.getMfpDrugReceiver());
            sPatientInvoiceMfpDrugsIdCard=checkString(patientInvoice.getMfpDrugReceiverId());
            sPatientInvoiceMfpDrugsIdCardDate=checkString(patientInvoice.getMfpDrugIdCardDate());
            sPatientInvoiceMfpDrugsIdCardPlace=checkString(patientInvoice.getMfpDrugIdCardPlace());
        }
        else{
        	out.println(getTran("web","invoice.does.not.exist",sWebLanguage)+": "+sFindPatientInvoiceUID);
        }

    } else {
        patientInvoice = new PatientInvoice();
        patientInvoice.setDate(new java.util.Date());
        patientInvoice.setStatus(MedwanQuery.getInstance().getConfigString("defaultPatientInvoiceStatus","open"));
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
	                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchPatientInvoice();">
	                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="doClear()">
	                <input type="button" class="button" name="ButtonFind" value="<%=getTran("web","find",sWebLanguage)%>" onclick="doFind()">
	                <% if(!isInsuranceAgent){ %>
	                <input type="button" class="button" name="ButtonNew" value="<%=getTran("web","new",sWebLanguage)%>" onclick="doNew()">
	                <% } %>
	            </td>
	        </tr>
	    </table>
	</form>
	<div id="divOpenPatientInvoices" class="searchResults" style="height:120px;"></div>
	<script>
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
	            <td class="admin" nowrap><table><tr><td class="admin" nowrap><%=getTran("web.finance","insurarreference",sWebLanguage)%></td></tr><tr><td class="admin" nowrap><%=getTran("web.finance","otherreference",sWebLanguage)%></td></tr></table></td>
	            <td class="admin2"><table><tr><td class="admin2" nowrap>
	                <input type="text" size="40" class="text" id="EditInsurarReference" name="EditInsurarReference" value="<%=sInsurarReference%>">
	                <%=getTran("web","date",sWebLanguage)%>: <%=writeDateField("EditInsurarReferenceDate","EditForm",sInsurarReferenceDate,sWebLanguage)%></td></tr><tr><td class="admin2" nowrap>
	                <input type="text" size="40" class="text" id="EditComment" name="EditComment" value="<%=sEditComment%>"></td></tr></table>
	            </td>
	        </tr>
	        <% if(MedwanQuery.getInstance().getConfigInt("enableMFP",0)==1){ %>
	        <tr>
	            <td class="admin">
           			<%=getTran("web.finance","mfp.invoice.drugsrecipient",sWebLanguage)%>
	            </td>
	            <td class="admin2">
	            	<%=getTran("web","name",sWebLanguage)%>: <input type="text" size="30" class="text"  id="EditInvoiceDrugsRecipient" name="EditInvoiceDrugsRecipient" value="<%=sPatientInvoiceMfpDrugsRecipient%>">
	            	<%=getTran("web.finance","mfp.invoice.drugsid",sWebLanguage)%>: <input type="text" size="30" class="text"  id="EditInvoiceDrugsIdCard" name="EditInvoiceDrugsIdCard" value="<%=sPatientInvoiceMfpDrugsIdCard%>"><BR/>
	            	<%=getTran("web","delivered.at",sWebLanguage)%>: <input type="text" size="30" class="text"  id="EditInvoiceDrugsIdCardPlace" name="EditInvoiceDrugsIdCardPlace" value="<%=sPatientInvoiceMfpDrugsIdCardPlace%>">
	            	<%=getTran("web","date",sWebLanguage)%>: <%=writeDateField("EditInvoiceDrugsIdCardDate","EditForm",sPatientInvoiceMfpDrugsIdCardDate,sWebLanguage)%>
	            </td>
	            <td class="admin" nowrap><%=getTran("web.finance","mfp.invoice.data",sWebLanguage)%></td>
	            <td class="admin2">
	            	<table>
	            		<tr>
	            			<td><%=getTran("web.finance","mfp.invoice.doctor",sWebLanguage)%>: <input type="text" size="8" class="text"  id="EditInvoiceDoctor" name="EditInvoiceDoctor" value="<%=sPatientInvoiceMfpDoctor%>"></td>
	            			<td><%=getTran("web.finance","mfp.invoice.post",sWebLanguage)%>: <input type="text" size="8" class="text"  id="EditInvoicePost" name="EditInvoicePost" value="<%=sPatientInvoiceMfpPost%>"></td>
	            			<td><%=getTran("web.finance","mfp.invoice.agent",sWebLanguage)%>: <input type="text" size="8" class="text"  id="EditInvoiceAgent" name="EditInvoiceAgent" value="<%=sPatientInvoiceMfpAgent%>"></td>
	            		</tr>
	            	</table>
	            </td>
	        </tr>
	        <%
	        }
        	if(patientInvoice!=null && patientInvoice.getUid()!=null && checkString(Pointer.getPointer("DERIVED."+patientInvoice.getUid())).length()>0){
        %>
        <tr>
        	<td class='admin'/><td class='admin2'/>
            <td class="admin" nowrap><%=getTran("web.finance","derived.from",sWebLanguage)%></td>
            <td class="admin2">
                <a href="javascript:setPatientInvoice('<%=Pointer.getPointer("DERIVED."+patientInvoice.getUid())%>');"><%=Pointer.getPointer("DERIVED."+patientInvoice.getUid())%></a>
            </td>
        </tr>
        <%	
        	}
        	if(patientInvoice!=null && patientInvoice.getUid()!=null && checkString(Pointer.getPointer("FOLLOW."+patientInvoice.getUid())).length()>0){
        %>
        <tr>
        	<td class='admin'/><td class='admin2'/>
            <td class="admin" nowrap><%=getTran("web.finance","corrected.by.invoice",sWebLanguage)%></td>
            <td class="admin2">
                <a href="javascript:setPatientInvoice('<%=Pointer.getPointer("FOLLOW."+patientInvoice.getUid())%>');"><%=Pointer.getPointer("FOLLOW."+patientInvoice.getUid())%></a>
            </td>
        </tr>
        <%	
        	}
        	if(checkString(patientInvoice.getAcceptationUid()).length()>0){
        %>
        <tr>
        	<td class='admin'/><td class='admin2'/>
            <td class="admin" nowrap><%=getTran("web.finance","accepted.by",sWebLanguage)%></td>
            <td class="admin2">
                <%=MedwanQuery.getInstance().getUserName(Integer.parseInt(patientInvoice.getAcceptationUid())) +" - "+patientInvoice.getAcceptationDate()%>
            </td>
        </tr>
        <%	
        	}
        	if(patientInvoice!=null && patientInvoice.getUid()!=null && checkString(Pointer.getPointer("NOVALIDATE."+patientInvoice.getUid())).length()>0){
        		String refusal=Pointer.getPointer("NOVALIDATE."+patientInvoice.getUid());
        %>
        <tr>
        	<td class='admin'/><td class='admin2'/>
            <td class="admin" nowrap><%=getTran("web.finance","refused.by",sWebLanguage)%></td>
            <td class="admin2">
                <%=MedwanQuery.getInstance().getUserName(Integer.parseInt(refusal.split(";")[0])) +" ("+refusal.split(";")[1]+")"%>
            </td>
        </tr>
        <%	
        	}
	        	if(patientInvoice!=null){
	        		String signatures="";
	        		Vector pointers=Pointer.getFullPointers("INVSIGN."+patientInvoice.getUid());
	        		for(int n=0;n<pointers.size();n++){
	        			if(n>0){
	        				signatures+=", ";
	        			}
	        			String ptr=(String)pointers.elementAt(n);
	        			signatures+=ptr.split(";")[0]+" - "+ScreenHelper.fullDateFormat.format(new SimpleDateFormat("yyyyMMddHHmmSSsss").parse(ptr.split(";")[1]));
	        		}
	        		if(signatures.length()>0){
		    	        %>
		    	        <tr>
		    	        	<td class='admin'/><td class='admin2'/>
		    	            <td class="admin" nowrap><%=getTran("web.finance","signed.by",sWebLanguage)%></td>
		    	            <td class="admin2">
		    	                <%=signatures %>
		    	            </td>
		    	        </tr>
		    	        <%
	        		}
	        	}
	        %>
	        <tr>
	            <td class='admin' nowrap><%=getTran("Web","date",sWebLanguage)%> *</td>
	            <td class='admin2'><%=writeDateField("EditDate","EditForm",ScreenHelper.getSQLDate(patientInvoice.getDate()),sWebLanguage)%></td>
	            <td class='admin' nowrap><%=getTran("Web.finance","patientinvoice.status",sWebLanguage)%> *</td>
	            <td class='admin2'>
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
	                <input class='text' readonly type='text' name='EditBalance' id='EditBalance' value='<%=checkString(Double.toString(patientInvoice.getBalance())).length()>0?new DecimalFormat(MedwanQuery.getInstance().getConfigString("priceFormat")).format(dBalance):""%>' size='20'> <%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
	                &nbsp;<%=getTran("web","total",sWebLanguage) %>: <label id='invoiceValue'></label> <%=MedwanQuery.getInstance().getConfigString("currency","EUR") %>
	                &nbsp;<%=getTran("web","paid",sWebLanguage) %>: <label id='invoicePaid'></label> <%=MedwanQuery.getInstance().getConfigString("currency","EUR") %>
	                &nbsp;100%: <label id='invoice100pct'></label> <%=MedwanQuery.getInstance().getConfigString("currency","EUR") %>
	            </td>
	            <td class='admin' nowrap><%=getTran("web","period",sWebLanguage)%></td>
	            <td class='admin2'>
                    <%=writeDateField("EditBegin", "EditForm", "", sWebLanguage)%>
                    <%=getTran("web","to",sWebLanguage)%>
                    <%=writeDateField("EditEnd", "EditForm", "", sWebLanguage)%>
                    &nbsp;<input type="button" class="button" name="update" value="<%=getTran("web","update",sWebLanguage)%>" onclick="loadDebets();"/>
		            <input type="hidden" name="EditInvoiceService" id="EditInvoiceService" value="">
	            </td>
	        </tr>
	        <%
	        if(patientInvoice==null || patientInvoice.getStatus()==null || patientInvoice.getStatus().equalsIgnoreCase("open") || MedwanQuery.getInstance().getConfigInt("enableInvoiceVerification",0)==1){
	        %>
	            <tr>
	            <% 	
	            	if(patientInvoice==null || patientInvoice.getStatus()==null || patientInvoice.getStatus().equalsIgnoreCase("open")){ 
	            %>
		            	<td class='admin'><%=getTran("web","service",sWebLanguage)%></td>
		            	<td class='admin2'>
				           	<input class="text" type="text" name="EditInvoiceServiceName" id="EditInvoiceServiceName" readonly size="<%=sTextWidth%>" value="">
				           	<img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTran("Web","select",sWebLanguage)%>" onclick="searchService('EditInvoiceService','EditInvoiceServiceName');">
				           	<img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTran("Web","clear",sWebLanguage)%>" onclick="document.getElementById('EditInvoiceService').value='';document.getElementById('EditInvoiceServiceName').value='';">
		                    &nbsp;<input type="button" class="button" name="update2" value="<%=getTran("web","update",sWebLanguage)%>" onclick="loadDebets();"/>
						</td>
				<%
					}
					else {
				%>
					<td class='admin'>&nbsp;</td><td class='admin2'>&nbsp;</td>			                        
		        <%
					}
		            if(MedwanQuery.getInstance().getConfigInt("enableInvoiceVerification",0)==1){ 
		        %>
		            	<td class='admin'><%=getTran("web","verifier",sWebLanguage)%></td>
		            	<td class='admin2'>
				           	<input class="text" type="text" name="EditInvoiceVerifier" id="EditInvoiceVerifier" size="<%=sTextWidth%>" value="<%=sVerifier%>">
						</td>
				<%
					}
					else {
				%>
						<td class='admin'>&nbsp;</td><td class='admin2'>&nbsp;<input type='hidden' name='EditInvoiceVerifier' id='EditInvoiceVerifier' value=''/></td>			                        
		        <%
					}
		        %>
		        </tr>
	        <%
	        }
	        else {
				%>
					<input type='hidden' name='EditInvoiceVerifier' id='EditInvoiceVerifier' value=''/>			                        
		        <%
	        }
  				boolean bReduction=false;
  				Insurance insurance = null;
            	String pid="0";
            	if(patientInvoice!=null){
            		pid=patientInvoice.getPatientUid();
            	}
            	else if(activePatient!=null){
            		pid=activePatient.personid;
            	}

  				if(patientInvoice!=null){
	            	insurance = Insurance.getMostInterestingInsuranceForPatient(pid);
	            	if(patientInvoice!=null && patientInvoice.getStatus()!=null && patientInvoice.getStatus().equals("open") && insurance!=null && insurance.getInsurar()!=null && insurance.getInsurar().getAllowedReductions()!=null && insurance.getInsurar().getAllowedReductions().length()>0){
						out.println("<tr><td class='admin'>"+getTran("web","acceptable.reductions",sWebLanguage)+"</td><td class='admin2' colspan='3'>");
	            		String options[]=insurance.getInsurar().getAllowedReductions().split(";");
	            		int reductionLevel=0;
	            		if(patientInvoice.getReduction()!=null){
	            			reductionLevel=new Double(patientInvoice.getReduction().getAmount()/patientInvoice.getPatientAmount()).intValue();
	            		}
						for(int n=0;n<options.length;n++){
	             			out.print("<input type='radio' "+(n==0 && patientInvoice.getReduction()==null?"checked":"")+" name='reduction' class='text' onclick='removeReductions();doBalance();' onDblClick='uncheckRadio(this);doBalance()' value='"+options[n]+"'>"+options[n]+"%");
						}
	            		bReduction=true;
	            		out.print("</td></tr>");
	            	}
  				}
             	if(!bReduction){
             		out.println("<input type='hidden' name='reduction' id='reduction' value='0'/>");
             	}
             	
             %>
	        <tr>
	            <td class='admin' nowrap><%=getTran("web.finance","prestations",sWebLanguage)%></td>
	            <td class='admin2' colspan='3'>
	                <div style="height:120px;"class="searchResults" id="patientInvoiceDebets" name="patientInvoiceDebets" >
	                </div>
	                <input class='button' type="button" id="ButtonDebetSelectAll" name="ButtonDebetSelectAll" value="<%=getTran("web","selectall",sWebLanguage)%>" onclick="selectAll('cbDebet',true,'ButtonDebetSelectAll','ButtonDebetDeselectAll',true);">&nbsp;
	                <input class='button' type="button" id="ButtonDebetDeselectAll" name="ButtonDebetDeselectAll" value="<%=getTran("web","deselectall",sWebLanguage)%>" onclick="selectAll('cbDebet',false,'ButtonDebetDeselectAll','ButtonDebetSelectAll',true);">
	            </td>
	        </tr>
	        <tr>
	            <td class='admin' nowrap><%=getTran("web.finance","credits",sWebLanguage)%></td>
	            <td class='admin2' colspan='3'>
	                <div style="height:120px;"class="searchResults">
	                    <table id='creditsTable' width="100%" class="list" cellspacing="1">
	                        <tr class="gray">
	                            <td width="20"/>
	                            <td width="80"><%=getTran("web","date",sWebLanguage)%></td>
	                            <td ><%=getTran("web","type",sWebLanguage)%></td>
	                            <td align="right"><%=getTran("web","amount",sWebLanguage)%></td>
	                        </tr>
	                    <%
		                    String sClass = "";
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
	            <td class="admin2" colspan='3'>
	                <%
	                if (!(isInsuranceAgent || checkString(patientInvoice.getStatus()).equalsIgnoreCase("closed")||checkString(patientInvoice.getStatus()).equalsIgnoreCase("canceled"))){
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
	                        <%
	                        	String defaultmodel="default";
	                        	insurance = Insurance.getMostInterestingInsuranceForPatient(pid);
	                        	if(insurance!=null && insurance.getInsurar().getDefaultPatientInvoiceModel()!=null){
	                        		defaultmodel=insurance.getInsurar().getDefaultPatientInvoiceModel();
	                        	}
	                        %>
	                        <select class="text" name="PrintModel" id="PrintModel">
	                            <option value="default" <%=defaultmodel.equalsIgnoreCase("default")?"selected":""%>><%=getTranNoLink("web","defaultmodel",sWebLanguage)%></option>
	                            <option value="ctams" <%=defaultmodel.equalsIgnoreCase("ctams")?"selected":""%>><%=getTranNoLink("web","ctamsmodel",sWebLanguage)%></option>
			                    <%
			                    	if(MedwanQuery.getInstance().getConfigInt("enableMFP",0)==1){
			                    %>
		                            <option value="mfp" <%=defaultmodel.equalsIgnoreCase("mfp")?"selected":""%>><%=getTranNoLink("web","mfpmodel",sWebLanguage)%></option>
		                            <option value="mfppharma" <%=defaultmodel.equalsIgnoreCase("mfpharma")?"selected":""%>><%=getTranNoLink("web","mfpharmamodel",sWebLanguage)%></option>
	                        	<%
                    				}
			                    	if(MedwanQuery.getInstance().getConfigInt("enableCMCK",0)==1){
			                    %>
		                            <option value="cmck" <%=defaultmodel.equalsIgnoreCase("cmck")?"selected":""%>><%=getTranNoLink("web","cmckmodel",sWebLanguage)%></option>
	                        	<%
	                				}
			                    	if(MedwanQuery.getInstance().getConfigInt("enableHMK",0)==1){
			                    %>
		                            <option value="hmk" <%=defaultmodel.equalsIgnoreCase("hmk")?"selected":""%>><%=getTranNoLink("web","hmkmodel",sWebLanguage)%></option>
	                        	<%
                    				}
	                        	%>
	                        </select>
							<%if(!isInsuranceAgent){ %>
	                        <input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print",sWebLanguage)%>' onclick="doPrintPdf('<%=patientInvoice.getUid()%>');">
	                        <%} %>
	                        <%if(MedwanQuery.getInstance().getConfigInt("enableProformaPatientInvoice",0)==1 || activeUser.getAccessRight("financial.printproformapatientinvoice.select")){ %>
	                        <input class="button" type="button" name="buttonPrint" value='PROFORMA' onclick="doPrintProformaPdf('<%=patientInvoice.getUid()%>');">
	                        <%
	                          }
	                        	if(!isInsuranceAgent && MedwanQuery.getInstance().getConfigInt("javaPOSenabled",0)==1){
	                        %>
	                        <input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print.receipt",sWebLanguage)%>' onclick="doPrintPatientReceipt('<%=patientInvoice.getUid()%>');">
	                        <%
	                        	}
	                        	if(!isInsuranceAgent && MedwanQuery.getInstance().getConfigInt("printPDFreceiptenabled",0)==1){
	                        %>
	                        <input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print.receipt.pdf",sWebLanguage)%>' onclick="doPrintPatientReceiptPdf('<%=patientInvoice.getUid()%>');">
	                        <%
	                        	}
	                        %>
	                        <%
	                        	if(MedwanQuery.getInstance().getConfigInt("enablePatientInvoiceRecreation",0)==1 && activeUser.getAccessRight("financial.modifyinvoice.select") && checkString(patientInvoice.getStatus()).equalsIgnoreCase("closed")){
	                        %>
                                	<input class="button" type="button" name="buttonModifyInvoice" value='<%=getTranNoLink("Web.finance","modifyinvoice",sWebLanguage)%>' onclick="doModifyInvoice('<%=patientInvoice.getUid()%>');">
		                    <%
	                        	}
	                            if (!isInsuranceAgent && !(checkString(patientInvoice.getStatus()).equalsIgnoreCase("canceled"))){
	                            	if((MedwanQuery.getInstance().getConfigInt("authorizeCancellationOfOpenInvoices",1)==1 && !patientInvoice.getStatus().equalsIgnoreCase("closed"))||(activeUser.getParameter("sa")!=null && activeUser.getParameter("sa").length() > 0)||activeUser.getAccessRight("financial.cancelclosedinvoice.select")){
	                        %>
	                                	<input class="button" type="button" name="buttonCancellation" value='<%=getTranNoLink("Web.finance","cancellation",sWebLanguage)%>' onclick="doInvoiceCancel('<%=patientInvoice.getUid()%>');">
	                        <%
	                            	}
	                            	Vector userWickets = Wicket.getWicketsForUser(activeUser.userid);
	                            	if(userWickets.size()>0){
	                        %>
                               	<input class="button" type="button" name="buttonPayment" value='<%=getTranNoLink("Web.finance","payment",sWebLanguage)%>' onclick="doPayment('<%=patientInvoice.getUid()%>');">
	                        <%
	                            	}
	                            }
	                        if(isInsuranceAgent && checkString(patientInvoice.getUid()).split("\\.").length==2 && checkString(patientInvoice.getAcceptationUid()).length()==0 && Pointer.getPointer("NOVALIDATE."+patientInvoice.getUid()).length()==0){
	                        %>
                               	<input class="button" type="button" name="buttonAcceptation" value='<%=getTranNoLink("Web.finance","validation",sWebLanguage)%>' onclick="doValidate('<%=patientInvoice.getUid()%>');">
                               	<input class="button" type="button" name="buttonNoAcceptation" value='<%=getTranNoLink("Web.finance","novalidation",sWebLanguage)%>' onclick="doNotValidate('<%=patientInvoice.getUid()%>');">
	                        <%
	                        }
	                        if(!isInsuranceAgent && activeUser.getAccessRight("occup.signinvoices.select")){
		                        %>
                               	<input class="button" type="button" name="buttonSignature" value='<%=getTranNoLink("Web.finance","signature",sWebLanguage)%>' onclick="doSign('<%=patientInvoice.getUid()%>');">
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
	<script>
	
		function doValidate(invoiceuid){
	        var today = new Date();
	        var url= '<c:url value="/financial/patientInvoiceValidate.jsp"/>?ts='+today;
	        new Ajax.Request(url,{
	              method: "POST",
	              postBody: 'EditInvoiceUID=' + invoiceuid,
	              onSuccess: function(resp){
	                  $('FindPatientInvoiceUID').value=invoiceuid;
	            	  doFind();
	              },
	              onFailure: function(){
	                  $('divMessage').innerHTML = "Error in function manageTranslationsStore() => AJAX";
	              }
	          }
	        );
		}
	
		function doNotValidate(invoiceuid){
		    openPopup("/financial/patientInvoiceNoValidate.jsp&ts=<%=getTs()%>&invoiceuid="+invoiceuid,500,200);
		}
	
		function doSign(invoiceuid){
	        var today = new Date();
	        var url= '<c:url value="/financial/patientInvoiceSign.jsp"/>?ts='+today;
	        new Ajax.Request(url,{
	              method: "POST",
	              postBody: 'EditInvoiceUID=' + invoiceuid,
	              onSuccess: function(resp){
	                  $('FindPatientInvoiceUID').value=invoiceuid;
	            	  doFind();
	            	  <%=sExternalSignatureCode%>
	            	  <%
	            	  	if(sExternalSignatureCode.length()>0){
	            	  %>
	            	  		window.close();
	            	  <%
	            	  	}
	            	  %>
	              },
	              onFailure: function(){
	                  $('divMessage').innerHTML = "Error in function manageTranslationsStore() => AJAX";
	              }
	          }
	        );
		}
	
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
	        if ((document.getElementById('EditDate').value.length>8)&&(!document.getElementById('invoiceStatus').selectedIndex || document.getElementById('invoiceStatus').selectedIndex>-1)&&bInvoiceSeries){
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
	            else if(document.getElementById('EditBalance').value.replace('.','').replace('0','').length>0 && document.getElementById('EditBalance').value*1><%=MedwanQuery.getInstance().getConfigString("minimumInvoiceBalance","1")%> && document.getElementById('invoiceStatus').value=="closed"){
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
		
		                if ((elm.type == 'checkbox'||elm.type == 'hidden')&&(elm.checked)) {
		                    sCbs += elm.name.split("=")[0]+",";
		                }
		            }
					reduction=-1;
			    	var reductions=document.getElementsByName('reduction');
					if(reductions[0].type=='radio'){
						for(var n=0;n<reductions.length;n++){
							if(reductions[n].checked){
								reduction=reductions[n].value*1;
							}
				    	}
					}
					else {
						reduction=0;
					}
					red="";
					if(reduction!=-1){
						red=reduction;
					}
		            var today = new Date();
		            var url= '<c:url value="/financial/patientInvoiceSave.jsp"/>?ts='+today;
		            document.getElementById('divMessage').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
		            var status="";
		            if(document.getElementById('invoiceStatus').selectedIndex){
		            	status=document.getElementById("invoiceStatus").options[document.getElementById("invoiceStatus").selectedIndex].value;
		            }
		            else{
		            	status=document.getElementById('invoiceStatus').value;
		            }
		            new Ajax.Request(url,{
		                  method: "POST",
		                  postBody: 'EditDate=' + document.getElementById('EditDate').value
		                          +'&EditPatientInvoiceUID=' + EditForm.EditPatientInvoiceUID.value
		                          +'&EditInvoiceUID=' + EditForm.EditInvoiceUID.value
		                          +'&EditStatus=' + status
		                          +'&EditCBs='+sCbs
		                          +'&EditInvoiceSeries='+sInvoiceSeries
		                          +'&EditInsurarReference='+EditForm.EditInsurarReference.value
		                          +'&EditInsurarReferenceDate='+EditForm.EditInsurarReferenceDate.value
		                          +'&EditInvoiceVerifier='+document.getElementById('EditInvoiceVerifier').value
		                          +'&EditReduction='+red
		                          +'&EditComment='+document.getElementById('EditComment').value
		              	        <% if(MedwanQuery.getInstance().getConfigInt("enableMFP",0)==1){ %>
		                          +'&EditInvoiceDoctor='+document.getElementById('EditInvoiceDoctor').value
		                          +'&EditInvoicePost='+document.getElementById('EditInvoicePost').value
		                          +'&EditInvoiceAgent='+document.getElementById('EditInvoiceAgent').value
		                          +'&EditInvoiceDrugsRecipient='+document.getElementById('EditInvoiceDrugsRecipient').value
		                          +'&EditInvoiceDrugsIdCard='+document.getElementById('EditInvoiceDrugsIdCard').value
		                          +'&EditInvoiceDrugsIdCardDate='+document.getElementById('EditInvoiceDrugsIdCardDate').value
		                          +'&EditInvoiceDrugsIdCardPlace='+document.getElementById('EditInvoiceDrugsIdCardPlace').value
		                        <%}%>
		                          +'&EditBalance=' + document.getElementById('EditBalance').value,
		                  onSuccess: function(resp){
		                      var label = eval('('+resp.responseText+')');
		                      $('divMessage').innerHTML=label.Message;
		                      $('EditPatientInvoiceUID').value=label.EditPatientInvoiceUID;
		                      $('EditInvoiceUID').value=label.EditInvoiceUID;
		                      $('EditInvoiceUIDText').value=label.EditInvoiceUID;
		                      $('EditComment').value=label.EditComment;
		                      $('EditInsurarReference').value=label.EditInsurarReference;
		                      $('EditInsurarReferenceDate').value=label.EditInsurarReferenceDate;
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
	                    window.showModalDialog?alertDialog("web.manage","dataMissing"):alertDialogDirectText('<%=getTran("web.manage","dataMissing",sWebLanguage)%>');
	        }
	    }
	
	    function selectAll(sStartsWith,bValue,buttonDisable,buttonEnable,bAdd){
	      for(i=0; i<EditForm.elements.length; i++){
	        elm = EditForm.elements[i];
	
	        if(elm.name.indexOf(sStartsWith)>-1){
	          if((elm.type == 'checkbox')&&(elm.checked!=bValue)){
	            elm.checked = bValue;
	            doBalance(elm, bAdd);
	          }
	        }
	      }	
	    }
	
	    function doBalance(){
	    	total=0.01;
	    	total=0;
	    	paid=0.01;
	    	paid=0;
	    	insurar=0.01;
	    	insurar=0;
	    	reduction=0.1;
	    	reduction=0;
	    	var elements = document.getElementsByTagName("input");
	    	for(var n=0;n<elements.length;n++){
	    		if(elements[n].name.indexOf("cbDebet")==0 && elements[n].checked){
	    			total+=parseFloat(elements[n].name.split("=")[1].replace(",","."))*1;
	    			insurar+=parseFloat(document.getElementById(elements[n].name.split("=")[0].replace("cbDebet","cbDebetInsurar")).value)*1;
	    		}
	    		else if(elements[n].name.indexOf("cbPatientInvoice")==0 && elements[n].checked){
	    			paid+=parseFloat(elements[n].name.split("=")[1].replace(",","."))*1;
	    		}
	    	}
	    	document.getElementById('invoiceValue').innerHTML='<b>'+total.toFixed(<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>)+'</b>';
	    	document.getElementById('invoicePaid').innerHTML='<b>'+paid.toFixed(<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>)+'</b>';
	    	document.getElementById('invoice100pct').innerHTML='<b>'+((insurar+total).toFixed(<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>))+'</b>';
			var reductions=document.getElementsByName('reduction');
			if(reductions[0].type=='radio'){
				for(var n=0;n<reductions.length;n++){
					if(reductions[n].checked){
						reduction=reductions[n].value;
					}
		    	}
			}
	    	document.getElementById('EditBalance').value = (total-paid-(total*reduction/100)).toFixed(<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
	    }
	
	    function doPrintPdf(invoiceUid){
	        if (<%=activeUser.getAccessRight("financial.printopeninvoice.select")?"1":"0"%>==0 && ("<%=sClosed%>"!="closed")&&("<%=sClosed%>"!="canceled")){
	            alert("<%=getTranNoLink("web","closetheinvoicefirst",sWebLanguage)%>");
	        }
	        else {
	            var url = "<c:url value='/financial/createPatientInvoicePdf.jsp'/>?Proforma=no&InvoiceUid="+invoiceUid+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value+"&PrintModel="+EditForm.PrintModel.value;
	            window.open(url,"PatientInvoicePdf<%=new java.util.Date().getTime()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
	        }
	    }
	
	    function doPrintProformaPdf(invoiceUid){
  	        var url = "<c:url value='/financial/createPatientInvoicePdf.jsp'/>?Proforma=yes&InvoiceUid="+invoiceUid+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value+"&PrintModel="+EditForm.PrintModel.value;
	        window.open(url,"PatientInvoicePdf<%=new java.util.Date().getTime()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
	    }
		
	    function doPrintPatientReceiptPdf(invoiceUid){
	        if (("<%=sClosed%>"!="closed")&&("<%=sClosed%>"!="canceled")){
	            alert("<%=getTranNoLink("web","closetheinvoicefirst",sWebLanguage)%>");
	        }
	        else {
	            var url = "<c:url value='/financial/createPatientInvoiceReceiptPdf.jsp'/>?InvoiceUid="+invoiceUid+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value;
	            window.open(url,"PatientInvoicePdf<%=new java.util.Date().getTime()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
            }
	    }
		
	  function doModifyInvoice(invoiceuid){
	    var params = '';
	    var today = new Date();
	    var url= '<c:url value="/financial/recreateInvoice.jsp"/>?invoiceuid='+invoiceuid+'&ts='+today;
	    document.getElementById('patientInvoiceDebets').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
	    new Ajax.Request(url,{
		  method: "GET",
	      parameters: params,
	      onSuccess: function(resp){
	       	var label = eval('('+resp.responseText+')');
	       	if(label.invoiceuid.length>0){
	          setPatientInvoice(label.invoiceuid);
	        };
	      },
		  onFailure: function(request, status, error){
			alert(request.responseText);
	      }
	    });
	  }
	    
	  function setPatientInvoice(sUid){
	    FindForm.FindPatientInvoiceUID.value = sUid;
	    FindForm.submit();
	  }
	
	  function doPrintPatientReceipt(invoiceUid){
	    var params = '';
	    var today = new Date();
	    var url= '<c:url value="/financial/printPatientReceiptOffline.jsp"/>?invoiceuid='+invoiceUid+'&ts='+today+'&language=<%=sWebLanguage%>&userid=<%=activeUser.userid%>';
	    new Ajax.Request(url,{
		  method: "GET",
	      parameters: params,
	      onSuccess: function(resp){
	        var label = eval('('+resp.responseText+')');
	        if(label.message.length>0){
	          alert(label.message.unhtmlEntities());
	        };
	      },
		  onFailure: function(request, status, error){
		    alert(request.responseText);
	      }
	    });
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
	      }
	    });
	  }
	
	  function loadDebets(){
	    var params = '';
	    var today = new Date();
	    var url= '<c:url value="/financial/getPatientDebets.jsp"/>?PatientUID=<%=sPatientId%>&PatientInvoiceUID='+EditForm.EditPatientInvoiceUID.value+'&EditInvoiceService=' +EditForm.EditInvoiceService.value+'&Begin='+EditForm.EditBegin.value+'&End='+EditForm.EditEnd.value+'&ts='+today;
	    document.getElementById('patientInvoiceDebets').innerHTML = "<img src='<c:url value="/_img/ajax-loader.gif"/>'/><br/>Loading";
	    new Ajax.Request(url,{
		  method: "GET",
	      parameters: params,
	      onSuccess: function(resp){
	        $('patientInvoiceDebets').innerHTML=resp.responseText;
	        doBalance();
	      }
	    });
	  }
	
	  function doStatus(){
	  }
	    
	  function activateReductions(){
	    var elements = document.getElementsByName("reduction");
		if(elements[0].type=='radio'){
		  elements[0].checked=true;
		}
	  }
	    
	  function removeReductions(){
	  	table = document.getElementById('creditsTable');
        var rowCount = table.rows.length;
            
        for(var i=1; i<rowCount; i++){
          var row = table.rows[i];
          var chkbox = row.cells[0].childNodes[0];
          if(null!=chkbox && chkbox.id.indexOf('reduction')==0){
            table.deleteRow(i);
            rowCount--;
            i--;
          }
        }
		activateReductions();
	  }
	    
	  function removeReductions2(){
	    var elements = document.getElementsByTagName("input");
	    for(var n=0;n<elements.length;n++){
	      if(elements[n].name.indexOf("cbPatientInvoice")==0 && elements[n].checked && elements[n].id.indexOf("reduction")==0){
	    	elements[n].checked=false;
	    	doBalance(elements[n],false);
		  }
	  	}
	  }
	
	  function searchService(serviceUidField,serviceNameField){
	    openPopup("/_common/search/searchService.jsp&ts=<%=getTs()%>&VarCode="+serviceUidField+"&VarText="+serviceNameField);
	    document.getElementById(serviceNameField).focus();
	  }
	  
	  function doPayment(invoiceUid){
	    openPopup("/financial/patientCreditEdit.jsp&ts=<%=getTs()%>&EditCreditInvoiceUid="+invoiceUid+"&ScreenType=doPayment&EditBalance="+document.getElementById('EditBalance').value);
	  }
	
	  function doInvoiceCancel(invoiceUid){
          if(yesnoDeleteDialog()){
	      if(document.getElementById('invoiceStatus').selectedIndex){
	       	document.getElementById("invoiceStatus").options[document.getElementById("invoiceStatus").selectedIndex].value='canceled';
	      }
	      else{
	       	document.getElementById('invoiceStatus').value='canceled';
	      }
	      doSave();
	    }
	  }

	  FindForm.FindPatientInvoiceUID.focus();
	  loadDebets();
	  loadOpenPatientInvoices();
	  doBalance();
	  document.getElementById('EditBalance').value = formatNumber(document.getElementById('EditBalance').value,<%=MedwanQuery.getInstance().getConfigInt("currencyDecimals",2)%>);
	  
	  <%
	  	if(automaticPayment){
	  %>
	  	doPayment('<%=sFindPatientInvoiceUID%>');
	  <%
	  	}
	  %>
	</script>
<%
	}

%>
