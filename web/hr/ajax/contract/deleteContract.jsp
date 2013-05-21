<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Contract"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sContractUid = checkString(request.getParameter("ContractUid"));
       
	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n**************** deleteContract.jsp ***************");
	    Debug.println("sContractUid : "+sContractUid+"\n");
	}
	///////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = Contract.delete(sContractUid);
	String sMessage = "";
    
    if(!errorOccurred){
        sMessage = getTran("web","dataIsDeleted",sWebLanguage);
    }
    else{
        sMessage = getTran("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}