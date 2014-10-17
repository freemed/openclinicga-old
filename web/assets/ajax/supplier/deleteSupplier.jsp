<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.assets.Supplier"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sSupplierUID = checkString(request.getParameter("SupplierUID"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** assets/ajax/supplier/deleteSupplier.jsp **************");
        Debug.println("sSupplierUID : "+sSupplierUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = Supplier.delete(sSupplierUID);
    String sMessage = "";
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTranNoLink("web","dataIsDeleted",sWebLanguage)+"</font>";
    }
    else{
        sMessage = "<font color='red'>"+getTranNoLink("web","error",sWebLanguage)+"</font>";
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>"
}