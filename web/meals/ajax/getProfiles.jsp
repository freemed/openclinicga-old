<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.meals.Meal,
                be.openclinic.meals.MealProfile,
                java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sFindProfileName = checkString(request.getParameter("FindProfileName"));
    boolean bWithSearchFields = checkString(request.getParameter("withSearchFields")).length() > 0;
    
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n********************* meals/ajax/getProfiles.jsp ***********************");
    	Debug.println("sFindProfileName  : "+sFindProfileName);
    	Debug.println("bWithSearchFields : "+bWithSearchFields+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    List lProfiles = MealProfile.getProfiles(sFindProfileName);

    if(bWithSearchFields){
        %>
		<div id="profileSearchDiv" style="width:514px"> 
			<%-- PROFILE NAME --%>
			<table class="list" width="100%" cellpadding="1" cellspacing="1" onKeyDown="if(enterEvent(event,13)){searchProfilesWindow();return false;}">
			    <tr>
			        <td class="admin" width="100"><%=getTran("meals","name",sWebLanguage)%></td>
			        <td class="admin2">
			            <input type="text" class="text" name="FindProfileName" id="FindProfileNameWindow" size="30" value="<%=sFindProfileName%>" maxLength="100">&nbsp;&nbsp;
			          
			            <%-- BUTTONS --%>
			            <input type="button" class="button" name="searchButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","search",sWebLanguage))%>" onclick="searchProfilesWindow(true);">
			            <img src="<%=sCONTEXTPATH%>/_img/icons/icon_delete.gif" class="link" title="<%=HTMLEntities.htmlentities(getTranNoLink("web","clear",sWebLanguage))%>" onclick="$('FindProfileNameWindow').value='';$('FindProfileNameWindow').focus();">
			        </td>
			    </tr>
			</table>
			<br>
			
		    <script>setTimeout("document.getElementById('FindProfileNameWindow').focus()",200);</script>
			
			<%-- SEARCH RESULTS --%>
			<%
			    if(lProfiles.size() > 0){
			        %>
					<table width="100%" class="sortable" id="searchresultsProfiles" cellspacing="1" cellpadding="1">
					    <%-- HEADER --%>
					    <tr class="gray">
					        <td width="200"><%=HTMLEntities.htmlentities(getTran("meals","profile",sWebLanguage))%></td>
					        <td width="*"><%=HTMLEntities.htmlentities(getTran("meals","meals",sWebLanguage))%></td>
					    </tr>
					    
				    	<tbody class="hand">
					    <%
					        Iterator iter = lProfiles.iterator();
					        MealProfile profile;
					        int i = 0;
					        
					        while(iter.hasNext()){
					            profile = (MealProfile)iter.next();
					            
					            out.write("<tr class='list"+(i%2==0?"":"1")+"'>");
					             out.write("<td onclick='getPatientProfile(\""+profile.getUid()+"\");'>"+HTMLEntities.htmlentities(profile.name)+"</td>");
					             out.write("<td onclick='getPatientProfile(\""+profile.getUid()+"\");'>"+profile.getProfileMeals().size()+"</td>");
					            out.write("</tr>");
					           
					            i++;
					        }
					    %>
					    </tbody>
					</table>

					<%=lProfiles.size()%> <%=HTMLEntities.htmlentities(getTran("web","recordsFound",sWebLanguage))%><br><br>
                    <script>ts_makeSortable(document.getElementById("searchresultsProfiles"));</script>	
					
					<input type="button" class="button" name="backButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="closeModalbox();">
					<script>Modalbox.resizeToContent();</script>
					<%
			    }
		    	else{
		    		%>
		    		    <%=HTMLEntities.htmlentities(getTran("web","noRecordsfound",sWebLanguage))%>
		    		    <input type="button" class="button" name="backButton" value="<%=HTMLEntities.htmlentities(getTranNoLink("web","close",sWebLanguage))%>" onclick="openBackProfile();">
		    	     	<script>Modalbox.resizeToContent();</script>
     			    <%
		    	}
		    %>
	    </div>
		<%
	}
    else{
    	if(lProfiles.size() > 0){
	        %>
		    <div id="profileSearchDiv" style="width:100%"> 
				<table width="100%" class="sortable" id="searchresultsProfiles" cellspacing="0" cellpadding="0">
				    <%-- HEADER --%>
				    <tr class="gray">
				        <td width="25">&nbsp;</td>
				        <td width="200"><%=HTMLEntities.htmlentities(getTran("meals","name",sWebLanguage))%></td>
				        <td width="*"><%=HTMLEntities.htmlentities(getTran("meals","meals",sWebLanguage))%></td>
				    </tr>
				    
				    <tbody class="hand">
				    <%
				        Iterator iter = lProfiles.iterator();
			            MealProfile profile;
				        int i = 0;
				        
				        while(iter.hasNext()){
				            profile = (MealProfile)iter.next();
				            
				            out.write("<tr class='list"+(i%2==0?"":"1")+"'>");
				             out.write("<td><img src='"+sCONTEXTPATH+"/_img/icons/icon_delete.png' class='link' title='"+getTranNoLink("web","delete",sWebLanguage)+"' onclick=\"deleteProfile('"+profile.getUid()+"');\"></td>");
				             out.write("<td onclick='openProfile(\""+profile.getUid()+"\")'>"+HTMLEntities.htmlentities(profile.name)+"</td>");
				             out.write("<td onclick='openProfile(\""+profile.getUid()+"\");'>"+profile.getProfileMeals().size()+"</td>");
				            out.write("</tr>");
				            
				            i++;
				        }
				    %>
				    </tbody>
				</table>
				
				<%=lProfiles.size()%> <%=HTMLEntities.htmlentities(getTran("web","recordsFound",sWebLanguage))%>
                <script>ts_makeSortable(document.getElementById("searchresultsProfiles"));</script>	
			</div>
	    	<%
    	}
    	else{
    		%><%=HTMLEntities.htmlentities(getTran("web","noRecordsfound",sWebLanguage))%><%
    	}
    }
%>