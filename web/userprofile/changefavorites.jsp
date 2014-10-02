<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%@ page import="java.util.*" %>
<%
    Label label;
    Parameter parameter;

    String sAction = checkString(request.getParameter("Action"));

    //--- SAVE ------------------------------------------------------------------------------------
    if (sAction.equals("save")) {
        String sFavorite;
        activeUser.removeParameter("favorite");
        Hashtable hFavorites = (Hashtable) MedwanQuery.getInstance().getLabels().get(sWebLanguage);
        hFavorites = (Hashtable) hFavorites.get("favorite");

        Enumeration e = hFavorites.elements();
        while (e.hasMoreElements()) {
            label = (Label) e.nextElement();
            sFavorite = checkString(request.getParameter(label.id));

            if (sFavorite.equalsIgnoreCase("on")) {
                // update parameter in user object
                parameter = new Parameter("favorite", label.id);
                activeUser.parameters.add(parameter);

                // update parameter in DB
                UserParameter.saveUserParameter(parameter, Integer.parseInt(activeUser.userid));               
            }
        }

        session.setAttribute("activeUser", activeUser);
    }

    //--- ANY ACTION ------------------------------------------------------------------------------
    StringBuffer sOut = new StringBuffer();
    String sChecked, element;

    Hashtable hFavorites = (Hashtable) MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());

    if (hFavorites != null) {
        hFavorites = (Hashtable) hFavorites.get("favorite");
    }

    if (hFavorites != null) {
        // create a hash with the labelvalue as id
        String labelId;
        Hashtable labelValues = new Hashtable();
        Enumeration enum = hFavorites.keys();
        while (enum.hasMoreElements()) {
            labelId = (String) enum.nextElement();
            label = (Label) hFavorites.get(labelId);
            labelValues.put(label.value, label);
        }
        // sort favorites on VALUE
        Vector keys = new Vector(labelValues.keySet());
        Collections.sort(keys);

        // put favorites in a dropdown
        Iterator iter = keys.iterator();
        while (iter.hasNext()) {
            element = (String) iter.next();
            label = (Label) labelValues.get(element);

            // check checkbox if label-favorite occurs in userparameters
            sChecked = "";
            for (int i = 0; i < activeUser.parameters.size(); i++) {
                parameter = (Parameter) activeUser.parameters.elementAt(i);
                if (parameter.parameter.equalsIgnoreCase("favorite") && label.id.equals(parameter.value)) {
                    sChecked = " checked";
                    break;
                }
            }

            // label row
            sOut.append("<tr>")
                    .append("<td colspan='2' class='admin2'>")
                    .append("<input type='checkbox' id='cf_c" + label.id + "' name='" + label.id + "'" + sChecked + ">")
                    .append("<label for='cf_c" + label.id + "'>").append(label.value).append("(" + label.id + ")</label>")
                    .append("</td>")
                    .append("</tr>");
        }
    }

    // no records found message
    if (sOut.length() == 0) {
        sOut.append("<tr><td colspan='2'>&nbsp;" + getTran("web", "norecordsfound", sWebLanguage) + "</td></tr>");
    }
%>

<form name='UserProfile' method='post'>
    <input type="hidden" name="Action">

    <table width="100%" cellspacing="1" cellpadding="0" class="list">
        <%-- TITLE --%>
        <tr>
            <td colspan="2"><%=writeTableHeader("Web.UserProfile","ChangeFavorites",sWebLanguage," doBack();")%></td>
        </tr>

        <%-- DISPLAY LABELS --%>
        <%=sOut%>
    </table>

    <%-- BUTTONS --%>
    <%=ScreenHelper.alignButtonsStart()%>
        <input type="button" class="button" name="saveButton" value='<%=getTranNoLink("Web","save",sWebLanguage)%>' onClick="doSave();">
        <input type="button" class="button" name="backButton" value='<%=getTranNoLink("Web","back",sWebLanguage)%>' onClick='doBack();'>
    <%=ScreenHelper.alignButtonsStop()%>
</form>

<script>
  function doSave(){
    UserProfile.saveButton.disabled = true;
    UserProfile.backButton.disabled = true;
    UserProfile.Action.value = "save";
    UserProfile.submit();
  }

  function doBack(){
    window.location.href = "<c:url value='/main.do'/>?Page=userprofile/index.jsp";
  }
</script>