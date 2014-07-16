<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.system.Screen"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n########### system/ajax/screenDesigner/listSavedScreens.jsp ############");
        Debug.println("No parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
%>

<select class="text" name="ScreenUID" value="" onChange="if(okToSwitchScreens()==true)fetchScreen();">
    <option value=""><%=getTranNoLink("web","choose",sWebLanguage)%></option>
    <option value="new"><%=getTranNoLink("web","new",sWebLanguage)%></option>
    <%
        List<Screen> savedScreens = Screen.getList(false); // no fullLoad
        Iterator screenIter = savedScreens.iterator();
        Screen tmpScreen;
        
        while(screenIter.hasNext()){
        	tmpScreen = (Screen)screenIter.next();
        	Debug.println("savedscreen ("+tmpScreen.getUid()+") : "+tmpScreen.getLabel(sWebLanguage));
        	
            %><option value="<%=tmpScreen.getUid()%>"><%=tmpScreen.getLabel(sWebLanguage)%></option><%	
        }                    
    %>
</select>