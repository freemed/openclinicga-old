<%@page import="be.openclinic.finance.PatientInvoice,
                be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("statistics","select",activeUser)%>
<%=sJSSORTTABLE%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n******************** statistics/toInvoiceLists.jsp *********************");
    	Debug.println("no parameters");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<form id="searchForm">
    <%=writeTableHeader("web","statistics.toinvoicelists",sWebLanguage," doBack();")%>
    
    <table class="menu" width="100%" cellspacing="1" cellpadding="0">
        <%-- INVOICE TYPE --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("web.finance","invoicetype",sWebLanguage)%></td>
            <td class="admin2">
                <input type="radio" class="hand" id="FindTypePatient" name="FindInvoiceType" value="patient" checked="true"><%=getLabel("web","patient",sWebLanguage,"FindTypePatient")%>
                <input type="radio" class="hand" id="FindTypeInsurar" name="FindInvoiceType" value="insurar"><%=getLabel("web","insurar",sWebLanguage,"FindTypeInsurar")%>
                <input type="radio" class="hand" id="FindExtraInvoiceType" name="FindInvoiceType" value="extrainsurar"><%=getLabel("web","extrainsurar",sWebLanguage,"FindExtraInvoiceType")%>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2" colspan="4">
                <input type="button" class="button" name="ButtonSearch" value="<%=getTranNoLink("Web","searchprestation",sWebLanguage)%>" onclick="doFind()">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","clear",sWebLanguage)%>" onclick="clearSearchFields()">&nbsp;
                <input type="button" class="button" name="ButtonBack" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="doBack()">
            </td>
        </tr>
    </table>
</form>

<div id="resultsByAjax"><%-- Filled by Ajax --%></div>

<script>
  function doFind(){
    $("resultsByAjax").update("<div id='wait'>&nbsp;</div>");
    
    var url = "<c:url value='statistics/ajax/getToInvoiceList.jsp'/>?ts="+new Date();
    var params = $("searchForm").serialize();
    new Ajax.Updater("resultsByAjax",url,{
      evalScripts:true,
      method:'post',
      parameters: params,
      onComplete:function(){
        sortables_init();
      },
      onFailure:function(){
        $('resultsByAjax').innerHTML = "Problem with ajax request";
      }
    });
  }
  
  <%-- CLEAR SEARCHFIELDS --%>
  function clearSearchFields(){
	document.getElementById("FindTypePatient").checked = true;
	document.getElementById("FindTypeInsurar").checked = false;
	document.getElementById("FindExtraInvoiceType").checked = false;
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=statistics/index.jsp";
  }
</script>