<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.system.ExternalContact" %>
<%@ page import="be.openclinic.finance.CreditTransaction" %>

<%!
    //--- GET PARENT ------------------------------------------------------------------------------
    private String getParent(String sCode,String sWebLanguage) {
        String sReturn = "";

        if ((sCode!=null)&&(sCode.trim().length()>0)) {
            String sLabel = getTran("Service",sCode,sWebLanguage);
            Service service = Service.getService(sCode);

            if (service!=null) {
                //String sParentID = checkString(rs.getString("serviceparentid"));
                String sParentID = checkString(service.parentcode);//rs.getString("serviceparentid"));
                if ((sParentID!=null)&&(!sParentID.equals("0000"))&&(sParentID.trim().length()>0)){

                    sReturn = getParent(sParentID,sWebLanguage)
                        +"&nbsp;<img src='"+sCONTEXTPATH+"/_img/pijl.gif'>&nbsp;"
                        +"<a href='#' onclick='populateService(\""+sCode+"\")' title='"+getTran("Web.Occup","medwan.common.open",sWebLanguage)+"'>"+sLabel+"</a>";
                }
            }

            if (sReturn.trim().length()==0) {
                sReturn = sReturn+"&nbsp;<img src='"+sCONTEXTPATH+"/_img/pijl.gif'>&nbsp;"
                    +"<a href='#' onclick='populateService(\""+sCode+"\")' title='"+getTran("Web.Occup","medwan.common.open",sWebLanguage)+"'>"+sLabel+"</a>";
            }
        }

        return sReturn;
    }

    //--- WRITE MY ROW ----------------------------------------------------------------------------
    private String writeMyRow(String sID, String sWebLanguage, String sIcon){
        String sLabel = getTran("Service",sID.trim(), sWebLanguage);
        if(sIcon.length()==0){
            sIcon = "<img src='"+sCONTEXTPATH+"/_img/menu_tee_plus.gif' onclick='populateService(\""+sID+"\")'"
                +" alt='"+getTranNoLink("Web.Occup","medwan.common.open",sWebLanguage)+"'>";
        }

        return "<tr><td>"
            +sIcon+"&nbsp;<img src='"+sCONTEXTPATH+"/_img/icon_view.gif' alt='"+getTranNoLink("Web","view",sWebLanguage)+"'"
            +" onclick='viewService(\""+sID+"\")'></td><td>"+sID+"</td>"
            +"<td><a href='#' onclick='selectParentService(\""+sID+"\",\""+sLabel+"\")' title='"+getTran("Web","select",sWebLanguage)+"'>"+sLabel+"</a></td></tr>";
    }
%>

<%
    // form data
    String sVarCode = checkString(request.getParameter("VarCode")),
            sVarText = checkString(request.getParameter("VarText")),
            sViewCode = checkString(request.getParameter("ViewCode")),
            sFindText = checkString(request.getParameter("FindText")).toUpperCase(),
            sFindCode = checkString(request.getParameter("FindCode")).toUpperCase();

    // options
    String sSearchInternalServices = checkString(request.getParameter("SearchInternalServices"));
    boolean searchInternalServices = true; // default
    if (sSearchInternalServices.length() > 0) {
        searchInternalServices = sSearchInternalServices.equalsIgnoreCase("true");
    }
    if (Debug.enabled) Debug.println("*** searchInternalServices : " + searchInternalServices);

    String sSearchExternalServices = checkString(request.getParameter("SearchExternalServices"));
    boolean searchExternalServices = false; // default
    if (sSearchExternalServices.length() > 0) {
        searchExternalServices = sSearchExternalServices.equalsIgnoreCase("true");
    }
    if (Debug.enabled) Debug.println("*** SearchExternalServices : " + searchExternalServices);

    // variables
    StringBuffer sOut = new StringBuffer();
    String sServiceID, sNavigation = "";
    Hashtable hSelected = new Hashtable();
    SortedSet set = new TreeSet();
    Object element;
    int iTotal = 0;

    //*** search on findCode ***
    if (sFindCode.length() > 0) {
        // internal services
        if (searchInternalServices) {
            Vector vChilds = Service.getChildIds(sFindCode);
            Iterator iter = vChilds.iterator();
            Service service;
            while (iter.hasNext()) {
                service = (Service) iter.next();
                sServiceID = checkString(service.code);
                set.add(sServiceID);
                hSelected.put(sServiceID, writeMyRow(sServiceID, sWebLanguage, ""));

                iTotal++;
            }

            sNavigation = getParent(sFindCode, sWebLanguage);
        }

        // external services
        if (searchExternalServices) {
            Vector vChilds = ExternalContact.getChildIds(sFindCode);
            Iterator iter = vChilds.iterator();

            //while (rs.next()) {
            ExternalContact extCon;
            while (iter.hasNext()) {
                extCon = (ExternalContact) iter.next();
                sServiceID = checkString(extCon.getServiceid());
                set.add(sServiceID);
                hSelected.put(sServiceID, writeMyRow(sServiceID, sWebLanguage, ""));

                iTotal++;
            }

            sNavigation = getParent(sFindCode, sWebLanguage);
        }
    }
    //*** search on findText ***
    else if (sFindText != null && sFindText.length() > 0) {
        String labelTypes;
        if (searchInternalServices && searchExternalServices) {
            labelTypes = " IN ('service','externalservice')";
        } else if (searchInternalServices) {
            labelTypes = " = 'service'";
        } else {
            labelTypes = " = 'externalservice'";
        }

        Vector vLabels = Label.getExternalContactsLabels(labelTypes, sFindText, sWebLanguage);
        Iterator iter = vLabels.iterator();

        String labelid;
        Label label;
        while (iter.hasNext()) {
            label = (Label) iter.next();
            labelid = label.id;
            set.add(labelid);
            hSelected.put(labelid, writeMyRow(labelid, sWebLanguage, ""));
            iTotal++;
        }
    }
    //*** empty search ***
    else {
//        if(getConfigString("fillUpSearchServiceScreens").equalsIgnoreCase("on")){
        String sActiveBalanceID = checkString(request.getParameter("activeBalanceID"));
        Vector vCredits = CreditTransaction.getServiceCreditTransactionByID(sActiveBalanceID);
        Iterator iter = vCredits.iterator();

        CreditTransaction credit;
        while(iter.hasNext()){
            credit = (CreditTransaction)iter.next();
            sServiceID = credit.getSource().getObjectUid();
            set.add(sServiceID);
            hSelected.put(sServiceID, writeMyRow(sServiceID, sWebLanguage, ""));
            iTotal++;
        }
    }
%>

<html>
<head>
    <title><%=sAPPTITLE%></title>
    <%=sCSSNORMAL%>
    <%=sJSCHAR%>
    <%=sJSPOPUPSEARCH%>
</head>

<%-- Start Floating Layer -----------------------------------------------------------------------%>
<div id="FloatingLayer" style="position:absolute;width:250px;left:150px;top:200px;visibility:hidden">
    <table border="0" width="250" cellspacing="0" cellpadding="5" style="border:1px solid #aaa">
        <tr>
            <td bgcolor="#dddddd" style="text-align:center">
              <%=getTran("web","searchInProgress",sWebLanguage)%>
            </td>
        </tr>
    </table>
</div>
<%-- End Floating layer -------------------------------------------------------------------------%>

<body class="Geenscroll">
    <form name='SearchForm' method="POST" onSubmit="doFind();">
        <%-- hidden fields --%>
        <input type="hidden" name='VarCode' value="<%=sVarCode%>">
        <input type="hidden" name='VarText' value="<%=sVarText%>">
        <input type="hidden" name="FindCode">
        <input type="hidden" name="ViewCode">

        <table width='100%' border='0' cellspacing='0' cellpadding='0' class='menu'>
            <tr>
                <td width='100%' height='25'>
                    &nbsp;<%=getTran("Web","Find",sWebLanguage)%>&nbsp;&nbsp;
                    <input type="text" NAME='FindText' class="text" value="<%=sFindText%>" size="40">

                    <%-- buttons --%>
                    <input class='button' type="button" name='FindButton' value="<%=getTran("Web","find",sWebLanguage)%>" onClick="doFind();">&nbsp;
                    <input class='button' type="button" name="ClearButton" value='<%=getTran("Web","clear",sWebLanguage)%>' OnClick="SearchForm.all['FindText'].value='';SearchForm.all['FindText'].focus();">
                </td>
            </tr>

            <tr><td class="navigation_line" height="1"></td></tr>

            <%-- menubar --%>
            <tr>
                <td class="menu_bar">
                    &nbsp;<a href='#' onclick='ClearButton.click();SearchForm.submit();'>Home</a><%=sNavigation%>
                </td>
            </tr>

            <%-- SEARCH RESULTS TABLE --%>
            <tr>
                <td class='white' style="vertical-align:top;">
                    <div class="search" style="width:536px;height:370px;">
                        <table width="100%" cellspacing="1">
                            <%
                                if(sViewCode.length()>0 || iTotal==0){
                                    if(iTotal==0){
                                        sViewCode = sFindCode;
                                    }

                                    String sLabel = getTran("Service",sViewCode,sWebLanguage);

                                    Service service = Service.getService(sViewCode);

                                    if(service!=null){
                                        String sCountry = checkString(service.country);
                                        if(sCountry.length() > 0){
                                            sCountry = getTran("Country",sCountry,sWebLanguage);
                                        }

                                        out.print(setRow("Web","Address", checkString(service.address),sWebLanguage));
                                        out.print(setRow("Web","zipcode", checkString(service.zipcode),sWebLanguage));
                                        out.print(setRow("Web","city", checkString(service.city),sWebLanguage));
                                        out.print(setRow("Web","country", sCountry,sWebLanguage));
                                        out.print(setRow("Web","telephone", checkString(service.telephone),sWebLanguage));
                                        out.print(setRow("Web","fax", checkString(service.fax),sWebLanguage));
                                        out.print(setRow("Web","contract", checkString(service.contract),sWebLanguage));
                                        out.print(setRow("Web","contracttype", checkString(service.contracttype),sWebLanguage));
                                        out.print(setRow("Web","contactperson", checkString(service.contactperson),sWebLanguage));
                                        out.print(setRow("Web","comment", checkString(service.comment),sWebLanguage));
                                        out.print(setRow("Web","medicalcentre", checkString(service.code5),sWebLanguage));

                                        %>
                                            <tr height="1">
                                                <td width="30%">&nbsp;</td>
                                                <td>&nbsp;</td>
                                            </tr>

                                            <tr>
                                                <td colspan="2" align="right">
                                                    <input type="button" class="button" value="<%=getTran("Web","select",sWebLanguage)%>" onclick="selectParentService('<%=sViewCode%>','<%=sLabel%>')">
                                                </td>
                                            </tr>
                                        <%
                                    }
                                }
                                else{
                                    // sorteer
                                    Iterator it = set.iterator();
                                    while(it.hasNext()){
                                        element = it.next();
                                        sOut.append((String)hSelected.get(element.toString()));
                                    }

                                    // display search results
                                    if(iTotal > 0){
                                        if((iTotal==1) && (checkString(sFindText).length() > 0)){
                                            // display 'no results' message
                                            %>
                                                <tr>
                                                    <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                                                </tr>
                                            <%
                                        }
                                        else{
                                            %>
                                                <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                                                    <%out.print(sOut.toString());%>
                                                </tbody>
                                            <%
                                        }
                                    }
                                    %>
                                        <%-- SPACER --%>
                                        <tr height="1">
                                            <td width="1%">&nbsp;</td>
                                            <td width="1%">&nbsp;</td>
                                        </tr>
                                    <%
                                }

                            %>
                        </table>
                    </div>
                </td>
            </tr>
        </table>

        <br>

        <%-- CLOSE BUTTON --%>
        <center>
            <input type="button" class="button" name="buttonclose" value='<%=getTran("Web","Close",sWebLanguage)%>' onclick='window.close()'>
        </center>
    </form>

    <script>
      window.resizeTo(550,505);
      SearchForm.FindText.focus();

      function selectParentService(sCode, sText){
        window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = sCode;
        if ('1'=='<%=MedwanQuery.getInstance().getConfigString("showUnitID")%>'){
          window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sCode+" "+sText;
        }
        else{
          window.opener.document.getElementsByName('<%=sVarText%>')[0].value = sText;
        }
        window.opener.document.getElementsByName('<%=sVarText%>')[0].title = sText;
        if(window.opener.submitSelect!=null){window.opener.submitSelect()};

        if(window.opener.document.getElementsByName('<%=sVarCode%>')[0] != null){
            if(window.opener.document.getElementsByName('<%=sVarCode%>')[0].onchange!=null){
                window.opener.document.getElementsByName('<%=sVarCode%>')[0].onchange();
            }
        }

        window.close();
      }

      function populateService(sID){
        SearchForm.FindCode.value=sID;
        SearchForm.submit();
      }

      function viewService(sID){
        SearchForm.FindCode.value=sID;
        SearchForm.ViewCode.value=sID;
        SearchForm.submit();
      }

      function doFind(){
        ToggleFloatingLayer('FloatingLayer',1);
        SearchForm.FindButton.disabled = true;
        SearchForm.submit();
      }
    </script>
</body>
</html>