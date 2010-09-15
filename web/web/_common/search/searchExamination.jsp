<%@ page import="be.openclinic.system.Examination,java.util.Vector,java.util.Hashtable,java.util.Collections" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String sAction = checkString(request.getParameter("Action"));

    // display options
    boolean displayAllExaminations = false; // show user examinations by default
    String sDisplayAllExaminations = checkString(request.getParameter("displayAllExaminations"));

    if(sDisplayAllExaminations.length() > 0){
        displayAllExaminations = sDisplayAllExaminations.equalsIgnoreCase("true");
    }

    if(sAction.length()==0){
        if(displayAllExaminations){
            sAction = "showAllExaminations";
        }
        else{
            sAction = "showUserExaminations";
        }
    }
%>
    <form name="SearchForm" method="POST">
        <table cellpadding="0" cellspacing="0">
            <%-- title --%>
            <tr class="admin">
                <td><%=getTran("web.manage","examinations",sWebLanguage)%></td>
            </tr>

            <tr>
                <td class="white" width="100%">
                    <div class="search" style="width:440px">
                        <table width="100%" cellpadding="1" cellspacing="0">
                            <%
                                String sVarCode = checkString(request.getParameter("VarCode")),
                                        sVarText = checkString(request.getParameter("VarText")),
                                        sVarUserID = checkString(request.getParameter("VarUserID"));

                                StringBuffer exams = new StringBuffer("");
                                Hashtable hExaminations = new Hashtable();
                                String sKey, sID;
                                Hashtable hResults;

                                if (sAction.equalsIgnoreCase("showAllExaminations")) {
                                    Vector vResults = Examination.searchAllExaminations();
                                    Iterator iter = vResults.iterator();

                                    while (iter.hasNext()) {
                                        hResults = (Hashtable) iter.next();
                                        hExaminations.put(getTran("examination", (String) hResults.get("id"), sWebLanguage), hResults.get("id"));
                                    }
                                } else if (sAction.equalsIgnoreCase("showUserExaminations")) {
                                    Parameter parameter;
                                    String sValue;

                                    if (sVarUserID.length() > 0) {
                                        activeUser.initialize(Integer.parseInt(sVarUserID));
                                    }

                                    for (int i = 0; i < activeUser.parameters.size(); i++) {
                                        parameter = (Parameter) activeUser.parameters.elementAt(i);

                                        if (parameter.parameter.toLowerCase().startsWith("showexamination_")) {
                                            sID = parameter.parameter.substring(16);
                                            sValue = Examination.searchExamination(Integer.parseInt(sID));
                                            if (sValue.length() > 0) {
                                                hExaminations.put(getTran("examination", sID, sWebLanguage), sID);
                                            }
                                        }
                                    }
                                }

                                // sort examinations
                                Vector v = new Vector(hExaminations.keySet());
                                Collections.sort(v);

                                Iterator it = v.iterator();
                                String sClass = "1";
                                String sSelectTran = getTran("web", "select", sWebLanguage);

                                while (it.hasNext()) {
                                    sKey = (String) it.next();
                                    sID = (String) hExaminations.get(sKey);
                                    sKey = getTran("examination", sID, sWebLanguage);

                                    // alternate row-style
                                    if (sClass.equals("")) sClass = "1";
                                    else sClass = "";

                                    if (sKey.indexOf("<a") > -1) {
                                        // link to manageTranslationPopup
                                        exams.append("<tr class='list" + sClass + "' title='" + sSelectTran + "'><td>" + sKey + "</td></tr>");
                                    } else {
                                        exams.append("<tr class='list" + sClass + "' title='" + sSelectTran + "' onclick=\"setExamination('" + sID + "','" + sKey + "');\"><td>" + sKey + "</td></tr>");
                                    }
                                }

                                if (hExaminations.size() > 0) {
                            %>
                                        <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
                                            <%=exams%>
                                        </tbody>
                                    <%
                                }
                                else{
                                    // display 'no results' message
                                    %>
                                        <tr>
                                            <td><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                                        </tr>
                                    <%
                                }
                            %>
                        </table>
                    </div>
                </td>
            </tr>

            <%
                // show all or less examinations
                if(sAction.equalsIgnoreCase("showAllExaminations")){
                    %><tr><td><a href="#" onclick="showUserExaminations()"><%=getTran("web.manage","showonlyuserexaminations",sWebLanguage)%></a></td></tr><%
                }
                else{
                    %><tr><td><a href="#" onclick="showAllExaminations()"><%=getTran("web.manage","showallexaminations",sWebLanguage)%></a></td></tr><%
                }
            %>
        </table>

        <br>

        <%-- CLOSE BUTTON --%>
        <center>
            <input type="button" class="button" name="buttonclose" value="<%=getTran("Web","Close",sWebLanguage)%>" onclick="window.close();">
        </center>

        <input type="hidden" name="Action">
    </form>

    <script>
      window.resizeTo(450,480);

      <%-- set examination --%>
      function setExamination(sID,sName) {
        window.opener.document.all["<%=sVarCode%>"].value = sID;

        if ("<%=sVarText%>".length > 0){
          window.opener.document.all["<%=sVarText%>"].value = sName;
        }

        window.close();
      }

      <%-- show all examinations --%>
      function showAllExaminations(){
        SearchForm.Action.value = "showAllExaminations";
        SearchForm.submit();
      }

      <%-- show only user examinations --%>
      function showUserExaminations(){
        SearchForm.Action.value = "showUserExaminations";
        SearchForm.submit();
      }
    </script>
