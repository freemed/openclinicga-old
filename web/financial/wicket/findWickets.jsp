<%@page import="be.openclinic.finance.Wicket"%>
<%@page import="java.util.Vector"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("financial.wicket","select",activeUser)%>

<form name="FindWicketForm" method="POST" action="<c:url value='/main.do'/>?Page=financial/wicket/wicketOverview.jsp&ts=<%=getTs()%>">
    <%=writeTableHeader("wicket","wicketoverview",sWebLanguage," doBack();")%>
    
    <table class='list' border='0' width='100%' cellspacing='1'>
        <%-- wicket --%>
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("wicket","wicket",sWebLanguage)%></td>
            <td class='admin2'>
                <select class="text" name="WicketUID">
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
                    <%
                        Vector vWickets = new Vector();
                        vWickets = Wicket.selectWickets();
                        Iterator iter = vWickets.iterator();
                        Wicket wicket;
                        while(iter.hasNext()){
                            wicket = (Wicket)iter.next();
                            
                            %><option value="<%=wicket.getUid()%>"><%=wicket.getUid()%>&nbsp;<%=getTranNoLink("service",wicket.getServiceUID(),sWebLanguage)%></option><%
                        }
                    %>
                </select>
                
                <input class='button' type='button' name='buttonfind' value='<%=getTranNoLink("Web","view",sWebLanguage)%>' onclick='doFind();'>
                <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
            </td>
        </tr>

        <input type='hidden' name='Action' value=''>
    </table>
</form>

<script>
  function doFind(){
    if(FindWicketForm.WicketUID.value!=""){
      FindWicketForm.Action.value = "SEARCH";
      FindWicketForm.buttonfind.disabled = true;
      FindWicketForm.submit();
    }
  }

  function doBack(){
    window.location.href="<c:url value='/main.do'/>?Page=financial/index.jsp&ts=<%=getTs()%>";
  }

  function doSearchBack(){
    window.location.href="<c:url value='/main.do'/>?Page=financial/index.jsp&ts=<%=getTs()%>";
  }
</script>