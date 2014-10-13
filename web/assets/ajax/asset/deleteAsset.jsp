<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.assets.Asset"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sAssetUID = checkString(request.getParameter("AssetUID"));
       
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n**************** deleteAsset.jsp ******************");
        Debug.println("sAssetUID : "+sAssetUID+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////

    
    boolean errorOccurred = Asset.delete(sAssetUID);
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