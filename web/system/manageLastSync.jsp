<%@page import="be.mxs.common.util.db.MedwanQuery,
                be.mxs.common.util.system.*,
                be.openclinic.system.Server,
                be.openclinic.system.Config,java.util.Calendar,java.util.Vector,java.util.Enumeration" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%!
    public String getServerNr(String sKey) {
        String sServerNr = "";

        if (sKey.toLowerCase().startsWith("lastsync.")) {
            sServerNr = sKey.substring(sKey.indexOf(".") + 1);
        }
        return sServerNr;
    }

    public String getServerName(String sServerNr) {
        String sServerName = "";
        sServerName = Server.getServerNameByServerId(sServerNr);

        return sServerName;
    }

    public Date parseDate(String sDate) {
        int iYear = 0,
                iMonth = 0,
                iDay = 0,
                iHour = 0,
                iMin = 0,
                iSec = 0,
                iMillisec = 0;

        if (sDate == null || sDate.length() < 8) {
            return null;
        } else {
            iYear = Integer.parseInt(sDate.substring(0, 4));
            iMonth = Integer.parseInt(sDate.substring(4, 6));
            iDay = Integer.parseInt(sDate.substring(6, 8));
            if (sDate.length() >= 10) {
                iHour = Integer.parseInt(sDate.substring(8, 10));
            }
            if (sDate.length() >= 12) {
                iMin = Integer.parseInt(sDate.substring(10, 12));
            }
            if (sDate.length() >= 14) {
                iSec = Integer.parseInt(sDate.substring(12, 14));
            }
            if (sDate.length() > 14) {
                iMillisec = Integer.parseInt(sDate.substring(14, sDate.length()));
            }

            /*Debug.println("Year:     " + iYear);
            Debug.println("Month:    " + iMonth);
            Debug.println("Day:      " + iDay);
            Debug.println("Hour:     " + iHour);
            Debug.println("Min:      " + iMin);
            Debug.println("Sec:      " + iSec);
            Debug.println("Millisec: " + iMillisec);*/

            Calendar cDate = Calendar.getInstance();
            cDate.setTimeInMillis(0);
            cDate.set(iYear, iMonth - 1, iDay, iHour, iMin, iSec);

            java.sql.Date dDate = new java.sql.Date(cDate.getTimeInMillis() + iMillisec);
            return dDate;
        }
    }

    public int getDaysPassed(Date parsedDate) {
        int iDiffDays;

        long lBetween = ScreenHelper.getSQLDate(getDate()).getTime() - parsedDate.getTime();
        lBetween = (lBetween / 1000 / 3600 / 24);
        iDiffDays = new Long(lBetween).intValue();
        return iDiffDays;
    }

    public Vector getUsers(String sServerNr, Connection dbConnection) {
        Vector vUsers = new Vector();
        vUsers = Server.getServerUsers(sServerNr);

        return vUsers;
    }

    public void sendToEmailAddresses(String sServerNr, Connection dbConnection, String sSubject, StringBuffer sMessage) {
        Debug.println("Email addresses for server: " + sServerNr);

        Vector vEmails = new Vector();
        Iterator iter = vEmails.iterator();
        String sEmail = "";
        while (iter.hasNext()) {
            sEmail = (String) iter.next();
            Debug.println("Email: " + sEmail);
            //Debug.println("SENDING EMAIL ......");
            sendEmail(sServerNr, sEmail, sSubject, sMessage);
        }
    }

    private void sendEmail(String sServerNr, String sEmail, String sSubject, StringBuffer sMessage) {
        String sMailServer = MedwanQuery.getInstance().getConfigString("DefaultMailServerAddress"), sMailFrom = MedwanQuery.getInstance().getConfigString("DefaultFromMailAddress"), sMailTo = sEmail;

        try {
            Mail.sendMail(sMailServer, sMailFrom, sMailTo, sSubject, sMessage.toString().replaceAll("&&", sServerNr));
            //Debug.println(sMessage.toString().replaceAll("&&",sServerNr));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
%>

<%
    String sIsMail = checkString(request.getParameter("isMail"));

    if (sIsMail.equals("true")) {
        Enumeration enum = request.getParameterNames();
        String sParameter;
        while (enum.hasMoreElements()) {
            sParameter = (String) enum.nextElement();
            Debug.println("Parameter: " + sParameter);
            if (sParameter.startsWith("server")) {
              	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                sendToEmailAddresses(checkString(request.getParameter(sParameter)), ad_conn, getTran("Web.Manage.lastsync", "mailsubject", sWebLanguage), new StringBuffer(getTran("Web.Manage.lastsync", "mailmessage", sWebLanguage)));
                ad_conn.close();
            }
        }
    }

%>
<%=writeTableHeader("Web.manage","ManageLastSync",sWebLanguage,"main.do?Page=system/menu.jsp")%>
<form name="MailLastSyncForm" method="POST" action='<c:url value="/main.do"/>?Page=system/manageLastSync.jsp'>
    <table width='100%' align='center' cellspacing="0" class="list">
        <tr class="admin">
          <td>
            <input class='button' type="button" name="select_button" value="<%=getTranNoLink("web","selectall",sWebLanguage)%>" onclick="selectAll('MailLastSyncForm','checked');">&nbsp;
            <input class='button' type="button" name="deselect_button" value="<%=getTranNoLink("web","deselectall",sWebLanguage)%>" onclick="deselectAll('MailLastSyncForm','');">
          </td>
          <td><%=getTran("Web.Manage.lastsync","ServerNumber",sWebLanguage)%></td>
          <td><%=getTran("Web.Manage.lastsync","ServerName",sWebLanguage)%></td>
          <td><%=getTran("Web.Manage.lastsync","LastSyncTime",sWebLanguage)%></td>
          <td><%=getTran("Web.Manage.lastsync","Number_of_days_passed",sWebLanguage)%></td>
          <td><%=getTran("Web.Manage.lastsync","Users",sWebLanguage)%></td>
        </tr>
    <%
        Vector vConfigs = new Vector();
        vConfigs = Config.getLastSyncConfigs();
        Iterator iter = vConfigs.iterator();

        Config objConfig;

        String sServerNr = "", sServerName = "", sLastSyncTime = "", sKey = "", sValue = "";
        int iDaysPassed = 0;
        Vector vUsers;

        //String[] sTest = {"lastSync.122","lastSync.1","lastSync.001","lastSync"};
        //String[] sTest2 = {"20060819125345005","20060815142545587","20060812031243756","20060820001216777"};

        String sClass = "list", sTmp = "";

        //for(int i = 0; i < sTest.length; i++){
        while (iter.hasNext()) {
            objConfig = (Config) iter.next();
            sKey = objConfig.getOc_key();
            sValue = objConfig.getOc_value().toString();

            if (sKey.toLowerCase().startsWith("lastsync.") && sKey.length() > 9 && sValue.length() > 0) {
                if (sClass.equals("list")) {
                    sClass = "list1";
                } else {
                    sClass = "list";
                }
                /*---------------- Column 1 => Checkboxes----------------*/

                /*---------------- Column 2 => Server Number-------------*/
                sServerNr = getServerNr(sKey);

                /*--------------- Column 3 => Server Name ---------------*/
                sServerName = getServerName(sServerNr);

                /*-------------- Column 4 => Last Sync Time -------------*/
                sLastSyncTime = sValue;

                /*---------- Column 5 => Days Passed Since Sync ---------*/
                String sParsedDate = "";
                if (sLastSyncTime.length() > 0) {
                    Date parsedDate = parseDate(sLastSyncTime);
                    sParsedDate = new SimpleDateFormat("yyyy-MM-dd H:m:s S").format(parsedDate);
                    iDaysPassed = getDaysPassed(parsedDate);

                    sTmp = sClass;
                    if (iDaysPassed > MedwanQuery.getInstance().getConfigInt("lastSyncLimit", 10)) {
                        sClass = "red";
                    }
                }

                /*------ Column 6 => Users For This (Server)Number ------*/
		      	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                vUsers = getUsers(sServerNr, ad_conn);
                ad_conn.close();
    %>
                    <tr class='<%=sClass%>'>
                        <td>
                            <%
                                if(sClass.equals("red") && vUsers.size() > 0){
                                    %>
                                    <input type="checkbox" name="server<%=sServerNr%>" value='<%=sServerNr%>'></td>
                                    <%
                                }
                            %>
                        <td><%=checkString(sServerNr)%></td>
                        <td><%=checkString(sServerName)%></td>
                        <td><%=sParsedDate + "ms"%></td>
                        <td><%=iDaysPassed%></td>
                        <td>
                            <%
                                Iterator iter2 = vUsers.iterator();
                                String sUser = "";
                                while(iter2.hasNext()){
                                    sUser = (String)iter2.next();
                                    out.print(sUser + "<br>");
                                }
                            %>
                        </td>
                    </tr>
                <%
                sClass = sTmp;
            }
        }
    %>
    <input type='hidden' name='isMail' value=''>
    </table>
    <%-- BUTTONS -------------------------------------------------------------------------------------%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class='button' type="button" name="Mailbutton" value='<%=getTranNoLink("Web","send_email",sWebLanguage)%>' onclick="doMail();">&nbsp;
        <input class='button' type="button" name="Backbutton" value='<%=getTranNoLink("Web","Back",sWebLanguage)%>' onclick="doBack();">
    <%=ScreenHelper.alignButtonsStop()%>
</form>
<script>
    function doBack(){
        window.location.href = '<c:url value='/main.do'/>?Page=system/menu.jsp';
    }

    function doMail(){
        MailLastSyncForm.isMail.value = 'true';
        MailLastSyncForm.Mailbutton.disabled = true;
        MailLastSyncForm.submit();
    }

    function selectAll(FormName, CheckValue){
        for(i = 0; i < document.forms[FormName].elements.length; i++) {
            elm = document.forms[FormName].elements[i]

            if (elm.type == 'checkbox') {
                    elm.checked = CheckValue
            }
        }
    }

    function deselectAll(FormName, CheckValue){
        for(i = 0; i < document.forms[FormName].elements.length; i++) {
            elm = document.forms[FormName].elements[i]

            if (elm.type == 'checkbox') {
                    elm.checked = CheckValue
            }
        }
    }
</script>