<%@page import="be.openclinic.hr.Contract,
                be.mxs.common.util.system.HTMLEntities,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
	String sContractUid = checkString(request.getParameter("ContractUid"));

	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
	    Debug.println("\n***************** getContract.jsp ******************");
	    Debug.println("sContractUid : "+sContractUid+"\n");
	}
	///////////////////////////////////////////////////////////////////////////

    Contract contract = Contract.get(sContractUid);
%>

{ 
  "contractId":"<%=Integer.toString(contract.objectId)%>",
  "beginDate":"<%=(contract.beginDate!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(contract.beginDate)):"")%>",
  "endDate":"<%=(contract.endDate!=null?HTMLEntities.htmlentities(ScreenHelper.getSQLDate(contract.endDate)):"")%>",
  "functionCode":"<%=HTMLEntities.htmlentities(contract.functionCode)%>",
  "functionTitle":"<%=HTMLEntities.htmlentities(contract.functionTitle)%>",
  "functionDescription":"<%=HTMLEntities.htmlentities(contract.functionDescription.replaceAll("\r\n","<br>"))%>",
  "ref1":"<%=HTMLEntities.htmlentities(contract.ref1)%>",
  "ref2":"<%=HTMLEntities.htmlentities(contract.ref2)%>",
  "ref3":"<%=HTMLEntities.htmlentities(contract.ref3)%>",
  "ref4":"<%=HTMLEntities.htmlentities(contract.ref4)%>",
  "ref5":"<%=HTMLEntities.htmlentities(contract.ref5)%>"
}