<%@page import="be.openclinic.system.Config,java.util.Vector,be.mxs.common.util.system.HTMLEntities" %>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>
<script src='<%=sCONTEXTPATH%>/_common/_script/stringFunctions.js'></script>
<%=checkPermission("system.management","all",activeUser)%>
<%
    String sFindKey = checkString(request.getParameter("FindKey"));
    String sFindValue = checkString(request.getParameter("FindValue"));

    Vector vConfig = Config.searchConfig(sFindKey, sFindValue);
    StringBuffer sOut = new StringBuffer();
    Iterator iter = vConfig.iterator();
    Config objConfig;

    String sClass = "", styleRed;
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm:ss");

    while (iter.hasNext()) {
        objConfig = (Config) iter.next();
        // alternate row-style
        if (sClass.equals("")) sClass = "1";
        else sClass = "";

        if (objConfig.getDeletetime() != null) styleRed = "style='color:red'";
        else styleRed = "";

        sOut.append("<tr class=\"list" + sClass + "\" " + styleRed + " onmouseover=\"this.className='list_select';\" onmouseout=\"this.className='list" + sClass + "';\" onclick=\"doShow('" + objConfig.getOc_key() + "');\">")
            .append(" <td>" + HTMLEntities.htmlentities(objConfig.getOc_key()) + "</td>")
            .append(" <td>" + HTMLEntities.htmlentities(objConfig.getOc_value().toString()) + "</td>")
            .append(" <td>" + (objConfig.getUpdatetime() == null ? "" : dateFormat.format(objConfig.getUpdatetime())) + "</td>")
            .append("</tr>");
    }

    if(sOut.length() > 0){
        %>
        <table width='100%' align='center' cellspacing="0" class="list">
          <tr class="admin">
              <td width="250">Key</td>
              <td width="50%"><%=HTMLEntities.htmlentities(getTran("Web", "value", sWebLanguage))%></td>
              <td width="150"><%=HTMLEntities.htmlentities(getTran("Web","updatetime",sWebLanguage))%></td>
          </tr>
          <tbody onmouseover='this.style.cursor="hand"' onmouseout='this.style.cursor="default"'>
              <%=sOut%>
          </tbody>
        </table>
        <%=HTMLEntities.htmlentities(getTran("Web","deletedItemsInRed",sWebLanguage))%>
        <%
    }
    else{
        out.print(HTMLEntities.htmlentities(getTran("web","nodataavailable",sWebLanguage)));
    }
%>