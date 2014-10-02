<%@ page import="java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sVarCode = checkString(request.getParameter("VarCode"));
    String sVarText = checkString(request.getParameter("VarText"));
    String sFindText = checkString(request.getParameter("FindText"));
    String sLabelType = checkString(request.getParameter("LabelType")).toLowerCase();
    boolean showLabelID = checkString(request.getParameter("ShowLabelID")).length() > 0;
    String defaultValue = checkString(request.getParameter("DefaultValue"));

    if (sFindText.length() == 0) {
        if (defaultValue.length() == 0) {
            sFindText = MedwanQuery.getInstance().getConfigString("defaultSearch" + sLabelType);
        }
    }

    sFindText = sFindText.toLowerCase();

    String sLabelLang = sWebLanguage;

    if (checkString(sLabelLang).length()==0){
        sLabelLang = MedwanQuery.getInstance().getConfigString("DefaultLanguage","fr");
    }

    // DEBUG ////////////////////////////////////////////////////////
    Debug.println("sVarCode     : " + sVarCode);
    Debug.println("sVarText     : " + sVarText);
    Debug.println("sFindText    : " + sFindText);
    Debug.println("sLabelType   : " + sLabelType);
    Debug.println("sLabelLang   : " + sLabelLang);
    Debug.println("showLabelID  : " + showLabelID);
    Debug.println("defaultValue : " + defaultValue + "\n");
    /////////////////////////////////////////////////////////////////

    StringBuffer sOut = new StringBuffer();
    int iMaxRSIndex = 100, iTotal = 1, iRSIndex = 0;
    String chooseTran = getTran("web", "choose", sWebLanguage);

    //--- "function" and "service" ---
    if (sLabelType.equalsIgnoreCase("function") || sLabelType.equalsIgnoreCase("service")) {
        if (sFindText.length() > 0) {
            Vector vLabels = Label.findFunctionServiceLabels(sLabelType,sLabelLang,sFindText);
            Iterator iter = vLabels.iterator();
            String sRSIndex = checkString(request.getParameter("RSIndex"));
            if (sRSIndex.length() > 0) {
                iRSIndex = Integer.parseInt(sRSIndex);
                for (int n = 0; n < iRSIndex - 1 && iter.hasNext(); n++) {
                    // skip labels the user does not want to see
                }
            }

            String sTmpValue, sTmpID;
            iter = vLabels.iterator();
            //while (rs.next() && iTotal < iMaxRSIndex) {
            Label label;
            while(iter.hasNext()){
                label = (Label)iter.next();
                sTmpValue = label.value;
                sTmpID = label.id;

                if (showLabelID) {
                    // display ID and value
                    sOut.append("<tr><td title='" + chooseTran + "' onClick=\"selectRecord('" + sTmpID + "','" + sTmpValue + "');\">" + sTmpID + " " + sTmpValue + "</td></tr>");
                } else {
                    // only display value
                    sOut.append("<tr><td title='" + chooseTran + "' onClick=\"selectRecord('" + sTmpID + "','" + sTmpValue + "');\">" + sTmpValue + "</td></tr>");
                }

                iTotal++;
            }
        }
    }
    //--- not "function" and "service" ---
    else {
        Hashtable hSelected = new Hashtable();
        SortedSet set = new TreeSet();

        // get labels-hash from MedwanQuery
        Hashtable langHashtable = MedwanQuery.getInstance().getLabels();
        if (langHashtable != null) {
            Hashtable typeHashtable = (Hashtable) langHashtable.get(sLabelLang.toLowerCase());
            if (typeHashtable != null) {
                Hashtable idHashtable = (Hashtable) typeHashtable.get(sLabelType.toLowerCase());
                if (idHashtable != null) {
                    Enumeration enum2 = idHashtable.elements();
                    Label label;

                    if (showLabelID) {
                        // loop : check language and id
                        while (enum2.hasMoreElements()) {
                            label = (Label) enum2.nextElement();

                            if ((label.value.toLowerCase().indexOf(sFindText.toLowerCase()) > -1) || (label.id.toLowerCase().indexOf(sFindText.toLowerCase()) > -1)) {
                                set.add(label.id);
                                hSelected.put(label.id, "<tr><td title='" + chooseTran + "' onClick=\"selectRecord('" + label.id + "','" + label.value + "');\"'>" + label.id + " " + label.value + "</td></tr>");
                                iTotal++;
                            }
                        }
                    } else {
                        // loop : only check language
                        while (enum2.hasMoreElements()) {
                            label = (Label) enum2.nextElement();

                            if (label.value.toLowerCase().indexOf(sFindText.toLowerCase()) > -1) {
                                set.add(label.value.toLowerCase());
                                hSelected.put(label.value.toLowerCase(), "<tr><td title='" + chooseTran + "' onClick=\"selectRecord('" + label.id + "','" + label.value + "');\"'>" + label.value + "</td></tr>");
                                iTotal++;
                            }
                        }
                    }

                    // sort
                    Iterator iter = set.iterator();
                    while (iter.hasNext()) {
                        sOut.append((String) hSelected.get(iter.next()));
                    }
                }
            }
        }
    }
%>
    <form name='SearchForm' method="POST">
        <%-- hidden fields --%>
        <input type="hidden" name='VarCode' value="<%=sVarCode%>">
        <input type="hidden" name='VarText' value="<%=sVarText%>">
        <input type="hidden" name='ShowLabelID' value="<%=(showLabelID?showLabelID+"":"")%>">
        <input type="hidden" name='LabelType' value='<%=sLabelType%>'>
        <input type="hidden" name='RSIndex'>

        <table width='100%' cellspacing='0' cellpadding='0' class='menu'>
            <%-- SEARCH HEADER --%>
            <tr>
                <td width='100%' height='25'>
                    &nbsp;<%=getTran("Web","Find",sWebLanguage)%>&nbsp;&nbsp;
                    <input type="text" NAME='FindText' class="text" value="<%=sFindText%>" size="40" >

                    <%-- buttons --%>
                    <input class="button" type="button" name="FindButton" value="<%=getTranNoLink("Web","find",sWebLanguage)%>" onClick="doFind();">&nbsp;
                    <input class="button" type="button" name="clear" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onClick="doClear();">
                </td>
            </tr>

            <%-- SEARCH RESULTS --%>
            <tr>
                <td class="white" style="vertical-align:top;">
                    <div class="search">
                        <table width="100%" cellspacing="1" cellpadding="0">
                            <%
                                // display search results
                                if(iTotal > 0){
                                    if(iTotal==1 && sFindText.length() > 0){
                                        // display 'no results' message
                                        %>
                                            <tr>
                                                <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                                            </tr>
                                        <%
                                    }
                                    else{
                                        if(sLabelType.equalsIgnoreCase("function") || sLabelType.equalsIgnoreCase("service")){
                                            // previous
                                            if (iRSIndex >= iMaxRSIndex) {
                                                %><a href='#' title='<%=getTran("Web","Previous",sWebLanguage)%>' OnClick="SearchForm.RSIndex.value='<%=(iRSIndex-iMaxRSIndex)%>';doFind();"><img src='<c:url value='/_img/themes/default/arrow_left.gif'/>' border='0'></a>&nbsp;<%
                                            }

                                            // next
                                            if (iTotal == iMaxRSIndex) {
                                                %><a href='#' title='<%=getTran("Web","Next",sWebLanguage)%>' OnClick="SearchForm.RSIndex.value='<%=(iRSIndex+iMaxRSIndex)%>';doFind();"><img src='<c:url value='/_img/arrow-right.jpg'/>' border='0'></a><%
                                            }
                                        }

                                        // search-results
                                        %>
                                            <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                                                <%=sOut%>
                                            </tbody>
                                        <%
                                    }
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
            <input type=button class=button name=buttonclose value='<%=getTranNoLink("Web","Close",sWebLanguage)%>' onclick='window.close();'>
        </center>

        <script>
          window.resizeTo(450,465);
          SearchForm.FindText.focus();

          function selectRecord(value,text){
            window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = value;
            window.opener.document.getElementsByName('<%=sVarText%>')[0].value = text;
            window.opener.document.getElementsByName('<%=sVarText%>')[0].title = text;
            window.close();
          }

          function doFind(){
            //ToggleFloatingLayer('FloatingLayer',1);
            SearchForm.FindButton.disabled = true;
            SearchForm.submit();
          }

          function doClear(){
            SearchForm.all['FindText'].value = '';
            SearchForm.all['FindText'].focus();
          }
        </script>
    </form>
