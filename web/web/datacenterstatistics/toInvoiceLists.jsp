<%@ page import="be.openclinic.finance.PatientInvoice" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@include file="/includes/validateUser.jsp" %>
<%=checkPermission("statistics", "select", activeUser)%><%=sJSSORTTABLE%><%=writeTableHeader("web", "statistics.toinvoicelists", sWebLanguage, "")%>
<form id="searchForm">
    <table class="menu" width="100%" cellspacing="0">
        <tr>
            <td><%=getTran("web.finance", "invoicetype", sWebLanguage)%>
            </td>
            <td>
                <input type="radio" id="FindTypePatient" name="FindInvoiceType" value="patient" checked="true"><%=getLabel("web", "patient", sWebLanguage, "FindTypePatient")%>
                <input type="radio" id="FindTypeInsurar" name="FindInvoiceType" value="insurar"><%=getLabel("web", "insurar", sWebLanguage, "FindTypeInsurar")%>
                <input type="radio" id="FindExtraInvoiceType" name="FindInvoiceType" value="extrainsurar"><%=getLabel("web", "extrainsurar", sWebLanguage, "FindExtraInvoiceType")%>
            </td>
        </tr>
        <tr>
            <td/>
            <td colspan="4">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","searchprestation",sWebLanguage)%>" onclick="doFind()">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFindFields()">&nbsp;
            </td>
        </tr>
    </table>
</form>
<br />
<div id="resultsByAjax">
    &nbsp; <%-- Filled by Ajax --%>
</div>
<script type="text/javascript">
    function doFind() {
        var id = "resultsByAjax";
        $(id).update("<div id='wait'>&nbsp;</div>");
        var url = "<c:url value="/statistics/ajax/getToInvoiceList.jsp" /><%="?ts="+getTs()%>" ;
        var params = $("searchForm").serialize();
        var myAjax = new Ajax.Updater(
                id, url,
        {
            evalScripts:true,
            method: 'post',
            parameters: params,
            onComplete:function() {
                sortables_init();
            },
            onFailure:function() {
                $('resultsByAjax').innerHTML = "Problem with ajax request !!";
            }
        });
    }
</script>