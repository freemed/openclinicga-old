<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sLabelType = checkString(request.getParameter("LabelType")),
           sLabelId   = checkString(request.getParameter("LabelId"));

    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
    	Debug.println("\n***************** ajax/blurLabel.jsp ***************");
    	Debug.println("sLabelType : "+sLabelType);
    	Debug.println("sLabelId   : "+sLabelId);
    }
    ///////////////////////////////////////////////////////////////////////////

    String sLabel = "";
    if(sLabelType.length() > 0 && sLabelId.length() > 0){
    	sLabel = ScreenHelper.getTranNoId(sLabelType,sLabelId,sWebLanguage);
    	sLabel = HTMLEntities.htmlentities(sLabel);
    	Debug.println(" --> sLabel : "+sLabel);
    }
%>

<%=sLabel%>