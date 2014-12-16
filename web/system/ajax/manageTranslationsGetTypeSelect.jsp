<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	/// DEBUG /////////////////////////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("\n************* system/manageTranslationsGetTypeSelect.jsp **************");
	  	Debug.println("no params\n");
	}
	///////////////////////////////////////////////////////////////////////////////////////////////
%>

<select id="FindLabelType" class="text">
    <option></option>
    <%
        java.util.Vector vLabelTypes = Label.getLabelTypes();
        Debug.println("--> vLabelTypes : "+vLabelTypes.size()); 
    
        Iterator iter = vLabelTypes.iterator();
        String sTmpLabeltype;

        while(iter.hasNext()){
            sTmpLabeltype = (String)iter.next();
            %><option value="<%=sTmpLabeltype%>"><%=sTmpLabeltype%></option><%
        }
    %>
</select>