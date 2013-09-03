<%@ page import="be.openclinic.medical.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%
	String name="",unit="",provider="",productuid="",productname="";
	String uid = checkString(request.getParameter("FindReagentUid"));
	if(uid.length()>0){
		Reagent reagent = Reagent.get(uid);
		if(reagent!=null){
			name=reagent.getName();
			unit=reagent.getUnit();
			provider=reagent.getProvider();
			if(reagent.getProduct()!=null){
				productuid=reagent.getProduct().getUid();
				productname=reagent.getProduct().getName();
			}
		}
	}
%>
{
"Name":"<%=name%>",
"Unit":"<%=unit%>",
"Provider":"<%=provider%>",
"ProductUid":"<%=productuid%>",
"ProductName":"<%=productname%>"
}