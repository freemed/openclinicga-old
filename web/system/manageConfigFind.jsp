<%@page import="be.openclinic.system.Config,
                java.util.Vector,
                be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<script src='<%=sCONTEXTPATH%>/_common/_script/prototype.js'></script>
<script src='<%=sCONTEXTPATH%>/_common/_script/stringFunctions.js'></script>
<%=checkPermission("system.management","all",activeUser)%>
<%
    String sFindKey   = checkString(request.getParameter("FindKey")),
           sFindValue = checkString(request.getParameter("FindValue"));

    Vector vConfig = Config.searchConfig(sFindKey,sFindValue);
    StringBuffer sOut = new StringBuffer();
    Iterator iter = vConfig.iterator();
    Config objConfig;

    String sClass = "", styleRed, sValue;

    while(iter.hasNext()){
        objConfig = (Config) iter.next();
        
        // alternate row-style
        if(sClass.equals("")) sClass = "1";
        else                  sClass = "";

        if(objConfig.getDeletetime()!=null) styleRed = "style='color:red'";
        else                                styleRed = "";
        
        // when tags noticed, display msg, otherwise the content is not shown as-is
        sValue = objConfig.getOc_value().toString();
        if(sValue.indexOf("<") > -1 || sValue.indexOf(">") > -1){
        	sValue = "[html|xml : check value in textarea below]";
        }
        
        sOut.append("<tr class=\"list"+sClass+"\" "+styleRed+" onclick=\"doShow('"+objConfig.getOc_key()+"');\">")
             .append("<td>"+HTMLEntities.htmlentities(objConfig.getOc_key())+"</td>")
             .append("<td>"+HTMLEntities.htmlentities(sValue)+"</td>")
             .append("<td>"+(objConfig.getUpdatetime()==null?"":ScreenHelper.fullDateFormatSS.format(objConfig.getUpdatetime()))+"</td>")
            .append("</tr>");
    }

    if(sOut.length() > 0){
        %>
        <table width="100%" align="center" cellspacing="0" class="list">
          <tr class="admin">
              <td width="250">Key</td>
              <td width="50%"><%=HTMLEntities.htmlentities(getTran("Web","value",sWebLanguage))%></td>
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