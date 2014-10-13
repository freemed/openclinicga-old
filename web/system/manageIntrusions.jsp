<%@ page import="net.admin.system.IntrusionAttempt,java.util.Enumeration,java.util.Vector" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.management","all",activeUser)%>
<%!
    //--- GET REMAINING DURATION STRING -----------------------------------------------------------
    private String getRemainingDurationString(Timestamp releaseTime){
        Timestamp currentTime = new Timestamp((new java.util.Date()).getTime());
        int remainingSeconds = (int)((releaseTime.getTime() - currentTime.getTime())/1000);

        String remainingDuration = "";
        if(remainingSeconds > 0){
            int days  = remainingSeconds/(24*3600);
            remainingSeconds = remainingSeconds%(24*3600);
            if(days > 0) remainingDuration+= days+" day(s) ";

            int hours = remainingSeconds/3600;
            remainingSeconds = remainingSeconds%3600;
            if(hours > 0) remainingDuration+= hours+" hour(s) ";

            int remainingMinutes = remainingSeconds/60;
            remainingSeconds = remainingSeconds%60;
            if(remainingMinutes > 0) remainingDuration+= remainingMinutes+" minute(s) ";

            if(remainingSeconds > 0) remainingDuration+= remainingSeconds+" second(s)";
        }

        return remainingDuration;
    }
%>

<%
    String unblockCode = "";
    StringBuffer sOutLogins, sOutIPs;

    String sAction = checkString(request.getParameter("Action"));
    String requestId = checkString(request.getParameter("requestId"));

    //--- SAVE ------------------------------------------------------------------------------------
    if (sAction.equals("save")) {
        String sIntruderID, sIntrusionCount, sBlocked;

        Enumeration e = request.getParameterNames();
        String sParameterName, sParameterValue;

        IntrusionAttempt objIA = new IntrusionAttempt();

        while (e.hasMoreElements()) {
            sParameterName = (String) e.nextElement();
            if (sParameterName.startsWith("EditIntruderID_")) {
                sParameterValue = sParameterName.substring(sParameterName.indexOf("_") + 1);
                sIntruderID = checkString(request.getParameter("EditIntruderID_" + sParameterValue));
                sIntrusionCount = checkString(request.getParameter("EditIntrusionCount_" + sParameterValue));
                sBlocked = checkString(request.getParameter("EditBlocked_" + sParameterValue));

                objIA.setIntrusionCount(Integer.parseInt(sIntrusionCount));
                objIA.setBlocked((sBlocked.length() > 0 ? sBlocked : "0"));
                objIA.setIntruderID(sIntruderID);

                IntrusionAttempt.saveIntrusionAttempt(objIA);
            }
        }

        //if(ps!=null) ps.close();
    }
    //--- DELETE ----------------------------------------------------------------------------------
    if (sAction.equals("delete")) {
        String sIntruderID = checkString(request.getParameter("DelIntruderID"));
        IntrusionAttempt.deleteIntrusionAttempt(sIntruderID);
    }
    //--- GENERATE UNBLOCK CODE -------------------------------------------------------------------
    else if (sAction.equals("generate")) {
        int id = Integer.parseInt(requestId);
        unblockCode = "" + (int) ((Math.floor(((id % 97) / 5.25) * (id / 525)) % 7871));
    }

    //--- DISPLAY ALL INTRUSIONS ------------------------------------------------------------------
    sOutLogins = new StringBuffer();
    sOutIPs = new StringBuffer();
    String sIntruderID, sClass = "";
    SimpleDateFormat fullDateFormat = ScreenHelper.fullDateFormatSS;
    Timestamp releaseTime;
    int recCounter = 0;

    //*** all login-intrusions ***
    /*
    // all known intruders
    sSelect = "SELECT i.* FROM PORTAL_INTRUSIONATTEMPTS i, PORTAL_USERS u"+
              " WHERE i.PORTAL_INTRUDERID = CONVERT(varchar(16),u.PORTAL_USERID)"+
              " ORDER BY i.PORTAL_INTRUDERID";
    */

    // all non-ip intrusions
    /*
    sSelect = "SELECT * FROM intrusionAttempts"+
              " WHERE intruderID NOT LIKE '%.%.%.%'"+
              " ORDER BY intruderID";
    */

    Vector vNonIpIntrusions = IntrusionAttempt.selectNonIPIntrusionAttempts();
    Iterator iter = vNonIpIntrusions.iterator();
    IntrusionAttempt objIA;

    while (iter.hasNext()) {
        objIA = (IntrusionAttempt) iter.next();
        recCounter++;

        sIntruderID = objIA.getIntruderID();
        releaseTime = objIA.getReleaseTime();

        // alternate row-styles
        if (sClass.equals("")) sClass = "1";
        else sClass = "";

        sOutLogins.append("<input type='hidden' name='EditIntruderID_" + recCounter + "' value='" + sIntruderID + "'>");
        sOutLogins.append("<tr class='list" + sClass + "'>")
                .append("<td>")
                .append("<a href=\"javascript:doDelete('" + sIntruderID + "');\">")
                .append("<img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt='" + getTran("Web", "delete", sWebLanguage) + "' border='0'>")
                .append("</a>")
                .append("</td>")
                .append("<td>" + sIntruderID + "</td>")
                .append("<td><input type='text' class='text' size='5' name='EditIntrusionCount_" + recCounter + "' value='" + objIA.getIntrusionCount() + "' onBlur='isNumber(this);'></td>")
                .append("<td><input type='checkbox' name='EditBlocked_" + recCounter + "' value='1' " + (objIA.getBlocked().equals("1") ? "checked" : "") + "></td>")
                .append("<td>" + (releaseTime == null ? "" : fullDateFormat.format(releaseTime)) + "</td>");

        String remainingDuration = "";
        if (releaseTime != null) {
            remainingDuration = getRemainingDurationString(releaseTime);
        }

        sOutLogins.append("<td>&nbsp;" + remainingDuration + "</td>")
                .append("</tr>");
    }

    //*** all ip-intrusions ***
    sClass = "";

    /*
    // all unknown intruders
    sSelect = "SELECT * FROM intrusionAttempts i"+
              " WHERE i.intruderID NOT IN("+
              "  SELECT CONVERT(varchar(16),userid) FROM Users"+
              " )"+
              " ORDER BY intruderID";
    */

    // all ip-addresses
    /*
    sSelect = "SELECT * FROM intrusionAttempts"+
              " WHERE intruderID LIKE '%.%.%.%'"+
              " ORDER BY intruderID";
    */
    Vector vIPIntrusions = IntrusionAttempt.selectIPIntrusionAttempts();
    Iterator iter2 = vIPIntrusions.iterator();

    IntrusionAttempt objIA2;

    while (iter2.hasNext()) {
        objIA2 = (IntrusionAttempt) iter2.next();

        recCounter++;

        sIntruderID = objIA2.getIntruderID();
        releaseTime = objIA2.getReleaseTime();

        // alternate row-styles
        if (sClass.equals("")) sClass = "1";
        else sClass = "";

        sOutIPs.append("<input type='hidden' name='EditIntruderID_" + recCounter + "' value='" + sIntruderID + "'>");
        sOutIPs.append("<tr class='list" + sClass + "'>")
                .append("<td>")
                .append("<a href=\"javascript:doDelete('" + sIntruderID + "');\">")
                .append("<img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.gif' alt='" + getTran("Web", "delete", sWebLanguage) + "' border='0'>")
                .append("</a>")
                .append("</td>")
                .append("<td>" + sIntruderID + "</td>")
                .append("<td><input type='text' class='text' size='5' name='EditIntrusionCount_" + recCounter + "' value='" + objIA2.getIntrusionCount() + "' onBlur='isNumber(this);'></td>")
                .append("<td><input type='checkbox' name='EditBlocked_" + recCounter + "' value='1' " + (objIA2.getBlocked().equals("1") ? "checked" : "") + "></td>")
                .append("<td>" + (releaseTime == null ? "" : ScreenHelper.fullDateFormatSS.format(releaseTime)) + "</td>");

        String remainingDuration = "";
        if (releaseTime != null) {
            remainingDuration = getRemainingDurationString(releaseTime);
        }

        sOutIPs.append("<td>&nbsp;" + remainingDuration + "</td>")
                .append("</tr>");
    }
%>
<form name='transactionForm' method='post'>
    <input type="hidden" name="Action">
    <input type="hidden" name="DelIntruderID">
    <%=writeTableHeader("Web.manage","intrusionmanagement",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <%-- LIST INTRUSIONS ------------------------------------------------------------------------%>
    <table width='100%' class="list" cellspacing="1" cellpadding="0">
        <%-- LOGINS-HEADER --%>
        <tr height="18">
            <td class="titleadmin" width="27">&nbsp;</td>
            <td class="titleadmin" width="150" nowrap>&nbsp;<%=getTran("web.manage","loginIntrusion",sWebLanguage)%></td>
            <td class="titleadmin" width="100" nowrap>&nbsp;<%=getTran("web.manage","intrusionCount",sWebLanguage)%></td>
            <td class="titleadmin" width="150" nowrap>&nbsp;<%=getTran("web.manage","permanentlyBlocked",sWebLanguage)%></td>
            <td class="titleadmin" width="150" nowrap>&nbsp;<%=getTran("web.manage","releasetime",sWebLanguage)%></td>
            <td class="titleadmin" width="500">&nbsp;<%=getTran("web.manage","remainingBlockTime",sWebLanguage)%></td>
        </tr>
        <%
            if(sOutLogins.length() > 0){
                %><%=sOutLogins%><%
            }
            else{
                // no records found
                %>
                    <tr>
                        <td>&nbsp;<%=getTran("web","norecordsfound",sWebLanguage)%></td>
                    </tr>
                <%
            }
        %>
    </table>
    <br>
    <table width='100%' class="list" cellspacing="1" cellpadding="0">
        <%-- IPs-HEADER --%>
        <tr height="18">
            <td class="titleadmin" width="27">&nbsp;</td>
            <td class="titleadmin" width="150" nowrap>&nbsp;<%=getTran("web.manage","ipIntrusion",sWebLanguage)%></td>
            <td class="titleadmin" width="100" nowrap>&nbsp;<%=getTran("web.manage","intrusionCount",sWebLanguage)%></td>
            <td class="titleadmin" width="150" nowrap>&nbsp;<%=getTran("web.manage","permanentlyBlocked",sWebLanguage)%></td>
            <td class="titleadmin" width="150" nowrap>&nbsp;<%=getTran("web.manage","releasetime",sWebLanguage)%></td>
            <td class="titleadmin" width="500">&nbsp;<%=getTran("web.manage","remainingBlockTime",sWebLanguage)%></td>
        </tr>
        <%
            if(sOutIPs.length() > 0){
                %><%=sOutIPs%><%
            }
            else{
                // no records found
                %>
                    <tr>
                        <td>&nbsp;<%=getTran("web","norecordsfound",sWebLanguage)%></td>
                    </tr>
                <%
            }
        %>
    </table>
    <br>
    <%=writeTableHeader("Web.manage","generateunblockcode",sWebLanguage," doBack();")%>
    <table width='100%' class="list" cellspacing="1" cellpadding="0">
        <%-- REQUEST ID --%>
        <tr>
            <td class="admin" width="<%=sTDAdminWidth%>"><%=getTran("Web.manage","unblockrequestid",sWebLanguage)%></td>
            <td class="admin2">
                <input class='text' type='text' name='requestId' size='20' maxLength='9' value='<%=requestId%>' onBlur="isNumber(this);"/>
            </td>
        </tr>
        <%-- UNBLOCK CODE --%>
        <tr>
            <td class="admin"><%=getTran("Web.manage","unblockcode",sWebLanguage)%></td>
            <td class="admin2">
                <input class='text' type='text' name='unblockCode' size='20' maxLength='4' value='<%=unblockCode%>' READONLY/>
            </td>
        </tr>
        <%-- BUTTONS ---------------------------------------------------------------------------------%>
        <%=ScreenHelper.setFormButtonsStart()%>
            <input type='button' class="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onClick="doSave();">
            <input type='button' class="button" name="reloadButton" value='<%=getTranNoLink("Web","reload",sWebLanguage)%>' onClick="doReload();">
            <input type='button' class="button" name='generateButton' value='<%=getTranNoLink("Web.manage","generate",sWebLanguage)%>' onClick="doGenerate();">
            <input type='button' class="button" name='cancelButton' value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onClick="doBack();">
        <%=ScreenHelper.setFormButtonsStop()%>
    </table>
    <script>
      <%-- DO SAVE --%>
      function doSave(){
        transactionForm.Action.value = "save";
        transactionForm.saveButton.disabled = true;
        transactionForm.submit();
      }

      <%-- DO DELETE --%>
      function doDelete(id){
        transactionForm.Action.value = "delete";
        transactionForm.DelIntruderID.value = id;
        transactionForm.submit();
      }

      <%-- DO RELOAD --%>
      function doReload(){
        window.location.href = "<c:url value='/main.do'/>?Page=system/manageIntrusions.jsp";
      }

      <%-- DO BACk --%>
      function doBack(){
        window.location.href = "<c:url value='/main.do'/>?Page=system/menu.jsp";
      }

      <%-- DO GENERATE --%>
      function doGenerate(){
        if(transactionForm.requestId.value.length > 0){
          transactionForm.Action.value = "generate";
          transactionForm.generateButton.disabled = true;
          transactionForm.submit();
        }
        else{
          alertDialog("web.manage","datamissing");

          if(transactionForm.requestId.value.length==0){
             transactionForm.requestId.focus();
          }
        }
      }
    </script>
</form>