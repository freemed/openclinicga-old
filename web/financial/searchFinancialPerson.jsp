<%@ page import="java.util.*,be.openclinic.finance.DebetTransaction,be.openclinic.finance.CreditTransaction" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sActiveBalanceID = checkString(request.getParameter("activeBalanceID"));

    String sReturnPersonID = checkString(request.getParameter("ReturnPersonID")),
            sReturnName = checkString(request.getParameter("ReturnName"));

    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    if (Debug.enabled) {
        Debug.println("################## SEARCH USER ####################################");
        Debug.println(" sReturnPersonID    : " + sReturnPersonID);
        Debug.println(" sReturnName      : " + sReturnName);
    }
    ///////////////////////////// <DEBUG> /////////////////////////////////////////////////////////
    String sLastname, sFirstname, sServiceID;

    Vector vPersonIDs = DebetTransaction.getPersonSupplierDebetTransactionByID(sActiveBalanceID);
    Vector vPersonIDs2 = CreditTransaction.getPersonSupplierCreditTransactionByID(sActiveBalanceID);
    vPersonIDs.addAll(vPersonIDs2);

    String sClass = "", sPersonID, sKey;
    Hashtable hSelected = new Hashtable();
    SortedSet set = new TreeSet();

    for (int i = 0; i < vPersonIDs.size(); i++) {
        sPersonID = checkString((String) vPersonIDs.elementAt(i));
        if (sPersonID.length() > 0) {
            Hashtable hSupplierInfo = null;//AdminPerson.getSupplierInfo(sPersonID);
            if(hSupplierInfo!=null){
                sLastname = checkString((String)hSupplierInfo.get("lastname"));
                sFirstname = checkString((String)hSupplierInfo.get("firstname"));
                sLastname = sLastname.replace('\'', '´');
                sFirstname = sFirstname.replace('\'', '´');
                // service
                sServiceID = checkString((String)hSupplierInfo.get("serviceid"));

                sKey = sLastname + sFirstname + sPersonID;
                set.add(sKey);
                hSelected.put(sKey, " onclick=\"setPerson(" + checkString((String)hSupplierInfo.get("personid")) + ", '" + sLastname + " " + sFirstname + "');\">"
                        + "<td>" + sLastname + "  " + sFirstname + "</td>"
                        + "<td>" + getTranDb("service", sServiceID, sWebLanguage) + "</td>"
                        + "</tr>");
            }
        }
    }
%>
<html>
<head>
    <title><%=sWEBTITLE+" "+sAPPTITLE%></title>
    <%=sCSSNORMAL%>
    <%=sJSCHAR%>
    <%=sJSDATE%>
    <%=sJSPOPUPSEARCH%>
</head>
<%-- Start Floating Layer -----------------------------------------------------------------------%>
<div id="FloatingLayer" style="position:absolute;width:250px;left:180px;top:180px;visibility:hidden">
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
    <form name="SearchForm" method="POST" action="<c:url value='/popup.jsp'/>?Page=_common/search/searchUser.jsp&ts=<%=getTs()%>" onkeydown="if(enterEvent(event,13)){doFind();}">
        <table width="100%" cellspacing="0" cellpadding="0" class="menu">

            <%-- SEARCH RESULTS TABLE --%>
            <tr>
                <td valign="top" colspan="5" class="white" width="100%">
                    <div class="search" style="width:588px">
                        <table border='0' width='100%' cellspacing="0" cellpadding="0">
                        <%
                            if(vPersonIDs.size()>0){
                                %>
                                    <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                                        <tr class="admin">
                                            <td nowrap><%=getTran("Web","name",sWebLanguage)%></td>
                                            <td width='110' nowrap><%=getTran("Web","service",sWebLanguage)%></td>
                                        </tr>
                                        <%
                                        if (!vPersonIDs.contains(activePatient.personid)){
                                            sLastname = activePatient.lastname;
                                            sFirstname = activePatient.firstname;
                                            sServiceID = "";
                                            out.print("<tr class='list' onclick=\"setPerson("+activePatient.personid+", '"+sLastname+" "+sFirstname+"');\">"
                                              +"<td>"+sLastname+"  "+sFirstname+"</td>"
                                              +"<td>"+getTranDb("service",sServiceID,sWebLanguage)+"</td>"
                                              +"</tr>");
                                        }

                                        if (!vPersonIDs.contains(activeUser.person.personid)){
                                            sLastname = activeUser.person.lastname;
                                            sFirstname = activeUser.person.firstname;
                                            sServiceID = "";
                                            out.print("<tr class='list' onclick=\"setPerson("+activeUser.person.personid+", '"+sLastname+" "+sFirstname+"');\">"
                                              +"<td>"+sLastname+"  "+sFirstname+"</td>"
                                              +"<td>"+getTranDb("service",sServiceID,sWebLanguage)+"</td>"
                                              +"</tr>");
                                        }
                                        // sort
                                        Iterator iter = set.iterator();
                                        while(iter.hasNext()){
                                            if(sClass.equals("")){
                                                sClass = "1";
                                            }
                                            else{
                                                sClass = "";
                                            }

                                            out.print("<tr class='list"+sClass+"'"+hSelected.get(iter.next()));
                                        }
                                        %>
                                    </tbody>
                                <%
                            }
                            else{
                                // display 'no results' message
                                %>
                                    <tr>
                                        <td colspan='3'><%=getTran("web","norecordsfound",sWebLanguage)%></td>
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
            <input type="button" class="button" name="closeButton" value='<%=getTran("Web","Close",sWebLanguage)%>' onclick='window.close()'>
        </center>

        <%-- hidden fields --%>
        <input type="hidden" name="ReturnPersonID" value="<%=sReturnPersonID%>">
        <input type="hidden" name="ReturnName" value="<%=sReturnName%>">
    </form>

    <script>
      window.resizeTo(600,450);

      <%-- SET PERSON --%>
      function setPerson(sPersonID,sName){
        if('<%=sReturnPersonID%>'.length>0){
          window.opener.document.getElementsByName('<%=sReturnPersonID%>')[0].value = sPersonID;
        }

        if('<%=sReturnName%>'.length>0){
          window.opener.document.getElementsByName('<%=sReturnName%>')[0].value = sName;
        }

        if(window.opener.document.getElementsByName('<%=sReturnPersonID%>')[0] != null){
          if(window.opener.document.getElementsByName('<%=sReturnPersonID%>')[0].onchange!=null){
            window.opener.document.getElementsByName('<%=sReturnPersonID%>')[0].onchange();
          }
        }

        window.close();
      }
    </script>
</body>
</html>