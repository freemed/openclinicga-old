<%@ page import="java.util.Vector,be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    // get values from form
    String findLabelID = checkString(request.getParameter("FindLabelID")),
            findLabelType = checkString(request.getParameter("FindLabelType")),
            findLabelLang = checkString(request.getParameter("FindLabelLang")),
            findLabelValue = checkString(request.getParameter("FindLabelValue"));

    // exclusions on labeltype
    boolean excludeServices = checkString(request.getParameter("excludeServices")).equals("true");
    boolean excludeFunctions = checkString(request.getParameter("excludeFunctions")).equals("true");

    // compose query
    Vector vLabels = Label.findFunction_manageTranslationsPage(ScreenHelper.checkDbString(findLabelType).toLowerCase(),
            ScreenHelper.checkDbString(findLabelID).toLowerCase(),
            ScreenHelper.checkDbString(findLabelLang).toLowerCase(),
            ScreenHelper.checkDbString(findLabelValue).toLowerCase(),
            excludeFunctions, excludeServices);

    String sLabelType, sLabelID, sLabelLang, sLabelValue, sClass = "";

    int recsFound = 0;
    StringBuffer foundLabels = new StringBuffer();

    Iterator iterFind = vLabels.iterator();

    //while(rs.next()){
    Label label;
    while (iterFind.hasNext()) {
        label = (Label) iterFind.next();
        sLabelType = checkString(label.type);
        sLabelID = checkString(label.id);
        sLabelLang = checkString(label.language);
        sLabelValue = checkString(label.value);

        // alternate row-style
        if (sClass.equals("")) sClass = "1";
        else sClass = "";

        // display label in row
        foundLabels.append("<tr class='list" + sClass + "'  >")
                .append(" <td class='hand' onclick=\"setLabel('" + sLabelType + "','" + sLabelID+ "');\">" + sLabelType + "</td>")
                .append(" <td class='hand' onclick=\"setLabel('" + sLabelType + "','" + sLabelID+ "');\">" + HTMLEntities.htmlentities(sLabelID) + "</td>")
                .append(" <td class='hand' onclick=\"setLabel('" + sLabelType + "','" + sLabelID+ "');\">" + HTMLEntities.htmlentities(getTran("web.language", sLabelLang, sWebLanguage)) + "</td>")
                .append("<td class='hand' onclick=\"setLabel('" + sLabelType + "','" + sLabelID+ "');\">" + HTMLEntities.htmlentities(sLabelValue) + "</td>");

        recsFound++;
    }

    if (recsFound > 0) {
    %>
    <table width="100%" cellspacing="0">
      <tr class="admin">
          <td width="20%"><%=getTran("Web.Translations","LabelType",sWebLanguage)%></td>
          <td width="38%"><%=getTran("Web.Translations","LabelID",sWebLanguage)%></td>
          <td width="10%"><%=getTran("Web","Language",sWebLanguage)%></td>
          <td width="30%"><%=getTran("Web","Value",sWebLanguage)%></td>
      </tr>
       <%-- FOUND LABELS --%>
      <tbody id="Input_Hist" onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
          <%=foundLabels%>
      </tbody>
    </table>
    <%
    }

    %><span><%=recsFound%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%></span>
