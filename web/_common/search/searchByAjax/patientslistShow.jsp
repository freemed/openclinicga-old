<%@page import="java.util.*,
                be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<ul id="autocompletion">
    <%
        String sName = checkString(request.getParameter("findName")).toUpperCase(),
               sFirstname = checkString(request.getParameter("findFirstname")).toUpperCase(),
               sField = checkString(request.getParameter("field"));

        int iMaxRows = MedwanQuery.getInstance().getConfigInt("MaxSearchFieldsRows", 30);

        List lResults = AdminPerson.getLimitedPatients(sName, sFirstname, iMaxRows);
        boolean hasMoreResults = (lResults.size() >= iMaxRows);
        if (lResults.size() > 0) {
            Iterator it = lResults.iterator();
            while (it.hasNext()) {
                AdminPerson person = (AdminPerson) it.next();
                if (sField.equals("findFirstname") || (!sFirstname.equals("") && sName.equals("")) ) {
                    out.write("<li>");
                    out.write(HTMLEntities.htmlentities("<b>" + person.firstname + "</b> " + person.lastname));
                    out.write("<span style='display:none'>" + person.personid + "-idcache</span>");
                    out.write("</li>");
                }
                else if (sField.equals("findName") ||(!sName.equals("") && sFirstname.equals(""))) {
                    out.write("<li>");
                    out.write(HTMLEntities.htmlentities("<b>" + person.lastname + "</b> " + person.firstname));
                    out.write("<span style='display:none'>" + person.personid + "-idcache</span>");
                    out.write("</li>");
                }
            }

        }
    %>
</ul>
<%
    if(hasMoreResults){
        out.write("<ul id='autocompletion'><li>...</li></ul>");
    }
%>

