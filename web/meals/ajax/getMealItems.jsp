<%@include file="/includes/validateUser.jsp"%>
<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.MealItem,
                java.util.*"%>

<%
    String sFindItemName        = checkString(request.getParameter("FindMealItemName")),
           sFindItemDescription = checkString(request.getParameter("FindMealItemDescription"));
           
    boolean bWithSearchFields = checkString(request.getParameter("withSearchFields")).length() > 0;
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* meals/ajax/getMealItems.jsp *********************");
    	Debug.println("sFindItemName        : "+sFindItemName);
    	Debug.println("sFindItemDescription : "+sFindItemDescription);
    	Debug.println("bWithSearchFields    : "+bWithSearchFields+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    MealItem item = new MealItem();
    item.name = sFindItemName;
    item.description = sFindItemDescription;
    
    List lMealsitems = MealItem.getList(item);
    		
    if(bWithSearchFields){
        %>
        <div id="mealItemsDiv" style="width:514px">
			<table class="list" width="100%" cellspacing="1" cellpadding="1" onKeyDown="if(enterEvent(event,13)){searchMealItemsWindow();return false;}">
			    <%-- NAME --%>
			    <tr>
			        <td class="admin" width="100"><%=HTMLEntities.htmlentities(getTran("meals","mealItemName",sWebLanguage))%></td>
			        <td class="admin2">
			            <input type="text" class="text" id="FindMealItemName" maxLength="255" value="<%=HTMLEntities.htmlentities(sFindItemName)%>"/>
			        </td>
			    </tr>
			    
			    <%-- DESCRIPTION --%>
			    <tr>
			        <td class="admin"><%=HTMLEntities.htmlentities(getTran("meals","mealItemDescription",sWebLanguage))%></td>
			        <td class="admin2">
			            <input type="text" class="text" id="FindMealItemDescription" maxLength="100" value="<%=HTMLEntities.htmlentities(sFindItemDescription)%>"/>&nbsp;&nbsp;
			         
			            <%-- BUTTONS --%>
			            <input type="button" class="button" name="searchButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","search",sWebLanguage))%>" onclick="searchMealItemsWindow();">
			            <img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" class="link" title="<%=HTMLEntities.htmlentities(getTranNoLink("web","clear",sWebLanguage))%>" onclick="clearMealItemSearchFields();">			      
			        </td>
			    </tr>
			</table>
			<br>  
			
			<script>setTimeout("if(document.getElementById('FindMealItemName')) document.getElementById('FindMealItemName').focus()",200);</script>
					
            <%
                if(lMealsitems.size() > 0){
    	 	   	    %>
						<%-- SEARCH RESULTS --%>
						<table width="100%" id="searchresultsMealItems" class="sortable" cellspacing="0" cellpadding="0">
						    <%-- HEADER --%>
						    <tr class="gray">
						        <td width="150"><%=HTMLEntities.htmlentities(getTran("meals","name",sWebLanguage))%></td>
						        <td width="100"><%=HTMLEntities.htmlentities(getTran("meals","unit",sWebLanguage))%></td>
				                <td width="100"><%=HTMLEntities.htmlentities(getTran("meals","nutrients",sWebLanguage))%></td>
						        <td width="*"><%=HTMLEntities.htmlentities(getTran("meals","description",sWebLanguage))%></td>
						    </tr>
	    
			           	    <tbody class="hand">
						    <%
						        Iterator iter = lMealsitems.iterator();
						        String sDescr;
						        int i = 0;
						        while(iter.hasNext()){
						            item = (MealItem)iter.next();
						            
						            sDescr = checkString(item.description);
						            if(sDescr.length() > 100){
						            	sDescr = item.description.substring(0,100)+"...";			            	
						            }
						            
						            out.write("<tr onclick='insertMealItem(\""+item.getUid()+"\",\""+HTMLEntities.htmlQuotes(HTMLEntities.htmlentities(item.name))+"\",\""+HTMLEntities.htmlQuotes(HTMLEntities.htmlentities(item.unit))+"\")' class='list"+(i%2==0?"":"1")+"'>");
						             out.write("<td>"+HTMLEntities.htmlentities(item.name)+"</td>");
						             out.write("<td>"+HTMLEntities.htmlentities(item.unit)+"</td>");
						             out.write("<td>"+item.nutricientItems.size()+"</td>");
						             out.write("<td>"+HTMLEntities.htmlentities(sDescr)+"</td>");
						            out.write("</tr>");
						            
						            i++;
						        }
						    %>
						    </tbody>
						</table>
						
			            <script>ts_makeSortable(document.getElementById("searchresultsMealItems"));</script>	
					<%
				}
		    %>
		
            <script>Modalbox.resizeToContent();</script>
			<%=lMealsitems.size()%> <%=HTMLEntities.htmlentities(getTran("web","recordsFound",sWebLanguage))%><br><br>
						
			<input type="button" class="button" name="backButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","back",sWebLanguage))%>" onclick="openBackMeal();">
		</div>
		<%
	}
	else{
		if(lMealsitems.size() > 0){
			%>
				<table width="100%" id="searchresultsMealItems" class="sortable" cellspacing="0" cellpadding="0">
				    <%-- HEADER --%>
				    <tr class="gray">
				        <td width="25">&nbsp;</td>
				        <td width="150"><%=HTMLEntities.htmlentities(getTran("meals","name",sWebLanguage))%></td>
				        <td width="100"><%=HTMLEntities.htmlentities(getTran("meals","unit",sWebLanguage))%></td>
				        <td width="100"><%=HTMLEntities.htmlentities(getTran("meals","nutrients",sWebLanguage))%></td>
				        <td width="*"><%=HTMLEntities.htmlentities(getTran("meals","description",sWebLanguage))%></td>
				    </tr>
				    
				    <tbody class="hand">
				    <%
				        Iterator iter = lMealsitems.iterator();
				        String sDescr;
				        int i = 0;
				        
				        while(iter.hasNext()){
				            item = (MealItem)iter.next();
				            
				            sDescr = checkString(item.description);
				            if(sDescr.length() > 100){
				            	sDescr = item.description.substring(0,100)+"...";			            	
				            }
				            
				            out.write("<tr class='list"+(i%2==0?"":"1")+"'>");
				             out.write("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.png' class='link' title='"+getTranNoLink("web","delete",sWebLanguage)+"' onclick=\"deleteMealItem('"+item.getUid()+"');\"></td>");
				             out.write("<td onclick='openMealItem(\""+item.getUid()+"\")'>"+HTMLEntities.htmlentities(item.name)+"</td>");
				             out.write("<td onclick='openMealItem(\""+item.getUid()+"\")'>"+HTMLEntities.htmlentities(item.unit)+"</td>");
				             out.write("<td onclick='openMealItem(\""+item.getUid()+"\")'>"+item.nutricientItems.size()+"</td>");
				             out.write("<td onclick='openMealItem(\""+item.getUid()+"\")'>"+HTMLEntities.htmlentities(sDescr)+"</td>");
				            out.write("</tr>");
				           
				            i++;
				        }
				    %>
				    </tbody>
				</table>
			
				<%=lMealsitems.size()%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%>
                <script>ts_makeSortable(document.getElementById("searchresultsMealItems"));</script>	
			<%
		}
		else{
			%><%=HTMLEntities.htmlentities(getTran("web","noRecordsfound",sWebLanguage))%><%
		}
	}
%>