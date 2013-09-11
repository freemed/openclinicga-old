<%@page import="be.mxs.common.util.system.HTMLEntities,
                be.openclinic.assets.MaintenanceOperation,
                java.util.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>

<%
    String sEditOperationUID = checkString(request.getParameter("EditOperationUID"));

    String sMaintenancePlanUID = ScreenHelper.checkString(request.getParameter("maintenancePlanUID")),
           sDate               = ScreenHelper.checkString(request.getParameter("date")),
           sOperator           = ScreenHelper.checkString(request.getParameter("operator")),
           sResult             = ScreenHelper.checkString(request.getParameter("result")),
           sComment            = ScreenHelper.checkString(request.getParameter("comment")),
           sNextDate           = ScreenHelper.checkString(request.getParameter("nextDate"));
        
    
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*********** saveMaintenanceOperation.jsp ***********");
        Debug.println("sEditOperationUID     : "+sEditOperationUID);
        Debug.println("sMaintenancePlanUID   : "+sMaintenancePlanUID);
        Debug.println("sDate                 : "+sDate);
        Debug.println("sOperator             : "+sOperator);
        Debug.println("sResult               : "+sResult);
        Debug.println("sComment              : "+sComment);
        Debug.println("sNextDate             : "+sNextDate+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////


    MaintenanceOperation operation = new MaintenanceOperation();
    String sMessage = "";
    
    if(sEditOperationUID.length() > 0){
        operation.setUid(sEditOperationUID);
    }
    else{
        operation.setUid("-1");
        operation.setCreateDateTime(getSQLTime());
    }

    operation.maintenanceplanUID = sMaintenancePlanUID;
    
    // date
    if(sDate.length() > 0){
        operation.date = ScreenHelper.stdDateFormat.parse(sDate);
    }
    
    operation.operator = sOperator;
    operation.result = sResult;
    operation.comment = sComment;
    
    // nextDate
    if(sNextDate.length() > 0){
        operation.nextDate = ScreenHelper.stdDateFormat.parse(sNextDate);
    }

    operation.setUpdateDateTime(ScreenHelper.getSQLDate(getDate()));
    operation.setUpdateUser(activeUser.userid);
    
    boolean errorOccurred = operation.store(activeUser.userid);
    
    if(!errorOccurred){
        sMessage = "<font color='green'>"+getTran("web","dataIsSaved",sWebLanguage)+"</font>";
    }
    else{
        sMessage = "<font color='red'>"+getTran("web","error",sWebLanguage)+"</font>";
    }
%>

{
  "message":"<%=HTMLEntities.htmlentities(sMessage)%>",
  "newUID":"<%=operation.getUid()%>"
}