<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.NutricientItem,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sNutricientItemId = checkString(request.getParameter("nutricientItemId"));
	
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n******************** meals/ajax/getNutricientItem.jsp ******************");
		Debug.println("sNutricientItemId : "+sNutricientItemId+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////

    NutricientItem item = new NutricientItem(sNutricientItemId);
    if(sNutricientItemId.length() > 0 && !sNutricientItemId.equals("-1")){
        item = NutricientItem.get(item);
    }
%>
<div id="nutricientItemEdit" style="width:514px">
	<table class="list" class="list" cellspacing="1" cellpadding="1" width="100%" onKeyDown="if(enterEvent(event,13)){setNutricientItem();return false;}">
	    <%-- NUTRIENT NAME --%>
	    <tr>
	        <td class="admin" width="120"><%=HTMLEntities.htmlentities(getTran("meals","name",sWebLanguage))%></td>
	        <td class="admin2">
	            <input class="text" type="text" style="width:200px" name="nutricientItemName" id="nutricientItemName" value="<%=checkString(HTMLEntities.htmlentities(item.name))%>"/>
	        </td>
	    </tr>
	    
	    <%-- UNIT --%>
	    <tr>
	        <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals","unit",sWebLanguage))%></td>
	        <td class="admin2">
	            <select id="nutricientItemUnit" class="text" style="width:200px">
                    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%>
	                <%
	                    Hashtable labelTypes = (Hashtable)MedwanQuery.getInstance().getLabels().get(sWebLanguage.toLowerCase());
	                    if(labelTypes!=null){
	                        Hashtable labelIds = (Hashtable)labelTypes.get("meals");
	                        Iterator iter = labelIds.keySet().iterator();
	                        Label label = null;
	                        
	                        while(iter.hasNext()){
	                            String sType = (String)iter.next();
	                            if(sType.indexOf("unit.nutricient")==0){
	                                label = (Label)labelIds.get(sType);
	                                out.write("<option "+(label.value.equalsIgnoreCase(item.unit)?"selected":"")+">"+HTMLEntities.htmlentities(label.value)+"</option>");
	                            }
	                        }
	                    }
	                %>
	            </select>
	        </td>
	    </tr>
	    
	    <%-- BUTTONS --%>
	    <tr>
	        <td class="admin">&nbsp;</td>
	        <td class="admin2">
	            <input type="hidden" id="nutricientItemId" value="<%=checkString(item.getUid())%>"/>
	            <input class="button" type="button" name="SaveButton" id="SaveButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","Save",sWebLanguage))%>" onclick="setNutricientItem();">&nbsp;
	            <%
	                if(!item.getUid().equalsIgnoreCase("-1")){
	                    %><input type="button" class="button" name="deleteButton" id="deleteButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","delete",sWebLanguage))%>" onclick="deleteNutricientItem('<%=item.getUid()%>');">&nbsp;<%
	                }
	            %>
	            <input class="button" type="button" name="closeButton" id="closeButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
            </td>
	    </tr>
	</table>
</div>