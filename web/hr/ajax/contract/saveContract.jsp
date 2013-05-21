<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.hr.Contract,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditContractUid = checkString(request.getParameter("EditContractUid")),
           sPersonId        = checkString(request.getParameter("PersonId"));

	String sBeginDate           = checkString(request.getParameter("beginDate")),
	       sEndDate             = checkString(request.getParameter("endDate")),
	       sFunctionCode        = checkString(request.getParameter("functionCode")),
	       sFunctionTitle       = checkString(request.getParameter("functionTitle")),
	       sFunctionDescription = checkString(request.getParameter("functionDescription"));
	
	String sRef1 = checkString(request.getParameter("ref1")),
	       sRef2 = checkString(request.getParameter("ref2")),
	       sRef3 = checkString(request.getParameter("ref3")),
	       sRef4 = checkString(request.getParameter("ref4")),
	       sRef5 = checkString(request.getParameter("ref5"));
       
	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n***************** saveContract.jsp ****************");
	    Debug.println("sEditContractUid     : "+sEditContractUid);
	    Debug.println("sPersonId            : "+sPersonId);
	    Debug.println("sBeginDate           : "+sBeginDate);
	    Debug.println("sEndDate             : "+sEndDate);
	    Debug.println("sFunctionCode        : "+sFunctionCode);
	    Debug.println("sFunctionTitle       : "+sFunctionTitle);
	    Debug.println("sFunctionDescription : "+sFunctionDescription);
	    
	    Debug.println("sRef1 : "+sRef1);
	    Debug.println("sRef2 : "+sRef2);
	    Debug.println("sRef3 : "+sRef3);
	    Debug.println("sRef4 : "+sRef4);
	    Debug.println("sRef5 : "+sRef5+"\n");
	}
	///////////////////////////////////////////////////////////////////////////


    Contract contract = new Contract();
    contract.personId = Integer.parseInt(sPersonId);
	String sMessage = "";
	
    if(sEditContractUid.length() > 0){
    	contract.setUid(sEditContractUid);
    }
    else{
    	contract.setUid("-1");
    	contract.setCreateDateTime(getSQLTime());
    }

    if(sBeginDate.length() > 0){
    	contract.beginDate = ScreenHelper.stdDateFormat.parse(sBeginDate);
    }
    if(sEndDate.length() > 0){
    	contract.endDate = ScreenHelper.stdDateFormat.parse(sEndDate);
    }

    contract.functionCode = sFunctionCode;
    contract.functionTitle = sFunctionTitle;
    contract.functionDescription = sFunctionDescription;
    contract.ref1 = sRef1;
    contract.ref2 = sRef2;
    contract.ref3 = sRef3;
    contract.ref4 = sRef4;
    contract.ref5 = sRef5;
    contract.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    contract.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = contract.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = getTran("web","dataIsSaved",sWebLanguage);
    }
    else{
        sMessage = getTran("web","error",sWebLanguage);
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUid":"<%=contract.getUid()%>"
}