<%@ page import="be.openclinic.medical.AnesthesieControl, java.util.Vector" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=checkPermission("controlanesthesie","select",activeUser)%>
<%
    String sFindBegin = checkString(request.getParameter("FindBegin"));
    String sFindEnd = checkString(request.getParameter("FindEnd"));
%>
<form name="transactionForm" method="post">
    <%=writeTableHeader("Web","controlanesthesie",sWebLanguage,"main.do?Page=medical/controlAnesthesieEdit.jsp")%>
    <table width="100%" class="list" cellspacing="1" onkeydown="if(enterEvent(event,13)){transactionForm.submit();}">
        <tr>
            <td class="admin2" width="<%=sTDAdminWidth%>"><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        <tr>
            <td class="admin2"><%=getTran("Web","End",sWebLanguage)%></td>
            <td class="admin2"><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        <%=ScreenHelper.setSearchFormButtonsStart()%>
            <input type="button" class="button" name="ButtonFind" value="<%=getTran("Web","Find",sWebLanguage)%>" onclick="transactionForm.submit()">&nbsp;
            <input type="button" class="button" name="ButtonClear" value="<%=getTran("Web","Clear",sWebLanguage)%>" onclick="clearFields()">&nbsp;
            <input type="button" class="button" name="ButtonNew" value="<%=getTran("Web","New",sWebLanguage)%>" onclick="doNew()">&nbsp;
        <%=ScreenHelper.setSearchFormButtonsStop()%>
    </table>
    <script>
        transactionForm.FindBegin.focus();

        function clearFields(){
            transactionForm.FindBegin.value="";
            transactionForm.FindEnd.value="";
            transactionForm.FindBegin.focus();
        }

        function doNew(){
            window.location.href = "<c:url value='/main.do'/>?Page=medical/controlAnesthesieEdit.jsp&ts=<%=getTs()%>";
        }
    </script>
</form>
<%
    if ((sFindBegin.trim().length()>0)||(sFindEnd.trim().length()>0)){
        %>
        <%=sJSSORTTABLE%>
        <table cellspacing="0" width="100%" class="sortable" id="searchresults">
            <tr class="admin">
                <td width="100"><%=getTran("Web.Occup","medwan.common.date",sWebLanguage)%></td>
                <td><%=getTran("openclinic.chuk","control_performed_by",sWebLanguage)%></td>
            </tr>
            <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
        <%
            String sClass = "", sDate, sControlName, sControlID;

            int iCounter = 0;

            Vector vACs = AnesthesieControl.searchAnesthesieControls(sFindBegin, sFindEnd);
            Iterator iter = vACs.iterator();
            AnesthesieControl ac;
            while (iter.hasNext()) {
                iCounter++;

                ac = (AnesthesieControl) iter.next();
                sDate = ScreenHelper.getSQLDate(ac.getDate());
                sControlID = ac.getControlPerformedById();

                if (sControlID.length()>0){
                   	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                    sControlName = ScreenHelper.getFullUserName(sControlID,ad_conn);
                    ad_conn.close();
                }
                else {
                    sControlName = "";
                }

                if (sClass.equals("")) {
                    sClass = "1";
                } else {
                    sClass = "";
                }
        %>
                <tr class='list<%=sClass%>'  onclick="doOpen('<%=ac.getUid()%>')">
                    <td><%=sDate%></td><td><%=sControlName%></td></tr>
            <%
        }

        %>
            </tbody>
        </table>
        <%=getTran("Web.Occup","total-number",sWebLanguage)%>: <%=iCounter%>
        <script>
            function doOpen(sID){
                window.location.href= "<c:url value='/main.do'/>?Page=medical/controlAnesthesieEdit.jsp&EditUID="+sID+"&View=true&ts=<%=getTs()%>";
            }
        </script>
        <%
    }
%>