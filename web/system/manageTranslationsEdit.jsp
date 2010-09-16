<%@ page import="be.mxs.common.util.system.HTMLEntities" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
    String editOldLabelID   = checkString(request.getParameter("EditOldLabelID")).toLowerCase(),
           editOldLabelType = checkString(request.getParameter("EditOldLabelType")).toLowerCase();

    String tmpLang, sOutput = "", sEditShowlink = "", sValue;
    Label label = null;
    // supported languages
    String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
    if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";

    StringTokenizer tokenizer = new StringTokenizer(supportedLanguages, ",");
    while (tokenizer.hasMoreTokens()) {
        tmpLang = tokenizer.nextToken();
        label = Label.get(editOldLabelType,editOldLabelID,tmpLang);

        if (label!=null){
            sEditShowlink = label.showLink;
            sValue = HTMLEntities.htmlentities(label.value.replaceAll("\n","<BR>").replaceAll("\r",""));
        }
        else {
            sValue = "";
        }

        sOutput += "\"EditLabelValue"+tmpLang.toUpperCase()+"\":\""+sValue+"\",";
    }
%>
{
<%=sOutput%>
"editShowLink":"<%=sEditShowlink%>"
}
