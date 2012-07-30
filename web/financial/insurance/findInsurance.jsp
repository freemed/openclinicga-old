<%@ page import="be.openclinic.finance.Insurance"%>
<%@ page import="java.util.Vector" %>
<%@include file="/includes/validateUser.jsp" %>

<%=checkPermission("financial.insurance","select",activeUser)%>

<%=sJSSORTTABLE%>
<%
    String sDefaultSortDir = "DESC";
    String sSortDir = checkString(request.getParameter("SortDir"));
    if(sSortDir.length()==0) sSortDir = sDefaultSortDir;

    String sFindInsuranceStart  = checkString(request.getParameter("FindInsuranceStart"));
    String sFindInsuranceStop   = checkString(request.getParameter("FindInsuranceStop"));

    String sFindInsuranceNr     = checkString(request.getParameter("FindInsuranceNr"));
    String sFindInsuranceType   = checkString(request.getParameter("FindInsuranceType"));

    String sFindSortColumn      = checkString(request.getParameter("FindSortColumn"));

%>
<form name="FindInsuranceForm" id="FindInsuranceForm" method="post" action="<c:url value='/main.do'/>?Page=financial/insurance/findInsurance.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("insurance","manageInsurance",sWebLanguage," doBack();")%>
    <table class='list' border='0' width='100%' cellspacing='1'>
         <%-- periode --%>
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>">
                <%=getTran("web","periode",sWebLanguage)%>
            </td>
            <td class="admin2">
                <%=getTran("web","from",sWebLanguage)%>
                <%=writeDateField("FindInsuranceStart","FindInsuranceForm",sFindInsuranceStart,sWebLanguage)%>
                <%=getTran("web","to",sWebLanguage)%>
                <%=writeDateField("FindInsuranceStop","FindInsuranceForm",sFindInsuranceStop,sWebLanguage)%>
            </td>
        </tr>
         <%-- type --%>
        <tr>
            <td class="admin2">
                <%=getTran("web","type",sWebLanguage)%>
            </td>
            <td class="admin2">
                <select class="text" name="FindInsuranceType">
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%=ScreenHelper.writeSelect("insurance.types",sFindInsuranceType,sWebLanguage)%>
                </select>
            </td>
        </tr>
         <%-- insurancenr --%>
        <tr>
            <td class="admin2">
                <%=getTran("insurance","insurancenr",sWebLanguage)%>
            </td>
            <td class="admin2">
                <input class="text" type="text" name="FindInsuranceNr" value="<%=sFindInsuranceNr%>"/>
            </td>
        </tr>
         <%-- buttons --%>
        <tr>
            <td class="admin2"/>
            <td class="admin2">
                <input class='button' type='button' name='buttonfind' value='<%=getTran("Web","search",sWebLanguage)%>' onclick='doFind();'>
                <input class='button' type='button' name='buttonclear' value='<%=getTran("Web","Clear",sWebLanguage)%>' onclick='doClear();'>
                <input class='button' type='button' name='buttonnew' value='<%=getTran("Web","new",sWebLanguage)%>' onclick='doNew();'>
                <input class='button' type="button" name="Backbutton" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>
        <%-- action,sortcolumn --%>
        <input type='hidden' name='Action' value=''>
        <input type='hidden' name='FindSortColumn' value='<%=sFindSortColumn%>'>
    </table>
</form>

<%
    Vector vInsurances = Insurance.findInsurances(sFindInsuranceStart, sFindInsuranceStop, sFindInsuranceType, sFindInsuranceNr, sFindSortColumn, activePatient.personid);
    Iterator iter = vInsurances.iterator();

    String sClass = "", sStartDate, sStopDate;

    StringBuffer sbResults = new StringBuffer();
    while (iter.hasNext()) {
        if (sClass.equals("")) {
            sClass = "1";
        } else {
            sClass = "";
        }

        Insurance insurance = (Insurance) iter.next();
        if (insurance.getStart() != null) {
            sStartDate = new SimpleDateFormat("dd/MM/yyyy").format(insurance.getStart());
        } else {
            sStartDate = "";
        }
        if (insurance.getStop() != null) {
            sStopDate = new SimpleDateFormat("dd/MM/yyyy").format(insurance.getStop());
        } else {
            sStopDate = "";
        }
        sbResults.append(
                "<tr class=\"list" + sClass + "\"" +
                        " onmouseover=\"this.style.cursor='hand';\"" +
                        " onmouseout=\"this.style.cursor='default';\"" +
                        " onclick=\"doSelect('" + insurance.getUid() + "');\">" +
                        "   <td>" + checkString(insurance.getType()) + "</td>" +
                        "   <td>" + sStartDate + "</td>" +
                        "   <td>" + sStopDate + "</td>" +
                        "   <td>" + checkString(insurance.getInsuranceNr()) + "</td>" +
                        "   <td>" + checkString(insurance.getCompany()) + "</td>" +
                        "</tr>");
    }

    String sortTran = getTran("web", "clicktosort", sWebLanguage);
%>
    <%
        if(vInsurances.size() > 0){
    %>
    <table width="100%" cellspacing="0" cellpadding="0" class="sortable" id="searchresults">
        <tr class="admin">
            <td width="10%"><a href="#" title="<%=sortTran%>" class="underlined"><<%=sSortDir%>><%=getTranNoLink("Web","type",sWebLanguage)%></<%=sSortDir%>></a></td>
            <td width="15%"><%=getTranNoLink("web","start",sWebLanguage)%></td>
            <td width="15%"><%=getTranNoLink("web","stop",sWebLanguage)%></td>
            <td width="20%"><%=getTranNoLink("web","number",sWebLanguage)%></td>
            <td width="*"><%=getTranNoLink("web","company",sWebLanguage)%></td>
        </tr>
        <%=sbResults%>
    </table>
    <%
        }else{
        %>
            <%=getTran("web","norecordsfound",sWebLanguage)%>
            <br><br>
        <%
        }
    %>
<script>
    function doClear(){
        FindInsuranceForm.FindInsuranceType.value = "";
        FindInsuranceForm.FindInsuranceStop.value = "";
        FindInsuranceForm.FindInsuranceStart.value = "";
        FindInsuranceForm.FindInsuranceNr.value = "";
    }
    function doFind(){
        if(FindInsuranceForm.FindInsuranceStart.value != ""
        || FindInsuranceForm.FindInsuranceStop.value != ""
        || FindInsuranceForm.FindInsuranceNr.value != ""
        || FindInsuranceForm.FindInsuranceType.value != "")
        {
            FindInsuranceForm.Action.value = "SEARCH";
            FindInsuranceForm.buttonfind.disabled = true;
            FindInsuranceForm.submit();
        }
    }

    function doNew(){
        window.location.href="<c:url value='/main.do'/>?Page=financial/insurance/editInsurance.jsp&ts=<%=getTs()%>";
    }

    function doBack(){
        window.location.href="<c:url value='/main.do'/>?Page=financial/index.jsp&ts=<%=getTs()%>";
    }

    function doSearchBack(){
        window.location.href="<c:url value='/main.do'/>?Page=financial/index.jsp&ts=<%=getTs()%>";
    }

    function doSelect(id){
        window.location.href="<c:url value='/main.do'/>?Page=financial/insurance/editInsurance.jsp&EditInsuranceUID=" + id + "&ts=<%=getTs()%>";
    }
</script>
