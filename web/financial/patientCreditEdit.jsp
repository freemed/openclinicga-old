<%@page import="be.openclinic.adt.Encounter,
                be.openclinic.finance.PatientCredit,
                java.util.Vector,java.text.*,
                be.openclinic.finance.Wicket,
                be.openclinic.finance.WicketCredit"%>
<%@ page import="be.openclinic.finance.PatientInvoice" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("financial.patientCreditEdit","edit",activeUser)%>
<%=sJSSTRINGFUNCTIONS%>
<%=sJSPROTOTYPE%>
<%
    PatientCredit credit=null;
    String sAction = checkString(request.getParameter("Action"));
    String sScreenType = checkString(request.getParameter("ScreenType"));

    String sFindDateBegin        = checkString(request.getParameter("FindDateBegin")),
           sFindDateEnd          = checkString(request.getParameter("FindDateEnd")),
           sFindAmountMin        = checkString(request.getParameter("FindAmountMin")),
           sFindAmountMax        = checkString(request.getParameter("FindAmountMax"));

    String sEditCreditUid        = checkString(request.getParameter("EditCreditUid")),
           sEditCreditDate       = checkString(request.getParameter("EditCreditDate")),
           sEditCreditInvoiceUid = checkString(request.getParameter("EditCreditInvoiceUid")),
           sEditCreditInvoiceNr  = checkString(request.getParameter("EditCreditInvoiceNr")),
           sEditCreditAmount     = checkString(request.getParameter("EditCreditAmount")),
           sEditCreditType       = checkString(request.getParameter("EditCreditType")),
           sEditCreditEncUid     = checkString(request.getParameter("EditCreditEncounterUid")),
           sEditCreditDescr      = checkString(request.getParameter("EditCreditDescription")),
       	   sEditBalance      = checkString(request.getParameter("EditBalance")),
           sEditCreditWicketUid  = checkString(request.getParameter("EditCreditWicketUid"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        System.out.println("\n################## patientCreditEdit : "+sAction+" ###############");
        System.out.println("* sEditCreditUid        : "+sEditCreditUid);
        System.out.println("* sEditCreditDate       : "+sEditCreditDate);
        System.out.println("* sEditCreditInvoiceUid : "+sEditCreditInvoiceUid);
        System.out.println("* sEditCreditInvoiceNr  : "+sEditCreditInvoiceNr);
        System.out.println("* sEditCreditAmount     : "+sEditCreditAmount);
        System.out.println("* sEditCreditType       : "+sEditCreditType);
        System.out.println("* sEditCreditEncUid     : "+sEditCreditEncUid);
        System.out.println("* sEditCreditDescr      : "+sEditCreditDescr);
        System.out.println("* sEditCreditWicketUid  : "+sEditCreditWicketUid+"\n");
    }
    ///////////////////////////// </DEBUG> ////////////////////////////////////////////////////////
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
                wicketCredit = WicketCredit.getByReferenceUid(sEditCreditUid);
            }

            // create wicket credit if not found or not specified
            if(wicketCredit==null || wicketCredit.getUid()==null || wicketCredit.getUid().length()==0){
                wicketCredit = new WicketCredit();

                wicketCredit.setWicketUID(sEditCreditWicketUid);
                session.setAttribute("defaultwicket",sEditCreditWicketUid);
                wicketCredit.setCreateDateTime(ScreenHelper.getSQLDate(sEditCreditDate));
                wicketCredit.setUserUID(Integer.parseInt(activeUser.userid));
            }

            wicketCredit.setOperationDate(new Timestamp(new SimpleDateFormat("dd/MM/yyyy").parse(sEditCreditDate).getTime()));
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

        if (sScreenType.length()>0){
            %>
            <script type="text/javascript">
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
        sEditCreditDate       = checkString(new SimpleDateFormat("dd/MM/yyyy").format(credit.getDate()));
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
    else if ((!sScreenType.equals(""))&&(sEditCreditInvoiceUid.length()>0)){
        PatientInvoice patientInvoice = PatientInvoice.get(sEditCreditInvoiceUid);
        if(sEditCreditAmount.length()==0 && sEditBalance.length()>0){
        	sEditCreditAmount=sEditBalance;
        }
        sEditCreditInvoiceNr = patientInvoice.getInvoiceUid();
        sEditCreditDate = checkString(new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date()));


        if (sScreenType.equalsIgnoreCase("doCancellation")){
            sEditCreditType = "correction";
            sEditCreditDescr = getTran("web","canceled",sWebLanguage);
        }
        else {
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
            sBegin = ", "+getSQLTimeStamp(new Timestamp(encounter.getBegin().getTime()));
        }

        String sEnd = "";
        if(encounter.getEnd()!=null){
            sEnd = ", "+getSQLTimeStamp(new Timestamp(encounter.getEnd().getTime()));
        }

        sEditCreditEncName = sEditCreditEncUid+sBegin+sEnd+sType;
    }
%>
<form name="EditForm" id="EditForm" method="POST" onClick="checkForMaxAmount(EditForm.EditCreditAmount);">
<%
    if (sScreenType.equals("")){
%>
    <%ScreenHelper.setIncludePage(customerInclude("financial/financialStatusPatient.jsp"),pageContext);%>
    <table class="menu" width="100%" cellspacing="0">
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web.occup","medwan.common.date",sWebLanguage)%></td>
            <td width="100"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td width="150"><%=writeDateField("FindDateBegin","EditForm",sFindDateBegin,sWebLanguage)%></td>
            <td width="100"><%=getTran("Web","end",sWebLanguage)%></td>
            <td><%=writeDateField("FindDateEnd","EditForm",sFindDateEnd,sWebLanguage)%></td>
        </tr>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("web","amount",sWebLanguage)%></td>
            <td><%=getTran("Web","min",sWebLanguage)%></td>
            <td><input type="text" class="text" name="FindAmountMin" id="FindAmountMin" value="<%=sFindAmountMin%>" onblur="isNumber(this)"></td>
            <td><%=getTran("Web","max",sWebLanguage)%></td>
            <td><input type="text" class="text" name="FindAmountMax" id="FindAmountMax" value="<%=sFindAmountMax%>" onblur="isNumber(this)"></td>
        </tr>
        <tr>
            <td/>
            <td colspan="4">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","search",sWebLanguage)%>" onclick="loadUnassignedCredits()">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFindFields()">&nbsp;
                <input class="button" type="button" name="buttonNew" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="clearEditFields();">
            </td>
        </tr>
    </table>
    <br>

    <div id="divCredits" class="searchResults" style="height:122px">
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
    <table class="list"width="100%" cellspacing="1">
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
                <img src="<c:url value='/_img/icon_search.gif'/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchInvoice('EditCreditInvoiceUid','EditCreditInvoiceNr','EditCreditAmount','EditCreditMaxAmount');">
                <img src="<c:url value='/_img/icon_delete.gif'/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditCreditInvoiceUid.value='';EditForm.EditCreditInvoiceNr.value='';EditForm.EditCreditMaxAmount.value='';">
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
                    <option/>
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
                <img src="<c:url value="/_img/icon_search.gif"/>" class="link" alt="<%=getTranNoLink("Web","select",sWebLanguage)%>" onclick="searchEncounter('EditCreditEncounterUid','EditCreditEncounterName');">
                <img src="<c:url value="/_img/icon_delete.gif"/>" class="link" alt="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="EditForm.EditCreditEncounterUid.value='';EditForm.EditCreditEncounterName.value='';">
            </td>
        </tr>
        <tr>
            <td class="admin"><%=getTran("web","description",sWebLanguage)%></td>
            <td class="admin2"><%=writeTextarea("EditCreditDescription","","","",sEditCreditDescr)%></td>
        </tr>
        <%
            Vector userWickets = Wicket.getWicketsForUser(activeUser.userid);
            if((userWickets.size() > 0)&&(!sScreenType.equalsIgnoreCase("doCancellation"))){
                %>
                    <tr>
                        <td class="admin"><%=getTran("wicket","wicket",sWebLanguage)%>&nbsp;*</td>
                        <td class="admin2">
                            <select class="text" id="EditCreditWicketUid" name="EditCreditWicketUid">
                                <option value=""><%=getTran("web","choose",sWebLanguage)%></option>
                                <%
                                    Iterator iter = userWickets.iterator();
                                    Wicket wicket;

                                    while(iter.hasNext()){
                                        wicket = (Wicket) iter.next();

                                        %>
                                          <option value="<%=wicket.getUid()%>" <%=sEditCreditWicketUid.equals(wicket.getUid())?" selected":""%>>
                                              <%=wicket.getUid()%>&nbsp;<%=getTran("service",wicket.getServiceUID(),sWebLanguage)%>
                                          </option>
                                        <%
                                    }
                                %>
                            </select>
                        </td>
                    </tr>
                <%
            }
            else {
            %>
            <input type="hidden" name="EditCreditWicketUid">
            <%
            }
        %>
        <tr>
            <td class="admin"/>
            <td class="admin2">
                <input class="button" type="button" name="buttonSave" value="<%=getTranNoLink("Web","save",sWebLanguage)%>" onclick="doSave();">&nbsp;
                <div id="printsection" name="printsection" style="visibility: hidden">
                    <%=getTran("Web.Occup","PrintLanguage",sWebLanguage)%>

                    <%
                        String sPrintLanguage = activeUser.person.language;

                        if (sPrintLanguage.length()==0){
                            sPrintLanguage = sWebLanguage;
                        }

                        String sSupportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages","en,fr");
                    %>

                    <select class="text" name="PrintLanguage" id="PrintLanguage">
                        <%
                            String tmpLang;
                            StringTokenizer tokenizer = new StringTokenizer(sSupportedLanguages, ",");
                            while (tokenizer.hasMoreTokens()) {
                                tmpLang = tokenizer.nextToken();

                                %><option value="<%=tmpLang%>"<%if (tmpLang.equalsIgnoreCase(sPrintLanguage)){out.print(" selected");}%>><%=getTran("Web.language",tmpLang,sWebLanguage)%></option><%
                            }
                        %>
                    </select>

                    <input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print",sWebLanguage)%>' onclick="doPrintPdf(document.getElementById('EditCreditUid').value);">
                    <%
                    	if(MedwanQuery.getInstance().getConfigInt("javaPOSenabled",0)==1){
                    %>
                    <input class="button" type="button" name="buttonPrint" value='<%=getTranNoLink("Web","print.receipt",sWebLanguage)%>' onclick="doPrintPatientPaymentReceipt();">
                    <%
                    	}
                    %>
                    
                </div>
            </td>
        </tr>
    </table>
    <%=getTran("web","asterisk_fields_are_obligate",sWebLanguage)%>
    <%-- display message --%>
    <br><br><span id="msgArea">&nbsp;<%=msg%></span>
</form>
<script>

  function clearMessage(){
    <%
        if(msg.length() > 0){
            %>document.getElementById("msgArea").innerHTML = "";<%
        }
    %>
  }

  function doPrintPatientPaymentReceipt(){
      var params = '';
      var today = new Date();
      var url= '<c:url value="/financial/printPaymentReceipt.jsp"/>?credituid='+document.getElementById('EditCreditUid').value+'&ts='+today;
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
					alert("Error printing receipt");
              }
          }
		);
  }
  
  function checkForMaxAmount(amountField){
    if(EditForm.EditCreditMaxAmount.value.length > 0){
      if(EditForm.EditCreditAmount.value > EditForm.EditCreditMaxAmount.value){
        amountField.value = EditForm.EditCreditMaxAmount.value;

        var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.financial&labelID=creditAmountLimitedToInvoiceAmount";
        var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
        (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm('<%=getTranNoLink("web.financial","creditAmountLimitedToInvoiceAmount",sWebLanguage)%>');

      }
    }
  }

  function doSave(){
    if(EditForm.EditCreditDate.value.length > 0 &&
       EditForm.EditCreditAmount.value.length > 0 &&
       EditForm.EditCreditEncounterUid.value.length > 0 &&
       EditForm.EditCreditType.value.length > 0){
      <%
          if ((userWickets.size() > 0)){
              %>
                if(document.getElementById("EditCreditWicketUid").selectedIndex==0){
                  var popupUrl = "<c:url value="/popup.jsp"/>?Page=_common/search/okPopup.jsp&ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
                  var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
                  (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm('<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>');


                  EditForm.EditCreditWicketUid.focus();
                }else {
                    EditForm.buttonSave.disabled = true;
                    EditForm.Action.value = "save";
                    EditForm.submit();
                }
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
 //       EditForm.EditCreditWicketUid.focus();
      }

      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=web.manage&labelID=datamissing";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
       (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm('<%=getTranNoLink("web.manage","datamissing",sWebLanguage)%>');
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
if (sScreenType.equals("")){
%>
      if (document.getElementById("EditCreditEncounterUid").value.length==0){
      var popupUrl = "<%=sCONTEXTPATH%>/_common/search/okPopup.jsp?ts=<%=getTs()%>&labelType=medical&labelID=no_encounter";
      var modalities = "dialogWidth:266px;dialogHeight:163px;center:yes;scrollbars:no;resizable:no;status:no;location:no;";
      (window.showModalDialog)?window.showModalDialog(popupUrl,"",modalities):window.confirm('<%=getTranNoLink("medical","no_encounter",sWebLanguage)%>');
    }
    else{
        $('divCredits').innerHTML="<br><br><br><div id='ajaxLoader' style='display:block;text-align:center;'><img src='<c:url value='/_img/ajax-loader.gif'/>'/><br>Loading..</div>";
        var params = 'FindDateBegin=' + EditForm.FindDateBegin.value
              +"&FindDateEnd="+document.getElementById('FindDateEnd').value
              +"&FindAmountMin="+document.getElementById('FindAmountMin').value
              +"&FindAmountMax="+document.getElementById('FindAmountMax').value
              +"&encounterUID="+document.getElementById("EditCreditEncounterUid").value;
        var today = new Date();
        var url= "<c:url value="/financial/getEncounterCredits.jsp"/>?ts="+today;
        new Ajax.Request(url,
          {
            method: "GET",
            parameters: params,
            onSuccess: function(resp){
              $("divCredits").innerHTML = resp.responseText;
            },
            onFailure: function(){
                $('divCredits').innerHTML="Error";
            }
          }
        );
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
    EditForm.EditCreditDescription.value = descr;
    EditForm.EditCreditInvoiceUid.value = invoiceUid;

    if (invoiceUid.indexOf(".")>-1){
        EditForm.EditCreditInvoiceNr.value = invoiceUid.split(".")[1];
    }
    else {
        EditForm.EditCreditInvoiceNr.value = "";
    }
    document.getElementById('creditid').innerHTML=document.getElementById('EditCreditUid').value.split(".")[1];
    document.getElementById('printsection').style.visibility='visible';
      document.getElementById('PrintLanguage').show();
  }

  function clearEditFields(){
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
    document.getElementById('PrintLanguage').hide();
    document.getElementById('creditid').innerHTML="";

    <%
        if(userWickets.size() > 0){
            %>EditForm.EditCreditWicketUid.value = "<%=activeUser.getParameter("defaultwicket")%>";<%
        }
    %>
  }

  function doPrintPdf(creditUid){
    var url = "<c:url value='/financial/createPaymentReceiptPdf.jsp'/>?CreditUid="+creditUid+"&ts=<%=getTs()%>&PrintLanguage="+EditForm.PrintLanguage.value;
    window.open(url,"PaymentReceiptPdf<%=new java.util.Date().getTime()%>","height=600,width=900,toolbar=yes,status=no,scrollbars=yes,resizable=yes,menubar=yes");
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
  if(document.getElementById('EditCreditUid').value.length>0){
      document.getElementById('creditid').innerHTML=document.getElementById('EditCreditUid').value.split(".")[1];
      document.getElementById('printsection').style.visibility='visible';
      document.getElementById('PrintLanguage').show();
  }
<%
if (sScreenType.equals("")){
%>
  loadUnassignedCredits();
<%
}
%>

</script>