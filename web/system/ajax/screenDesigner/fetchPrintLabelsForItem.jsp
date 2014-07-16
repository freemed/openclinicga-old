<%@page import="be.mxs.common.util.system.HTMLEntities"%>
<%@page import="be.openclinic.system.Screen"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sItemTypeId = checkString(request.getParameter("ItemTypeId")),
    	   sCellId     = checkString(request.getParameter("CellId"));

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n######## system/ajax/screenDesigner/fetchPrintlabelsForItem.jsp ########");
        Debug.println("sItemTypeId : "+sItemTypeId);
        Debug.println("sCellId     : "+sCellId+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    Screen screen = (Screen)session.getAttribute("screen");
%>

{
	<%		
		// supported languages
		String supportedLanguages = MedwanQuery.getInstance().getConfigString("supportedLanguages");
		if(supportedLanguages.length()==0) supportedLanguages = "nl,fr";
		supportedLanguages = supportedLanguages.toLowerCase();
		
		// print language selector
		StringTokenizer tokenizer = new StringTokenizer(supportedLanguages,",");
		String tmpLang, sValue = "";
		
		while(tokenizer.hasMoreTokens()){
			tmpLang = tokenizer.nextToken().toUpperCase();
		    sValue = ScreenHelper.getTranNoId("web.occup",ScreenHelper.ITEM_PREFIX+"ITEM_TYPE_CUSTOMEXAM_"+sCellId+"_"+sItemTypeId,tmpLang);
			Debug.println(tmpLang+" --> "+sValue);

		    if(sValue.length() > 0){
		        %>"<%=tmpLang%>":"<%=HTMLEntities.htmlentities(sValue)%>",<%
		    }
		}	
	%>
	"itemTypeId":"<%=sItemTypeId%>"
}