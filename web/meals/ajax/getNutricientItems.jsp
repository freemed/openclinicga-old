<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.NutricientItem,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAction = checkString(request.getParameter("Action"));

    String sFindNutricientName       = checkString(request.getParameter("FindNutricientName")),
           sFindNutricientNameWindow = checkString(request.getParameter("FindNutricientNameWindow"));
    
    boolean bWithSearchFields = (checkString(request.getParameter("withSearchFields")).length() > 0);
	if(bWithSearchFields){
        sFindNutricientName = sFindNutricientNameWindow;
    }
    
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n****************** meals/ajax/getNutricientItems.jsp ******************");
		Debug.println("sAction                   : "+sAction);
		Debug.println("sFindNutricientName       : "+sFindNutricientName);
		Debug.println("sFindNutricientNameWindow : "+sFindNutricientNameWindow);
		Debug.println("bWithSearchFields         : "+bWithSearchFields+"\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
	
	
    NutricientItem item = new NutricientItem();
    item.name = sFindNutricientName;
   
    //*** SEARCH FIELDS *******************************************************
    if(bWithSearchFields){
        %>
		<div id="nutrientsSearchDiv" style="width:514px"> 
			<table class="list" width="100%" cellspacing="1" cellpadding="1" onKeyDown="if(enterEvent(event,13)){searchNutricientItemsWindow();return false;}">
                <%-- NUTRIENT NAME --%>
			    <tr>
			        <td class="admin" width="100"><%=getTran("meals","nutricientName",sWebLanguage)%></td>
			        <td class="admin2">
			            <input type="text" class="text" id="FindNutricientNameWindow" name="FindNutricientNameWindow" value="<%=sFindNutricientNameWindow%>" size="30" maxLength="255">&nbsp;&nbsp;
			            
			            <%-- BUTTONS --%>
			            <input type="button" class="button" name="searchButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","search",sWebLanguage))%>" onclick="searchNutricientItemsWindow();">
			            <img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" class="link" title="<%=HTMLEntities.htmlentities(getTranNoLink("web","clear",sWebLanguage))%>" onclick="FindNutricientNameWindow.value='';FindNutricientNameWindow.focus();">
			        </td>
			    </tr>
			</table>
	        <br>
			
			<script>setTimeout("document.getElementById('FindNutricientNameWindow').focus()",200);</script>
        <%

        //*** SEARCH **************************************
        if(sAction.equalsIgnoreCase("search")){
	        List lNutricientItems = NutricientItem.getList(item);
	        
	        if(lNutricientItems.size() > 0){
		        %>	         	
	      		<table width="100%" class="sortable" id="searchresultsNutrients" cellspacing="0" cellpadding="0">
				    <%-- HEADER --%>
				    <tr class="gray">
				        <td width="150"><%=HTMLEntities.htmlentities(getTran("meals","name",sWebLanguage))%></td>
				        <td width="*"><%=HTMLEntities.htmlentities(getTran("meals","unit",sWebLanguage))%></td>
				    </tr>
				    
				    <tbody class="hand">
				    <%
				        Iterator iter = lNutricientItems.iterator();
				        int i = 0;
				        
				        while(iter.hasNext()){
				            item = (NutricientItem)iter.next();
				                        
				            out.write("<tr onclick='insertNutricientItem(\""+item.getUid()+"\",\""+HTMLEntities.htmlQuotes(HTMLEntities.htmlentities(item.name))+"\",\""+HTMLEntities.htmlQuotes(HTMLEntities.htmlentities(item.unit))+"\")' class='list"+(i%2==0?"":"1")+"'>");
				             out.write("<td>"+HTMLEntities.htmlentities(item.name)+"</td>");
				             out.write("<td>"+HTMLEntities.htmlentities(item.unit)+"</td>");
				            out.write("</tr>");
				            
				            i++;
				        }
			        %>
			        </tbody>
				</table>
		
				<%=lNutricientItems.size()%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%>
                <script>ts_makeSortable(document.getElementById("searchresultsNutrients"));</script>	
		        <%
	        }
	        else{
        		%><%=HTMLEntities.htmlentities(getTran("web","noRecordsfound",sWebLanguage))%><%
	        }
	    }
        
        %>
        	<br><br>		
			<input type="button" class="button" name="backButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","back",sWebLanguage))%>" onclick="openBackMealItem();">
            <script>Modalbox.resizeToContent();</script>
		</div>
        <%
	}
    //*** NO SEARCH FIELDS ****************************************************
    else{
    	//*** SEARCH **************************************
        if(sAction.equalsIgnoreCase("search")){
     	    List lNutricientItems = NutricientItem.getList(item);
     	    
        	if(lNutricientItems.size() > 0){
			    %>
			    <div id="nutrientsSearchDiv" style="width:100%"> 
					<table width="100%" class="sortable" id="searchresultsNutrients" cellspacing="0" cellpadding="0">
					    <%-- HEADER --%>
					    <tr class="gray">
					        <td width="25">&nbsp;</td>
					        <td width="150"><%=HTMLEntities.htmlentities(getTran("meals","name",sWebLanguage))%></td>
					        <td width="*"><%=HTMLEntities.htmlentities(getTran("meals","unit",sWebLanguage))%></td>
					    </tr>
				    
				        <tbody class="hand">
					    <%
					        Iterator iter = lNutricientItems.iterator();
					        int i = 0;
					        while(iter.hasNext()){
					            item = (NutricientItem)iter.next();
					                      
					            out.write("<tr class='list"+(i%2==0?"":"1")+"' onmouseover=\"this.className='list_select'\" onmouseout=\"this.className='list"+(i%2==0?"":"1")+"'\">");
					             out.write("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.png' class='link' title='"+getTranNoLink("web","delete",sWebLanguage)+"' onclick=\"deleteNutricientItem('"+item.getUid()+"');\"></td>");
					             out.write("<td onclick='openNutricientItem(\""+item.getUid()+"\")'>"+HTMLEntities.htmlentities(item.name)+"</td>");
					             out.write("<td onclick='openNutricientItem(\""+item.getUid()+"\")'>"+HTMLEntities.htmlentities(item.unit)+"</td>");
					            out.write("</tr>");
					           
					            i++;
					        }
					    %>
					    </tbody>
					</table>
			
					<%=lNutricientItems.size()%> <%=HTMLEntities.htmlentities(getTran("web","recordsfound",sWebLanguage))%>
                    <script>ts_makeSortable(document.getElementById("searchresultsNutrients"));</script>	
				</div>
				<%
        	}
        	else{
        		%><%=HTMLEntities.htmlentities(getTran("web","noRecordsfound",sWebLanguage))%><%
        	}
        }
	}
%>		