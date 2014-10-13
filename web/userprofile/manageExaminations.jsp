<%@ page import="java.util.*,be.openclinic.system.Examination" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=sJSSORTTABLE%>

<form name='transactionForm' method='post'>
    <%=writeTableHeader("Web.UserProfile","ManageExaminations",sWebLanguage," doBack();")%>
    <table width='100%' cellspacing="1" cellpadding="0" class="sortable" id="searchresults">
        <%-- HEADER --%>
        <tr class="gray">
            <td width="25">&nbsp;</td>
            <td width="100%"><%=getTran("web","examination",sWebLanguage)%></td>
        </tr>

        <%
            String sAction = checkString(request.getParameter("Action"));

            if (sAction.equals("save")) {
                Parameter parameter;
                Vector vParameters = (Vector) activeUser.parameters.clone();

                for (int i = 0; i < vParameters.size(); i++) {
                    parameter = (Parameter) vParameters.elementAt(i);

                    if (parameter.parameter.toLowerCase().startsWith("showexamination_")) {
                        activeUser.removeParameter(parameter.parameter);
                    }
                }

                String sParamName, sParamValue;
                Enumeration e = request.getParameterNames();
                while (e.hasMoreElements()) {
                    sParamName = (String) e.nextElement();

                    if (sParamName.toLowerCase().startsWith("edit")) {
                        sParamValue = checkString(request.getParameter(sParamName));

                        if (sParamValue.equals("on")) {
                            parameter = new Parameter();
                            parameter.parameter = "showexamination_" + sParamName.substring(4);
                            parameter.value = "on";
                            activeUser.parameters.add(parameter);
                            activeUser.updateParameter(parameter);
                        }
                    }
                }

                session.setAttribute("activeUser", activeUser);
            }
            Vector vExaminations = Examination.searchAllExaminations();
            Iterator iter = vExaminations.iterator();

            Hashtable hTransactions = new Hashtable();
            Hashtable hResults;

            while(iter.hasNext()){
                hResults = (Hashtable)iter.next();
                hTransactions.put(getTran("web.occup", (String)hResults.get("transactionType"), sWebLanguage).toLowerCase(), hResults.get("id"));
            }

            Vector v = new Vector(hTransactions.keySet());
            Collections.sort(v);
            Iterator it = v.iterator();
            String sClass = "";
            String sKey, sChecked, sID;
            while (it.hasNext()) {

                if (sClass.equals("")) {
                    sClass = "1";
                } else {
                    sClass = "";
                }

                sKey = (String) it.next();
                sID = (String) hTransactions.get(sKey);
                sChecked = "";

                if (checkString(activeUser.getParameter("showexamination_" + sID)).length() > 0) {
                    sChecked = " checked";
                }

                %>
                    <tr class="list<%=sClass%>">
                        <td><input type="checkbox" name="Edit<%=sID%>"<%=sChecked%> class="hand"></td><td><%=sKey%></td>
                    </tr>
                <%
            }
        %>
    </table>

    <%-- BUTTONS --%>
    <div style="padding-top:5px;text-align:center;width:100%">
        <input type='button' name='saveButton' class="button" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onClick="doSave();">
        <input type='button' name='backButton' class="button" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick='doBack();'>
    </div>

    <input type="hidden" name="Action">
</form>

<script>
  function doSave(){
    transactionForm.saveButton.disabled = true;
    transactionForm.backButton.disabled = true;
    transactionForm.Action.value = "save";
    transactionForm.submit();
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
  }
</script>