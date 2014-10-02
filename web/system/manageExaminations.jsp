<%@page import="be.openclinic.system.Examination,
                java.util.Vector,
                java.util.Collections"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.manageexaminations","select",activeUser)%>
<%
    String msg = "", sEditPriority = "", sEditData = "", sEditTranType = "", sEditExamName = "", 
    		sEditRequiredInvoicable = "", sEditRequiredPrestation = "", sEditRequiredPrestationClass = "", sEditRequiredPrestationInvoiced = "",
           sEditRequiredPrestationClassInvoiced = "";
    boolean bQueryInsert = false;
    boolean bQueryUpdate = false;

    String sAction = checkString(request.getParameter("Action")),
           sExamID = checkString(request.getParameter("FindExamID"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n******************** system/manageExaminations.jsp ********************");
        Debug.println("sAction             : "+sAction);
        Debug.println("sExamID             : "+sExamID);
        Debug.println("EditPriority        : "+checkString(request.getParameter("EditPriority")));
        Debug.println("EditData            : "+checkString(request.getParameter("EditData")));
        Debug.println("EditTransactionType : "+checkString(request.getParameter("EditTransactionType")));
        Debug.println("EditExamName        : "+checkString(request.getParameter("EditExamName")));
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    //--- SAVE ------------------------------------------------------------------------------------
    if(sAction.equals("save")){
        sEditPriority = checkString(request.getParameter("EditPriority"));
        sEditData     = checkString(request.getParameter("EditData"));
        sEditTranType = checkString(request.getParameter("EditTransactionType"));
        sEditExamName = checkString(request.getParameter("EditExamName"));
       
        sEditRequiredInvoicable = checkString(request.getParameter("EditRequiredInvoicable"));
        sEditRequiredPrestation = checkString(request.getParameter("EditRequiredPrestation"));
        sEditRequiredPrestationClass = checkString(request.getParameter("EditRequiredPrestationClass"));
        sEditRequiredPrestationInvoiced = checkString(request.getParameter("EditRequiredPrestationInvoiced"));
        sEditRequiredPrestationClassInvoiced = checkString(request.getParameter("EditRequiredPrestationClassInvoiced"));

        if(sEditTranType.length() > 0){
        	MedwanQuery.getInstance().setConfigString(sEditTranType.split("\\&")[0]+".requiredInvoicable", sEditRequiredInvoicable.length()>0?"1":"0");
        	MedwanQuery.getInstance().setConfigString(sEditTranType.split("\\&")[0]+".requiredPrestation", sEditRequiredPrestation);
        	MedwanQuery.getInstance().setConfigString(sEditTranType.split("\\&")[0]+".requiredPrestationClass", sEditRequiredPrestationClass);
        	MedwanQuery.getInstance().setConfigString(sEditTranType.split("\\&")[0]+".requiredPrestation.invoiced", sEditRequiredPrestationInvoiced.length()>0?"1":"0");
        	MedwanQuery.getInstance().setConfigString(sEditTranType.split("\\&")[0]+".requiredPrestationClass.invoiced", sEditRequiredPrestationClassInvoiced.length()>0?"1":"0");
        }
        if(sEditPriority.length()==0){
            sEditPriority = "0";
        }

        //*** INSERT examination ***
        if(sExamID.equals("-1")){
            boolean examinationWithSameNameExists = Label.existsBasedOnName("examination",sEditExamName,sWebLanguage),
                    examinationWithSameTypeExists = (Examination.getByType(sEditTranType)!=null);

            if(!examinationWithSameNameExists && !examinationWithSameTypeExists){
                sExamID = MedwanQuery.getInstance().getOpenclinicCounter("ExaminationID")+"";
                bQueryInsert = true;
                msg = getTran("web.manage","examinationadded",sWebLanguage);

                // create label object for examination and save it
                Label label = new Label();
                label.type = "examination";
                label.id = sExamID;
                label.showLink = "1";
                label.language = sWebLanguage;
                label.value = sEditExamName;
                label.updateUserId = activeUser.userid;

                label.saveToDB();
                reloadSingleton(session);
            }
            else{
                if(examinationWithSameTypeExists){
                    msg = "<font color='red'>"+getTran("web.manage","examinationOfSameTypeExists",sWebLanguage)+"</script>";
                }
                else{
                    msg = "<font color='red'>"+getTran("web.manage","examinationWithSameNameExists",sWebLanguage)+"</script>";
                }
            }
        }
        //*** UPDATE examination ***
        else{
            bQueryUpdate = true;
            msg = getTran("web.manage","examinationsaved",sWebLanguage);
        }

        // save/add examination
        if(bQueryInsert || bQueryUpdate){
            Examination objExam = new Examination();

            objExam.setUpdatetime(getSQLTime());
            objExam.setUpdateuserid(Integer.parseInt(activeUser.userid));
            objExam.setData(sEditData.getBytes().length > 0?sEditData.getBytes():null);
            objExam.setPriority(Integer.parseInt(sEditPriority));
            objExam.setTransactionType(sEditTranType);
            objExam.setId(Integer.parseInt(sExamID));
            
            // set messageKey for vaccinations
            if(sEditTranType.startsWith(ScreenHelper.ITEM_PREFIX+"TRANSACTION_TYPE_VACCINATION")){	
	            String sMessageKey = sEditTranType.substring(sEditTranType.indexOf("&vaccination=")+"&vaccination=".length());		
				if(sMessageKey.length() > 0){
	                objExam.setMessageKey(sMessageKey);
				}
            }
            
            if(bQueryInsert){
                Examination.addExamination(objExam);
            }
            else if(bQueryUpdate){
                Examination.saveExamination(objExam);
            }
        }
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete")){
        Examination objExam = new Examination();
        objExam.setDeletedate(getSQLTime());
        objExam.setUpdatetime(getSQLTime());
        objExam.setUpdateuserid(Integer.parseInt(activeUser.userid));
        objExam.setId(Integer.parseInt(sExamID));

        Examination.deleteExamination(objExam);
        sExamID = "-1";
        msg = getTran("web.manage","examinationdeleted",sWebLanguage);
    }
%>

<form name="transactionForm" id="transactionForm" method="post" onclick="setSaveButton(event);" onkeyup="setSaveButton(event);">
    <input type="hidden" name="Action" value="">
    <%=writeTableHeader("Web.manage","manageexaminations",sWebLanguage,"doBack();")%>
    <table width="100%" class="menu" cellspacing="0">
        <%-- SEARCH --%>
        <tr>
            <td width="<%=sTDAdminWidth%>">&nbsp;<%=getTran("Web.manage","examination",sWebLanguage)%></td>
            <td>
                <select name="FindExamID" class="text" onChange="transactionForm.submit();">
                    <option value="-1"><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        String sKey, sID, sSelected;
                        byte[] aData;

                        Vector vResults = Examination.searchAllExaminations();
                        Iterator iter = vResults.iterator();
                        Hashtable hExaminations = new Hashtable();
                        Hashtable hResults;

                        // get examinations
                        while (iter.hasNext()) {
                            hResults = (Hashtable) iter.next();
                            System.out.println((String) hResults.get("id")); //////////
                            hExaminations.put(getTran("examination", (String) hResults.get("id"), sWebLanguage), hResults.get("id"));
                        }

                        // sort examinations
                        Vector v = new Vector(hExaminations.keySet());
                        Collections.sort(v);

                        Iterator it = v.iterator();
                        String sClass = "1";
                        Examination examination;
                        while (it.hasNext()) {
                            sKey = (String) it.next();
                            sID = (String) hExaminations.get(sKey);
                            sKey = getTran("examination", sID, sWebLanguage);

                            // alternate row-style
                            if (sClass.equals("")) sClass = "1";
                            else sClass = "";

                            sSelected = "";

                            if (sID.equals(sExamID)) {
                                examination = Examination.get(sID);
                                sSelected = " selected";

                                sEditPriority = Integer.toString(examination.getPriority());
                                sEditTranType = examination.getTransactionType();
                                aData = examination.getData();

                                if (aData != null) {
                                    sEditData = new String(aData);
                                }
                            }

                            %><option value="<%=sID%>"<%=sSelected%>><%=sKey%></option><%
                        }
                    %>
                </select>
                <%-- BUTTONS --%>
                <input class="button" type="button" name="newButton" value="<%=getTranNoLink("Web","new",sWebLanguage)%>" onclick="doNew();">
                <input class="button" type="button" name="backButton" id="backButton" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
            </td>
        </tr>
    </table>
   <%
        // message
        if(msg.length() > 0){
            %>
                &nbsp;<%=msg%>
                <br>
            <%
        }
    %>
    <br>
    <%
        if(sExamID.length() > 0){
            %>
                <%-- EXAMINATION DETAILS --------------------------------------------------------%>
                <table width="100%" class="list" cellspacing="1" cellpadding="0">
                    <%-- translation --%>
                    <%
                        // for new examination : ask for name (label)
                        if(sExamID.equals("-1")){
                            %>
                                <tr class="list">
                                    <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.manage","examination",sWebLanguage)%>&nbsp;*&nbsp;</td>
                                    <td class="admin2">
                                        <input type="text" class="normal" name="EditExamName" value="<%=sEditExamName%>" size="50" maxLength="255">
                                    </td>
                                </tr>
                            <%
                        }
                        // for existing examination : show link to manageTranslationPopupSimple, even if the label is yet provided.
                        else{
                            String examNameLink = ScreenHelper.getTranWithLink("examination",sExamID,sWebLanguage);

                            %>
                                <tr class="list">
                                    <td class="admin"><%=getTran("web.manage","examination",sWebLanguage)%></td>
                                    <td class="admin2"><%=examNameLink%></td>
                                </tr>
                            <%
                        }
                    %>
                    <%-- priority --%>
                    <tr class="list">
                        <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web","Priority",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="text" name="EditPriority" value="<%=sEditPriority%>" size="10" onBlur="isNumber(this);">
                        </td>
                    </tr>
                    <%-- data --%>
                    <tr>
                        <td class="admin"><%=getTran("web","Data",sWebLanguage)%></td>
                        <td class="admin2">
                            <textarea onKeyup="resizeTextarea(this,10);" class="text" cols="130" rows="2" name="EditData"><%=sEditData%></textarea>
                        </td>
                    </tr>
                    <%-- transactionType --%>
                    <tr>
                        <td class="admin"><%=getTran("Web.Translations","transactionType",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="normal" size="130" maxLength="255" name="EditTransactionType" value="<%=sEditTranType%>">
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("web","required.invoicable",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="checkbox" class="test" name="EditRequiredInvoicable" <%=MedwanQuery.getInstance().getConfigInt(sEditTranType.split("\\&")[0]+".requiredInvoicable",0)==1?"checked":"" %>/><%=getTran("web","invoicable",sWebLanguage) %>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("web","required.prestationcode",sWebLanguage)%></td>
                        <td class="admin2">
                            <input type="text" class="normal" size="20" maxLength="20" name="EditRequiredPrestation" value="<%=MedwanQuery.getInstance().getConfigString(sEditTranType.split("\\&")[0]+".requiredPrestation")%>">
                            <input type="checkbox" class="test" name="EditRequiredPrestationInvoiced" <%=MedwanQuery.getInstance().getConfigInt(sEditTranType.split("\\&")[0]+".requiredPrestation.invoiced",0)==1?"checked":"" %>/><%=getTran("web","invoiced",sWebLanguage) %>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"><%=getTran("web","required.prestationclass",sWebLanguage)%></td>
                        <td class="admin2">
                        	<select class="text" name="EditRequiredPrestationClass">
                        		<option value=""></option>
                        		<%=ScreenHelper.writeSelect("prestation.class", MedwanQuery.getInstance().getConfigString(sEditTranType.split("\\&")[0]+".requiredPrestationClass"), sWebLanguage, false, true) %>
                        	</select>
                            <input type="checkbox" class="test" name="EditRequiredPrestationClassInvoiced" <%=MedwanQuery.getInstance().getConfigInt(sEditTranType.split("\\&")[0]+".requiredPrestationClass.invoiced",0)==1?"checked":"" %>/><%=getTran("web","invoiced",sWebLanguage) %>
                        </td>
                    </tr>
                    <tr>
                        <td class="admin"/>
                        <td class="admin2">
                            <%
                                // ADD / SAVE
                                if(activeUser.getAccessRight("system.manageexaminations.add") || activeUser.getAccessRight("system.manageexaminations.edit")){
                                    %><input class="button" type="button" name="saveButton" onClick="doSave();" value="<%=getTranNoLink("Web",(sAction.equals("new")?"add":"save"),sWebLanguage)%>"/><%
                                }
                            %>
                            <input class="button" type="button" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack();">
                        </td>
                    </tr>
                </table>
                <%-- indication of obligated fields --%>
                <%=getTran("Web","colored_fields_are_obligate",sWebLanguage)%>
            <%
        }
    %>
</form>
<script>
  <%-- DO NEW --%>
  function doNew(){
    transactionForm.FindExamID.value = "-1";
    transactionForm.Action.value = "new";
    transactionForm.submit();
  }

  <%-- DO SAVE --%>
  function doSave(){
    <%
        if(sExamID.equals("-1")){
            %>
              if(transactionForm.EditExamName.value.length > 0){
                transactionForm.Action.value = "save";
                transactionForm.submit();
              }
              else{
                alertDialog("web.manage","datamissing");
                transactionForm.EditExamName.focus();
              }
            <%
        }
        else{
            %>
              transactionForm.Action.value = "save";
              transactionForm.submit();
            <%
        }
    %>
  }

  <%-- DO BACK  --%>
  function doBack(){
    if(checkSaveButton()){
      window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
    }
  }

  <%-- ASK DELETE --%>
  function askDelete(){
	if(yesnoDialog("Web","areYouSureToDelete")){
      transactionForm.Action.value = "delete";
      transactionForm.submit();
    }
  }
</script>

<%=writeJSButtons("transactionForm","backButton")%>