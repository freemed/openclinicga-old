<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.MealItem,
                be.openclinic.meals.NutricientItem,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sMealItemId = checkString(request.getParameter("mealItemId"));

	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n********************* meals/ajax/getMealItem.jsp ***********************");
		Debug.println("sMealItemId : "+sMealItemId+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    MealItem mealItem = new MealItem(sMealItemId);
    if(sMealItemId.length() > 0 && !sMealItemId.equals("-1")){
        mealItem = MealItem.get(mealItem);
    }
%>

<div id="mealItemEdit" style="width:514px">
    <table class="list" cellspacing="1" cellpadding="1" width="100%">
        <%-- ITEM NAME --%>
        <tr>
            <td class="admin" width="120"><%=HTMLEntities.htmlentities(getTran("meals","name",sWebLanguage))%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <input class="text" style="width:200px" type="text" name="mealItemName" id="mealItemName" value="<%=checkString(HTMLEntities.htmlentities(mealItem.name))%>"/>
            </td>
        </tr>
        
        <%-- ITEM UNIT --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals","unit",sWebLanguage))%>&nbsp;*&nbsp;</td>
            <td class="admin2">
                <select id="mealItemUnit" class="text" style="width:200px">
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%>
                    <%
                        Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
                        if(labelTypes!=null){
                            Hashtable labelIds = (Hashtable)labelTypes.get("meals");
                            Iterator iter = labelIds.keySet().iterator();
                            Label label = null;
                            
                            while(iter.hasNext()){
                                String sType = (String)iter.next();
                                
                                if(sType.startsWith("unit.mealitem")){
                                	label = (Label)labelIds.get(sType);
                                    out.write("<option "+(label.value.equalsIgnoreCase(mealItem.unit)?"selected":"")+">"+HTMLEntities.htmlentities(label.value)+"</option>");
                                }
                            }
                        }
                    %>
                </select>
            </td>
        </tr>
        
        <%-- DESCRIPTION --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals","description",sWebLanguage))%></td>
            <td class="admin2">
                <textarea class="text" style="width:200px" rows="2" onKeyup="resizeTextarea(this,10);limitLength(this);" id="mealItemDescription"><%=HTMLEntities.htmlentities(checkString(mealItem.description))%></textarea>
            </td>
        </tr>
        
        <script>resizeTextarea($("mealItemDescription"),10);</script>
        
        <%-- MEAL ITEM NUTRICIENTS --%>
        <tr>
            <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals","nutricients",sWebLanguage))%></td>
            <td class="admin2">
                <a href="javascript:void(0)" class="link add" onclick="searchNutricientItemsWindow(false);"><span><%=HTMLEntities.htmlentities(getTran("meals","addNutricientItem",sWebLanguage).toLowerCase())%></span></a>
                <br>
                
                <ul id="nutricientList" class="items" style="width:90%">
                    <%
                        Iterator iter = mealItem.nutricientItems.iterator();
                        while(iter.hasNext()){
                            NutricientItem nutricient = (NutricientItem)iter.next();
                            out.write("<script>insertNutricientItem('"+nutricient.getUid()+"','"+nutricient.name+"','"+nutricient.unit+"','"+nutricient.quantity+"');</script>");                            	
                        }
                    %>
                </ul>
            </td>
        </tr>
        
        <%-- BUTTONS --%>
        <tr>
            <td class="admin">&nbsp;</td>
            <td class="admin2">
                <input type="hidden" id="mealItemId" value="<%=checkString(mealItem.getUid())%>"/>
                <input class="button" type="button" name="SaveButton" id="saveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","save",sWebLanguage))%>" onclick="setMealItem();">&nbsp;
                <%
                    if(!mealItem.getUid().equalsIgnoreCase("-1")){
                    	%><input type="button" class="button" name="deleteButton" id="deleteButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","delete",sWebLanguage))%>" onclick="deleteMealItem('<%=mealItem.getUid()%>');">&nbsp;<%
                    }
                %>                
                <input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
            </td>
        </tr>
    </table>
</div>

<div id="nutricientItemsList" style="width:500px">&nbsp;</div>