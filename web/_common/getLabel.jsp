<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>

<%
    String sLabelType  = checkString(request.getParameter("LabelType")),
            sLabelId   = checkString(request.getParameter("LabelId")),
            sLabelLang = checkString(request.getParameter("LabelLang"));

    if(sLabelLang.length()==0) sLabelLang = sWebLanguage;

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n************************** _common/getLabel.jsp ***********************");
    	Debug.println("sLabelType : "+sLabelType);
    	Debug.println("sLabelId   : "+sLabelId);
    	Debug.println("sLabelLang : "+sLabelLang);
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    String sLabel = ScreenHelper.getTranNoLink(sLabelType,sLabelId,sLabelLang);
    
    if(sLabel.length() > 0){
        Debug.println("--> "+sLabel);
        %><%=HTMLEntities.htmlentities(sLabel)%><%
    }
    else{
        Debug.println("--> no found");
    }
%>    