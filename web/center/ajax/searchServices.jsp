<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="be.openclinic.system.Center" %>
<%@ page import="java.util.*" %>
<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@include file="/includes/validateUser.jsp" %>
<%String sFindBegin = checkString(request.getParameter("FindBegin"));
    String sFindEnd = checkString(request.getParameter("FindEnd"));%>
<table width='100%' onmouseover="this.style.cursor= 'pointer';" onmouseover="this.style.cursor= 'default';" cellspacing='1' class="sortable" id="searchresults">
    <tr height='20' class='admin'>
        <td width="100"><%=getTran("web", "version", sWebLanguage)%></td>
        <td width="150"><%=getTran("web", "updatetime", sWebLanguage)%></td>
        <td width="150"><%=getTran("wicket", "create_date", sWebLanguage)%></td>
        <td><%=getTran("web", "user", sWebLanguage)%></td>
    </tr>
    <%int i = 0;
        List l = (Center.getAll(sFindBegin, sFindEnd, true));
        l.addAll(Center.getAll(sFindBegin, sFindEnd, false));
        Iterator it = l.iterator();
        Center c;
        while (it.hasNext()) {
            c = (Center) it.next(); %>
    <tr  <%if (c.isActual()) {
        out.write("class='green' onmouseout=\"this.className='green';\" onmouseover=\"this.className='list_select';\"");
    } else if ((i % 2) == 0) {
        out.write("class='list' onmouseout=\"this.className='list';\" onmouseover=\"this.className='list_select';\"");
    } else {
        out.write("class='list1' onmouseout=\"this.className='list1';\" onmouseover=\"this.className='list_select';\"");
    }%> onclick="window.location='<c:url value="/main.do"/>?Page=center/manage.jsp&action=set&version=<%=c.getVersion()%>'">
        <td><%=c.getVersion()%></td>
        <td><%=ScreenHelper.getSQLDate(c.getUpdateDateTime())%></td>
        <td><%=ScreenHelper.getSQLDate(c.getCreateDateTime())%></td>
        <td><%
            Hashtable hUser = User.getUserName(c.getUpdateUser());

            if (hUser != null){
                out.print(hUser.get("lastname")+" "+hUser.get("firstname"));
            }
            %>
        </td>
    </tr>
    <%i++;
        // out.write("name "+c.getName());
    }%>
</table>
<span><%=l.size()%> <%=HTMLEntities.htmlentities(getTran("web", "recordsfound", sWebLanguage))%></span>
<script>
    sortables_init();
</script>