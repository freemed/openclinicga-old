<%@page import="be.openclinic.adt.Encounter,
                be.openclinic.finance.PatientCredit,
                java.util.Vector,java.text.*,
                be.openclinic.finance.Wicket,
                be.openclinic.finance.WicketCredit,
                be.openclinic.finance.PatientInvoice,
                be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.patientCreditEdit","select",activeUser)%>
<%=sJSSTRINGFUNCTIONS%>
<%=sJSPROTOTYPE%>

<%
	String sFindPatientCreditUID = checkString(request.getParameter("FindPatientCreditUID"));
	PatientCredit credit = null;
	String sPatientId = "";
	
	if(sFindPatientCreditUID.length() > 0){
	    credit = PatientCredit.get(MedwanQuery.getInstance().getConfigString("serverId")+"."+sFindPatientCreditUID);
	    if(credit!=null && credit.getDate()!=null){
	        sPatientId = credit.getEncounter().getPatientUID();
	        if(request.getParameter("LoadPatientId")!=null && (activePatient==null || !sPatientId.equalsIgnoreCase(activePatient.personid))){
	        	if(activePatient==null){
	        		activePatient=new AdminPerson();
	        		session.setAttribute("activePatient",activePatient);
	        	}
	        	activePatient.initialize(sPatientId);
	        }
	    	%>
	    	<script>
	    	  url = '<c:url value="/main.do"/>?Page=financial/patientCreditEdit.jsp&ts=<%=ScreenHelper.getTs()%>&EditCreditUid=<%=credit.getUid()%>';
	    	  window.location.href = url;
	    	</script>
	    	<%
	    	out.flush();
	    }
	    else{
	    	out.print(getTran("web","credit.does.not.exist",sWebLanguage)+": "+sFindPatientCreditUID);
	    }	
	} 

    String sAction = checkString(request.getParameter("Action"));
    String sScreenType = checkString(request.getParameter("ScreenType"));

    String sFindDateBegin = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd   = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax = checkString(request.getParameter("FindAmountMax"));

    String sEditCreditUid        = checkString(request.getParameter("EditCreditUid")),
           sEditCreditDate       = checkString(request.getParameter("EditCreditDate")),
           sEditCreditInvoiceUid = checkString(request.getParameter("EditCreditInvoiceUid")),
           sEditCreditInvoiceNr  = checkString(request.getParameter("EditCreditInvoiceNr")),
           sEditCreditAmount     = checkString(request.getParameter("EditCreditAmount")),
           sEditCreditType       = checkString(request.getParameter("EditCreditType")),
           sEditCreditEncUid     = checkString(request.getParameter("EditCreditEncounterUid")),
           sEditCreditDescr      = checkString(request.getParameter("EditCreditDescription")),
       	   sEditBalance          = checkString(request.getParameter("EditBalance")),
           sEditCreditWicketUid  = checkString(request.getParameter("EditCreditWicketUid"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** financial/patientCreditEdit.jsp ******************");
        Debug.println("sAction               : "+sAction);
        Debug.println("sEditCreditUid        : "+sEditCreditUid);
        Debug.println("sEditCreditDate       : "+sEditCreditDate);
        Debug.println("sEditCreditInvoiceUid : "+sEditCreditInvoiceUid);
        Debug.println("sEditCreditInvoiceNr  : "+sEditCreditInvoiceNr);
        Debug.println("sEditCreditAmount     : "+sEditCreditAmount);
        Debug.println("sEditCreditType       : "+sEditCreditType);
        Debug.println("sEditCreditEncUid     : "+sEditCreditEncUid);
        Debug.println("sEditCreditDescr      : "+sEditCreditDescr);
        Debug.println("sEditCreditWicketUid  : "+sEditCreditWicketUid+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    AdminPerson adminPerson = activePatient;
    if(ScreenHelper.checkString(sEditCreditInvoiceUid).length()>0){
        PatientInvoice invoice = PatientInvoice.get(sEditCreditInvoiceUid);
        adminPerson=invoice.getPatient();
    }
    if(adminPerson==null){
    	adminPerson=activePatient;
    }
    String sEditCreditEncName = "", msg = "";

    // set default wicket if no wicket specified
    if(sEditCreditWicketUid.length()==0){
        sEditCreditWicketUid = activeUser.getParameter("defaultwicket");
    }
    if(sEditCreditWicketUid.length()==0){
        sEditCreditWicketUid = checkString((String)session.getAttribute("defaultwicket"));
    }
    
    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        // get or create credit
        if(sEditCreditUid.length() > 0){
            credit = PatientCredit.get(sEditCreditUid);
        }
        else{
            credit = new PatientCredit();
            credit.setCreateDateTime(ScreenHelper.getSQLDate(getDate()));
        }

        // set and store credit
        credit.setDate(ScreenHelper.getSQLDate(sEditCreditDate));
        credit.setInvoiceUid(sEditCreditInvoiceUid);
        credit.setAmount(Double.parseDouble(sEditCreditAmount));
        credit.setType(sEditCreditType);
        credit.setEncounter(Encounter.get(sEditCreditEncUid));
        credit.setEncounterUid(sEditCreditEncUid);
        credit.setComment(sEditCreditDescr);
        credit.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
        credit.setUpdateUser(activeUser.userid);
        credit.setPatientUid(MedwanQuery.getInstance().getConfigString("serverId")+"."+adminPerson.personid);
        credit.store();

        msg = getTran("web","dataIsSaved",sWebLanguage);

        //*** update wicket credit ********************************************
        if(sEditCreditWicketUid.length() > 0){
            // get wicket credit belonging to this patientCredit, if any specified
            WicketCredit wicketCredit = null;
            if(sEditCreditUid.length() > 0){
                wicketCredit = WicketCredit.getByReferenceUid(sEditCreditUid,"PatientCredit");
            }

            // create wicket credit if not found or not specified
            if(wicketCredit==null || wicketCredit.getUid()==null || wicketCredit.getUid().length()==0){
                wicketCredit = new WicketCredit();

                wicketCredit.setWicketUID(sEditCreditWicketUid);
                session.setAttribute("defaultwicket",sEditCreditWicketUid);
                wicketCredit.setCreateDateTime(ScreenHelper.getSQLDate(sEditCreditDate));
                wicketCredit.setUserUID(Integer.parseInt(activeUser.userid));
            }

            wicketCredit.setOperationDate(new Timestamp(ScreenHelper.parseDate(sEditCreditDate).getTime()));
            wicketCredit.setOperationType(sEditCreditType);
            wicketCredit.setAmount(Double.parseDouble(sEditCreditAmount));

            // set patient name as default comment
            if(wicketCredit.getComment()==null || (wicketCredit.getComment()!=null && wicketCredit.getComment().toString().length()==0)){
                wicketCredit.setComment(adminPerson.lastname+" "+adminPerson.firstname+" - "+sEditCreditInvoiceUid.replaceAll("1\\.",""));
            }

            wicketCredit.setInvoiceUID(sEditCreditInvoiceUid);

            // reference to patientCredit
            ObjectReference objRef = new ObjectReference();
            objRef.setObjectType("PatientCredit");
            objRef.setObjectUid(credit.getUid());
            wicketCredit.setReferenceObject(objRef);

            wicketCredit.setUpdateDateTime(getSQLTime());
            wicketCredit.setUpdateUser(activeUser.userid);

            wicketCredit.store();

            // recalculate wicket balance
            Wicket wicket = Wicket.get(sEditCreditWicketUid);
            wicket.recalculateBalance();
        }

        //sEditCreditUid = ""; // do not load the just saved credit

        if(sScreenType.length() > 0){
            %>
            <script>
              window.opener.doFind();
              window.close();
            </script>
            <%
        }
    }

    //--- LOAD SPECIFIED CREDIT -------------------------------------------------------------------
    Encounter encounter;

    if(sEditCreditUid.length() > 0){
        credit = PatientCredit.get(sEditCreditUid);

        sEditCreditUid        = credit.getUid();
        sEditCreditDate       = checkString(ScreenHelper.stdDateFormat.format(credit.getDate()));
        sEditCreditInvoiceUid = credit.getInvoiceUid();
        sEditCreditInvoiceNr  = sEditCreditInvoiceUid.substring(sEditCreditInvoiceUid.indexOf(".")+1);
        sEditCreditAmount     = Double.toString(credit.getAmount());
        sEditCreditDescr      = credit.getComment();
        sEditCreditType       = credit.getType();

        // encounter
        encounter = credit.getEncounter();
        if(encounter!=null){
            sEditCreditEncUid  = encounter.getUid();
            sEditCreditEncName = encounter.getPatient().lastname+" "+encounter.getPatient().firstname;
        }
    }
    else if(!sScreenType.equals("") && sEditCreditInvoiceUid.length()>0){
        PatientInvoice patientInvoice = PatientInvoice.get(sEditCreditInvoiceUid);
        if(sEditCreditAmount.length()==0 && sEditBalance.length()>0){
        	sEditCreditAmount = sEditBalance;
        }
        sEditCreditInvoiceNr = patientInvoice.getInvoiceUid();
        sEditCreditDate = checkString(ScreenHelper.stdDateFormat.format(new java.util.Date()));

        if(sScreenType.equalsIgnoreCase("doCancellation")){
            sEditCreditType = "correction";
            sEditCreditDescr = getTran("web","canceled",sWebLanguage);
        }
        else{
            sEditCreditType = "patient.payment";
        }

        encounter = Encounter.getActiveEncounter(adminPerson.personid);
        if(encounter==null){
            encounter = new Encounter();
        }
    }
    else{
        // new credit
        sEditCreditUid        = "";
        sEditCreditDate       = getDate(); // now
        sEditCreditInvoiceUid = "";
        sEditCreditInvoiceNr  = "";
        sEditCreditAmount     = "";
        sEditCreditEncUid     = "";
        sEditCreditEncName    = "";
        sEditCreditType       = MedwanQuery.getInstance().getConfigString("defaultPatientCreditType","patient.payment");
        sEditCreditDescr      = "";

        // active encounter as default
        encounter = Encounter.getActiveEncounter(adminPerson.personid);
        if(encounter==null){
            encounter = new Encounter();
        }
    }

    // compose encounter name
    if(encounter!=null){
        sEditCreditEncUid = checkString(encounter.getUid());

        String sType = "";
        if(checkString(encounter.getType()).length()>0){
            sType = ", "+getTran("encountertype",encounter.getType(),sWebLanguage);
        }

        String sBegin = "";
        if(encounter.getBegin()!=null){
            sBegin = ", "+ScreenHelper.getSQLDate(encounter.getBegin());
        }

        String sEnd = "";
        if(encounter.getEnd()!=null){
            sEnd = ", "+ScreenHelper.getSQLDate(encounter.getEnd());
        }

        sEditCreditEncName = sEditCreditEncUid+sBegin+sEnd+sType;
    }
%>
<form name="EditForm" id="EditForm" method="POST" onClick="checkForMaxAmount(EditForm.EditCreditAmount);">
<%
    if(sScreenType.length()==0){
%>
    <%ScreenHelper.setIncludePage(customerInclude("financial/financialStatusPatient.jsp"),pageContext);%>
    <table class="list" width="100%" cellspacing="1" cellpadding="0">
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.occup","medwan.common.date",sWebLanguage)%></td>
            <td class="admin2" width="80"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td class="admin2" width="150"><%=writeDateField("FindDateBegin","EditForm",sFindDateBegin,sWebLanguage)%></td>
            <td class="admin2" width="80"><%=getTran("Web","end",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindDateEnd","EditForm",sFindDateEnd,sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","amount",sWebLanguage)%></td>
            <td class="admin2"><%=getTran("Web","min",sWebLanguage)%></td>
            <td class="admin2"><input type="text" class="text" name="FindAmountMin" id="FindAmountMin" value="<%=sFindAmountMin%>" onblur="isNumber(this)"></td>
            <td class="admin2"><%=getTran("Web","max",sWebLanguage)%></td>
            <td class="admin2"><input type="text" class="text" name="FindAmountMax" id="FindAmountMax" value="<%=sFindAmountMax%>" onblur="isNumber(this)"></td>
        </tr>
        <tr>
            <td class="admin"/>
            <td class="admin2" colspan="4">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="loadUnassignedCredits()">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFindFields()">&nbsp;
                <input class="button" type="button" name="buttonNew" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="clearEditFields();">
            </td>
        </tr>
    </table>
    <br>

    <div id="divCredits" class="searchResults" style="height:122px;width:100%">
       <%-- Filled by Ajax --%>
    </div>
    <br>
<%
    }
%>
    <%-- hidden fields --%>
    <input type="hidden" name="Action">
    <input type="hidden" name="EditCreditUid" id="EditCreditUid" value="<%=sEditCreditUid%>"/>
    <input type="hidden" name="ScreenType" value="<%=sScreenType%>">
    
    <%=writeTableHeader("financial","patientCreditEdit",sWebLanguage," doBack();")%>
    <table class="list" width="100%" cellspacing="1" cellpadding="0">
	    <tr>
	        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","creditid",sWebLanguage)%></td>
	        <td class="admin2"><div id="creditid"></div></td>
	    </tr>
	    <tr>
	        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web","date",sWebLanguage)%>&nbsp;*</td>
	        <td class="admin2"><%=writeDateField("EditCreditDate","EditForm",sEditCreditDate,sWebLanguage)%></td>
	    </tr>
        <tr>
            <td class="admin"><%=getTran("web","invoice",sWebLanguage)%>&nbsp;</td>
            <td class="admin2">
                <input type="hidden" name="EditCreditInvoiceUid" value="<%=sEditCreditInvoiceUid%>">
                <input class="text" type="text" name="EditCreditInvoiceNr" readonly size="10" value="<%=sEditCreditInvoiceNr%>">
                
                <%-- icons --%>
                <img src="<c:url value='/_img/icons/icon_search.gif'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInvoice('EditCreditInvoiceUid','EditCreditInvoiceNr','EditCreditAmount','EditCreditMaxAmount');">
                <img src="<c:url value='/_img/icons/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditCreditInvoiceUid.value='';EditForm.EditCreditInvoiceNr.value='';EditForm.EditCreditMaxAmount.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","amount",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input type="hidden" name="EditCreditMaxAmount">
                <input class="text" type="text" name="EditCreditAmount" value="<%=sEditCreditAmount%>" size="10" maxLength="9" onKeyUp="isNumberNegativeAllowed(this);" onBlur="checkForMaxAmount(this);">&nbsp;<%=MedwanQuery.getInstance().getConfigParam("currency","€")%>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","type",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <select class="text" name="EditCreditType">
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelectUnsorted("credit.type",sEditCreditType,sWebLanguage)%>
                </select>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","encounter",sWebLanguage)%>&nbsp;*</td>
            <td class="admin2">
                <input type="hidden" id="EditCreditEncounterUid" name="EditCreditEncounterUid" value="<%=sEditCreditEncUid%>">
                <input class="text" type="text" name="EditCreditEncounterName" readonly size="<%=sTextWidth%>" value="<%=sEditCreditEncName%>">

                <%-- icons --%>
                <img src="<c:url value="/_img/icons/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('EditCreditEncounterUid','EditCreditEncounterName');">
                <img src="<c:url value="/_img/icons/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditCreditEncounterUid.value='';EditForm.EditCreditEncounterName.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","description",sWebLanguage)%></td>
            <td class="admin2"><%=writeTextarea("EditCreditDescription","","","",sEditCreditDescr)%></td>
        </tr>
        
        <%
            Vector userWickets = Wicket.getWicketsForUser(activeUser.userid);
            if(userWickets.size() > 0 && !sScreenType.equalsIgnoreCase("doCancellation")){
                %>
                    <tr>
                        <td class="admin"><%=getTran("wicket","wicket",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <select class="text" id="EditCreditWicketUid" name="EditCreditWicketUid">
                                <option value="" selected><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                                <%
                                    Iterator iter = userWickets.iterator();
                                    Wicket wicket;

                                    while(iter.hasNext()){
                                        wicket = (Wicket)iter.next();

                                        %>
                                          <option value="<%=wicket.getUid()%>" <%=sAction.length()==0 && sEditCreditWicketUid.equals(wicket.getUid())?" selected":""%>>
                                              <%=wicket.getUid()%>&nbsp;<%=getTranNoLink("service",wicket.getServiceUID(),sWebLanguage)%>
                                          </option>
                                        <%
                                    }
                                %>
                            </select>
                        </td>
                    </tr>
                <%
            }
            else{
                %><input type="hidden" name="EditCreditWicketUid"/><%
            }
        %>
        
        <%-- BUTTONS & PRINT --%>
        <tr>
            <td class="admin"/>
            <td class="admin2">
            	<%
	            	if(userWickets.size() > 0){
	            	    %><input class="button" type="button" name="buttonSave" id="buttonSave" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;&nbsp;<%
	            	}
	            	else{
	            	    %><font color="red"><%=getTran("web","nowicketassignedtouser",sWebLanguage)%></font><%
            		}
                %>
                
                <span id="printsection" name="printsection" style="visibility:hidden">
                    <%=getTran("Web.Occup","PrintLanguage",sWebLanguage)%>&nbsp;

                    <%
                        String sPrintLanguage = activeUser.person.language;
                        if(sPrintLanguage.length()==0){
                            sPrintLanguage = sWebLanguage;
                        }

                        String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");
                    %>

                    <select class="text" name="PrintLanguage" id="PrintLanguage">
                        <%
                            String tmpLang;
                            StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages,",");
                            while(tokenizer.hasMoreTokens()){
                                tmpLang = tokenizer.nextToken();

                                %><option value="<%=tmpLang%>" <%=(tmpLang.equalsIgnoreCase(sPrintLanguage)?" selected":"")%>><%=getTranNoLink("Web.language",tmpLang,sWebLanguage)%></option><%
                            }
                        %>
                    </select>

                    <%-- BUTTONS --%>
                    <input class="button" type="button" name="buttonPrint" value="<%=getTranNoLink("Web","print",sWebLanguage)%>" onclick="doPrintPdf(document.getElementById('EditCreditUid').value);">
                    <%
                    	if(MedwanQuery.getInstance().getConfigInt("javaPOSenabled",0)==1){
                            %><input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print.receipt",sWebLanguage)%>' onclick="doPrintPatientPaymentReceipt();"><%
                    	}
	                	if(MedwanQuery.getInstance().getConfigInt("printPDFreceiptenabled",0)==1){
	                        %><input class="button" type="button" name="buttonPrintPdf" value='<%=getTranNoLink("Web","print.receipt.pdf",sWebLanguage)%>' onclick="doPrintPatientReceiptPdf();"><%
	                	}
                    %>                    
                </span>
            </td>
        </tr>
    </table>
    <%=getTran("web","asterisk_fields_are_obligate",sWebLanguage)%>
    
    <%-- display message --%>
    <br><br><span id="msgArea">&nbsp;<%=msg%></span>
</form>

<script>
  var dateFormat = "<%=ScreenHelper.stdDateFormat.toPattern()%>";
   
  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById("msgArea").innerHTML = "";<%
        }
    %>
  }

  function doPrintPatientPaymentReceipt(){
    var url= "<c:url value='/financial/printPaymentReceiptOffline.jsp'/>"+
             "?credituid="+document.getElementById("EditCreditUid").value+
             "&language=<%=sWebLanguage%>&userid=<%=activeUser.userid%>"+
             "&ts="+new Date();
    new Ajax.Request(url,{
	  method: "GET",
      parameters: "",
      onSuccess: function(resp){
        var label = eval('('+resp.responseText+')');
        if(label.message.length>0){
          alertDialogDirectText(label.message.unhtmlEntities());
        };
      },
      onFailure: function(){
        alert("Error printing receipt");
      }
    });
  }

  function doPrintPatientReceiptPdf(){
    var url = "<c:url value='/financial/createPatientPaymentReceiptPdf.jsp'/>?creditUid="+EditForm.EditCreditUid.value+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value;
    window.open(url,"PatientPaymentPdf<%=getTs()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
  }

  function checkForMaxAmount(amountField){
    if(EditForm.EditCreditMaxAmount.value.length > 0){
      if(EditForm.EditCreditAmount.value > EditForm.EditCreditMaxAmount.value){
        amountField.value = EditForm.EditCreditMaxAmount.value;
        alertDialog("web.financial","creditAmountLimitedToInvoiceAmount");        
      }
    }
  }

  function doSave(){
	document.getElementById("buttonSave").disabled = true;
	
    if(EditForm.EditCreditDate.value.length > 0 &&
       EditForm.EditCreditAmount.value.length > 0 &&
       EditForm.EditCreditEncounterUid.value.length > 0 &&
       EditForm.EditCreditType.value.length > 0){
      <%
          if(userWickets.size() > 0){
              %>
                if(document.getElementById("EditCreditWicketUid").selectedIndex==0){
                  alertDialog("web.manage","datamissing");
                  EditForm.EditCreditWicketUid.focus();
                  document.getElementById("buttonSave").disabled = false;
                }
                else{
                  EditForm.buttonSave.disabled = true;
                  EditForm.Action.value = "save";
                  EditForm.submit();
                }
        	<%
          }
          else{
        	  %>
                EditForm.buttonSave.disabled = true;
                EditForm.Action.value = "save";
                EditForm.submit();
        	  <%
          }
        %>
    }
    else{
      if(EditForm.EditCreditDate.value.length==0){
        EditForm.EditCreditDate.focus();
      }
      else if(EditForm.EditCreditAmount.value.length==0){
        EditForm.EditCreditAmount.focus();
      }
      else if(EditForm.EditCreditEncounterUid.value.length==0){
        EditForm.EditCreditEncounterName.focus();
      }
      else if(EditForm.EditCreditType.value.length==0){
        EditForm.EditCreditType.focus();
      }
      else if(EditForm.EditCreditWicketUid.value.length==0){
        //EditForm.EditCreditWicketUid.focus();
      }

      alertDialog("web.manage","datamissing");
	  document.getElementById("buttonSave").disabled = false;
    }
  }

  function searchInvoice(invoiceUidField,invoiceNrField,invoiceBalanceField,invoiceMaxBalanceField){
    var url = "/_common/search/searchPatientInvoice.jsp&ts=<%=getTs()%>"+
              "&ReturnFieldInvoiceUid="+invoiceUidField+
              "&ReturnFieldInvoiceNr="+invoiceNrField+
              //"&FindInvoiceBalanceMin=0.01"+
              "&FindInvoiceStatus=<%=MedwanQuery.getInstance().getConfigString("defaultInvoiceStatus","open")%>"+
              "&FindInvoicePatient=<%=adminPerson.personid%>"+
              "&Action=search";

    if(invoiceBalanceField!=undefined){
      url+= "&ReturnFieldInvoiceBalance="+invoiceBalanceField;
    }

    if(invoiceMaxBalanceField!=undefined){
      url+= "&ReturnFieldInvoiceMaxBalance="+invoiceMaxBalanceField;
    }

    openPopup(url);
  }

  function searchEncounter(encounterUidField,encounterNameField){
    openPopup("/_common/search/searchEncounter.jsp&ts=<%=getTs()%>"+
              "&VarCode="+encounterUidField+
              "&VarText="+encounterNameField+
              "&VarFunction=loadUnassignedCredits()"+
              "&FindEncounterPatient=<%=adminPerson.personid%>");
  }

  function loadUnassignedCredits(){
	<%
	    if(sScreenType.length()==0){
	%>
	    if(document.getElementById("EditCreditEncounterUid").value.length==0){
	      alertDialog("medical","no_encounter");
	    }
	    else{
	      $("divCredits").innerHTML = "<br><br><br><div id='ajaxLoader' style='display:block;text-align:center;'>"+
	                                  "<img src='<%=sCONTEXTPATH%>/_img/themes/<%=sUserTheme%>/ajax-loader.gif'/><br>Loading..</div>";
	      var params = "FindDateBegin="+ EditForm.FindDateBegin.value+
	                   "&FindDateEnd="+document.getElementById('FindDateEnd').value+
	                   "&FindAmountMin="+document.getElementById('FindAmountMin').value+
	                   "&FindAmountMax="+document.getElementById('FindAmountMax').value+
	                   "&encounterUID="+document.getElementById("EditCreditEncounterUid").value;
	      var url= "<c:url value='/financial/getEncounterCredits.jsp'/>?ts="+new Date();
	      new Ajax.Request(url,{
	        method: "GET",
	        parameters: params,
	        onSuccess: function(resp){
	          $("divCredits").innerHTML = resp.responseText;
	        },
	        onFailure: function(){
	          $("divCredits").innerHTML = "Error";
	        }
	      });
	    }
	<%
	    }
	%>
  }

  function selectCredit(creditUid,creditDate,amount,type,encUid,encName,descr, invoiceUid,wicketuid){
    EditForm.EditCreditWicketUid.value=wicketuid;
    EditForm.EditCreditUid.value = creditUid;
    EditForm.EditCreditDate.value = creditDate;
    EditForm.EditCreditAmount.value = amount;
    EditForm.EditCreditType.value = type;
    EditForm.EditCreditEncounterUid.value = encUid;
    EditForm.EditCreditEncounterName.value = encName;
    EditForm.EditCreditDescription.value = replaceAll(descr,"<br>","\r\n");
    EditForm.EditCreditInvoiceUid.value = invoiceUid;
    
    if(<%=(activeUser.getAccessRight("financial.patientcreditedit.edit")?"true":"false")%> && EditForm.EditCreditWicketUid.value==wicketuid){
      document.getElementById("buttonSave").style.visibility='visible';
      document.getElementById("EditCreditWicketUid").style.visibility='visible';
    }
    else if(document.getElementById("buttonSave")){
      document.getElementById("buttonSave").style.visibility='hidden';
      document.getElementById("EditCreditWicketUid").style.visibility='hidden';
    }

    if(invoiceUid.indexOf(".")>-1){
      EditForm.EditCreditInvoiceNr.value = invoiceUid.split(".")[1];
    }
    else{
      EditForm.EditCreditInvoiceNr.value = "";
    }
    
    document.getElementById('creditid').innerHTML=document.getElementById('EditCreditUid').value.split(".")[1];
    document.getElementById('printsection').style.visibility='visible';
    document.getElementById('PrintLanguage').style.visibility='visible';
  }

  function clearEditFields(){
	if(document.getElementById("buttonSave")){
	  document.getElementById("buttonSave").style.visibility='visible';
	}
    document.getElementById("EditCreditWicketUid").style.visibility='visible';
    
    EditForm.EditCreditUid.value = "";
    EditForm.EditCreditDate.value = "<%=getDate()%>";
    EditForm.EditCreditInvoiceUid.value = "";
    EditForm.EditCreditInvoiceNr.value = "";
    EditForm.EditCreditAmount.value = "";
    EditForm.EditCreditType.value = "<%=MedwanQuery.getInstance().getConfigString("defaultPatientCreditType","patient.payment")%>";

    <%
        // active encounter as default
        encounter = Encounter.getActiveEncounter(adminPerson.personid);
        if(encounter==null){
            encounter = new Encounter();
        }
    %>
    EditForm.EditCreditEncounterUid.value = "<%=encounter.getUid()%>";
    EditForm.EditCreditEncounterName.value = "<%=encounter.getEncounterDisplayName(sWebLanguage)%>";
    EditForm.EditCreditDescription.value = "";
    document.getElementById('printsection').style.visibility='hidden';
    document.getElementById('PrintLanguage').style.visibility='hidden';
    document.getElementById('creditid').innerHTML="";

    <%
        if(userWickets.size() > 0){
            %>EditForm.EditCreditWicketUid.value = "<%=activeUser.getParameter("defaultwicket")%>";<%
        }
    %>
  }

  function doPrintPdf(creditUid){
    var url = "<c:url value='/financial/createPaymentReceiptPdf.jsp'/>?CreditUid="+creditUid+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value;
    window.open(url,"PaymentReceiptPdf<%=getTs()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=financial/historyBalance.jsp&ts=<%=getTs()%>";
  }

  function clearFindFields(){
    EditForm.FindDateBegin.value = "";
    EditForm.FindDateEnd.value = "";
    EditForm.FindAmountMin.value = "";
    EditForm.FindAmountMax.value = "";
  }

  EditForm.EditCreditDate.focus();
  
  if(document.getElementById('EditCreditUid').value.length > 0){
    document.getElementById('creditid').innerHTML=document.getElementById('EditCreditUid').value.split(".")[1];
    document.getElementById('printsection').style.visibility = 'visible';
    document.getElementById('PrintLanguage').style.visibility = 'visible';
  }
  
<%
	if(sScreenType.equals("")){
	    %>loadUnassignedCredits();<%
	}
%>
</script>