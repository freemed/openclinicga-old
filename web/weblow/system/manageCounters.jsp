<%@page import="com.codestudio.util.SQLUtil,
                 com.codestudio.util.JDBCPool,
                be.openclinic.system.Counter,java.util.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%=checkPermission("system.management","all",activeUser)%>

<%
    String sFindDatabase = checkString(request.getParameter("FindDatabase"));
    String sEditName     = checkString(request.getParameter("EditName"));
    String sEditCounter  = checkString(request.getParameter("EditCounter"));
%>

<form name="transactionForm" method="post">
    <input type="hidden" name="EditName">
    <input type="hidden" name="EditCounter">
    <%=writeTableHeader("Web.manage","Counters",sWebLanguage,"main.do?Page=system/menu.jsp")%>
    <table border="0" width='100%' cellspacing="0" cellpadding="1" class="menu">
        <%-- DATABASE SELECT --%>
        <tr>
            <td width="<%=sTDAdminWidth%>">&nbsp;<%=getTran("Web.Manage.Counter","DB",sWebLanguage)%></td>
            <td>
                <select name="FindDatabase" class="text" onchange="transactionForm.submit();">
                <%
                    SortedSet set = new TreeSet();
                    SQLUtil sqlUtil = SQLUtil.getInstance();
                    Enumeration jdbcPools = sqlUtil.getAllPoolnames();

                    JDBCPool jdbcPool;
                    while (jdbcPools.hasMoreElements()) {
                        jdbcPool = sqlUtil.getPool((String) jdbcPools.nextElement());
                        set.add(jdbcPool.getPoolname());
                    }

                    // sort
                    Iterator it = set.iterator();
                    String sPool, sSelected;
                    while (it.hasNext()) {
                        sSelected = "";
                        sPool = (String) it.next();
                        if (sFindDatabase == null || sFindDatabase.length() == 0) {
                            sFindDatabase = sPool;
                        }

                        if (sPool.equals(sFindDatabase)) {
                            sSelected = " selected";
                        }

                %><option<%=sSelected%> name="<%=sPool%>"><%=sPool%></option><%
                    }
                %>
                </select>
            </td>
        </tr>
    </table>
    <br>
    <%-- SEARCH RESULTS --%>
    <table border="0" width='100%' cellspacing="1" cellpadding="1" class="list">
        <tr class="admin">
            <td colspan="2">&nbsp;<%=getTran("Web.Manage.Counter","counters",sWebLanguage)%></td>
        </tr>
        <%
            String sName, sCounter;
            int recCounter = 0;

            if (sEditName.length() > 0) {
                Counter objCounter = new Counter();
                objCounter.setCounter(Integer.parseInt(sEditCounter));
                objCounter.setName(sEditName);

                Counter.saveCounter(objCounter, sFindDatabase);
            }

            // select
            Vector vCounters = Counter.selectCounters(sFindDatabase);
            Iterator iter = vCounters.iterator();

            Counter objCounter = new Counter();

            while (iter.hasNext()) {
                objCounter = (Counter) iter.next();
                recCounter++;
                sName = objCounter.getName();
                sCounter = Integer.toString(objCounter.getCounter());
        %>
                <tr>
                    <td class="admin" width="200"><%=sName%>&nbsp;</td>
                    <td class="admin2" width="*">
                        <input type="text" class="text" name="Edit<%=sName%>" value="<%=sCounter%>">
                        <input type="button" class="button" name="Button<%=sName%>" value="<%=getTran("web","save",sWebLanguage)%>" onclick="doSubmit('<%=sName%>')">
                    </td>
                </tr>
                <%
            }
            // no records found
            if(recCounter==0){
                %>
                    <tr>
                        <td colspan="2"><%=getTran("web","norecordsfound",sWebLanguage)%></td>
                    </tr>
                <%
            }
        %>
    </table>
    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input class="button" type="button" name="cancel" value='<%=getTran("Web","Back",sWebLanguage)%>' onclick='window.location.href="<c:url value='/main.do'/>?Page=system/menu.jsp";'>
    <%=ScreenHelper.alignButtonsStop()%>
    <script>
      function doSubmit(name){
        transactionForm.EditName.value = name;
        transactionForm.EditCounter.value = eval("transactionForm.Edit"+name+".value");
        transactionForm.submit();
      }
    </script>
</form>