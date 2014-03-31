<%@ page import="java.util.Vector,java.util.Hashtable" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sCity, sZipcode;

    String sFindText = checkString(request.getParameter("FindText")),
            sFindTextLocal = checkString(request.getParameter("FindTextLocal")),
            sVarText = checkString(request.getParameter("VarText")),
            sVarCode = checkString(request.getParameter("VarCode"));

    if (sFindTextLocal.length() == 0) sFindTextLocal = sFindText;

    // what language to display data in
    String cityDisplayLang = checkString(request.getParameter("DisplayLang"));
    if (cityDisplayLang.length() == 0) {
        if (activePatient != null && checkString(activePatient.language).length() > 0) {
            cityDisplayLang = activePatient.language;
        } else {
            cityDisplayLang = activeUser.person.language;
        }
    }

    // convert language
    if (cityDisplayLang.substring(0, 1).equalsIgnoreCase("F")) cityDisplayLang = "fr";
    else if (cityDisplayLang.substring(0, 1).equalsIgnoreCase("N")) cityDisplayLang = "nl";
    else if (cityDisplayLang.substring(0, 1).equalsIgnoreCase("E")) cityDisplayLang = "en";
    else if (cityDisplayLang.substring(0, 1).equalsIgnoreCase("D")) cityDisplayLang = "de";
    else {
        cityDisplayLang = "nl";
    }

    // compose query
    Vector vResults = Zipcode.searchZipcodes(cityDisplayLang, sFindTextLocal);
    Iterator iter = vResults.iterator();

    Hashtable hResults = new Hashtable();

    int iTotal = 1;

    StringBuffer sOut = new StringBuffer();
    String chooseTran = getTran("web", "choose", sWebLanguage);

    while (iter.hasNext()) {
        hResults = (Hashtable) iter.next();

        sCity = (String) hResults.get("city");
        sCity = sCity.replaceAll("'", "´");
        sZipcode = (String) hResults.get("zipcode");

        sOut.append("<tr>")
                .append(" <td title='" + chooseTran + "' onClick=\"selectUnit('" + sZipcode + "','" + sCity + "');\">")
                .append(sZipcode + " " + sCity)
                .append(" </td>")
                .append("</tr>");
        iTotal++;
    }
%>
    <form name='SearchForm' method="POST">
        <input type="hidden" name="DisplayLang" value="<%=cityDisplayLang%>">

        <table width='100%' border='0' cellspacing='0' cellpadding='0' class='menu'>
            <%-- SEARCH ROW --%>
            <tr>
                <td width='100%' height='25'>
                    &nbsp;<%=getTran("Web","Find",sWebLanguage)%>&nbsp;&nbsp;
                    <input class="text" type="text" name='FindTextLocal' value="<%=sFindTextLocal%>" size="40">

                    <%-- BUTTONS --%>
                    <input class='button' type="button" name='FindSearchbutton' value="<%=getTran("Web","find",sWebLanguage)%>" onClick='doFind();'>&nbsp;
                    <input class='button' type="button" name="clear" value='<%=getTran("Web","clear",sWebLanguage)%>' OnClick="doClear();">
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
                                    if(iTotal==1 && sFindTextLocal.length() > 0){
                                        // display 'no results' message
                                        %>
                                            <tr>
                                                <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                                            </tr>
                                        <%

                                        // clear city if zipcode not found.
                                        out.print("<script>");
                                        out.print("  window.opener.document.getElementsByName('"+sVarText+"')[0].value = '';");
                                        out.print("</script>");
                                        out.flush();
                                    }
                                    else{
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
            <input type="button" class="button" name="buttonclose" value='<%=getTran("Web","Close",sWebLanguage)%>' onclick='window.close();'>
            <input type="hidden" name='VarText' value="<%=sVarText%>">
            <input type="hidden" name='VarCode' value="<%=sVarCode%>">
        </center>

        <script>
          window.resizeTo(450,485);
          SearchForm.FindText.focus();

          <%-- SELECT UNIT --%>
          function selectUnit(code,city){
            window.opener.document.getElementsByName('<%=sVarCode%>')[0].value = code;
            window.opener.document.getElementsByName('<%=sVarText%>')[0].title = city;
            window.opener.document.getElementsByName('<%=sVarText%>')[0].value = city;
            window.close();
          }

          <%-- DO CLEAR --%>
          function doClear(){
            SearchForm.all['FindTextLocal'].value = '';
            SearchForm.all['FindTextLocal'].focus();
          }

          <%-- DO FIND --%>
          function doFind(){
            ToggleFloatingLayer('FloatingLayer',1);
            SearchForm.FindSearchbutton.disabled = true;
            SearchForm.submit();
          }
        </script>
    </form>
