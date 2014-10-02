<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@ page import="java.util.*" %>
<%@ page import="be.openclinic.meals.MealItem" %>
<%@ page import="be.openclinic.meals.NutricientItem" %>
<%@include file="/includes/validateUser.jsp" %>
<%
    String sMealItemId = checkString(request.getParameter("mealItemId"));
    MealItem item = new MealItem(sMealItemId);
    if (sMealItemId.length() > 0 && !sMealItemId.equals("-1")) {
        item = MealItem.get(item);
    }
%>
<div id="mealItemEdit" style="width:500px">
    <table cellspacing="1" cellpadding="1" width="100%" class="sortable" onKeyDown='if(event.keyCode==13){setMealItem();return false;}'>
        <tr width="100%">
            <td class="admin" width="<%=sTDAdminWidth%>"><%=HTMLEntities.htmlentities(getTran("meals", "mealItemName", sWebLanguage))%>
            </td>
            <td class="admin2">
                <input class="text" style="width:200px" type="text" id="mealItemName" value="<%=checkString(HTMLEntities.htmlentities(item.name))%>"/>
            </td>
        </tr>
        <tr width="100%">
            <td class="admin"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealItemUnit", sWebLanguage))%>
            </td>
            <td class="admin2">
                <select id="mealItemUnit" style="width:200px">
                    <%
                        Hashtable labelTypes = (Hashtable) MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
                        if (labelTypes != null) {
                            Hashtable labelIds = (Hashtable) labelTypes.get("meals");
                            Iterator it = labelIds.keySet().iterator();
                            Label l = null;
                            while (it.hasNext()) {
                                String s = (String) it.next();
                                if (s.indexOf("unit.mealitem") == 0) {
                                    l = (Label) labelIds.get(s);
                                    out.write("<option " + (l.value.equalsIgnoreCase(item.unit) ? "selected=selected" : "") + " >" + HTMLEntities.htmlentities(l.value) + "</option>");
                                }
                            }
                        }%>
                </select>
            </td>
        </tr>
        <tr width="100%">
            <td class="admin"><%=HTMLEntities.htmlentities(getTranNoLink("meals", "mealItemDescription", sWebLanguage))%>
            </td>
            <td class="admin2">
                <textarea class="text" style="width:200px" type="text" id="mealItemDescription"><%=HTMLEntities.htmlentities(checkString(item.description))%>
                </textarea>
            </td>
        </tr>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals", "mealItems", sWebLanguage))%>
            </td>
            <td class="admin2">
                <a href="javascript:void(0)" class="link add" onclick="searchNutricientItemsWindow();"><span><%=HTMLEntities.htmlentities(getTranNoLink("web", "add", sWebLanguage) + " " + getTranNoLink("meals", "nutricientItem", sWebLanguage).toLowerCase())%></span></a>
                <br/>
                <ul id="mealItemNutricients" class="items" style="width:370px">
                    <%Iterator it = item.nutricientItems.iterator();
                        while (it.hasNext()) {
                            NutricientItem nutricientItem = (NutricientItem) it.next();
                            out.write("<li id='mealitemnutricient_" + nutricientItem.getUid() + "'><div style='width:190px'>" + nutricientItem.name + "</div><div style='width:150px'><input type='text' size='7' id='mealitemnutricientqt_" + nutricientItem.getUid() + "' value='" + nutricientItem.quantity + "'/> " + HTMLEntities.htmlentities(nutricientItem.unit) + "</div><div style='width:20px'><img src='" + sCONTEXTPATH + "/_img/icons/icon_delete.png' class='link' title='" + (getTranNoLink("web", "delete", sWebLanguage)) + "' onclick='removeNutricientItem(\"" + nutricientItem.getUid() + "\");'></div></li>");
                        }%>
                </ul>
            </td>
        </tr>
        <tr width="100%">
            <td class="admin">&nbsp;
            </td>
            <td class="admin2">
                <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","Save",sWebLanguage))%>" onclick="setMealItem();"> &nbsp;<input <%=(item.getUid().equalsIgnoreCase("-1")?"type=\"hidden\"":"type=\"button\"")%> class="button" name="SaveButton" id="deleteButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","delete",sWebLanguage))%>" onclick="deleteMealItem('<%=item.getUid()%>');"> &nbsp;<input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
                <input type="hidden" id="mealItemId" value="<%=checkString(item.getUid())%>"/>
            </td>
        </tr>
    </table>
</div>
<div id="nutricientItemsList" style="width:500px">&nbsp;</div>