<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
    String sLabelType = checkString(request.getParameter("LabelType")),
           sLabelId   = checkString(request.getParameter("LabelId"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************************** _common/getLabel.jsp ***********************");
    	Debug.println("sLabelType : "+sLabelType);
    	Debug.println("sLabelId   : "+sLabelId);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sLabel = ScreenHelper.getTranNoLink(sLabelType,sLabelId,sWebLanguage);
    
    if(sLabel.length() > 0){
        Debug.println("--> "+sLabel);
        %><%=HTMLEntities.htmlentities(sLabel)%><%
    }
    else{
        Debug.println("--> no found");
    }
%>    