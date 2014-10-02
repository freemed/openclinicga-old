<%@ page import="java.util.*, java.sql.Date,be.openclinic.system.Transaction" %>
<%@page errorPage="/includes/error.jsp"%>
<%@ include file="/includes/validateUser.jsp"%>
<%=checkPermission("system.management","all",activeUser)%>
<%
    String sFindBegin = checkString(request.getParameter("FindBegin"));
    String sFindEnd = checkString(request.getParameter("FindEnd"));
    String sFindContext = checkString(request.getParameter("FindContext"));
%>
<form name="transactionForm" id="transactionForm" method="post">
    <%=writeTableHeader("Web.manage","MonitorServices",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <table width="100%" class="menu" cellspacing="1" onkeydown="if(enterEvent(event,13)){transactionForm.submit();}">
<%-- default context (departement) --%>
        <tr>
            <td width="<%=sTDAdminWidth%>"><%=getTran("Web.UserProfile","DefaultContext",sWebLanguage)%></td>
            <td>
                <select name='FindContext' class='text'>
                    <%
                        // list possible contexts from XML-file
                        String sDoc = MedwanQuery.getInstance().getConfigString("templateSource")+"contexts.xml";
                        if(sDoc.length()>0){
                            SAXReader reader = new SAXReader(false);
                            Document document = reader.read(new URL(sDoc));
                            Iterator elements = document.getRootElement().elementIterator("context");
                            Hashtable hServices = new Hashtable();
                            Element element;

                            while (elements.hasNext()){
                                element = (Element)elements.next();
                                hServices.put(getTran("Web.Occup",element.attribute("id").getValue(),sWebLanguage),element.attribute("id").getValue());
                            }
                            Vector keys = new Vector(hServices.keySet());
                            Collections.sort(keys);
                            Iterator it = keys.iterator();
                            String sKey, sID;
                            while (it.hasNext()) {
                                sKey = (String)it.next();
                                sID = (String)hServices.get(sKey);
                                out.print("<option value='"+sID+"' "+(sID.equalsIgnoreCase(sFindContext)?"selected":"")+"/>"+sKey);
                            }
                        }
                    %>
                </select>
            </td>
        </tr>
        <tr>
            <td><%=getTran("Web","Begin",sWebLanguage)%></td>
            <td><%=writeDateField("FindBegin","transactionForm",sFindBegin,sWebLanguage)%></td>
        </tr>
        <tr>
            <td><%=getTran("Web","End",sWebLanguage)%></td>
            <td><%=writeDateField("FindEnd","transactionForm",sFindEnd,sWebLanguage)%></td>
        </tr>
        <tr>
            <td/>
            <td>
                <input type="button" class="button" name="ButtonFind" value="<%=getTranNoLink("Web","Find",sWebLanguage)%>" onclick="transactionForm.submit()">&nbsp;
                <input type="button" class="button" name="ButtonClear" value="<%=getTranNoLink("Web","Clear",sWebLanguage)%>" onclick="clearFields()">&nbsp;
                <input type="button" class="button" name="ButtonCancel" value="<%=getTranNoLink("Web","back",sWebLanguage)%>" onclick="window.location.href='<c:url value='/main.do?Page=system/menu.jsp'/>'">
            </td>
        </tr>
    </table>
    <script>
        transactionForm.FindBegin.focus();

        function clearFields(){
            transactionForm.FindBegin.value="";
            transactionForm.FindEnd.value="";
            transactionForm.FindBegin.focus();
        }
    </script>
</form>
<%
    if (((sFindBegin.trim().length()>0)||(sFindEnd.trim().length()>0))&&(sFindContext.length()>0)){
            java.util.Hashtable hAccess = new Hashtable();
            Integer iTotal;
            Date dAccess;
            Vector vTempUserIds = UserParameter.getUserIds("defaultcontext",sFindContext);
            Iterator iter = vTempUserIds.iterator();

            Vector vUserIDs = new Vector();
            while(iter.hasNext()){
                vUserIDs.add(iter.next());
            }

            int iCounter = 0;
            if (sFindBegin.length()==0){
                sFindBegin = "1/1/2000";
            }

            if (sFindEnd.length()==0){
                sFindEnd = getDate();
            }

            sFindEnd = ScreenHelper.getDateAdd(sFindEnd, "2");

            java.sql.Date dBegin = ScreenHelper.getSQLDate(sFindBegin);
            java.sql.Date dEnd = ScreenHelper.getSQLDate(sFindEnd);

            Vector vAccessLogs;
            for (int i = 0; i < vUserIDs.size(); i++) {
                vAccessLogs = AccessLog.getAccessTimes(dBegin,dEnd,Integer.parseInt((String) vUserIDs.elementAt(i)));
                Iterator iterAccesLog = vAccessLogs.iterator();
                while(iterAccesLog.hasNext()){
                    dAccess = (Date)iterAccesLog.next();
                    iTotal = (Integer)hAccess.get(dAccess);
                    if (iTotal==null){
                        hAccess.put(dAccess,new Integer("1"));
                    }
                    else {
                        hAccess.put(dAccess, new Integer(iTotal.intValue()+1));
                    }
                }
            }
        %>
        <table class="list" cellspacing="0" width="100%">
            <tr><td class="titleadmin" colspan="3"><%=getTran("Web.Manage","MonitorAccess",sWebLanguage)%></td></tr>
            <tr class="admin">
                <td width="100"><%=getTran("Web","date",sWebLanguage)%></td>
                <td width="100" align="right"><%=getTran("Web","total",sWebLanguage)%></td>
                <td/>
            </tr>
            <%
                Vector keys = new Vector(hAccess.keySet());
                Collections.sort(keys);
                Iterator it = keys.iterator();

                String sDate, sClass = "";
                while (it.hasNext()) {
                    dAccess = (Date)it.next();
                    sDate = ScreenHelper.getSQLDate(dAccess);
                    iTotal = (Integer) hAccess.get(dAccess);
                    iCounter += iTotal.intValue();

                    if (sClass.equals("")){
                        sClass = "1";
                    }
                    else {
                        sClass = "";
                    }
                    out.print("<tr class='list"+sClass+"'><td>"+sDate+"</td><td align='right'>"+iTotal.intValue()+"</td><td/></tr>");
                }
            %>
        </table>
        <%=getTran("Web.Occup","total-number",sWebLanguage)%>: <%=iCounter%>
        <%
        iCounter = 0;
        hAccess = new Hashtable();

        Vector vAdminPersons;
        for (int i = 0; i < vUserIDs.size(); i++) {
            vAdminPersons = AdminPerson.getUpdateTimes(dBegin,dEnd,Integer.parseInt((String)vUserIDs.elementAt(i)));
            Iterator iterAdminPerson = vAdminPersons.iterator();
            while(iterAdminPerson.hasNext()){
                dAccess = (Date)iterAdminPerson.next();
                iTotal = (Integer)hAccess.get(dAccess);

                if (iTotal==null){
                    hAccess.put(dAccess,new Integer("1"));
                }
                else {
                    hAccess.put(dAccess, new Integer(iTotal.intValue()+1));
                }
            }
        }
        %>
        <br/><br/>
        <table class="list" cellspacing="0" width="100%">
            <tr><td class="titleadmin" colspan="3"><%=getTran("Web.Manage","updatedpatients",sWebLanguage)%></td></tr>
            <tr class="admin">
                <td width="100"><%=getTran("Web","date",sWebLanguage)%></td>
                <td width="100" align="right"><%=getTran("Web","total",sWebLanguage)%></td>
                <td/>
            </tr>
            <%
                keys = new Vector(hAccess.keySet());
                Collections.sort(keys);
                it = keys.iterator();

                while (it.hasNext()) {
                    dAccess = (Date)it.next();
                    sDate = ScreenHelper.getSQLDate(dAccess);
                    iTotal = (Integer) hAccess.get(dAccess);
                    iCounter += iTotal.intValue();

                    if (sClass.equals("")){
                        sClass = "1";
                    }
                    else {
                        sClass = "";
                    }
                    out.print("<tr class='list"+sClass+"'><td>"+sDate+"</td><td align='right'>"+iTotal.intValue()+"</td><td/></tr>");
                }
            %>
        </table>
        <%=getTran("Web.Occup","total-number",sWebLanguage)%>: <%=iCounter%>
        <%
            iCounter = 0;
            hAccess = new Hashtable();
            Vector vTransactions;
            for (int i = 0; i < vUserIDs.size(); i++) {
                vTransactions = Transaction.getUpdateTimes(dBegin,dEnd,Integer.parseInt((String) vUserIDs.elementAt(i)));
                Iterator iterTransaction = vTransactions.iterator();
                while(iterTransaction.hasNext()){
                    dAccess = (Date)iterTransaction.next();
                    iTotal = (Integer) hAccess.get(dAccess);

                    if (iTotal == null) {
                        hAccess.put(dAccess, new Integer("1"));
                    } else {
                        hAccess.put(dAccess, new Integer(iTotal.intValue() + 1));
                    }
                }
            }
        %>
        <br/><br/>
        <table class="list" cellspacing="0" width="100%">
            <tr><td class="titleadmin" colspan="3"><%=getTran("Web.Manage","updatedconsultations",sWebLanguage)%></td></tr>
            <tr class="admin">
                <td width="100"><%=getTran("Web","date",sWebLanguage)%></td>
                <td width="100" align="right"><%=getTran("Web","total",sWebLanguage)%></td>
                <td/>
            </tr>
            <%
                keys = new Vector(hAccess.keySet());
                Collections.sort(keys);
                it = keys.iterator();

                while (it.hasNext()) {
                    dAccess = (Date)it.next();
                    sDate = ScreenHelper.getSQLDate(dAccess);
                    iTotal = (Integer) hAccess.get(dAccess);
                    iCounter += iTotal.intValue();

                    if (sClass.equals("")){
                        sClass = "1";
                    }
                    else {
                        sClass = "";
                    }
                    out.print("<tr class='list"+sClass+"'><td>"+sDate+"</td><td align='right'>"+iTotal.intValue()+"</td><td/></tr>");
                }
            %>
        </table>
        <%=getTran("Web.Occup","total-number",sWebLanguage)%>: <%=iCounter%>
<%
    }
%>